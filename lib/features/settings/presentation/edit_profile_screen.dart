import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/widgets/avatar_view.dart';
import '../../../core/widgets/grevia_button.dart';
import '../../../core/widgets/grevia_text_field.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(currentUserProfileProvider).value;
    _nameController = TextEditingController(text: profile?.displayName ?? '');
    _bioController = TextEditingController(text: profile?.bio ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _isLoading = true);
    final userRepo = ref.read(userRepositoryProvider);
    final profile = ref.read(currentUserProfileProvider).value;

    if (profile != null) {
      final updated = profile.copyWith(
        displayName: name,
        bio: _bioController.text.trim(),
        updatedAt: DateTime.now(),
      );
      await userRepo.saveUserProfile(updated);
    }

    if (!mounted) return;
    setState(() => _isLoading = false);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(currentUserProfileProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        children: [
          Center(
            child: Stack(
              children: [
                AvatarView(
                  photoUrl: profile?.photoUrl,
                  name: profile?.displayName ?? 'Grevia',
                  size: 90,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt,
                        color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          GreviaTextField(
            controller: _nameController,
            labelText: 'Display Name',
          ),
          const SizedBox(height: 16),
          GreviaTextField(
            controller: _bioController,
            labelText: 'Bio',
            maxLines: 3,
          ),
          const SizedBox(height: 32),
          GreviaButton(
            text: 'Save Changes',
            isLoading: _isLoading,
            onPressed: _saveChanges,
          ),
        ],
      ),
    );
  }
}
