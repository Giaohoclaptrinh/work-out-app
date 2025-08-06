import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/workout.dart';

class WorkoutService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get user's workouts
  Future<List<Workout>> getUserWorkouts(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('workouts')
          .orderBy('startTime', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Workout.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get user workouts: $e');
    }
  }

  // Get current user's workouts
  Future<List<Workout>> getCurrentUserWorkouts() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');
    return getUserWorkouts(user.uid);
  }

  // Create workout
  Future<void> createWorkout(Workout workout) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('workouts')
          .doc(workout.id)
          .set(workout.toJson());
    } catch (e) {
      throw Exception('Failed to create workout: $e');
    }
  }

  // Update workout
  Future<void> updateWorkout(Workout workout) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('workouts')
          .doc(workout.id)
          .update(workout.toJson());
    } catch (e) {
      throw Exception('Failed to update workout: $e');
    }
  }

  // Delete workout
  Future<void> deleteWorkout(String workoutId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('workouts')
          .doc(workoutId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete workout: $e');
    }
  }

  // Get workout by ID
  Future<Workout?> getWorkout(String workoutId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('workouts')
          .doc(workoutId)
          .get();

      if (doc.exists) {
        return Workout.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get workout: $e');
    }
  }

  // Stream user's workouts
  Stream<List<Workout>> streamUserWorkouts(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('workouts')
        .orderBy('startTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Workout.fromJson(doc.data()))
            .toList());
  }

  // Stream current user's workouts
  Stream<List<Workout>> streamCurrentUserWorkouts() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);
    return streamUserWorkouts(user.uid);
  }

  // Get workouts by date range
  Future<List<Workout>> getWorkoutsByDateRange(
      String userId, DateTime startDate, DateTime endDate) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('workouts')
          .where('startTime', isGreaterThanOrEqualTo: startDate.toIso8601String())
          .where('startTime', isLessThanOrEqualTo: endDate.toIso8601String())
          .orderBy('startTime', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Workout.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get workouts by date range: $e');
    }
  }

  // Get completed workouts count
  Future<int> getCompletedWorkoutsCount(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('workouts')
          .where('completed', isEqualTo: true)
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to get completed workouts count: $e');
    }
  }

  // Get total workout duration
  Future<Duration> getTotalWorkoutDuration(String userId) async {
    try {
      final workouts = await getUserWorkouts(userId);
      int totalSeconds = 0;

      for (final workout in workouts) {
        if (workout.duration != null) {
          totalSeconds += workout.duration!.inSeconds;
        }
      }

      return Duration(seconds: totalSeconds);
    } catch (e) {
      throw Exception('Failed to get total workout duration: $e');
    }
  }
} 