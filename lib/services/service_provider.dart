import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'user_profile_service.dart';
import 'workout_service.dart';
import 'exercise_service.dart';
import 'storage_service.dart';
import 'onboarding_service.dart';

class ServiceProvider extends ChangeNotifier {
  late final AuthService authService;
  late final UserProfileService userProfileService;
  late final WorkoutService workoutService;
  late final ExerciseService exerciseService;
  late final StorageService storageService;
  late final OnboardingService onboardingService;

  ServiceProvider() {
    authService = AuthService();
    userProfileService = UserProfileService();
    workoutService = WorkoutService();
    exerciseService = ExerciseService();
    storageService = StorageService();
    onboardingService = OnboardingService();
  }

  // Initialize all services
  Future<void> initialize() async {
    // Add any initialization logic here
    notifyListeners();
  }

  // Dispose all services
  @override
  void dispose() {
    authService.dispose();
    super.dispose();
  }
}

// Provider setup helper
class AppProviders {
  static List<ChangeNotifierProvider> getProviders() {
    return [
      ChangeNotifierProvider<ServiceProvider>(create: (_) => ServiceProvider()),
      ChangeNotifierProvider<AuthService>(
        create: (context) => context.read<ServiceProvider>().authService,
      ),
      ChangeNotifierProvider<UserProfileService>(
        create: (context) => context.read<ServiceProvider>().userProfileService,
      ),
      ChangeNotifierProvider<OnboardingService>(
        create: (context) => context.read<ServiceProvider>().onboardingService,
      ),
    ];
  }
}
