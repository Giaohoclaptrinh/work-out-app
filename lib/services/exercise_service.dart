import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/exercise.dart';
import '../utils/debug_helper.dart';
import 'calories_tracker_service.dart';

class ExerciseService {
  static final ExerciseService _instance = ExerciseService._internal();
  factory ExerciseService() => _instance;
  ExerciseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CaloriesTrackerService _caloriesTracker = CaloriesTrackerService();

  /// Get all exercises
  Future<List<Exercise>> getAllExercises() async {
    try {
      final snapshot = await _firestore.collection('exercises').get();
      return snapshot.docs.map(_documentToExercise).toList();
    } catch (e) {
      throw Exception('Failed to get exercises: $e');
    }
  }

  /// Get all workouts (exercises with type 'workout')
  Future<List<Exercise>> getAllWorkouts() async {
    try {
      final snapshot = await _firestore
          .collection('exercises')
          .where('type', isEqualTo: 'workout')
          .get();
      return snapshot.docs.map(_documentToExercise).toList();
    } catch (e) {
      throw Exception('Failed to get workouts: $e');
    }
  }

  /// Get exercise by ID
  Future<Exercise?> getExerciseById(String id) async {
    try {
      final doc = await _firestore.collection('exercises').doc(id).get();
      if (doc.exists) {
        return _documentToExercise(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get exercise: $e');
    }
  }

  /// Create new exercise
  Future<void> createExercise(Exercise exercise) async {
    try {
      await _firestore.collection('exercises').add(exercise.toJson());
    } catch (e) {
      throw Exception('Failed to create exercise: $e');
    }
  }

  /// Update exercise
  Future<void> updateExercise(String id, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('exercises').doc(id).update(data);
    } catch (e) {
      throw Exception('Failed to update exercise: $e');
    }
  }

  /// Delete exercise
  Future<void> deleteExercise(String id) async {
    try {
      await _firestore.collection('exercises').doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete exercise: $e');
    }
  }

  /// Get exercises by category
  Future<List<Exercise>> getExercisesByCategory(String category) async {
    try {
      final snapshot = await _firestore
          .collection('exercises')
          .where('category', isEqualTo: category)
          .get();
      return snapshot.docs.map(_documentToExercise).toList();
    } catch (e) {
      throw Exception('Failed to get exercises by category: $e');
    }
  }

  /// Get exercises by muscle group
  Future<List<Exercise>> getExercisesByMuscleGroup(String muscleGroup) async {
    try {
      final snapshot = await _firestore
          .collection('exercises')
          .where('muscleGroups', arrayContains: muscleGroup)
          .get();
      return snapshot.docs.map(_documentToExercise).toList();
    } catch (e) {
      throw Exception('Failed to get exercises by muscle group: $e');
    }
  }

  /// Search exercises by name
  Future<List<Exercise>> searchExercises(String query) async {
    try {
      final snapshot = await _firestore
          .collection('exercises')
          .orderBy('name')
          .startAt([query])
          .endAt([query + '\uf8ff'])
          .get();
      return snapshot.docs.map(_documentToExercise).toList();
    } catch (e) {
      throw Exception('Failed to search exercises: $e');
    }
  }

  /// Get exercises with real-time updates
  Stream<List<Exercise>> getExercisesStream() {
    return _firestore
        .collection('exercises')
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_documentToExercise).toList());
  }

  /// Get favorite workouts
  Future<List<Exercise>> getFavoriteWorkouts() async {
    try {
      // Simplified query: only filter by type, then filter isFavorite in memory
      final querySnapshot = await _firestore
          .collection('exercises')
          .where('type', isEqualTo: 'workout')
          .get();

      final exercises = querySnapshot.docs
          .map((doc) => Exercise.fromJson(doc.data()))
          .where((exercise) => exercise.isFavorite == true) // Filter in memory
          .toList();

      // Sort in memory
      exercises.sort((a, b) => a.name.compareTo(b.name));
      return exercises;
    } catch (e) {
      throw Exception('Failed to get favorite workouts: $e');
    }
  }

  /// Get workout history (completed workouts)
  Future<List<Exercise>> getWorkoutHistory() async {
    try {
      // Simplified query: only filter by type, then filter completedAt in memory
      final querySnapshot = await _firestore
          .collection('exercises')
          .where('type', isEqualTo: 'workout')
          .get();

      final exercises = querySnapshot.docs
          .map((doc) => Exercise.fromJson(doc.data()))
          .where((exercise) => exercise.completedAt != null) // Filter in memory
          .toList();

      // Sort in memory by completedAt descending
      exercises.sort((a, b) {
        if (a.completedAt == null && b.completedAt == null) return 0;
        if (a.completedAt == null) return 1;
        if (b.completedAt == null) return -1;
        return b.completedAt!.compareTo(a.completedAt!);
      });
      return exercises;
    } catch (e) {
      throw Exception('Failed to get workout history: $e');
    }
  }

  /// Toggle favorite status
  Future<void> toggleFavorite(String exerciseId) async {
    try {
      final doc = await _firestore
          .collection('exercises')
          .doc(exerciseId)
          .get();
      if (doc.exists) {
        final currentFavorite = doc.data()?['isFavorite'] as bool? ?? false;
        await _firestore.collection('exercises').doc(exerciseId).update({
          'isFavorite': !currentFavorite,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception('Failed to toggle favorite: $e');
    }
  }

  /// Mark workout as completed and track calories burned
  Future<void> completeWorkout(String exerciseId) async {
    try {
      // Get workout details first
      final doc = await _firestore
          .collection('exercises')
          .doc(exerciseId)
          .get();
      if (!doc.exists) {
        throw Exception('Workout not found');
      }

      final workoutData = doc.data()!;
      final workoutName = workoutData['name'] as String? ?? 'Unknown Workout';
      final calories =
          (workoutData['calories'] as num?)?.toInt() ??
          100; // Default 100 calories

      // Use client timestamp for immediate real-time updates
      final now = DateTime.now();
      await _firestore.collection('exercises').doc(exerciseId).update({
        'completedAt': now,
        'updatedAt': now,
      });

      // Track calories burned
      await _caloriesTracker.addCaloriesBurned(
        exerciseId,
        workoutName,
        calories,
      );
    } catch (e) {
      throw Exception('Failed to complete workout: $e');
    }
  }

  /// Get workout tips
  Future<List<Map<String, dynamic>>> getWorkoutTips() async {
    try {
      final snapshot = await _firestore.collection('workoutTips').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get workout tips: $e');
    }
  }

  /// Helper method to convert Firestore document to Exercise
  Exercise _documentToExercise(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id;
    return Exercise.fromJson(data);
  }
}
