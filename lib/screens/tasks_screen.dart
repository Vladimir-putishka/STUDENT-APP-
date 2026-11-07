import 'package:flutter/material.dart';

import '../models/student_task.dart';
import '../services/task_service.dart';

import 'task_detail_screen.dart';
import 'add_task_screen.dart';

enum _TaskFilter {
  all('All assignments'),
  pending('In progress'),
  overdue('Overdue'),
  completed('Completed'),
  saved('Bookmarked');

  const _TaskFilter(this.label);
  final String label;
}

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
  String query = '';
  _TaskFilter filter = _TaskFilter.all;

  // OPEN TASK DETAILS

  void openTask(StudentTask task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TaskDetailScreen(
          taskId: task.id,
          taskService: widget.taskService,
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

  Future<void> toggleCompleted(StudentTask task, bool? value) async {
    try {
      await widget.taskService.updateTask(
        task.id,
        (current) => current.withStatus(completed: value),
      );
    } catch (_) {
      showError('Could not update the assignment.');
    }
  }

  // REFRESH TASKS

  Future<void> refreshTasks() async {
    try {
      await widget.taskService.loadTasks(refresh: true);
    } catch (_) {
      showError('Could not reload saved assignments.');
    }
  }

  void showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$message Try again.')),
    );
  }

  // SWIPE TO DELETE + UNDO

  Future<bool> deleteTask(StudentTask task) async {
    final service = widget.taskService;
    final int originalIndex;
    try {
      originalIndex = await service.removeTask(task);
    } catch (_) {
      showError('Could not delete the assignment.');
      return false;
    }

    if (!mounted || originalIndex == -1) return false;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
          content: Text('${task.title} deleted'),

          action: SnackBarAction(
            label: 'UNDO',
            onPressed: () async {
              if (!mounted) return;
              try {
                await service.restoreTask(task, originalIndex);
              } catch (_) {
                showError('Could not restore the assignment.');
              }
            },
          ),
        ),
      );
    // The service already removed the row once the deletion was saved.
    return false;
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

  Widget buildList(List<StudentTask> tasks) {
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

          confirmDismiss: (_) => deleteTask(task),

          child: Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.surfaceContainerLow,
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

                        Flexible(child: Text(
                          task.isOverdue(DateTime.now()) ? '${task.dueDate} · Overdue' : task.dueDate,
                          style: TextStyle(
                            fontSize: 12,
                            color: task.isOverdue(DateTime.now())
                                ? Theme.of(context).colorScheme.error
                                : Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        )),
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

  Widget buildGrid(List<StudentTask> tasks) {
    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),

      padding: const EdgeInsets.only(bottom: 100),

      gridDelegate:
      const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 240,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 210,
      ),

      itemCount: tasks.length,

      itemBuilder: (context, index) {
        final task = tasks[index];

        return Dismissible(
          key: ValueKey(task.id),

          direction: DismissDirection.endToStart,

          background: buildDeleteBackground(),

          confirmDismiss: (_) => deleteTask(task),

          child: Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.surfaceContainerLow,
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

  Widget buildEmptyState(bool hasTasks) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 24),
      children: [
        const Icon(Icons.assignment_outlined, size: 48),
        const SizedBox(height: 12),
        Text(
          hasTasks ? 'No matching assignments' : 'No assignments yet',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        if (!hasTasks)
          const Text('Tap Add Task to get started.', textAlign: TextAlign.center),
      ],
    );
  }

  // BUILD SCREEN

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.taskService,

      builder: (context, _) {
        final tasks = widget.taskService.tasks;
        final completed = widget.taskService.completedCount;
        final remaining = tasks.length - completed;
        final today = DateTime.now();
        final visibleTasks = tasks.where((task) {
          if (!'${task.title} ${task.subject}'.toLowerCase().contains(query)) {
            return false;
          }
          return switch (filter) {
            _TaskFilter.all => true,
            _TaskFilter.pending => !task.isCompleted,
            _TaskFilter.overdue => task.isOverdue(today),
            _TaskFilter.completed => task.isCompleted,
            _TaskFilter.saved => task.isFavorite,
          };
        }).toList();

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
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                    borderRadius:
                    BorderRadius.circular(16),
                  ),

                  child: Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      Text('$remaining remaining'),
                      Text('$completed completed'),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                TextField(
                  onChanged: (value) => setState(() => query = value.trim().toLowerCase()),
                  decoration: const InputDecoration(
                    labelText: 'Search assignments',
                    prefixIcon: Icon(Icons.search),
                    isDense: true,
                  ),
                ),
                DropdownButton<_TaskFilter>(
                  isExpanded: true,
                  value: filter,
                  items: [
                    for (final item in _TaskFilter.values)
                      DropdownMenuItem(value: item, child: Text(item.label)),
                  ],
                  onChanged: (value) => setState(() => filter = value!),
                ),

                // LIST / GRID / EMPTY STATE

                Expanded(
                  child: RefreshIndicator(
                    onRefresh: refreshTasks,

                    child: visibleTasks.isEmpty
                        ? buildEmptyState(tasks.isNotEmpty)
                        : isGridView
                        ? buildGrid(visibleTasks)
                        : buildList(visibleTasks),
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

          ),
        );
      },
    );
  }
}
