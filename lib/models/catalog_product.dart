import 'package:flutter/material.dart';

class CatalogProduct {
  final int id;
  final String title;
  final String category;
  final double price;
  final double rating;
  final IconData icon;
  final Color color;

  static String formatPrice(double price) => '${price.toStringAsFixed(0)} ₸';

  Map<String, Object> toJson() => {
        'id': id,
        'title': title,
        'category': category,
        'price': price,
        'rating': rating,
      };

  const CatalogProduct({
    required this.id,
    required this.title,
    required this.category,
    required this.price,
    required this.rating,
    required this.icon,
    required this.color,
  });
}
