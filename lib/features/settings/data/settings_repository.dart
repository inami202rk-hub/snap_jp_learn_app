import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  static const String _srsPreviewEnabledKey = 'srs_preview_enabled';

  Future<bool> getSrsPreviewEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_srsPreviewEnabledKey) ?? true; // デフォルトはtrue
  }

  Future<void> setSrsPreviewEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_srsPreviewEnabledKey, enabled);
  }
}
