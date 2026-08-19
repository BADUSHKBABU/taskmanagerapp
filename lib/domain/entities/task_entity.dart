enum TaskPriority { high, medium, low }

enum TaskCompletionStatus { pending, started, completed, dropped }

class TaskEntity {
  final String id;
  final String title;
  final String description;
  final TaskPriority priority;
  final DateTime dueDate;
  final TaskCompletionStatus status;
  final DateTime createdDate;

  const TaskEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.dueDate,
    required this.status,
    required this.createdDate,
  });

  bool get isCompleted => status == TaskCompletionStatus.completed;

  TaskEntity copyWith({
    String? id,
    String? title,
    String? description,
    TaskPriority? priority,
    DateTime? dueDate,
    TaskCompletionStatus? status,
    DateTime? createdDate,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      createdDate: createdDate ?? this.createdDate,
    );
  }
}
