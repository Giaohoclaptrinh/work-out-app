import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/workout.dart';
import '../models/meal.dart';
import '../models/dashboard_data.dart';
import 'workout_service.dart';
import 'meal_service.dart';

class DashboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final WorkoutService _workoutService = WorkoutService();
  final MealService _mealService = MealService();

  // Get comprehensive dashboard data
  Future<DashboardData> getDashboardData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Get user profile data
      final userData = await _getUserProfileData(user.uid);

      // Get today's data
      final today = DateTime.now();
      final todayString = today.toIso8601String().split('T')[0];

      // Get workout data
      final workoutHistory = await _workoutService.getWorkoutHistory();
      final todayWorkouts = workoutHistory.where((workout) {
        final workoutDate = workout.completedAt;
        return workoutDate != null &&
            workoutDate.year == today.year &&
            workoutDate.month == today.month &&
            workoutDate.day == today.day;
      }).toList();

      // Get meal data
      final todayMealPlan = await _mealService.getMealPlanForDate(today);

      // Calculate totals
      final totalCaloriesConsumed = _calculateTotalCaloriesConsumed(
        todayMealPlan,
      );
      final totalCaloriesBurned = _calculateTotalCaloriesBurned(todayWorkouts);
      final waterIntake = await _getWaterIntake(todayString);
      final stepsTaken = await _getStepsTaken(todayString);
      final sleepHours = await _getSleepHours(todayString);

      // Calculate BMI
      final bmi = _calculateBMI(
        userData['weight'] ?? 70,
        userData['height'] ?? 170,
      );

      // Determine health status
      final healthStatus = _determineHealthStatus(
        bmi,
        totalCaloriesConsumed,
        totalCaloriesBurned,
      );

      return DashboardData(
        totalCaloriesConsumed: totalCaloriesConsumed,
        totalCaloriesBurned: totalCaloriesBurned,
        waterIntake: waterIntake,
        stepsTaken: stepsTaken,
        sleepHours: sleepHours,
        workoutsCompleted: todayWorkouts.length,
        mealsPlanned:
            todayMealPlan?.meals.values.fold(
              0,
              (sum, meals) => (sum ?? 0) + (meals?.length ?? 0),
            ) ??
            0,
        bmi: bmi,
        healthStatus: healthStatus,
        recentWorkouts: workoutHistory.take(5).toList(),
        recentMealPlans: await _getRecentMealPlans(),
      );
    } catch (e) {
      print('Error getting dashboard data: $e');
      // Return default data
      return DashboardData(
        totalCaloriesConsumed: 0,
        totalCaloriesBurned: 0,
        waterIntake: 0,
        stepsTaken: 0,
        sleepHours: 0,
        workoutsCompleted: 0,
        mealsPlanned: 0,
        bmi: 0,
        healthStatus: 'Unknown',
        recentWorkouts: [],
        recentMealPlans: [],
      );
    }
  }

  // Get user profile data
  Future<Map<String, dynamic>> _getUserProfileData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.data() ?? {};
    } catch (e) {
      print('Error getting user profile data: $e');
      return {};
    }
  }

  // Calculate total calories consumed from meal plan
  int _calculateTotalCaloriesConsumed(MealPlan? mealPlan) {
    if (mealPlan == null) return 0;

    int total = 0;
    mealPlan.meals.values.forEach((meals) {
      total += meals.fold(0, (sum, meal) => sum + meal.calories);
    });
    return total;
  }

  // Calculate total calories burned from workouts
  int _calculateTotalCaloriesBurned(List<Workout> workouts) {
    return workouts.fold(0, (sum, workout) => sum + workout.calories);
  }

  // Get water intake for today
  Future<int> _getWaterIntake(String date) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 0;

      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('waterIntake')
          .doc(date)
          .get();

      return doc.data()?['amount'] ?? 0;
    } catch (e) {
      print('Error getting water intake: $e');
      return 0;
    }
  }

  // Get steps taken for today
  Future<int> _getStepsTaken(String date) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 0;

      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('steps')
          .doc(date)
          .get();

      return doc.data()?['count'] ?? 0;
    } catch (e) {
      print('Error getting steps: $e');
      return 0;
    }
  }

  // Get sleep hours for today
  Future<int> _getSleepHours(String date) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 0;

      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('sleep')
          .doc(date)
          .get();

      return doc.data()?['hours'] ?? 0;
    } catch (e) {
      print('Error getting sleep hours: $e');
      return 0;
    }
  }

  // Calculate BMI
  double _calculateBMI(double weight, double height) {
    if (height <= 0) return 0;
    final heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }

  // Determine health status
  String _determineHealthStatus(
    double bmi,
    int caloriesConsumed,
    int caloriesBurned,
  ) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi >= 18.5 && bmi < 25) return 'Normal';
    if (bmi >= 25 && bmi < 30) return 'Overweight';
    if (bmi >= 30) return 'Obese';

    // Additional factors
    if (caloriesConsumed > caloriesBurned + 500) return 'Need Exercise';
    if (caloriesConsumed < caloriesBurned - 500) return 'Need Nutrition';

    return 'Good';
  }

  // Get recent meal plans
  Future<List<MealPlan>> _getRecentMealPlans() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      final today = DateTime.now();
      final List<MealPlan> recentPlans = [];

      // Get meal plans for the last 7 days
      for (int i = 0; i < 7; i++) {
        final date = today.subtract(Duration(days: i));
        final mealPlan = await _mealService.getMealPlanForDate(date);
        if (mealPlan != null) {
          recentPlans.add(mealPlan);
        }
      }

      return recentPlans;
    } catch (e) {
      print('Error getting recent meal plans: $e');
      return [];
    }
  }

  // Update water intake
  Future<void> updateWaterIntake(int amount) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final today = DateTime.now().toIso8601String().split('T')[0];
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('waterIntake')
          .doc(today)
          .set({'amount': amount, 'updatedAt': FieldValue.serverTimestamp()});
    } catch (e) {
      print('Error updating water intake: $e');
    }
  }

  // Update steps
  Future<void> updateSteps(int count) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final today = DateTime.now().toIso8601String().split('T')[0];
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('steps')
          .doc(today)
          .set({'count': count, 'updatedAt': FieldValue.serverTimestamp()});
    } catch (e) {
      print('Error updating steps: $e');
    }
  }

  // Update sleep hours
  Future<void> updateSleepHours(int hours) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final today = DateTime.now().toIso8601String().split('T')[0];
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('sleep')
          .doc(today)
          .set({'hours': hours, 'updatedAt': FieldValue.serverTimestamp()});
    } catch (e) {
      print('Error updating sleep hours: $e');
    }
  }
}
