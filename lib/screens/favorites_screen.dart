import 'package:flutter/material.dart';

import '../models/news_article.dart';
import '../widgets/news_card.dart';

import 'news_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  final List<NewsArticle> favorites;
  final bool Function(NewsArticle) isFavorite;
  final ValueChanged<NewsArticle> onFavoriteToggle;

  const FavoritesScreen({
    super.key,
    required this.favorites,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  void openNews(BuildContext context, NewsArticle article) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewsDetailScreen(
          article: article,
          isFavorite: isFavorite(article),
          onFavoriteToggle: onFavoriteToggle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),

          child: ListView(
            padding: const EdgeInsets.all(20),

            children: [
              const Text(
                'My Favorites',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                '${favorites.length} saved articles',
                style: const TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 24),

              if (favorites.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),

                    child: Column(
                      children: [
                        Icon(
                          Icons.favorite_border,
                          size: 65,
                          color: Colors.grey,
                        ),

                        SizedBox(height: 15),

                        Text(
                          'No favorites yet',
                          style: TextStyle(fontSize: 18),
                        ),

                        SizedBox(height: 8),

                        Text(
                          'Save articles from Home to see them here.',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

              for (final article in favorites)
                NewsCard(
                  article: article,
                  isFavorite: isFavorite(article),

                  onFavoriteTap: () {
                    onFavoriteToggle(article);
                  },

                  onTap: () {
                    openNews(context, article);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}