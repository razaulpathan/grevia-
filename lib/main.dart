import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/providers/app_providers.dart';
import 'core/routing/app_router.dart';
import 'core/services/firebase_service.dart';
import 'core/services/local_preferences_service.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (safely handles environments with/without native google-services.json)
  await FirebaseService.instance.initialize();

  // Initialize Local Preferences
  final localPreferences = await LocalPreferencesService.create();

  runApp(
    ProviderScope(
      overrides: [
        localPreferencesServiceProvider.overrideWithValue(localPreferences),
      ],
      child: const GreviaApp(),
    ),
  );
}

class GreviaApp extends ConsumerWidget {
  const GreviaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'Grevia',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: appRouter,
    );
  }
}
