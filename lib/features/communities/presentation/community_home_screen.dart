import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/avatar_view.dart';

class CommunityHomeScreen extends ConsumerWidget {
  final String communityId;
  final String? initialTitle;

  const CommunityHomeScreen({
    super.key,
    required this.communityId,
    this.initialTitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = initialTitle ?? 'Community';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: ListView(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                AvatarView(name: title, size: 64),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Community of connected groups',
                        style:
                            TextStyle(fontSize: 13, color: AppColors.iconMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Linked Groups',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.iconMuted),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.campaign, color: AppColors.primaryGreen),
            title: const Text('Announcements',
                style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: const Text('Official updates for all members'),
            onTap: () {
              context.push('/group/announcements_$communityId',
                  extra: {'title': 'Announcements'});
            },
          ),
          ListTile(
            leading: const Icon(Icons.group, color: AppColors.primaryGreen),
            title: const Text('General Discussion',
                style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: const Text('Open chat for community members'),
            onTap: () {
              context.push('/group/general_$communityId',
                  extra: {'title': 'General Discussion'});
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.add, color: AppColors.primaryGreen),
            title: const Text('Add Existing Group'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Select a group to link to this community.')),
              );
            },
          ),
        ],
      ),
    );
  }
}
