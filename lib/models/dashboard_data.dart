import '../models/workout.dart';
import '../models/meal.dart';

class DashboardData {
  final String userId;
  final String userName;
  final String userEmail;
  final double bmi;
  final int totalCaloriesConsumed;
  final int totalCaloriesBurned;
  final int netCalories;
  final double waterIntake;
  final int stepsTaken;
  final double sleepHours;
  final String healthStatus;
  final int workoutsCompletedToday;
  final int totalWorkoutsCompleted;
  final int currentStreak;
  final Map<String, dynamic> weeklyProgress;
  final DateTime lastUpdated;

  DashboardData({
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.bmi,
    required this.totalCaloriesConsumed,
    required this.totalCaloriesBurned,
    required this.netCalories,
    required this.waterIntake,
    required this.stepsTaken,
    required this.sleepHours,
    required this.healthStatus,
    required this.workoutsCompletedToday,
    required this.totalWorkoutsCompleted,
    required this.currentStreak,
    required this.weeklyProgress,
    required this.lastUpdated,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'bmi': bmi,
      'totalCaloriesConsumed': totalCaloriesConsumed,
      'totalCaloriesBurned': totalCaloriesBurned,
      'netCalories': netCalories,
      'waterIntake': waterIntake,
      'stepsTaken': stepsTaken,
      'sleepHours': sleepHours,
      'healthStatus': healthStatus,
      'workoutsCompletedToday': workoutsCompletedToday,
      'totalWorkoutsCompleted': totalWorkoutsCompleted,
      'currentStreak': currentStreak,
      'weeklyProgress': weeklyProgress,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      userEmail: json['userEmail'] ?? '',
      bmi: (json['bmi'] ?? 0.0).toDouble(),
      totalCaloriesConsumed: json['totalCaloriesConsumed'] ?? 0,
      totalCaloriesBurned: json['totalCaloriesBurned'] ?? 0,
      netCalories: json['netCalories'] ?? 0,
      waterIntake: (json['waterIntake'] ?? 0.0).toDouble(),
      stepsTaken: json['stepsTaken'] ?? 0,
      sleepHours: (json['sleepHours'] ?? 0.0).toDouble(),
      healthStatus: json['healthStatus'] ?? 'Unknown',
      workoutsCompletedToday: json['workoutsCompletedToday'] ?? 0,
      totalWorkoutsCompleted: json['totalWorkoutsCompleted'] ?? 0,
      currentStreak: json['currentStreak'] ?? 0,
      weeklyProgress: json['weeklyProgress'] ?? {},
      lastUpdated: DateTime.parse(
        json['lastUpdated'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}
