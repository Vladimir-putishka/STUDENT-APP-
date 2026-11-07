import 'package:flutter/material.dart';

import '../models/catalog_product.dart';

const List<CatalogProduct> marketplaceProducts = [
  CatalogProduct(
    id: 1,
    title: 'MacBook Air',
    category: 'Electronics',
    price: 499990,
    rating: 4.9,
    icon: Icons.laptop_mac,
    color: Color(0xFF405DE6),
  ),
  CatalogProduct(
    id: 2,
    title: 'Cybersecurity Handbook',
    category: 'Books',
    price: 12990,
    rating: 4.8,
    icon: Icons.security,
    color: Color(0xFF1DAB8A),
  ),
  CatalogProduct(
    id: 3,
    title: 'Wireless Mouse',
    category: 'Accessories',
    price: 15990,
    rating: 4.6,
    icon: Icons.mouse,
    color: Color(0xFFE59736),
  ),
  CatalogProduct(
    id: 4,
    title: 'Programming Notebook',
    category: 'Stationery',
    price: 2990,
    rating: 4.7,
    icon: Icons.menu_book,
    color: Color(0xFF8E64D8),
  ),
  CatalogProduct(
    id: 5,
    title: 'USB-C Hub',
    category: 'Electronics',
    price: 19990,
    rating: 4.5,
    icon: Icons.usb,
    color: Color(0xFFE65A74),
  ),
  CatalogProduct(
    id: 6,
    title: 'Student Backpack',
    category: 'Accessories',
    price: 24990,
    rating: 4.8,
    icon: Icons.backpack,
    color: Color(0xFF19A7CE),
  ),
];
