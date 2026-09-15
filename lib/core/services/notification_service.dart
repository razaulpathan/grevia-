import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../constants/firebase_constants.dart';
import 'firebase_service.dart';

class NotificationService {
  final FirebaseService _firebaseService;

  NotificationService([FirebaseService? firebaseService])
      : _firebaseService = firebaseService ?? FirebaseService.instance;

  Future<void> initNotifications(String userId) async {
    if (!_firebaseService.isInitialized) return;

    try {
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        final token = await messaging.getToken();
        if (token != null) {
          await saveDeviceToken(userId, token);
        }

        // Listen to token refreshes
        messaging.onTokenRefresh.listen((newToken) {
          saveDeviceToken(userId, newToken);
        });
      }
    } catch (e) {
      debugPrint('FCM init warning: $e');
    }
  }

  Future<void> saveDeviceToken(String userId, String token) async {
    final firestore = _firebaseService.firestore;
    if (firestore == null) return;

    try {
      await firestore.collection(FirebaseCollections.users).doc(userId).update({
        'fcmToken': token,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await firestore
          .collection(FirebaseCollections.devices)
          .doc('${userId}_$token')
          .set({
        'userId': userId,
        'token': token,
        'platform': defaultTargetPlatform.name,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Failed to save device token: $e');
    }
  }
}
