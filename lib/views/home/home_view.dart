import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../common/color_extension.dart';
import '../../services/dashboard_service.dart';
import '../../models/dashboard_data.dart';
import '../../widgets/round_button.dart';
import '../../widgets/workout_row.dart';
import '../../widgets/today_target_cell.dart';
import '../../widgets/latest_activity_row.dart';
import '../../widgets/notification_row.dart';
import '../../widgets/what_train_row.dart';
import '../../widgets/upcoming_workout_row.dart';
import '../../widgets/exercises_row.dart';
import '../../widgets/dashboard_card.dart';
import '../../services/exercise_service.dart';
import '../../services/notification_service.dart';
import '../../screens/bmi_chart_screen.dart';
import '../../utils/debug_helper.dart';
import '../../utils/settings_helper.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with WidgetsBindingObserver {
  final DashboardService _dashboardService = DashboardService();
  final NotificationService _notificationService = NotificationService();
  DashboardData? _dashboardData;
  bool _isLoading = true;
  Map<String, dynamic>? _userData;

  Timer? _refreshTimer;

  // chart demo data
  final List<int> showingTooltipOnSpots = const [21];
  List<FlSpot> get allSpots => const [
    FlSpot(0, 20),
    FlSpot(1, 25),
    FlSpot(2, 40),
    FlSpot(3, 50),
    FlSpot(4, 35),
    FlSpot(5, 40),
    FlSpot(6, 30),
    FlSpot(7, 20),
    FlSpot(8, 25),
    FlSpot(9, 40),
    FlSpot(10, 50),
    FlSpot(11, 35),
    FlSpot(12, 50),
    FlSpot(13, 60),
    FlSpot(14, 40),
    FlSpot(15, 50),
    FlSpot(16, 20),
    FlSpot(17, 25),
    FlSpot(18, 40),
    FlSpot(19, 50),
    FlSpot(20, 35),
    FlSpot(21, 80),
    FlSpot(22, 30),
    FlSpot(23, 20),
    FlSpot(24, 25),
    FlSpot(25, 40),
    FlSpot(26, 50),
    FlSpot(27, 35),
    FlSpot(28, 50),
    FlSpot(29, 60),
    FlSpot(30, 40),
  ];

  // data sources for sections
  List lastWorkoutArr = [];
  List notificationsArr = [];
  List activitiesArr = [];
  List tipsArr = [];
  List upcomingWorkoutArr = [];
  List exercisesArr = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _loadDashboardData(forceRefresh: true);
    _loadUserData();
    _loadRealData();
    _setupRealTimeUpdates();
  }

  void _setupRealTimeUpdates() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      _dashboardService.setupRealTimeUpdates(() {
        if (mounted) _loadDashboardData(forceRefresh: true);
      });
    });
  }

  void _retrySetupRealTimeUpdates() {
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      _dashboardService.setupRealTimeUpdates(() {
        if (mounted) _loadDashboardData(forceRefresh: true);
      });
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && mounted) {
      _loadDashboardData(forceRefresh: true);
      _retrySetupRealTimeUpdates();
    }
  }

  Future<void> _loadUserData() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (!mounted) return;
      setState(() {
        _userData = doc.data();
      });
    } catch (_) {
      // silent
    }
  }

  String _getBMIStatus() {
    if (_userData == null) return 'Calculate your BMI';
    final weight = (_userData!['weight'] as num?)?.toDouble() ?? 70.0;
    final height = (_userData!['height'] as num?)?.toDouble() ?? 170.0;
    if (height <= 0) return 'Enter your height';
    final h = height / 100;
    final bmi = weight / (h * h);

    if (bmi < 18.5) return 'You are underweight';
    if (bmi < 25) return 'You have a normal weight';
    if (bmi < 30) return 'You are overweight';
    if (bmi >= 30) return 'You are obese';
    return 'Calculate your BMI';
  }

  void _showNotificationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Notifications',
          style: TextStyle(color: TColor.black, fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Column(
            children: [
              ElevatedButton(
                onPressed: _addTestNotification,
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColor.primaryColor1,
                ),
                child: const Text(
                  'Add Test Notification',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 10),

              const SizedBox(height: 10),
              Expanded(
                child: notificationsArr.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.notifications_none,
                              size: 64,
                              color: TColor.gray,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No notifications yet',
                              style: TextStyle(
                                color: TColor.gray,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: notificationsArr.length,
                        itemBuilder: (context, index) {
                          final n = notificationsArr[index];
                          final read = n['read'] == true;
                          return ListTile(
                            leading: Icon(
                              read
                                  ? Icons.notifications
                                  : Icons.notifications_active,
                              color: read ? TColor.gray : TColor.primaryColor1,
                            ),
                            title: Text(
                              n['title'] ?? 'Notification',
                              style: TextStyle(
                                fontWeight: read
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(n['message'] ?? ''),
                                const SizedBox(height: 4),
                                Text(
                                  NotificationService.formatTimeAgo(
                                    n['timestamp'],
                                  ),
                                  style: TextStyle(
                                    color: TColor.gray,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              if (!read) _markNotificationAsRead(n['id']);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: TColor.primaryColor1)),
          ),
        ],
      ),
    );
  }

  Future<void> _addTestNotification() async {
    try {
      await _notificationService.addNotification(
        'Welcome!',
        'Thank you for using our fitness app. Start your workout journey today!',
        type: 'welcome',
      );
      await _notificationService.addActivity(
        'Account Created',
        'Your fitness account has been successfully created',
        type: 'account',
      );
      await _loadRealData();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test notification added!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      DebugHelper.logError('Error adding test notification: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // Removed auto-log daily stats feature (button and handler)

  Future<void> _markNotificationAsRead(String notificationId) async {
    await _notificationService.markNotificationAsRead(notificationId);
    await _loadRealData();
  }

  Future<void> _loadDashboardData({bool forceRefresh = false}) async {
    final startTime = DateTime.now();
    try {
      setState(() => _isLoading = true);

      final dashboardData = await _dashboardService
          .getDashboardData(forceRefresh: forceRefresh)
          .timeout(const Duration(seconds: 10));

      if (!mounted) return;
      setState(() {
        _dashboardData = dashboardData;
        _isLoading = false;
      });
    } catch (e) {
      final loadTime = DateTime.now().difference(startTime);
      DebugHelper.logError(
        'Dashboard data failed after ${loadTime.inMilliseconds}ms: $e',
      );

      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _dashboardData = DashboardData(
          userId: '',
          userName: 'User',
          userEmail: '',
          bmi: 0.0,
          totalCaloriesConsumed: 0,
          totalCaloriesBurned: 0,
          netCalories: 0,
          waterIntake: 0.0,
          stepsTaken: 0,
          sleepHours: 0.0,
          healthStatus: 'Good',
          workoutsCompletedToday: 0,
          totalWorkoutsCompleted: 0,
          currentStreak: 0,
          weeklyProgress: {
            'workouts': 0,
            'calories': 0,
            'goal': 5,
            'progress': 0.0,
          },
          lastUpdated: DateTime.now(),
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load dashboard data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadRealData() async {
    try {
      final exerciseService = ExerciseService();
      final tips = await exerciseService.getWorkoutTips();
      final notifications = await _notificationService.getUserNotifications(
        limit: 5,
      );
      final activities = await _notificationService.getUserActivities(limit: 5);

      if (!mounted) return;
      setState(() {
        tipsArr = tips;
        notificationsArr = notifications;
        activitiesArr = activities;
      });
    } catch (_) {
      // silent
    }
  }

  @override
  void dispose() {
    _dashboardService.stopRealTimeUpdates();
    _refreshTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: SettingsHelper.getBackgroundColor(context),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: TColor.primaryColor1),
            )
          : RefreshIndicator(
              onRefresh: () => _loadDashboardData(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: media.width * 0.05),
                        _WelcomeHeader(
                          name: _userData?['displayName'] ?? 'User',
                          onBellPressed: _showNotificationDialog,
                        ),
                        SizedBox(height: media.width * 0.05),

                        _BMICard(
                          media: media,
                          bmiStatus: _getBMIStatus(),
                          onViewMore: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const BMIChartScreen(),
                              ),
                            );
                          },
                          sections: showingSections(),
                        ),

                        SizedBox(height: media.width * 0.05),

                        // TODAY OVERVIEW
                        if (_dashboardData != null)
                          SettingsHelper.createFixedFontTodayOverviewSection(
                            title: "Today's Overview",
                            dashboardCards: [
                              DashboardCard(
                                title: "Calories Consumed",
                                value:
                                    (_dashboardData?.totalCaloriesConsumed ?? 0)
                                        .toString(),
                                unit: "kcal",
                                icon: Icons.local_fire_department,
                                color: TColor.primaryColor1,
                                progress:
                                    (_dashboardData?.totalCaloriesConsumed ??
                                        0) /
                                    2000,
                              ),
                              DashboardCard(
                                title: "Calories Burned",
                                value:
                                    (_dashboardData?.totalCaloriesBurned ?? 0)
                                        .toString(),
                                unit: "kcal",
                                icon: Icons.fitness_center,
                                color: TColor.secondaryColor1,
                                progress:
                                    (_dashboardData?.totalCaloriesBurned ?? 0) /
                                    500,
                              ),
                              DashboardCard(
                                title: "Water Intake",
                                value: (_dashboardData?.waterIntake ?? 0.0)
                                    .toStringAsFixed(1),
                                unit: "ml",
                                icon: Icons.water_drop,
                                color: Colors.blue,
                                progress:
                                    (_dashboardData?.waterIntake ?? 0.0) / 2000,
                              ),
                              DashboardCard(
                                title: "Steps Taken",
                                value: (_dashboardData?.stepsTaken ?? 0)
                                    .toString(),
                                unit: "steps",
                                icon: Icons.directions_walk,
                                color: Colors.green,
                                progress:
                                    (_dashboardData?.stepsTaken ?? 0) / 10000,
                              ),
                            ],
                            onRefresh: () =>
                                _loadDashboardData(forceRefresh: true),
                            context: context,
                          ),

                        const SizedBox(height: 20),

                        // TODAY TARGET (single)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 15,
                          ),
                          decoration: BoxDecoration(
                            color: TColor.primaryColor2.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  "Today Target",
                                  style: TextStyle(
                                    color: TColor.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              SizedBox(
                                width: 70,
                                height: 25,
                                child: RoundButton(
                                  title: "Check",
                                  type: RoundButtonType.bgGradient,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  onPressed: () {},
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: media.width * 0.05),

                        // TODAY'S TARGETS STRIP (single)
                        const _SectionTitle('Today\'s Targets'),
                        const SizedBox(height: 10),
                        const _TargetsStrip(),

                        const SizedBox(height: 20),

                        // ACTIVITY STATUS (single)
                        const _SectionTitle('Activity Status'),
                        const SizedBox(height: 10),
                        _ActivityStatusCard(
                          media: media,
                          allSpots: allSpots,
                          showingTooltipOnSpots: showingTooltipOnSpots,
                        ),

                        SizedBox(height: media.width * 0.05),

                        // SECTIONS — each only once
                        _SectionHeaderWithMore(
                          title: 'Latest Workouts',
                          onMore: () {},
                        ),
                        const SizedBox(height: 10),
                        _SectionList(
                          items: lastWorkoutArr,
                          itemBuilder: (w) => WorkoutRow(wObj: w),
                        ),
                        const SizedBox(height: 20),

                        const _SectionTitle('What to Train'),
                        const SizedBox(height: 10),
                        _SectionList(
                          items: tipsArr,
                          itemBuilder: (tip) => WhatTrainRow(wObj: tip),
                        ),
                        const SizedBox(height: 20),

                        const _SectionTitle('Upcoming Workouts'),
                        const SizedBox(height: 10),
                        _SectionList(
                          items: upcomingWorkoutArr,
                          itemBuilder: (w) => UpcomingWorkoutRow(wObj: w),
                        ),
                        const SizedBox(height: 20),

                        const _SectionTitle('Recent Activities'),
                        const SizedBox(height: 10),
                        _SectionList(
                          items: activitiesArr,
                          itemBuilder: (a) => LatestActivityRow(wObj: a),
                        ),
                        const SizedBox(height: 20),

                        const _SectionTitle('Recent Notifications'),
                        const SizedBox(height: 10),
                        _SectionList(
                          items: notificationsArr,
                          itemBuilder: (n) => NotificationRow(nObj: n),
                        ),
                        const SizedBox(height: 20),

                        const _SectionTitle('Popular Exercises'),
                        const SizedBox(height: 10),
                        _SectionList(
                          items: exercisesArr,
                          itemBuilder: (e) =>
                              ExercisesRow(eObj: e, onPressed: () {}),
                        ),

                        SizedBox(height: media.width * 0.1),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return [
      PieChartSectionData(
        color: TColor.primaryColor1,
        value: 35,
        title: '',
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: TColor.primaryColor2,
        value: 25,
        title: '',
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: TColor.secondaryColor1,
        value: 40,
        title: '',
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ];
  }
}

/* ---------- Reusable UI pieces ---------- */

class _WelcomeHeader extends StatelessWidget {
  final String name;
  final VoidCallback onBellPressed;
  const _WelcomeHeader({required this.name, required this.onBellPressed});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome Back,",
                style: TextStyle(color: TColor.gray, fontSize: 12),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              Text(
                name,
                style: TextStyle(
                  color: TColor.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onBellPressed,
          icon: Image.asset(
            "assets/img/notification_active.png",
            width: 25,
            height: 25,
          ),
        ),
      ],
    );
  }
}

class _BMICard extends StatelessWidget {
  final Size media;
  final String bmiStatus;
  final VoidCallback onViewMore;
  final List<PieChartSectionData> sections;

  const _BMICard({
    super.key,
    required this.media,
    required this.bmiStatus,
    required this.onViewMore,
    required this.sections,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minHeight: media.width * 0.35,
        maxHeight: media.width * 0.45,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: TColor.primaryG),
        borderRadius: BorderRadius.circular(media.width * 0.075),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            "assets/img/bg_dots.png",
            height: media.width * 0.4,
            width: double.maxFinite,
            fit: BoxFit.fitHeight,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: SettingsHelper.createFlexibleColumn(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "BMI (Body Mass Index)",
                        style: TextStyle(
                          color: TColor.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        bmiStatus,
                        style: TextStyle(
                          color: TColor.white.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      SizedBox(height: media.width * 0.02),
                      SizedBox(
                        width: 120,
                        height: 30,
                        child: RoundButton(
                          title: "View More",
                          type: RoundButtonType.bgSGradient,
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          onPressed: onViewMore,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                AspectRatio(
                  aspectRatio: 1,
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(touchCallback: (_, __) {}),
                      startDegreeOffset: 250,
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 1,
                      centerSpaceRadius: 0,
                      sections: sections,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityStatusCard extends StatelessWidget {
  final Size media;
  final List<FlSpot> allSpots;
  final List<int> showingTooltipOnSpots;
  const _ActivityStatusCard({
    required this.media,
    required this.allSpots,
    required this.showingTooltipOnSpots,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: Container(
        height: media.width * 0.4,
        width: double.maxFinite,
        decoration: BoxDecoration(
          color: TColor.primaryColor2.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Stack(
          alignment: Alignment.topLeft,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Heart Rate",
                    style: TextStyle(
                      color: TColor.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (bounds) =>
                        LinearGradient(
                          colors: TColor.primaryG,
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ).createShader(
                          Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                        ),
                    child: Text(
                      "78 BPM",
                      style: TextStyle(
                        color: TColor.white.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            LineChart(
              LineChartData(
                showingTooltipIndicators: showingTooltipOnSpots
                    .map(
                      (index) => ShowingTooltipIndicators([
                        LineBarSpot(
                          LineChartBarData(spots: allSpots),
                          0,
                          allSpots[index],
                        ),
                      ]),
                    )
                    .toList(),
                lineTouchData: LineTouchData(enabled: true),
                lineBarsData: [
                  LineChartBarData(
                    spots: allSpots,
                    isCurved: false,
                    barWidth: 3,
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          TColor.primaryColor2.withValues(alpha: 0.4),
                          TColor.primaryColor1.withValues(alpha: 0.1),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    dotData: FlDotData(show: false),
                    gradient: LinearGradient(colors: TColor.primaryG),
                  ),
                ],
                minY: 0,
                maxY: 130,
                titlesData: FlTitlesData(show: false),
                gridData: FlGridData(show: false),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.transparent),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: TColor.black,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _SectionHeaderWithMore extends StatelessWidget {
  final String title;
  final VoidCallback onMore;
  const _SectionHeaderWithMore({required this.title, required this.onMore});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _SectionTitle(title),
        TextButton(
          onPressed: onMore,
          child: Text(
            "See More",
            style: TextStyle(color: TColor.gray, fontSize: 14),
          ),
        ),
      ],
    );
  }
}

class _TargetsStrip extends StatelessWidget {
  const _TargetsStrip();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        children: const [
          TodayTargetCell(
            icon: "assets/img/burn.png",
            value: "320",
            title: "Calories",
          ),
          SizedBox(width: 15),
          TodayTargetCell(
            icon: "assets/img/bottle.png",
            value: "6.8L",
            title: "Water",
          ),
          SizedBox(width: 15),
          TodayTargetCell(
            icon: "assets/img/bed.png",
            value: "8h 20m",
            title: "Sleep",
          ),
          SizedBox(width: 15),
          TodayTargetCell(
            icon: "assets/img/foot.png",
            value: "2400",
            title: "Steps",
          ),
        ],
      ),
    );
  }
}

class _SectionList<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(T item) itemBuilder;

  const _SectionList({required this.items, required this.itemBuilder});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Text('No data', style: TextStyle(color: TColor.gray));
    }
    return Column(children: items.map((e) => itemBuilder(e)).toList());
  }
}
