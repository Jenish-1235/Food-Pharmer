// storage_service.dart
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadImage(File image) async {
    try {
      String filePath = 'images/${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = _storage.ref().child(filePath);
      UploadTask uploadTask = ref.putFile(
        image,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      await uploadTask.whenComplete(() {});
      String downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Error uploading image: $e');
    }
  }
}
