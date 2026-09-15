import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/widgets/avatar_view.dart';
import '../../profile/domain/models/user_profile.dart';

class GlobalSearchScreen extends ConsumerStatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  ConsumerState<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends ConsumerState<GlobalSearchScreen> {
  final _searchController = TextEditingController();
  List<UserProfile> _users = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    final clean = query.trim();
    if (clean.isEmpty) {
      setState(() {
        _users = [];
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);
    final userRepo = ref.read(userRepositoryProvider);
    final results = await userRepo.searchUsers(clean);

    if (!mounted) return;
    setState(() {
      _users = results;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search chats, people, channels...',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
          ),
          onChanged: _search,
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                _search('');
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _users.isEmpty
              ? Center(
                  child: Text(
                    _searchController.text.isEmpty
                        ? 'Search for people by @username or name'
                        : 'No results found for "${_searchController.text}"',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textDarkSecondary
                          : AppColors.textLightSecondary,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: _users.length,
                  itemBuilder: (context, index) {
                    final user = _users[index];
                    return ListTile(
                      leading: AvatarView(
                        photoUrl: user.photoUrl,
                        name: user.displayName,
                        size: 46,
                        isOnline: user.isOnline,
                        showOnlineIndicator: true,
                      ),
                      title: Text(user.displayName,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('@${user.username}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.chat_bubble_outline,
                            color: AppColors.primaryGreen),
                        onPressed: () {
                          final myId = ref.read(currentUserIdProvider) ?? '';
                          final myProfile =
                              ref.read(currentUserProfileProvider).value;
                          final chatRepo = ref.read(chatRepositoryProvider);

                          chatRepo
                              .createOrGetPrivateChat(
                            currentUserId: myId,
                            targetUserId: user.uid,
                            currentUserName:
                                myProfile?.displayName ?? 'Grevia User',
                            targetUserName: user.displayName,
                            currentUserPhoto: myProfile?.photoUrl,
                            targetUserPhoto: user.photoUrl,
                          )
                              .then((chat) {
                            if (context.mounted) {
                              context.push(
                                '/chat/${chat.chatId}',
                                extra: {
                                  'title': user.displayName,
                                  'avatar': user.photoUrl
                                },
                              );
                            }
                          });
                        },
                      ),
                      onTap: () {
                        context.push(
                          '/user/${user.uid}',
                          extra: {
                            'name': user.displayName,
                            'username': user.username,
                            'bio': user.bio,
                            'photoUrl': user.photoUrl,
                          },
                        );
                      },
                    );
                  },
                ),
    );
  }
}
