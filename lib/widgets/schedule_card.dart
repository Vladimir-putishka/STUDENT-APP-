import 'package:flutter/material.dart';

class ScheduleCard extends StatelessWidget {
  const ScheduleCard({super.key, required this.time, required this.subject, required this.room});
  final String time;
  final String subject;
  final String room;

  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    color: Colors.white,
    margin: const EdgeInsets.only(bottom: 10),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
      child: Row(children: [
        Container(width: 5, height: 42,
          decoration: BoxDecoration(color: const Color(0xFF405DE6), borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 12),
        SizedBox(width: 64, child: Text(time,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700))),
        const SizedBox(width: 6),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(subject, maxLines: 2, overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 3),
          Text(room, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        ])),
      ]),
    ),
  );
}
