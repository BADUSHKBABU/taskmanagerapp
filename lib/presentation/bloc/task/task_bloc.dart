import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:taskmanagerapp/core/errors/failures.dart';
import 'package:taskmanagerapp/core/network/network_info.dart';
import 'package:taskmanagerapp/domain/entities/task_entity.dart';
import 'package:taskmanagerapp/domain/usecases/task_usecases.dart';
import 'package:taskmanagerapp/presentation/bloc/task/task_event.dart';
import 'package:taskmanagerapp/presentation/bloc/task/task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final GetTasksStreamUseCase getTasksStreamUseCase;
  final CreateTaskUseCase createTaskUseCase;
  final UpdateTaskUseCase updateTaskUseCase;
  final DeleteTaskUseCase deleteTaskUseCase;
  final ToggleTaskStatusUseCase toggleTaskStatusUseCase;
  final NetworkInfo networkInfo;

  StreamSubscription<List<TaskEntity>>? _tasksSubscription;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  TaskBloc({
    required this.getTasksStreamUseCase,
    required this.createTaskUseCase,
    required this.updateTaskUseCase,
    required this.deleteTaskUseCase,
    required this.toggleTaskStatusUseCase,
    required this.networkInfo,
  }) : super(const TaskState()) {
    on<SubscribeTasksEvent>(_onSubscribeTasks);
    on<TasksUpdatedEvent>(_onTasksUpdated);
    on<TasksErrorEvent>(_onTasksError);
    on<SearchTasksEvent>(_onSearchTasks);
    on<FilterTasksEvent>(_onFilterTasks);
    on<SortTasksEvent>(_onSortTasks);
    on<ConnectivityChangedEvent>(_onConnectivityChanged);
    on<CreateTaskEvent>(_onCreateTask);
    on<UpdateTaskEvent>(_onUpdateTask);
    on<DeleteTaskEvent>(_onDeleteTask);
    on<ToggleTaskStatusEvent>(_onToggleTaskStatus);

    _initConnectivity();
    add(const SubscribeTasksEvent());
  }

  void _initConnectivity() async {
    final isConnected = await networkInfo.isConnected;
    add(ConnectivityChangedEvent(isConnected));

    _connectivitySubscription = networkInfo.onConnectivityChanged.listen((results) {
      final isNowOnline = !results.contains(ConnectivityResult.none);
      add(ConnectivityChangedEvent(isNowOnline));
    });
  }

  void _onSubscribeTasks(SubscribeTasksEvent event, Emitter<TaskState> emit) {
    emit(state.copyWith(status: TaskBlocStatus.loading, errorMessage: null));
    _tasksSubscription?.cancel();
    _tasksSubscription = getTasksStreamUseCase().listen(
      (tasks) => add(TasksUpdatedEvent(tasks)),
      onError: (error) {
        final message = error is Failure ? error.message : error.toString();
        add(TasksErrorEvent(message));
      },
    );
  }

  void _onTasksUpdated(TasksUpdatedEvent event, Emitter<TaskState> emit) {
    emit(state.copyWith(
      status: TaskBlocStatus.success,
      allTasks: event.tasks,
      isSyncing: false,
      errorMessage: null,
    ));
  }

  void _onTasksError(TasksErrorEvent event, Emitter<TaskState> emit) {
    emit(state.copyWith(
      status: TaskBlocStatus.failure,
      isSyncing: false,
      errorMessage: event.errorMessage,
    ));
  }

  void _onSearchTasks(SearchTasksEvent event, Emitter<TaskState> emit) {
    emit(state.copyWith(searchQuery: event.query));
  }

  void _onFilterTasks(FilterTasksEvent event, Emitter<TaskState> emit) {
    emit(state.copyWith(statusFilter: event.filter));
  }

  void _onSortTasks(SortTasksEvent event, Emitter<TaskState> emit) {
    emit(state.copyWith(sortOption: event.sortOption));
  }

  void _onConnectivityChanged(ConnectivityChangedEvent event, Emitter<TaskState> emit) {
    emit(state.copyWith(isOnline: event.isOnline));
  }

  Future<void> _onCreateTask(CreateTaskEvent event, Emitter<TaskState> emit) async {
    emit(state.copyWith(isSyncing: true));
    try {
      await createTaskUseCase(event.task);
      emit(state.copyWith(
        isSyncing: false,
        actionSuccessMessage: 'Task created successfully',
      ));
    } catch (e) {
      final message = e is Failure ? e.message : e.toString();
      emit(state.copyWith(isSyncing: false, errorMessage: message));
    }
  }

  Future<void> _onUpdateTask(UpdateTaskEvent event, Emitter<TaskState> emit) async {
    final originalTasks = state.allTasks;
    final updatedTasks = state.allTasks.map((t) {
      return t.id == event.task.id ? event.task : t;
    }).toList();

    emit(state.copyWith(allTasks: updatedTasks, isSyncing: true));

    try {
      await updateTaskUseCase(event.task);
      emit(state.copyWith(
        isSyncing: false,
        actionSuccessMessage: 'Task updated successfully',
      ));
    } catch (e) {
      final message = e is Failure ? e.message : e.toString();
      emit(state.copyWith(allTasks: originalTasks, isSyncing: false, errorMessage: message));
    }
  }

  Future<void> _onDeleteTask(DeleteTaskEvent event, Emitter<TaskState> emit) async {
    final originalTasks = state.allTasks;
    final updatedTasks = state.allTasks.where((t) => t.id != event.taskId).toList();

    emit(state.copyWith(allTasks: updatedTasks, isSyncing: true));

    try {
      await deleteTaskUseCase(event.taskId);
      emit(state.copyWith(
        isSyncing: false,
        actionSuccessMessage: 'Task deleted',
      ));
    } catch (e) {
      final message = e is Failure ? e.message : e.toString();
      emit(state.copyWith(allTasks: originalTasks, isSyncing: false, errorMessage: message));
    }
  }

  Future<void> _onToggleTaskStatus(ToggleTaskStatusEvent event, Emitter<TaskState> emit) async {
    final originalTasks = state.allTasks;
    // Optimistic state update
    final updatedTasks = state.allTasks.map((t) {
      if (t.id == event.taskId) {
        return t.copyWith(status: event.status);
      }
      return t;
    }).toList();

    emit(state.copyWith(allTasks: updatedTasks));

    try {
      await toggleTaskStatusUseCase(event.taskId, event.status);
    } catch (e) {
      // Revert if error occurs
      final message = e is Failure ? e.message : e.toString();
      emit(state.copyWith(allTasks: originalTasks, errorMessage: message));
    }
  }

  @override
  Future<void> close() {
    _tasksSubscription?.cancel();
    _connectivitySubscription?.cancel();
    return super.close();
  }
}
