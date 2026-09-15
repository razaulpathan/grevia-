/// Firestore Collection and Subcollection Names
class FirebaseCollections {
  FirebaseCollections._();

  static const String users = 'users';
  static const String usernames = 'usernames';
  static const String chats = 'chats';
  static const String messages = 'messages';
  static const String groups = 'groups';
  static const String channels = 'channels';
  static const String communities = 'communities';
  static const String statuses = 'statuses';
  static const String calls = 'calls';
  static const String reports = 'reports';
  static const String devices = 'devices';
  static const String invites = 'invites';
  static const String blockedUsers = 'blocked_users';
}

/// Firebase Storage Paths
class FirebaseStoragePaths {
  FirebaseStoragePaths._();

  static String profilePhoto(String userId) => 'users/$userId/profile.jpg';
  static String chatMedia(String chatId, String messageId, String extension) =>
      'chats/$chatId/$messageId.$extension';
  static String statusMedia(String userId, String statusId, String extension) =>
      'statuses/$userId/$statusId.$extension';
  static String groupPhoto(String groupId) => 'groups/$groupId/photo.jpg';
  static String channelPhoto(String channelId) =>
      'channels/$channelId/photo.jpg';
}
