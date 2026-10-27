import 'package:flutter/material.dart';

class StudentTask {
  StudentTask({
    required this.id,
    required this.title,
    required this.subject,
    required this.description,
    required this.dueDate,
    required this.category,
    required this.color,
    this.isCompleted = false,
    this.isFavorite = false,
  });

  final String id;
  final String title;
  final String subject;
  final String description;
  final String dueDate;
  final String category;
  final Color color;

  bool isCompleted;
  bool isFavorite;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subject': subject,
      'description': description,
      'dueDate': dueDate,
      'category': category,
      'color': color.toARGB32(),
      'isCompleted': isCompleted,
      'isFavorite': isFavorite,
    };
  }

  factory StudentTask.fromJson(Map<String, dynamic> json) {
    return StudentTask(
      id: json['id'] as String,
      title: json['title'] as String,
      subject: json['subject'] as String,
      description: json['description'] as String,
      dueDate: json['dueDate'] as String,
      category: json['category'] as String,
      color: Color(json['color'] as int),
      isCompleted: json['isCompleted'] as bool? ?? false,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }
}