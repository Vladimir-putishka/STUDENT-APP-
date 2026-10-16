import 'package:flutter/material.dart';

import '../models/student_task.dart';
import '../models/news_article.dart';

import '../widgets/schedule_card.dart';
import '../widgets/task_card.dart';
import '../widgets/news_card.dart';

import 'task_detail_screen.dart';
import 'news_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userName;
  final List<NewsArticle> news;
  final bool Function(NewsArticle) isFavorite;
  final ValueChanged<NewsArticle> onFavoriteToggle;

  const HomeScreen({
    super.key,
    required this.userName,
    required this.news,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<StudentTask> tasks = [
    StudentTask(
      title: 'Flutter UI Assignment',
      subject: 'Mobile Development',
      description:
      'Build two responsive Flutter screens using Stack, '
          'Row, Column, Card, Wrap and Expanded. '
          'Add an interactive feature with setState().',
      dueDate: 'Oct 12',
      category: 'Development',
      color: const Color(0xFF405DE6),
    ),

    StudentTask(
      title: 'Marketing Case Study',
      subject: 'Marketing Analytics',
      description:
      'Analyze the customer journey and suggest '
          'improvements based on the main barriers.',
      dueDate: 'Oct 14',
      category: 'Research',
      color: const Color(0xFFE59736),
    ),

    StudentTask(
      title: 'Security Quiz Revision',
      subject: 'Cybersecurity',
      description:
      'Review authentication protocols and prepare '
          'short notes for the class quiz.',
      dueDate: 'Oct 16',
      category: 'Quiz',
      color: const Color(0xFF1DAB8A),
    ),
  ];

  void openTask(StudentTask task) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TaskDetailScreen(
          task: task,
          onUpdate: () {
            setState(() {});
          },
        ),
      ),
    );
  }

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
    final completed =
        tasks.where((task) => task.isCompleted).length;

    final remaining = tasks.length - completed;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),

            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),

              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

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

                // PROGRESS

                Container(
                  padding: const EdgeInsets.all(22),

                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF405DE6),
                        Color(0xFF7386F7),
                      ],
                    ),

                    borderRadius: BorderRadius.circular(24),
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

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
                        value: completed / tasks.length,
                        backgroundColor: Colors.white30,
                        color: Colors.white,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(8),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        '$remaining tasks remaining',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 26),

                // SCHEDULE

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

                // TASKS

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

                    isFavorite: widget.isFavorite(article),

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
  }
}