import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  StorageService({FirebaseStorage? storage}) : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  Future<String> uploadUserPhoto(String userId, File file) async {
    final ref = _storage.ref('users/$userId/profile.jpg');
    final uploadTask = ref.putFile(file);
    final snapshot = await uploadTask;
    return snapshot.ref.getDownloadURL();
  }

  Future<String> uploadMessageMedia({
    required String chatId,
    required String userId,
    required String fileName,
    required File file,
  }) async {
    final ref = _storage.ref('chats/$chatId/$userId/$fileName');
    final snapshot = await ref.putFile(file);
    return snapshot.ref.getDownloadURL();
  }
}
