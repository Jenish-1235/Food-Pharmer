// lib/home/tabs/dashboard_tab.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/services/firestore_service.dart';
import '../widgets/product_list_item.dart';

class DashboardTab extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  DashboardTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Since we're fetching all products, no need to filter by userId
    return RefreshIndicator(
      onRefresh: () async {
        // Trigger a rebuild by triggering a state change
        // This can be handled better with state management solutions
      },
      child: StreamBuilder<QuerySnapshot>(
        stream: _firestoreService.getAllProducts(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            // Display the specific error message
            return Center(child: Text("Error loading data: ${snapshot.error}"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No analysis results yet."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              return ProductListItem(
                imageUrl: data['imageUrl'] ?? '',
                productName: data['productName'] ?? 'Unnamed Product',
                safetyLabel: data['safetyLabel'] ?? 'Unknown',
                ingredients: List<Map<String, dynamic>>.from(data['ingredients'] ?? [])
                    .map((e) => e['name'] as String)
                    .toList(),
                harmfulIngredients: List<Map<String, dynamic>>.from(data['harmfulIngredients'] ?? [])
                    .map((e) => e['name'] as String)
                    .toList(),
              );
            },
          );
        },
      ),
    );
  }
}
