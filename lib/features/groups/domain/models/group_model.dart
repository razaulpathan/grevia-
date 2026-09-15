import 'package:cloud_firestore/cloud_firestore.dart';

class GroupPermissions {
  final bool canSendMessages;
  final bool canSendMedia;
  final bool canAddMembers;
  final bool canChangeInfo;
  final bool canPinMessages;
  final bool canCreatePolls;

  const GroupPermissions({
    this.canSendMessages = true,
    this.canSendMedia = true,
    this.canAddMembers = true,
    this.canChangeInfo = false,
    this.canPinMessages = true,
    this.canCreatePolls = true,
  });

  Map<String, dynamic> toMap() => {
        'canSendMessages': canSendMessages,
        'canSendMedia': canSendMedia,
        'canAddMembers': canAddMembers,
        'canChangeInfo': canChangeInfo,
        'canPinMessages': canPinMessages,
        'canCreatePolls': canCreatePolls,
      };

  factory GroupPermissions.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const GroupPermissions();
    return GroupPermissions(
      canSendMessages: map['canSendMessages'] as bool? ?? true,
      canSendMedia: map['canSendMedia'] as bool? ?? true,
      canAddMembers: map['canAddMembers'] as bool? ?? true,
      canChangeInfo: map['canChangeInfo'] as bool? ?? false,
      canPinMessages: map['canPinMessages'] as bool? ?? true,
      canCreatePolls: map['canCreatePolls'] as bool? ?? true,
    );
  }
}

class GroupModel {
  final String groupId;
  final String name;
  final String description;
  final String? photoUrl;
  final String ownerId;
  final List<String> adminIds;
  final List<String> memberIds;
  final DateTime createdAt;
  final bool isPrivate;
  final String inviteCode;
  final GroupPermissions permissions;
  final List<String> pendingJoinRequests;

  const GroupModel({
    required this.groupId,
    required this.name,
    this.description = '',
    this.photoUrl,
    required this.ownerId,
    this.adminIds = const [],
    this.memberIds = const [],
    required this.createdAt,
    this.isPrivate = false,
    this.inviteCode = '',
    this.permissions = const GroupPermissions(),
    this.pendingJoinRequests = const [],
  });

  bool isOwner(String userId) => ownerId == userId;
  bool isAdmin(String userId) => isOwner(userId) || adminIds.contains(userId);
  bool isMember(String userId) => memberIds.contains(userId);

  Map<String, dynamic> toMap() {
    return {
      'groupId': groupId,
      'name': name,
      'description': description,
      'photoUrl': photoUrl,
      'ownerId': ownerId,
      'adminIds': adminIds,
      'memberIds': memberIds,
      'createdAt': Timestamp.fromDate(createdAt),
      'isPrivate': isPrivate,
      'inviteCode': inviteCode,
      'permissions': permissions.toMap(),
      'pendingJoinRequests': pendingJoinRequests,
    };
  }

  factory GroupModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime parseDateTime(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return GroupModel(
      groupId: id,
      name: map['name'] as String? ?? 'Group',
      description: map['description'] as String? ?? '',
      photoUrl: map['photoUrl'] as String?,
      ownerId: map['ownerId'] as String? ?? '',
      adminIds: List<String>.from(map['adminIds'] as List? ?? []),
      memberIds: List<String>.from(map['memberIds'] as List? ?? []),
      createdAt: parseDateTime(map['createdAt']),
      isPrivate: map['isPrivate'] as bool? ?? false,
      inviteCode: map['inviteCode'] as String? ?? '',
      permissions:
          GroupPermissions.fromMap(map['permissions'] as Map<String, dynamic>?),
      pendingJoinRequests:
          List<String>.from(map['pendingJoinRequests'] as List? ?? []),
    );
  }
}
