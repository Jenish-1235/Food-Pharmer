// lib/home/widgets/product_list_item.dart
import 'package:flutter/material.dart';
import '../widgets/product_detail_page.dart';

class ProductListItem extends StatelessWidget {
  final String imageUrl;
  final String productName;
  final String safetyLabel;
  final List<String> ingredients;
  final List<String> harmfulIngredients;

  const ProductListItem({
    Key? key,
    required this.imageUrl,
    required this.productName,
    required this.safetyLabel,
    required this.ingredients,
    required this.harmfulIngredients,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color labelColor = safetyLabel == 'Safe' ? Colors.green : Colors.red;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(productData: {
              'productName': productName,
              'safetyLabel': safetyLabel,
              'imageUrl': imageUrl,
              'ingredients': ingredients
                  .map((e) => {'name': e, 'quantityPresentAsPerImageInferred': 'Unknown'})
                  .toList(),
              'harmfulIngredients': harmfulIngredients
                  .map((e) => {'name': e, 'quantityPresentAsPerImageInferred': 'Unknown'})
                  .toList(),
            }),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              imageUrl.isNotEmpty
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.broken_image, size: 80, color: Colors.grey),
                ),
              )
                  : const Icon(Icons.image, size: 80, color: Colors.grey),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productName,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          "Safety: ",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                        Text(
                          safetyLabel,
                          style: TextStyle(
                            fontSize: 14,
                            color: labelColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Ingredients: ${ingredients.join(', ')}",
                      style: const TextStyle(fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (harmfulIngredients.isNotEmpty)
                      Wrap(
                        spacing: 6.0,
                        children: harmfulIngredients
                            .map((e) => Chip(
                          label: Text(e, style: const TextStyle(color: Colors.white)),
                          backgroundColor: Colors.red,
                          visualDensity: VisualDensity.compact,
                        ))
                            .toList(),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                safetyLabel == 'Safe' ? Icons.check_circle : Icons.error,
                color: labelColor,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}