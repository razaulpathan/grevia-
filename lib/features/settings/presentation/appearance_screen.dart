import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/app_providers.dart';

class AppearanceScreen extends ConsumerWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appearance'),
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Theme Preference',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.iconMuted),
            ),
          ),
          RadioListTile<ThemeMode>(
            title: const Text('System Default'),
            subtitle: const Text('Matches your device operating system theme'),
            value: ThemeMode.system,
            groupValue: currentTheme,
            activeColor: AppColors.primaryGreen,
            onChanged: (mode) {
              if (mode != null) themeNotifier.setTheme(mode);
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Light Mode'),
            subtitle:
                const Text('Clean white surfaces with Grevia primary green'),
            value: ThemeMode.light,
            groupValue: currentTheme,
            activeColor: AppColors.primaryGreen,
            onChanged: (mode) {
              if (mode != null) themeNotifier.setTheme(mode);
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Dark Mode'),
            subtitle: const Text(
                'Deep dark surfaces intentionally designed for OLED & low light'),
            value: ThemeMode.dark,
            groupValue: currentTheme,
            activeColor: AppColors.primaryGreen,
            onChanged: (mode) {
              if (mode != null) themeNotifier.setTheme(mode);
            },
          ),
        ],
      ),
    );
  }
}
