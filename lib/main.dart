import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() => runApp(const StudentAssistantApp());

class StudentAssistantApp extends StatelessWidget {
  const StudentAssistantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Assistant',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF6F8FD),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF405DE6)),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF6F8FD),
          scrolledUnderElevation: 0,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
