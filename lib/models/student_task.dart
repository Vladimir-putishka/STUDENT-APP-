import 'package:flutter/material.dart';

class StudentTask {
  StudentTask({
    required this.title,
    required this.subject,
    required this.description,
    required this.dueDate,
    required this.category,
    required this.color,
    this.isCompleted = false,
    this.isFavorite = false,
  });

  final String title;
  final String subject;
  final String description;
  final String dueDate;
  final String category;
  final Color color;
  bool isCompleted;
  bool isFavorite;
}
