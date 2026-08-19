import 'package:equatable/equatable.dart';
import 'package:taskmanagerapp/domain/entities/task_entity.dart';
import 'package:taskmanagerapp/presentation/bloc/task/task_event.dart';

enum TaskBlocStatus { initial, loading, success, failure }

class TaskState  {
  final TaskBlocStatus status;
  final List<TaskEntity> allTasks;
  final String searchQuery;
  final TaskStatusFilter statusFilter;
  final TaskSortOption sortOption;
  final bool isOnline;
  final bool isSyncing;
  final String? errorMessage;
  final String? actionSuccessMessage;

  const TaskState({
    this.status = TaskBlocStatus.initial,
    this.allTasks = const [],
    this.searchQuery = '',
    this.statusFilter = TaskStatusFilter.all,
    this.sortOption = TaskSortOption.dueDateAsc,
    this.isOnline = true,
    this.isSyncing = false,
    this.errorMessage,
    this.actionSuccessMessage,
  });

 
  List<TaskEntity> get filteredTasks 
  {
    List<TaskEntity> result = List.from(allTasks);

    // 1. Search by title & description
    if (searchQuery.trim().isNotEmpty) {
      final query = searchQuery.trim().toLowerCase();
      result = result.where((task) {
        return task.title.toLowerCase().contains(query) ||
            task.description.toLowerCase().contains(query);
      }).toList();
    }

    // 2. Filter by status (all, pending, started, completed, dropped)
    switch (statusFilter) {
      case TaskStatusFilter.pending:
        result = result.where((task) => task.status == TaskCompletionStatus.pending).toList();
        break;
      case TaskStatusFilter.started:
        result = result.where((task) => task.status == TaskCompletionStatus.started).toList();
        break;
      case TaskStatusFilter.completed:
        result = result.where((task) => task.status == TaskCompletionStatus.completed).toList();
        break;
      case TaskStatusFilter.dropped:
        result = result.where((task) => task.status == TaskCompletionStatus.dropped).toList();
        break;
      case TaskStatusFilter.all:
        break;
    }

    // 3. Sort by chosen option
    result.sort((a, b) {
      switch (sortOption) {
        case TaskSortOption.dueDateAsc:
          return a.dueDate.compareTo(b.dueDate);
        case TaskSortOption.dueDateDesc:
          return b.dueDate.compareTo(a.dueDate);
        case TaskSortOption.priorityHighToLow:
          final priorityMap = {
            TaskPriority.high: 3,
            TaskPriority.medium: 2,
            TaskPriority.low: 1,
          };
          final valA = priorityMap[a.priority] ?? 0;
          final valB = priorityMap[b.priority] ?? 0;
          if (valA != valB) return valB.compareTo(valA);
          return a.dueDate.compareTo(b.dueDate);
        case TaskSortOption.createdDateDesc:
          return b.createdDate.compareTo(a.createdDate);
      }
    });

    return result;
  }

  int get totalTasksCount => allTasks.length;
  int get pendingTasksCount => allTasks.where((t) => t.status == TaskCompletionStatus.pending).length;
  int get startedTasksCount => allTasks.where((t) => t.status == TaskCompletionStatus.started).length;
  int get completedTasksCount => allTasks.where((t) => t.status == TaskCompletionStatus.completed).length;
  int get droppedTasksCount => allTasks.where((t) => t.status == TaskCompletionStatus.dropped).length;

  TaskState copyWith({
    TaskBlocStatus? status,
    List<TaskEntity>? allTasks,
    String? searchQuery,
    TaskStatusFilter? statusFilter,
    TaskSortOption? sortOption,
    bool? isOnline,
    bool? isSyncing,
    String? errorMessage,
    String? actionSuccessMessage,
  }) {
    return TaskState(
      status: status ?? this.status,
      allTasks: allTasks ?? this.allTasks,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
      sortOption: sortOption ?? this.sortOption,
      isOnline: isOnline ?? this.isOnline,
      isSyncing: isSyncing ?? this.isSyncing,
      errorMessage: errorMessage,
      actionSuccessMessage: actionSuccessMessage,
    );
  }


}
