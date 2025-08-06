
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

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthService, OnboardingService>(
      builder: (context, authService, onboardingService, child) {
        if (onboardingService.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!onboardingService.isOnboardingComplete) {
          return const OnboardingScreen();
        }

        if (authService.isAuthenticated) {
          final uid = authService.currentUser?.uid;
          if (uid == null) return const AuthScreen();

          // Kiểm tra xem đã có dữ liệu cơ thể chưa
          return FutureBuilder<bool>(
            future: _checkBodyData(uid),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.data == false) {
                return BodyDataInputScreen(uid: uid);
              } else {
                return const MainTabView();
              }
            },
          );
        }

        return const AuthScreen();
      },
    );
  }
}
