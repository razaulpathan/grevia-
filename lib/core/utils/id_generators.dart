import 'dart:math';
import 'package:uuid/uuid.dart';

/// ID and Code Generators for Grevia
class IdGenerators {
  IdGenerators._();

  static const _uuid = Uuid();

  /// Deterministic chat ID for 1-to-1 conversations to guarantee uniqueness
  static String getPrivateChatId(String userIdA, String userIdB) {
    if (userIdA.compareTo(userIdB) < 0) {
      return '${userIdA}_$userIdB';
    }
    return '${userIdB}_$userIdA';
  }

  /// Unique message ID
  static String generateMessageId() {
    return _uuid.v4();
  }

  /// Unique call session ID
  static String generateCallId() {
    return _uuid.v4();
  }

  /// Generate alphanumeric invite code for groups and channels (e.g. "grevia_abc123")
  static String generateInviteCode([int length = 8]) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final rand = Random.secure();
    return List.generate(length, (index) => chars[rand.nextInt(chars.length)])
        .join();
  }
}
