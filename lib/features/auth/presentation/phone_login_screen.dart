import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/grevia_button.dart';
import '../../../core/widgets/grevia_text_field.dart';

class PhoneLoginScreen extends ConsumerStatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  ConsumerState<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends ConsumerState<PhoneLoginScreen> {
  final _phoneController = TextEditingController();
  String _selectedCountryId = 'US';
  bool _isLoading = false;
  String? _errorMessage;

  final List<Map<String, String>> _countries = [
    {'id': 'US', 'name': 'United States', 'code': '+1', 'flag': '🇺🇸'},
    {'id': 'GB', 'name': 'United Kingdom', 'code': '+44', 'flag': '🇬🇧'},
    {'id': 'IN', 'name': 'India', 'code': '+91', 'flag': '🇮🇳'},
    {'id': 'PK', 'name': 'Pakistan', 'code': '+92', 'flag': '🇵🇰'},
    {'id': 'CA', 'name': 'Canada', 'code': '+1', 'flag': '🇨🇦'},
    {'id': 'DE', 'name': 'Germany', 'code': '+49', 'flag': '🇩🇪'},
    {'id': 'AU', 'name': 'Australia', 'code': '+61', 'flag': '🇦🇺'},
    {'id': 'AE', 'name': 'United Arab Emirates', 'code': '+971', 'flag': '🇦🇪'},
  ];

  String get _selectedCountryCode {
    return _countries.firstWhere(
      (c) => c['id'] == _selectedCountryId,
      orElse: () => _countries.first,
    )['code']!;
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSendCode() async {
    final rawNumber = _phoneController.text.trim();
    final validationError = Validators.validatePhoneNumber(rawNumber);
    if (validationError != null) {
      setState(() => _errorMessage = validationError);
      return;
    }

    final normalized = Formatters.normalizePhoneNumber(
      rawNumber,
      defaultCountryCode: _selectedCountryCode,
    );

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authRepo = ref.read(authRepositoryProvider);

    await authRepo.verifyPhoneNumber(
      phoneNumber: normalized,
      onCodeSent: (verificationId) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        context.push(
          AppRoutes.otp,
          extra: {
            'phoneNumber': normalized,
            'verificationId': verificationId,
          },
        );
      },
      onVerificationFailed: (exception) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _errorMessage = exception.message;
        });
      },
      onAutoVerified: (smsCode) {
        if (!mounted) return;
        // Handled directly if Android automatically resolves SMS
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Phone Number'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Please confirm your country code and enter your phone number to receive a verification SMS.',
                style: TextStyle(
                  fontSize: 15,
                  color: isDark
                      ? AppColors.textDarkSecondary
                      : AppColors.textLightSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),
              // Country Picker Dropdown
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurface
                      : AppColors.lightCardSurface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color:
                        isDark ? AppColors.darkDivider : AppColors.lightDivider,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedCountryId,
                    dropdownColor: isDark
                        ? AppColors.darkSurface
                        : AppColors.lightCardSurface,
                    items: _countries.map((c) {
                      return DropdownMenuItem<String>(
                        value: c['id'],
                        child: Text(
                          '${c['flag']}  ${c['name']} (${c['code']})',
                          style: TextStyle(
                            fontSize: 15,
                            color: isDark
                                ? AppColors.textDarkPrimary
                                : AppColors.textLightPrimary,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedCountryId = val);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Phone Input
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 52,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkSurface
                          : AppColors.lightCardSurface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark
                            ? AppColors.darkDivider
                            : AppColors.lightDivider,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _selectedCountryCode,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.textDarkPrimary
                            : AppColors.textLightPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GreviaTextField(
                      controller: _phoneController,
                      hintText: 'Phone number',
                      keyboardType: TextInputType.phone,
                      autofocus: true,
                      onChanged: (_) {
                        if (_errorMessage != null) {
                          setState(() => _errorMessage = null);
                        }
                      },
                    ),
                  ),
                ],
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
                text: 'Continue',
                isLoading: _isLoading,
                onPressed: _handleSendCode,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
