// firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveAnalysisResult(Map<String, dynamic> data) async {
    try {
      await _firestore.collection('products').add(data);
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
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      throw Exception('Error fetching harmful ingredients: $e');
    }
  }
}
