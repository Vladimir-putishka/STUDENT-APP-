import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../data/marketplace_products.dart';
import '../models/catalog_product.dart';
import '../services/student_storage.dart';

class CartProvider extends ChangeNotifier {
  CartProvider([this._storage]) {
    final saved = _storage?.read('cart');
    if (saved == null) return;
    final products = {for (final item in marketplaceProducts) item.id: item};
    for (final entry in jsonDecode(saved) as List) {
      final data = entry is Map ? Map<String, dynamic>.from(entry) : null;
      final id = data == null ? entry as int : data['id'] as int;
      var product = products[id];
      if (product == null && data != null) {
        product = CatalogProduct(
          id: id,
          title: data['title'] as String,
          category: data['category'] as String,
          price: (data['price'] as num).toDouble(),
          rating: (data['rating'] as num).toDouble(),
          icon: Icons.menu_book,
          color: const Color(0xFF405DE6),
        );
      }
      if (product != null && !isInCart(product)) _items.add(product);
    }
  }

  final StudentStorage? _storage;
  List<CatalogProduct> _items = [];
  bool _disposed = false;

  List<CatalogProduct> get items => List.unmodifiable(_items);
  int get itemCount => _items.length;
  double get totalPrice =>
      _items.fold(0, (total, product) => total + product.price);

  bool isInCart(CatalogProduct product) =>
      _items.any((item) => item.id == product.id);

  Future<void> _change(void Function(List<CatalogProduct>) change) {
    final storage = _storage;
    Future<void> apply() async {
      final next = [..._items];
      change(next);
      if (listEquals(next, _items)) return;
      if (storage != null) {
        await storage.write(
            'cart', jsonEncode([for (final item in next) item.toJson()]));
      }
      _items = next;
      if (!_disposed) notifyListeners();
    }

    return storage == null ? apply() : storage.run(apply);
  }

  Future<void> addToCart(CatalogProduct product) => _change((items) {
        if (!isInCart(product)) items.add(product);
      });

  Future<void> removeFromCart(CatalogProduct product) =>
      _change((items) => items.removeWhere((item) => item.id == product.id));

  Future<void> toggle(CatalogProduct product) => _change((items) {
        if (isInCart(product)) {
          items.removeWhere((item) => item.id == product.id);
        } else {
          items.add(product);
        }
      });

  Future<void> clearAll() => _change((items) => items.clear());

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
