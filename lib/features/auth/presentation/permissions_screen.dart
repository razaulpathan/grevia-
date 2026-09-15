import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/widgets/grevia_button.dart';

class PermissionsScreen extends StatelessWidget {
  const PermissionsScreen({super.key});

  Future<void> _requestPermissions(BuildContext context) async {
    await [
      Permission.contacts,
      Permission.notification,
      Permission.camera,
      Permission.microphone,
    ].request();

    if (context.mounted) {
      context.go(AppRoutes.chats);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final permissions = [
      {
        'icon': Icons.contacts_outlined,
        'title': 'Contacts Access',
        'desc':
            'To find your friends already using Grevia and sync names effortlessly.',
      },
      {
        'icon': Icons.notifications_none_outlined,
        'title': 'Notifications',
        'desc':
            'To receive instant alerts for incoming messages and audio/video calls.',
      },
      {
        'icon': Icons.camera_alt_outlined,
        'title': 'Camera & Microphone',
        'desc':
            'To take photos, record voice notes, and make high-definition WebRTC calls.',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Permissions'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'To give you the best communication experience, Grevia needs access to a few features on your device.',
                style: TextStyle(
                  fontSize: 15,
                  color: isDark
                      ? AppColors.textDarkSecondary
                      : AppColors.textLightSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),
              ...permissions.map((p) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkSecondarySurface
                              : AppColors.lightGreen,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          p['icon'] as IconData,
                          size: 24,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p['title'] as String,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.textDarkPrimary
                                    : AppColors.textLightPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              p['desc'] as String,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? AppColors.textDarkSecondary
                                    : AppColors.textLightSecondary,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const Spacer(),
              GreviaButton(
                text: 'Grant Permissions',
                onPressed: () => _requestPermissions(context),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () => context.go(AppRoutes.chats),
                  child: const Text('Maybe Later'),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
