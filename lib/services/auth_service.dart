import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _usersKey = 'app_users_v2';
  static const String _sessionKey = 'app_session_v2';

  static const int _iterations = 100000;

  static String _generateSalt() {
    final random = Random.secure();

    final bytes = List<int>.generate(
      16,
          (_) => random.nextInt(256),
    );

    return base64Encode(bytes);
  }

  static List<int> _hashPassword(
      String password,
      List<int> salt,
      ) {
    final hmac = Hmac(sha256, utf8.encode(password));

    final block = [...salt, 0, 0, 0, 1];

    var u = hmac.convert(block).bytes;
    final result = List<int>.from(u);

    for (var i = 1; i < _iterations; i++) {
      u = hmac.convert(u).bytes;

      for (var j = 0; j < result.length; j++) {
        result[j] ^= u[j];
      }
    }

    return result;
  }

  static Future<List<Map<String, dynamic>>> _getUsers() async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getString(_usersKey);

    if (data == null) {
      return [];
    }

    final decoded = jsonDecode(data) as List<dynamic>;

    return decoded
        .map((user) => Map<String, dynamic>.from(user as Map))
        .toList();
  }

  static Future<void> _saveUsers(
      List<Map<String, dynamic>> users,
      ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _usersKey,
      jsonEncode(users),
    );
  }

  // REGISTER

  static Future<void> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    final users = await _getUsers();

    final normalizedEmail = email.trim().toLowerCase();

    final exists = users.any(
          (user) => user['email'] == normalizedEmail,
    );

    if (exists) {
      throw StateError('This email is already registered.');
    }

    final salt = _generateSalt();

    final passwordHash = _hashPassword(
      password,
      base64Decode(salt),
    );

    users.add({
      'name': name.trim(),
      'email': normalizedEmail,
      'role': role,
      'salt': salt,
      'passwordHash': base64Encode(passwordHash),
    });

    await _saveUsers(users);

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _sessionKey,
      normalizedEmail,
    );
  }

  // LOGIN

  static Future<bool> login({
    required String email,
    required String password,
  }) async {
    final users = await _getUsers();

    final normalizedEmail = email.trim().toLowerCase();

    Map<String, dynamic>? foundUser;

    for (final user in users) {
      if (user['email'] == normalizedEmail) {
        foundUser = user;
        break;
      }
    }

    if (foundUser == null) {
      return false;
    }

    final salt = base64Decode(foundUser['salt'] as String);

    final expectedHash = base64Decode(
      foundUser['passwordHash'] as String,
    );

    final enteredHash = _hashPassword(password, salt);

    if (expectedHash.length != enteredHash.length) {
      return false;
    }

    var difference = 0;

    for (var i = 0; i < expectedHash.length; i++) {
      difference |= expectedHash[i] ^ enteredHash[i];
    }

    if (difference != 0) {
      return false;
    }

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _sessionKey,
      normalizedEmail,
    );

    return true;
  }

  // CURRENT USER

  static Future<Map<String, String>?> currentUser() async {
    final prefs = await SharedPreferences.getInstance();

    final email = prefs.getString(_sessionKey);

    if (email == null) {
      return null;
    }

    final users = await _getUsers();

    for (final user in users) {
      if (user['email'] == email) {
        return {
          'name': user['name'] as String,
          'email': user['email'] as String,
          'role': user['role'] as String,
        };
      }
    }

    return null;
  }

  // LOGOUT

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_sessionKey);
  }

  // CHECK ACCOUNT

  static Future<bool> hasAccount() async {
    final users = await _getUsers();
    return users.isNotEmpty;
  }
}