import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/avatar_view.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/skeleton_loader.dart';
import '../domain/models/chat.dart';

class ChatsScreen extends ConsumerWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUserId = ref.watch(currentUserIdProvider) ?? '';
    final chatRepo = ref.watch(chatRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Grevia'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search',
            onPressed: () => context.push(AppRoutes.globalSearch),
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'My QR',
            onPressed: () => context.push(AppRoutes.qrProfile),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'new_group':
                  context.push(AppRoutes.createGroup);
                  break;
                case 'new_channel':
                  context.push(AppRoutes.createChannel);
                  break;
                case 'new_community':
                  context.push(AppRoutes.createCommunity);
                  break;
                case 'archived':
                  context.push(AppRoutes.archivedChats);
                  break;
                case 'saved':
                  context.push(
                    '/chat/${currentUserId}_$currentUserId',
                    extra: {'title': 'Saved Messages', 'isSaved': true},
                  );
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'new_group',
                child: Row(
                  children: [
                    Icon(Icons.group_add_outlined, size: 20),
                    SizedBox(width: 12),
                    Text('New Group'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'new_channel',
                child: Row(
                  children: [
                    Icon(Icons.campaign_outlined, size: 20),
                    SizedBox(width: 12),
                    Text('New Channel'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'new_community',
                child: Row(
                  children: [
                    Icon(Icons.hub_outlined, size: 20),
                    SizedBox(width: 12),
                    Text('New Community'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'archived',
                child: Row(
                  children: [
                    Icon(Icons.archive_outlined, size: 20),
                    SizedBox(width: 12),
                    Text('Archived Chats'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'saved',
                child: Row(
                  children: [
                    Icon(Icons.bookmark_outline, size: 20),
                    SizedBox(width: 12),
                    Text('Saved Messages'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: StreamBuilder<List<Chat>>(
        stream: chatRepo.getChatsStream(currentUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const ChatListSkeleton();
          }

          final allChats = snapshot.data ?? [];
          final activeChats =
              allChats.where((c) => !c.isArchivedBy(currentUserId)).toList();

          if (activeChats.isEmpty) {
            return EmptyStateView(
              icon: Icons.chat_outlined,
              title: 'No conversations yet',
              description:
                  'Start messaging your friends or create a new group to get started.',
              actionText: 'Start a Chat',
              onActionPressed: () => context.push(AppRoutes.newChat),
            );
          }

          // Sort: Pinned chats first, then by lastMessageTime descending
          activeChats.sort((a, b) {
            final aPinned = a.isPinnedBy(currentUserId);
            final bPinned = b.isPinnedBy(currentUserId);
            if (aPinned && !bPinned) return -1;
            if (!aPinned && bPinned) return 1;
            final aTime =
                a.lastMessageTime ?? DateTime.fromMillisecondsSinceEpoch(0);
            final bTime =
                b.lastMessageTime ?? DateTime.fromMillisecondsSinceEpoch(0);
            return bTime.compareTo(aTime);
          });

          return ListView.separated(
            itemCount: activeChats.length,
            separatorBuilder: (_, __) => Divider(
              indent: 78,
              endIndent: 16,
              color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
            ),
            itemBuilder: (context, index) {
              final chat = activeChats[index];
              final isPinned = chat.isPinnedBy(currentUserId);
              final isMuted = chat.isMutedBy(currentUserId);
              final unreadCount = chat.getUnreadCount(currentUserId);
              final title = chat.getChatTitle(currentUserId);
              final avatarUrl = chat.getChatAvatar(currentUserId);

              return ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: AvatarView(
                  photoUrl: avatarUrl,
                  name: title,
                  size: 52,
                  showOnlineIndicator: chat.type == ChatType.private,
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: unreadCount > 0
                              ? FontWeight.w700
                              : FontWeight.w600,
                          color: isDark
                              ? AppColors.textDarkPrimary
                              : AppColors.textLightPrimary,
                        ),
                      ),
                    ),
                    if (chat.lastMessageTime != null)
                      Text(
                        Formatters.formatChatListTime(chat.lastMessageTime),
                        style: TextStyle(
                          fontSize: 12,
                          color: unreadCount > 0
                              ? AppColors.primaryGreen
                              : (isDark
                                  ? AppColors.textDarkSecondary
                                  : AppColors.textLightSecondary),
                          fontWeight: unreadCount > 0
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat.lastMessageText.isNotEmpty
                              ? chat.lastMessageText
                              : 'No messages yet',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? AppColors.textDarkSecondary
                                : AppColors.textLightSecondary,
                            fontWeight: unreadCount > 0
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (isMuted)
                        const Padding(
                          padding: EdgeInsets.only(left: 6.0),
                          child: Icon(Icons.volume_off,
                              size: 16, color: AppColors.iconMuted),
                        ),
                      if (isPinned)
                        const Padding(
                          padding: EdgeInsets.only(left: 6.0),
                          child: Icon(Icons.push_pin,
                              size: 16, color: AppColors.iconMuted),
                        ),
                      if (unreadCount > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$unreadCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                onTap: () {
                  context.push(
                    '/chat/${chat.chatId}',
                    extra: {
                      'title': title,
                      'avatar': avatarUrl,
                      'type': chat.type.name,
                    },
                  );
                },
                onLongPress: () {
                  _showChatOptionsSheet(context, ref, chat, currentUserId);
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.newChat),
        child: const Icon(Icons.edit_outlined),
      ),
    );
  }

  void _showChatOptionsSheet(
    BuildContext context,
    WidgetRef ref,
    Chat chat,
    String currentUserId,
  ) {
    final chatRepo = ref.read(chatRepositoryProvider);
    final isPinned = chat.isPinnedBy(currentUserId);
    final isMuted = chat.isMutedBy(currentUserId);

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
              ListTile(
                leading:
                    Icon(isPinned ? Icons.push_pin_outlined : Icons.push_pin),
                title: Text(isPinned ? 'Unpin Chat' : 'Pin to Top'),
                onTap: () {
                  chatRepo.togglePinChat(chat.chatId, currentUserId, !isPinned);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(isMuted
                    ? Icons.volume_up_outlined
                    : Icons.volume_off_outlined),
                title: Text(
                    isMuted ? 'Unmute Notifications' : 'Mute Notifications'),
                onTap: () {
                  chatRepo.toggleMuteChat(chat.chatId, currentUserId, !isMuted);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.archive_outlined),
                title: const Text('Archive Chat'),
                onTap: () {
                  chatRepo.toggleArchiveChat(chat.chatId, currentUserId, true);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.mark_chat_read_outlined),
                title: const Text('Mark as Read'),
                onTap: () {
                  chatRepo.markAsRead(chat.chatId, currentUserId);
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
