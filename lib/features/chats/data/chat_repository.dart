import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firebase_constants.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/utils/id_generators.dart';
import '../../messages/domain/models/message.dart';
import '../domain/models/chat.dart';

abstract class ChatRepository {
  Stream<List<Chat>> getChatsStream(String userId);
  Stream<List<Message>> getMessagesStream(String chatId, {int limit = 50});
  Future<Chat> createOrGetPrivateChat({
    required String currentUserId,
    required String targetUserId,
    required String currentUserName,
    required String targetUserName,
    String? currentUserPhoto,
    String? targetUserPhoto,
  });
  Future<void> sendMessage(Message message);
  Future<void> updateDeliveryStatus(
      String chatId, String messageId, DeliveryStatus status);
  Future<void> reactToMessage(
      String chatId, String messageId, String userId, String emoji);
  Future<void> deleteMessage(
      String chatId, String messageId, bool isForEveryone);
  Future<void> setTyping(String chatId, String userId, bool isTyping);
  Future<void> togglePinChat(String chatId, String userId, bool isPinned);
  Future<void> toggleMuteChat(String chatId, String userId, bool isMuted);
  Future<void> toggleArchiveChat(String chatId, String userId, bool isArchived);
  Future<void> markAsRead(String chatId, String userId);
}

class FirestoreChatRepository implements ChatRepository {
  final FirebaseService _firebaseService;
  final Map<String, List<Chat>> _localChats = {};
  final Map<String, List<Message>> _localMessages = {};
  final StreamController<List<Chat>> _chatsStreamController =
      StreamController<List<Chat>>.broadcast();
  final Map<String, StreamController<List<Message>>> _messageControllers = {};

  FirestoreChatRepository([FirebaseService? firebaseService])
      : _firebaseService = firebaseService ?? FirebaseService.instance;

