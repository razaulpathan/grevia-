import 'dart:io';
import 'package:flutter/foundation.dart';
import '../constants/firebase_constants.dart';
import '../errors/app_exceptions.dart';
import 'firebase_service.dart';

class StorageService {
  final FirebaseService _firebaseService;

  StorageService([FirebaseService? firebaseService])
      : _firebaseService = firebaseService ?? FirebaseService.instance;

  /// Upload file to Firebase Storage and return download URL
  Future<String> uploadFile({
    required String path,
    required File file,
  }) async {
    final storage = _firebaseService.storage;
    if (storage == null) {
      debugPrint(
          'Storage not initialized. Returning mock/local media URL for safe mode.');
      return 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500';
    }

    try {
      final ref = storage.ref().child(path);
      final uploadTask = await ref.putFile(file);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw StorageUploadException('Failed to upload file to storage: $e');
    }
  }

  /// Upload profile photo for a user
  Future<String> uploadProfilePhoto(String userId, File file) {
    return uploadFile(
      path: FirebaseStoragePaths.profilePhoto(userId),
      file: file,
    );
  }

  /// Upload chat media with collision prevention
  Future<String> uploadChatMedia(
      String chatId, String messageId, String extension, File file) {
    return uploadFile(
      path: FirebaseStoragePaths.chatMedia(chatId, messageId, extension),
      file: file,
    );
  }
}
