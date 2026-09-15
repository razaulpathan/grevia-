import 'package:shared_preferences/shared_preferences.dart';

class LocalPreferencesService {
  final SharedPreferences _prefs;

  LocalPreferencesService(this._prefs);

  static Future<LocalPreferencesService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalPreferencesService(prefs);
  }

  static const String _keyTheme = 'grevia_theme';
  static const String _keyDraftPrefix = 'grevia_draft_';
  static const String _keyFirstLaunch = 'grevia_first_launch';
  static const String _keyCachedUserId = 'grevia_cached_user_id';

  String getThemePreference() => _prefs.getString(_keyTheme) ?? 'system';
  Future<bool> setThemePreference(String theme) =>
      _prefs.setString(_keyTheme, theme);

  String getDraft(String chatId) =>
      _prefs.getString('$_keyDraftPrefix$chatId') ?? '';
  Future<bool> setDraft(String chatId, String draft) =>
      _prefs.setString('$_keyDraftPrefix$chatId', draft);
  Future<bool> clearDraft(String chatId) =>
      _prefs.remove('$_keyDraftPrefix$chatId');

  bool isFirstLaunch() => _prefs.getBool(_keyFirstLaunch) ?? true;
  Future<bool> setFirstLaunchComplete() =>
      _prefs.setBool(_keyFirstLaunch, false);

  String? getCachedUserId() => _prefs.getString(_keyCachedUserId);
  Future<bool> setCachedUserId(String? uid) => uid != null
      ? _prefs.setString(_keyCachedUserId, uid)
      : _prefs.remove(_keyCachedUserId);
}
