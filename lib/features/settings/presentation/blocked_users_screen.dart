import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/widgets/empty_state_view.dart';

class BlockedUsersScreen extends ConsumerWidget {
  const BlockedUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentUserProfileProvider).value;
    final blocked = profile?.privacySettings.blockedUsers ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Blocked Users'),
      ),
      body: blocked.isEmpty
          ? const EmptyStateView(
              icon: Icons.block,
              title: 'No blocked users',
              description:
                  'Blocked contacts will no longer be able to call you or send you messages.',
            )
          : ListView.builder(
              itemCount: blocked.length,
              itemBuilder: (context, index) {
                final userId = blocked[index];
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text('User $userId'),
                  trailing: TextButton(
                    onPressed: () {
                      final myId = ref.read(currentUserIdProvider) ?? '';
                      ref
                          .read(userRepositoryProvider)
                          .unblockUser(myId, userId);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('User unblocked.')),
                      );
                    },
                    child: const Text('Unblock',
                        style: TextStyle(color: AppColors.errorRed)),
                  ),
                );
              },
            ),
    );
  }
}
