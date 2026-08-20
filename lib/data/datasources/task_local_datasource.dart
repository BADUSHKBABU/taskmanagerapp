import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:taskmanagerapp/data/models/task_model.dart';

abstract class TaskLocalDataSource {
  List<TaskModel> getCachedTasks();
  Stream<List<TaskModel>> watchCachedTasks();
  Future<void> cacheTasks(List<TaskModel> tasks);
  Future<void> saveTask(TaskModel task);
  Future<void> deleteTask(String taskId);
}

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  static const String boxName = 'tasks_box';
  final Box _box;

  TaskLocalDataSourceImpl({Box? box})
      : _box = box ?? Hive.box(boxName);

  @override
  List<TaskModel> getCachedTasks() {
    final List<TaskModel> tasks = [];
    for (final key in _box.keys) {
      final value = _box.get(key);
      if (value != null && value is Map) {
        try {
          final map = Map<String, dynamic>.from(value);
          final id = key.toString();
          tasks.add(TaskModel.fromMap(map, id));
        } catch (_) {}
      }
    }
    return tasks;
  }

  @override
  Stream<List<TaskModel>> watchCachedTasks() async* {
    yield getCachedTasks();
    yield* _box.watch().map((_) => getCachedTasks());
  }

  @override
  Future<void> cacheTasks(List<TaskModel> tasks) async {
    final Map<String, dynamic> mapToPut = {};
    for (final task in tasks) {
      mapToPut[task.id] = task.toMap();
    }
    await _box.clear();
    await _box.putAll(mapToPut);
  }

  @override
  Future<void> saveTask(TaskModel task) async {
    await _box.put(task.id, task.toMap());
  }

  @override
  Future<void> deleteTask(String taskId) async {
    await _box.delete(taskId);
  }
}
