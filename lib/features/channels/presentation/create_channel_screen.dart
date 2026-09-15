import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/widgets/grevia_button.dart';
import '../../../core/widgets/grevia_text_field.dart';

class CreateChannelScreen extends ConsumerStatefulWidget {
  const CreateChannelScreen({super.key});

  @override
  ConsumerState<CreateChannelScreen> createState() =>
      _CreateChannelScreenState();
}

class _CreateChannelScreenState extends ConsumerState<CreateChannelScreen> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isPrivate = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateChannel() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a channel name.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final uid = ref.read(currentUserIdProvider) ?? '';
    final channelRepo = ref.read(channelRepositoryProvider);

    try {
      final channel = await channelRepo.createChannel(
        name: name,
        username: _usernameController.text.trim(),
        description: _descriptionController.text.trim(),
        ownerId: uid,
        isPrivate: _isPrivate,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      context.pushReplacement(
        '/channel/${channel.channelId}',
        extra: {'title': channel.name},
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create channel: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Channel'),
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
                    child: const Icon(Icons.campaign,
                        color: AppColors.primaryGreen),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GreviaTextField(
                      controller: _nameController,
                      hintText: 'Channel Name',
                      autofocus: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GreviaTextField(
                controller: _usernameController,
                hintText: 'channel_username',
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(left: 14, right: 6),
                  child: Center(widthFactor: 0, child: Text('@')),
                ),
              ),
              const SizedBox(height: 16),
              GreviaTextField(
                controller: _descriptionController,
                hintText: 'Description (optional)',
                maxLines: 2,
              ),
              const SizedBox(height: 20),
              SwitchListTile(
                title: const Text('Private Channel'),
                subtitle: const Text('Can only be joined via invite link'),
                value: _isPrivate,
                onChanged: (val) => setState(() => _isPrivate = val),
              ),
              const Spacer(),
              GreviaButton(
                text: 'Create Channel',
                isLoading: _isLoading,
                onPressed: _handleCreateChannel,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
