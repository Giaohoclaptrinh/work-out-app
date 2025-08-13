import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/debug_helper.dart';
import 'calories_tracker_service.dart';
import 'cache_service.dart';

class DailyStatsService {
  static final DailyStatsService _instance = DailyStatsService._internal();
  factory DailyStatsService() => _instance;
  DailyStatsService._internal();

  final FirebaseFirestore _fs = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const _caloriePerKg = 7700;
  static const _opTimeout = Duration(seconds: 12);

  Future<Map<String, dynamic>> logDailyStats({
    required String date, // YYYY-MM-DD
    required int caloriesBurnedKcal,
    required int caloriesConsumedKcal,
    double? weightKg,
    double? previousWeightKg,
    double? heightCm,
    double? defaultHeightCm,
    String notes = '',
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // --- Tính toán ---
    final net = caloriesConsumedKcal - caloriesBurnedKcal;
    final effHeight = heightCm ?? defaultHeightCm;
    final needsHeight = effHeight == null;

    double? calcWeight;
    double? weightChange;
    String estimation = 'measured';

    if (weightKg != null) {
      calcWeight = weightKg;
      estimation = 'measured';
      if (previousWeightKg != null) {
        weightChange = (weightKg - previousWeightKg);
      }
    } else if (previousWeightKg != null) {
      // cho phép ước lượng cân, ngay cả khi thiếu height (BMI sẽ bỏ qua)
      weightChange = (-net) / _caloriePerKg;
      calcWeight = previousWeightKg + weightChange;
      estimation = 'estimated';
    } else {
      estimation = 'unknown';
    }

    double? bmi;
    String? bmiStatus;
    if (calcWeight != null && effHeight != null && effHeight > 0) {
      final h = effHeight / 100.0;
      bmi = calcWeight / (h * h);
      // round hiển thị
      bmi = double.parse(bmi.toStringAsFixed(2));
      if (weightChange != null) {
        weightChange = double.parse(weightChange!.toStringAsFixed(2));
      }
      if (bmi < 18.5) {
        bmiStatus = 'Underweight';
      } else if (bmi < 25) {
        bmiStatus = 'Normal';
      } else if (bmi < 30) {
        bmiStatus = 'Overweight';
      } else {
        bmiStatus = 'Obese';
      }
    }

    // --- Build payload: chỉ add field khi có giá trị ---
    final Map<String, dynamic> daily = {
      'doc_id': date,
      'date': date,
      'calories_burned_kcal': caloriesBurnedKcal,
      'calories_consumed_kcal': caloriesConsumedKcal,
      'net_calories_kcal': net,
      // hiển thị theo unit
      'weight_display': calcWeight,
      'calorie_per_kg': _caloriePerKg,
      'estimation_method': estimation,
      'notes': notes,
      'needs_height': needsHeight,
      'updated_at': FieldValue.serverTimestamp(),
    };
    void add(String k, dynamic v) {
      if (v != null) daily[k] = v;
    }

    add('weight_kg', calcWeight);
    add('previous_weight_kg', previousWeightKg);
    add('height_cm', effHeight);
    add('bmi', bmi);
    add('bmi_status', bmiStatus);
    add('weight_change_kg', weightChange);

    final userRef = _fs.collection('users').doc(user.uid);
    final dailyRef = userRef.collection('daily_stats').doc(date);
    final chartRef = userRef.collection('charts').doc('bmi_progress');

    // --- Simple operations: overwrite daily_stats + append chart point ---
    // daily_stats: always overwrite (merge: true)
    final dailySnap = await dailyRef.get().timeout(_opTimeout);
    if (!dailySnap.exists) {
      daily['created_at'] = FieldValue.serverTimestamp();
    }
    await dailyRef.set(daily, SetOptions(merge: true));

    // --- Update user's current weight/height to reflect measurement/estimation ---
    if (calcWeight != null) {
      await userRef.set({
        'weight': calcWeight,
        if (effHeight != null) 'height': effHeight,
        'weightEstimation': estimation,
        'weightUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    // charts/bmi_progress: append BMI point if available
    if (bmi != null) {
      final chartSnap = await chartRef.get().timeout(_opTimeout);
      List<dynamic> points = [];

      if (chartSnap.exists) {
        final data = chartSnap.data() as Map<String, dynamic>;
        points =
            (((data['series'] ?? {})['bmi'] ?? {})['points'] ?? [])
                as List<dynamic>;
      }

      // Remove existing point for same date
      points = points.where((p) {
        final m = (p as Map<String, dynamic>);
        return m['x_date'] != date;
      }).toList();

      // Add new point
      final point = {
        'x_date': date,
        'x_ts_ms': DateTime.parse(date).millisecondsSinceEpoch,
        'y_bmi': bmi,
        'meta': {'net_calories_kcal': net, 'weight_kg': calcWeight},
      };
      points.add(point);

      // Update chart
      await chartRef.set({
        'series': {
          'bmi': {'points': points},
        },
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    DebugHelper.logCache(
      'Daily stats logged $date → BMI=$bmi, W=${calcWeight ?? '-'}',
    );

    return daily;
  }

  Future<Map<String, dynamic>?> getDailyStats(String date) async {
    final u = _auth.currentUser;
    if (u == null) return null;
    try {
      final snap = await _fs
          .collection('users')
          .doc(u.uid)
          .collection('daily_stats')
          .doc(date)
          .get()
          .timeout(_opTimeout);
      return snap.data();
    } catch (e) {
      DebugHelper.logError('getDailyStats: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getBMIProgress() async {
    final u = _auth.currentUser;
    if (u == null) return null;
    try {
      final snap = await _fs
          .collection('users')
          .doc(u.uid)
          .collection('charts')
          .doc('bmi_progress')
          .get()
          .timeout(_opTimeout);
      return snap.data();
    } catch (e) {
      DebugHelper.logError('getBMIProgress: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getWeeklyStats() async {
    final u = _auth.currentUser;
    if (u == null) return [];
    try {
      final now = DateTime.now();
      final start = now.subtract(Duration(days: now.weekday - 1));
      String fmt(DateTime d) =>
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

      final qs = await _fs
          .collection('users')
          .doc(u.uid)
          .collection('daily_stats')
          .where('date', isGreaterThanOrEqualTo: fmt(start))
          .where('date', isLessThanOrEqualTo: fmt(now))
          .orderBy('date')
          .get()
          .timeout(_opTimeout);

      return qs.docs.map((d) => d.data()).toList();
    } catch (e) {
      DebugHelper.logError('getWeeklyStats: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getMonthlyStats() async {
    final u = _auth.currentUser;
    if (u == null) return [];
    try {
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, 1);
      String fmt(DateTime d) =>
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

      final qs = await _fs
          .collection('users')
          .doc(u.uid)
          .collection('daily_stats')
          .where('date', isGreaterThanOrEqualTo: fmt(start))
          .where('date', isLessThanOrEqualTo: fmt(now))
          .orderBy('date')
          .get()
          .timeout(_opTimeout);

      return qs.docs.map((d) => d.data()).toList();
    } catch (e) {
      DebugHelper.logError('getMonthlyStats: $e');
      return [];
    }
  }

  Future<void> autoLogTodayStats({
    double? weightKg,
    double? previousWeightKg,
    double? heightCm,
    double? defaultHeightCm,
    String notes = '',
  }) async {
    try {
      final today = DateTime.now();
      String fmt(DateTime d) =>
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      final dateStr = fmt(today);

      // Get user profile data automatically
      final userProfile = await _getUserProfile();
      final userWeight = weightKg ?? userProfile['weight']?.toDouble();
      final userHeight = heightCm ?? userProfile['height']?.toDouble();

      // Get previous weight from yesterday's stats if not provided
      double? prevWeight = previousWeightKg;
      if (prevWeight == null) {
        final yesterday = today.subtract(const Duration(days: 1));
        final yesterdayStr = fmt(yesterday);
        final yesterdayStats = await getDailyStats(yesterdayStr);
        prevWeight = yesterdayStats?['weight_kg']?.toDouble();
      }

      final caloriesTracker = CaloriesTrackerService();
      final burned = await caloriesTracker.getTodayCaloriesBurned();

      final cache = CacheService();
      final meal = await cache.getMealPlan(today);
      final consumed = _getTotalCalories(meal);

      await logDailyStats(
        date: dateStr,
        caloriesBurnedKcal: burned,
        caloriesConsumedKcal: consumed,
        weightKg: userWeight,
        previousWeightKg: prevWeight,
        heightCm: userHeight,
        defaultHeightCm: defaultHeightCm,
        notes: notes,
      );
      DebugHelper.logCache(
        'Auto-logged today: burned=$burned, consumed=$consumed, weight=$userWeight, height=$userHeight',
      );
    } catch (e) {
      DebugHelper.logError('autoLogTodayStats: $e');
    }
  }

  /// Get current user profile data
  Future<Map<String, dynamic>> _getUserProfile() async {
    final u = _auth.currentUser;
    if (u == null) return {};

    try {
      final snap = await _fs
          .collection('users')
          .doc(u.uid)
          .get()
          .timeout(_opTimeout);
      return snap.data() ?? {};
    } catch (e) {
      DebugHelper.logError('getUserProfile: $e');
      return {};
    }
  }

  int _getTotalCalories(dynamic mealPlan) {
    if (mealPlan == null) return 2000;
    try {
      int total = 0;
      if (mealPlan is Map<String, dynamic>) {
        total += _calcMeal(mealPlan['breakfast']);
        total += _calcMeal(mealPlan['lunch']);
        total += _calcMeal(mealPlan['dinner']);
        total += _calcMeal(mealPlan['snacks']);
      }
      return total > 0 ? total : 2000;
    } catch (e) {
      DebugHelper.logError('calc meal calories: $e');
      return 2000;
    }
  }

  int _calcMeal(dynamic meal) {
    if (meal == null) return 0;
    try {
      if (meal is List) {
        return meal.fold<int>(0, (sum, item) {
          final c = (item is Map && item['calories'] != null)
              ? (item['calories'] as num).toInt()
              : 0;
          return sum + c;
        });
      } else if (meal is Map && meal['calories'] != null) {
        return (meal['calories'] as num).toInt();
      }
      return 0;
    } catch (_) {
      return 0;
    }
  }
}
