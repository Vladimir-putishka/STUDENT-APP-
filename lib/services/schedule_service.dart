import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../models/class_session.dart';
import 'student_storage.dart';

class ScheduleService extends ChangeNotifier {
  ScheduleService(this._storage);

  final StudentStorage _storage;
  List<ClassSession> _sessions = [];
  bool _disposed = false;

  List<ClassSession> forWeekday(int weekday) =>
      _sessions.where((session) => session.weekday == weekday).toList()
        ..sort((a, b) => a.startMinute.compareTo(b.startMinute));

  void load() {
    final saved = _storage.read('schedule');
    if (saved == null) return;
    _sessions = [
      for (final json in jsonDecode(saved) as List)
        ClassSession.fromJson(json as Map<String, dynamic>),
    ];
  }

  Future<void> _change(void Function(List<ClassSession>) change) =>
      _storage.run(() async {
        final next = [..._sessions];
        change(next);
        await _storage.write(
          'schedule',
          jsonEncode([for (final session in next) session.toJson()]),
        );
        _sessions = next;
        if (!_disposed) notifyListeners();
      });

  Future<void> save(ClassSession session) => _change((sessions) {
        sessions.removeWhere((item) => item.id == session.id);
        sessions.add(session);
      });

  Future<void> remove(String id) => _change(
      (sessions) => sessions.removeWhere((session) => session.id == id));

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
