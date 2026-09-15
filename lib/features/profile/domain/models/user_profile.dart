import 'package:cloud_firestore/cloud_firestore.dart';

class UserPrivacySettings {
  final String lastSeen; // 'everyone', 'contacts', 'nobody'
  final String online;
  final String profilePhoto;
  final String phoneNumber;
  final String bio;
  final String status;
  final bool readReceipts;
  final List<String> blockedUsers;

  const UserPrivacySettings({
    this.lastSeen = 'everyone',
    this.online = 'everyone',
    this.profilePhoto = 'everyone',
    this.phoneNumber = 'contacts',
    this.bio = 'everyone',
    this.status = 'contacts',
    this.readReceipts = true,
    this.blockedUsers = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'lastSeen': lastSeen,
      'online': online,
      'profilePhoto': profilePhoto,
      'phoneNumber': phoneNumber,
      'bio': bio,
      'status': status,
      'readReceipts': readReceipts,
      'blockedUsers': blockedUsers,
    };
  }

  factory UserPrivacySettings.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const UserPrivacySettings();
    return UserPrivacySettings(
      lastSeen: map['lastSeen'] as String? ?? 'everyone',
      online: map['online'] as String? ?? 'everyone',
      profilePhoto: map['profilePhoto'] as String? ?? 'everyone',
      phoneNumber: map['phoneNumber'] as String? ?? 'contacts',
      bio: map['bio'] as String? ?? 'everyone',
      status: map['status'] as String? ?? 'contacts',
      readReceipts: map['readReceipts'] as bool? ?? true,
      blockedUsers: List<String>.from(map['blockedUsers'] as List? ?? []),
    );
  }
}

class UserNotificationSettings {
  final bool messageNotifications;
  final bool groupNotifications;
  final bool channelNotifications;
  final bool callNotifications;
  final bool previewText;
  final bool soundEnabled;
  final bool vibrationEnabled;

  const UserNotificationSettings({
    this.messageNotifications = true,
    this.groupNotifications = true,
    this.channelNotifications = true,
    this.callNotifications = true,
    this.previewText = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'messageNotifications': messageNotifications,
      'groupNotifications': groupNotifications,
      'channelNotifications': channelNotifications,
      'callNotifications': callNotifications,
      'previewText': previewText,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
    };
  }

  factory UserNotificationSettings.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const UserNotificationSettings();
    return UserNotificationSettings(
      messageNotifications: map['messageNotifications'] as bool? ?? true,
      groupNotifications: map['groupNotifications'] as bool? ?? true,
      channelNotifications: map['channelNotifications'] as bool? ?? true,
      callNotifications: map['callNotifications'] as bool? ?? true,
      previewText: map['previewText'] as bool? ?? true,
      soundEnabled: map['soundEnabled'] as bool? ?? true,
      vibrationEnabled: map['vibrationEnabled'] as bool? ?? true,
    );
  }
}

class UserProfile {
  final String uid;
  final String phoneNumber;
  final String phoneNumberNormalized;
  final String displayName;
  final String username;
  final String usernameLowercase;
  final String? photoUrl;
  final String bio;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastSeen;
  final bool isOnline;
  final String status;
  final UserPrivacySettings privacySettings;
  final UserNotificationSettings notificationSettings;
  final String themePreference; // 'system', 'light', 'dark'
  final String accountStatus; // 'active', 'suspended', 'deleted'
  final String? fcmToken;

  const UserProfile({
    required this.uid,
    required this.phoneNumber,
    required this.phoneNumberNormalized,
    required this.displayName,
    required this.username,
    required this.usernameLowercase,
    this.photoUrl,
    this.bio = 'Hey there! I am using Grevia.',
    required this.createdAt,
    required this.updatedAt,
    this.lastSeen,
    this.isOnline = false,
    this.status = 'Available',
    this.privacySettings = const UserPrivacySettings(),
    this.notificationSettings = const UserNotificationSettings(),
    this.themePreference = 'system',
    this.accountStatus = 'active',
    this.fcmToken,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'phoneNumber': phoneNumber,
      'phoneNumberNormalized': phoneNumberNormalized,
      'displayName': displayName,
      'username': username,
      'usernameLowercase': usernameLowercase,
      'photoUrl': photoUrl,
      'bio': bio,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'lastSeen': lastSeen != null ? Timestamp.fromDate(lastSeen!) : null,
      'isOnline': isOnline,
      'status': status,
      'privacySettings': privacySettings.toMap(),
      'notificationSettings': notificationSettings.toMap(),
      'themePreference': themePreference,
      'accountStatus': accountStatus,
      'fcmToken': fcmToken,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map, String id) {
    DateTime parseDateTime(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return UserProfile(
      uid: id,
      phoneNumber: map['phoneNumber'] as String? ?? '',
      phoneNumberNormalized: map['phoneNumberNormalized'] as String? ?? '',
      displayName: map['displayName'] as String? ?? 'Grevia User',
      username: map['username'] as String? ?? '',
      usernameLowercase: map['usernameLowercase'] as String? ?? '',
      photoUrl: map['photoUrl'] as String?,
      bio: map['bio'] as String? ?? 'Hey there! I am using Grevia.',
      createdAt: parseDateTime(map['createdAt']),
      updatedAt: parseDateTime(map['updatedAt']),
      lastSeen: map['lastSeen'] != null ? parseDateTime(map['lastSeen']) : null,
      isOnline: map['isOnline'] as bool? ?? false,
      status: map['status'] as String? ?? 'Available',
      privacySettings: UserPrivacySettings.fromMap(
          map['privacySettings'] as Map<String, dynamic>?),
      notificationSettings: UserNotificationSettings.fromMap(
          map['notificationSettings'] as Map<String, dynamic>?),
      themePreference: map['themePreference'] as String? ?? 'system',
      accountStatus: map['accountStatus'] as String? ?? 'active',
      fcmToken: map['fcmToken'] as String?,
    );
  }

  UserProfile copyWith({
    String? displayName,
    String? username,
    String? photoUrl,
    String? bio,
    DateTime? updatedAt,
    DateTime? lastSeen,
    bool? isOnline,
    String? status,
    UserPrivacySettings? privacySettings,
    UserNotificationSettings? notificationSettings,
    String? themePreference,
    String? accountStatus,
    String? fcmToken,
  }) {
    return UserProfile(
      uid: uid,
      phoneNumber: phoneNumber,
      phoneNumberNormalized: phoneNumberNormalized,
      displayName: displayName ?? this.displayName,
      username: username ?? this.username,
      usernameLowercase: (username ?? this.username).toLowerCase(),
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSeen: lastSeen ?? this.lastSeen,
      isOnline: isOnline ?? this.isOnline,
      status: status ?? this.status,
      privacySettings: privacySettings ?? this.privacySettings,
      notificationSettings: notificationSettings ?? this.notificationSettings,
      themePreference: themePreference ?? this.themePreference,
      accountStatus: accountStatus ?? this.accountStatus,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }
}
