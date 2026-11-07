import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/marketplace_products.dart';
import '../models/catalog_product.dart';
import '../providers/cart_provider.dart';
import '../widgets/catalog_product_card.dart';
import 'cart_screen.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  bool isGridView = false;
  final List<CatalogProduct> products = [...marketplaceProducts];

  Future<void> refreshCatalog() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    final newProduct = CatalogProduct(
      id: DateTime.now().microsecondsSinceEpoch,
      title: 'New Study Item ${products.length + 1}',
      category: 'Stationery',
      price: 9990,
      rating: 4.9,
      icon: Icons.menu_book,
      color: const Color(0xFF405DE6),
    );

    setState(() {
      products.insert(0, newProduct);
    });
  }

  void openCart() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CartScreen()),
    );
  }

  void toggleView() {
    setState(() {
      isGridView = !isGridView;
    });
  }

  Future<void> toggleCart(CartProvider cart, CatalogProduct product) async {
    try {
      await cart.toggle(product);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not update your cart. Try again.')),
      );
    }
  }

  Widget buildListView(CartProvider cart) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: products.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final product = products[index];
        return CatalogProductCard(
          product: product,
          isGrid: false,
          isInCart: cart.isInCart(product),
          onCartToggle: () => toggleCart(cart, product),
        );
      },
    );
  }

  Widget buildGridView(CartProvider cart) {
    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 240,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 232,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return CatalogProductCard(
          product: product,
          isGrid: true,
          isInCart: cart.isInCart(product),
          onCartToggle: () => toggleCart(cart, product),
        );
      },
    );
  }

  Widget buildCartButton(BuildContext context, CartProvider cart) {
    return IconButton(
      tooltip: 'Open cart',
      onPressed: openCart,
      icon: Badge.count(
        count: cart.itemCount,
        isLabelVisible: cart.itemCount > 0,
        child: const Icon(Icons.shopping_cart_outlined),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Student Marketplace',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                tooltip: isGridView ? 'Switch to list' : 'Switch to grid',
                onPressed: toggleView,
                icon: Icon(isGridView ? Icons.view_list : Icons.grid_view),
              ),
              buildCartButton(context, cart),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${products.length} products available',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: refreshCatalog,
                    child: isGridView ? buildGridView(cart) : buildListView(cart),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
