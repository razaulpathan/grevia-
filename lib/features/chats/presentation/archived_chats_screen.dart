import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/avatar_view.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/skeleton_loader.dart';
import '../domain/models/chat.dart';

class ArchivedChatsScreen extends ConsumerWidget {
  const ArchivedChatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUserId = ref.watch(currentUserIdProvider) ?? '';
    final chatRepo = ref.watch(chatRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Archived Chats'),
      ),
      body: StreamBuilder<List<Chat>>(
        stream: chatRepo.getChatsStream(currentUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const ChatListSkeleton();
          }

          final allChats = snapshot.data ?? [];
          final archived =
              allChats.where((c) => c.isArchivedBy(currentUserId)).toList();

          if (archived.isEmpty) {
            return const EmptyStateView(
              icon: Icons.archive_outlined,
              title: 'No archived chats',
              description:
                  'Chats you archive will be kept organized and muted here.',
            );
          }

          return ListView.separated(
            itemCount: archived.length,
            separatorBuilder: (_, __) => Divider(
              indent: 78,
              endIndent: 16,
              color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
            ),
            itemBuilder: (context, index) {
              final chat = archived[index];
              final title = chat.getChatTitle(currentUserId);
              final avatar = chat.getChatAvatar(currentUserId);

              return ListTile(
                leading: AvatarView(photoUrl: avatar, name: title, size: 50),
                title: Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(
                  chat.lastMessageText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(
                  Formatters.formatChatListTime(chat.lastMessageTime),
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.textDarkSecondary
                        : AppColors.textLightSecondary,
                  ),
                ),
                onTap: () {
                  context.push(
                    '/chat/${chat.chatId}',
                    extra: {'title': title, 'avatar': avatar},
                  );
                },
                onLongPress: () {
                  chatRepo.toggleArchiveChat(chat.chatId, currentUserId, false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Chat unarchived.')),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
