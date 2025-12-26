import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceUtil {
  static final SharedPreferenceUtil _instance = SharedPreferenceUtil._internal();
  static SharedPreferenceUtil get instance => _instance;

  late SharedPreferences _prefs;

  SharedPreferenceUtil._internal();

  Future<void> ensureInitialized() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // API Key
  static const _keyApiKey = 'api_key';
  String? get apiKey => _prefs.getString(_keyApiKey);
  Future<void> setApiKey(String? value) async {
    if (value == null) {
      await _prefs.remove(_keyApiKey);
    } else {
      await _prefs.setString(_keyApiKey, value);
    }
  }

  // NSFW toggle
  static const _keyNsfwEnabled = 'nsfw_enabled';
  bool get nsfwEnabled => _prefs.getBool(_keyNsfwEnabled) ?? false;
  Future<void> setNsfwEnabled(bool value) async {
    await _prefs.setBool(_keyNsfwEnabled, value);
  }

  // Theme mode: 0=system, 1=light, 2=dark
  static const _keyThemeMode = 'theme_mode';
  int get themeMode => _prefs.getInt(_keyThemeMode) ?? 0;
  Future<void> setThemeMode(int value) async {
    await _prefs.setInt(_keyThemeMode, value);
  }

  // Default categories: 111=all, 100=general, 010=anime, 001=people
  static const _keyDefaultCategories = 'default_categories';
  String get defaultCategories => _prefs.getString(_keyDefaultCategories) ?? '111';
  Future<void> setDefaultCategories(String value) async {
    await _prefs.setString(_keyDefaultCategories, value);
  }

  // Default purity: 100=sfw, 110=sfw+sketchy, 111=all
  static const _keyDefaultPurity = 'default_purity';
  String get defaultPurity => _prefs.getString(_keyDefaultPurity) ?? '100';
  Future<void> setDefaultPurity(String value) async {
    await _prefs.setString(_keyDefaultPurity, value);
  }
}
