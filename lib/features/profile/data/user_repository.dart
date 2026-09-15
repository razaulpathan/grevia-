import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firebase_constants.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../../core/services/firebase_service.dart';
import '../domain/models/user_profile.dart';

abstract class UserRepository {
  Future<UserProfile?> getUserProfile(String uid);
  Future<void> saveUserProfile(UserProfile profile);
  Future<bool> isUsernameAvailable(String username);
  Future<void> claimUsername(String uid, String username);
  Future<List<UserProfile>> searchUsers(String query);
  Future<void> updatePresence(String uid, bool isOnline);
  Future<void> blockUser(String currentUserId, String targetUserId);
  Future<void> unblockUser(String currentUserId, String targetUserId);
}

class FirestoreUserRepository implements UserRepository {
  final FirebaseService _firebaseService;
  final Map<String, UserProfile> _localCache = {};

  FirestoreUserRepository([FirebaseService? firebaseService])
      : _firebaseService = firebaseService ?? FirebaseService.instance;

  @override
  Future<UserProfile?> getUserProfile(String uid) async {
    if (_localCache.containsKey(uid)) return _localCache[uid];

    final firestore = _firebaseService.firestore;
    if (firestore == null) return _localCache[uid];

    try {
      final doc =
          await firestore.collection(FirebaseCollections.users).doc(uid).get();
      if (!doc.exists || doc.data() == null) return null;
      final profile = UserProfile.fromMap(doc.data()!, doc.id);
      _localCache[uid] = profile;
      return profile;
    } catch (_) {
      return _localCache[uid];
    }
  }

  @override
  Future<void> saveUserProfile(UserProfile profile) async {
    _localCache[profile.uid] = profile;
    final firestore = _firebaseService.firestore;
    if (firestore == null) return;

    await firestore
        .collection(FirebaseCollections.users)
        .doc(profile.uid)
        .set(profile.toMap(), SetOptions(merge: true));
  }

  @override
  Future<bool> isUsernameAvailable(String username) async {
    final clean = (username.startsWith('@') ? username.substring(1) : username)
        .toLowerCase();
    final firestore = _firebaseService.firestore;
    if (firestore == null) {
      return !_localCache.values.any((u) => u.usernameLowercase == clean);
    }

    final doc = await firestore
        .collection(FirebaseCollections.usernames)
        .doc(clean)
        .get();
    return !doc.exists;
  }

  @override
  Future<void> claimUsername(String uid, String username) async {
    final clean = (username.startsWith('@') ? username.substring(1) : username)
        .toLowerCase();
    final firestore = _firebaseService.firestore;
    if (firestore == null) {
      if (_localCache.values
          .any((u) => u.usernameLowercase == clean && u.uid != uid)) {
        throw UsernameTakenException(clean);
      }
      return;
    }

    final usernameRef =
        firestore.collection(FirebaseCollections.usernames).doc(clean);
    final userRef = firestore.collection(FirebaseCollections.users).doc(uid);

    await firestore.runTransaction((transaction) async {
      final usernameDoc = await transaction.get(usernameRef);
      if (usernameDoc.exists && usernameDoc.data()?['uid'] != uid) {
        throw UsernameTakenException(clean);
      }

      transaction.set(usernameRef, {
        'uid': uid,
        'username': clean,
        'claimedAt': FieldValue.serverTimestamp(),
      });

      transaction.update(userRef, {
        'username': clean,
        'usernameLowercase': clean,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Future<List<UserProfile>> searchUsers(String query) async {
    final clean = query.trim().toLowerCase().replaceAll('@', '');
    if (clean.isEmpty) return [];

    final firestore = _firebaseService.firestore;
    if (firestore == null) {
      return _localCache.values
          .where((u) =>
              u.usernameLowercase.contains(clean) ||
              u.displayName.toLowerCase().contains(clean))
          .toList();
    }

    try {
      // Query users by username prefix
      final snapshot = await firestore
          .collection(FirebaseCollections.users)
          .where('usernameLowercase', isGreaterThanOrEqualTo: clean)
          .where('usernameLowercase', isLessThanOrEqualTo: '$clean\uf8ff')
          .limit(20)
          .get();

      final results = snapshot.docs
          .map((doc) => UserProfile.fromMap(doc.data(), doc.id))
          .toList();

      for (final p in results) {
        _localCache[p.uid] = p;
      }
      return results;
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> updatePresence(String uid, bool isOnline) async {
    if (_localCache.containsKey(uid)) {
      _localCache[uid] = _localCache[uid]!.copyWith(
        isOnline: isOnline,
        lastSeen: DateTime.now(),
      );
    }
    final firestore = _firebaseService.firestore;
    if (firestore == null) return;

    try {
      await firestore.collection(FirebaseCollections.users).doc(uid).update({
        'isOnline': isOnline,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  @override
  Future<void> blockUser(String currentUserId, String targetUserId) async {
    final firestore = _firebaseService.firestore;
    if (firestore == null) return;

    await firestore
        .collection(FirebaseCollections.users)
        .doc(currentUserId)
        .update({
      'privacySettings.blockedUsers': FieldValue.arrayUnion([targetUserId]),
    });
  }

  @override
  Future<void> unblockUser(String currentUserId, String targetUserId) async {
    final firestore = _firebaseService.firestore;
    if (firestore == null) return;

    await firestore
        .collection(FirebaseCollections.users)
        .doc(currentUserId)
        .update({
      'privacySettings.blockedUsers': FieldValue.arrayRemove([targetUserId]),
    });
  }
}
