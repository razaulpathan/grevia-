import 'package:cloud_firestore/cloud_firestore.dart';

class ChannelModel {
  final String channelId;
  final String name;
  final String username;
  final String description;
  final String? photoUrl;
  final String ownerId;
  final List<String> adminIds;
  final int subscriberCount;
  final List<String> subscriberIds;
  final bool isPrivate;
  final String inviteCode;
  final DateTime createdAt;

  const ChannelModel({
    required this.channelId,
    required this.name,
    this.username = '',
    this.description = '',
    this.photoUrl,
    required this.ownerId,
    this.adminIds = const [],
    this.subscriberCount = 0,
    this.subscriberIds = const [],
    this.isPrivate = false,
    this.inviteCode = '',
    required this.createdAt,
  });

  bool isOwner(String userId) => ownerId == userId;
  bool isAdmin(String userId) => isOwner(userId) || adminIds.contains(userId);
  bool isSubscriber(String userId) => subscriberIds.contains(userId);

  Map<String, dynamic> toMap() {
    return {
      'channelId': channelId,
      'name': name,
      'username': username,
      'description': description,
      'photoUrl': photoUrl,
      'ownerId': ownerId,
      'adminIds': adminIds,
      'subscriberCount': subscriberCount,
      'subscriberIds': subscriberIds,
      'isPrivate': isPrivate,
      'inviteCode': inviteCode,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory ChannelModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime parseDateTime(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return ChannelModel(
      channelId: id,
      name: map['name'] as String? ?? 'Channel',
      username: map['username'] as String? ?? '',
      description: map['description'] as String? ?? '',
      photoUrl: map['photoUrl'] as String?,
      ownerId: map['ownerId'] as String? ?? '',
      adminIds: List<String>.from(map['adminIds'] as List? ?? []),
      subscriberCount: map['subscriberCount'] as int? ?? 0,
      subscriberIds: List<String>.from(map['subscriberIds'] as List? ?? []),
      isPrivate: map['isPrivate'] as bool? ?? false,
      inviteCode: map['inviteCode'] as String? ?? '',
      createdAt: parseDateTime(map['createdAt']),
    );
  }
}
