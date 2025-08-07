import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/onboarding_service.dart';
import '../screens/auth_screen.dart';
import '../screens/onboarding_screen.dart';
import '../views/body_data_input_screen.dart';
import '../views/main_tab/main_tab_view.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  Future<bool> _checkBodyData(String uid) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    if (doc.exists) {
      return doc.data()?['hasBodyData'] == true;
    }
    return false;
  }

  Future<bool> _checkOnboardingStatus(String uid) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    if (doc.exists) {
      // Only check onboarding for users who have the hasSeenOnboarding field
      // If the field doesn't exist, assume they've seen it (existing users)
      return doc.data()?['hasSeenOnboarding'] ?? true;
    }
    return true; // Default to true for existing users
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthService, OnboardingService>(
      builder: (context, authService, onboardingService, child) {
        if (onboardingService.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Check if user is authenticated
        if (authService.isAuthenticated) {
          final uid = authService.currentUser?.uid;
          if (uid == null) return const AuthScreen();

          // For authenticated users, check onboarding and body data
          return FutureBuilder<Map<String, bool>>(
            future:
                Future.wait([
                  _checkOnboardingStatus(uid),
                  _checkBodyData(uid),
                ]).then(
                  (results) => {
                    'hasSeenOnboarding': results[0],
                    'hasBodyData': results[1],
                  },
                ),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              final data = snapshot.data!;

              // If user hasn't seen onboarding, show it first
              if (!data['hasSeenOnboarding']!) {
                return const OnboardingScreen();
              }

              // If user hasn't completed body data, show body data input
              if (!data['hasBodyData']!) {
                return BodyDataInputScreen(uid: uid);
              }

              // User has completed both onboarding and body data
              return const MainTabView();
            },
          );
        }

        // For non-authenticated users, check if they need to see onboarding
        if (!onboardingService.isOnboardingComplete) {
          return const OnboardingScreen();
        }

        return const AuthScreen();
      },
    );
  }
}
