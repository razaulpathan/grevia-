import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/widgets/grevia_button.dart';
import '../../../core/widgets/grevia_text_field.dart';

class CreateGroupScreen extends ConsumerStatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isPrivate = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateGroup() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a group name.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final uid = ref.read(currentUserIdProvider) ?? '';
    final groupRepo = ref.read(groupRepositoryProvider);

    try {
      final group = await groupRepo.createGroup(
        name: name,
        description: _descriptionController.text.trim(),
        ownerId: uid,
        initialMembers: [uid],
        isPrivate: _isPrivate,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      context.pushReplacement(
        '/group/${group.groupId}',
        extra: {'title': group.name},
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create group: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Group'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt,
                        color: AppColors.primaryGreen),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GreviaTextField(
                      controller: _nameController,
                      hintText: 'Group Name',
                      autofocus: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GreviaTextField(
                controller: _descriptionController,
                hintText: 'Description (optional)',
                maxLines: 2,
              ),
              const SizedBox(height: 20),
              SwitchListTile(
                title: const Text('Private Group'),
                subtitle: const Text(
                    'People can only join via invite link or approval'),
                value: _isPrivate,
                onChanged: (val) => setState(() => _isPrivate = val),
              ),
              const Spacer(),
              GreviaButton(
                text: 'Create Group',
                isLoading: _isLoading,
                onPressed: _handleCreateGroup,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
