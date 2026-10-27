import 'package:flutter/material.dart';

import '../models/student_task.dart';
import '../models/news_article.dart';

import '../services/task_service.dart';

import '../widgets/schedule_card.dart';
import '../widgets/task_card.dart';
import '../widgets/news_card.dart';

import 'task_detail_screen.dart';
import 'news_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final TaskService taskService;
  final String userName;
  final List<NewsArticle> news;
  final bool Function(NewsArticle) isFavorite;
  final ValueChanged<NewsArticle> onFavoriteToggle;

  const HomeScreen({
    super.key,
    required this.taskService,
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
          task: task,
          onUpdate: () {
            widget.taskService.updateTask(task);
          },
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
      animation: widget.taskService,
      builder: (context, _) {
        // GET SHARED TASKS

        final tasks = widget.taskService.tasks;

        // CALCULATE PROGRESS

        final completed =
            tasks.where((task) => task.isCompleted).length;

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

                              const Text(
                                'Let’s make today productive.',
                                style: TextStyle(
                                  color: Color(0xFF7B8398),
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

                    const Text(
                      'Today’s schedule',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 13),

                    const ScheduleCard(
                      time: '09:00',
                      subject: 'Mobile Development',
                      room: 'Room 305',
                    ),

                    const ScheduleCard(
                      time: '11:00',
                      subject: 'Cybersecurity',
                      room: 'Room 214',
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
                          '${tasks.length} total',
                          style: const TextStyle(
                            color: Color(0xFF7B8398),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 13),

                    // SHARED TASKS

                    if (tasks.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(24),

                        decoration: BoxDecoration(
                          color: Colors.white,
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
                              'No assignments yet',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            SizedBox(height: 6),

                            Text(
                              'Open Tasks to add your first assignment.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      for (final task in tasks)
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