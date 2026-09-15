import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/widgets/grevia_button.dart';

class QrScannerScreen extends ConsumerStatefulWidget {
  const QrScannerScreen({super.key});

  @override
  ConsumerState<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends ConsumerState<QrScannerScreen> {
  final _manualInputController = TextEditingController();

  @override
  void dispose() {
    _manualInputController.dispose();
    super.dispose();
  }

  void _handleDeepLink(String data) {
    // Expected format: grevia://user/{username} or plain username
    String username = data.trim();
    if (username.startsWith('grevia://user/')) {
      username = username.replaceFirst('grevia://user/', '');
    } else if (username.startsWith('@')) {
      username = username.substring(1);
    }

    if (username.isEmpty) return;

    final userRepo = ref.read(userRepositoryProvider);
    userRepo.searchUsers(username).then((results) {
      if (!mounted) return;
      if (results.isNotEmpty) {
        final target = results.first;
        context.pushReplacement(
          '/user/${target.uid}',
          extra: {
            'name': target.displayName,
            'username': target.username,
            'bio': target.bio,
            'photoUrl': target.photoUrl,
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No user found for @$username')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Camera Viewfinder Box
              Expanded(
                child: Center(
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppColors.primaryGreen,
                        width: 2.5,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.qr_code_scanner,
                        size: 100,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Point your camera at a Grevia QR code, or enter a username below.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _manualInputController,
                      decoration: const InputDecoration(
                        hintText: 'Enter @username...',
                        prefixIcon: Icon(Icons.alternate_email),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 50,
                    child: GreviaButton(
                      text: 'Find',
                      onPressed: () =>
                          _handleDeepLink(_manualInputController.text),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
