import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/avatar_view.dart';
import '../domain/models/status_model.dart';

class UpdatesScreen extends ConsumerWidget {
  const UpdatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final myProfile = ref.watch(currentUserProfileProvider).value;
    final statusRepo = ref.watch(statusRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Updates'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push(AppRoutes.globalSearch),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (val) {
              if (val == 'privacy') {
                context.push(AppRoutes.statusPrivacy);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'privacy',
                child: Text('Status Privacy'),
              ),
            ],
          ),
        ],
      ),
      body: StreamBuilder<List<StatusModel>>(
        stream: statusRepo.getStatusesStream(),
        builder: (context, snapshot) {
          final statuses = snapshot.data ?? [];
          final activeStatuses = statuses.where((s) => !s.isExpired).toList();

          return ListView(
            children: [
              // My Status Header
              ListTile(
                leading: Stack(
                  children: [
                    AvatarView(
                      photoUrl: myProfile?.photoUrl,
                      name: myProfile?.displayName ?? 'Me',
                      size: 52,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            width: 2,
                          ),
                        ),
                        child: const Icon(Icons.add,
                            size: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                title: const Text('My Status',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Tap to add status update'),
                onTap: () => context.push(AppRoutes.statusComposer),
              ),

              const Divider(),

              // Recent Updates Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: Text(
                  'Recent Updates',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.textDarkSecondary
                        : AppColors.textLightSecondary,
                  ),
                ),
              ),

              if (activeStatuses.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Center(
                    child: Text(
                      'No recent updates from contacts.\nTap above to share your first story!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isDark
                            ? AppColors.textDarkSecondary
                            : AppColors.textLightSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                )
              else
                ...activeStatuses.map((st) {
                  return ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(2.5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.primaryGreen, width: 2.5),
                      ),
                      child: AvatarView(
                        photoUrl: st.userPhoto,
                        name: st.userName,
                        size: 46,
                      ),
                    ),
                    title: Text(st.userName,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(Formatters.formatChatListTime(st.createdAt)),
                    onTap: () {
                      context.push(
                        AppRoutes.statusViewer,
                        extra: st,
                      );
                    },
                  );
                }),

              const Divider(),

              // Channels Section
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Channels',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.textDarkSecondary
                            : AppColors.textLightSecondary,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push(AppRoutes.createChannel),
                      child: const Text('Create Channel'),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const AvatarView(name: 'Grevia News', size: 44),
                title: const Text('Grevia Official',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle:
                    const Text('Welcome to Grevia! Discover features & tips.'),
                trailing: const Icon(Icons.verified,
                    color: AppColors.primaryGreen, size: 18),
                onTap: () {
                  context.push('/channel/grevia_official',
                      extra: {'title': 'Grevia Official'});
                },
              ),
            ],
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'text_status',
            onPressed: () => context.push(AppRoutes.statusComposer),
            backgroundColor: isDark
                ? AppColors.darkSecondarySurface
                : const Color(0xFFE2ECE6),
            foregroundColor: AppColors.primaryGreen,
            child: const Icon(Icons.edit),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'photo_status',
            onPressed: () => context.push(AppRoutes.statusComposer),
            child: const Icon(Icons.camera_alt),
          ),
        ],
      ),
    );
  }
}
