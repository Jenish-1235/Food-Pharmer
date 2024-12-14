// home_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

import 'package:foodpharmer/services/storage_service.dart';
import 'package:foodpharmer/services/vision_service.dart';
import 'package:foodpharmer/services/firestore_service.dart';
import 'package:foodpharmer/models/ingredient.dart'; // Import the Ingredient model

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({Key? key}) : super(key: key);

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> with TickerProviderStateMixin {
  late TabController _tabBarController;
  File? _selectedImage;
  bool _isUploading = false;
  bool _isAnalyzing = false;

  final StorageService _storageService = StorageService();
  final VisionService _visionService = VisionService(apiKey: 'AIzaSyDvuVjFUosK4nOV-7Kk9Bbnb1ainx3Q2O0'); // Replace with your API key
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _tabBarController = TabController(
      vsync: this,
      length: 3, // Capture, Dashboard, Profile
      initialIndex: 0,
    );
  }

  @override
  void dispose() {
    _tabBarController.dispose();
    super.dispose();
  }

  // Define the _normalizeName function
  String _normalizeName(String name) {
    // Remove any non-alphanumeric characters except spaces
    return name.replaceAll(RegExp(r'[^\w\s]'), '').trim().toLowerCase();
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
        debugPrint("Image selected from gallery: ${pickedFile.path}");
      } else {
        debugPrint("No image selected.");
      }
    } catch (e) {
      debugPrint("Error selecting image from gallery: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error selecting image: $e")),
      );
    }
  }

  Future<void> _captureImageFromCamera() async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
        debugPrint("Image captured from camera: ${pickedFile.path}");
      } else {
        debugPrint("No image captured.");
      }
    } catch (e) {
      debugPrint("Error capturing image from camera: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error capturing image: $e")),
      );
    }
  }

  Future<void> _uploadAndAnalyzeImage() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No image selected or captured")),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // Upload image to Firebase Storage
      String downloadUrl = await _storageService.uploadImage(_selectedImage!);
      debugPrint("Image uploaded successfully. URL: $downloadUrl");

      setState(() {
        _isUploading = false;
        _isAnalyzing = true;
      });

      // Analyze the image using Google Vision API
      String extractedText = await _visionService.extractText(downloadUrl);
      debugPrint("Extracted Text: $extractedText");

      // Process extracted text to get ingredients
      List<Ingredient> ingredients = _parseIngredients(extractedText);
      debugPrint("Parsed Ingredients: ${ingredients.map((e) => e.name).toList()}");

      // Fetch harmful ingredients from Firestore
      List<Map<String, dynamic>> harmfulIngredients = await _firestoreService.getHarmfulIngredients();
      debugPrint("Fetched Harmful Ingredients: $harmfulIngredients");

      // Compare and determine harmful ingredients
      List<Ingredient> flaggedIngredients = _compareIngredients(ingredients, harmfulIngredients);
      debugPrint("Flagged Ingredients: ${flaggedIngredients.map((e) => e.name).toList()}");

      // Determine safety label
      String safetyLabel = flaggedIngredients.isEmpty ? 'Safe' : 'Unsafe';

      // Save the results to Firestore
      await _firestoreService.saveAnalysisResult({
        'analysisDate': FieldValue.serverTimestamp(),
        'harmfulIngredients': flaggedIngredients.map((e) => {'name': e.name, 'quantity': e.quantity}).toList(),
        'imageUrl': downloadUrl,
        'ingredients': ingredients.map((e) => {'name': e.name, 'quantity': e.quantity}).toList(),
        'productName': _generateProductName(ingredients),
        'safetyLabel': safetyLabel,
        'userId': FirebaseAuth.instance.currentUser?.uid, // Optional: Remove if not needed
      });

      setState(() {
        _isAnalyzing = false;
        _selectedImage = null; // Reset selected image after analysis
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Image analyzed and saved successfully!")),
      );
    } catch (e) {
      debugPrint("Error uploading and analyzing image: $e");
      setState(() {
        _isUploading = false;
        _isAnalyzing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  List<Ingredient> _parseIngredients(String text) {
    final regex = RegExp(r'^(.+?)(\d.*)?$');

    final parsed = text
        .split(RegExp(r',|\n'))
        .map((ingredient) => ingredient.trim().toLowerCase())
        .where((ingredient) => ingredient.isNotEmpty)
        .map((ingredient) {
      final match = regex.firstMatch(ingredient);
      if (match != null) {
        final name = _normalizeName(match.group(1) ?? 'unknown');
        final quantity = match.group(2)?.trim() ?? '';
        return Ingredient(name: name, quantity: quantity);
      } else {
        return Ingredient(name: 'unknown', quantity: '');
      }
    })
        .where((ingredient) => ingredient.name.isNotEmpty && ingredient.name != 'unknown')
        .toList();

    debugPrint("Parsed Ingredients: ${parsed.map((e) => e.name).toList()}");
    return parsed;
  }

  List<Ingredient> _compareIngredients(
      List<Ingredient> ingredients, List<Map<String, dynamic>> harmfulIngredients) {
    List<Ingredient> flagged = [];

    // Create a Set of harmful ingredient names in lowercase and normalized
    Set<String> harmfulNames = harmfulIngredients
        .map((harmful) => _normalizeName(harmful['name'].toString()))
        .toSet();

    debugPrint("Harmful Ingredient Names: $harmfulNames");

    for (var ingredient in ingredients) {
      for (var harmfulName in harmfulNames) {
        if (ingredient.name.contains(harmfulName)) {
          flagged.add(ingredient);
          debugPrint("Flagged Ingredient: ${ingredient.name}");
          break; // Avoid duplicate entries
        }
      }
    }

    debugPrint("Total Flagged Ingredients: ${flagged.length}");
    return flagged;
  }

  String _generateProductName(List<Ingredient> ingredients) {
    if (ingredients.isEmpty) return "Unnamed Product";
    return ingredients.first.name.capitalize(); // Capitalize first letter
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Pharmer'),
        backgroundColor: theme.primaryColor,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: TabBarView(
                controller: _tabBarController,
                children: [
                  // Tab 1: Capture
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _selectedImage == null
                          ? Column(
                        children: [
                          ElevatedButton.icon(
                            onPressed: _captureImageFromCamera,
                            icon: const Icon(Icons.camera),
                            label: const Text("Capture Image"),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _pickImageFromGallery,
                            icon: const Icon(Icons.image),
                            label: const Text("Pick from Gallery"),
                          ),
                        ],
                      )
                          : Column(
                        children: [
                          Image.file(
                            _selectedImage!,
                            height: 200,
                            width: 200,
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: _isUploading || _isAnalyzing
                                    ? null
                                    : _uploadAndAnalyzeImage,
                                child: _isUploading
                                    ? const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                )
                                    : _isAnalyzing
                                    ? const Text("Analyzing...")
                                    : const Text("Analyze Image"),
                              ),
                              const SizedBox(width: 16),
                              ElevatedButton(
                                onPressed: _isUploading || _isAnalyzing
                                    ? null
                                    : () {
                                  setState(() {
                                    _selectedImage = null;
                                  });
                                  debugPrint("Image discarded.");
                                },
                                child: const Text("Discard Image"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _isUploading || _isAnalyzing
                                ? null
                                : () async {
                              await _pickImageFromGallery();
                            },
                            icon: const Icon(Icons.image_search),
                            label: const Text("Pick Another Image"),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Tab 2: Dashboard
                  DashboardTab(), // Updated below

                  // Tab 3: Profile
                  ProfileTab(),
                ],
              ),
            ),

            // TabBar at the bottom
            TabBar(
              controller: _tabBarController,
              labelColor: theme.textTheme.bodyLarge?.color,
              unselectedLabelColor: theme.disabledColor,
              indicatorColor: theme.primaryColor,
              tabs: const [
                Tab(text: 'Capture'),
                Tab(text: 'Dashboard'),
                Tab(text: 'Profile'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (this.isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

class DashboardTab extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  DashboardTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Since we're fetching all products, no need to filter by userId
    return StreamBuilder<QuerySnapshot>(
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
    );
  }
}

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

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: imageUrl.isNotEmpty
            ? ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            imageUrl,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(child: CircularProgressIndicator());
            },
            errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.broken_image, size: 50, color: Colors.grey),
          ),
        )
            : const Icon(Icons.image, size: 50, color: Colors.grey),
        title: Text(
          productName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Safety: $safetyLabel", style: TextStyle(color: labelColor, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text("Ingredients: ${ingredients.join(', ')}"),
            if (harmfulIngredients.isNotEmpty)
              Wrap(
                spacing: 6.0,
                children: harmfulIngredients
                    .map((e) => Chip(
                  label: Text(e, style: const TextStyle(color: Colors.white)),
                  backgroundColor: Colors.red,
                ))
                    .toList(),
              ),
          ],
        ),
        trailing: Icon(
          safetyLabel == 'Safe' ? Icons.check_circle : Icons.error,
          color: labelColor,
        ),
      ),
    );
  }
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text("User not logged in."));
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            user.displayName ?? 'No Name',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(user.email ?? 'No Email'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
            child: const Text("Log Out"),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Implement delete account functionality
              debugPrint("Delete Account pressed.");
            },
            child: const Text("Delete Account"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
  }
}
