import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingService extends ChangeNotifier {
  static const String _onboardingCompleteKey = 'onboarding_complete';
  bool _isOnboardingComplete = false;
  bool _isLoading = true;

  bool get isOnboardingComplete => _isOnboardingComplete;
  bool get isLoading => _isLoading;

  OnboardingService() {
    _loadOnboardingStatus();
  }

  Future<void> _loadOnboardingStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isOnboardingComplete = prefs.getBool(_onboardingCompleteKey) ?? false;
    } catch (e) {
      _isOnboardingComplete = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> completeOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_onboardingCompleteKey, true);
      _isOnboardingComplete = true;
      notifyListeners();
    } catch (e) {
      // Handle error silently or log it
      debugPrint('Error completing onboarding: $e');
    }
  }

  Future<void> resetOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_onboardingCompleteKey, false);
      _isOnboardingComplete = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error resetting onboarding: $e');
    }
  }
}