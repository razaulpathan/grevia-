import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class StatusPrivacyScreen extends StatefulWidget {
  const StatusPrivacyScreen({super.key});

  @override
  State<StatusPrivacyScreen> createState() => _StatusPrivacyScreenState();
}

class _StatusPrivacyScreenState extends State<StatusPrivacyScreen> {
  String _privacy = 'contacts';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Status Privacy'),
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Who can see my status updates',
              style: TextStyle(
                  fontSize: 14,
                  color: AppColors.iconMuted,
                  fontWeight: FontWeight.bold),
            ),
          ),
          RadioListTile<String>(
            title: const Text('My Contacts'),
            subtitle: const Text('Share with all contacts saved in your phone'),
            value: 'contacts',
            groupValue: _privacy,
            onChanged: (val) => setState(() => _privacy = val!),
          ),
          RadioListTile<String>(
            title: const Text('My Contacts Except...'),
            subtitle: const Text('Hide your updates from specific contacts'),
            value: 'contacts_except',
            groupValue: _privacy,
            onChanged: (val) => setState(() => _privacy = val!),
          ),
          RadioListTile<String>(
            title: const Text('Only Share With...'),
            subtitle: const Text('Only selected contacts can view'),
            value: 'only_share',
            groupValue: _privacy,
            onChanged: (val) => setState(() => _privacy = val!),
          ),
        ],
      ),
    );
  }
}
