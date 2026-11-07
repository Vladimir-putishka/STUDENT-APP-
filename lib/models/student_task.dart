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

  final bool isCompleted;
  final bool isFavorite;

  DateTime? get deadline {
    final parts = dueDate.split('/');
    if (parts.length != 3) return null;
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;
    final date = DateTime(year, month, day);
    return date.day == day && date.month == month ? date : null;
  }

  bool isOverdue(DateTime today) =>
      !isCompleted &&
      (deadline?.isBefore(DateUtils.dateOnly(today)) ?? false);

  StudentTask withStatus({bool? completed, bool? favorite}) => StudentTask(
        id: id,
        title: title,
        subject: subject,
        description: description,
        dueDate: dueDate,
        category: category,
        color: color,
        isCompleted: completed ?? isCompleted,
        isFavorite: favorite ?? isFavorite,
      );

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
