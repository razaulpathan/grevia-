import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firebase_constants.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/utils/id_generators.dart';
import '../domain/models/group_model.dart';

abstract class GroupRepository {
  Future<GroupModel> createGroup({
    required String name,
    required String description,
    required String ownerId,
    required List<String> initialMembers,
    String? photoUrl,
    bool isPrivate = false,
  });
  Future<GroupModel?> getGroup(String groupId);
  Future<void> addMember(String groupId, String userId);
  Future<void> removeMember(String groupId, String userId);
  Future<void> promoteAdmin(String groupId, String userId);
  Future<void> demoteAdmin(String groupId, String userId);
  Future<void> updatePermissions(String groupId, GroupPermissions permissions);
}

class FirestoreGroupRepository implements GroupRepository {
  final FirebaseService _firebaseService;
  final Map<String, GroupModel> _localGroups = {};

  FirestoreGroupRepository([FirebaseService? firebaseService])
      : _firebaseService = firebaseService ?? FirebaseService.instance;

  @override
  Future<GroupModel> createGroup({
    required String name,
    required String description,
    required String ownerId,
    required List<String> initialMembers,
    String? photoUrl,
    bool isPrivate = false,
  }) async {
    final groupId = IdGenerators.generateMessageId();
    final members = {...initialMembers, ownerId}.toList();
    final inviteCode = IdGenerators.generateInviteCode();

    final group = GroupModel(
      groupId: groupId,
      name: name,
      description: description,
      photoUrl: photoUrl,
      ownerId: ownerId,
      adminIds: [ownerId],
      memberIds: members,
      createdAt: DateTime.now(),
      isPrivate: isPrivate,
      inviteCode: inviteCode,
    );

    _localGroups[groupId] = group;
    final firestore = _firebaseService.firestore;
    if (firestore != null) {
      await firestore
          .collection(FirebaseCollections.groups)
          .doc(groupId)
          .set(group.toMap());
    }

    return group;
  }

  @override
  Future<GroupModel?> getGroup(String groupId) async {
    if (_localGroups.containsKey(groupId)) return _localGroups[groupId];
    final firestore = _firebaseService.firestore;
    if (firestore == null) return null;

    final doc = await firestore
        .collection(FirebaseCollections.groups)
        .doc(groupId)
        .get();
    if (!doc.exists || doc.data() == null) return null;
    final group = GroupModel.fromMap(doc.data()!, doc.id);
    _localGroups[groupId] = group;
    return group;
  }

  @override
  Future<void> addMember(String groupId, String userId) async {
    final firestore = _firebaseService.firestore;
    if (firestore != null) {
      await firestore
          .collection(FirebaseCollections.groups)
          .doc(groupId)
          .update({
        'memberIds': FieldValue.arrayUnion([userId]),
      });
    }
  }

  @override
  Future<void> removeMember(String groupId, String userId) async {
    final firestore = _firebaseService.firestore;
    if (firestore != null) {
      await firestore
          .collection(FirebaseCollections.groups)
          .doc(groupId)
          .update({
        'memberIds': FieldValue.arrayRemove([userId]),
        'adminIds': FieldValue.arrayRemove([userId]),
      });
    }
  }

  @override
  Future<void> promoteAdmin(String groupId, String userId) async {
    final firestore = _firebaseService.firestore;
    if (firestore != null) {
      await firestore
          .collection(FirebaseCollections.groups)
          .doc(groupId)
          .update({
        'adminIds': FieldValue.arrayUnion([userId]),
      });
    }
  }

  @override
  Future<void> demoteAdmin(String groupId, String userId) async {
    final firestore = _firebaseService.firestore;
    if (firestore != null) {
      await firestore
          .collection(FirebaseCollections.groups)
          .doc(groupId)
          .update({
        'adminIds': FieldValue.arrayRemove([userId]),
      });
    }
  }

  @override
  Future<void> updatePermissions(
      String groupId, GroupPermissions permissions) async {
    final firestore = _firebaseService.firestore;
    if (firestore != null) {
      await firestore
          .collection(FirebaseCollections.groups)
          .doc(groupId)
          .update({
        'permissions': permissions.toMap(),
      });
    }
  }
}
