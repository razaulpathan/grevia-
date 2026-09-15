import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/app_providers.dart';
import '../domain/models/group_model.dart';

class GroupPermissionsScreen extends ConsumerStatefulWidget {
  final String groupId;

  const GroupPermissionsScreen({super.key, required this.groupId});

  @override
  ConsumerState<GroupPermissionsScreen> createState() =>
      _GroupPermissionsScreenState();
}

class _GroupPermissionsScreenState
    extends ConsumerState<GroupPermissionsScreen> {
  bool _canSendMessages = true;
  bool _canSendMedia = true;
  bool _canAddMembers = true;
  bool _canChangeInfo = false;
  bool _canPinMessages = true;
  bool _canCreatePolls = true;

  @override
  Widget build(BuildContext context) {
    final groupRepo = ref.watch(groupRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Permissions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: AppColors.primaryGreen),
            onPressed: () {
              groupRepo.updatePermissions(
                widget.groupId,
                GroupPermissions(
                  canSendMessages: _canSendMessages,
                  canSendMedia: _canSendMedia,
                  canAddMembers: _canAddMembers,
                  canChangeInfo: _canChangeInfo,
                  canPinMessages: _canPinMessages,
                  canCreatePolls: _canCreatePolls,
                ),
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Permissions updated.')),
              );
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'What can members of this group do?',
              style: TextStyle(
                  fontSize: 14,
                  color: AppColors.iconMuted,
                  fontWeight: FontWeight.bold),
            ),
          ),
          SwitchListTile(
            title: const Text('Send Messages'),
            value: _canSendMessages,
            onChanged: (val) => setState(() => _canSendMessages = val),
          ),
          SwitchListTile(
            title: const Text('Send Media'),
            value: _canSendMedia,
            onChanged: (val) => setState(() => _canSendMedia = val),
          ),
          SwitchListTile(
            title: const Text('Add Other Members'),
            value: _canAddMembers,
            onChanged: (val) => setState(() => _canAddMembers = val),
          ),
          SwitchListTile(
            title: const Text('Pin Messages'),
            value: _canPinMessages,
            onChanged: (val) => setState(() => _canPinMessages = val),
          ),
          SwitchListTile(
            title: const Text('Create Polls'),
            value: _canCreatePolls,
            onChanged: (val) => setState(() => _canCreatePolls = val),
          ),
          SwitchListTile(
            title: const Text('Change Group Info'),
            subtitle: const Text('Name, icon, and description'),
            value: _canChangeInfo,
            onChanged: (val) => setState(() => _canChangeInfo = val),
          ),
        ],
      ),
    );
  }
}
