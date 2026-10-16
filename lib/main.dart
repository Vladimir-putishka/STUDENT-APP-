import 'package:flutter/material.dart';

import 'screens/registration_screen.dart';
import 'screens/main_navigation.dart';

void main() {
  runApp(const StudentAssistantApp());
}

class StudentAssistantApp extends StatefulWidget {
  const StudentAssistantApp({super.key});

  @override
  State<StudentAssistantApp> createState() =>
      _StudentAssistantAppState();
}

class _StudentAssistantAppState extends State<StudentAssistantApp> {
  String? userName;
  String? userEmail;
  String? userRole;

  bool isRegistered = false;

  void registerUser(
      String name,
      String email,
      String role,
      ) {
    setState(() {
      userName = name;
      userEmail = email;
      userRole = role;
      isRegistered = true;
    });
  }

  void logout() {
    setState(() {
      userName = null;
      userEmail = null;
      userRole = null;
      isRegistered = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Assistant',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF6F8FD),

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF405DE6),
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF6F8FD),
          scrolledUnderElevation: 0,
        ),
      ),

      home: isRegistered
          ? MainNavigation(
        userName: userName ?? 'Student',
        userEmail: userEmail ?? '',
        userRole: userRole ?? 'Student',
        onLogout: logout,
      )
          : RegistrationScreen(
        onRegister: registerUser,
      ),
    );
  }
}