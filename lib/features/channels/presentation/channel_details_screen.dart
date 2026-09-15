import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/avatar_view.dart';

class ChannelDetailsScreen extends ConsumerWidget {
  final String channelId;
  final String? initialTitle;

  const ChannelDetailsScreen({
    super.key,
    required this.channelId,
    this.initialTitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final title = initialTitle ?? 'Channel Details';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Channel Info'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          Center(
            child: AvatarView(
              name: title,
              size: 96,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.textDarkPrimary
                    : AppColors.textLightPrimary,
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Center(
            child: Text(
              '1 subscriber',
              style: TextStyle(fontSize: 14, color: AppColors.primaryGreen),
            ),
          ),
          const SizedBox(height: 24),
          Divider(
              color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
          ListTile(
            leading: const Icon(Icons.link, color: AppColors.primaryGreen),
            title: const Text('Invite Link'),
            subtitle: Text('grevia.app/c/$channelId'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Channel invite link copied!')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications_outlined,
                color: AppColors.primaryGreen),
            title: const Text('Mute Notifications'),
            onTap: () {},
          ),
          Divider(
              color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: AppColors.errorRed),
            title: const Text('Leave Channel',
                style: TextStyle(color: AppColors.errorRed)),
            onTap: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
