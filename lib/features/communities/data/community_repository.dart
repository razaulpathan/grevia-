import '../../../core/constants/firebase_constants.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/utils/id_generators.dart';
import '../domain/models/community_model.dart';

abstract class CommunityRepository {
  Future<CommunityModel> createCommunity({
    required String name,
    required String description,
    required String ownerId,
    required List<String> linkedGroupIds,
    String? photoUrl,
  });
  Future<CommunityModel?> getCommunity(String communityId);
}

class FirestoreCommunityRepository implements CommunityRepository {
  final FirebaseService _firebaseService;
  final Map<String, CommunityModel> _localCommunities = {};

  FirestoreCommunityRepository([FirebaseService? firebaseService])
      : _firebaseService = firebaseService ?? FirebaseService.instance;

  @override
  Future<CommunityModel> createCommunity({
    required String name,
    required String description,
    required String ownerId,
    required List<String> linkedGroupIds,
    String? photoUrl,
  }) async {
    final communityId = IdGenerators.generateMessageId();
    final community = CommunityModel(
      communityId: communityId,
      name: name,
      description: description,
      photoUrl: photoUrl,
      ownerId: ownerId,
      adminIds: [ownerId],
      linkedGroupIds: linkedGroupIds,
      memberIds: [ownerId],
      createdAt: DateTime.now(),
    );

    _localCommunities[communityId] = community;
    final firestore = _firebaseService.firestore;
    if (firestore != null) {
      await firestore
          .collection(FirebaseCollections.communities)
          .doc(communityId)
          .set(community.toMap());
    }

    return community;
  }

  @override
  Future<CommunityModel?> getCommunity(String communityId) async {
    if (_localCommunities.containsKey(communityId))
      return _localCommunities[communityId];
    final firestore = _firebaseService.firestore;
    if (firestore == null) return null;

    final doc = await firestore
        .collection(FirebaseCollections.communities)
        .doc(communityId)
        .get();
    if (!doc.exists || doc.data() == null) return null;
    final community = CommunityModel.fromMap(doc.data()!, doc.id);
    _localCommunities[communityId] = community;
    return community;
  }
}
