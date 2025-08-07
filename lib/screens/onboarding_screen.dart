import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../services/onboarding_service.dart';
import '../common/color_extension.dart';
import '../views/body_data_input_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: "Welcome to Fitness Tracker",
      subtitle: "Your Personal Journey Begins",
      description:
          "Transform your fitness journey with our comprehensive workout tracking and personalized recommendations",
      icon: Icons.fitness_center,
      gradient: [Color(0xFF667eea), Color(0xFF764ba2)],
      image: "assets/img/Workout1.png",
    ),
    OnboardingPage(
      title: "Track Your Progress",
      subtitle: "See Your Growth",
      description:
          "Monitor your workouts, set achievable goals, and watch your improvement over time with detailed analytics",
      icon: Icons.trending_up,
      gradient: [Color(0xFFf093fb), Color(0xFFf5576c)],
      image: "assets/img/Workout2.png",
    ),
    OnboardingPage(
      title: "Stay Motivated",
      subtitle: "Achieve Your Dreams",
      description:
          "Get personalized recommendations, celebrate milestones, and stay consistent with your fitness journey",
      icon: Icons.emoji_events,
      gradient: [Color(0xFF4facfe), Color(0xFF00f2fe)],
      image: "assets/img/Workout3.png",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  void _completeOnboarding() async {
    context.read<OnboardingService>().completeOnboarding();

    // Save onboarding status to Firestore
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .update({'hasSeenOnboarding': true});
      } catch (e) {
        print('Error saving onboarding status: $e');
      }
    }

    // Navigate to body data input
    if (currentUser != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => BodyDataInputScreen(uid: currentUser.uid),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.grey.shade50],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Logo or app name
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: TColor.primaryG),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.fitness_center,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'FitTracker',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    if (_currentPage < _pages.length - 1)
                      TextButton(
                        onPressed: _skipOnboarding,
                        child: Text(
                          'Skip',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Page content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                    _animationController.reset();
                    _animationController.forward();
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 20),

                              // Image with gradient overlay
                              Container(
                                width: 260,
                                height: 260,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: page.gradient,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: page.gradient[0].withOpacity(0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    // Background pattern
                                    Positioned.fill(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            24,
                                          ),
                                          color: Colors.white.withOpacity(0.1),
                                        ),
                                      ),
                                    ),
                                    // Icon
                                    Center(
                                      child: Icon(
                                        page.icon,
                                        size: 70,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 32),

                              // Title
                              Text(
                                page.title,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins',
                                  color: Colors.black87,
                                  height: 1.2,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              const SizedBox(height: 8),

                              // Subtitle
                              Text(
                                page.subtitle,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Poppins',
                                  color: page.gradient[0],
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              const SizedBox(height: 16),

                              // Description
                              Text(
                                page.description,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'Poppins',
                                  color: Colors.grey[600],
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Page indicator and navigation
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    // Page indicator
                    SmoothPageIndicator(
                      controller: _pageController,
                      count: _pages.length,
                      effect: WormEffect(
                        dotColor: Colors.grey[300]!,
                        activeDotColor: _pages[_currentPage].gradient[0],
                        dotHeight: 10,
                        dotWidth: 10,
                        spacing: 12,
                        strokeWidth: 2,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Next/Get Started button
                    Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _pages[_currentPage].gradient,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: _pages[_currentPage].gradient[0].withOpacity(
                              0.3,
                            ),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _nextPage,
                          borderRadius: BorderRadius.circular(16),
                          child: Center(
                            child: Text(
                              _currentPage == _pages.length - 1
                                  ? 'Get Started'
                                  : 'Next',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final List<Color> gradient;
  final String image;

  OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.gradient,
    required this.image,
  });
}
