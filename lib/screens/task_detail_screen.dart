import 'package:flutter/material.dart';
import '../models/student_task.dart';
import '../services/task_service.dart';
import 'add_task_screen.dart';

class TaskDetailScreen extends StatelessWidget {
  const TaskDetailScreen({super.key, required this.taskId, required this.taskService});
  final String taskId;
  final TaskService taskService;

  Future<void> update(
    BuildContext context,
    StudentTask Function(StudentTask) change,
  ) async {
    try {
      await taskService.updateTask(taskId, change);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not update the assignment. Try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: taskService,
        builder: (context, _) {
          final task = taskService.findTask(taskId);
          if (task == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Task details')),
              body: const Center(child: Text('This assignment was removed.')),
            );
          }
          return buildDetails(context, task);
        },
      );

  Widget buildDetails(BuildContext context, StudentTask task) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task details'),
        actions: [
          IconButton(
            tooltip: 'Edit assignment',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => AddTaskScreen(taskService: taskService, task: task),
              ),
            ),
          ),
        ],
      ),
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
                        tooltip: task.isFavorite ? 'Remove bookmark' : 'Bookmark assignment',
                        onPressed: () => update(
                          context,
                          (current) => current.withStatus(favorite: !current.isFavorite),
                        ),
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
                  if (task.isOverdue(DateTime.now()))
                    const Chip(label: Text('Overdue'), avatar: Icon(Icons.warning_amber, size: 17)),
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
                Text(task.description.isEmpty ? 'No description' : task.description,
                  style: TextStyle(fontSize: 15, height: 1.6,
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
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
                  onPressed: () => update(
                    context,
                    (current) => current.withStatus(completed: !current.isCompleted),
                  ),
                  icon: Icon(task.isCompleted ? Icons.undo_rounded : Icons.check_circle_outline_rounded),
                  label: Text(task.isCompleted ? 'Mark as In Progress' : 'Mark as Completed'),
                  style: FilledButton.styleFrom(
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
