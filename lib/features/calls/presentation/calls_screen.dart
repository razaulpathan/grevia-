import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/avatar_view.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../domain/models/call_session.dart';

class CallsScreen extends ConsumerWidget {
  const CallsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUserId = ref.watch(currentUserIdProvider) ?? '';
    final callRepo = ref.watch(callRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calls'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push(AppRoutes.globalSearch),
          ),
        ],
      ),
      body: StreamBuilder<List<CallSession>>(
        stream: callRepo.getCallHistoryStream(currentUserId),
        builder: (context, snapshot) {
          final calls = snapshot.data ?? [];

          if (calls.isEmpty) {
            return EmptyStateView(
              icon: Icons.phone_outlined,
              title: 'No recent calls',
              description:
                  'Stay connected with high-quality voice and video calls powered by WebRTC.',
              actionText: 'Start a Call',
              onActionPressed: () => context.push(AppRoutes.contacts),
            );
          }

          return ListView.separated(
            itemCount: calls.length,
            separatorBuilder: (_, __) => Divider(
              indent: 78,
              endIndent: 16,
              color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
            ),
            itemBuilder: (context, index) {
              final call = calls[index];
              final isIncoming = call.isIncoming(currentUserId);
              final isMissed = call.status == CallStatus.missed;
              final otherName =
                  isIncoming ? call.callerName : call.receiverName;
              final otherPhoto =
                  isIncoming ? call.callerPhoto : call.receiverPhoto;

              return ListTile(
                leading: AvatarView(
                  photoUrl: otherPhoto,
                  name: otherName,
                  size: 50,
                ),
                title: Text(
                  otherName,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isMissed ? AppColors.errorRed : null,
                  ),
                ),
                subtitle: Row(
                  children: [
                    Icon(
                      isIncoming
                          ? (isMissed ? Icons.call_missed : Icons.call_received)
                          : Icons.call_made,
                      size: 15,
                      color: isMissed
                          ? AppColors.errorRed
                          : AppColors.primaryGreen,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      Formatters.formatChatListTime(call.createdAt),
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppColors.textDarkSecondary
                            : AppColors.textLightSecondary,
                      ),
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: Icon(
                    call.type == CallType.video
                        ? Icons.videocam_outlined
                        : Icons.call_outlined,
                    color: AppColors.primaryGreen,
                  ),
                  onPressed: () {
                    if (call.type == CallType.video) {
                      context.push('/call/video/${call.callId}');
                    } else {
                      context.push('/call/voice/${call.callId}');
                    }
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.contacts),
        child: const Icon(Icons.add_call),
      ),
    );
  }
}
