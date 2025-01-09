// lib/home/tabs/capture_tab.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:foodpharmer/services/storage_service.dart';
import 'package:foodpharmer/services/vision_service.dart';
import 'package:foodpharmer/services/firestore_service.dart';
import 'package:foodpharmer/models/ingredient.dart';
import '../extensions/string_extension.dart';
import 'package:image_picker/image_picker.dart';

class CaptureTab extends StatefulWidget {
  final File? selectedImage;
  final VoidCallback onImageDiscarded;
  final Function(File) onImageSelected;

  const CaptureTab({
    Key? key,
    required this.selectedImage,
    required this.onImageDiscarded,
    required this.onImageSelected,
  }) : super(key: key);

  @override
  State<CaptureTab> createState() => _CaptureTabState();
}

class _CaptureTabState extends State<CaptureTab> {
  bool _isUploading = false;
  bool _isAnalyzing = false;

  final StorageService _storageService = StorageService();
  final VisionService _visionService =
  VisionService(apiKey: 'AIzaSyDvuVjFUosK4nOV-7Kk9Bbnb1ainx3Q2O0'); // Replace with your API key
  final FirestoreService _firestoreService = FirestoreService();

  // Define the _normalizeName function
  String _normalizeName(String name) {
    // Remove any non-alphanumeric characters except spaces
    return name.replaceAll(RegExp(r'[^\w\s]'), '').trim().toLowerCase();
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        widget.onImageSelected(File(pickedFile.path));
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
        widget.onImageSelected(File(pickedFile.path));
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
    if (widget.selectedImage == null) {
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
      String downloadUrl = await _storageService.uploadImage(widget.selectedImage!);
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
      debugPrint("Parsed Ingredients: ${ingredients.map((e) => "${e.name}: ${e.quantity}").toList()}");

      // Fetch harmful ingredients from Firestore
      List<Map<String, dynamic>> harmfulIngredients = await _firestoreService.getHarmfulIngredients();
      debugPrint("Fetched Harmful Ingredients: $harmfulIngredients");

      // Compare and determine harmful ingredients
      List<Ingredient> flaggedIngredients = _compareIngredients(ingredients, harmfulIngredients);
      debugPrint("Flagged Ingredients: ${flaggedIngredients.map((e) => "${e.name}: ${e.quantity}").toList()}");

      // Determine safety label
      String safetyLabel = flaggedIngredients.isEmpty ? 'Safe' : 'Unsafe';

      // Save the results to Firestore
      await _firestoreService.saveAnalysisResult({
        'analysisDate': FieldValue.serverTimestamp(),
        'harmfulIngredients': flaggedIngredients.map((e) => {
          'name': e.name,
          'quantityPresentAsPerImageInferred': e.quantity, // Removed "mg"
        }).toList(),
        'imageUrl': downloadUrl,
        'ingredients': ingredients.map((e) => {
          'name': e.name,
          'quantityPresentAsPerImageInferred': e.quantity, // Removed "mg"
        }).toList(),
        'productName': _generateProductName(ingredients),
        'safetyLabel': safetyLabel,
        'userId': FirebaseAuth.instance.currentUser?.uid ?? 'unknownUser',
      });

      setState(() {
        _isAnalyzing = false;
        widget.onImageDiscarded(); // Reset selected image after analysis
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
    // Regular expression to capture ingredient name and quantity
    final regex = RegExp(r'^(.+?)\s+(\d+\.?\d*)$', caseSensitive: false);

    final parsed = text
        .split(RegExp(r',|\n'))
        .map((ingredient) => ingredient.trim().toLowerCase())
        .where((ingredient) => ingredient.isNotEmpty)
        .map((ingredient) {
      final match = regex.firstMatch(ingredient);
      if (match != null) {
        final name = _normalizeName(match.group(1) ?? 'unknown');
        final quantityStr = match.group(2) ?? '0';

        // Parse quantity as a double
        double quantity = double.tryParse(quantityStr) ?? 0.0;

        return Ingredient(name: name, quantity: quantity);
      } else {
        debugPrint("Failed to parse ingredient: $ingredient");
        return Ingredient(name: 'unknown', quantity: 0.0);
      }
    })
        .where((ingredient) => ingredient.name.isNotEmpty && ingredient.name != 'unknown' && ingredient.quantity > 0)
        .toList();

    debugPrint("Parsed Ingredients: ${parsed.map((e) => "${e.name}: ${e.quantity}").toList()}");
    return parsed;
  }

  List<Ingredient> _compareIngredients(
      List<Ingredient> ingredients, List<Map<String, dynamic>> harmfulIngredients) {
    List<Ingredient> flagged = [];

    // Create a Map of harmful ingredient names to their threshold
    Map<String, double> harmfulMap = {};
    for (var harmful in harmfulIngredients) {
      String? harmfulName = harmful['"name"']; // Corrected key access
      double? threshold = double.tryParse(harmful['threshold'].toString());
      if (harmfulName != null && threshold != null) {
        harmfulMap[_normalizeName(harmfulName)] = threshold;
        debugPrint("Harmful Ingredient Added to Map: ${_normalizeName(harmfulName)} with threshold $threshold");
      } else {
        debugPrint("Invalid harmful ingredient data: $harmful");
      }
    }

    debugPrint("Harmful Ingredients Map: $harmfulMap");

    for (var ingredient in ingredients) {
      if (harmfulMap.containsKey(ingredient.name)) {
        double threshold = harmfulMap[ingredient.name]!;
        if (ingredient.quantity > threshold) {
          flagged.add(ingredient);
          debugPrint("Flagged Ingredient: ${ingredient.name} with quantity ${ingredient.quantity} exceeding threshold $threshold");
        } else {
          debugPrint("Ingredient: ${ingredient.name} with quantity ${ingredient.quantity} is below threshold $threshold");
        }
      }
    }

    debugPrint("Total Flagged Ingredients: ${flagged.length}");
    return flagged;
  }

  String _generateProductName(List<Ingredient> ingredients) {
    if (ingredients.isEmpty) return "Unnamed Product";
    // Example: Capitalize first ingredient's name
    return ingredients.first.name.capitalize();
  }

  @override
  Widget build(BuildContext context) {
    return widget.selectedImage == null
        ? Column(
      children: [
        ElevatedButton.icon(
          onPressed: _isUploading || _isAnalyzing ? null : _captureImageFromCamera,
          icon: const Icon(Icons.camera_alt),
          label: const Text("Capture Image"),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: _isUploading || _isAnalyzing ? null : _pickImageFromGallery,
          icon: const Icon(Icons.photo_library),
          label: const Text("Pick from Gallery"),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    )
        : Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(
            widget.selectedImage!,
            height: 250,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _isUploading || _isAnalyzing ? null : _uploadAndAnalyzeImage,
                child: _isUploading
                    ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : _isAnalyzing
                    ? const Text("Analyzing...")
                    : const Text("Analyze Image"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton(
                onPressed: _isUploading || _isAnalyzing
                    ? null
                    : () {
                  widget.onImageDiscarded();
                  debugPrint("Image discarded.");
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Image discarded.")),
                  );
                },
                child: const Text("Discard Image"),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: _isUploading || _isAnalyzing
              ? null
              : () async {
            await _pickImageFromGallery();
          },
          icon: const Icon(Icons.image_search),
          label: const Text("Pick Another Image"),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}
