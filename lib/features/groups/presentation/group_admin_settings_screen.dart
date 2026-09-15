import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/avatar_view.dart';

class GroupAdminSettingsScreen extends ConsumerStatefulWidget {
  final String groupId;

  const GroupAdminSettingsScreen({super.key, required this.groupId});

  @override
  ConsumerState<GroupAdminSettingsScreen> createState() =>
      _GroupAdminSettingsScreenState();
}

class _GroupAdminSettingsScreenState
    extends ConsumerState<GroupAdminSettingsScreen> {
  bool _onlyAdminsCanPost = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administrators'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Admin-Only Messaging'),
            subtitle: const Text(
                'Only administrators can send messages to this group'),
            value: _onlyAdminsCanPost,
            onChanged: (val) => setState(() => _onlyAdminsCanPost = val),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Group Administrators',
              style: TextStyle(
                  fontSize: 14,
                  color: AppColors.iconMuted,
                  fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const AvatarView(name: 'You', size: 40),
            title: const Text('You',
                style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: const Text('Owner'),
          ),
        ],
      ),
    );
  }
}
