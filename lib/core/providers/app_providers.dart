import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/calls/data/call_repository.dart';
import '../../features/channels/data/channel_repository.dart';
import '../../features/chats/data/chat_repository.dart';
import '../../features/communities/data/community_repository.dart';
import '../../features/groups/data/group_repository.dart';
import '../../features/profile/data/user_repository.dart';
import '../../features/profile/domain/models/user_profile.dart';
import '../../features/status/data/status_repository.dart';
import '../services/firebase_service.dart';
import '../services/local_preferences_service.dart';
import '../services/storage_service.dart';
import '../services/webrtc_service.dart';

// Services
final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService.instance;
});

final localPreferencesServiceProvider =
    Provider<LocalPreferencesService>((ref) {
  throw UnimplementedError(
      'localPreferencesServiceProvider must be initialized in main()');
});

final storageServiceProvider = Provider<StorageService>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return StorageService(firebaseService);
});

final webrtcServiceProvider = Provider<WebRtcService>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return WebRtcService(firebaseService);
});

// Repositories
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return FirebaseAuthRepository(firebaseService);
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return FirestoreUserRepository(firebaseService);
});

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return FirestoreChatRepository(firebaseService);
});

final groupRepositoryProvider = Provider<GroupRepository>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return FirestoreGroupRepository(firebaseService);
});

final channelRepositoryProvider = Provider<ChannelRepository>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return FirestoreChannelRepository(firebaseService);
});

final communityRepositoryProvider = Provider<CommunityRepository>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return FirestoreCommunityRepository(firebaseService);
});

final statusRepositoryProvider = Provider<StatusRepository>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return FirestoreStatusRepository(firebaseService);
});

final callRepositoryProvider = Provider<CallRepository>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return FirestoreCallRepository(firebaseService);
});

// Auth & User State
final authStateProvider = StreamProvider<String?>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return authRepo.authStateChanges;
});

final currentUserIdProvider = Provider<String?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.value ?? ref.watch(authRepositoryProvider).currentUserId;
});

final currentUserProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return null;
  final userRepo = ref.watch(userRepositoryProvider);
  return await userRepo.getUserProfile(uid);
});

// Theme Mode Notifier
class ThemeNotifier extends StateNotifier<ThemeMode> {
  final LocalPreferencesService _prefs;

  ThemeNotifier(this._prefs) : super(ThemeMode.system) {
    _loadTheme();
  }

  void _loadTheme() {
    final theme = _prefs.getThemePreference();
    if (theme == 'light') {
      state = ThemeMode.light;
    } else if (theme == 'dark') {
      state = ThemeMode.dark;
    } else {
      state = ThemeMode.system;
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    final str = mode == ThemeMode.light
        ? 'light'
        : mode == ThemeMode.dark
            ? 'dark'
            : 'system';
    await _prefs.setThemePreference(str);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  final prefs = ref.watch(localPreferencesServiceProvider);
  return ThemeNotifier(prefs);
});
