import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../common/color_extension.dart';
import '../../screens/auth_screen.dart';
import '../../services/notification_service.dart';
import '../../widgets/round_button.dart';
import '../../widgets/setting_row.dart';
import '../../widgets/title_subtitle_cell.dart';
import '../../widgets/today_target_cell.dart';
import '../../widgets/latest_activity_row.dart';
import '../../widgets/notification_row.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  bool positive = false;
  bool _disposed = false;

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
    {"image": "assets/img/p_setting.png", "name": "Setting", "tag": "7"},
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
      final notificationService = NotificationService();

      // Load notifications and activities
      final notifications = await notificationService.getUserNotifications(
        limit: 5,
      );
      final activities = await notificationService.getUserActivities(limit: 5);

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
                              onPressed: () {},
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
                              onPressed: () {},
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
