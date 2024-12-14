// firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart'; // For debugPrint

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveAnalysisResult(Map<String, dynamic> data) async {
    try {
      await _firestore.collection('products').add(data);
      debugPrint("Analysis result saved successfully.");
    } catch (e) {
      throw Exception('Error saving analysis result: $e');
    }
  }

  // Method to get all products
  Stream<QuerySnapshot> getAllProducts() {
    return _firestore
        .collection('products')
        .orderBy('analysisDate', descending: true)
        .snapshots();
  }

  Future<List<Map<String, dynamic>>> getHarmfulIngredients() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('harmfulIngredients').get();
      List<Map<String, dynamic>> harmfulIngredients = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        debugPrint("Fetched Harmful Ingredient Data: $data");
        debugPrint("Fetched Harmful Ingredient Name: ${data['"name"']}"); // Access without quotes
        return data;
      }).toList();
      return harmfulIngredients;
    } catch (e) {
      throw Exception('Error fetching harmful ingredients: $e');
    }
  }
}
