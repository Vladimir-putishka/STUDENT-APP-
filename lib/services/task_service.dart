import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/student_task.dart';

class TaskService extends ChangeNotifier {
  static const _storageKey = 'student_tasks_v1';

  final List<StudentTask> _tasks = [];

  List<StudentTask> get tasks => List.unmodifiable(_tasks);

  int get completedCount =>
      _tasks.where((task) => task.isCompleted).length;

  int get remainingCount => _tasks.length - completedCount;

  List<StudentTask> get _initialTasks => [
    StudentTask(
      id: 'initial_1',
      title: 'Flutter Laboratory Work 8',
      subject: 'Mobile Development',
      description:
      'Implement dynamic lists, grids, pull-to-refresh, '
          'swipe-to-delete and undo actions.',
      dueDate: 'Oct 28',
      category: 'Development',
      color: const Color(0xFF405DE6),
    ),
    StudentTask(
      id: 'initial_2',
      title: 'Marketing Analytics Presentation',
      subject: 'Marketing Analytics',
      description:
      'Prepare a presentation with competitor analysis '
          'and customer journey insights.',
      dueDate: 'Oct 30',
      category: 'Research',
      color: const Color(0xFFE59736),
    ),
    StudentTask(
      id: 'initial_3',
      title: 'Cybersecurity Midterm 2',
      subject: 'Cybersecurity',
      description:
      'Review authentication protocols, RBAC and ABAC.',
      dueDate: 'Nov 2',
      category: 'Exam',
      color: const Color(0xFF1DAB8A),
    ),
  ];

  Future<void> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_storageKey);

    _tasks.clear();

    if (stored == null) {
      _tasks.addAll(_initialTasks);
      await _saveTasks();
    } else {
      final decoded = jsonDecode(stored) as List<dynamic>;

      _tasks.addAll(
        decoded.map(
              (item) =>
              StudentTask.fromJson(item as Map<String, dynamic>),
        ),
      );
    }

    notifyListeners();
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();

    final encoded = jsonEncode(
      _tasks.map((task) => task.toJson()).toList(),
    );

    await prefs.setString(_storageKey, encoded);
  }

  Future<void> addTask(StudentTask task) async {
    _tasks.insert(0, task);
    notifyListeners();
    await _saveTasks();
  }

  Future<int> removeTask(StudentTask task) async {
    final index = _tasks.indexWhere((item) => item.id == task.id);

    if (index == -1) return -1;

    _tasks.removeAt(index);
    notifyListeners();
    await _saveTasks();

    return index;
  }

  Future<void> restoreTask(StudentTask task, int index) async {
    if (_tasks.any((item) => item.id == task.id)) return;

    final safeIndex = index.clamp(0, _tasks.length);

    _tasks.insert(safeIndex, task);
    notifyListeners();
    await _saveTasks();
  }

  Future<void> updateTask(StudentTask task) async {
    notifyListeners();
    await _saveTasks();
  }

  Future<void> resetTasks() async {
    _tasks
      ..clear()
      ..addAll(_initialTasks);

    notifyListeners();
    await _saveTasks();
  }

  Future<void> simulateRefresh() async {
    await Future.delayed(
      const Duration(milliseconds: 1500),
    );

    final task = StudentTask(
      id: 'refresh_${DateTime.now().microsecondsSinceEpoch}',
      title: 'New Flutter Assignment',
      subject: 'Mobile Development',
      description:
      'New assignment received from the university platform '
          '(simulated for Laboratory Work 8).',
      dueDate: 'Nov 5',
      category: 'Development',
      color: const Color(0xFF405DE6),
    );

    _tasks.insert(0, task);
    notifyListeners();
    await _saveTasks();
  }
}