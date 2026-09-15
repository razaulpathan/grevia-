import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../constants/firebase_constants.dart';
import 'firebase_service.dart';

import '../constants/rtc_constants.dart';

class WebRtcIceConfiguration {
  final List<Map<String, dynamic>> iceServers;
  final String primaryWsServer;
  final String secondaryWsServer;

  const WebRtcIceConfiguration({
    this.iceServers = const [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
    ],
    this.primaryWsServer = RtcConstants.primaryWebSocketServer,
    this.secondaryWsServer = RtcConstants.secondaryWebSocketServer,
  });

  /// Factory for adding custom coturn TURN credentials
  factory WebRtcIceConfiguration.withTurn({
    required String turnUrl,
    required String username,
    required String credential,
    String? primaryWsServer,
    String? secondaryWsServer,
  }) {
    return WebRtcIceConfiguration(
      iceServers: [
        {'urls': 'stun:stun.l.google.com:19302'},
        {
          'urls': turnUrl,
          'username': username,
          'credential': credential,
        },
      ],
      primaryWsServer: primaryWsServer ?? RtcConstants.primaryWebSocketServer,
      secondaryWsServer: secondaryWsServer ?? RtcConstants.secondaryWebSocketServer,
    );
  }
}

class WebRtcService {
  final FirebaseService _firebaseService;
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;

  final RTCVideoRenderer localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer remoteRenderer = RTCVideoRenderer();

  StreamSubscription? _callDocSub;
  StreamSubscription? _callerIceSub;
  StreamSubscription? _calleeIceSub;

  WebRtcService([FirebaseService? firebaseService])
      : _firebaseService = firebaseService ?? FirebaseService.instance;

  Future<void> initRenderers() async {
    await localRenderer.initialize();
    await remoteRenderer.initialize();
  }

  Future<void> openUserMedia({required bool isVideo}) async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': isVideo
          ? {
              'mandatory': {
                'minWidth': '640',
                'minHeight': '480',
                'minFrameRate': '30',
              },
              'facingMode': 'user',
              'optional': [],
            }
          : false,
    };

    _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
    localRenderer.srcObject = _localStream;
  }

  Future<RTCPeerConnection> _createPeerConnection() async {
    const config = WebRtcIceConfiguration();
    final Map<String, dynamic> rtcConfig = {
      'iceServers': config.iceServers,
      'sdpSemantics': 'unified-plan',
    };

    final pc = await createPeerConnection(rtcConfig);

    _localStream?.getTracks().forEach((track) {
      pc.addTrack(track, _localStream!);
    });

    pc.onTrack = (RTCTrackEvent event) {
      if (event.streams.isNotEmpty) {
        _remoteStream = event.streams[0];
        remoteRenderer.srcObject = _remoteStream;
      }
    };

    return pc;
  }

  /// Create Offer (Caller)
  Future<void> createOffer(String callId) async {
    _peerConnection = await _createPeerConnection();
    final firestore = _firebaseService.firestore;
    if (firestore == null) return;

    final callDoc = firestore.collection(FirebaseCollections.calls).doc(callId);
    final callerCandidatesCollection =
        callDoc.collection('callerIceCandidates');

    _peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
      callerCandidatesCollection.add(candidate.toMap());
    };

    final offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);

    await callDoc.set({
      'offer': {'sdp': offer.sdp, 'type': offer.type},
      'status': 'ringing',
    }, SetOptions(merge: true));

    // Listen for Answer
    _callDocSub = callDoc.snapshots().listen((snapshot) async {
      final data = snapshot.data();
      if (data != null && data['answer'] != null && _peerConnection != null) {
        final answer = RTCSessionDescription(
          data['answer']['sdp'],
          data['answer']['type'],
        );
        if (_peerConnection?.signalingState !=
            RTCSignalingState.RTCSignalingStateStable) {
          await _peerConnection!.setRemoteDescription(answer);
        }
      }
    });

    // Listen for Callee ICE candidates
    _calleeIceSub = callDoc
        .collection('calleeIceCandidates')
        .snapshots()
        .listen((snapshot) {
      for (final change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data();
          if (data != null) {
            _peerConnection?.addCandidate(
              RTCIceCandidate(
                data['candidate'],
                data['sdpMid'],
                data['sdpMLineIndex'],
              ),
            );
          }
        }
      }
    });
  }

  /// Answer Call (Callee)
  Future<void> answerCall(String callId) async {
    _peerConnection = await _createPeerConnection();
    final firestore = _firebaseService.firestore;
    if (firestore == null) return;

    final callDoc = firestore.collection(FirebaseCollections.calls).doc(callId);
    final calleeCandidatesCollection =
        callDoc.collection('calleeIceCandidates');

    _peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
      calleeCandidatesCollection.add(candidate.toMap());
    };

    final snapshot = await callDoc.get();
    final data = snapshot.data();
    if (data != null && data['offer'] != null) {
      final offer = RTCSessionDescription(
        data['offer']['sdp'],
        data['offer']['type'],
      );
      await _peerConnection!.setRemoteDescription(offer);

      final answer = await _peerConnection!.createAnswer();
      await _peerConnection!.setLocalDescription(answer);

      await callDoc.set({
        'answer': {'sdp': answer.sdp, 'type': answer.type},
        'status': 'connected',
      }, SetOptions(merge: true));
    }

    // Listen for Caller ICE candidates
    _callerIceSub = callDoc
        .collection('callerIceCandidates')
        .snapshots()
        .listen((snapshot) {
      for (final change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data();
          if (data != null) {
            _peerConnection?.addCandidate(
              RTCIceCandidate(
                data['candidate'],
                data['sdpMid'],
                data['sdpMLineIndex'],
              ),
            );
          }
        }
      }
    });
  }

  void toggleMicrophone(bool isMuted) {
    _localStream?.getAudioTracks().forEach((track) {
      track.enabled = !isMuted;
    });
  }

  void toggleCamera(bool isCameraOff) {
    _localStream?.getVideoTracks().forEach((track) {
      track.enabled = !isCameraOff;
    });
  }

  Future<void> switchCamera() async {
    if (_localStream != null && _localStream!.getVideoTracks().isNotEmpty) {
      final videoTrack = _localStream!.getVideoTracks().first;
      await Helper.switchCamera(videoTrack);
    }
  }

  Future<void> endCall(String callId) async {
    final firestore = _firebaseService.firestore;
    if (firestore != null) {
      await firestore.collection(FirebaseCollections.calls).doc(callId).update({
        'status': 'ended',
        'endedAt': FieldValue.serverTimestamp(),
      });
    }
    await dispose();
  }

  Future<void> dispose() async {
    await _callDocSub?.cancel();
    await _callerIceSub?.cancel();
    await _calleeIceSub?.cancel();

    _localStream?.getTracks().forEach((track) => track.stop());
    await _localStream?.dispose();
    _localStream = null;

    await _peerConnection?.close();
    _peerConnection = null;

    try {
      localRenderer.srcObject = null;
      remoteRenderer.srcObject = null;
      await localRenderer.dispose();
      await remoteRenderer.dispose();
    } catch (_) {}
  }
}
