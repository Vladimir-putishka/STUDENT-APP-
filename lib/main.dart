import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/cart_provider.dart';
import 'services/auth_service.dart';
import 'services/student_storage.dart';
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
  State<StudentAssistantApp> createState() => _StudentAssistantAppState();
}

class _StudentAssistantAppState extends State<StudentAssistantApp> {
  // AUTHENTICATION STATE

  bool isLoading = true;
  bool showRegistration = false;
  bool darkMode = false;
  bool sessionError = false;
  bool isLoggingOut = false;
  StudentStorage? storage;

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
      final nextStorage = user == null
          ? null
          : StudentStorage(await SharedPreferences.getInstance(), user['email']!);

      if (!mounted) return;

      setState(() {
        storage = nextStorage;
        darkMode = nextStorage?.read('dark_mode') == 'true';
        sessionError = false;

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
        sessionError = true;
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
    if (isLoggingOut) return;
    setState(() => isLoggingOut = true);
    try {
      await AuthService.logout();

      if (!mounted) return;

      setState(() {
        storage = null;
        darkMode = false;
        showRegistration = false;

        userName = '';
        userEmail = '';
        userRole = '';
      });

      debugPrint('User logged out successfully');
    } finally {
      if (mounted) setState(() => isLoggingOut = false);
    }
  }

  Future<void> setDarkMode(bool value) async {
    final account = storage;
    if (account == null) return;
    await account.run(() async {
      await account.write('dark_mode', value.toString());
      if (mounted && storage == account) setState(() => darkMode = value);
    });
  }

  // APPLICATION THEME

  ThemeData buildAppTheme(Brightness brightness) {
    final colors = ColorScheme.fromSeed(
      seedColor: const Color(0xFF405DE6),
      brightness: brightness,
    );
    final background = brightness == Brightness.light
        ? const Color(0xFFF6F8FD)
        : colors.surface;
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      colorScheme: colors,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        scrolledUnderElevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colors.primary,
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
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
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

    if (sessionError) {
      return Scaffold(
        body: Center(
          child: FilledButton(
            onPressed: () {
              setState(() => isLoading = true);
              loadSession();
            },
            child: const Text('Could not load your account. Retry'),
          ),
        ),
      );
    }

    final account = storage;
    if (account != null) {
      return MainNavigation(
        storage: account,
        userName: userName,
        userEmail: userEmail,
        userRole: userRole,
        onLogout: logout,
        darkMode: darkMode,
        onThemeChanged: setDarkMode,
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
    return ChangeNotifierProvider(
      key: ValueKey(storage?.email),
      create: (_) => CartProvider(storage),
      child: MaterialApp(
        title: 'Student Assistant',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(Brightness.light),
        darkTheme: buildAppTheme(Brightness.dark),
        themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
        home: buildCurrentScreen(),
      ),
    );
  }
}
