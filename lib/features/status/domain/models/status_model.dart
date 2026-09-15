import 'package:cloud_firestore/cloud_firestore.dart';

enum StatusType {
  text,
  photo,
  video,
}

class StatusViewer {
  final String userId;
  final String displayName;
  final String? photoUrl;
  final DateTime viewedAt;

  const StatusViewer({
    required this.userId,
    required this.displayName,
    this.photoUrl,
    required this.viewedAt,
  });

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'displayName': displayName,
        'photoUrl': photoUrl,
        'viewedAt': Timestamp.fromDate(viewedAt),
      };

  factory StatusViewer.fromMap(Map<String, dynamic> map) {
    DateTime parseDateTime(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return StatusViewer(
      userId: map['userId'] as String? ?? '',
      displayName: map['displayName'] as String? ?? 'User',
      photoUrl: map['photoUrl'] as String?,
      viewedAt: parseDateTime(map['viewedAt']),
    );
  }
}

class StatusModel {
  final String statusId;
  final String userId;
  final String userName;
  final String? userPhoto;
  final StatusType type;
  final String content; // text content or media URL
  final String? caption;
  final int backgroundColor; // for text status, e.g. 0xFF0F7C43
  final DateTime createdAt;
  final List<StatusViewer> viewers;
  final String privacy;

  const StatusModel({
    required this.statusId,
    required this.userId,
    required this.userName,
    this.userPhoto,
    required this.type,
    required this.content,
    this.caption,
    this.backgroundColor = 0xFF0F7C43,
    required this.createdAt,
    this.viewers = const [],
    this.privacy = 'contacts',
  });

  bool get isExpired => DateTime.now().difference(createdAt).inHours >= 24;

  Map<String, dynamic> toMap() {
    return {
      'statusId': statusId,
      'userId': userId,
      'userName': userName,
      'userPhoto': userPhoto,
      'type': type.name,
      'content': content,
      'caption': caption,
      'backgroundColor': backgroundColor,
      'createdAt': Timestamp.fromDate(createdAt),
      'viewers': viewers.map((v) => v.toMap()).toList(),
      'privacy': privacy,
    };
  }

  factory StatusModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime parseDateTime(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return StatusModel(
      statusId: id,
      userId: map['userId'] as String? ?? '',
      userName: map['userName'] as String? ?? 'User',
      userPhoto: map['userPhoto'] as String?,
      type: StatusType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => StatusType.text,
      ),
      content: map['content'] as String? ?? '',
      caption: map['caption'] as String?,
      backgroundColor: map['backgroundColor'] as int? ?? 0xFF0F7C43,
      createdAt: parseDateTime(map['createdAt']),
      viewers: (map['viewers'] as List? ?? [])
          .map((v) => StatusViewer.fromMap(Map<String, dynamic>.from(v as Map)))
          .toList(),
      privacy: map['privacy'] as String? ?? 'contacts',
    );
  }
}
