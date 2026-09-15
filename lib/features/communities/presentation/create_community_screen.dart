import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/widgets/grevia_button.dart';
import '../../../core/widgets/grevia_text_field.dart';

class CreateCommunityScreen extends ConsumerStatefulWidget {
  const CreateCommunityScreen({super.key});

  @override
  ConsumerState<CreateCommunityScreen> createState() =>
      _CreateCommunityScreenState();
}

class _CreateCommunityScreenState extends ConsumerState<CreateCommunityScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a community name.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final uid = ref.read(currentUserIdProvider) ?? '';
    final commRepo = ref.read(communityRepositoryProvider);

    try {
      final community = await commRepo.createCommunity(
        name: name,
        description: _descriptionController.text.trim(),
        ownerId: uid,
        linkedGroupIds: [],
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      context.pushReplacement(
        '/community/${community.communityId}',
        extra: {'title': community.name},
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create community: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Community'),
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
                    child: const Icon(Icons.hub_outlined,
                        color: AppColors.primaryGreen),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GreviaTextField(
                      controller: _nameController,
                      hintText: 'Community Name',
                      autofocus: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GreviaTextField(
                controller: _descriptionController,
                hintText: 'Description of your community and its topic...',
                maxLines: 3,
              ),
              const Spacer(),
              GreviaButton(
                text: 'Create Community',
                isLoading: _isLoading,
                onPressed: _handleCreate,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
