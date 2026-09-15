import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/widgets/avatar_view.dart';
import '../../../core/widgets/grevia_button.dart';
import '../../../core/widgets/grevia_text_field.dart';
import '../../profile/domain/models/user_profile.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  final _bioController =
      TextEditingController(text: 'Hey there! I am using Grevia.');
  File? _imageFile;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  Future<void> _handleSave() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _errorMessage = 'Please enter your display name.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final uid = ref.read(currentUserIdProvider);
    if (uid == null) {
      context.go(AppRoutes.welcome);
      return;
    }

    final userRepo = ref.read(userRepositoryProvider);
    final storageService = ref.read(storageServiceProvider);

    try {
      String? photoUrl;
      if (_imageFile != null) {
        photoUrl = await storageService.uploadProfilePhoto(uid, _imageFile!);
      }

      final existingProfile = await userRepo.getUserProfile(uid);
      final profile = UserProfile(
        uid: uid,
        phoneNumber: existingProfile?.phoneNumber ?? '',
        phoneNumberNormalized: existingProfile?.phoneNumberNormalized ?? '',
        displayName: name,
        username: existingProfile?.username ?? '',
        usernameLowercase: (existingProfile?.username ?? '').toLowerCase(),
        photoUrl: photoUrl ?? existingProfile?.photoUrl,
        bio: _bioController.text.trim(),
        createdAt: existingProfile?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await userRepo.saveUserProfile(profile);

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (profile.username.isEmpty) {
        context.go(AppRoutes.usernameSetup);
      } else {
        context.go(AppRoutes.permissions);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Setup'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),
              // Profile Photo Picker
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    if (_imageFile != null)
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: FileImage(_imageFile!),
                      )
                    else
                      AvatarView(
                        name: _nameController.text.isNotEmpty
                            ? _nameController.text
                            : 'Grevia',
                        size: 100,
                      ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryGreen,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt,
                            size: 20, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              GreviaTextField(
                controller: _nameController,
                labelText: 'Display Name',
                hintText: 'e.g. Alice Walker',
                prefixIcon: const Icon(Icons.person_outline),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              GreviaTextField(
                controller: _bioController,
                labelText: 'Bio / Status',
                hintText: 'A short bio about you',
                prefixIcon: const Icon(Icons.info_outline),
                maxLines: 2,
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: AppColors.errorRed,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              const SizedBox(height: 40),
              GreviaButton(
                text: 'Next',
                isLoading: _isLoading,
                onPressed: _handleSave,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
