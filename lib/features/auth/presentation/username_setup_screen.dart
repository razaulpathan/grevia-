import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/grevia_button.dart';
import '../../../core/widgets/grevia_text_field.dart';

class UsernameSetupScreen extends ConsumerStatefulWidget {
  const UsernameSetupScreen({super.key});

  @override
  ConsumerState<UsernameSetupScreen> createState() =>
      _UsernameSetupScreenState();
}

class _UsernameSetupScreenState extends ConsumerState<UsernameSetupScreen> {
  final _usernameController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _isAvailable = false;
  bool _isChecking = false;

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _checkAvailability(String val) async {
    final validationError = Validators.validateUsername(val);
    if (validationError != null) {
      setState(() {
        _errorMessage = validationError;
        _isAvailable = false;
      });
      return;
    }

    setState(() {
      _isChecking = true;
      _errorMessage = null;
    });

    final userRepo = ref.read(userRepositoryProvider);
    final available = await userRepo.isUsernameAvailable(val);

    if (!mounted) return;
    setState(() {
      _isChecking = false;
      _isAvailable = available;
      if (!available) {
        _errorMessage = 'Username @$val is already taken.';
      }
    });
  }

  Future<void> _handleClaimUsername() async {
    final raw = _usernameController.text.trim();
    final clean = raw.startsWith('@') ? raw.substring(1) : raw;

    final validationError = Validators.validateUsername(clean);
    if (validationError != null) {
      setState(() => _errorMessage = validationError);
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

    try {
      await userRepo.claimUsername(uid, clean);
      if (!mounted) return;
      setState(() => _isLoading = false);
      context.go(AppRoutes.permissions);
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Username'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You can choose a unique username on Grevia. People will be able to search and message you without knowing your phone number.',
                style: TextStyle(
                  fontSize: 15,
                  color: isDark
                      ? AppColors.textDarkSecondary
                      : AppColors.textLightSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),
              GreviaTextField(
                controller: _usernameController,
                labelText: 'Username',
                hintText: 'e.g. alice_walker',
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(left: 16, right: 8),
                  child: Center(
                    widthFactor: 0.0,
                    child: Text('@',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
                suffixIcon: _isChecking
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : _isAvailable
                        ? const Icon(Icons.check_circle,
                            color: AppColors.primaryGreen)
                        : null,
                onChanged: (val) {
                  _checkAvailability(val);
                },
              ),
              const SizedBox(height: 10),
              Text(
                'Requirements: 3-30 characters, letters, numbers, and underscores.',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.textDarkSecondary
                      : AppColors.textLightSecondary,
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: AppColors.errorRed,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              const Spacer(),
              GreviaButton(
                text: 'Complete Setup',
                isLoading: _isLoading,
                onPressed: _isAvailable ? _handleClaimUsername : null,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
