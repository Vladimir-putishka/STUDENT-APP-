import 'package:flutter/material.dart';
import '../models/student_task.dart';

class TaskDetailScreen extends StatefulWidget {
  const TaskDetailScreen({super.key, required this.task, required this.onUpdate});
  final StudentTask task;
  final VoidCallback onUpdate;

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  void toggleFavorite() {
    setState(() => widget.task.isFavorite = !widget.task.isFavorite);
    widget.onUpdate();
  }

  void toggleCompleted() {
    setState(() => widget.task.isCompleted = !widget.task.isCompleted);
    widget.onUpdate();
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    return Scaffold(
      appBar: AppBar(title: const Text('Task details'), centerTitle: true),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                SizedBox(
                  height: 205,
                  child: Stack(children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [task.color, const Color(0xFF93A1F7)]),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Center(child: Icon(Icons.school_rounded,
                        size: 90, color: Colors.white70)),
                    ),
                    Positioned(top: 14, right: 14, child: Material(
                      color: Colors.white, borderRadius: BorderRadius.circular(14),
                      child: IconButton(
                        tooltip: 'Favorite',
                        onPressed: toggleFavorite,
                        icon: Icon(task.isFavorite ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                          color: task.color),
                      ),
                    )),
                    Positioned(bottom: 15, left: 15, child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(color: Colors.white,
                        borderRadius: BorderRadius.circular(20)),
                      child: Text('STUDENT TASK',
                        style: TextStyle(color: task.color, fontWeight: FontWeight.bold, fontSize: 11)),
                    )),
                  ]),
                ),
                const SizedBox(height: 24),
                Text(task.title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  Chip(label: Text(task.category), avatar: const Icon(Icons.label_outline, size: 17)),
                  Chip(label: Text(task.dueDate), avatar: const Icon(Icons.event, size: 17)),
                  Chip(label: Text(task.isCompleted ? 'Completed' : 'In progress'),
                    avatar: Icon(task.isCompleted ? Icons.check_circle_outline : Icons.timelapse, size: 17)),
                ]),
                const SizedBox(height: 18),
                const Text('Course', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Row(children: [
                  const Icon(Icons.menu_book_outlined, color: Color(0xFF405DE6)),
                  const SizedBox(width: 9),
                  Expanded(child: Text(task.subject, style: const TextStyle(fontSize: 16))),
                ]),
                const SizedBox(height: 25),
                const Text('Description', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                const SizedBox(height: 9),
                Text(task.description, style: const TextStyle(fontSize: 15, height: 1.6,
                  color: Color(0xFF555F75))),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 10, 20, 16),
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Row(children: [
              Expanded(child: SizedBox(
                height: 54,
                child: FilledButton.icon(
                  onPressed: toggleCompleted,
                  icon: Icon(task.isCompleted ? Icons.undo_rounded : Icons.check_circle_outline_rounded),
                  label: Text(task.isCompleted ? 'Mark as In Progress' : 'Mark as Completed'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF405DE6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              )),
            ]),
          ),
        ),
      ),
    );
  }
}
