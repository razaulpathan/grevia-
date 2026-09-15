import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityModel {
  final String communityId;
  final String name;
  final String description;
  final String? photoUrl;
  final String ownerId;
  final List<String> adminIds;
  final List<String> linkedGroupIds;
  final List<String> memberIds;
  final DateTime createdAt;

  const CommunityModel({
    required this.communityId,
    required this.name,
    this.description = '',
    this.photoUrl,
    required this.ownerId,
    this.adminIds = const [],
    this.linkedGroupIds = const [],
    this.memberIds = const [],
    required this.createdAt,
  });

  bool isOwner(String userId) => ownerId == userId;
  bool isAdmin(String userId) => isOwner(userId) || adminIds.contains(userId);

  Map<String, dynamic> toMap() {
    return {
      'communityId': communityId,
      'name': name,
      'description': description,
      'photoUrl': photoUrl,
      'ownerId': ownerId,
      'adminIds': adminIds,
      'linkedGroupIds': linkedGroupIds,
      'memberIds': memberIds,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory CommunityModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime parseDateTime(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return CommunityModel(
      communityId: id,
      name: map['name'] as String? ?? 'Community',
      description: map['description'] as String? ?? '',
      photoUrl: map['photoUrl'] as String?,
      ownerId: map['ownerId'] as String? ?? '',
      adminIds: List<String>.from(map['adminIds'] as List? ?? []),
      linkedGroupIds: List<String>.from(map['linkedGroupIds'] as List? ?? []),
      memberIds: List<String>.from(map['memberIds'] as List? ?? []),
      createdAt: parseDateTime(map['createdAt']),
    );
  }
}
