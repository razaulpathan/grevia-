import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firebase_constants.dart';
import '../../../core/services/firebase_service.dart';
import '../domain/models/status_model.dart';

abstract class StatusRepository {
  Stream<List<StatusModel>> getStatusesStream();
  Future<void> postStatus(StatusModel status);
  Future<void> recordViewer(String statusId, StatusViewer viewer);
  Future<void> deleteStatus(String statusId);
}

class FirestoreStatusRepository implements StatusRepository {
  final FirebaseService _firebaseService;
  final List<StatusModel> _localStatuses = [];
  final StreamController<List<StatusModel>> _statusController =
      StreamController<List<StatusModel>>.broadcast();

  FirestoreStatusRepository([FirebaseService? firebaseService])
      : _firebaseService = firebaseService ?? FirebaseService.instance;

  @override
  Stream<List<StatusModel>> getStatusesStream() {
    final firestore = _firebaseService.firestore;
    if (firestore == null) {
      return _statusController.stream;
    }

    final oneDayAgo = DateTime.now().subtract(const Duration(hours: 24));

    return firestore
        .collection(FirebaseCollections.statuses)
        .where('createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(oneDayAgo))
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => StatusModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  @override
  Future<void> postStatus(StatusModel status) async {
    _localStatuses.insert(0, status);
    _statusController.add(_localStatuses);

    final firestore = _firebaseService.firestore;
    if (firestore != null) {
      await firestore
          .collection(FirebaseCollections.statuses)
          .doc(status.statusId)
          .set(status.toMap());
    }
  }

  @override
  Future<void> recordViewer(String statusId, StatusViewer viewer) async {
    final firestore = _firebaseService.firestore;
    if (firestore != null) {
      await firestore
          .collection(FirebaseCollections.statuses)
          .doc(statusId)
          .update({
        'viewers': FieldValue.arrayUnion([viewer.toMap()]),
      });
    }
  }

  @override
  Future<void> deleteStatus(String statusId) async {
    _localStatuses.removeWhere((s) => s.statusId == statusId);
    _statusController.add(_localStatuses);

    final firestore = _firebaseService.firestore;
    if (firestore != null) {
      await firestore
          .collection(FirebaseCollections.statuses)
          .doc(statusId)
          .delete();
    }
  }
}
