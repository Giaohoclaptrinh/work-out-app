import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/exercise.dart';
import '../models/meal.dart';
import '../utils/debug_helper.dart';

/// Optimized cache service for production use
class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Cache storage
  final Map<String, _CacheItem<List<Exercise>>> _exerciseCache = {};
  final Map<String, _CacheItem<MealPlan?>> _mealCache = {};

  // Cache configuration
  static const Duration _defaultExpiry = Duration(minutes: 5);

  /// Get all workouts with intelligent caching
  Future<List<Exercise>> getWorkouts() async {
    const cacheKey = 'workouts';

    // Return cached data if valid
    if (_exerciseCache.containsKey(cacheKey) &&
        !_exerciseCache[cacheKey]!.isExpired) {
      return _exerciseCache[cacheKey]!.data;
    }

    // Fetch from Firestore
    try {
      final snapshot = await _firestore
          .collection('exercises')
          .where('type', isEqualTo: 'workout')
          .get();

      final workouts =
          snapshot.docs
              .map((doc) => Exercise.fromJson({...doc.data(), 'id': doc.id}))
              .toList()
            ..sort((a, b) => a.name.compareTo(b.name));

      // Cache the result
      _exerciseCache[cacheKey] = _CacheItem(workouts);
      return workouts;
    } catch (e) {
      DebugHelper.logError('Failed to fetch workouts: $e');
      // Return stale cache if available
      return _exerciseCache[cacheKey]?.data ?? [];
    }
  }

  /// Get favorite workouts
  Future<List<Exercise>> getFavoriteWorkouts() async {
    const cacheKey = 'favorites';

    if (_exerciseCache.containsKey(cacheKey) &&
        !_exerciseCache[cacheKey]!.isExpired) {
      return _exerciseCache[cacheKey]!.data;
    }

    try {
      final allWorkouts = await getWorkouts();
      final favorites = allWorkouts
          .where((workout) => workout.isFavorite == true)
          .toList();

      _exerciseCache[cacheKey] = _CacheItem(favorites);
      return favorites;
    } catch (e) {
      DebugHelper.logError('Failed to fetch favorites: $e');
      return _exerciseCache[cacheKey]?.data ?? [];
    }
  }

  /// Get workout history
  Future<List<Exercise>> getWorkoutHistory() async {
    const cacheKey = 'history';

    if (_exerciseCache.containsKey(cacheKey) &&
        !_exerciseCache[cacheKey]!.isExpired) {
      return _exerciseCache[cacheKey]!.data;
    }

    try {
      final allWorkouts = await getWorkouts();
      final history =
          allWorkouts.where((workout) => workout.completedAt != null).toList()
            ..sort((a, b) => b.completedAt!.compareTo(a.completedAt!));

      _exerciseCache[cacheKey] = _CacheItem(history);
      return history;
    } catch (e) {
      DebugHelper.logError('Failed to fetch history: $e');
      return _exerciseCache[cacheKey]?.data ?? [];
    }
  }

  /// Get meal plan for specific date
  Future<MealPlan?> getMealPlan(DateTime date) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final dateStr = date.toIso8601String().split('T')[0];
    final cacheKey = 'meal_${user.uid}_$dateStr';

    if (_mealCache.containsKey(cacheKey) && !_mealCache[cacheKey]!.isExpired) {
      return _mealCache[cacheKey]!.data;
    }

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('mealPlans')
          .where('date', isEqualTo: dateStr)
          .limit(1)
          .get();

      MealPlan? mealPlan;
      if (snapshot.docs.isNotEmpty) {
        mealPlan = MealPlan.fromJson(snapshot.docs.first.data());
      }

      _mealCache[cacheKey] = _CacheItem(mealPlan, Duration(minutes: 10));
      return mealPlan;
    } catch (e) {
      DebugHelper.logError('Failed to fetch meal plan: $e');
      return _mealCache[cacheKey]?.data;
    }
  }

  /// Batch get meal plans for date range
  Future<Map<String, MealPlan?>> getMealPlans(List<DateTime> dates) async {
    final user = _auth.currentUser;
    if (user == null) return {};

    final results = <String, MealPlan?>{};
    final uncachedDates = <String>[];

    // Check cache first
    for (final date in dates) {
      final dateStr = date.toIso8601String().split('T')[0];
      final cacheKey = 'meal_${user.uid}_$dateStr';

      if (_mealCache.containsKey(cacheKey) &&
          !_mealCache[cacheKey]!.isExpired) {
        results[dateStr] = _mealCache[cacheKey]!.data;
      } else {
        uncachedDates.add(dateStr);
      }
    }

    // Batch fetch uncached dates
    if (uncachedDates.isNotEmpty) {
      try {
        final snapshot = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('mealPlans')
            .where('date', whereIn: uncachedDates)
            .get();

        final fetchedPlans = <String, MealPlan>{};
        for (final doc in snapshot.docs) {
          final plan = MealPlan.fromJson(doc.data());
          fetchedPlans[plan.id] = plan;
        }

        // Cache and add to results
        for (final dateStr in uncachedDates) {
          final plan = fetchedPlans[dateStr];
          final cacheKey = 'meal_${user.uid}_$dateStr';

          _mealCache[cacheKey] = _CacheItem(plan, Duration(minutes: 10));
          results[dateStr] = plan;
        }
      } catch (e) {
        DebugHelper.logError('Failed to batch fetch meal plans: $e');
        // Fill missing dates with null
        for (final dateStr in uncachedDates) {
          results[dateStr] = null;
        }
      }
    }

    return results;
  }

  /// Clear specific cache
  void clearCache({String? type}) {
    switch (type) {
      case 'workouts':
        _exerciseCache.clear();
        break;
      case 'meals':
        _mealCache.clear();
        break;
      default:
        _exerciseCache.clear();
        _mealCache.clear();
    }
  }

  /// Get cache statistics
  Map<String, int> getCacheStats() {
    return {
      'workouts': _exerciseCache.length,
      'meals': _mealCache.length,
      'total': _exerciseCache.length + _mealCache.length,
    };
  }
}

/// Cache item with expiry
class _CacheItem<T> {
  final T data;
  final DateTime timestamp;
  final Duration expiry;

  _CacheItem(this.data, [this.expiry = CacheService._defaultExpiry])
    : timestamp = DateTime.now();

  bool get isExpired => DateTime.now().difference(timestamp) > expiry;
}
