import 'package:flutter/foundation.dart';

/// Production-safe logging utility
class DebugHelper {
  /// Log general messages (debug mode only)
  static void log(String message) {
    if (kDebugMode) {
      print('📝 $message');
    }
  }

  /// Log error messages (debug mode only)
  static void logError(String error) {
    if (kDebugMode) {
      print('❌ $error');
    }
  }

  /// Log cache-related messages (debug mode only)
  static void logCache(String message) {
    if (kDebugMode) {
      print('📦 $message');
    }
  }

  /// Log performance messages (debug mode only)
  static void logPerformance(String message) {
    if (kDebugMode) {
      print('⚡ $message');
    }
  }
}
