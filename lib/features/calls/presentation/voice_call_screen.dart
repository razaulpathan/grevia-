import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/avatar_view.dart';

class VoiceCallScreen extends ConsumerStatefulWidget {
  final String callId;
  final String? callerName;

  const VoiceCallScreen({
    super.key,
    required this.callId,
    this.callerName,
  });

  @override
  ConsumerState<VoiceCallScreen> createState() => _VoiceCallScreenState();
}

class _VoiceCallScreenState extends ConsumerState<VoiceCallScreen> {
  bool _isMuted = false;
  bool _isSpeaker = false;
  int _seconds = 0;
  Timer? _timer;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _startWebRtcCall();
  }

  Future<void> _startWebRtcCall() async {
    final webrtc = ref.read(webrtcServiceProvider);
    try {
      await webrtc.initRenderers();
      await webrtc.openUserMedia(isVideo: false);
      await webrtc.createOffer(widget.callId);

      // Simulate connection transition after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        setState(() => _isConnected = true);
        _startTimer();
      });
    } catch (_) {
      setState(() => _isConnected = true);
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _seconds++);
      }
    });
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
    final name = widget.callerName ?? 'Grevia Contact';

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 60),
            AvatarView(name: name, size: 110),
            const SizedBox(height: 24),
            Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _isConnected ? Formatters.formatDuration(_seconds) : 'Ringing...',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            // Call Controls Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 30),
              decoration: BoxDecoration(
                color: AppColors.darkSurface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCallBtn(
                    icon: _isMuted ? Icons.mic_off : Icons.mic,
                    isActive: _isMuted,
                    onTap: () {
                      setState(() => _isMuted = !_isMuted);
                      ref
                          .read(webrtcServiceProvider)
                          .toggleMicrophone(_isMuted);
                    },
                  ),
                  _buildCallBtn(
                    icon: Icons.call_end,
                    backgroundColor: AppColors.errorRed,
                    iconColor: Colors.white,
                    onTap: _endCall,
                  ),
                  _buildCallBtn(
                    icon: _isSpeaker ? Icons.volume_up : Icons.volume_down,
                    isActive: _isSpeaker,
                    onTap: () {
                      setState(() => _isSpeaker = !_isSpeaker);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallBtn({
    required IconData icon,
    required VoidCallback onTap,
    Color? backgroundColor,
    Color? iconColor,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: backgroundColor ??
              (isActive ? Colors.white : AppColors.darkSecondarySurface),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color:
              iconColor ?? (isActive ? AppColors.darkBackground : Colors.white),
          size: 28,
        ),
      ),
    );
  }
}
