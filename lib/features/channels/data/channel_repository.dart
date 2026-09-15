import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firebase_constants.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/utils/id_generators.dart';
import '../domain/models/channel_model.dart';

abstract class ChannelRepository {
  Future<ChannelModel> createChannel({
    required String name,
    required String username,
    required String description,
    required String ownerId,
    String? photoUrl,
    bool isPrivate = false,
  });
  Future<ChannelModel?> getChannel(String channelId);
  Future<void> subscribe(String channelId, String userId);
  Future<void> unsubscribe(String channelId, String userId);
}

class FirestoreChannelRepository implements ChannelRepository {
  final FirebaseService _firebaseService;
  final Map<String, ChannelModel> _localChannels = {};

  FirestoreChannelRepository([FirebaseService? firebaseService])
      : _firebaseService = firebaseService ?? FirebaseService.instance;

  @override
  Future<ChannelModel> createChannel({
    required String name,
    required String username,
    required String description,
    required String ownerId,
    String? photoUrl,
    bool isPrivate = false,
  }) async {
    final channelId = IdGenerators.generateMessageId();
    final inviteCode = IdGenerators.generateInviteCode();

    final channel = ChannelModel(
      channelId: channelId,
      name: name,
      username: username,
      description: description,
      photoUrl: photoUrl,
      ownerId: ownerId,
      adminIds: [ownerId],
      subscriberCount: 1,
      subscriberIds: [ownerId],
      isPrivate: isPrivate,
      inviteCode: inviteCode,
      createdAt: DateTime.now(),
    );

    _localChannels[channelId] = channel;
    final firestore = _firebaseService.firestore;
    if (firestore != null) {
      await firestore
          .collection(FirebaseCollections.channels)
          .doc(channelId)
          .set(channel.toMap());
    }

    return channel;
  }

  @override
  Future<ChannelModel?> getChannel(String channelId) async {
    if (_localChannels.containsKey(channelId)) return _localChannels[channelId];
    final firestore = _firebaseService.firestore;
    if (firestore == null) return null;

    final doc = await firestore
        .collection(FirebaseCollections.channels)
        .doc(channelId)
        .get();
    if (!doc.exists || doc.data() == null) return null;
    final channel = ChannelModel.fromMap(doc.data()!, doc.id);
    _localChannels[channelId] = channel;
    return channel;
  }

  @override
  Future<void> subscribe(String channelId, String userId) async {
    final firestore = _firebaseService.firestore;
    if (firestore != null) {
      await firestore
          .collection(FirebaseCollections.channels)
          .doc(channelId)
          .update({
        'subscriberIds': FieldValue.arrayUnion([userId]),
        'subscriberCount': FieldValue.increment(1),
      });
    }
  }

  @override
  Future<void> unsubscribe(String channelId, String userId) async {
    final firestore = _firebaseService.firestore;
    if (firestore != null) {
      await firestore
          .collection(FirebaseCollections.channels)
          .doc(channelId)
          .update({
        'subscriberIds': FieldValue.arrayRemove([userId]),
        'subscriberCount': FieldValue.increment(-1),
      });
    }
  }
}
