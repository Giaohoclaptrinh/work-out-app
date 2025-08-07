import '../models/workout.dart';
import '../models/meal.dart';

class DashboardData {
  final int totalCaloriesConsumed;
  final int totalCaloriesBurned;
  final int waterIntake;
  final int stepsTaken;
  final int sleepHours;
  final int workoutsCompleted;
  final int mealsPlanned;
  final double bmi;
  final String healthStatus;
  final List<Workout> recentWorkouts;
  final List<MealPlan> recentMealPlans;

  DashboardData({
    required this.totalCaloriesConsumed,
    required this.totalCaloriesBurned,
    required this.waterIntake,
    required this.stepsTaken,
    required this.sleepHours,
    required this.workoutsCompleted,
    required this.mealsPlanned,
    required this.bmi,
    required this.healthStatus,
    required this.recentWorkouts,
    required this.recentMealPlans,
  });
}
