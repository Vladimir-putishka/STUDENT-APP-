import 'package:flutter/material.dart';

import '../models/class_session.dart';
import '../models/student_task.dart';
import '../models/news_article.dart';

import '../services/task_service.dart';
import '../services/schedule_service.dart';

import '../widgets/schedule_card.dart';
import '../widgets/task_card.dart';
import '../widgets/news_card.dart';

import 'task_detail_screen.dart';
import 'news_detail_screen.dart';
import 'schedule_screen.dart';

class HomeScreen extends StatefulWidget {
  final TaskService taskService;
  final ScheduleService schedule;
  final String userName;
  final List<NewsArticle> news;
  final bool Function(NewsArticle) isFavorite;
  final Future<bool> Function(NewsArticle) onFavoriteToggle;

  const HomeScreen({
    super.key,
    required this.taskService,
    required this.schedule,
    required this.userName,
    required this.news,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // OPEN TASK DETAILS

  void openTask(StudentTask task) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TaskDetailScreen(
          taskId: task.id,
          taskService: widget.taskService,
        ),
      ),
    );
  }

  // OPEN UNIVERSITY NEWS

  void openNews(NewsArticle article) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewsDetailScreen(
          article: article,
          isFavorite: widget.isFavorite(article),
          onFavoriteToggle: widget.onFavoriteToggle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // LISTEN TO SHARED TASK SERVICE

    return AnimatedBuilder(
      animation: Listenable.merge([widget.taskService, widget.schedule]),
      builder: (context, _) {
        // GET SHARED TASKS

        final tasks = widget.taskService.tasks;
        final now = DateTime.now();
        final classes = widget.schedule.forWeekday(now.weekday);
        final upcoming = tasks.where((task) => !task.isCompleted).toList()
          ..sort((a, b) {
            final first = a.deadline;
            final second = b.deadline;
            if (first == null) return second == null ? 0 : 1;
            if (second == null) return -1;
            return first.compareTo(second);
          });

        // CALCULATE PROGRESS

        final completed = widget.taskService.completedCount;

        final remaining = tasks.length - completed;

        final double progress =
        tasks.isEmpty ? 0.0 : completed / tasks.length;

        return Scaffold(
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 760,
                ),

                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    20,
                    20,
                    32,
                  ),

                  children: [
                    // HEADER

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,

                            children: [
                              Text(
                                'Hello, ${widget.userName}!',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                MaterialLocalizations.of(context).formatFullDate(now),
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 8),

                        const CircleAvatar(
                          radius: 23,
                          backgroundColor: Color(0xFFE5E9FF),

                          child: Icon(
                            Icons.person_rounded,
                            color: Color(0xFF405DE6),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // PROGRESS CARD

                    Container(
                      padding: const EdgeInsets.all(22),

                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF405DE6),
                            Color(0xFF7386F7),
                          ],
                        ),

                        borderRadius:
                        BorderRadius.circular(24),
                      ),

                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,

                        children: [
                          const Text(
                            'YOUR PROGRESS',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 12),

                          Text(
                            '$completed / ${tasks.length} tasks completed',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                            ),
                          ),

                          const SizedBox(height: 15),

                          LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.white30,
                            color: Colors.white,
                            minHeight: 8,
                            borderRadius:
                            BorderRadius.circular(8),
                          ),

                          const SizedBox(height: 12),

                          Text(
                            '$remaining tasks remaining',
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 26),

                    // TODAY'S SCHEDULE

                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Today’s schedule',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => ScheduleScreen(schedule: widget.schedule),
                            ),
                          ),
                          child: const Text('Weekly schedule'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 13),

                    if (classes.isEmpty)
                      const Text('No classes scheduled for today.')
                    else
                      for (final session in classes)
                        ScheduleCard(
                          time: ClassSession.timeOfDay(session.startMinute).format(context),
                          subject: session.subject,
                          room: session.room,
                        ),

                    const SizedBox(height: 20),

                    // UPCOMING TASKS HEADER

                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Upcoming tasks',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),

                        Text(
                          '${upcoming.length} open',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 13),

                    // SHARED TASKS

                    if (upcoming.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(24),

                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerLow,
                          borderRadius:
                          BorderRadius.circular(16),
                        ),

                        child: const Column(
                          children: [
                            Icon(
                              Icons.assignment_outlined,
                              size: 45,
                              color: Colors.grey,
                            ),

                            SizedBox(height: 12),

                            Text(
                              'No open assignments',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            SizedBox(height: 6),

                            Text(
                              'Add and manage assignments in the Tasks tab.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      for (final task in upcoming)
                        TaskCard(
                          task: task,
                          onTap: () => openTask(task),
                        ),

                    const SizedBox(height: 30),

                    // UNIVERSITY NEWS

                    const Text(
                      'University News',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Text('Sample announcements'),

                    const SizedBox(height: 15),

                    for (final article in widget.news)
                      NewsCard(
                        article: article,

                        isFavorite:
                        widget.isFavorite(article),

                        onTap: () {
                          openNews(article);
                        },

                        onFavoriteTap: () {
                          widget.onFavoriteToggle(article);
                        },
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
}
