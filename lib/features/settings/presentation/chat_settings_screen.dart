import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class ChatSettingsScreen extends StatefulWidget {
  const ChatSettingsScreen({super.key});

  @override
  State<ChatSettingsScreen> createState() => _ChatSettingsScreenState();
}

class _ChatSettingsScreenState extends State<ChatSettingsScreen> {
  double _fontSize = 15.0;
  bool _autoDownloadWifi = true;
  bool _autoDownloadCellular = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Settings'),
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Message Text Size',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.iconMuted),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const Text('A', style: TextStyle(fontSize: 12)),
                Expanded(
                  child: Slider(
                    value: _fontSize,
                    min: 12.0,
                    max: 20.0,
                    divisions: 8,
                    activeColor: AppColors.primaryGreen,
                    onChanged: (val) => setState(() => _fontSize = val),
                  ),
                ),
                const Text('A',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Auto-Download Media',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.iconMuted),
            ),
          ),
          SwitchListTile(
            title: const Text('When connected on Wi-Fi'),
            subtitle: const Text('Photos, Audio, Videos, Documents'),
            value: _autoDownloadWifi,
            onChanged: (val) => setState(() => _autoDownloadWifi = val),
          ),
          SwitchListTile(
            title: const Text('When using Mobile Data'),
            subtitle: const Text('Photos only'),
            value: _autoDownloadCellular,
            onChanged: (val) => setState(() => _autoDownloadCellular = val),
          ),
        ],
      ),
    );
  }
}
