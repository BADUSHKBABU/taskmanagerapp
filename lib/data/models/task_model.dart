import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taskmanagerapp/domain/entities/task_entity.dart';

class TaskModel extends TaskEntity {
  const TaskModel({
    required super.id,
    required super.title,
    required super.description,
    required super.priority,
    required super.dueDate,
    required super.status,
    required super.createdDate,
  });

  factory TaskModel.fromMap(Map<String, dynamic> map, String id) {
    // Parse priority
    TaskPriority priority = TaskPriority.medium;
    final priorityStr = (map['priority'] as String? ?? 'Medium').toLowerCase();
    if (priorityStr == 'high') {
      priority = TaskPriority.high;
    } else if (priorityStr == 'low') {
      priority = TaskPriority.low;
    }

    // Parse completion_status (pending, started, completed, dropped, or legacy boolean)
    TaskCompletionStatus status = TaskCompletionStatus.pending;
    final rawStatus = map['completion_status'];
    if (rawStatus is bool) {
      status = rawStatus ? TaskCompletionStatus.completed : TaskCompletionStatus.pending;
    } else if (rawStatus is String) {
      final statusLower = rawStatus.toLowerCase().trim();
      switch (statusLower) {
        case 'started':
        case 'in_progress':
          status = TaskCompletionStatus.started;
          break;
        case 'completed':
        case 'true':
          status = TaskCompletionStatus.completed;
          break;
        case 'dropped':
        case 'droped':
        case 'cancelled':
          status = TaskCompletionStatus.dropped;
          break;
        case 'pending':
        case 'false':
        default:
          status = TaskCompletionStatus.pending;
          break;
      }
    }

    // Helper to parse dates
    DateTime parseDate(dynamic dateVal) {
      if (dateVal is Timestamp) return dateVal.toDate();
      if (dateVal is DateTime) return dateVal;
      if (dateVal is String && dateVal.trim().isNotEmpty) {
        try {
          return DateTime.parse(dateVal);
        } catch (_) {}
      }
      return DateTime.now();
    }

    final dueDate = parseDate(map['due_date']);
    final createdDate = parseDate(map['crated_date'] ?? map['created_date']);

    return TaskModel(
      id: id,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      priority: priority,
      dueDate: dueDate,
      status: status,
      createdDate: createdDate,
    );
  }

  factory TaskModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return TaskModel.fromMap(data, doc.id);
  }

  Map<String, dynamic> toMap() {
    String priorityStr = 'Medium';
    switch (priority) {
      case TaskPriority.high:
        priorityStr = 'High';
        break;
      case TaskPriority.medium:
        priorityStr = 'Medium';
        break;
      case TaskPriority.low:
        priorityStr = 'Low';
        break;
    }

    String statusStr = 'pending';
    switch (status) {
      case TaskCompletionStatus.pending:
        statusStr = 'pending';
        break;
      case TaskCompletionStatus.started:
        statusStr = 'started';
        break;
      case TaskCompletionStatus.completed:
        statusStr = 'completed';
        break;
      case TaskCompletionStatus.dropped:
        statusStr = 'dropped';
        break;
    }

    return {
      'title': title,
      'description': description,
      'priority': priorityStr,
      'due_date': dueDate.toIso8601String(),
      'completion_status': statusStr,
      'crated_date': createdDate.toIso8601String(),
    };
  }

  factory TaskModel.fromEntity(TaskEntity entity) {
    return TaskModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      priority: entity.priority,
      dueDate: entity.dueDate,
      status: entity.status,
      createdDate: entity.createdDate,
    );
  }
}
