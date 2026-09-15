import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firebase_constants.dart';
import '../../../core/services/firebase_service.dart';
import '../domain/models/call_session.dart';

abstract class CallRepository {
  Future<void> initiateCall(CallSession session);
  Stream<List<CallSession>> getActiveCallsStream(String userId);
  Stream<List<CallSession>> getCallHistoryStream(String userId);
  Future<void> updateCallStatus(String callId, CallStatus status);
}

class FirestoreCallRepository implements CallRepository {
  final FirebaseService _firebaseService;
  final List<CallSession> _localCalls = [];
  final StreamController<List<CallSession>> _callsStreamController =
      StreamController<List<CallSession>>.broadcast();

  FirestoreCallRepository([FirebaseService? firebaseService])
      : _firebaseService = firebaseService ?? FirebaseService.instance;

  @override
  Future<void> initiateCall(CallSession session) async {
    _localCalls.insert(0, session);
    _callsStreamController.add(_localCalls);

    final firestore = _firebaseService.firestore;
    if (firestore != null) {
      await firestore
          .collection(FirebaseCollections.calls)
          .doc(session.callId)
          .set(session.toMap());
    }
  }

  @override
  Stream<List<CallSession>> getActiveCallsStream(String userId) {
    final firestore = _firebaseService.firestore;
    if (firestore == null) {
      return _callsStreamController.stream.map(
        (calls) => calls
            .where(
                (c) => c.receiverId == userId && c.status == CallStatus.ringing)
            .toList(),
      );
    }

    return firestore
        .collection(FirebaseCollections.calls)
        .where('receiverId', isEqualTo: userId)
        .where('status', isEqualTo: 'ringing')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => CallSession.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  @override
  Stream<List<CallSession>> getCallHistoryStream(String userId) {
    final firestore = _firebaseService.firestore;
    if (firestore == null) {
      return _callsStreamController.stream;
    }

    return firestore
        .collection(FirebaseCollections.calls)
        .where('callerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(40)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => CallSession.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  @override
  Future<void> updateCallStatus(String callId, CallStatus status) async {
    final firestore = _firebaseService.firestore;
    if (firestore != null) {
      await firestore.collection(FirebaseCollections.calls).doc(callId).update({
        'status': status.name,
        if (status == CallStatus.ended) 'endedAt': FieldValue.serverTimestamp(),
      });
    }
  }
}
