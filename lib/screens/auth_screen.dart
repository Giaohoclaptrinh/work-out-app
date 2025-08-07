import 'package:flutter/material.dart';
import 'package:workout_app/widgets/round_textfield.dart';
import 'package:workout_app/widgets/round_button.dart';
import 'package:workout_app/widgets/setting_row.dart';
import 'package:workout_app/services/auth_service.dart';
import 'package:provider/provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isSignUp = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleAuth() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      if (_isSignUp) {
        await authService.signUpWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đăng ký thành công!')),
          );
        }
      } else {
        await authService.signInWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đăng nhập thành công!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

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
              
              // Title
              Text(
                _isSignUp ? 'Đăng Ký' : 'Đăng Nhập',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              
              // Email input
              RoundTextField(
                controller: _emailController,
                hintText: 'Email',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              
              // Password input
              RoundTextField(
                controller: _passwordController,
                hintText: 'Password',
                obscureText: true,
              ),
              const SizedBox(height: 24),
              
              // Login/Signup button
              RoundButton(
                title: _isLoading 
                  ? 'Đang xử lý...' 
                  : (_isSignUp ? 'Đăng Ký' : 'Đăng Nhập'),
                onPressed: _isLoading ? () {} : () => _handleAuth(),
              ),
              const SizedBox(height: 16),
              
              // Toggle between login and signup
              TextButton(
                onPressed: () {
                  setState(() {
                    _isSignUp = !_isSignUp;
                  });
                },
                child: Text(
                  _isSignUp 
                    ? 'Đã có tài khoản? Đăng nhập' 
                    : 'Chưa có tài khoản? Đăng ký',
                ),
              ),
              const SizedBox(height: 24),
              
              // Social login options
              SettingRow(
                icon: 'assets/img/google.png',
                title: 'Login with Google',
                onPressed: () {
                  // TODO: Add Google login logic
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tính năng đang phát triển')),
                  );
                },
              ),
              SettingRow(
                icon: 'assets/img/facebook.png',
                title: 'Login with Facebook',
                onPressed: () {
                  // TODO: Add Facebook login logic
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tính năng đang phát triển')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
