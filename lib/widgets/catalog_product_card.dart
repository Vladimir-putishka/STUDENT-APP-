import 'package:flutter/material.dart';
import '../models/catalog_product.dart';

class CatalogProductCard extends StatelessWidget {
  final CatalogProduct product;
  final bool isGrid;

  const CatalogProductCard({
    super.key,
    required this.product,
    required this.isGrid,
  });

  @override
  Widget build(BuildContext context) {
    return isGrid ? _buildGridCard() : _buildListCard();
  }

  Widget _buildListCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: product.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              product.icon,
              size: 30,
              color: product.color,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  product.category,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 5),

                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(product.rating.toString()),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Text(
            '${product.price.toStringAsFixed(0)} ₸',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF405DE6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: product.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                product.icon,
                size: 55,
                color: product.color,
              ),
            ),
          ),

          const SizedBox(height: 10),

          Text(
            product.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            product.category,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 5),

          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 15),
              const SizedBox(width: 3),
              Text(
                product.rating.toString(),
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),

          const SizedBox(height: 5),

          Text(
            '${product.price.toStringAsFixed(0)} ₸',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF405DE6),
            ),
          ),
        ],
      ),
    );
  }
}