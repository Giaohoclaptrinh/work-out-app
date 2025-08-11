import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/dashboard_data.dart';
import '../models/exercise.dart';
import '../models/meal.dart';
import 'cache_service.dart';
import '../utils/debug_helper.dart';

class DashboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CacheService _cache = CacheService();

  /// Get comprehensive dashboard data with optimized caching
  Future<DashboardData> getDashboardData({bool forceRefresh = false}) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    try {
      final today = DateTime.now();

      // Force refresh workout history if requested
      List<Exercise> workoutHistory;
      if (forceRefresh) {
        workoutHistory = await _cache.forceRefreshWorkoutHistory();
      } else {
        workoutHistory = await _cache.getWorkoutHistory();
      }

      // Parallel data fetching for better performance
      final futures = await Future.wait([
        _getUserProfile(user.uid),
        Future.value(workoutHistory), // Use already fetched data
        _cache.getMealPlan(today),
        _getUserStats(user.uid, today),
      ]);

      final userProfile = futures[0] as Map<String, dynamic>;
      final todayMeal = futures[2] as MealPlan?;
      final userStats = futures[3] as Map<String, dynamic>;

      // Calculate metrics
      final todaysWorkouts = workoutHistory
          .where(
            (w) => w.completedAt != null && _isSameDay(w.completedAt!, today),
          )
          .toList();

      final bmi = _calculateBMI(
        userProfile['weight'] ?? 70,
        userProfile['height'] ?? 170,
      );

      final caloriesConsumed = _getTotalCalories(todayMeal);
      final caloriesBurned = todaysWorkouts.fold(
        0,
        (total, workout) => total + (workout.calories ?? 0),
      );

      return DashboardData(
        userId: user.uid,
        userName: userProfile['displayName'] ?? 'User',
        userEmail: userProfile['email'] ?? user.email ?? '',
        bmi: bmi,
        totalCaloriesConsumed: caloriesConsumed,
        totalCaloriesBurned: caloriesBurned,
        netCalories: caloriesConsumed - caloriesBurned,
        waterIntake: (userStats['waterIntake'] ?? 0.0).toDouble(),
        stepsTaken: userStats['stepsTaken'] ?? 0,
        sleepHours: (userStats['sleepHours'] ?? 0.0).toDouble(),
        healthStatus: _getHealthStatus(bmi, caloriesConsumed, caloriesBurned),
        workoutsCompletedToday: todaysWorkouts.length,
        totalWorkoutsCompleted: workoutHistory.length,
        currentStreak: _calculateStreak(workoutHistory),
        weeklyProgress: _getWeeklyProgress(workoutHistory),
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      DebugHelper.logError('Dashboard data error: $e');
      throw Exception('Failed to load dashboard data');
    }
  }

  /// Setup real-time updates for dashboard
  void setupRealTimeUpdates(Function() onDataChanged) {
    _cache.setupRealTimeListeners((cacheKey) {
      onDataChanged();
    });
  }

  /// Stop real-time updates
  void stopRealTimeUpdates() {
    _cache.stopListeners();
  }

  /// Test cache invalidation
  void testCacheInvalidation() {
    _cache.testCacheInvalidation();
  }

  /// Force clear all cache
  void forceClearAllCache() {
    _cache.forceClearAllCache();
  }

  /// Get batch meal plans for date range
  Future<Map<String, MealPlan?>> getMealPlansForWeek(DateTime startDate) async {
    final dates = List.generate(
      7,
      (index) => startDate.add(Duration(days: index)),
    );
    return await _cache.getMealPlans(dates);
  }

  Future<Map<String, dynamic>> _getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.data() ?? {};
    } catch (e) {
      return {};
    }
  }

  Future<Map<String, dynamic>> _getUserStats(
    String userId,
    DateTime date,
  ) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0];
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('dailyStats')
          .doc(dateStr)
          .get();

      return doc.exists ? doc.data()! : _getDefaultStats();
    } catch (e) {
      return _getDefaultStats();
    }
  }

  Map<String, dynamic> _getDefaultStats() {
    return {'waterIntake': 0.0, 'stepsTaken': 0, 'sleepHours': 0.0};
  }

  double _calculateBMI(dynamic weight, dynamic height) {
    try {
      final w = (weight is num) ? weight.toDouble() : double.parse('$weight');
      final h = (height is num) ? height.toDouble() : double.parse('$height');

      if (h <= 0) return 0.0;

      final heightM = h / 100;
      return w / (heightM * heightM);
    } catch (e) {
      return 0.0;
    }
  }

  int _getTotalCalories(MealPlan? mealPlan) {
    if (mealPlan == null) return 0;

    int total = 0;
    for (final meals in mealPlan.meals.values) {
      for (final meal in meals) {
        total += meal.calories;
      }
    }
    return total;
  }

  String _getHealthStatus(double bmi, int caloriesIn, int caloriesOut) {
    final factors = <String>[];

    if (bmi >= 18.5 && bmi < 25) factors.add('healthy_weight');
    if ((caloriesIn - caloriesOut).abs() <= 500) {
      factors.add('balanced_calories');
    }

    return factors.length >= 2
        ? 'Good'
        : factors.length == 1
        ? 'Fair'
        : 'Needs Improvement';
  }

  int _calculateStreak(List<Exercise> history) {
    if (history.isEmpty) return 0;

    final today = DateTime.now();
    int streak = 0;

    final sorted = history.where((w) => w.completedAt != null).toList()
      ..sort((a, b) => b.completedAt!.compareTo(a.completedAt!));

    DateTime? lastDate;
    for (final workout in sorted) {
      final workoutDate = workout.completedAt!;

      if (lastDate == null) {
        if (_isSameDay(workoutDate, today) ||
            _isSameDay(workoutDate, today.subtract(Duration(days: 1)))) {
          streak = 1;
          lastDate = workoutDate;
        } else {
          break;
        }
      } else {
        final expected = lastDate.subtract(Duration(days: 1));
        if (_isSameDay(workoutDate, expected)) {
          streak++;
          lastDate = workoutDate;
        } else if (!_isSameDay(workoutDate, lastDate)) {
          break;
        }
      }
    }

    return streak;
  }

  Map<String, dynamic> _getWeeklyProgress(List<Exercise> history) {
    final today = DateTime.now();
    final weekStart = today.subtract(Duration(days: today.weekday - 1));

    final thisWeek = history
        .where(
          (w) => w.completedAt != null && w.completedAt!.isAfter(weekStart),
        )
        .toList();

    return {
      'workouts': thisWeek.length,
      'calories': thisWeek.fold(0, (total, w) => total + (w.calories ?? 0)),
      'goal': 5,
      'progress': (thisWeek.length / 5.0).clamp(0.0, 1.0),
    };
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Clear cache for fresh data
  void clearCache() => _cache.clearCache();

  /// Get cache statistics
  Map<String, dynamic> getCacheStats() => _cache.getCacheStats();
}
