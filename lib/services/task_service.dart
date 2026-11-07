import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../models/student_task.dart';
import 'student_storage.dart';

class TaskService extends ChangeNotifier {
  TaskService(this._storage);

  final StudentStorage _storage;
  List<StudentTask> _tasks = [];
  bool _disposed = false;

  List<StudentTask> get tasks => List.unmodifiable(_tasks);

  int get completedCount => _tasks.where((task) => task.isCompleted).length;

  StudentTask? findTask(String id) {
    for (final task in _tasks) {
      if (task.id == id) return task;
    }
    return null;
  }

  Future<void> loadTasks({bool refresh = false}) => _storage.run(() async {
        if (refresh) await _storage.reload();
        final stored = _storage.read('tasks');
        final decoded = stored == null ? [] : jsonDecode(stored) as List;
        _tasks = [
          for (final item in decoded)
            StudentTask.fromJson(item as Map<String, dynamic>),
        ];
        if (!_disposed) notifyListeners();
      });

  Future<T> _change<T>(T Function(List<StudentTask>) change) =>
      _storage.run(() async {
        final next = [..._tasks];
        final result = change(next);
        await _storage.write(
          'tasks',
          jsonEncode([for (final task in next) task.toJson()]),
        );
        _tasks = next;
        if (!_disposed) notifyListeners();
        return result;
      });

  Future<void> addTask(StudentTask task) =>
      _change((tasks) => tasks.insert(0, task));

  Future<int> removeTask(StudentTask task) => _change((tasks) {
        final index = tasks.indexWhere((item) => item.id == task.id);
        if (index != -1) tasks.removeAt(index);
        return index;
      });

  Future<void> restoreTask(StudentTask task, int index) => _change((tasks) {
        if (tasks.any((item) => item.id == task.id)) return;
        tasks.insert(index.clamp(0, tasks.length), task);
      });

  Future<void> updateTask(
    String id,
    StudentTask Function(StudentTask current) update,
  ) =>
      _change((tasks) {
        final index = tasks.indexWhere((task) => task.id == id);
        if (index == -1) throw StateError('Assignment no longer exists');
        tasks[index] = update(tasks[index]);
      });

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
