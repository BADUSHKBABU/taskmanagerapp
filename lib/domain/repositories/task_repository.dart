import 'package:taskmanagerapp/domain/entities/task_entity.dart';

abstract class TaskRepository {
  Stream<List<TaskEntity>> getTasksStream();
  Future<void> createTask(TaskEntity task);
  Future<void> updateTask(TaskEntity task);
  Future<void> deleteTask(String taskId);
  Future<void> updateTaskStatus(String taskId, TaskCompletionStatus status);
}
