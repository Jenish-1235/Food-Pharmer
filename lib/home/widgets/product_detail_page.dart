// lib/home/widgets/product_detail_page.dart
import 'package:flutter/material.dart';

class ProductDetailPage extends StatelessWidget {
  final Map<String, dynamic> productData;

  const ProductDetailPage({Key? key, required this.productData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String productName = productData['productName'] ?? 'Unnamed Product';
    String safetyLabel = productData['safetyLabel'] ?? 'Unknown';
    String imageUrl = productData['imageUrl'] ?? '';
    List<Map<String, dynamic>> ingredients =
    List<Map<String, dynamic>>.from(productData['ingredients'] ?? []);
    List<Map<String, dynamic>> harmfulIngredients =
    List<Map<String, dynamic>>.from(productData['harmfulIngredients'] ?? []);

    return Scaffold(
      appBar: AppBar(
        title: Text(productName),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView( // To handle overflow if content is large
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: imageUrl.isNotEmpty
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    imageUrl,
                    height: 250,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image, size: 100, color: Colors.grey),
                  ),
                )
                    : const Icon(Icons.image, size: 100, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              Text(
                "Product Name:",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                productName,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Text(
                "Safety Label:",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                safetyLabel,
                style: TextStyle(
                  fontSize: 16,
                  color: safetyLabel == 'Safe' ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Ingredients:",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              ...ingredients.map(
                    (ingredient) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.check, color: Colors.green),
                  title: Text(ingredient['name']),
                ),
              ),
              const SizedBox(height: 16),
              if (harmfulIngredients.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Harmful Ingredients:",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...harmfulIngredients.map(
                          (harmful) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.warning, color: Colors.red),
                        title: Text(harmful['name']),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}