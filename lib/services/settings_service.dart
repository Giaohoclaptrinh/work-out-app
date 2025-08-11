import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/debug_helper.dart';

class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Default settings
  static const Map<String, dynamic> _defaultSettings = {
    'darkMode': false,
    'pushNotifications': true,
    'workoutReminders': true,
    'mealReminders': true,
    'soundEffects': true,
    'hapticFeedback': true,
    'autoSync': true,
    'showTips': true,
    'fontSize': 16.0,
    'language': 'Tiếng Việt',
    'units': 'Metric',
    'workoutDifficulty': 'Intermediate',
  };

  /// Get current user settings
  Future<Map<String, dynamic>> getSettings() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return _defaultSettings;

      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('settings')
          .doc('app_settings')
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        // Merge with defaults to ensure all keys exist
        return {..._defaultSettings, ...data};
      }

      // Create default settings if not exists
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('settings')
          .doc('app_settings')
          .set(_defaultSettings);

      return _defaultSettings;
    } catch (e) {
      DebugHelper.logError('Error getting settings: $e');
      return _defaultSettings;
    }
  }

  /// Update specific settings
  Future<void> updateSettings(Map<String, dynamic> settingsPatch) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Normalize values
      final normalizedPatch = _normalizeSettings(settingsPatch);

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('settings')
          .doc('app_settings')
          .set(normalizedPatch, SetOptions(merge: true));

      DebugHelper.logCache('Settings updated: $normalizedPatch');
    } catch (e) {
      DebugHelper.logError('Error updating settings: $e');
    }
  }

  /// Update single setting
  Future<void> updateSetting(String key, dynamic value) async {
    await updateSettings({key: value});
  }

  /// Get specific setting value
  Future<T?> getSetting<T>(String key, {T? defaultValue}) async {
    final settings = await getSettings();
    return settings[key] as T? ?? defaultValue;
  }

  /// Check if setting is enabled
  Future<bool> isEnabled(String key) async {
    final value = await getSetting<bool>(key);
    return value ?? false;
  }

  /// Normalize settings values
  Map<String, dynamic> _normalizeSettings(Map<String, dynamic> settings) {
    final normalized = <String, dynamic>{};

    for (final entry in settings.entries) {
      final key = entry.key;
      final value = entry.value;

      switch (key) {
        case 'darkMode':
        case 'pushNotifications':
        case 'workoutReminders':
        case 'mealReminders':
        case 'soundEffects':
        case 'hapticFeedback':
        case 'autoSync':
        case 'showTips':
          normalized[key] = _normalizeBool(value);
          break;

        case 'fontSize':
          normalized[key] = _normalizeFontSize(value);
          break;

        case 'language':
          normalized[key] = _normalizeLanguage(value);
          break;

        case 'units':
          normalized[key] = _normalizeUnits(value);
          break;

        case 'workoutDifficulty':
          normalized[key] = _normalizeDifficulty(value);
          break;
      }
    }

    return normalized;
  }

  bool _normalizeBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) {
      final lower = value.toLowerCase();
      return lower.contains('on') ||
          lower.contains('enable') ||
          lower.contains('true') ||
          lower.contains('bật');
    }
    return false;
  }

  double _normalizeFontSize(dynamic value) {
    if (value is num) {
      final size = value.toDouble();
      return size.clamp(12.0, 24.0);
    }
    if (value is String) {
      final size = double.tryParse(value);
      if (size != null) {
        return size.clamp(12.0, 24.0);
      }
    }
    return 16.0;
  }

  String _normalizeLanguage(dynamic value) {
    if (value is String) {
      final lower = value.toLowerCase();
      if (lower.contains('vi') || lower.contains('vietnamese')) {
        return 'Tiếng Việt';
      }
      if (lower.contains('en') || lower.contains('english')) {
        return 'English';
      }
      if (lower.contains('es') || lower.contains('spanish')) {
        return 'Español';
      }
      if (lower.contains('fr') || lower.contains('french')) {
        return 'Français';
      }
      if (lower.contains('zh') || lower.contains('chinese')) {
        return '中文';
      }
      if (lower.contains('ja') || lower.contains('japanese')) {
        return '日本語';
      }
    }
    return 'Tiếng Việt';
  }

  String _normalizeUnits(dynamic value) {
    if (value is String) {
      final lower = value.toLowerCase();
      if (lower.contains('metric') ||
          lower.contains('kg') ||
          lower.contains('cm')) {
        return 'Metric';
      }
      if (lower.contains('imperial') ||
          lower.contains('lbs') ||
          lower.contains('ft')) {
        return 'Imperial';
      }
    }
    return 'Metric';
  }

  String _normalizeDifficulty(dynamic value) {
    if (value is String) {
      final lower = value.toLowerCase();
      if (lower.contains('beginner')) return 'Beginner';
      if (lower.contains('intermediate')) return 'Intermediate';
      if (lower.contains('advanced')) return 'Advanced';
      if (lower.contains('expert')) return 'Expert';
    }
    return 'Intermediate';
  }

  /// Reset settings to defaults
  Future<void> resetToDefaults() async {
    await updateSettings(_defaultSettings);
  }

  /// Get all available languages
  List<String> getAvailableLanguages() {
    return ['Tiếng Việt', 'English', 'Español', 'Français', '中文', '日本語'];
  }

  /// Get all available units
  List<String> getAvailableUnits() {
    return ['Metric', 'Imperial'];
  }

  /// Get all available difficulties
  List<String> getAvailableDifficulties() {
    return ['Beginner', 'Intermediate', 'Advanced', 'Expert'];
  }
}
