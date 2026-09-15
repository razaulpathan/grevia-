import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/avatar_view.dart';

class ChatDetailsScreen extends ConsumerStatefulWidget {
  final String chatId;
  final String? initialTitle;
  final String? initialAvatar;

  const ChatDetailsScreen({
    super.key,
    required this.chatId,
    this.initialTitle,
    this.initialAvatar,
  });

  @override
  ConsumerState<ChatDetailsScreen> createState() => _ChatDetailsScreenState();
}

class _ChatDetailsScreenState extends ConsumerState<ChatDetailsScreen> {
  bool _isMuted = false;
  int _disappearingDuration = 0; // 0 = Off

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final title = widget.initialTitle ?? 'Chat Details';
    final avatar = widget.initialAvatar;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Info'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          Center(
            child: AvatarView(
              photoUrl: avatar,
              name: title,
              size: 96,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.textDarkPrimary
                    : AppColors.textLightPrimary,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              'online',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Divider(
              color: isDark ? AppColors.darkDivider : AppColors.lightDivider),

          // Shared Media Section
          ListTile(
            leading: const Icon(Icons.perm_media_outlined,
                color: AppColors.primaryGreen),
            title: const Text('Media, Links, and Docs'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.push('/chat/${widget.chatId}/media');
            },
          ),
          Divider(
              color: isDark ? AppColors.darkDivider : AppColors.lightDivider),

          // Notification Settings
          SwitchListTile(
            secondary: const Icon(Icons.notifications_outlined,
                color: AppColors.primaryGreen),
            title: const Text('Mute Notifications'),
            value: _isMuted,
            onChanged: (val) {
              setState(() => _isMuted = val);
            },
          ),

          // Disappearing Messages
          ListTile(
            leading:
                const Icon(Icons.timer_outlined, color: AppColors.primaryGreen),
            title: const Text('Disappearing Messages'),
            subtitle: Text(_disappearingDuration == 0
                ? 'Off'
                : '$_disappearingDuration seconds'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showDisappearingMessagesSheet();
            },
          ),

          Divider(
              color: isDark ? AppColors.darkDivider : AppColors.lightDivider),

          // Block & Report
          ListTile(
            leading: const Icon(Icons.block, color: AppColors.errorRed),
            title: const Text('Block User',
                style: TextStyle(color: AppColors.errorRed)),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User has been blocked.')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.report_problem_outlined,
                color: AppColors.errorRed),
            title: const Text('Report User',
                style: TextStyle(color: AppColors.errorRed)),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Report submitted for review.')),
              );
            },
          ),
          ListTile(
            leading:
                const Icon(Icons.delete_outline, color: AppColors.errorRed),
            title: const Text('Delete Chat',
                style: TextStyle(color: AppColors.errorRed)),
            onTap: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showDisappearingMessagesSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Disappearing Messages',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                title: const Text('Off'),
                trailing: _disappearingDuration == 0
                    ? const Icon(Icons.check, color: AppColors.primaryGreen)
                    : null,
                onTap: () {
                  setState(() => _disappearingDuration = 0);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('24 Hours'),
                trailing: _disappearingDuration == 86400
                    ? const Icon(Icons.check, color: AppColors.primaryGreen)
                    : null,
                onTap: () {
                  setState(() => _disappearingDuration = 86400);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('7 Days'),
                trailing: _disappearingDuration == 604800
                    ? const Icon(Icons.check, color: AppColors.primaryGreen)
                    : null,
                onTap: () {
                  setState(() => _disappearingDuration = 604800);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
