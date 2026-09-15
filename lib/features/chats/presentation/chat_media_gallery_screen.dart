import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/empty_state_view.dart';

class ChatMediaGalleryScreen extends StatelessWidget {
  final String chatId;

  const ChatMediaGalleryScreen({super.key, required this.chatId});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Shared Media'),
          bottom: const TabBar(
            indicatorColor: AppColors.primaryGreen,
            labelColor: AppColors.primaryGreen,
            tabs: [
              Tab(text: 'Media'),
              Tab(text: 'Docs'),
              Tab(text: 'Links'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            EmptyStateView(
              icon: Icons.photo_library_outlined,
              title: 'No media shared',
              description:
                  'Photos and videos sent in this chat will appear here.',
            ),
            EmptyStateView(
              icon: Icons.insert_drive_file_outlined,
              title: 'No files shared',
              description:
                  'Documents and files sent in this chat will appear here.',
            ),
            EmptyStateView(
              icon: Icons.link_outlined,
              title: 'No links shared',
              description:
                  'Web links shared in this conversation will be listed here.',
            ),
          ],
        ),
      ),
    );
  }
}
