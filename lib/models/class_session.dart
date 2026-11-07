import 'package:flutter/material.dart';

class ClassSession {
  const ClassSession({
    required this.id,
    required this.weekday,
    required this.startMinute,
    required this.endMinute,
    required this.subject,
    required this.room,
  });

  final String id;
  final int weekday;
  final int startMinute;
  final int endMinute;
  final String subject;
  final String room;

  static TimeOfDay timeOfDay(int minute) =>
      TimeOfDay(hour: minute ~/ 60, minute: minute % 60);

  Map<String, Object> toJson() => {
        'id': id,
        'weekday': weekday,
        'start': startMinute,
        'end': endMinute,
        'subject': subject,
        'room': room,
      };

  factory ClassSession.fromJson(Map<String, dynamic> json) => ClassSession(
        id: json['id'] as String,
        weekday: json['weekday'] as int,
        startMinute: json['start'] as int,
        endMinute: json['end'] as int,
        subject: json['subject'] as String,
        room: json['room'] as String,
      );
}
