import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

/// Central Firebase Service wrapper with safe initialization checks
class FirebaseService {
  FirebaseService._();
  static final FirebaseService instance = FirebaseService._();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  FirebaseAuth? get auth => _isInitialized ? FirebaseAuth.instance : null;
  FirebaseFirestore? get firestore =>
      _isInitialized ? FirebaseFirestore.instance : null;
  FirebaseStorage? get storage =>
      _isInitialized ? FirebaseStorage.instance : null;

  Future<void> initialize() async {
    try {
      if (Firebase.apps.isEmpty) {
        // Will initialize if options exist on platform or native google-services.json is present
        await Firebase.initializeApp();
      }
      _isInitialized = true;

      // Enable Firestore offline persistence if supported
      if (!kIsWeb && _isInitialized) {
        FirebaseFirestore.instance.settings = const Settings(
          persistenceEnabled: true,
          cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
        );
      }
    } catch (e) {
      debugPrint(
          'Firebase not configured with credentials yet: $e. Running in safe mode.');
      _isInitialized = false;
    }
  }
}
