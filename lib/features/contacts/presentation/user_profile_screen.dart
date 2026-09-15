import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/utils/id_generators.dart';
import '../../../core/widgets/avatar_view.dart';
import '../../calls/domain/models/call_session.dart';

class UserProfileScreen extends ConsumerWidget {
  final String userId;
  final Map<String, dynamic>? userData;

  const UserProfileScreen({
    super.key,
    required this.userId,
    this.userData,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final name = userData?['name'] as String? ?? 'Grevia User';
    final username = userData?['username'] as String? ?? userId;
    final bio = userData?['bio'] as String? ?? 'Available on Grevia';
    final photoUrl = userData?['photoUrl'] as String?;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Profile link copied: grevia.app/$username')),
              );
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          Center(
            child: AvatarView(
              photoUrl: photoUrl,
              name: name,
              size: 100,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              name,
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
              '@$username',
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Action Buttons: Chat, Call, Video
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildActionButton(
                icon: Icons.chat_bubble_outline,
                label: 'Message',
                onTap: () {
                  final myId = ref.read(currentUserIdProvider) ?? '';
                  final myProfile = ref.read(currentUserProfileProvider).value;
                  final chatRepo = ref.read(chatRepositoryProvider);

                  chatRepo
                      .createOrGetPrivateChat(
                    currentUserId: myId,
                    targetUserId: userId,
                    currentUserName: myProfile?.displayName ?? 'Grevia User',
                    targetUserName: name,
                    currentUserPhoto: myProfile?.photoUrl,
                    targetUserPhoto: photoUrl,
                  )
                      .then((chat) {
                    if (context.mounted) {
                      context.push(
                        '/chat/${chat.chatId}',
                        extra: {'title': name, 'avatar': photoUrl},
                      );
                    }
                  });
                },
              ),
              const SizedBox(width: 24),
              _buildActionButton(
                icon: Icons.call_outlined,
                label: 'Audio',
                onTap: () {
                  final callId = IdGenerators.generateCallId();
                  final myId = ref.read(currentUserIdProvider) ?? '';
                  ref.read(callRepositoryProvider).initiateCall(
                        CallSession(
                          callId: callId,
                          callerId: myId,
                          callerName: 'Me',
                          receiverId: userId,
                          receiverName: name,
                          receiverPhoto: photoUrl,
                          type: CallType.voice,
                          createdAt: DateTime.now(),
                        ),
                      );
                  context.push('/call/voice/$callId');
                },
              ),
              const SizedBox(width: 24),
              _buildActionButton(
                icon: Icons.videocam_outlined,
                label: 'Video',
                onTap: () {
                  final callId = IdGenerators.generateCallId();
                  final myId = ref.read(currentUserIdProvider) ?? '';
                  ref.read(callRepositoryProvider).initiateCall(
                        CallSession(
                          callId: callId,
                          callerId: myId,
                          callerName: 'Me',
                          receiverId: userId,
                          receiverName: name,
                          receiverPhoto: photoUrl,
                          type: CallType.video,
                          createdAt: DateTime.now(),
                        ),
                      );
                  context.push('/call/video/$callId');
                },
              ),
            ],
          ),
          const SizedBox(height: 28),
          Divider(
              color: isDark ? AppColors.darkDivider : AppColors.lightDivider),

          // User Bio
          ListTile(
            leading:
                const Icon(Icons.info_outline, color: AppColors.primaryGreen),
            title: const Text('Bio',
                style: TextStyle(fontSize: 13, color: AppColors.iconMuted)),
            subtitle: Text(bio, style: const TextStyle(fontSize: 15)),
          ),
          Divider(
              color: isDark ? AppColors.darkDivider : AppColors.lightDivider),

          // Block & Report
          ListTile(
            leading: const Icon(Icons.block, color: AppColors.errorRed),
            title: const Text('Block User',
                style: TextStyle(color: AppColors.errorRed)),
            onTap: () {
              final myId = ref.read(currentUserIdProvider) ?? '';
              ref.read(userRepositoryProvider).blockUser(myId, userId);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User has been blocked.')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primaryGreen, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
