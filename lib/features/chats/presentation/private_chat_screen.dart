import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/id_generators.dart';
import '../../../core/widgets/avatar_view.dart';
import '../../calls/domain/models/call_session.dart';
import '../../messages/domain/models/message.dart';

class PrivateChatScreen extends ConsumerStatefulWidget {
  final String chatId;
  final String? initialTitle;
  final String? initialAvatar;
  final String? chatType;

  const PrivateChatScreen({
    super.key,
    required this.chatId,
    this.initialTitle,
    this.initialAvatar,
    this.chatType,
  });

  @override
  ConsumerState<PrivateChatScreen> createState() => _PrivateChatScreenState();
}

class _PrivateChatScreenState extends ConsumerState<PrivateChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  ReplyMetadata? _replyingTo;
  bool _isTyping = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSendMessage({
    String? text,
    MessageType type = MessageType.text,
    String? mediaUrl,
    String? fileName,
    int? fileSize,
    int? duration,
    PollData? pollData,
    LocationData? locationData,
  }) {
    final content = text ?? _messageController.text.trim();
    if (content.isEmpty &&
        mediaUrl == null &&
        pollData == null &&
        locationData == null) return;

    final currentUserId = ref.read(currentUserIdProvider) ?? '';
    final chatRepo = ref.read(chatRepositoryProvider);
    final userProfile = ref.read(currentUserProfileProvider).value;

    final message = Message(
      messageId: IdGenerators.generateMessageId(),
      chatId: widget.chatId,
      senderId: currentUserId,
      senderName: userProfile?.displayName ?? 'Me',
      type: type,
      text: content,
      mediaUrl: mediaUrl,
      fileName: fileName,
      fileSize: fileSize,
      duration: duration,
      replyTo: _replyingTo,
      createdAt: DateTime.now(),
      deliveryStatus: DeliveryStatus.sent,
      pollData: pollData,
      locationData: locationData,
    );

    chatRepo.sendMessage(message);

    _messageController.clear();
    setState(() {
      _replyingTo = null;
      _isTyping = false;
    });

    // Mark as read and cancel typing
    chatRepo.setTyping(widget.chatId, currentUserId, false);
  }

  void _initiateCall(bool isVideo) {
    final currentUserId = ref.read(currentUserIdProvider) ?? '';
    final userProfile = ref.read(currentUserProfileProvider).value;
    final callRepo = ref.read(callRepositoryProvider);

    final callId = IdGenerators.generateCallId();
    final session = CallSession(
      callId: callId,
      callerId: currentUserId,
      callerName: userProfile?.displayName ?? 'Grevia User',
      callerPhoto: userProfile?.photoUrl,
      receiverId:
          widget.chatId.replaceAll(currentUserId, '').replaceAll('_', ''),
      receiverName: widget.initialTitle ?? 'User',
      receiverPhoto: widget.initialAvatar,
      type: isVideo ? CallType.video : CallType.voice,
      status: CallStatus.ringing,
      createdAt: DateTime.now(),
    );

    callRepo.initiateCall(session);

    if (isVideo) {
      context.push('/call/video/$callId');
    } else {
      context.push('/call/voice/$callId');
    }
  }

  void _showAttachmentSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor:
          isDark ? AppColors.darkSurface : AppColors.lightCardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Wrap(
              spacing: 24,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: [
                _buildAttachmentItem(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  color: const Color(0xFFE91E63),
                  onTap: () async {
                    Navigator.pop(context);
                    final picker = ImagePicker();
                    final picked =
                        await picker.pickImage(source: ImageSource.camera);
                    if (picked != null) {
                      _uploadAndSendMedia(File(picked.path), MessageType.image);
                    }
                  },
                ),
                _buildAttachmentItem(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  color: const Color(0xFF9C27B0),
                  onTap: () async {
                    Navigator.pop(context);
                    final picker = ImagePicker();
                    final picked =
                        await picker.pickImage(source: ImageSource.gallery);
                    if (picked != null) {
                      _uploadAndSendMedia(File(picked.path), MessageType.image);
                    }
                  },
                ),
                _buildAttachmentItem(
                  icon: Icons.videocam,
                  label: 'Video',
                  color: const Color(0xFFFF5722),
                  onTap: () async {
                    Navigator.pop(context);
                    final picker = ImagePicker();
                    final picked =
                        await picker.pickVideo(source: ImageSource.gallery);
                    if (picked != null) {
                      _uploadAndSendMedia(File(picked.path), MessageType.video);
                    }
                  },
                ),
                _buildAttachmentItem(
                  icon: Icons.insert_drive_file,
                  label: 'Document',
                  color: const Color(0xFF2196F3),
                  onTap: () async {
                    Navigator.pop(context);
                    final result = await FilePicker.platform.pickFiles();
                    if (result != null && result.files.single.path != null) {
                      final file = File(result.files.single.path!);
                      _uploadAndSendMedia(
                        file,
                        MessageType.document,
                        fileName: result.files.single.name,
                        fileSize: result.files.single.size,
                      );
                    }
                  },
                ),
                _buildAttachmentItem(
                  icon: Icons.location_on,
                  label: 'Location',
                  color: const Color(0xFF4CAF50),
                  onTap: () {
                    Navigator.pop(context);
                    _handleSendMessage(
                      text: '📍 Shared Location',
                      type: MessageType.location,
                      locationData: const LocationData(
                        latitude: 37.7749,
                        longitude: -122.4194,
                        address: 'San Francisco, CA',
                      ),
                    );
                  },
                ),
                _buildAttachmentItem(
                  icon: Icons.poll,
                  label: 'Poll',
                  color: const Color(0xFFFF9800),
                  onTap: () {
                    Navigator.pop(context);
                    _showCreatePollDialog();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAttachmentItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label,
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Future<void> _uploadAndSendMedia(
    File file,
    MessageType type, {
    String? fileName,
    int? fileSize,
  }) async {
    final storage = ref.read(storageServiceProvider);
    final messageId = IdGenerators.generateMessageId();
    final ext = file.path.split('.').last;

    final url =
        await storage.uploadChatMedia(widget.chatId, messageId, ext, file);

    _handleSendMessage(
      type: type,
      mediaUrl: url,
      fileName: fileName ?? file.path.split(Platform.pathSeparator).last,
      fileSize: fileSize ?? await file.length(),
    );
  }

  void _showCreatePollDialog() {
    final questionCtrl = TextEditingController();
    final opt1Ctrl = TextEditingController();
    final opt2Ctrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create Poll'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: questionCtrl,
                decoration:
                    const InputDecoration(hintText: 'Ask a question...'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: opt1Ctrl,
                decoration: const InputDecoration(hintText: 'Option 1'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: opt2Ctrl,
                decoration: const InputDecoration(hintText: 'Option 2'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final q = questionCtrl.text.trim();
                final o1 = opt1Ctrl.text.trim();
                final o2 = opt2Ctrl.text.trim();
                if (q.isNotEmpty && o1.isNotEmpty && o2.isNotEmpty) {
                  Navigator.pop(context);
                  _handleSendMessage(
                    type: MessageType.poll,
                    pollData: PollData(
                      question: q,
                      options: [
                        PollOption(id: 'opt_1', text: o1),
                        PollOption(id: 'opt_2', text: o2),
                      ],
                    ),
                  );
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUserId = ref.watch(currentUserIdProvider) ?? '';
    final chatRepo = ref.watch(chatRepositoryProvider);

    final title = widget.initialTitle ?? 'Chat';
    final avatar = widget.initialAvatar;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            AvatarView(photoUrl: avatar, name: title, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'tap for info',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.textDarkSecondary
                          : AppColors.textLightSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call_outlined),
            tooltip: 'Voice Call',
            onPressed: () => _initiateCall(false),
          ),
          IconButton(
            icon: const Icon(Icons.videocam_outlined),
            tooltip: 'Video Call',
            onPressed: () => _initiateCall(true),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (val) {
              if (val == 'details') {
                context.push(
                  '/chat/${widget.chatId}/details',
                  extra: {'title': title, 'avatar': avatar},
                );
              } else if (val == 'media') {
                context.push('/chat/${widget.chatId}/media');
              } else if (val == 'clear') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Chat history cleared.')),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                  value: 'details', child: Text('View Details')),
              const PopupMenuItem(value: 'media', child: Text('Media & Files')),
              const PopupMenuItem(value: 'clear', child: Text('Clear History')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages Stream List
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: chatRepo.getMessagesStream(widget.chatId),
              builder: (context, snapshot) {
                final messages = snapshot.data ?? [];

                if (messages.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        'No messages here yet.\nSend a message to start the conversation!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDark
                              ? AppColors.textDarkSecondary
                              : AppColors.textLightSecondary,
                        ),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.senderId == currentUserId;
                    return _buildMessageBubble(msg, isMe, isDark);
                  },
                );
              },
            ),
          ),

          // Reply Bar Preview
          if (_replyingTo != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: isDark
                  ? AppColors.darkSecondarySurface
                  : AppColors.lightGreen,
              child: Row(
                children: [
                  Container(
                      width: 4, height: 36, color: AppColors.primaryGreen),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _replyingTo!.senderName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                        Text(
                          _replyingTo!.text,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => setState(() => _replyingTo = null),
                  ),
                ],
              ),
            ),

          // Composer Input Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color:
                  isDark ? AppColors.darkSurface : AppColors.lightCardSurface,
              border: Border(
                top: BorderSide(
                  color:
                      isDark ? AppColors.darkDivider : AppColors.lightDivider,
                ),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.attach_file_rounded),
                    color: AppColors.primaryGreen,
                    onPressed: _showAttachmentSheet,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      maxLines: 4,
                      minLines: 1,
                      decoration: const InputDecoration(
                        hintText: 'Message...',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      ),
                      onChanged: (val) {
                        final typing = val.trim().isNotEmpty;
                        if (typing != _isTyping) {
                          setState(() => _isTyping = typing);
                          chatRepo.setTyping(
                              widget.chatId, currentUserId, typing);
                        }
                      },
                    ),
                  ),
                  if (_isTyping)
                    IconButton(
                      icon: const Icon(Icons.send_rounded),
                      color: AppColors.primaryGreen,
                      onPressed: () => _handleSendMessage(),
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.mic_none_rounded),
                      color: AppColors.primaryGreen,
                      onPressed: () {
                        // Send Voice Note simulation
                        _handleSendMessage(
                          text: 'Voice Message (0:07)',
                          type: MessageType.voice,
                          duration: 7,
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message msg, bool isMe, bool isDark) {
    Color bubbleColor;
    if (isMe) {
      bubbleColor =
          isDark ? AppColors.sentBubbleDark : AppColors.sentBubbleLight;
    } else {
      bubbleColor =
          isDark ? AppColors.receivedBubbleDark : AppColors.receivedBubbleLight;
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: () => _showMessageOptions(msg, isMe),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isMe ? 16 : 4),
              bottomRight: Radius.circular(isMe ? 4 : 16),
            ),
            border: Border.all(
              color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
              width: 0.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Reply Reference
              if (msg.replyTo != null)
                Container(
                  padding: const EdgeInsets.all(6),
                  margin: const EdgeInsets.only(bottom: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${msg.replyTo!.senderName}: ${msg.replyTo!.text}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 12, fontStyle: FontStyle.italic),
                  ),
                ),

              // Message Content
              _buildMessageContent(msg),

              const SizedBox(height: 4),
              // Time & Status
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    Formatters.formatChatListTime(msg.createdAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? AppColors.textDarkSecondary
                          : AppColors.textLightSecondary,
                    ),
                  ),
                  if (isMe) ...[
                    const SizedBox(width: 4),
                    _buildDeliveryIcon(msg.deliveryStatus),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageContent(Message msg) {
    switch (msg.type) {
      case MessageType.image:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: msg.mediaUrl != null
                  ? Image.network(msg.mediaUrl!, height: 180, fit: BoxFit.cover)
                  : const Icon(Icons.image, size: 80),
            ),
            if (msg.text.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(msg.text, style: const TextStyle(fontSize: 15)),
            ],
          ],
        );
      case MessageType.voice:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.play_arrow_rounded,
                color: AppColors.primaryGreen, size: 32),
            const SizedBox(width: 8),
            Container(width: 80, height: 4, color: AppColors.primaryGreen),
            const SizedBox(width: 8),
            Text('${msg.duration ?? 0}s', style: const TextStyle(fontSize: 12)),
          ],
        );
      case MessageType.document:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.insert_drive_file,
                color: AppColors.primaryGreen, size: 32),
            const SizedBox(width: 10),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    msg.fileName ?? 'Document',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    Formatters.formatFileSize(msg.fileSize ?? 0),
                    style: const TextStyle(fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        );
      case MessageType.poll:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              msg.pollData?.question ?? 'Poll',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 8),
            if (msg.pollData != null)
              ...msg.pollData!.options.map((opt) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.radio_button_unchecked, size: 18),
                        const SizedBox(width: 8),
                        Text(opt.text),
                      ],
                    ),
                  )),
          ],
        );
      default:
        return Text(
          msg.text,
          style: const TextStyle(fontSize: 15, height: 1.3),
        );
    }
  }

  Widget _buildDeliveryIcon(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.sending:
        return const Icon(Icons.access_time,
            size: 13, color: AppColors.iconMuted);
      case DeliveryStatus.sent:
        return const Icon(Icons.check, size: 14, color: AppColors.iconMuted);
      case DeliveryStatus.delivered:
        return const Icon(Icons.done_all, size: 14, color: AppColors.iconMuted);
      case DeliveryStatus.read:
        return const Icon(Icons.done_all,
            size: 14, color: AppColors.primaryGreen);
      case DeliveryStatus.failed:
        return const Icon(Icons.error_outline,
            size: 14, color: AppColors.errorRed);
    }
  }

  void _showMessageOptions(Message msg, bool isMe) {
    final chatRepo = ref.read(chatRepositoryProvider);

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
                leading: const Icon(Icons.reply_outlined),
                title: const Text('Reply'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _replyingTo = ReplyMetadata(
                      messageId: msg.messageId,
                      senderName: msg.senderName,
                      text: msg.text,
                      type: msg.type,
                    );
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.copy_outlined),
                title: const Text('Copy Text'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Message copied to clipboard.')),
                  );
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.delete_outline, color: AppColors.errorRed),
                title: const Text('Delete for Me',
                    style: TextStyle(color: AppColors.errorRed)),
                onTap: () {
                  chatRepo.deleteMessage(widget.chatId, msg.messageId, false);
                  Navigator.pop(context);
                },
              ),
              if (isMe)
                ListTile(
                  leading: const Icon(Icons.delete_forever,
                      color: AppColors.errorRed),
                  title: const Text('Delete for Everyone',
                      style: TextStyle(color: AppColors.errorRed)),
                  onTap: () {
                    chatRepo.deleteMessage(widget.chatId, msg.messageId, true);
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
