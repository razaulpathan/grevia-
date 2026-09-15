import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/widgets/avatar_view.dart';
import '../../profile/domain/models/user_profile.dart';

class NewChatScreen extends ConsumerStatefulWidget {
  const NewChatScreen({super.key});

  @override
  ConsumerState<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends ConsumerState<NewChatScreen> {
  final _searchController = TextEditingController();
  List<UserProfile> _searchResults = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    final userRepo = ref.read(userRepositoryProvider);
    final results = await userRepo.searchUsers(query);

    if (!mounted) return;
    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  Future<void> _startChatWithUser(UserProfile targetUser) async {
    final currentUserId = ref.read(currentUserIdProvider) ?? '';
    final myProfile = ref.read(currentUserProfileProvider).value;
    final chatRepo = ref.read(chatRepositoryProvider);

    final chat = await chatRepo.createOrGetPrivateChat(
      currentUserId: currentUserId,
      targetUserId: targetUser.uid,
      currentUserName: myProfile?.displayName ?? 'Grevia User',
      targetUserName: targetUser.displayName,
      currentUserPhoto: myProfile?.photoUrl,
      targetUserPhoto: targetUser.photoUrl,
    );

    if (!mounted) return;
    context.pushReplacement(
      '/chat/${chat.chatId}',
      extra: {
        'title': targetUser.displayName,
        'avatar': targetUser.photoUrl,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Message'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search people by username or name...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _isSearching
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : null,
              ),
              onChanged: _performSearch,
            ),
          ),
          Expanded(
            child: _searchResults.isNotEmpty
                ? ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final user = _searchResults[index];
                      return ListTile(
                        leading: AvatarView(
                          photoUrl: user.photoUrl,
                          name: user.displayName,
                          size: 44,
                          isOnline: user.isOnline,
                          showOnlineIndicator: true,
                        ),
                        title: Text(user.displayName,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text('@${user.username}'),
                        onTap: () => _startChatWithUser(user),
                      );
                    },
                  )
                : ListView(
                    children: [
                      ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkSecondarySurface
                                : AppColors.lightGreen,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.group_add_outlined,
                              color: AppColors.primaryGreen),
                        ),
                        title: const Text('New Group',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        onTap: () => context.push(AppRoutes.createGroup),
                      ),
                      ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkSecondarySurface
                                : AppColors.lightGreen,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.campaign_outlined,
                              color: AppColors.primaryGreen),
                        ),
                        title: const Text('New Channel',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        onTap: () => context.push(AppRoutes.createChannel),
                      ),
                      ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkSecondarySurface
                                : AppColors.lightGreen,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.hub_outlined,
                              color: AppColors.primaryGreen),
                        ),
                        title: const Text('New Community',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        onTap: () => context.push(AppRoutes.createCommunity),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
