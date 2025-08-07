import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../common/color_extension.dart';
import '../../common/common_widgets.dart';
import '../../widgets/what_train_row.dart';
import '../../widgets/upcoming_workout_row.dart';
import '../../widgets/workout_row.dart';
import '../../widgets/exercises_row.dart';
import '../../widgets/today_target_cell.dart';
import '../../widgets/exercises_set_section.dart';
import '../../widgets/step_detail_row.dart';
import '../../screens/gym_visual_exercises_screen.dart';

class WorkoutTrackerView extends StatefulWidget {
  const WorkoutTrackerView({super.key});

  @override
  State<WorkoutTrackerView> createState() => _WorkoutTrackerViewState();
}

class _WorkoutTrackerViewState extends State<WorkoutTrackerView> {
  List<Map<String, dynamic>> workoutHistory = [];
  List<Map<String, dynamic>> workoutTips = [];
  List<Map<String, dynamic>> upcomingWorkouts = [];
  List<Map<String, dynamic>> exercises = [];
  bool isLoading = true;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    fetchWorkoutData();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> fetchWorkoutData() async {
    if (_disposed) return;

    try {
      // Use Future.wait to load data concurrently
      final results = await Future.wait([
        FirebaseFirestore.instance.collection('workouts').get(),
        FirebaseFirestore.instance.collection('tips').get(),
      ]);

      if (_disposed) return;

      final workoutSnapshot = results[0];
      final tipSnapshot = results[1];

      final workouts = workoutSnapshot.docs.map((doc) => doc.data()).toList();
      final tips = tipSnapshot.docs.map((doc) => doc.data()).toList();

      // Add null safety for data loading
      if (workouts.isEmpty) {
        print('No workouts found in Firestore');
      }
      if (tips.isEmpty) {
        print('No tips found in Firestore');
      }

      // Add sample data for upcoming workouts and exercises
      final upcoming = [
        {
          'title': 'Upper Body Workout',
          'time': 'Tomorrow, 9:00 AM',
          'duration': '45 min',
          'exercises': 8,
        },
        {
          'title': 'Cardio Session',
          'time': 'Wednesday, 7:00 AM',
          'duration': '30 min',
          'exercises': 5,
        },
      ];

      final exerciseList = [
        {
          'name': 'Push-ups',
          'category': 'Strength',
          'muscleGroups': ['Chest', 'Triceps'],
          'difficulty': 'Beginner',
        },
        {
          'name': 'Squats',
          'category': 'Strength',
          'muscleGroups': ['Legs', 'Glutes'],
          'difficulty': 'Beginner',
        },
        {
          'name': 'Pull-ups',
          'category': 'Strength',
          'muscleGroups': ['Back', 'Biceps'],
          'difficulty': 'Intermediate',
        },
      ];

      if (!_disposed) {
        setState(() {
          workoutHistory = workouts;
          workoutTips = tips;
          upcomingWorkouts = upcoming;
          exercises = exerciseList;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading workout data: $e");
      if (!_disposed) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_disposed) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: TColor.white,
        centerTitle: true,
        elevation: 0,
        leadingWidth: 0,
        leading: const SizedBox(),
        title: Text(
          "Workout Tracker",
          style: TextStyle(
            color: TColor.black,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      backgroundColor: TColor.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                if (!_disposed) {
                  await fetchWorkoutData();
                }
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 25,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Today Target (placeholder section)
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Today Target",
                                style: TextStyle(
                                  color: TColor.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "Check",
                                style: TextStyle(
                                  color: TColor.primaryColor1,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Today Target",
                                style: TextStyle(
                                  color: TColor.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "Check",
                                style: TextStyle(
                                  color: TColor.primaryColor1,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // Schedule
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: TColor.primaryColor2.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Daily Workout Schedule",
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
                              fontSize: 10,
                              onPressed: () {},
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),

                    // GymVisual Exercises Section
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: TColor.secondaryG),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "GymVisual Exercises",
                                  style: TextStyle(
                                    color: TColor.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "Browse professional exercise library",
                                  style: TextStyle(
                                    color: TColor.white.withOpacity(0.8),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 100,
                            height: 35,
                            child: RoundButton(
                              title: "Browse",
                              fontSize: 12,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const GymVisualExercisesScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Today's Targets Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Today's Targets",
                          style: TextStyle(
                            color: TColor.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            "See All",
                            style: TextStyle(color: TColor.gray, fontSize: 14),
                          ),
                        ),
                      ],
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

                    // Exercise Sets Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Exercise Sets",
                          style: TextStyle(
                            color: TColor.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            "See All",
                            style: TextStyle(color: TColor.gray, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: TColor.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 3,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          ExercisesSetSection(
                            sObj: {
                              "name": "Upper Body",
                              "set": [
                                {
                                  "name": "Push-ups",
                                  "time": "3 sets x 12 reps",
                                  "image": "assets/img/barbell.png",
                                },
                                {
                                  "name": "Pull-ups",
                                  "time": "3 sets x 8 reps",
                                  "image": "assets/img/barbell.png",
                                },
                              ],
                            },
                            onPressed: (obj) {
                              print('Selected exercise: ${obj['name']}');
                            },
                          ),
                          const SizedBox(height: 15),
                          ExercisesSetSection(
                            sObj: {
                              "name": "Lower Body",
                              "set": [
                                {
                                  "name": "Squats",
                                  "time": "3 sets x 15 reps",
                                  "image": "assets/img/barbell.png",
                                },
                                {
                                  "name": "Lunges",
                                  "time": "3 sets x 10 reps each",
                                  "image": "assets/img/barbell.png",
                                },
                              ],
                            },
                            onPressed: (obj) {
                              print('Selected exercise: ${obj['name']}');
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Workout Steps Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Workout Steps",
                          style: TextStyle(
                            color: TColor.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            "See All",
                            style: TextStyle(color: TColor.gray, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: TColor.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 3,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          StepDetailRow(
                            sObj: {
                              "no": "01",
                              "title": "Warm Up",
                              "detail": "5-10 minutes of light cardio",
                            },
                            isLast: false,
                          ),
                          const SizedBox(height: 10),
                          StepDetailRow(
                            sObj: {
                              "no": "02",
                              "title": "Main Workout",
                              "detail": "45 minutes of strength training",
                            },
                            isLast: false,
                          ),
                          const SizedBox(height: 10),
                          StepDetailRow(
                            sObj: {
                              "no": "03",
                              "title": "Cool Down",
                              "detail": "5-10 minutes of stretching",
                            },
                            isLast: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Upcoming Workouts Section
                    if (upcomingWorkouts.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Upcoming Workouts",
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
                      ...upcomingWorkouts.map(
                        (workout) => UpcomingWorkoutRow(
                          wObj: {
                            'title': workout['title'],
                            'time': workout['time'],
                            'image': 'assets/img/Workout1.png', // Default image
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // What Do You Want to Train Section
                    Text(
                      "What Do You Want to Train",
                      style: TextStyle(
                        color: TColor.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 15),
                    ...workoutTips.map(
                      (tip) => WhatTrainRow(
                        wObj: {
                          'title': tip['title'] ?? '',
                          'exercises': '5 exercises',
                          'time': '30 min',
                          'image': 'assets/img/Workout2.png', // Default image
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Exercises Section
                    if (exercises.isNotEmpty) ...[
                      Text(
                        "Popular Exercises",
                        style: TextStyle(
                          color: TColor.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 15),
                      ...exercises.map(
                        (exercise) => ExercisesRow(
                          eObj: {
                            'title': exercise['name'],
                            'value':
                                '${exercise['category']} • ${exercise['difficulty']}',
                            'image': 'assets/img/Workout3.png', // Default image
                          },
                          onPressed: () {},
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Workout History
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Latest Workout",
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
                    if (workoutHistory.isNotEmpty)
                      ...workoutHistory.map(
                        (item) => WorkoutRow(
                          wObj: {
                            'name': item['title'] ?? '',
                            'time': '30',
                            'kcal': '250',
                            'progress': 0.7,
                            'image': 'assets/img/Workout1.png', // Default image
                          },
                        ),
                      ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
}
