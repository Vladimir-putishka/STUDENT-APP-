import 'package:flutter/material.dart';

import '../models/catalog_product.dart';
import '../widgets/catalog_product_card.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  bool isGridView = false;

  int nextId = 7;

  final List<CatalogProduct> products = [
    const CatalogProduct(
      id: 1,
      title: 'MacBook Air',
      category: 'Electronics',
      price: 499990,
      rating: 4.9,
      icon: Icons.laptop_mac,
      color: Color(0xFF405DE6),
    ),

    const CatalogProduct(
      id: 2,
      title: 'Cybersecurity Handbook',
      category: 'Books',
      price: 12990,
      rating: 4.8,
      icon: Icons.security,
      color: Color(0xFF1DAB8A),
    ),

    const CatalogProduct(
      id: 3,
      title: 'Wireless Mouse',
      category: 'Accessories',
      price: 15990,
      rating: 4.6,
      icon: Icons.mouse,
      color: Color(0xFFE59736),
    ),

    const CatalogProduct(
      id: 4,
      title: 'Programming Notebook',
      category: 'Stationery',
      price: 2990,
      rating: 4.7,
      icon: Icons.menu_book,
      color: Color(0xFF8E64D8),
    ),

    const CatalogProduct(
      id: 5,
      title: 'USB-C Hub',
      category: 'Electronics',
      price: 19990,
      rating: 4.5,
      icon: Icons.usb,
      color: Color(0xFFE65A74),
    ),

    const CatalogProduct(
      id: 6,
      title: 'Student Backpack',
      category: 'Accessories',
      price: 24990,
      rating: 4.8,
      icon: Icons.backpack,
      color: Color(0xFF19A7CE),
    ),
  ];

  // INITIAL CATALOG DATA

  List<CatalogProduct> get initialProducts => [
    const CatalogProduct(
      id: 1,
      title: 'MacBook Air',
      category: 'Electronics',
      price: 499990,
      rating: 4.9,
      icon: Icons.laptop_mac,
      color: Color(0xFF405DE6),
    ),
    const CatalogProduct(
      id: 2,
      title: 'Cybersecurity Handbook',
      category: 'Books',
      price: 12990,
      rating: 4.8,
      icon: Icons.security,
      color: Color(0xFF1DAB8A),
    ),
    const CatalogProduct(
      id: 3,
      title: 'Wireless Mouse',
      category: 'Accessories',
      price: 15990,
      rating: 4.6,
      icon: Icons.mouse,
      color: Color(0xFFE59736),
    ),
    const CatalogProduct(
      id: 4,
      title: 'Programming Notebook',
      category: 'Stationery',
      price: 2990,
      rating: 4.7,
      icon: Icons.menu_book,
      color: Color(0xFF8E64D8),
    ),
    const CatalogProduct(
      id: 5,
      title: 'USB-C Hub',
      category: 'Electronics',
      price: 19990,
      rating: 4.5,
      icon: Icons.usb,
      color: Color(0xFFE65A74),
    ),
    const CatalogProduct(
      id: 6,
      title: 'Student Backpack',
      category: 'Accessories',
      price: 24990,
      rating: 4.8,
      icon: Icons.backpack,
      color: Color(0xFF19A7CE),
    ),
  ];

  // SWITCH BETWEEN LIST AND GRID

  void toggleView() {
    setState(() {
      isGridView = !isGridView;
    });
  }

  // PULL TO REFRESH

  Future<void> refreshCatalog() async {
    await Future.delayed(
      const Duration(milliseconds: 1500),
    );

    if (!mounted) return;

    final newProduct = CatalogProduct(
      id: nextId++,
      title: 'New Study Item $nextId',
      category: 'New Arrival',
      price: 9990,
      rating: 4.9,
      icon: Icons.auto_awesome,
      color: const Color(0xFF405DE6),
    );

    setState(() {
      products.insert(0, newProduct);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Catalog updated! New item added.'),
      ),
    );
  }

  // SWIPE TO DELETE + UNDO

  void removeProduct(CatalogProduct product) {
    final originalIndex = products.indexOf(product);

    if (originalIndex == -1) return;

    setState(() {
      products.removeAt(originalIndex);
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${product.title} removed'),

          duration: const Duration(seconds: 5),

          action: SnackBarAction(
            label: 'UNDO',

            onPressed: () {
              setState(() {
                final index = originalIndex.clamp(
                  0,
                  products.length,
                );

                products.insert(index, product);
              });
            },
          ),
        ),
      );
  }

  // RESET ORIGINAL CATALOG

  void resetCatalog() {
    setState(() {
      products
        ..clear()
        ..addAll(initialProducts);

      nextId = 7;
    });
  }

  // DELETE BACKGROUND

  Widget deleteBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 25),
      color: Colors.red,

      child: const Icon(
        Icons.delete,
        color: Colors.white,
        size: 30,
      ),
    );
  }

  // LIST VIEW

  Widget buildListView() {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),

      itemCount: products.length,

      separatorBuilder: (context, index) {
        return const Divider(
          height: 1,
          thickness: 0.5,
        );
      },

      itemBuilder: (context, index) {
        final product = products[index];

        return Dismissible(
          key: ValueKey(product.id),

          direction: DismissDirection.endToStart,

          background: deleteBackground(),

          onDismissed: (direction) {
            removeProduct(product);
          },

          child: CatalogProductCard(
            product: product,
            isGrid: false,
          ),
        );
      },
    );
  }

  // GRID VIEW

  Widget buildGridView() {
    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),

      gridDelegate:
      const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),

      itemCount: products.length,

      itemBuilder: (context, index) {
        final product = products[index];

        return CatalogProductCard(
          product: product,
          isGrid: true,
        );
      },
    );
  }

  // EMPTY STATE

  Widget buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.inventory_2_outlined,
            size: 85,
            color: Colors.grey,
          ),

          const SizedBox(height: 16),

          const Text(
            'Catalog is Empty',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            'All products have been removed.',
            style: TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 25),

          ElevatedButton.icon(
            onPressed: resetCatalog,
            icon: const Icon(Icons.refresh),
            label: const Text('Reset Catalog'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Smart Catalog',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        actions: [
          IconButton(
            onPressed: toggleView,

            tooltip: isGridView
                ? 'Switch to List'
                : 'Switch to Grid',

            icon: Icon(
              isGridView
                  ? Icons.view_list
                  : Icons.grid_view,
            ),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              '${products.length} products available',
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: RefreshIndicator(
                onRefresh: refreshCatalog,

                child: products.isEmpty
                    ? buildEmptyState()
                    : isGridView
                    ? buildGridView()
                    : buildListView(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}