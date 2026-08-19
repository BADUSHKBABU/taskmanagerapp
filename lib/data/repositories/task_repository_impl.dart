import 'dart:async';
import 'package:taskmanagerapp/core/network/network_info.dart';
import 'package:taskmanagerapp/data/datasources/task_local_datasource.dart';
import 'package:taskmanagerapp/data/datasources/task_remote_datasource.dart';
import 'package:taskmanagerapp/data/models/task_model.dart';
import 'package:taskmanagerapp/domain/entities/task_entity.dart';
import 'package:taskmanagerapp/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource remoteDataSource;
  final TaskLocalDataSource localDataSource;
  final NetworkInfo? networkInfo;

  TaskRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    this.networkInfo,
  });

  @override
  Stream<List<TaskEntity>> getTasksStream() async* {
  
    final cached = localDataSource.getCachedTasks();
    if (cached.isNotEmpty) {
      yield cached;
    }

    try {
      await for (final remoteModels in remoteDataSource.getTasksStream()) {
        await localDataSource.cacheTasks(remoteModels);
        yield remoteModels;
      }
    } catch (_) {
      
      yield* localDataSource.watchCachedTasks();
    }
  }

  @override
  Future<void> createTask(TaskEntity task) async {
    final model = TaskModel.fromEntity(task);
    await localDataSource.saveTask(model);

    try {
      final isOnline = await networkInfo?.isConnected ?? true;
      if (isOnline) {
        await remoteDataSource.createTask(model);
      }
    } catch (_) {
     
    }
  }

  @override
  Future<void> updateTask(TaskEntity task) async {
    final model = TaskModel.fromEntity(task);
    await localDataSource.saveTask(model);

    try {
      final isOnline = await networkInfo?.isConnected ?? true;
      if (isOnline) {
        await remoteDataSource.updateTask(model);
      }
    } catch (_) {
     
    }
  }

  @override
  Future<void> deleteTask(String taskId) async {
    await localDataSource.deleteTask(taskId);

    try {
      final isOnline = await networkInfo?.isConnected ?? true;
      if (isOnline) {
        await remoteDataSource.deleteTask(taskId);
      }
    } catch (_) {
     
    }
  }

  @override
  Future<void> updateTaskStatus(String taskId, TaskCompletionStatus status) async {
    final cachedTasks = localDataSource.getCachedTasks();
    final index = cachedTasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      final updatedModel = TaskModel(
        id: cachedTasks[index].id,
        title: cachedTasks[index].title,
        description: cachedTasks[index].description,
        priority: cachedTasks[index].priority,
        dueDate: cachedTasks[index].dueDate,
        status: status,
        createdDate: cachedTasks[index].createdDate,
      );
      await localDataSource.saveTask(updatedModel);
    }

    try {
      final isOnline = await networkInfo?.isConnected ?? true;
      if (isOnline) {
        await remoteDataSource.updateTaskStatus(taskId, status);
      }
    } catch (_) {
     
    }
  }
}

