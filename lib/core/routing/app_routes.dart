/// Grevia Named Route Constants
class AppRoutes {
  AppRoutes._();

  // Auth & Onboarding
  static const String splash = '/splash';
  static const String welcome = '/welcome';
  static const String phoneLogin = '/login';
  static const String otp = '/otp';
  static const String profileSetup = '/profile-setup';
  static const String usernameSetup = '/username-setup';
  static const String permissions = '/permissions';

  // Bottom Navigation Root Tabs
  static const String chats = '/chats';
  static const String updates = '/updates';
  static const String contacts = '/contacts';
  static const String calls = '/calls';
  static const String settings = '/settings';

  // Chat Routes
  static const String archivedChats = '/chats/archived';
  static const String savedMessages = '/chats/saved';
  static const String privateChat = '/chat/:chatId';
  static const String chatDetails = '/chat/:chatId/details';
  static const String chatMediaGallery = '/chat/:chatId/media';
  static const String newChat = '/new-chat';

  // Search & Profile
  static const String globalSearch = '/search';
  static const String userProfile = '/user/:userId';
  static const String qrProfile = '/qr-profile';
  static const String qrScanner = '/qr-scanner';

  // Groups
  static const String createGroup = '/groups/create';
  static const String groupChat = '/group/:groupId';
  static const String groupDetails = '/group/:groupId/details';
  static const String groupMembers = '/group/:groupId/members';
  static const String groupAdminSettings = '/group/:groupId/admin';
  static const String groupPermissions = '/group/:groupId/permissions';
  static const String inviteGroupMembers = '/group/:groupId/invite';

  // Channels
  static const String createChannel = '/channels/create';
  static const String channelFeed = '/channel/:channelId';
  static const String channelDetails = '/channel/:channelId/details';

  // Communities
  static const String createCommunity = '/communities/create';
  static const String communityHome = '/community/:communityId';

  // Status / Stories
  static const String statusComposer = '/status/compose';
  static const String statusViewer = '/status/view';
  static const String statusPrivacy = '/status/privacy';

  // Calls
  static const String voiceCall = '/call/voice/:callId';
  static const String videoCall = '/call/video/:callId';
  static const String incomingCall = '/call/incoming/:callId';

  // Settings
  static const String accountSettings = '/settings/account';
  static const String editProfile = '/settings/edit-profile';
  static const String privacySettings = '/settings/privacy';
  static const String blockedUsers = '/settings/blocked-users';
  static const String securitySettings = '/settings/security';
  static const String notificationsSettings = '/settings/notifications';
  static const String chatSettings = '/settings/chats';
  static const String appearanceSettings = '/settings/appearance';
  static const String storageSettings = '/settings/storage';
  static const String devicesSettings = '/settings/devices';
  static const String help = '/settings/help';
  static const String about = '/settings/about';
  static const String deleteAccount = '/settings/delete-account';
}
