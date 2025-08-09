import 'package:flutter/foundation.dart';

class DebugHelper {
  static void log(String message) {
    if (kDebugMode) {
      print(message);
    }
  }

  static void logError(String error) {
    if (kDebugMode) {
      print('❌ $error');
    }
  }

  static void logSuccess(String message) {
    if (kDebugMode) {
      print('✅ $message');
    }
  }

  static void logInfo(String message) {
    if (kDebugMode) {
      print('ℹ️ $message');
    }
  }

  static void logCache(String message) {
    if (kDebugMode) {
      print('📦 $message');
    }
  }

  static void logPerformance(String message) {
    if (kDebugMode) {
      print('⚡ $message');
    }
  }
}
