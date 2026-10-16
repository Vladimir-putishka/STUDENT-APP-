import 'package:flutter/material.dart';

import '../models/news_article.dart';

import 'home_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';

class MainNavigation extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String userRole;
  final VoidCallback onLogout;

  const MainNavigation({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.userRole,
    required this.onLogout,
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int selectedIndex = 0;

  final Set<String> favoriteIds = {};

  final List<NewsArticle> news = [
    const NewsArticle(
      id: '1',
      title: 'Cybersecurity Workshop',
      description:
      'Join our cybersecurity workshop and learn about '
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
      description:
      'Complete the Flutter navigation laboratory assignment. '
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
      description:
      'The university has published information about '
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
      description:
      'Meet representatives from technology companies, '
          'explore internship opportunities and learn '
          'about career development. Students can '
          'communicate with potential employers.',
      imageUrl:
      'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=900',
      category: 'Career',
      date: 'October 30, 2026',
    ),
  ];

  void toggleFavorite(NewsArticle article) {
    setState(() {
      if (favoriteIds.contains(article.id)) {
        favoriteIds.remove(article.id);
      } else {
        favoriteIds.add(article.id);
      }
    });
  }

  bool isFavorite(NewsArticle article) {
    return favoriteIds.contains(article.id);
  }

  @override
  Widget build(BuildContext context) {
    final favoriteNews = news
        .where((article) => favoriteIds.contains(article.id))
        .toList();

    final screens = [
      HomeScreen(
        userName: widget.userName,
        news: news,
        isFavorite: isFavorite,
        onFavoriteToggle: toggleFavorite,
      ),

      FavoritesScreen(
        favorites: favoriteNews,
        isFavorite: isFavorite,
        onFavoriteToggle: toggleFavorite,
      ),

      ProfileScreen(
        name: widget.userName,
        email: widget.userEmail,
        role: widget.userRole,
        onLogout: widget.onLogout,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: screens,
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,

        selectedItemColor: const Color(0xFF405DE6),
        unselectedItemColor: Colors.grey,

        type: BottomNavigationBarType.fixed,

        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
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