import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/widgets/avatar_view.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profile = ref.watch(currentUserProfileProvider).value;
    final authRepo = ref.watch(authRepositoryProvider);

    final name = profile?.displayName ?? 'Grevia User';
    final username = profile?.username ?? 'username';
    final phone = profile?.phoneNumber ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code),
            onPressed: () => context.push(AppRoutes.qrProfile),
          ),
        ],
      ),
      body: ListView(
        children: [
          // Profile Banner Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  isDark ? AppColors.darkSurface : AppColors.lightCardSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
              ),
            ),
            child: Row(
              children: [
                AvatarView(
                  photoUrl: profile?.photoUrl,
                  name: name,
                  size: 60,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '@$username',
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.primaryGreen),
                      ),
                      if (phone.isNotEmpty)
                        Text(
                          phone,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.textDarkSecondary
                                : AppColors.textLightSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined,
                      color: AppColors.primaryGreen),
                  onPressed: () => context.push(AppRoutes.editProfile),
                ),
              ],
            ),
          ),

          // Main Settings Options
          _buildSettingsTile(
            context,
            icon: Icons.account_circle_outlined,
            title: 'Account',
            subtitle: 'Phone number, username, bio',
            onTap: () => context.push(AppRoutes.accountSettings),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.lock_outline,
            title: 'Privacy',
            subtitle: 'Last seen, profile photo, blocked users',
            onTap: () => context.push(AppRoutes.privacySettings),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.security_outlined,
            title: 'Security',
            subtitle: 'App lock, two-step verification',
            onTap: () => context.push(AppRoutes.securitySettings),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.notifications_none_outlined,
            title: 'Notifications',
            subtitle: 'Messages, groups, channels, calls',
            onTap: () => context.push(AppRoutes.notificationsSettings),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.chat_bubble_outline,
            title: 'Chat Settings',
            subtitle: 'Wallpaper, text size, auto-download',
            onTap: () => context.push(AppRoutes.chatSettings),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.palette_outlined,
            title: 'Appearance',
            subtitle: 'Theme, dark mode, accent colors',
            onTap: () => context.push(AppRoutes.appearanceSettings),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.data_usage_outlined,
            title: 'Storage and Data',
            subtitle: 'Network usage, cache management',
            onTap: () => context.push(AppRoutes.storageSettings),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.devices_outlined,
            title: 'Devices',
            subtitle: 'Active sessions, desktop links',
            onTap: () => context.push(AppRoutes.devicesSettings),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.help_outline,
            title: 'Help',
            subtitle: 'FAQ, contact support, privacy policy',
            onTap: () => context.push(AppRoutes.help),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.info_outline,
            title: 'About Grevia',
            subtitle: 'v1.0.0 (Production Build)',
            onTap: () => context.push(AppRoutes.about),
          ),

          const Divider(),

          // Logout
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.errorRed),
            title: const Text('Log Out',
                style: TextStyle(
                    color: AppColors.errorRed, fontWeight: FontWeight.w600)),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Log Out'),
                  content:
                      const Text('Are you sure you want to log out of Grevia?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.errorRed),
                      onPressed: () async {
                        Navigator.pop(context);
                        await authRepo.signOut();
                        if (context.mounted) {
                          context.go(AppRoutes.welcome);
                        }
                      },
                      child: const Text('Log Out'),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryGreen),
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }
}
