import 'package:flutter/material.dart';

import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/main_navigation.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const StudentAssistantApp());
}

class StudentAssistantApp extends StatefulWidget {
  const StudentAssistantApp({super.key});

  @override
  State<StudentAssistantApp> createState() =>
      _StudentAssistantAppState();
}

class _StudentAssistantAppState extends State<StudentAssistantApp> {

  // AUTHENTICATION STATE

  bool isLoading = true;
  bool isLoggedIn = false;
  bool showRegistration = false;

  // USER DATA

  String userName = '';
  String userEmail = '';
  String userRole = '';

  // INITIALIZE APPLICATION

  @override
  void initState() {
    super.initState();
    loadSession();
  }

  // LOAD SAVED SESSION

  Future<void> loadSession() async {
    try {
      final user = await AuthService.currentUser();

      if (!mounted) return;

      setState(() {
        isLoggedIn = user != null;

        if (user != null) {
          userName = user['name'] ?? '';
          userEmail = user['email'] ?? '';
          userRole = user['role'] ?? 'Student';
          showRegistration = false;
        } else {
          userName = '';
          userEmail = '';
          userRole = '';
        }

        isLoading = false;
      });
    } catch (error) {
      debugPrint('Session loading error: $error');

      if (!mounted) return;

      setState(() {
        isLoading = false;
        isLoggedIn = false;
      });
    }
  }

  // OPEN REGISTRATION SCREEN

  void openRegistration() {
    setState(() {
      showRegistration = true;
    });
  }

  // OPEN LOGIN SCREEN

  void openLogin() {
    setState(() {
      showRegistration = false;
    });
  }

  // REGISTER NEW USER

  Future<void> registerUser(
      String name,
      String email,
      String password,
      String role,
      ) async {
    await AuthService.register(
      name: name,
      email: email,
      password: password,
      role: role,
    );

    await loadSession();

    debugPrint('Registration completed successfully');
  }

  // LOGIN EXISTING USER

  Future<bool> loginUser(
      String email,
      String password,
      ) async {
    final success = await AuthService.login(
      email: email,
      password: password,
    );

    if (success) {
      await loadSession();
      debugPrint('User logged in successfully');
    }

    return success;
  }

  // LOGOUT USER

  Future<void> logout() async {
    try {
      await AuthService.logout();

      if (!mounted) return;

      setState(() {
        isLoggedIn = false;
        showRegistration = false;

        userName = '';
        userEmail = '';
        userRole = '';
      });

      debugPrint('User logged out successfully');
    } catch (error) {
      debugPrint('Logout error: $error');
    }
  }

  // APPLICATION THEME

  ThemeData buildAppTheme() {
    return ThemeData(
      useMaterial3: true,

      scaffoldBackgroundColor: const Color(0xFFF6F8FD),

      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF405DE6),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF6F8FD),
        scrolledUnderElevation: 0,
      ),

      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF405DE6),
            width: 2,
          ),
        ),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF405DE6),
          foregroundColor: Colors.white,

          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // SELECT CURRENT SCREEN

  Widget buildCurrentScreen() {

    // LOADING

    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF405DE6),
          ),
        ),
      );
    }

    // MAIN APPLICATION

    if (isLoggedIn) {
      return MainNavigation(
        userName: userName,
        userEmail: userEmail,
        userRole: userRole,
        onLogout: logout,
      );
    }

    // REGISTRATION SCREEN

    if (showRegistration) {
      return RegistrationScreen(
        onRegister: registerUser,
        onLogin: openLogin,
      );
    }

    // LOGIN SCREEN

    return LoginScreen(
      onLogin: loginUser,
      onRegister: openRegistration,
    );
  }

  // BUILD APPLICATION

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Assistant',

      debugShowCheckedModeBanner: false,

      theme: buildAppTheme(),

      home: buildCurrentScreen(),
    );
  }
}