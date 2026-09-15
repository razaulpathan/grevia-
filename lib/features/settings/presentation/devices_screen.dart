import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/widgets/grevia_button.dart';

class DevicesScreen extends StatelessWidget {
  const DevicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Devices'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.laptop_chromebook,
                  size: 40, color: AppColors.primaryGreen),
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Link Grevia Web or Desktop',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 6),
          const Center(
            child: Text(
              'Use Grevia on multiple devices at once seamlessly.',
              style: TextStyle(color: AppColors.iconMuted, fontSize: 13),
            ),
          ),
          const SizedBox(height: 20),
          GreviaButton(
            text: 'Link a Device',
            icon: Icons.qr_code_scanner,
            onPressed: () => context.push(AppRoutes.qrScanner),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Current Device',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.iconMuted),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.phone_android,
                color: AppColors.primaryGreen, size: 28),
            title: const Text('This Device',
                style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: const Text('Grevia for Android • Online'),
            trailing: const Icon(Icons.check_circle,
                color: AppColors.primaryGreen, size: 18),
          ),
        ],
      ),
    );
  }
}
