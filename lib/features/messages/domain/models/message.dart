import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType {
  text,
  image,
  video,
  voice,
  document,
  file,
  gif,
  sticker,
  contact,
  location,
  poll,
  system,
}

enum DeliveryStatus {
  sending,
  sent,
  delivered,
  read,
  failed,
}

class ReplyMetadata {
  final String messageId;
  final String senderName;
  final String text;
  final MessageType type;

  const ReplyMetadata({
    required this.messageId,
    required this.senderName,
    required this.text,
    required this.type,
  });

  Map<String, dynamic> toMap() => {
        'messageId': messageId,
        'senderName': senderName,
        'text': text,
        'type': type.name,
      };

  factory ReplyMetadata.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return const ReplyMetadata(
        messageId: '',
        senderName: '',
        text: '',
        type: MessageType.text,
      );
    }
    return ReplyMetadata(
      messageId: map['messageId'] as String? ?? '',
      senderName: map['senderName'] as String? ?? '',
      text: map['text'] as String? ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => MessageType.text,
      ),
    );
  }
}

class PollOption {
  final String id;
  final String text;
  final List<String> voterUserIds;

  const PollOption({
    required this.id,
    required this.text,
    this.voterUserIds = const [],
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'text': text,
        'voterUserIds': voterUserIds,
      };

  factory PollOption.fromMap(Map<String, dynamic> map) => PollOption(
        id: map['id'] as String? ?? '',
        text: map['text'] as String? ?? '',
        voterUserIds: List<String>.from(map['voterUserIds'] as List? ?? []),
      );
}

class PollData {
  final String question;
  final List<PollOption> options;
  final bool isMultipleChoice;

  const PollData({
    required this.question,
    required this.options,
    this.isMultipleChoice = false,
  });

  Map<String, dynamic> toMap() => {
        'question': question,
        'options': options.map((e) => e.toMap()).toList(),
        'isMultipleChoice': isMultipleChoice,
      };

  factory PollData.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const PollData(question: '', options: []);
    return PollData(
      question: map['question'] as String? ?? '',
      options: (map['options'] as List? ?? [])
          .map((e) => PollOption.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
      isMultipleChoice: map['isMultipleChoice'] as bool? ?? false,
    );
  }
}

class LocationData {
  final double latitude;
  final double longitude;
  final String address;

  const LocationData({
    required this.latitude,
    required this.longitude,
    this.address = '',
  });

  Map<String, dynamic> toMap() => {
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
      };

  factory LocationData.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const LocationData(latitude: 0, longitude: 0);
    return LocationData(
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      address: map['address'] as String? ?? '',
    );
  }
}

class Message {
  final String messageId;
  final String chatId;
  final String senderId;
  final String senderName;
  final MessageType type;
  final String text;
  final String? mediaUrl;
  final String? thumbnailUrl;
  final String? fileName;
  final int? fileSize;
  final String? mimeType;
  final int? duration; // for voice/video in seconds
  final ReplyMetadata? replyTo;
  final Map<String, String> reactions; // userId -> emoji
  final DateTime createdAt;
  final DateTime? editedAt;
  final DateTime? deletedAt;
  final bool isDeletedForEveryone;
  final DeliveryStatus deliveryStatus;
  final PollData? pollData;
  final LocationData? locationData;
  final bool isPinned;

  const Message({
    required this.messageId,
    required this.chatId,
    required this.senderId,
    this.senderName = '',
    this.type = MessageType.text,
    this.text = '',
    this.mediaUrl,
    this.thumbnailUrl,
    this.fileName,
    this.fileSize,
    this.mimeType,
    this.duration,
    this.replyTo,
    this.reactions = const {},
    required this.createdAt,
    this.editedAt,
    this.deletedAt,
    this.isDeletedForEveryone = false,
    this.deliveryStatus = DeliveryStatus.sent,
    this.pollData,
    this.locationData,
    this.isPinned = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'chatId': chatId,
      'senderId': senderId,
      'senderName': senderName,
      'type': type.name,
      'text': text,
      'mediaUrl': mediaUrl,
      'thumbnailUrl': thumbnailUrl,
      'fileName': fileName,
      'fileSize': fileSize,
      'mimeType': mimeType,
      'duration': duration,
      'replyTo': replyTo?.toMap(),
      'reactions': reactions,
      'createdAt': Timestamp.fromDate(createdAt),
      'editedAt': editedAt != null ? Timestamp.fromDate(editedAt!) : null,
      'deletedAt': deletedAt != null ? Timestamp.fromDate(deletedAt!) : null,
      'isDeletedForEveryone': isDeletedForEveryone,
      'deliveryStatus': deliveryStatus.name,
      'pollData': pollData?.toMap(),
      'locationData': locationData?.toMap(),
      'isPinned': isPinned,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map, String id) {
    DateTime parseDateTime(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return Message(
      messageId: id,
      chatId: map['chatId'] as String? ?? '',
      senderId: map['senderId'] as String? ?? '',
      senderName: map['senderName'] as String? ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => MessageType.text,
      ),
      text: map['text'] as String? ?? '',
      mediaUrl: map['mediaUrl'] as String?,
      thumbnailUrl: map['thumbnailUrl'] as String?,
      fileName: map['fileName'] as String?,
      fileSize: map['fileSize'] as int?,
      mimeType: map['mimeType'] as String?,
      duration: map['duration'] as int?,
      replyTo: map['replyTo'] != null
          ? ReplyMetadata.fromMap(
              Map<String, dynamic>.from(map['replyTo'] as Map))
          : null,
      reactions: Map<String, String>.from(map['reactions'] as Map? ?? {}),
      createdAt: parseDateTime(map['createdAt']),
      editedAt: map['editedAt'] != null ? parseDateTime(map['editedAt']) : null,
      deletedAt:
          map['deletedAt'] != null ? parseDateTime(map['deletedAt']) : null,
      isDeletedForEveryone: map['isDeletedForEveryone'] as bool? ?? false,
      deliveryStatus: DeliveryStatus.values.firstWhere(
        (e) => e.name == map['deliveryStatus'],
        orElse: () => DeliveryStatus.sent,
      ),
      pollData: map['pollData'] != null
          ? PollData.fromMap(Map<String, dynamic>.from(map['pollData'] as Map))
          : null,
      locationData: map['locationData'] != null
          ? LocationData.fromMap(
              Map<String, dynamic>.from(map['locationData'] as Map))
          : null,
      isPinned: map['isPinned'] as bool? ?? false,
    );
  }

  Message copyWith({
    String? text,
    DeliveryStatus? deliveryStatus,
    DateTime? editedAt,
    DateTime? deletedAt,
    bool? isDeletedForEveryone,
    Map<String, String>? reactions,
    PollData? pollData,
    bool? isPinned,
  }) {
    return Message(
      messageId: messageId,
      chatId: chatId,
      senderId: senderId,
      senderName: senderName,
      type: type,
      text: text ?? this.text,
      mediaUrl: mediaUrl,
      thumbnailUrl: thumbnailUrl,
      fileName: fileName,
      fileSize: fileSize,
      mimeType: mimeType,
      duration: duration,
      replyTo: replyTo,
      reactions: reactions ?? this.reactions,
      createdAt: createdAt,
      editedAt: editedAt ?? this.editedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      isDeletedForEveryone: isDeletedForEveryone ?? this.isDeletedForEveryone,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      pollData: pollData ?? this.pollData,
      locationData: locationData,
      isPinned: isPinned ?? this.isPinned,
    );
  }
}
