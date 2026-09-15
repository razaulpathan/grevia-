import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() =>
      _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState
    extends State<NotificationsSettingsScreen> {
  bool _messages = true;
  bool _groups = true;
  bool _channels = true;
  bool _previewText = true;
  bool _vibration = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Alerts & Previews',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.iconMuted),
            ),
          ),
          SwitchListTile(
            title: const Text('Private Messages'),
            subtitle:
                const Text('Play sound and show alert for new 1-to-1 messages'),
            value: _messages,
            onChanged: (val) => setState(() => _messages = val),
          ),
          SwitchListTile(
            title: const Text('Group Messages'),
            subtitle: const Text('Alerts for group chats'),
            value: _groups,
            onChanged: (val) => setState(() => _groups = val),
          ),
          SwitchListTile(
            title: const Text('Channel Broadcasts'),
            subtitle: const Text('Alerts for channel posts'),
            value: _channels,
            onChanged: (val) => setState(() => _channels = val),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Message Previews'),
            subtitle: const Text('Preview message text inside notifications'),
            value: _previewText,
            onChanged: (val) => setState(() => _previewText = val),
          ),
          SwitchListTile(
            title: const Text('Vibration'),
            value: _vibration,
            onChanged: (val) => setState(() => _vibration = val),
          ),
        ],
      ),
    );
  }
}
