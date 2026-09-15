import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/otp_screen.dart';
import '../../features/auth/presentation/permissions_screen.dart';
import '../../features/auth/presentation/phone_login_screen.dart';
import '../../features/auth/presentation/profile_setup_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/username_setup_screen.dart';
import '../../features/auth/presentation/welcome_screen.dart';
import '../../features/calls/presentation/video_call_screen.dart';
import '../../features/calls/presentation/voice_call_screen.dart';
import '../../features/channels/presentation/channel_details_screen.dart';
import '../../features/channels/presentation/channel_feed_screen.dart';
import '../../features/channels/presentation/create_channel_screen.dart';
import '../../features/chats/presentation/archived_chats_screen.dart';
import '../../features/chats/presentation/chat_details_screen.dart';
import '../../features/chats/presentation/chat_media_gallery_screen.dart';
import '../../features/chats/presentation/new_chat_screen.dart';
import '../../features/chats/presentation/private_chat_screen.dart';
import '../../features/communities/presentation/community_home_screen.dart';
import '../../features/communities/presentation/create_community_screen.dart';
import '../../features/contacts/presentation/global_search_screen.dart';
import '../../features/contacts/presentation/qr_profile_screen.dart';
import '../../features/contacts/presentation/qr_scanner_screen.dart';
import '../../features/contacts/presentation/user_profile_screen.dart';
import '../../features/groups/presentation/create_group_screen.dart';
import '../../features/groups/presentation/group_admin_settings_screen.dart';
import '../../features/groups/presentation/group_chat_screen.dart';
import '../../features/groups/presentation/group_details_screen.dart';
import '../../features/groups/presentation/group_permissions_screen.dart';
import '../../features/groups/presentation/invite_members_screen.dart';
import '../../features/navigation/presentation/main_scaffold.dart';
import '../../features/settings/presentation/about_screen.dart';
import '../../features/settings/presentation/account_settings_screen.dart';
import '../../features/settings/presentation/appearance_screen.dart';
import '../../features/settings/presentation/blocked_users_screen.dart';
import '../../features/settings/presentation/chat_settings_screen.dart';
import '../../features/settings/presentation/delete_account_screen.dart';
import '../../features/settings/presentation/devices_screen.dart';
import '../../features/settings/presentation/edit_profile_screen.dart';
import '../../features/settings/presentation/help_screen.dart';
import '../../features/settings/presentation/notifications_settings_screen.dart';
import '../../features/settings/presentation/privacy_settings_screen.dart';
import '../../features/settings/presentation/security_settings_screen.dart';
import '../../features/settings/presentation/storage_data_screen.dart';
import '../../features/status/domain/models/status_model.dart';
import '../../features/status/presentation/status_composer_screen.dart';
import '../../features/status/presentation/status_privacy_screen.dart';
import '../../features/status/presentation/status_viewer_screen.dart';
import 'app_routes.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: AppRoutes.splash,
  routes: [
    // Auth Routes
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.welcome,
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.phoneLogin,
      builder: (context, state) => const PhoneLoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.otp,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return OtpScreen(
          phoneNumber: extra['phoneNumber'] as String? ?? '',
          verificationId: extra['verificationId'] as String? ?? '',
        );
      },
    ),
    GoRoute(
      path: AppRoutes.profileSetup,
      builder: (context, state) => const ProfileSetupScreen(),
    ),
    GoRoute(
      path: AppRoutes.usernameSetup,
      builder: (context, state) => const UsernameSetupScreen(),
    ),
    GoRoute(
      path: AppRoutes.permissions,
      builder: (context, state) => const PermissionsScreen(),
    ),

    // Main App Navigation Tabs
    GoRoute(
      path: AppRoutes.chats,
      builder: (context, state) => const MainScaffold(initialIndex: 0),
    ),
    GoRoute(
      path: AppRoutes.updates,
      builder: (context, state) => const MainScaffold(initialIndex: 1),
    ),
    GoRoute(
      path: AppRoutes.contacts,
      builder: (context, state) => const MainScaffold(initialIndex: 2),
    ),
    GoRoute(
      path: AppRoutes.calls,
      builder: (context, state) => const MainScaffold(initialIndex: 3),
    ),
    GoRoute(
      path: AppRoutes.settings,
      builder: (context, state) => const MainScaffold(initialIndex: 4),
    ),

    // Chat Sub-Routes
    GoRoute(
      path: AppRoutes.archivedChats,
      builder: (context, state) => const ArchivedChatsScreen(),
    ),
    GoRoute(
      path: AppRoutes.newChat,
      builder: (context, state) => const NewChatScreen(),
    ),
    GoRoute(
      path: AppRoutes.privateChat,
      builder: (context, state) {
        final chatId = state.pathParameters['chatId']!;
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return PrivateChatScreen(
          chatId: chatId,
          initialTitle: extra['title'] as String?,
          initialAvatar: extra['avatar'] as String?,
          chatType: extra['type'] as String?,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.chatDetails,
      builder: (context, state) {
        final chatId = state.pathParameters['chatId']!;
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return ChatDetailsScreen(
          chatId: chatId,
          initialTitle: extra['title'] as String?,
          initialAvatar: extra['avatar'] as String?,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.chatMediaGallery,
      builder: (context, state) {
        final chatId = state.pathParameters['chatId']!;
        return ChatMediaGalleryScreen(chatId: chatId);
      },
    ),

    // Contacts & Search
    GoRoute(
      path: AppRoutes.globalSearch,
      builder: (context, state) => const GlobalSearchScreen(),
    ),
    GoRoute(
      path: AppRoutes.userProfile,
      builder: (context, state) {
        final userId = state.pathParameters['userId']!;
        final extra = state.extra as Map<String, dynamic>?;
        return UserProfileScreen(userId: userId, userData: extra);
      },
    ),
    GoRoute(
      path: AppRoutes.qrProfile,
      builder: (context, state) => const QrProfileScreen(),
    ),
    GoRoute(
      path: AppRoutes.qrScanner,
      builder: (context, state) => const QrScannerScreen(),
    ),

    // Groups
    GoRoute(
      path: AppRoutes.createGroup,
      builder: (context, state) => const CreateGroupScreen(),
    ),
    GoRoute(
      path: AppRoutes.groupChat,
      builder: (context, state) {
        final groupId = state.pathParameters['groupId']!;
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return GroupChatScreen(
          groupId: groupId,
          initialTitle: extra['title'] as String?,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.groupDetails,
      builder: (context, state) {
        final groupId = state.pathParameters['groupId']!;
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return GroupDetailsScreen(
          groupId: groupId,
          initialTitle: extra['title'] as String?,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.groupPermissions,
      builder: (context, state) {
        final groupId = state.pathParameters['groupId']!;
        return GroupPermissionsScreen(groupId: groupId);
      },
    ),
    GoRoute(
      path: AppRoutes.groupAdminSettings,
      builder: (context, state) {
        final groupId = state.pathParameters['groupId']!;
        return GroupAdminSettingsScreen(groupId: groupId);
      },
    ),
    GoRoute(
      path: AppRoutes.inviteGroupMembers,
      builder: (context, state) {
        final groupId = state.pathParameters['groupId']!;
        return InviteMembersScreen(groupId: groupId);
      },
    ),

    // Channels
    GoRoute(
      path: AppRoutes.createChannel,
      builder: (context, state) => const CreateChannelScreen(),
    ),
    GoRoute(
      path: AppRoutes.channelFeed,
      builder: (context, state) {
        final channelId = state.pathParameters['channelId']!;
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return ChannelFeedScreen(
          channelId: channelId,
          initialTitle: extra['title'] as String?,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.channelDetails,
      builder: (context, state) {
        final channelId = state.pathParameters['channelId']!;
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return ChannelDetailsScreen(
          channelId: channelId,
          initialTitle: extra['title'] as String?,
        );
      },
    ),

    // Communities
    GoRoute(
      path: AppRoutes.createCommunity,
      builder: (context, state) => const CreateCommunityScreen(),
    ),
    GoRoute(
      path: AppRoutes.communityHome,
      builder: (context, state) {
        final communityId = state.pathParameters['communityId']!;
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return CommunityHomeScreen(
          communityId: communityId,
          initialTitle: extra['title'] as String?,
        );
      },
    ),

    // Status / Stories
    GoRoute(
      path: AppRoutes.statusComposer,
      builder: (context, state) => const StatusComposerScreen(),
    ),
    GoRoute(
      path: AppRoutes.statusViewer,
      builder: (context, state) {
        final status = state.extra as StatusModel?;
        return StatusViewerScreen(status: status);
      },
    ),
    GoRoute(
      path: AppRoutes.statusPrivacy,
      builder: (context, state) => const StatusPrivacyScreen(),
    ),

    // Calls
    GoRoute(
      path: AppRoutes.voiceCall,
      builder: (context, state) {
        final callId = state.pathParameters['callId']!;
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return VoiceCallScreen(
          callId: callId,
          callerName: extra['callerName'] as String?,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.videoCall,
      builder: (context, state) {
        final callId = state.pathParameters['callId']!;
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return VideoCallScreen(
          callId: callId,
          callerName: extra['callerName'] as String?,
        );
      },
    ),

    // Settings
    GoRoute(
      path: AppRoutes.accountSettings,
      builder: (context, state) => const AccountSettingsScreen(),
    ),
    GoRoute(
      path: AppRoutes.editProfile,
      builder: (context, state) => const EditProfileScreen(),
    ),
    GoRoute(
      path: AppRoutes.privacySettings,
      builder: (context, state) => const PrivacySettingsScreen(),
    ),
    GoRoute(
      path: AppRoutes.blockedUsers,
      builder: (context, state) => const BlockedUsersScreen(),
    ),
    GoRoute(
      path: AppRoutes.securitySettings,
      builder: (context, state) => const SecuritySettingsScreen(),
    ),
    GoRoute(
      path: AppRoutes.notificationsSettings,
      builder: (context, state) => const NotificationsSettingsScreen(),
    ),
    GoRoute(
      path: AppRoutes.chatSettings,
      builder: (context, state) => const ChatSettingsScreen(),
    ),
    GoRoute(
      path: AppRoutes.appearanceSettings,
      builder: (context, state) => const AppearanceScreen(),
    ),
    GoRoute(
      path: AppRoutes.storageSettings,
      builder: (context, state) => const StorageDataScreen(),
    ),
    GoRoute(
      path: AppRoutes.devicesSettings,
      builder: (context, state) => const DevicesScreen(),
    ),
    GoRoute(
      path: AppRoutes.help,
      builder: (context, state) => const HelpScreen(),
    ),
    GoRoute(
      path: AppRoutes.about,
      builder: (context, state) => const AboutScreen(),
    ),
    GoRoute(
      path: AppRoutes.deleteAccount,
      builder: (context, state) => const DeleteAccountScreen(),
    ),
  ],
);
