import 'package:flutter/material.dart';

class CatalogProduct {
  final int id;
  final String title;
  final String category;
  final double price;
  final double rating;
  final IconData icon;
  final Color color;

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