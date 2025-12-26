import 'package:signals/signals.dart';
import '../util/shared_preference_util.dart';

class SettingViewModel {
  final apiKey = signal<String?>(null);
  final nsfwEnabled = signal(false);
  final themeMode = signal(0); // 0=system, 1=light, 2=dark

  Future<void> initSignals() async {
    final prefs = SharedPreferenceUtil.instance;
    apiKey.value = prefs.apiKey;
    nsfwEnabled.value = prefs.nsfwEnabled;
    themeMode.value = prefs.themeMode;
  }

  Future<void> setApiKey(String? value) async {
    apiKey.value = value;
    await SharedPreferenceUtil.instance.setApiKey(value);
  }

  Future<void> setNsfwEnabled(bool value) async {
    nsfwEnabled.value = value;
    await SharedPreferenceUtil.instance.setNsfwEnabled(value);
  }

  Future<void> setThemeMode(int value) async {
    themeMode.value = value;
    await SharedPreferenceUtil.instance.setThemeMode(value);
  }
}
