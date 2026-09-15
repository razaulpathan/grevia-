import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routing/app_routes.dart';

class PrivacySettingsScreen extends ConsumerStatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  ConsumerState<PrivacySettingsScreen> createState() =>
      _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends ConsumerState<PrivacySettingsScreen> {
  bool _readReceipts = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy'),
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Who can see my personal info',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.iconMuted),
            ),
          ),
          ListTile(
            title: const Text('Last Seen & Online'),
            trailing: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Everyone', style: TextStyle(color: AppColors.iconMuted)),
                Icon(Icons.chevron_right, size: 20),
              ],
            ),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Profile Photo'),
            trailing: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Everyone', style: TextStyle(color: AppColors.iconMuted)),
                Icon(Icons.chevron_right, size: 20),
              ],
            ),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Phone Number'),
            trailing: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('My Contacts',
                    style: TextStyle(color: AppColors.iconMuted)),
                Icon(Icons.chevron_right, size: 20),
              ],
            ),
            onTap: () {},
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Read Receipts'),
            subtitle: const Text(
                'If turned off, you won\'t see or send read receipts'),
            value: _readReceipts,
            onChanged: (val) => setState(() => _readReceipts = val),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.block, color: AppColors.primaryGreen),
            title: const Text('Blocked Users'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoutes.blockedUsers),
          ),
        ],
      ),
    );
  }
}
