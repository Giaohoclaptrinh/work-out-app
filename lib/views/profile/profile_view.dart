import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../common/color_extension.dart';
import '../../screens/auth_screen.dart';
import '../../services/notification_service.dart';
import '../../services/exercise_service.dart';
import '../../widgets/round_button.dart';
import '../../widgets/setting_row.dart';
import '../../widgets/title_subtitle_cell.dart';
import '../../widgets/today_target_cell.dart';
import '../../widgets/latest_activity_row.dart';
import '../../widgets/notification_row.dart';
import '../../widgets/round_textfield.dart';
import '../../screens/settings_screen.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  bool positive = false;
  bool _disposed = false;
  final NotificationService _notificationService = NotificationService();
  final ExerciseService _exerciseService = ExerciseService();

  List accountArr = [
    {"image": "assets/img/p_personal.png", "name": "Personal Data", "tag": "1"},
    {"image": "assets/img/p_achi.png", "name": "Achievement", "tag": "2"},
    {
      "image": "assets/img/p_activity.png",
      "name": "Activity History",
      "tag": "3",
    },
    {
      "image": "assets/img/p_workout.png",
      "name": "Workout Progress",
      "tag": "4",
    },
  ];

  List otherArr = [
    {"image": "assets/img/p_contact.png", "name": "Contact Us", "tag": "5"},
    {"image": "assets/img/p_privacy.png", "name": "Privacy Policy", "tag": "6"},
    {"image": "assets/img/p_setting.png", "name": "Settings", "tag": "7"},
  ];

  List notificationsArr = [];
  List activitiesArr = [];

  @override
  void initState() {
    super.initState();
    _loadRealData();
  }

  Future<void> _loadRealData() async {
    try {
      // Load notifications and activities
      final notifications = await _notificationService.getUserNotifications(
        limit: 5,
      );
      final activities = await _notificationService.getUserActivities(limit: 5);

      // Format notifications for UI
      final formattedNotifications = notifications.map((notification) {
        return {
          "image": "assets/img/bell.png",
          "title": notification['title'] ?? 'Notification',
          "time": NotificationService.formatTimeAgo(notification['timestamp']),
        };
      }).toList();

      // Format activities for UI
      final formattedActivities = activities.map((activity) {
        return {
          "image": "assets/img/barbell.png",
          "title": activity['title'] ?? 'Activity',
          "time": NotificationService.formatTimeAgo(activity['timestamp']),
        };
      }).toList();

      if (mounted) {
        setState(() {
          notificationsArr = formattedNotifications;
          activitiesArr = formattedActivities;
        });
      }
    } catch (e) {
      print('Error loading real data: $e');
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<Map<String, dynamic>?> fetchUserData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return null;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();

    return doc.data();
  }

  void _handleAccountItemTap(String tag) {
    switch (tag) {
      case "1": // Personal Data
        _showPersonalDataDialog();
        break;
      case "2": // Achievement
        _showAchievementDialog();
        break;
      case "3": // Activity History
        _showActivityHistoryDialog();
        break;
      case "4": // Workout Progress
        _showWorkoutProgressDialog();
        break;
      default:
        _showNotificationToast("Feature coming soon!");
    }
  }

  void _handleOtherItemTap(String tag) {
    switch (tag) {
      case "5": // Contact Us
        _showContactDialog();
        break;
      case "6": // Privacy Policy
        _showPrivacyDialog();
        break;
      case "7": // Settings
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SettingsScreen()),
        );
        break;
      default:
        _showNotificationToast("Feature coming soon!");
    }
  }

  void _showContactDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Contact Us',
          style: TextStyle(color: TColor.black, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.email, color: TColor.primaryColor1),
              title: const Text('Email'),
              subtitle: const Text('support@fitnessapp.com'),
              onTap: () {
                // TODO: Open email app
              },
            ),
            ListTile(
              leading: Icon(Icons.phone, color: TColor.primaryColor1),
              title: const Text('Phone'),
              subtitle: const Text('+1 (555) 123-4567'),
              onTap: () {
                // TODO: Open phone app
              },
            ),
            ListTile(
              leading: Icon(Icons.chat, color: TColor.primaryColor1),
              title: const Text('Live Chat'),
              subtitle: const Text('Available 24/7'),
              onTap: () {
                // TODO: Open chat support
              },
            ),
          ],
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

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Privacy Policy',
          style: TextStyle(color: TColor.black, fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Data Collection',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: TColor.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'We collect personal information such as height, weight, and workout data to provide personalized fitness recommendations.',
                  style: TextStyle(color: TColor.gray),
                ),
                const SizedBox(height: 16),
                Text(
                  'Data Usage',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: TColor.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your data is used to track progress, provide insights, and improve your fitness experience. We never share personal data with third parties without consent.',
                  style: TextStyle(color: TColor.gray),
                ),
                const SizedBox(height: 16),
                Text(
                  'Data Security',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: TColor.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'We use industry-standard encryption and security measures to protect your personal information and workout data.',
                  style: TextStyle(color: TColor.gray),
                ),
              ],
            ),
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

  void _showNotificationToast(String message) {
    _notificationService.addNotification(
      'Profile Action',
      message,
      type: 'info',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: TColor.primaryColor1,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showPersonalDataDialog() async {
    final userData = await fetchUserData();
    if (!mounted) return;

    final weightController = TextEditingController(
      text: (userData?['weight']?.toString()) ?? '70',
    );
    final heightController = TextEditingController(
      text: (userData?['height']?.toString()) ?? '175',
    );
    final ageController = TextEditingController(
      text: (userData?['age']?.toString()) ?? '25',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Personal Data',
          style: TextStyle(color: TColor.black, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RoundTextField(
                controller: weightController,
                hintText: 'Weight (kg)',
                icon: "assets/img/weight.png",
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 15),
              RoundTextField(
                controller: heightController,
                hintText: 'Height (cm)',
                icon: "assets/img/hight.png",
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 15),
              RoundTextField(
                controller: ageController,
                hintText: 'Age',
                icon: "assets/img/date.png",
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: TColor.gray)),
          ),
          ElevatedButton(
            onPressed: () => _updatePersonalData(
              weightController.text,
              heightController.text,
              ageController.text,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: TColor.primaryColor1,
            ),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _updatePersonalData(
    String weight,
    String height,
    String age,
  ) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update({
            'weight': double.tryParse(weight) ?? 70.0,
            'height': double.tryParse(height) ?? 175.0,
            'age': int.tryParse(age) ?? 25,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      Navigator.pop(context);

      await _notificationService.addNotification(
        'Profile Updated! 🎉',
        'Your personal data has been successfully updated',
        type: 'profile_update',
      );

      _showNotificationToast('Personal data updated successfully!');

      // Refresh the page
      setState(() {});
    } catch (e) {
      _showNotificationToast('Error updating data: $e');
    }
  }

  void _showWorkoutProgressDialog() async {
    try {
      // Get user's workout history
      final completedWorkouts = await _exerciseService.getWorkoutHistory();
      final favoriteWorkouts = await _exerciseService.getFavoriteWorkouts();

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Workout Progress',
            style: TextStyle(color: TColor.black, fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress Stats
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: TColor.primaryG),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildProgressStat(
                          'Completed',
                          '${completedWorkouts.length}',
                          Icons.check_circle,
                        ),
                        _buildProgressStat(
                          'Favorites',
                          '${favoriteWorkouts.length}',
                          Icons.favorite,
                        ),
                        _buildProgressStat(
                          'Streak',
                          '7', // Could be calculated
                          Icons.local_fire_department,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Recent Workouts
                  Text(
                    'Recent Workouts',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: TColor.black,
                    ),
                  ),
                  const SizedBox(height: 10),

                  if (completedWorkouts.isEmpty)
                    Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.fitness_center,
                            size: 50,
                            color: TColor.gray,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'No workouts completed yet',
                            style: TextStyle(color: TColor.gray),
                          ),
                        ],
                      ),
                    )
                  else
                    ...completedWorkouts
                        .take(5)
                        .map(
                          (workout) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: TColor.lightGray.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.fitness_center,
                                  color: TColor.primaryColor1,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        workout.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: TColor.black,
                                        ),
                                      ),
                                      Text(
                                        workout.category,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: TColor.gray,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (workout.calories != null)
                                  Text(
                                    '${workout.calories} cal',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: TColor.primaryColor1,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Close',
                style: TextStyle(color: TColor.primaryColor1),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      _showNotificationToast('Error loading workout progress: $e');
    }
  }

  Widget _buildProgressStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
        ),
      ],
    );
  }

  void _showAchievementDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Achievements',
          style: TextStyle(color: TColor.black, fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: GridView.count(
            crossAxisCount: 2,
            children: [
              _buildAchievementCard('First Workout', '🏃‍♂️', true),
              _buildAchievementCard('7 Day Streak', '🔥', true),
              _buildAchievementCard('50 Workouts', '💪', false),
              _buildAchievementCard('Weight Goal', '🎯', false),
              _buildAchievementCard('Early Bird', '🌅', true),
              _buildAchievementCard('Night Owl', '🦉', false),
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

  Widget _buildAchievementCard(String title, String emoji, bool achieved) {
    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: achieved
            ? TColor.primaryColor1.withOpacity(0.1)
            : TColor.lightGray.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: achieved ? TColor.primaryColor1 : TColor.gray,
          width: achieved ? 2 : 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            emoji,
            style: TextStyle(
              fontSize: 30,
              color: achieved ? null : Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: achieved ? TColor.black : TColor.gray,
            ),
          ),
          if (achieved)
            Icon(Icons.check_circle, color: TColor.primaryColor1, size: 16),
        ],
      ),
    );
  }

  void _showActivityHistoryDialog() async {
    await _notificationService.addNotification(
      'Activity History',
      'Viewing your workout activity history',
      type: 'view',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Activity History',
          style: TextStyle(color: TColor.black, fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: activitiesArr.length,
            itemBuilder: (context, index) {
              final activity = activitiesArr[index];
              return ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: TColor.primaryColor1.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.fitness_center,
                    color: TColor.primaryColor1,
                    size: 20,
                  ),
                ),
                title: Text(
                  activity['title'],
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: TColor.black,
                  ),
                ),
                subtitle: Text(
                  activity['time'],
                  style: TextStyle(color: TColor.gray, fontSize: 12),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: TColor.gray,
                ),
              );
            },
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: fetchUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = snapshot.data ?? {};

        return Scaffold(
          backgroundColor: TColor.white,
          body: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Profile Header
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.asset(
                          "assets/img/pp_1.png",
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user['displayName'] ?? 'Stefani Wong',
                              style: TextStyle(
                                color: TColor.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              (user['goals'] as List?)?.join(', ') ??
                                  'Lose a Fat Program',
                              style: TextStyle(
                                color: TColor.gray,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 70,
                        height: 25,
                        child: RoundButton(
                          title: "Edit",
                          type: RoundButtonType.bgGradient,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          onPressed: () {
                            // TODO: Edit profile
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // Height - Weight - Age
                  Row(
                    children: [
                      Expanded(
                        child: TitleSubtitleCell(
                          title: "${user['height'] ?? '180'}cm",
                          subtitle: "Height",
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: TitleSubtitleCell(
                          title: "${user['weight'] ?? '65'}kg",
                          subtitle: "Weight",
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: TitleSubtitleCell(
                          title: "${user['age'] ?? '22'}yo",
                          subtitle: "Age",
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),

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
                  const SizedBox(height: 25),

                  // Account Section
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 15,
                    ),
                    decoration: BoxDecoration(
                      color: TColor.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 2),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Account",
                          style: TextStyle(
                            color: TColor.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: accountArr.length,
                          itemBuilder: (context, index) {
                            var iObj = accountArr[index] as Map? ?? {};
                            return SettingRow(
                              icon:
                                  iObj["image"]?.toString() ??
                                  "assets/img/p_personal.png",
                              title: iObj["name"]?.toString() ?? "Setting",
                              onPressed: () {
                                _handleAccountItemTap(
                                  iObj["tag"]?.toString() ?? "",
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Notifications Section
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 15,
                    ),
                    decoration: BoxDecoration(
                      color: TColor.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 2),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Notifications",
                          style: TextStyle(
                            color: TColor.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 30,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(
                                "assets/img/p_notification.png",
                                height: 15,
                                width: 15,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Text(
                                  "Pop-up Notification",
                                  style: TextStyle(
                                    color: TColor.black,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              CustomAnimatedToggleSwitch<bool>(
                                current: positive,
                                values: [false, true],
                                indicatorSize: Size.square(30.0),
                                animationDuration: const Duration(
                                  milliseconds: 200,
                                ),
                                animationCurve: Curves.linear,
                                onChanged: (b) {
                                  if (!_disposed) {
                                    setState(() => positive = b);
                                  }
                                },
                                iconBuilder: (context, local, global) {
                                  return const SizedBox();
                                },
                                onTap: (b) {
                                  if (!_disposed) {
                                    setState(() => positive = !positive);
                                  }
                                },
                                iconsTappable: false,
                                wrapperBuilder: (context, global, child) {
                                  return Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Positioned(
                                        left: 10.0,
                                        right: 10.0,
                                        height: 30.0,
                                        child: DecoratedBox(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: TColor.secondaryG,
                                            ),
                                            borderRadius:
                                                const BorderRadius.all(
                                                  Radius.circular(50.0),
                                                ),
                                          ),
                                        ),
                                      ),
                                      child,
                                    ],
                                  );
                                },
                                foregroundIndicatorBuilder: (context, global) {
                                  return SizedBox.fromSize(
                                    size: const Size(10, 10),
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: TColor.white,
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(50.0),
                                        ),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black38,
                                            spreadRadius: 0.05,
                                            blurRadius: 1.1,
                                            offset: Offset(0.0, 0.8),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),

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
                  const SizedBox(height: 25),

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
                  const SizedBox(height: 25),

                  // Other Section
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 15,
                    ),
                    decoration: BoxDecoration(
                      color: TColor.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 2),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Other",
                          style: TextStyle(
                            color: TColor.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: otherArr.length,
                          itemBuilder: (context, index) {
                            var iObj = otherArr[index] as Map? ?? {};
                            return SettingRow(
                              icon:
                                  iObj["image"]?.toString() ??
                                  "assets/img/p_setting.png",
                              title: iObj["name"]?.toString() ?? "Setting",
                              onPressed: () {
                                _handleOtherItemTap(
                                  iObj["tag"]?.toString() ?? "",
                                );
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        SettingRow(
                          icon: "assets/img/p_next.png",
                          title: "Sign Out",
                          onPressed: () async {
                            final navigatorContext = context;
                            await FirebaseAuth.instance.signOut();
                            if (!_disposed && mounted) {
                              Navigator.pushReplacement(
                                navigatorContext,
                                MaterialPageRoute(
                                  builder: (_) => const AuthScreen(),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
