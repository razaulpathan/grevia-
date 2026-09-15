import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & FAQ'),
      ),
      body: ListView(
        children: [
          ExpansionTile(
            leading:
                const Icon(Icons.help_outline, color: AppColors.primaryGreen),
            title: const Text('What is Grevia?'),
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: Text(
                  'Grevia is a modern, privacy-focused social messaging application offering realtime 1-to-1 conversations, group chats, broadcast channels, communities, 24-hour stories, and HD WebRTC voice and video calls.',
                ),
              ),
            ],
          ),
          ExpansionTile(
            leading:
                const Icon(Icons.lock_outline, color: AppColors.primaryGreen),
            title: const Text('How is my privacy protected?'),
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: Text(
                  'All messaging traffic is secured with TLS transport security. You have full granular control over who sees your online presence, profile photo, and last seen timestamps.',
                ),
              ),
            ],
          ),
          ExpansionTile(
            leading: const Icon(Icons.qr_code, color: AppColors.primaryGreen),
            title: const Text('How do QR identities work?'),
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: Text(
                  'Every Grevia user gets a unique QR identity linked to their @username. You can share your QR code to connect with friends instantly without disclosing your phone number.',
                ),
              ),
            ],
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.contact_support_outlined,
                color: AppColors.primaryGreen),
            title: const Text('Contact Support'),
            subtitle: const Text('support@grevia.app'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Email support: support@grevia.app')),
              );
            },
          ),
        ],
      ),
    );
  }
}
