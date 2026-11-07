import 'package:shared_preferences/shared_preferences.dart';

class StudentStorage {
  StudentStorage(this._prefs, this.email);

  final SharedPreferences _prefs;
  final String email;
  Future<void> _pending = Future.value();

  String _key(String name) => 'student.$email.$name';

  String? read(String name) => _prefs.getString(_key(name));

  Future<void> reload() => _prefs.reload();

  Future<void> write(String name, String value) async {
    if (!await _prefs.setString(_key(name), value)) {
      throw StateError('Could not save $name');
    }
  }

  Future<T> run<T>(Future<T> Function() operation) {
    final result = _pending.then((_) => operation());
    _pending = result.then<void>((_) {}, onError: (Object _, StackTrace __) {});
    return result;
  }

  Future<void> importLegacyTasks(String? originalAccount) async {
    if (email != originalAccount) return;
    final legacy = _prefs.getString('student_tasks_v1');
    if (legacy == null || read('tasks') != null) return;
    await write('tasks', legacy);
  }
}
