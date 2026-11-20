import 'package:flutter/material.dart';

class CatalogProduct {
  final int id;
  final String title;
  final String category;
  final double price;
  final double rating;
  final IconData icon;
  final Color color;
  final String source;
  final String currency;

  String get cartKey => '$source:$id';

  String get formattedPrice =>
      currency == 'USD' ? '\$${price.toStringAsFixed(2)}' : formatPrice(price);

  static String formatPrice(double price) => '${price.toStringAsFixed(0)} ₸';

  Map<String, Object> toJson() => {
        'id': id,
        'title': title,
        'category': category,
        'price': price,
        'rating': rating,
        'source': source,
        'currency': currency,
      };

  const CatalogProduct({
    required this.id,
    required this.title,
    required this.category,
    required this.price,
    required this.rating,
    required this.icon,
    required this.color,
    this.source = 'local',
    this.currency = 'KZT',
  });
}
