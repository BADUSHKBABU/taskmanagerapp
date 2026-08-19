import 'package:taskmanagerapp/domain/entities/task_entity.dart';
import 'package:taskmanagerapp/domain/repositories/task_repository.dart';

class GetTasksStreamUseCase {
  final TaskRepository repository;
  GetTasksStreamUseCase(this.repository);

  Stream<List<TaskEntity>> call() {
    return repository.getTasksStream();
  }
}

class CreateTaskUseCase {
  final TaskRepository repository;
  CreateTaskUseCase(this.repository);

  Future<void> call(TaskEntity task) {
    return repository.createTask(task);
  }
}

class UpdateTaskUseCase {
  final TaskRepository repository;
  UpdateTaskUseCase(this.repository);

  Future<void> call(TaskEntity task) {
    return repository.updateTask(task);
  }
}

class DeleteTaskUseCase {
  final TaskRepository repository;
  DeleteTaskUseCase(this.repository);

  Future<void> call(String taskId) {
    return repository.deleteTask(taskId);
  }
}

class ToggleTaskStatusUseCase {
  final TaskRepository repository;
  ToggleTaskStatusUseCase(this.repository);

  Future<void> call(String taskId, TaskCompletionStatus status) {
    return repository.updateTaskStatus(taskId, status);
  }
}
