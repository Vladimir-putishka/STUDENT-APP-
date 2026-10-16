import 'package:flutter/material.dart';

import '../models/news_article.dart';

class NewsDetailScreen extends StatefulWidget {
  final NewsArticle article;
  final bool isFavorite;
  final ValueChanged<NewsArticle> onFavoriteToggle;

  const NewsDetailScreen({
    super.key,
    required this.article,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  @override
  State<NewsDetailScreen> createState() =>
      _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  late bool favorite;

  @override
  void initState() {
    super.initState();
    favorite = widget.isFavorite;
  }

  void toggleFavorite() {
    setState(() {
      favorite = !favorite;
    });

    widget.onFavoriteToggle(widget.article);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('News Details'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),

                  child: Image.network(
                    widget.article.imageUrl,
                    width: double.infinity,
                    height: 260,
                    fit: BoxFit.cover,

                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 260,
                        color: const Color(0xFFE5E9FF),

                        child: const Center(
                          child: Icon(Icons.image, size: 60),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  widget.article.category.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF405DE6),
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  widget.article.title,
                  style: const TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  widget.article.date,
                  style: const TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 24),

                Text(
                  widget.article.description,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.6,
                  ),
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton.icon(
                    onPressed: toggleFavorite,

                    icon: Icon(
                      favorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                    ),

                    label: Text(
                      favorite
                          ? 'Remove from Favorites'
                          : 'Add to Favorites',
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,

                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },

                    icon: const Icon(Icons.arrow_back),

                    label: const Text('Back'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}