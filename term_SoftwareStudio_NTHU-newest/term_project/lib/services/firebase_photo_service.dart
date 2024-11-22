import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class FirebasePhotoService {
  Future<String?> uploadPhoto(File imageFile) async {
    try {
      String fileName = 'images/${DateTime.now().millisecondsSinceEpoch.toString()}.jpg';
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance.ref().child(fileName);
      await ref.putFile(imageFile);
      
      String imageUrl = await ref.getDownloadURL();
      await FirebaseFirestore.instance.collection('photos').add({
        'url': imageUrl,
        'uploaded_at': FieldValue.serverTimestamp()
      });

      return imageUrl;
    } catch (e) {
      // ignore: avoid_print
      print('Error occurred while uploading: $e');
      return null;
    }
  }
}
