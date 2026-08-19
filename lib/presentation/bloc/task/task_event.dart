import 'package:equatable/equatable.dart';
import 'package:taskmanagerapp/domain/entities/task_entity.dart';

enum TaskStatusFilter { all, pending, started, completed, dropped }
enum TaskSortOption { dueDateAsc, dueDateDesc, priorityHighToLow, createdDateDesc }

abstract class TaskEvent {
  const TaskEvent();

}

class SubscribeTasksEvent extends TaskEvent {
  const SubscribeTasksEvent();
}

class TasksUpdatedEvent extends TaskEvent {
  final List<TaskEntity> tasks;

  const TasksUpdatedEvent(this.tasks);

}

class TasksErrorEvent extends TaskEvent {
  final String errorMessage;

  const TasksErrorEvent(this.errorMessage);


}

class SearchTasksEvent extends TaskEvent {
  final String query;

  const SearchTasksEvent(this.query);


}

class FilterTasksEvent extends TaskEvent {
  final TaskStatusFilter filter;

  const FilterTasksEvent(this.filter);


}

class SortTasksEvent extends TaskEvent {
  final TaskSortOption sortOption;

  const SortTasksEvent(this.sortOption);


}

class ConnectivityChangedEvent extends TaskEvent {
  final bool isOnline;

  const ConnectivityChangedEvent(this.isOnline);

}

class CreateTaskEvent extends TaskEvent {
  final TaskEntity task;

  const CreateTaskEvent(this.task);


}

class UpdateTaskEvent extends TaskEvent {
  final TaskEntity task;

  const UpdateTaskEvent(this.task);

 
}

class DeleteTaskEvent extends TaskEvent {
  final String taskId;

  const DeleteTaskEvent(this.taskId);


}

class ToggleTaskStatusEvent extends TaskEvent {
  final String taskId;
  final TaskCompletionStatus status;

  const ToggleTaskStatusEvent(this.taskId, this.status);


}
