import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/catalog_product.dart';
import '../providers/cart_provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  Future<void> changeCart(BuildContext context, Future<void> Function() action) async {
    try {
      await action();
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not update your cart. Try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Cart',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          body:
              cart.itemCount == 0 ? _buildEmptyState() : _buildCartContent(context, cart),
        );
      },
    );
  }

  Widget _buildCartContent(BuildContext context, CartProvider cart) {
    final items = cart.items;
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final product = items[index];
              return _CartItemCard(
                product: product,
                formattedPrice: CatalogProduct.formatPrice(product.price),
                onRemove: () => changeCart(context, () => cart.removeFromCart(product)),
              );
            },
          ),
        ),
        _CartSummary(
          itemCount: cart.itemCount,
          totalPrice: CatalogProduct.formatPrice(cart.totalPrice),
          onClearAll: () => changeCart(context, cart.clearAll),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 76,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Your cart is empty',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Add study items from the Student Marketplace.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final CatalogProduct product;
  final String formattedPrice;
  final VoidCallback onRemove;

  const _CartItemCard({
    required this.product,
    required this.formattedPrice,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 5,
        ),
        leading: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: product.color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(product.icon, color: product.color),
        ),
        title: Text(
          product.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(formattedPrice),
        trailing: IconButton(
          tooltip: 'Remove from cart',
          onPressed: onRemove,
          icon: const Icon(Icons.delete_outline),
          color: Theme.of(context).colorScheme.error,
        ),
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  final int itemCount;
  final String totalPrice;
  final VoidCallback onClearAll;

  const _CartSummary({
    required this.itemCount,
    required this.totalPrice,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(child: Text(itemCount == 1 ? 'Total · 1 item' : 'Total · $itemCount items')),
                Text(
                  totalPrice,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onClearAll,
                icon: const Icon(Icons.delete_sweep_outlined),
                label: const Text('Clear All'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
