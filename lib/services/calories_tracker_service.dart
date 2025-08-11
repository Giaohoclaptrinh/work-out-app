import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/debug_helper.dart';

class CaloriesTrackerService {
  static final CaloriesTrackerService _instance =
      CaloriesTrackerService._internal();
  factory CaloriesTrackerService() => _instance;
  CaloriesTrackerService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get today's total calories burned
  Future<int> getTodayCaloriesBurned() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 0;

      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('workout_history')
          .where('completedAt', isGreaterThanOrEqualTo: startOfDay)
          .where('completedAt', isLessThan: endOfDay)
          .get();

      int totalCalories = 0;
      for (final doc in snapshot.docs) {
        final data = doc.data();
        totalCalories += (data['calories'] as num?)?.toInt() ?? 0;
      }

      return totalCalories;
    } catch (e) {
      DebugHelper.logError('Error getting today calories burned: $e');
      return 0;
    }
  }

  /// Add calories burned from a completed workout
  Future<void> addCaloriesBurned(
    String workoutId,
    String workoutName,
    int calories,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final workoutData = {
        'workoutId': workoutId,
        'workoutName': workoutName,
        'calories': calories,
        'completedAt': FieldValue.serverTimestamp(),
        'date': DateTime.now().toIso8601String(),
      };

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('workout_history')
          .add(workoutData);
    } catch (e) {
      DebugHelper.logError('Error adding calories burned: $e');
    }
  }

  /// Get weekly calories burned
  Future<Map<String, int>> getWeeklyCaloriesBurned() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return {};

      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final startOfWeekDay = DateTime(
        startOfWeek.year,
        startOfWeek.month,
        startOfWeek.day,
      );

      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('workout_history')
          .where('completedAt', isGreaterThanOrEqualTo: startOfWeekDay)
          .get();

      final Map<String, int> weeklyCalories = {};

      // Initialize all days of the week with 0
      for (int i = 0; i < 7; i++) {
        final day = startOfWeekDay.add(Duration(days: i));
        final dayKey =
            '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
        weeklyCalories[dayKey] = 0;
      }

      // Add calories for each completed workout
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final completedAt = data['completedAt'] as Timestamp?;
        if (completedAt != null) {
          final day = completedAt.toDate();
          final dayKey =
              '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
          weeklyCalories[dayKey] =
              (weeklyCalories[dayKey] ?? 0) +
              ((data['calories'] as num?)?.toInt() ?? 0);
        }
      }

      return weeklyCalories;
    } catch (e) {
      DebugHelper.logError('Error getting weekly calories burned: $e');
      return {};
    }
  }

  /// Get total calories burned for a specific date range
  Future<int> getCaloriesBurnedForDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 0;

      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('workout_history')
          .where('completedAt', isGreaterThanOrEqualTo: startDate)
          .where(
            'completedAt',
            isLessThan: endDate.add(const Duration(days: 1)),
          )
          .get();

      int totalCalories = 0;
      for (final doc in snapshot.docs) {
        final data = doc.data();
        totalCalories += (data['calories'] as num?)?.toInt() ?? 0;
      }

      return totalCalories;
    } catch (e) {
      DebugHelper.logError('Error getting calories for date range: $e');
      return 0;
    }
  }

  /// Clear all workout history (for testing)
  Future<void> clearWorkoutHistory() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('workout_history')
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      DebugHelper.logError('Error clearing workout history: $e');
    }
  }
}
