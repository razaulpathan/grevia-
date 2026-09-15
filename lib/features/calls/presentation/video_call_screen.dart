import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/utils/formatters.dart';

class VideoCallScreen extends ConsumerStatefulWidget {
  final String callId;
  final String? callerName;

  const VideoCallScreen({
    super.key,
    required this.callId,
    this.callerName,
  });

  @override
  ConsumerState<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends ConsumerState<VideoCallScreen> {
  bool _isMuted = false;
  bool _isCameraOff = false;
  int _seconds = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initWebRtc();
  }

  Future<void> _initWebRtc() async {
    final webrtc = ref.read(webrtcServiceProvider);
    try {
      await webrtc.initRenderers();
      await webrtc.openUserMedia(isVideo: true);
      await webrtc.createOffer(widget.callId);

      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => _seconds++);
      });
    } catch (_) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => _seconds++);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    ref.read(webrtcServiceProvider).dispose();
    super.dispose();
  }

  void _endCall() {
    ref.read(webrtcServiceProvider).endCall(widget.callId);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final webrtc = ref.watch(webrtcServiceProvider);
    final name = widget.callerName ?? 'Grevia Video Call';

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Remote Video Fullscreen
            Positioned.fill(
              child: webrtc.remoteRenderer.srcObject != null
                  ? RTCVideoView(webrtc.remoteRenderer,
                      objectFit:
                          RTCVideoViewObjectFit.RTCVideoViewObjectFitCover)
                  : Container(
                      color: const Color(0xFF1E2623),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.person,
                                size: 80, color: Colors.white38),
                            const SizedBox(height: 12),
                            Text(
                              name,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              Formatters.formatDuration(_seconds),
                              style: const TextStyle(
                                  color: Colors.white60, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),

            // Local Video Preview (Floating PIP)
            Positioned(
              top: 20,
              right: 20,
              child: Container(
                width: 100,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white24, width: 1.5),
                ),
                clipBehavior: Clip.antiAlias,
                child: webrtc.localRenderer.srcObject != null
                    ? RTCVideoView(webrtc.localRenderer,
                        mirror: true,
                        objectFit:
                            RTCVideoViewObjectFit.RTCVideoViewObjectFitCover)
                    : const Center(
                        child: Icon(Icons.videocam_off, color: Colors.white54),
                      ),
              ),
            ),

            // Controls Bar
            Positioned(
              bottom: 30,
              left: 24,
              right: 24,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.65),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(_isMuted ? Icons.mic_off : Icons.mic,
                          color: Colors.white),
                      onPressed: () {
                        setState(() => _isMuted = !_isMuted);
                        webrtc.toggleMicrophone(_isMuted);
                      },
                    ),
                    IconButton(
                      icon: Icon(
                          _isCameraOff ? Icons.videocam_off : Icons.videocam,
                          color: Colors.white),
                      onPressed: () {
                        setState(() => _isCameraOff = !_isCameraOff);
                        webrtc.toggleCamera(_isCameraOff);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.cameraswitch, color: Colors.white),
                      onPressed: () => webrtc.switchCamera(),
                    ),
                    IconButton(
                      icon: const Icon(Icons.call_end, color: Colors.white),
                      style: IconButton.styleFrom(
                          backgroundColor: AppColors.errorRed),
                      onPressed: _endCall,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
