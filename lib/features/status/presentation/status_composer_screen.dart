import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/utils/id_generators.dart';
import '../domain/models/status_model.dart';

class StatusComposerScreen extends ConsumerStatefulWidget {
  const StatusComposerScreen({super.key});

  @override
  ConsumerState<StatusComposerScreen> createState() =>
      _StatusComposerScreenState();
}

class _StatusComposerScreenState extends ConsumerState<StatusComposerScreen> {
  final _textController = TextEditingController();
  int _selectedColorIndex = 0;

  final List<int> _colors = [
    0xFF0F7C43, // Grevia Dark Green
    0xFF18A957, // Grevia Primary Green
    0xFF1E88E5, // Ocean Blue
    0xFF5E35B1, // Deep Purple
    0xFFE91E63, // Vibrant Pink
    0xFFE65100, // Sunset Orange
    0xFF37474F, // Dark Slate
  ];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _postStatus() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final myProfile = ref.read(currentUserProfileProvider).value;
    final currentUserId = ref.read(currentUserIdProvider) ?? '';
    final statusRepo = ref.read(statusRepositoryProvider);

    final status = StatusModel(
      statusId: IdGenerators.generateMessageId(),
      userId: currentUserId,
      userName: myProfile?.displayName ?? 'Grevia User',
      userPhoto: myProfile?.photoUrl,
      type: StatusType.text,
      content: text,
      backgroundColor: _colors[_selectedColorIndex],
      createdAt: DateTime.now(),
    );

    statusRepo.postStatus(status);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Status update posted!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = Color(_colors[_selectedColorIndex]);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.palette_outlined),
            tooltip: 'Change Color',
            onPressed: () {
              setState(() {
                _selectedColorIndex =
                    (_selectedColorIndex + 1) % _colors.length;
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Center(
            child: TextField(
              controller: _textController,
              maxLines: 8,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
              decoration: const InputDecoration(
                hintText: 'Type a status...',
                hintStyle: TextStyle(color: Colors.white60),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _postStatus,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primaryGreen,
        child: const Icon(Icons.send),
      ),
    );
  }
}
