import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/widgets/avatar_view.dart';
import '../domain/models/group_model.dart';

class GroupDetailsScreen extends ConsumerWidget {
  final String groupId;
  final String? initialTitle;

  const GroupDetailsScreen({
    super.key,
    required this.groupId,
    this.initialTitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final title = initialTitle ?? 'Group Details';
    final groupRepo = ref.watch(groupRepositoryProvider);
    final currentUserId = ref.watch(currentUserIdProvider) ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Info'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              context.push('/group/$groupId/invite');
            },
          ),
        ],
      ),
      body: FutureBuilder<GroupModel?>(
        future: groupRepo.getGroup(groupId),
        builder: (context, snapshot) {
          final group = snapshot.data;
          final isAdmin = group?.isAdmin(currentUserId) ?? false;

          return ListView(
            children: [
              const SizedBox(height: 20),
              Center(
                child: AvatarView(
                  photoUrl: group?.photoUrl,
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
                  '${group?.memberIds.length ?? 1} members',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? AppColors.textDarkSecondary
                        : AppColors.textLightSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Divider(
                  color:
                      isDark ? AppColors.darkDivider : AppColors.lightDivider),

              // Group Actions
              ListTile(
                leading: const Icon(Icons.person_add_outlined,
                    color: AppColors.primaryGreen),
                title: const Text('Add Members'),
                onTap: () => context.push('/group/$groupId/invite'),
              ),
              ListTile(
                leading: const Icon(Icons.link, color: AppColors.primaryGreen),
                title: const Text('Invite via Link / QR'),
                onTap: () => context.push('/group/$groupId/invite'),
              ),
              if (isAdmin) ...[
                ListTile(
                  leading: const Icon(Icons.security_outlined,
                      color: AppColors.primaryGreen),
                  title: const Text('Group Permissions'),
                  onTap: () => context.push('/group/$groupId/permissions'),
                ),
                ListTile(
                  leading: const Icon(Icons.admin_panel_settings_outlined,
                      color: AppColors.primaryGreen),
                  title: const Text('Admin Settings'),
                  onTap: () => context.push('/group/$groupId/admin'),
                ),
              ],
              Divider(
                  color:
                      isDark ? AppColors.darkDivider : AppColors.lightDivider),

              // Members List Section
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: Text(
                  'Members',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.textDarkSecondary
                        : AppColors.textLightSecondary,
                  ),
                ),
              ),
              ListTile(
                leading: const AvatarView(name: 'You', size: 40),
                title: const Text('You',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                trailing: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Admin',
                    style: TextStyle(
                        color: AppColors.primaryGreen,
                        fontSize: 11,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Divider(
                  color:
                      isDark ? AppColors.darkDivider : AppColors.lightDivider),

              // Exit Group
              ListTile(
                leading:
                    const Icon(Icons.exit_to_app, color: AppColors.errorRed),
                title: const Text('Exit Group',
                    style: TextStyle(color: AppColors.errorRed)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
