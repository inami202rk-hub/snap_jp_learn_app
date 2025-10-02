import 'package:flutter/foundation.dart';
import '../data/settings_repository.dart';

class SettingsService extends ChangeNotifier {
  final SettingsRepository _repository = SettingsRepository();
  
  bool _srsPreviewEnabled = true;
  bool get srsPreviewEnabled => _srsPreviewEnabled;

  Future<void> initialize() async {
    _srsPreviewEnabled = await _repository.getSrsPreviewEnabled();
    notifyListeners();
  }

  Future<void> setSrsPreviewEnabled(bool enabled) async {
    if (_srsPreviewEnabled != enabled) {
      _srsPreviewEnabled = enabled;
      await _repository.setSrsPreviewEnabled(enabled);
      notifyListeners();
    }
  }
}
