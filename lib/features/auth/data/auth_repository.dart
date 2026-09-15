import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../../core/services/firebase_service.dart';

abstract class AuthRepository {
  Stream<String?> get authStateChanges;
  String? get currentUserId;
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(AuthException exception) onVerificationFailed,
    required Function(String smsCode) onAutoVerified,
  });
  Future<String> verifyOtp({
    required String verificationId,
    required String smsCode,
  });
  Future<void> signOut();
  Future<void> deleteAccount();
}

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseService _firebaseService;
  final StreamController<String?> _fallbackAuthController =
      StreamController<String?>.broadcast();
  String? _fallbackUserId;

  FirebaseAuthRepository([FirebaseService? firebaseService])
      : _firebaseService = firebaseService ?? FirebaseService.instance;

  @override
  Stream<String?> get authStateChanges {
    final auth = _firebaseService.auth;
    if (auth != null) {
      return auth.authStateChanges().map((user) => user?.uid);
    }
    return _fallbackAuthController.stream;
  }

  @override
  String? get currentUserId {
    final auth = _firebaseService.auth;
    if (auth != null) {
      return auth.currentUser?.uid;
    }
    return _fallbackUserId;
  }

  @override
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(AuthException exception) onVerificationFailed,
    required Function(String smsCode) onAutoVerified,
  }) async {
    final auth = _firebaseService.auth;
    if (auth == null) {
      debugPrint('Running phone auth in safe mode (offline/unconfigured).');
      // For safe development testing, immediately return test verification ID
      onCodeSent('test_verification_id_$phoneNumber');
      return;
    }

    try {
      await auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) {
          if (credential.smsCode != null) {
            onAutoVerified(credential.smsCode!);
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          onVerificationFailed(AuthException.fromFirebaseCode(e.code));
        },
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      onVerificationFailed(AuthException(e.toString()));
    }
  }

  @override
  Future<String> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    final auth = _firebaseService.auth;
    if (auth == null) {
      // Safe mode login
      _fallbackUserId = 'user_${verificationId.hashCode.abs()}';
      _fallbackAuthController.add(_fallbackUserId);
      return _fallbackUserId!;
    }

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      final userCredential = await auth.signInWithCredential(credential);
      final uid = userCredential.user?.uid;
      if (uid == null) throw const AuthException('Failed to retrieve user ID.');
      return uid;
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseCode(e.code);
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    final auth = _firebaseService.auth;
    if (auth != null) {
      await auth.signOut();
    } else {
      _fallbackUserId = null;
      _fallbackAuthController.add(null);
    }
  }

  @override
  Future<void> deleteAccount() async {
    final auth = _firebaseService.auth;
    if (auth != null && auth.currentUser != null) {
      await auth.currentUser!.delete();
    } else {
      _fallbackUserId = null;
      _fallbackAuthController.add(null);
    }
  }
}
