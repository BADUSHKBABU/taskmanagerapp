import 'package:taskmanagerapp/data/datasources/task_remote_datasource.dart';
import 'package:taskmanagerapp/data/models/task_model.dart';
import 'package:taskmanagerapp/domain/entities/task_entity.dart';
import 'package:taskmanagerapp/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource remoteDataSource;

  TaskRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<List<TaskEntity>> getTasksStream() {
    return remoteDataSource.getTasksStream();
  }

  @override
  Future<void> createTask(TaskEntity task) {
    final model = TaskModel.fromEntity(task);
    return remoteDataSource.createTask(model);
  }

  @override
  Future<void> updateTask(TaskEntity task) {
    final model = TaskModel.fromEntity(task);
    return remoteDataSource.updateTask(model);
  }

  @override
  Future<void> deleteTask(String taskId) {
    return remoteDataSource.deleteTask(taskId);
  }

  @override
  Future<void> updateTaskStatus(String taskId, TaskCompletionStatus status) {
    return remoteDataSource.updateTaskStatus(taskId, status);
  }
}
