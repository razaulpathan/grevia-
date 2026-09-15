import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  bool _twoStepVerification = false;
  bool _appLock = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            secondary:
                const Icon(Icons.password, color: AppColors.primaryGreen),
            title: const Text('Two-Step Verification'),
            subtitle: const Text(
                'Require an additional PIN when registering phone number'),
            value: _twoStepVerification,
            onChanged: (val) => setState(() => _twoStepVerification = val),
          ),
          const Divider(),
          SwitchListTile(
            secondary:
                const Icon(Icons.fingerprint, color: AppColors.primaryGreen),
            title: const Text('App Lock'),
            subtitle: const Text(
                'Unlock Grevia using fingerprint or device passcode'),
            value: _appLock,
            onChanged: (val) => setState(() => _appLock = val),
          ),
        ],
      ),
    );
  }
}
