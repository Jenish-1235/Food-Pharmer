// vision_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class VisionService {
  final String apiKey;

  VisionService({required this.apiKey});

  Future<String> extractText(String imageUrl) async {
    const String endpoint = "https://vision.googleapis.com/v1/images:annotate";

    final Map<String, dynamic> body = {
      "requests": [
        {
          "image": {"source": {"imageUri": imageUrl}},
          "features": [{"type": "TEXT_DETECTION"}]
        }
      ]
    };

    try {
      final response = await http.post(
        Uri.parse("$endpoint?key=$apiKey"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['responses'][0]['fullTextAnnotation']['text'] ?? 'No text found';
      } else {
        throw Exception("Failed to analyze image: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error analyzing image: $e");
    }
  }
}
