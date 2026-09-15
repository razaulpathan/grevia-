import 'package:cloud_firestore/cloud_firestore.dart';

enum ChatType {
  private,
  group,
  channel,
  saved,
}

class Chat {
  final String chatId;
  final ChatType type;
  final List<String> participantIds;
  final Map<String, String> participantNames;
  final Map<String, String> participantPhotos;
  final String lastMessageText;
  final String lastMessageType;
  final String lastMessageSenderId;
  final DateTime? lastMessageTime;
  final Map<String, int> unreadCounts;
  final List<String> pinnedByUserIds;
  final List<String> mutedByUserIds;
  final List<String> archivedByUserIds;
  final Map<String, DateTime> typingUsers;
  final Map<String, String> drafts;
  final String? groupName;
  final String? groupPhoto;
  final int disappearingDurationSeconds;

  const Chat({
    required this.chatId,
    required this.type,
    required this.participantIds,
    this.participantNames = const {},
    this.participantPhotos = const {},
    this.lastMessageText = '',
    this.lastMessageType = 'text',
    this.lastMessageSenderId = '',
    this.lastMessageTime,
    this.unreadCounts = const {},
    this.pinnedByUserIds = const [],
    this.mutedByUserIds = const [],
    this.archivedByUserIds = const [],
    this.typingUsers = const {},
    this.drafts = const {},
    this.groupName,
    this.groupPhoto,
    this.disappearingDurationSeconds = 0,
  });

  bool isPinnedBy(String userId) => pinnedByUserIds.contains(userId);
  bool isMutedBy(String userId) => mutedByUserIds.contains(userId);
  bool isArchivedBy(String userId) => archivedByUserIds.contains(userId);
  int getUnreadCount(String userId) => unreadCounts[userId] ?? 0;
  String getDraft(String userId) => drafts[userId] ?? '';

  String getChatTitle(String currentUserId) {
    if (type == ChatType.saved) return 'Saved Messages';
    if (type == ChatType.group || type == ChatType.channel) {
      return groupName ?? 'Group';
    }
    // Private chat: find other participant
    final otherId = participantIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => currentUserId,
    );
    return participantNames[otherId] ?? 'User';
  }

  String? getChatAvatar(String currentUserId) {
    if (type == ChatType.saved) return null;
    if (type == ChatType.group || type == ChatType.channel) {
      return groupPhoto;
    }
    final otherId = participantIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => currentUserId,
    );
    return participantPhotos[otherId];
  }

  Map<String, dynamic> toMap() {
    return {
      'chatId': chatId,
      'type': type.name,
      'participantIds': participantIds,
      'participantNames': participantNames,
      'participantPhotos': participantPhotos,
      'lastMessageText': lastMessageText,
      'lastMessageType': lastMessageType,
      'lastMessageSenderId': lastMessageSenderId,
      'lastMessageTime':
          lastMessageTime != null ? Timestamp.fromDate(lastMessageTime!) : null,
      'unreadCounts': unreadCounts,
      'pinnedByUserIds': pinnedByUserIds,
      'mutedByUserIds': mutedByUserIds,
      'archivedByUserIds': archivedByUserIds,
      'drafts': drafts,
      'groupName': groupName,
      'groupPhoto': groupPhoto,
      'disappearingDurationSeconds': disappearingDurationSeconds,
    };
  }

  factory Chat.fromMap(Map<String, dynamic> map, String id) {
    DateTime? parseDateTime(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val);
      return null;
    }

    return Chat(
      chatId: id,
      type: ChatType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => ChatType.private,
      ),
      participantIds: List<String>.from(map['participantIds'] as List? ?? []),
      participantNames:
          Map<String, String>.from(map['participantNames'] as Map? ?? {}),
      participantPhotos:
          Map<String, String>.from(map['participantPhotos'] as Map? ?? {}),
      lastMessageText: map['lastMessageText'] as String? ?? '',
      lastMessageType: map['lastMessageType'] as String? ?? 'text',
      lastMessageSenderId: map['lastMessageSenderId'] as String? ?? '',
      lastMessageTime: parseDateTime(map['lastMessageTime']),
      unreadCounts: Map<String, int>.from(map['unreadCounts'] as Map? ?? {}),
      pinnedByUserIds: List<String>.from(map['pinnedByUserIds'] as List? ?? []),
      mutedByUserIds: List<String>.from(map['mutedByUserIds'] as List? ?? []),
      archivedByUserIds:
          List<String>.from(map['archivedByUserIds'] as List? ?? []),
      drafts: Map<String, String>.from(map['drafts'] as Map? ?? {}),
      groupName: map['groupName'] as String?,
      groupPhoto: map['groupPhoto'] as String?,
      disappearingDurationSeconds:
          map['disappearingDurationSeconds'] as int? ?? 0,
    );
  }

  Chat copyWith({
    String? lastMessageText,
    String? lastMessageType,
    String? lastMessageSenderId,
    DateTime? lastMessageTime,
    Map<String, int>? unreadCounts,
    List<String>? pinnedByUserIds,
    List<String>? mutedByUserIds,
    List<String>? archivedByUserIds,
    Map<String, String>? drafts,
    String? groupName,
    String? groupPhoto,
    int? disappearingDurationSeconds,
  }) {
    return Chat(
      chatId: chatId,
      type: type,
      participantIds: participantIds,
      participantNames: participantNames,
      participantPhotos: participantPhotos,
      lastMessageText: lastMessageText ?? this.lastMessageText,
      lastMessageType: lastMessageType ?? this.lastMessageType,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCounts: unreadCounts ?? this.unreadCounts,
      pinnedByUserIds: pinnedByUserIds ?? this.pinnedByUserIds,
      mutedByUserIds: mutedByUserIds ?? this.mutedByUserIds,
      archivedByUserIds: archivedByUserIds ?? this.archivedByUserIds,
      typingUsers: typingUsers,
      drafts: drafts ?? this.drafts,
      groupName: groupName ?? this.groupName,
      groupPhoto: groupPhoto ?? this.groupPhoto,
      disappearingDurationSeconds:
          disappearingDurationSeconds ?? this.disappearingDurationSeconds,
    );
  }
}
