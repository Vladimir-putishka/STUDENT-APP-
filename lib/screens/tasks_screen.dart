import 'package:flutter/material.dart';

import '../models/student_task.dart';
import '../services/task_service.dart';

import 'task_detail_screen.dart';
import 'add_task_screen.dart';

class TasksScreen extends StatefulWidget {
  final TaskService taskService;

  const TasksScreen({
    super.key,
    required this.taskService,
  });

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  bool isGridView = false;
  bool isRefreshing = false;

  // OPEN TASK DETAILS

  void openTask(StudentTask task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TaskDetailScreen(
          task: task,
          onUpdate: () {
            widget.taskService.updateTask(task);
          },
        ),
      ),
    );
  }

  // ADD NEW TASK

  void openAddTask() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddTaskScreen(
          taskService: widget.taskService,
        ),
      ),
    );
  }

  // MARK TASK AS COMPLETED

  void toggleCompleted(StudentTask task, bool? value) {
    task.isCompleted = value ?? false;
    widget.taskService.updateTask(task);
  }

  // REFRESH TASKS

  Future<void> refreshTasks() async {
    if (isRefreshing) return;

    setState(() {
      isRefreshing = true;
    });

    try {
      await widget.taskService.simulateRefresh();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Assignments updated successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Refresh failed: $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isRefreshing = false;
        });
      }
    }
  }

  // SWIPE TO DELETE + UNDO

  Future<void> deleteTask(StudentTask task) async {
    final originalIndex = await widget.taskService.removeTask(task);

    if (!mounted || originalIndex == -1) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
          content: Text('${task.title} deleted'),

          action: SnackBarAction(
            label: 'UNDO',
            onPressed: () {
              widget.taskService.restoreTask(
                task,
                originalIndex,
              );
            },
          ),
        ),
      );
  }

  // DELETE BACKGROUND

  Widget buildDeleteBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),

      decoration: BoxDecoration(
        color: Colors.red.shade400,
        borderRadius: BorderRadius.circular(12),
      ),

      child: const Icon(
        Icons.delete,
        color: Colors.white,
        size: 28,
      ),
    );
  }

  // CATEGORY ICON

  IconData categoryIcon(String category) {
    switch (category) {
      case 'Development':
        return Icons.code;
      case 'Research':
        return Icons.analytics_outlined;
      case 'Exam':
        return Icons.school_outlined;
      case 'Quiz':
        return Icons.quiz_outlined;
      default:
        return Icons.assignment_outlined;
    }
  }

  // LIST VIEW

  Widget buildList() {
    final tasks = widget.taskService.tasks;

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),

      padding: const EdgeInsets.only(bottom: 100),

      itemCount: tasks.length,

      separatorBuilder: (context, index) {
        return const Divider(
          height: 12,
          thickness: 0.5,
          color: Color(0xFFE5E7EB),
        );
      },

      itemBuilder: (context, index) {
        final task = tasks[index];

        return Dismissible(
          key: ValueKey(task.id),

          direction: DismissDirection.endToStart,

          background: buildDeleteBackground(),

          onDismissed: (_) {
            deleteTask(task);
          },

          child: Card(
            elevation: 0,
            color: Colors.white,
            margin: EdgeInsets.zero,

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),

            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),

              leading: CircleAvatar(
                backgroundColor:
                task.color.withValues(alpha: 0.12),

                child: Icon(
                  categoryIcon(task.category),
                  color: task.color,
                ),
              ),

              title: Text(
                task.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,

                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,

                  decoration: task.isCompleted
                      ? TextDecoration.lineThrough
                      : null,
                ),
              ),

              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),

                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [
                    Text(
                      task.subject,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 5),

                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 13,
                          color: Colors.grey,
                        ),

                        const SizedBox(width: 5),

                        Text(
                          task.dueDate,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              trailing: Checkbox(
                value: task.isCompleted,

                onChanged: (value) {
                  toggleCompleted(task, value);
                },
              ),

              onTap: () {
                openTask(task);
              },
            ),
          ),
        );
      },
    );
  }

  // GRID VIEW

  Widget buildGrid() {
    final tasks = widget.taskService.tasks;

    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),

      padding: const EdgeInsets.only(bottom: 100),

      gridDelegate:
      const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),

      itemCount: tasks.length,

      itemBuilder: (context, index) {
        final task = tasks[index];

        return Dismissible(
          key: ValueKey(task.id),

          direction: DismissDirection.endToStart,

          background: buildDeleteBackground(),

          onDismissed: (_) {
            deleteTask(task);
          },

          child: Card(
            elevation: 0,
            color: Colors.white,
            margin: EdgeInsets.zero,

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),

            clipBehavior: Clip.antiAlias,

            child: InkWell(
              onTap: () {
                openTask(task);
              },

              child: Padding(
                padding: const EdgeInsets.all(10),

                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [
                    // CATEGORY ICON

                    Container(
                      width: 42,
                      height: 42,

                      decoration: BoxDecoration(
                        color: task.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),

                      child: Icon(
                        categoryIcon(task.category),
                        color: task.color,
                        size: 24,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // TASK TITLE

                    Text(
                      task.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,

                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,

                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),

                    const SizedBox(height: 5),

                    // SUBJECT

                    Text(
                      task.subject,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,

                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),

                    const Spacer(),

                    // DUE DATE

                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 12,
                          color: Colors.grey,
                        ),

                        const SizedBox(width: 4),

                        Expanded(
                          child: Text(
                            task.dueDate,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,

                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // COMPLETED CHECKBOX

                    Align(
                      alignment: Alignment.centerRight,

                      child: SizedBox(
                        width: 40,
                        height: 36,

                        child: Checkbox(
                          value: task.isCompleted,

                          onChanged: (value) {
                            toggleCompleted(task, value);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // EMPTY STATE

  Widget buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            const Icon(
              Icons.assignment_outlined,
              size: 75,
              color: Colors.grey,
            ),

            const SizedBox(height: 16),

            const Text(
              'Catalog is Empty',
              textAlign: TextAlign.center,

              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'You have no assignments right now.',
              textAlign: TextAlign.center,

              style: TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: widget.taskService.resetTasks,

              icon: const Icon(Icons.restart_alt),

              label: const Text('Reset Catalog'),
            ),
          ],
        ),
      ),
    );
  }

  // BUILD SCREEN

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.taskService,

      builder: (context, _) {
        final tasks = widget.taskService.tasks;

        final completed =
            tasks.where((task) => task.isCompleted).length;

        final remaining = tasks.length - completed;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Study Planner',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            actions: [
              IconButton(
                tooltip: isGridView
                    ? 'Switch to List View'
                    : 'Switch to Grid View',

                onPressed: () {
                  setState(() {
                    isGridView = !isGridView;
                  });
                },

                icon: Icon(
                  isGridView
                      ? Icons.view_list
                      : Icons.grid_view,
                ),
              ),
            ],
          ),

          body: Padding(
            padding: const EdgeInsets.all(16),

            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [
                // ASSIGNMENT STATISTICS

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),

                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                    BorderRadius.circular(16),
                  ),

                  child: Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,

                    children: [
                      Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,

                        children: [
                          Text(
                            '${tasks.length} Assignments',

                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            '$remaining remaining',

                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),

                      Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.end,

                        children: [
                          Text(
                            '$completed completed',

                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1DAB8A),
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            isGridView
                                ? 'Grid View'
                                : 'List View',

                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // LIST / GRID / EMPTY STATE

                Expanded(
                  child: RefreshIndicator(
                    onRefresh: refreshTasks,

                    child: tasks.isEmpty
                        ? LayoutBuilder(
                      builder: (context, constraints) {
                        return ListView(
                          physics:
                          const AlwaysScrollableScrollPhysics(),

                          children: [
                            SizedBox(
                              height: constraints.maxHeight,
                              child: buildEmptyState(),
                            ),
                          ],
                        );
                      },
                    )
                        : isGridView
                        ? buildGrid()
                        : buildList(),
                  ),
                ),
              ],
            ),
          ),

          // ADD ASSIGNMENT

          floatingActionButton: FloatingActionButton.extended(
            onPressed: openAddTask,

            icon: const Icon(Icons.add),

            label: const Text('Add Task'),

            backgroundColor: const Color(0xFF405DE6),
            foregroundColor: Colors.white,
          ),
        );
      },
    );
  }
}