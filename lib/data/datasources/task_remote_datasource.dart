import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taskmanagerapp/core/errors/failures.dart';
import 'package:taskmanagerapp/data/models/task_model.dart';
import 'package:taskmanagerapp/domain/entities/task_entity.dart';

abstract class TaskRemoteDataSource {
  Stream<List<TaskModel>> getTasksStream();
  Future<void> createTask(TaskModel task);
  Future<void> updateTask(TaskModel task);
  Future<void> deleteTask(String taskId);
  Future<void> updateTaskStatus(String taskId, TaskCompletionStatus status);
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final FirebaseFirestore _firestore;

  TaskRemoteDataSourceImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _taskCollection =>
      _firestore.collection('Task');

  @override
  Stream<List<TaskModel>> getTasksStream() {

    return _taskCollection
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => TaskModel.fromSnapshot(doc)).toList();
        }).handleError((error) {
          throw ServerFailure('Firestore Error: ${error.toString()}');
        });
  }

  @override
  Future<void> createTask(TaskModel task) async {
    try {
      await _taskCollection.add(task.toMap());
    } catch (e) {
      throw ServerFailure('Failed to create task: ${e.toString()}');
    }
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    try {
      await _taskCollection.doc(task.id).update(task.toMap());
    } catch (e) {
      throw ServerFailure('Failed to update task: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteTask(String taskId) async {
    try {
      await _taskCollection.doc(taskId).delete();
    } catch (e) {
      throw ServerFailure('Failed to delete task: ${e.toString()}');
    }
  }

  @override
  Future<void> updateTaskStatus(
    String taskId,
    TaskCompletionStatus status,
  ) async {
    final statusStr = status.name;

    try {
      await _taskCollection.doc(taskId).update({
        'completion_status': statusStr,
      });
    } catch (e) {
      throw ServerFailure(
        'Failed to update completion status: ${e.toString()}',
      );
    }
  }
}
