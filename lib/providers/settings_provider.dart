import 'package:flutter/material.dart';
import '../services/settings_service.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsService _settingsService = SettingsService();
  Map<String, dynamic> _settings = {};
  bool _isLoading = true;

  Map<String, dynamic> get settings => _settings;
  bool get isLoading => _isLoading;

  // Convenience getters
  bool get isDarkMode => _settings['darkMode'] ?? false;
  double get fontSize => _settings['fontSize'] ?? 16.0;
  String get language => _settings['language'] ?? 'Tiếng Việt';
  String get units => _settings['units'] ?? 'Metric';
  String get workoutDifficulty =>
      _settings['workoutDifficulty'] ?? 'Intermediate';
  bool get pushNotifications => _settings['pushNotifications'] ?? true;
  bool get workoutReminders => _settings['workoutReminders'] ?? true;
  bool get mealReminders => _settings['mealReminders'] ?? true;
  bool get soundEffects => _settings['soundEffects'] ?? true;
  bool get hapticFeedback => _settings['hapticFeedback'] ?? true;
  bool get autoSync => _settings['autoSync'] ?? true;
  bool get showTips => _settings['showTips'] ?? true;

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> loadSettings() async {
    try {
      setState(() => _isLoading = true);
      final settings = await _settingsService.getSettings();
      setState(() {
        _settings = settings;
        _isLoading = false;
      });
    } catch (e) {
      // If loading fails, use default settings
      setState(() {
        _settings = _getDefaultSettings();
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic> _getDefaultSettings() {
    return {
      'darkMode': false,
      'fontSize': 16.0,
      'language': 'Tiếng Việt',
      'units': 'Metric',
      'workoutDifficulty': 'Intermediate',
      'pushNotifications': true,
      'workoutReminders': true,
      'mealReminders': true,
      'soundEffects': true,
      'hapticFeedback': true,
      'autoSync': true,
      'showTips': true,
    };
  }

  Future<void> updateSetting(String key, dynamic value) async {
    try {
      await _settingsService.updateSetting(key, value);
      _settings[key] = value;
      notifyListeners();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> updateSettings(Map<String, dynamic> settingsPatch) async {
    try {
      await _settingsService.updateSettings(settingsPatch);
      _settings.addAll(settingsPatch);
      notifyListeners();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> resetToDefaults() async {
    try {
      await _settingsService.resetToDefaults();
      await loadSettings();
    } catch (e) {
      // Handle error
    }
  }

  void setState(VoidCallback fn) {
    fn();
    notifyListeners();
  }

  // Helper methods for specific settings
  Future<void> toggleDarkMode() async {
    await updateSetting('darkMode', !isDarkMode);
  }

  Future<void> setFontSize(double size) async {
    await updateSetting('fontSize', size.clamp(12.0, 24.0));
  }

  Future<void> setLanguage(String lang) async {
    await updateSetting('language', lang);
  }

  Future<void> setUnits(String unit) async {
    await updateSetting('units', unit);
  }

  Future<void> setWorkoutDifficulty(String difficulty) async {
    await updateSetting('workoutDifficulty', difficulty);
  }

  Future<void> togglePushNotifications() async {
    await updateSetting('pushNotifications', !pushNotifications);
  }

  Future<void> toggleWorkoutReminders() async {
    await updateSetting('workoutReminders', !workoutReminders);
  }

  Future<void> toggleMealReminders() async {
    await updateSetting('mealReminders', !mealReminders);
  }

  Future<void> toggleSoundEffects() async {
    await updateSetting('soundEffects', !soundEffects);
  }

  Future<void> toggleHapticFeedback() async {
    await updateSetting('hapticFeedback', !hapticFeedback);
  }

  Future<void> toggleAutoSync() async {
    await updateSetting('autoSync', !autoSync);
  }

  Future<void> toggleShowTips() async {
    await updateSetting('showTips', !showTips);
  }
}
