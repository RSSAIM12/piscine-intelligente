import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  Future<String> uploadPoolImage(File image, String poolId) async {
    try {
      final ref = _storage.ref().child('pool_images/$poolId/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = await ref.putFile(image);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Erreur upload image: $e');
    }
  }
  
  Future<void> deletePoolImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      print('Erreur suppression image: $e');
    }
  }
  
  Future<List<String>> getPoolImages(String poolId) async {
    final listResult = await _storage.ref().child('pool_images/$poolId').listAll();
    final urls = await Future.wait(
      listResult.items.map((ref) => ref.getDownloadURL())
    );
    return urls;
  }
}