  @override
  Stream<List<Chat>> getChatsStream(String userId) {
    final firestore = _firebaseService.firestore;
    if (firestore == null) {
      return _chatsStreamController.stream;
    }

    return firestore
        .collection(FirebaseCollections.chats)
        .where('participantIds', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Chat.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  @override
  Stream<List<Message>> getMessagesStream(String chatId, {int limit = 50}) {
    final firestore = _firebaseService.firestore;
    if (firestore == null) {
      _messageControllers.putIfAbsent(
          chatId, () => StreamController<List<Message>>.broadcast());
      return _messageControllers[chatId]!.stream;
    }

    return firestore
        .collection(FirebaseCollections.chats)
        .doc(chatId)
        .collection(FirebaseCollections.messages)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Message.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  @override
  Future<Chat> createOrGetPrivateChat({
    required String currentUserId,
    required String targetUserId,
    required String currentUserName,
    required String targetUserName,
    String? currentUserPhoto,
    String? targetUserPhoto,
  }) async {
    final chatId = IdGenerators.getPrivateChatId(currentUserId, targetUserId);
    final firestore = _firebaseService.firestore;

    final chat = Chat(
      chatId: chatId,
      type: currentUserId == targetUserId ? ChatType.saved : ChatType.private,
      participantIds: [currentUserId, targetUserId],
      participantNames: {
        currentUserId: currentUserName,
        targetUserId: targetUserName,
      },
      participantPhotos: {
        currentUserId: currentUserPhoto ?? '',
        targetUserId: targetUserPhoto ?? '',
      },
      lastMessageText: '',
      lastMessageType: 'text',
      lastMessageSenderId: '',
      lastMessageTime: DateTime.now(),
    );

    if (firestore == null) {
      _localChats.putIfAbsent(currentUserId, () => []);
      if (!_localChats[currentUserId]!.any((c) => c.chatId == chatId)) {
        _localChats[currentUserId]!.add(chat);
        _chatsStreamController.add(_localChats[currentUserId]!);
      }
      return chat;
    }

    final docRef = firestore.collection(FirebaseCollections.chats).doc(chatId);
    final doc = await docRef.get();
    if (!doc.exists) {
      await docRef.set(chat.toMap(), SetOptions(merge: true));
    }
    return chat;
  }

  @override
  Future<void> sendMessage(Message message) async {
    final firestore = _firebaseService.firestore;
    if (firestore == null) {
      _localMessages.putIfAbsent(message.chatId, () => []);
      _localMessages[message.chatId]!.insert(0, message);
      _messageControllers[message.chatId]?.add(_localMessages[message.chatId]!);
      return;
    }

    final chatRef =
        firestore.collection(FirebaseCollections.chats).doc(message.chatId);
    final messageRef =
        chatRef.collection(FirebaseCollections.messages).doc(message.messageId);

    final batch = firestore.batch();
    batch.set(messageRef, message.toMap());
    batch.update(chatRef, {
      'lastMessageText': message.type == MessageType.text
          ? message.text
          : '[${message.type.name}]',
      'lastMessageType': message.type.name,
      'lastMessageSenderId': message.senderId,
      'lastMessageTime': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  @override
  Future<void> updateDeliveryStatus(
      String chatId, String messageId, DeliveryStatus status) async {
    final firestore = _firebaseService.firestore;
    if (firestore == null) return;

    await firestore
        .collection(FirebaseCollections.chats)
        .doc(chatId)
        .collection(FirebaseCollections.messages)
        .doc(messageId)
        .update({'deliveryStatus': status.name});
  }

  @override
  Future<void> reactToMessage(
      String chatId, String messageId, String userId, String emoji) async {
    final firestore = _firebaseService.firestore;
    if (firestore == null) return;

    await firestore
        .collection(FirebaseCollections.chats)
        .doc(chatId)
        .collection(FirebaseCollections.messages)
        .doc(messageId)
        .update({'reactions.$userId': emoji});
  }

  @override
  Future<void> deleteMessage(
      String chatId, String messageId, bool isForEveryone) async {
    final firestore = _firebaseService.firestore;
    if (firestore == null) return;

    final docRef = firestore
        .collection(FirebaseCollections.chats)
        .doc(chatId)
        .collection(FirebaseCollections.messages)
        .doc(messageId);

    if (isForEveryone) {
      await docRef.update({
        'isDeletedForEveryone': true,
        'text': 'This message was deleted',
        'mediaUrl': null,
        'deletedAt': FieldValue.serverTimestamp(),
      });
    } else {
      await docRef.delete();
    }
  }

  @override
  Future<void> setTyping(String chatId, String userId, bool isTyping) async {
    final firestore = _firebaseService.firestore;
    if (firestore == null) return;

    await firestore.collection(FirebaseCollections.chats).doc(chatId).update({
      'typingUsers.$userId':
          isTyping ? FieldValue.serverTimestamp() : FieldValue.delete(),
    });
  }

  @override
  Future<void> togglePinChat(
      String chatId, String userId, bool isPinned) async {
    final firestore = _firebaseService.firestore;
    if (firestore == null) return;

    await firestore.collection(FirebaseCollections.chats).doc(chatId).update({
      'pinnedByUserIds': isPinned
          ? FieldValue.arrayUnion([userId])
          : FieldValue.arrayRemove([userId]),
    });
  }

  @override
  Future<void> toggleMuteChat(
      String chatId, String userId, bool isMuted) async {
    final firestore = _firebaseService.firestore;
    if (firestore == null) return;

    await firestore.collection(FirebaseCollections.chats).doc(chatId).update({
      'mutedByUserIds': isMuted
          ? FieldValue.arrayUnion([userId])
          : FieldValue.arrayRemove([userId]),
    });
  }

  @override
  Future<void> toggleArchiveChat(
      String chatId, String userId, bool isArchived) async {
    final firestore = _firebaseService.firestore;
    if (firestore == null) return;

    await firestore.collection(FirebaseCollections.chats).doc(chatId).update({
      'archivedByUserIds': isArchived
          ? FieldValue.arrayUnion([userId])
          : FieldValue.arrayRemove([userId]),
    });
  }

  @override
  Future<void> markAsRead(String chatId, String userId) async {
    final firestore = _firebaseService.firestore;
    if (firestore == null) return;

    await firestore.collection(FirebaseCollections.chats).doc(chatId).update({
      'unreadCounts.$userId': 0,
    });
  }
}
