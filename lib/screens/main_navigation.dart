import 'dart:convert';

import 'package:flutter/material.dart';

import '../models/news_article.dart';
import '../services/auth_service.dart';
import '../services/task_service.dart';
import '../services/student_storage.dart';
import '../services/schedule_service.dart';

import 'home_screen.dart';
import 'tasks_screen.dart';
import 'catalog_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';

class MainNavigation extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String userRole;
  final StudentStorage storage;
  final Future<void> Function() onLogout;
  final bool darkMode;
  final Future<void> Function(bool) onThemeChanged;

  const MainNavigation({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.userRole,
    required this.storage,
    required this.onLogout,
    required this.darkMode,
    required this.onThemeChanged,
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  // NAVIGATION

  int selectedIndex = 0;

  // SHARED TASK SERVICE

  late final taskService = TaskService(widget.storage);
  late final schedule = ScheduleService(widget.storage);

  bool tasksLoaded = false;
  String? loadingError;

  // FAVORITE NEWS

  final Set<String> favoriteIds = {};

  // UNIVERSITY NEWS

  final List<NewsArticle> news = [
    const NewsArticle(
      id: '1',
      title: 'Cybersecurity Workshop',
      description: 'Join our cybersecurity workshop and learn about '
          'network security, authentication, ethical hacking '
          'and digital protection. Students will have the '
          'opportunity to practice basic cybersecurity skills.',
      imageUrl:
          'https://images.unsplash.com/photo-1550751827-4bd374c3f58b?w=900',
      category: 'Events',
      date: 'October 20, 2026',
    ),
    const NewsArticle(
      id: '2',
      title: 'Flutter Assignment 7',
      description: 'Complete the Flutter navigation laboratory assignment. '
          'Create an application with BottomNavigationBar, '
          'multiple screens, favorites and parameterized navigation.',
      imageUrl:
          'https://images.unsplash.com/photo-1515879218367-8466d910aaa4?w=900',
      category: 'Homework',
      date: 'October 22, 2026',
    ),
    const NewsArticle(
      id: '3',
      title: 'Midterm Exam Schedule',
      description: 'The university has published information about '
          'upcoming midterm examinations. Students should '
          'review their course schedules and prepare '
          'for assessments.',
      imageUrl:
          'https://images.unsplash.com/photo-1434030216411-0b793f4b4173?w=900',
      category: 'Academic',
      date: 'October 25, 2026',
    ),
    const NewsArticle(
      id: '4',
      title: 'University Career Fair',
      description: 'Meet representatives from technology companies, '
          'explore internship opportunities and learn '
          'about career development. Students can '
          'communicate with potential employers.',
      imageUrl:
          'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=900',
      category: 'Career',
      date: 'October 30, 2026',
    ),
  ];

  // INITIALIZE

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  // LOAD SAVED TASKS

  Future<void> loadTasks() async {
    try {
      await widget.storage.importLegacyTasks(await AuthService.firstAccountEmail());
      await taskService.loadTasks();

      if (!mounted) return;

      schedule.load();
      setState(() {
        final saved = widget.storage.read('favorite_news');
        favoriteIds
          ..clear()
          ..addAll(saved == null ? [] : (jsonDecode(saved) as List).cast<String>());
        tasksLoaded = true;
        loadingError = null;
      });

      debugPrint('Tasks loaded successfully');
    } catch (error) {
      debugPrint('Task loading error: $error');

      if (!mounted) return;

      setState(() {
        tasksLoaded = false;
        loadingError = error.toString();
      });
    }
  }

  // TOGGLE FAVORITE NEWS

  Future<bool> toggleFavorite(NewsArticle article) async {
    final storage = widget.storage;
    try {
      return await storage.run(() async {
        final next = {...favoriteIds};
        if (!next.add(article.id)) next.remove(article.id);
        await storage.write('favorite_news', jsonEncode(next.toList()));
        if (mounted) {
          setState(() {
            favoriteIds
              ..clear()
              ..addAll(next);
          });
        }
        return next.contains(article.id);
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save this article. Try again.')),
        );
      }
      return isFavorite(article);
    }
  }

  // CHECK IF NEWS IS FAVORITE

  bool isFavorite(NewsArticle article) {
    return favoriteIds.contains(article.id);
  }

  // CHANGE TAB

  void changeTab(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  // DISPOSE SERVICE

  @override
  void dispose() {
    taskService.dispose();
    schedule.dispose();
    super.dispose();
  }

  // LOADING SCREEN

  Widget buildLoadingScreen() {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          color: Color(0xFF405DE6),
        ),
      ),
    );
  }

  // ERROR SCREEN

  Widget buildErrorScreen() {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 70,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'Could not load your student workspace',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text('Try loading your saved data again.'),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    loadingError = null;
                  });

                  loadTasks();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
              TextButton(onPressed: logout, child: const Text('Sign out')),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> logout() async {
    try {
      await widget.onLogout();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not sign out. Try again.')),
        );
      }
    }
  }

  // MAIN SCREEN

  @override
  Widget build(BuildContext context) {
    // WAIT UNTIL TASKS ARE LOADED

    if (!tasksLoaded) {
      if (loadingError != null) {
        return buildErrorScreen();
      }

      return buildLoadingScreen();
    }

    // FILTER FAVORITE NEWS

    final favoriteNews =
        news.where((article) => favoriteIds.contains(article.id)).toList();

    // APPLICATION SCREENS

    final screens = [
      HomeScreen(
        userName: widget.userName,
        news: news,
        isFavorite: isFavorite,
        onFavoriteToggle: toggleFavorite,
        taskService: taskService,
        schedule: schedule,
      ),
      TasksScreen(
        taskService: taskService,
      ),
      const CatalogScreen(),
      FavoritesScreen(
        favorites: favoriteNews,
        isFavorite: isFavorite,
        onFavoriteToggle: toggleFavorite,
      ),
      ProfileScreen(
        name: widget.userName,
        email: widget.userEmail,
        role: widget.userRole,
        onLogout: logout,
        darkMode: widget.darkMode,
        onThemeChanged: widget.onThemeChanged,
      ),
    ];

    return Scaffold(
      // KEEP SCREENS ALIVE

      body: IndexedStack(
        index: selectedIndex,
        children: screens,
      ),

      // BOTTOM NAVIGATION

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        onTap: changeTab,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront_outlined),
            activeIcon: Icon(Icons.storefront),
            label: 'Marketplace',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            activeIcon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
