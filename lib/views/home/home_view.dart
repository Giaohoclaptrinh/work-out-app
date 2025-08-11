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
import '../../services/workout_service.dart';
import '../../services/notification_service.dart';
import '../../services/exercise_service.dart';
import '../../screens/bmi_chart_screen.dart';
import '../../utils/debug_helper.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with WidgetsBindingObserver {
  final DashboardService _dashboardService = DashboardService();
  final NotificationService _notificationService = NotificationService();
  final NotificationService _notificationService = NotificationService();
  DashboardData? _dashboardData;
  bool _isLoading = true;
  Map<String, dynamic>? _userData;

  // Timer for periodic refresh
  Timer? _refreshTimer;

  List<int> showingTooltipOnSpots = [21];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Force refresh once when entering HomeView to ensure up-to-date data
    _loadDashboardData(forceRefresh: true);
    _loadUserData();
    _loadRealData();

    // Setup real-time updates after a short delay to ensure Firebase is ready
    _setupRealTimeUpdates();
  }

  void _setupRealTimeUpdates() {
    // Delay setup to ensure Firebase connection is stable
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _dashboardService.setupRealTimeUpdates(() {
          if (mounted) {
            setState(() {
              _loadDashboardData(forceRefresh: true);
            });
          }
        });
      }
    });
  }

  void _retrySetupRealTimeUpdates() {
    // Retry setup if initial setup failed
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _dashboardService.setupRealTimeUpdates(() {
          if (mounted) {
            setState(() {
              _loadDashboardData(forceRefresh: true);
            });
          }
        });
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Refresh data when app comes back to foreground
    if (state == AppLifecycleState.resumed && mounted) {
      setState(() {
        _loadDashboardData(forceRefresh: true);
      });
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

      if (mounted) {
        setState(() {
          _userData = doc.data();
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  String _getBMIStatus() {
    if (_userData == null) return 'Calculate your BMI';

    final weight = _userData!['weight']?.toDouble() ?? 70.0;
    final height = _userData!['height']?.toDouble() ?? 170.0;

    if (height <= 0) return 'Enter your height';

    final heightInMeters = height / 100;
    final bmi = weight / (heightInMeters * heightInMeters);

    if (bmi < 18.5) return 'You are underweight';
    if (bmi >= 18.5 && bmi < 25) return 'You have a normal weight';
    if (bmi >= 25 && bmi < 30) return 'You are overweight';
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
              // Add notification button for testing
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

              // Notifications list
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
                          final notification = notificationsArr[index];
                          return ListTile(
                            leading: Icon(
                              notification['read'] == true
                                  ? Icons.notifications
                                  : Icons.notifications_active,
                              color: notification['read'] == true
                                  ? TColor.gray
                                  : TColor.primaryColor1,
                            ),
                            title: Text(
                              notification['title'] ?? 'Notification',
                              style: TextStyle(
                                fontWeight: notification['read'] == true
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(notification['message'] ?? ''),
                                const SizedBox(height: 4),
                                Text(
                                  NotificationService.formatTimeAgo(
                                    notification['timestamp'],
                                  ),
                                  style: TextStyle(
                                    color: TColor.gray,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              if (notification['read'] != true) {
                                _markNotificationAsRead(notification['id']);
                              }
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

    // Reload notifications
    await _loadRealData();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Test notifications added!'),
          backgroundColor: TColor.primaryColor1,
        ),
      );
    }
  }

  Future<void> _refreshDashboard() async {
    try {
      // Force refresh dashboard data
      await _loadDashboardData(forceRefresh: true);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Dashboard refreshed!'),
            backgroundColor: TColor.primaryColor1,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      DebugHelper.logError('Error refreshing dashboard: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Refresh failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _testRealTimeUpdate() async {
    try {
      // Complete a test workout to trigger real-time update
      final exerciseService = ExerciseService();
      final workouts = await exerciseService.getAllWorkouts();

      if (workouts.isNotEmpty) {
        final testWorkout = workouts.first;
        await exerciseService.completeWorkout(testWorkout.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Test workout completed! Dashboard should update automatically.',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      DebugHelper.logError('Error testing real-time update: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Test failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _testCacheInvalidation() async {
    try {
      // Manually trigger cache invalidation
      _dashboardService.testCacheInvalidation();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Cache invalidation test triggered! Check console for logs.',
            ),
            backgroundColor: Colors.blue,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      DebugHelper.logError('Error testing cache invalidation: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Test failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _forceRefreshDashboard() async {
    try {
      // Force clear all cache and refresh
      _dashboardService.forceClearAllCache();
      await _loadDashboardData(forceRefresh: true);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Dashboard force refreshed!'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      DebugHelper.logError('Error force refreshing dashboard: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Force refresh failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _checkDashboardData() async {
    try {
      if (_dashboardData != null) {
        print('📊 Current Dashboard Data:');
        print(
          '  - Workouts Completed Today: ${_dashboardData!.workoutsCompletedToday}',
        );
        print(
          '  - Total Workouts Completed: ${_dashboardData!.totalWorkoutsCompleted}',
        );
        print('  - Calories Burned: ${_dashboardData!.totalCaloriesBurned}');
        print(
          '  - Last Updated: ${_dashboardData!.lastUpdated.toIso8601String()}',
        );
      } else {
        print('📊 Dashboard Data: NULL');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Dashboard data logged to console'),
            backgroundColor: Colors.purple,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      DebugHelper.logError('Error checking dashboard data: $e');
    }
  }

  Future<void> _explainCacheStrategy() async {
    try {
      print('📚 Cache Strategy Explanation:');
      print('');
      print('🔄 WHY Cache Clear vs Smart Cache:');
      print('  ❌ Cache Clear: Xóa hết data → Fetch lại → Chậm');
      print('  ✅ Smart Cache: Mark stale → Fetch khi cần → Nhanh');
      print('');
      print('📊 Cache States:');
      print('  🟢 FRESH: Data mới, dùng ngay');
      print('  🟡 STALE: Data cũ, cần fetch mới');
      print('  🔴 EXPIRED: Data quá hạn, phải fetch');
      print('');
      print('⚡ Performance:');
      print('  - Cache Clear: 200-500ms (fetch lại hết)');
      print('  - Smart Cache: 50-100ms (chỉ fetch stale data)');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Cache strategy explained in console'),
            backgroundColor: Colors.teal,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      DebugHelper.logError('Error explaining cache strategy: $e');
    }
  }

  Future<void> _testDirectFirestoreFetch() async {
    try {
      print('🔥 Testing Direct Firestore Fetch:');

      // Fetch directly from Firestore
      final snapshot = await FirebaseFirestore.instance
          .collection('exercises')
          .where('type', isEqualTo: 'workout')
          .get();

      print('📊 Direct Firestore Results:');
      print('  - Total documents: ${snapshot.docs.length}');

      for (int i = 0; i < snapshot.docs.length; i++) {
        final doc = snapshot.docs[i];
        final data = doc.data();
        print('  - Document ${i + 1}: ${data['name']}');
        print('    * completedAt: ${data['completedAt']}');
        print('    * type: ${data['type']}');
        print('    * calories: ${data['calories']}');
      }

      // Check completed workouts
      final completedWorkouts = snapshot.docs
          .where((doc) => doc.data()['completedAt'] != null)
          .toList();

      print('📊 Completed Workouts: ${completedWorkouts.length}');
      for (int i = 0; i < completedWorkouts.length; i++) {
        final doc = completedWorkouts[i];
        final data = doc.data();
        print(
          '  - Completed ${i + 1}: ${data['name']} at ${data['completedAt']}',
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Direct Firestore fetch completed - check console',
            ),
            backgroundColor: Colors.indigo,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      DebugHelper.logError('Error testing direct Firestore fetch: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Direct fetch failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _testRealTimeListener() async {
    try {
      print('📡 Testing Real-time Listener:');

      // Test if listener is active
      print('  - Checking if listener is active...');

      // Complete a test workout to trigger listener
      final exerciseService = ExerciseService();
      final workouts = await exerciseService.getAllWorkouts();

      if (workouts.isNotEmpty) {
        final testWorkout = workouts.first;
        print('  - Completing workout: ${testWorkout.name}');

        await exerciseService.completeWorkout(testWorkout.id);

        print('  - Workout completed, waiting for listener...');

        // Wait a bit for listener to trigger
        await Future.delayed(const Duration(seconds: 2));

        print('  - Check console for listener logs above');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Real-time listener test completed - check console',
            ),
            backgroundColor: Colors.cyan,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      DebugHelper.logError('Error testing real-time listener: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Listener test failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _markNotificationAsRead(String notificationId) async {
    await _notificationService.markNotificationAsRead(notificationId);
    await _loadRealData(); // Refresh to show read status
  }

  Future<void> _loadDashboardData({bool forceRefresh = false}) async {
    final startTime = DateTime.now();

    try {
      setState(() {
        _isLoading = true;
      });

      // Add timeout to prevent hanging
      final dashboardData = await _dashboardService
          .getDashboardData(forceRefresh: forceRefresh)
          .timeout(const Duration(seconds: 10));

      if (mounted) {
        setState(() {
          _dashboardData = dashboardData;
          _isLoading = false;
        });
      }
    } catch (e) {
      final loadTime = DateTime.now().difference(startTime);
      DebugHelper.logError(
        'Dashboard data failed after ${loadTime.inMilliseconds}ms: $e',
      );
      if (mounted) {
        setState(() {
          _isLoading = false;
          // Set default data to prevent UI crashes
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

        // Show error message to user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load dashboard data: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _loadRealData() async {
    try {
      // Load workout tips
      final workoutService = WorkoutService();
      final tips = await workoutService.getWorkoutTips();

      // Load notifications
      final notifications = await _notificationService.getUserNotifications(
        limit: 5,
      );

      // Load activities
      final activities = await _notificationService.getUserActivities(limit: 5);

      // Load notifications
      final notifications = await _notificationService.getUserNotifications(
        limit: 5,
      );

      // Load activities
      final activities = await _notificationService.getUserActivities(limit: 5);

      if (mounted) {
        setState(() {
          tipsArr = tips;
          notificationsArr = notifications;
          activitiesArr = activities;
          notificationsArr = notifications;
          activitiesArr = activities;
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _refreshDashboardData() async {
    await _refreshDashboard();
  }

  bool _isDashboardDataValid() {
    if (_dashboardData == null) return false;

    // Check if data is not too old (within last 24 hours)
    final now = DateTime.now();
    final dataAge = now.difference(_dashboardData!.lastUpdated);
    if (dataAge.inHours > 24) return false;

    // Check if essential fields are present
    return _dashboardData!.userName.isNotEmpty &&
        _dashboardData!.userId.isNotEmpty;
  }

  @override
  void dispose() {
    // Stop real-time listeners
    _dashboardService.stopRealTimeUpdates();

    // Cancel periodic timer
    _refreshTimer?.cancel();

    // Remove observer
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

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

  List lastWorkoutArr = [];
  List waterArr = [];
  List notificationsArr = [];
  List activitiesArr = [];
  List tipsArr = [];
  List upcomingWorkoutArr = [];
  List exercisesArr = [];

  Widget bottomTitleWidgets(double value, TitleMeta meta, double chartWidth) {
    if (value % 1 != 0) return Container();
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.grey,
      fontFamily: 'Digital',
      fontSize: 18,
    );

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    if (value.toInt() < 0 || value.toInt() >= months.length) return Container();

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(months[value.toInt()], style: style),
    );
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: TColor.white,
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: TColor.primaryColor1),
            )
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Welcome header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Welcome Back,",
                                  style: TextStyle(
                                    color: TColor.gray,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  _userData?['displayName'] ?? 'User',
                                  style: TextStyle(
                                    color: TColor.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: _showNotificationDialog,
                              icon: Image.asset(
                                "assets/img/notification_active.png",
                                width: 25,
                                height: 25,
                                fit: BoxFit.fitHeight,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: media.width * 0.05),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: TColor.primaryColor1),
            )
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Welcome header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Welcome Back,",
                                  style: TextStyle(
                                    color: TColor.gray,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  _userData?['displayName'] ?? 'User',
                                  style: TextStyle(
                                    color: TColor.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: _showNotificationDialog,
                              icon: Image.asset(
                                "assets/img/notification_active.png",
                                width: 25,
                                height: 25,
                                fit: BoxFit.fitHeight,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: media.width * 0.05),

                        // BMI Card
                        Container(
                          height: media.width * 0.4,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: TColor.primaryG),
                            borderRadius: BorderRadius.circular(
                              media.width * 0.075,
                            ),
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
                                padding: const EdgeInsets.symmetric(
                                  vertical: 25,
                                  horizontal: 25,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "BMI (Body Mass Index)",
                                          style: TextStyle(
                                            color: TColor.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Text(
                                          _getBMIStatus(),
                                          style: TextStyle(
                                            color: TColor.white.withOpacity(
                                              0.7,
                                            ),
                                            fontSize: 12,
                                          ),
                                        ),
                                        SizedBox(height: media.width * 0.05),
                                        SizedBox(
                                          width: 120,
                                          height: 35,
                                          child: RoundButton(
                                            title: "View More",
                                            type: RoundButtonType.bgSGradient,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const BMIChartScreen(),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    AspectRatio(
                                      aspectRatio: 1,
                                      child: PieChart(
                                        PieChartData(
                                          pieTouchData: PieTouchData(
                                            touchCallback:
                                                (
                                                  FlTouchEvent event,
                                                  pieTouchResponse,
                                                ) {},
                                          ),
                                          startDegreeOffset: 250,
                                          borderData: FlBorderData(show: false),
                                          sectionsSpace: 1,
                                          centerSpaceRadius: 0,
                                          sections: showingSections(),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // BMI Card
                        Container(
                          height: media.width * 0.4,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: TColor.primaryG),
                            borderRadius: BorderRadius.circular(
                              media.width * 0.075,
                            ),
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
                                padding: const EdgeInsets.symmetric(
                                  vertical: 25,
                                  horizontal: 25,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "BMI (Body Mass Index)",
                                          style: TextStyle(
                                            color: TColor.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Text(
                                          _getBMIStatus(),
                                          style: TextStyle(
                                            color: TColor.white.withOpacity(
                                              0.7,
                                            ),
                                            fontSize: 12,
                                          ),
                                        ),
                                        SizedBox(height: media.width * 0.05),
                                        SizedBox(
                                          width: 120,
                                          height: 35,
                                          child: RoundButton(
                                            title: "View More",
                                            type: RoundButtonType.bgSGradient,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const BMIChartScreen(),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    AspectRatio(
                                      aspectRatio: 1,
                                      child: PieChart(
                                        PieChartData(
                                          pieTouchData: PieTouchData(
                                            touchCallback:
                                                (
                                                  FlTouchEvent event,
                                                  pieTouchResponse,
                                                ) {},
                                          ),
                                          startDegreeOffset: 250,
                                          borderData: FlBorderData(show: false),
                                          sectionsSpace: 1,
                                          centerSpaceRadius: 0,
                                          sections: showingSections(),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: media.width * 0.05),
                        SizedBox(height: media.width * 0.05),

                        // Dashboard Cards
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Today's Overview",
                              style: TextStyle(
                                color: TColor.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            IconButton(
                              onPressed: _refreshDashboardData,
                              icon: Icon(
                                Icons.refresh,
                                color: TColor.primaryColor1,
                                size: 20,
                              ),
                              tooltip: 'Refresh dashboard data',
                            ),
                          ],
                        ),
                        SizedBox(height: 15),
                        if (_isLoading)
                          Container(
                            height: 200,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: TColor.primaryColor1,
                              ),
                            ),
                          )
                        else if (!_isDashboardDataValid())
                          Container(
                            height: 200,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: TColor.gray,
                                    size: 48,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Dashboard data unavailable',
                                    style: TextStyle(
                                      color: TColor.gray,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  TextButton(
                                    onPressed: _refreshDashboardData,
                                    child: Text(
                                      'Retry',
                                      style: TextStyle(
                                        color: TColor.primaryColor1,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            crossAxisSpacing: 15,
                            mainAxisSpacing: 15,
                            childAspectRatio: 1.4,
                            children: [
                              DashboardCard(
                                title: "Calories Consumed",
                                value:
                                    _dashboardData?.totalCaloriesConsumed
                                        .toString() ??
                                    "0",
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
                                    _dashboardData?.totalCaloriesBurned
                                        .toString() ??
                                    "0",
                                unit: "kcal",
                                icon: Icons.fitness_center,
                                color: TColor.secondaryColor1,
                                progress:
                                    (_dashboardData?.totalCaloriesBurned ?? 0) /
                                    500,
                              ),
                              DashboardCard(
                                title: "Water Intake",
                                value:
                                    _dashboardData?.waterIntake.toStringAsFixed(
                                      1,
                                    ) ??
                                    "0.0",
                                unit: "ml",
                                icon: Icons.water_drop,
                                color: Colors.blue,
                                progress:
                                    (_dashboardData?.waterIntake ?? 0.0) / 2000,
                              ),
                              DashboardCard(
                                title: "Steps Taken",
                                value:
                                    _dashboardData?.stepsTaken.toString() ??
                                    "0",
                                unit: "steps",
                                icon: Icons.directions_walk,
                                color: Colors.green,
                                progress:
                                    (_dashboardData?.stepsTaken ?? 0) / 10000,
                              ),
                            ],
                          ),
                        SizedBox(height: 20),

                        // Today Target
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 15,
                          ),
                          decoration: BoxDecoration(
                            color: TColor.primaryColor2.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Today Target",
                                style: TextStyle(
                                  color: TColor.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
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
                        // Today Target
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 15,
                          ),
                          decoration: BoxDecoration(
                            color: TColor.primaryColor2.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Today Target",
                                style: TextStyle(
                                  color: TColor.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
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
                        SizedBox(height: media.width * 0.05),

                        // Today's Targets
                        Text(
                          "Today's Targets",
                          style: TextStyle(
                            color: TColor.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 80,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            children: [
                              TodayTargetCell(
                                icon: "assets/img/burn.png",
                                value: "320",
                                title: "Calories",
                              ),
                              const SizedBox(width: 15),
                              TodayTargetCell(
                                icon: "assets/img/bottle.png",
                                value: "6.8L",
                                title: "Water",
                              ),
                              const SizedBox(width: 15),
                              TodayTargetCell(
                                icon: "assets/img/bed.png",
                                value: "8h 20m",
                                title: "Sleep",
                              ),
                              const SizedBox(width: 15),
                              TodayTargetCell(
                                icon: "assets/img/foot.png",
                                value: "2400",
                                title: "Steps",
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Today's Targets
                        Text(
                          "Today's Targets",
                          style: TextStyle(
                            color: TColor.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 80,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            children: [
                              TodayTargetCell(
                                icon: "assets/img/burn.png",
                                value: "320",
                                title: "Calories",
                              ),
                              const SizedBox(width: 15),
                              TodayTargetCell(
                                icon: "assets/img/bottle.png",
                                value: "6.8L",
                                title: "Water",
                              ),
                              const SizedBox(width: 15),
                              TodayTargetCell(
                                icon: "assets/img/bed.png",
                                value: "8h 20m",
                                title: "Sleep",
                              ),
                              const SizedBox(width: 15),
                              TodayTargetCell(
                                icon: "assets/img/foot.png",
                                value: "2400",
                                title: "Steps",
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Activity Status (Chart)
                        Text(
                          "Activity Status",
                          style: TextStyle(
                            color: TColor.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: Container(
                            height: media.width * 0.4,
                            width: double.maxFinite,
                            decoration: BoxDecoration(
                              color: TColor.primaryColor2.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Stack(
                              alignment: Alignment.topLeft,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 20,
                                    horizontal: 20,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                        shaderCallback: (bounds) {
                                          return LinearGradient(
                                            colors: TColor.primaryG,
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                          ).createShader(
                                            Rect.fromLTRB(
                                              0,
                                              0,
                                              bounds.width,
                                              bounds.height,
                                            ),
                                          );
                                        },
                                        child: Text(
                                          "78 BPM",
                                          style: TextStyle(
                                            color: TColor.white.withOpacity(
                                              0.7,
                                            ),
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
                                    showingTooltipIndicators:
                                        showingTooltipOnSpots.map((index) {
                                          return ShowingTooltipIndicators([
                                            LineBarSpot(
                                              LineChartBarData(spots: allSpots),
                                              0,
                                              allSpots[index],
                                            ),
                                          ]);
                                        }).toList(),
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
                                              TColor.primaryColor2.withOpacity(
                                                0.4,
                                              ),
                                              TColor.primaryColor1.withOpacity(
                                                0.1,
                                              ),
                                            ],
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                          ),
                                        ),
                                        dotData: FlDotData(show: false),
                                        gradient: LinearGradient(
                                          colors: TColor.primaryG,
                                        ),
                                      ),
                                    ],
                                    minY: 0,
                                    maxY: 130,
                                    titlesData: FlTitlesData(show: false),
                                    gridData: FlGridData(show: false),
                                    borderData: FlBorderData(
                                      show: true,
                                      border: Border.all(
                                        color: Colors.transparent,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Activity Status (Chart)
                        Text(
                          "Activity Status",
                          style: TextStyle(
                            color: TColor.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: Container(
                            height: media.width * 0.4,
                            width: double.maxFinite,
                            decoration: BoxDecoration(
                              color: TColor.primaryColor2.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Stack(
                              alignment: Alignment.topLeft,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 20,
                                    horizontal: 20,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                        shaderCallback: (bounds) {
                                          return LinearGradient(
                                            colors: TColor.primaryG,
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                          ).createShader(
                                            Rect.fromLTRB(
                                              0,
                                              0,
                                              bounds.width,
                                              bounds.height,
                                            ),
                                          );
                                        },
                                        child: Text(
                                          "78 BPM",
                                          style: TextStyle(
                                            color: TColor.white.withOpacity(
                                              0.7,
                                            ),
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
                                    showingTooltipIndicators:
                                        showingTooltipOnSpots.map((index) {
                                          return ShowingTooltipIndicators([
                                            LineBarSpot(
                                              LineChartBarData(spots: allSpots),
                                              0,
                                              allSpots[index],
                                            ),
                                          ]);
                                        }).toList(),
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
                                              TColor.primaryColor2.withOpacity(
                                                0.4,
                                              ),
                                              TColor.primaryColor1.withOpacity(
                                                0.1,
                                              ),
                                            ],
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                          ),
                                        ),
                                        dotData: FlDotData(show: false),
                                        gradient: LinearGradient(
                                          colors: TColor.primaryG,
                                        ),
                                      ),
                                    ],
                                    minY: 0,
                                    maxY: 130,
                                    titlesData: FlTitlesData(show: false),
                                    gridData: FlGridData(show: false),
                                    borderData: FlBorderData(
                                      show: true,
                                      border: Border.all(
                                        color: Colors.transparent,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: media.width * 0.05),
                        SizedBox(height: media.width * 0.05),

                        // Latest Workouts
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Latest Workouts",
                              style: TextStyle(
                                color: TColor.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: Text(
                                "See More",
                                style: TextStyle(
                                  color: TColor.gray,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ...lastWorkoutArr.map(
                          (workout) => WorkoutRow(wObj: workout),
                        ),
                        const SizedBox(height: 20),
                        // Latest Workouts
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Latest Workouts",
                              style: TextStyle(
                                color: TColor.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: Text(
                                "See More",
                                style: TextStyle(
                                  color: TColor.gray,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ...lastWorkoutArr.map(
                          (workout) => WorkoutRow(wObj: workout),
                        ),
                        const SizedBox(height: 20),

                        // What to Train
                        Text(
                          "What to Train",
                          style: TextStyle(
                            color: TColor.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...tipsArr.map((tip) => WhatTrainRow(wObj: tip)),
                        const SizedBox(height: 20),
                        // What to Train
                        Text(
                          "What to Train",
                          style: TextStyle(
                            color: TColor.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...tipsArr.map((tip) => WhatTrainRow(wObj: tip)),
                        const SizedBox(height: 20),

                        // Upcoming Workouts
                        Text(
                          "Upcoming Workouts",
                          style: TextStyle(
                            color: TColor.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...upcomingWorkoutArr.map(
                          (workout) => UpcomingWorkoutRow(wObj: workout),
                        ),
                        const SizedBox(height: 20),
                        // Upcoming Workouts
                        Text(
                          "Upcoming Workouts",
                          style: TextStyle(
                            color: TColor.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...upcomingWorkoutArr.map(
                          (workout) => UpcomingWorkoutRow(wObj: workout),
                        ),
                        const SizedBox(height: 20),

                        // Recent Activities
                        Text(
                          "Recent Activities",
                          style: TextStyle(
                            color: TColor.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...activitiesArr.map(
                          (activity) => LatestActivityRow(wObj: activity),
                        ),
                        const SizedBox(height: 20),
                        // Recent Activities
                        Text(
                          "Recent Activities",
                          style: TextStyle(
                            color: TColor.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...activitiesArr.map(
                          (activity) => LatestActivityRow(wObj: activity),
                        ),
                        const SizedBox(height: 20),

                        // Recent Notifications
                        Text(
                          "Recent Notifications",
                          style: TextStyle(
                            color: TColor.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...notificationsArr.map(
                          (notification) => NotificationRow(nObj: notification),
                        ),
                        const SizedBox(height: 20),
                        // Recent Notifications
                        Text(
                          "Recent Notifications",
                          style: TextStyle(
                            color: TColor.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...notificationsArr.map(
                          (notification) => NotificationRow(nObj: notification),
                        ),
                        const SizedBox(height: 20),

                        // Popular Exercises
                        Text(
                          "Popular Exercises",
                          style: TextStyle(
                            color: TColor.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...exercisesArr.map(
                          (exercise) =>
                              ExercisesRow(eObj: exercise, onPressed: () {}),
                        ),
                        // Popular Exercises
                        Text(
                          "Popular Exercises",
                          style: TextStyle(
                            color: TColor.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...exercisesArr.map(
                          (exercise) =>
                              ExercisesRow(eObj: exercise, onPressed: () {}),
                        ),

                        SizedBox(height: media.width * 0.1),
                      ],
                    ),
                  ),
                ),
              ),
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
