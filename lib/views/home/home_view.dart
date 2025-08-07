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

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final DashboardService _dashboardService = DashboardService();
  DashboardData? _dashboardData;
  bool _isLoading = true;
  Map<String, dynamic>? _userData;

  List<int> showingTooltipOnSpots = [21];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
    _loadUserData();
    _loadRealData();
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
      print('Error loading user data: $e');
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

  Future<void> _loadDashboardData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final dashboardData = await _dashboardService.getDashboardData();

      if (mounted) {
        setState(() {
          _dashboardData = dashboardData;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading dashboard data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadRealData() async {
    try {
      // Load workout tips
      final workoutService = WorkoutService();
      final tips = await workoutService.getWorkoutTips();

      if (mounted) {
        setState(() {
          tipsArr = tips;
        });
      }
    } catch (e) {
      print('Error loading real data: $e');
    }
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
      body: RefreshIndicator(
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
                            style: TextStyle(color: TColor.gray, fontSize: 12),
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
                        onPressed: () {},
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
                          padding: const EdgeInsets.symmetric(
                            vertical: 25,
                            horizontal: 25,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
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
                                  ),
                                  Text(
                                    _getBMIStatus(),
                                    style: TextStyle(
                                      color: TColor.white.withOpacity(0.7),
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
                                      onPressed: () {},
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

                  // Dashboard Cards
                  if (_dashboardData != null) ...[
                    Text(
                      "Today's Overview",
                      style: TextStyle(
                        color: TColor.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 15),
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
                          value: "${_dashboardData!.totalCaloriesConsumed}",
                          unit: "kcal",
                          icon: Icons.local_fire_department,
                          color: TColor.primaryColor1,
                          progress:
                              _dashboardData!.totalCaloriesConsumed / 2000,
                        ),
                        DashboardCard(
                          title: "Calories Burned",
                          value: "${_dashboardData!.totalCaloriesBurned}",
                          unit: "kcal",
                          icon: Icons.fitness_center,
                          color: TColor.secondaryColor1,
                          progress: _dashboardData!.totalCaloriesBurned / 500,
                        ),
                        DashboardCard(
                          title: "Water Intake",
                          value: "${_dashboardData!.waterIntake}",
                          unit: "ml",
                          icon: Icons.water_drop,
                          color: Colors.blue,
                          progress: _dashboardData!.waterIntake / 2000,
                        ),
                        DashboardCard(
                          title: "Steps Taken",
                          value: "${_dashboardData!.stepsTaken}",
                          unit: "steps",
                          icon: Icons.directions_walk,
                          color: Colors.green,
                          progress: _dashboardData!.stepsTaken / 10000,
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                  ],

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
                                      color: TColor.white.withOpacity(0.7),
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
                                  .map((index) {
                                    return ShowingTooltipIndicators([
                                      LineBarSpot(
                                        LineChartBarData(spots: allSpots),
                                        0,
                                        allSpots[index],
                                      ),
                                    ]);
                                  })
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
                                        TColor.primaryColor2.withOpacity(0.4),
                                        TColor.primaryColor1.withOpacity(0.1),
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
                                border: Border.all(color: Colors.transparent),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

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
                          style: TextStyle(color: TColor.gray, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...lastWorkoutArr.map((workout) => WorkoutRow(wObj: workout)),
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
