import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grevia/core/utils/formatters.dart';
import 'package:grevia/core/utils/id_generators.dart';
import 'package:grevia/core/utils/validators.dart';
import 'package:grevia/core/widgets/avatar_view.dart';
import 'package:grevia/core/widgets/empty_state_view.dart';
import 'package:grevia/core/widgets/grevia_button.dart';
import 'package:grevia/features/chats/domain/models/chat.dart';
import 'package:grevia/features/messages/domain/models/message.dart';
import 'package:grevia/features/profile/domain/models/user_profile.dart';

void main() {
  group('Validators Tests', () {
    test('Valid username checks', () {
      expect(Validators.isValidUsername('alice'), true);
      expect(Validators.isValidUsername('alice_123'), true);
      expect(Validators.isValidUsername('@bob_walker'), true);
      expect(Validators.isValidUsername('usr'), true); // 3 chars
      expect(Validators.isValidUsername('ab'), false); // Too short
      expect(Validators.isValidUsername('user with space'), false);
      expect(Validators.isValidUsername('user!@#'), false);
      expect(Validators.isValidUsername(''), false);
      expect(Validators.isValidUsername(null), false);
    });

    test('Phone number validation', () {
      expect(Validators.isValidPhoneNumber('+1234567890'), true);
      expect(Validators.isValidPhoneNumber('(555) 123-4567'), true);
      expect(Validators.isValidPhoneNumber('123'), false); // Too short
      expect(Validators.isValidPhoneNumber(''), false);
    });
  });

  group('Formatters Tests', () {
    test('Phone normalization', () {
      expect(
          Formatters.normalizePhoneNumber('+1 (555) 019-2831'), '+15550192831');
      expect(
          Formatters.normalizePhoneNumber('5550192831',
              defaultCountryCode: '+1'),
          '+15550192831');
      expect(Formatters.normalizePhoneNumber('004412345678'), '+4412345678');
    });

    test('File size formatter', () {
      expect(Formatters.formatFileSize(500), '500 B');
      expect(Formatters.formatFileSize(1024), '1.0 KB');
      expect(Formatters.formatFileSize(1024 * 1024 * 5), '5.0 MB');
      expect(Formatters.formatFileSize(1024 * 1024 * 1024 * 2), '2.00 GB');
    });

    test('Duration formatter', () {
      expect(Formatters.formatDuration(45), '00:45');
      expect(Formatters.formatDuration(125), '02:05');
      expect(Formatters.formatDuration(3665), '01:01:05');
    });

    test('Last seen formatter', () {
      expect(Formatters.formatLastSeen(isOnline: true), 'online');
      expect(Formatters.formatLastSeen(isOnline: false, lastSeen: null),
          'offline');
    });
  });

  group('IdGenerators Tests', () {
    test('Deterministic private chat ID', () {
      final id1 = IdGenerators.getPrivateChatId('user_alice', 'user_bob');
      final id2 = IdGenerators.getPrivateChatId('user_bob', 'user_alice');
      expect(id1, id2);
      expect(id1, 'user_alice_user_bob');
    });

    test('Unique message ID generation', () {
      final m1 = IdGenerators.generateMessageId();
      final m2 = IdGenerators.generateMessageId();
      expect(m1, isNotEmpty);
      expect(m2, isNotEmpty);
      expect(m1 != m2, true);
    });
  });

  group('Models Serialization Tests', () {
    test('Message toMap and fromMap serialization', () {
      final now = DateTime.now();
      final msg = Message(
        messageId: 'msg_123',
        chatId: 'chat_abc',
        senderId: 'user_1',
        senderName: 'Alice',
        type: MessageType.text,
        text: 'Hello Grevia!',
        createdAt: now,
        deliveryStatus: DeliveryStatus.delivered,
      );

      final map = msg.toMap();
      expect(map['messageId'], 'msg_123');
      expect(map['text'], 'Hello Grevia!');
      expect(map['deliveryStatus'], 'delivered');

      final restored = Message.fromMap(map, 'msg_123');
      expect(restored.messageId, 'msg_123');
      expect(restored.text, 'Hello Grevia!');
      expect(restored.deliveryStatus, DeliveryStatus.delivered);
    });

    test('UserProfile and PrivacySettings serialization', () {
      const privacy = UserPrivacySettings(
        lastSeen: 'nobody',
        readReceipts: false,
      );
      final profile = UserProfile(
        uid: 'user_100',
        phoneNumber: '+15551234567',
        phoneNumberNormalized: '+15551234567',
        displayName: 'John Doe',
        username: 'johndoe',
        usernameLowercase: 'johndoe',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        privacySettings: privacy,
      );

      final map = profile.toMap();
      expect(map['username'], 'johndoe');
      expect(map['privacySettings']['lastSeen'], 'nobody');
      expect(map['privacySettings']['readReceipts'], false);

      final restored = UserProfile.fromMap(map, 'user_100');
      expect(restored.username, 'johndoe');
      expect(restored.privacySettings.lastSeen, 'nobody');
      expect(restored.privacySettings.readReceipts, false);
    });

    test('Chat model helper methods', () {
      const chat = Chat(
        chatId: 'userA_userB',
        type: ChatType.private,
        participantIds: ['userA', 'userB'],
        participantNames: {'userA': 'Alice', 'userB': 'Bob'},
        pinnedByUserIds: ['userA'],
        unreadCounts: {'userA': 3},
      );

      expect(chat.getChatTitle('userA'), 'Bob');
      expect(chat.getChatTitle('userB'), 'Alice');
      expect(chat.isPinnedBy('userA'), true);
      expect(chat.isPinnedBy('userB'), false);
      expect(chat.getUnreadCount('userA'), 3);
      expect(chat.getUnreadCount('userB'), 0);
    });
  });

  group('Widget Tests', () {
    testWidgets('EmptyStateView renders title, description, and action button',
        (tester) async {
      bool actionTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateView(
              icon: Icons.chat_bubble_outline,
              title: 'No Conversations',
              description: 'You have no chats at this moment.',
              actionText: 'Start Chat',
              onActionPressed: () => actionTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('No Conversations'), findsOneWidget);
      expect(find.text('You have no chats at this moment.'), findsOneWidget);
      expect(find.text('Start Chat'), findsOneWidget);

      await tester.tap(find.text('Start Chat'));
      expect(actionTapped, true);
    });

    testWidgets('GreviaButton renders correctly and responds to tap',
        (tester) async {
      bool buttonPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GreviaButton(
              text: 'Click Me',
              onPressed: () => buttonPressed = true,
            ),
          ),
        ),
      );

      expect(find.text('Click Me'), findsOneWidget);
      await tester.tap(find.text('Click Me'));
      expect(buttonPressed, true);
    });

    testWidgets('AvatarView renders initials when photoUrl is null',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AvatarView(
              name: 'Sarah Connor',
              size: 50,
            ),
          ),
        ),
      );

      expect(find.text('SC'), findsOneWidget);
    });
  });
}
