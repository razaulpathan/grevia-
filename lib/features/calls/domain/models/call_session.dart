import 'package:cloud_firestore/cloud_firestore.dart';

enum CallType {
  voice,
  video,
}

enum CallStatus {
  ringing,
  connecting,
  connected,
  ended,
  missed,
  rejected,
}

class CallSession {
  final String callId;
  final String callerId;
  final String callerName;
  final String? callerPhoto;
  final String receiverId;
  final String receiverName;
  final String? receiverPhoto;
  final CallType type;
  final CallStatus status;
  final DateTime createdAt;
  final DateTime? endedAt;
  final int durationSeconds;
  final Map<String, dynamic>? offer;
  final Map<String, dynamic>? answer;

  const CallSession({
    required this.callId,
    required this.callerId,
    required this.callerName,
    this.callerPhoto,
    required this.receiverId,
    required this.receiverName,
    this.receiverPhoto,
    this.type = CallType.voice,
    this.status = CallStatus.ringing,
    required this.createdAt,
    this.endedAt,
    this.durationSeconds = 0,
    this.offer,
    this.answer,
  });

  bool isIncoming(String currentUserId) => receiverId == currentUserId;

  Map<String, dynamic> toMap() {
    return {
      'callId': callId,
      'callerId': callerId,
      'callerName': callerName,
      'callerPhoto': callerPhoto,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'receiverPhoto': receiverPhoto,
      'type': type.name,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'endedAt': endedAt != null ? Timestamp.fromDate(endedAt!) : null,
      'durationSeconds': durationSeconds,
      'offer': offer,
      'answer': answer,
    };
  }

  factory CallSession.fromMap(Map<String, dynamic> map, String id) {
    DateTime parseDateTime(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return CallSession(
      callId: id,
      callerId: map['callerId'] as String? ?? '',
      callerName: map['callerName'] as String? ?? 'Caller',
      callerPhoto: map['callerPhoto'] as String?,
      receiverId: map['receiverId'] as String? ?? '',
      receiverName: map['receiverName'] as String? ?? 'Receiver',
      receiverPhoto: map['receiverPhoto'] as String?,
      type: CallType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => CallType.voice,
      ),
      status: CallStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => CallStatus.ringing,
      ),
      createdAt: parseDateTime(map['createdAt']),
      endedAt: map['endedAt'] != null ? parseDateTime(map['endedAt']) : null,
      durationSeconds: map['durationSeconds'] as int? ?? 0,
      offer: map['offer'] as Map<String, dynamic>?,
      answer: map['answer'] as Map<String, dynamic>?,
    );
  }

  CallSession copyWith({
    CallStatus? status,
    DateTime? endedAt,
    int? durationSeconds,
    Map<String, dynamic>? answer,
  }) {
    return CallSession(
      callId: callId,
      callerId: callerId,
      callerName: callerName,
      callerPhoto: callerPhoto,
      receiverId: receiverId,
      receiverName: receiverName,
      receiverPhoto: receiverPhoto,
      type: type,
      status: status ?? this.status,
      createdAt: createdAt,
      endedAt: endedAt ?? this.endedAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      offer: offer,
      answer: answer ?? this.answer,
    );
  }
}
