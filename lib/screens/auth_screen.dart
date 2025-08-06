import 'package:flutter/material.dart';
import 'package:workout_app/widgets/round_textfield.dart';
import 'package:workout_app/widgets/round_button.dart';
import 'package:workout_app/widgets/setting_row.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              // Email input
              RoundTextField(
                hintText: 'Email',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              // Password input
              RoundTextField(hintText: 'Password', obscureText: true),
              const SizedBox(height: 24),
              // Login button
              RoundButton(
                title: 'Login',
                onPressed: () {
                  // TODO: Add login logic
                },
              ),
              const SizedBox(height: 24),
              // Social login options
              SettingRow(
                icon: 'assets/img/google.png',
                title: 'Login with Google',
                onPressed: () {
                  // TODO: Add Google login logic
                },
              ),
              SettingRow(
                icon: 'assets/img/facebook.png',
                title: 'Login with Facebook',
                onPressed: () {
                  // TODO: Add Facebook login logic
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
