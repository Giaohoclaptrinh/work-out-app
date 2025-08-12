import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/exercise.dart';

import 'calories_tracker_service.dart';

class ExerciseService {
  static final ExerciseService _instance = ExerciseService._internal();
  factory ExerciseService() => _instance;
  ExerciseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
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

  /// Get all workouts from workouts collection
  Future<List<Exercise>> getAllWorkouts() async {
    try {
      final snapshot = await _firestore.collection('workouts').get();
      return snapshot.docs.map(_documentToWorkoutExercise).toList();
    } catch (e) {
      throw Exception('Failed to get workouts: $e');
    }
  }

  /// Get favorite workouts
  Future<List<Exercise>> getFavoriteWorkouts() async {
    try {
      final querySnapshot = await _firestore.collection('workouts').get();

      final exercises = querySnapshot.docs
          .map(_documentToWorkoutExercise)
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
      final List<Exercise> all = [];

      // Core workouts
      final coreSnapshot = await _firestore.collection('workouts').get();
      all.addAll(
        coreSnapshot.docs
            .map(_documentToWorkoutExercise)
            .where((e) => e.completedAt != null),
      );

      // User custom workouts
      final user = _auth.currentUser;
      if (user != null) {
        final customSnapshot = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('customWorkouts')
            .get();
        all.addAll(
          customSnapshot.docs
              .map(_documentToCustomExercise)
              .where((e) => e.completedAt != null),
        );
      }

      all.sort((a, b) {
        if (a.completedAt == null && b.completedAt == null) return 0;
        if (a.completedAt == null) return 1;
        if (b.completedAt == null) return -1;
        return b.completedAt!.compareTo(a.completedAt!);
      });
      return all;
    } catch (e) {
      throw Exception('Failed to get workout history: $e');
    }
  }

  /// Toggle favorite status
  Future<void> toggleFavorite(String exerciseId) async {
    try {
      final doc = await _firestore.collection('workouts').doc(exerciseId).get();
      if (doc.exists) {
        final currentFavorite = doc.data()?['isFavorite'] as bool? ?? false;
        await _firestore.collection('workouts').doc(exerciseId).update({
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
      // Try core workouts first
      final coreDoc = await _firestore
          .collection('workouts')
          .doc(exerciseId)
          .get();

      String workoutName = 'Unknown Workout';
      int calories = 100;

      if (coreDoc.exists) {
        final coreData = coreDoc.data()!;
        workoutName = coreData['name'] as String? ?? 'Unknown Workout';
        calories = (coreData['calories'] as num?)?.toInt() ?? 100;
        final now = DateTime.now();
        await _firestore.collection('workouts').doc(exerciseId).update({
          'completedAt': now,
          'updatedAt': now,
        });
      } else {
        // Fallback to user's custom workouts
        final user = _auth.currentUser;
        if (user == null) throw Exception('User not authenticated');
        final customDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('customWorkouts')
            .doc(exerciseId)
            .get();
        if (!customDoc.exists) throw Exception('Workout not found');

        final data = customDoc.data()!;
        workoutName = data['name'] as String? ?? 'Unknown Workout';
        calories = (data['calories'] as num?)?.toInt() ?? 100;
        final now = DateTime.now();
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('customWorkouts')
            .doc(exerciseId)
            .update({'completedAt': now, 'updatedAt': now});
      }

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

  /// Save or update a custom workout for the current user
  Future<String> saveCustomWorkout(Exercise exercise) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final docRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('customWorkouts')
          .doc(exercise.id);

      await docRef.set({
        'name': exercise.name,
        'description': exercise.description,
        'category': exercise.category,
        'difficulty': exercise.difficulty,
        'duration': exercise.duration,
        'calories': exercise.calories,
        'equipment': exercise.equipment,
        'image': exercise.imageUrl,
        'muscleGroups': exercise.muscleGroups,
        'isFavorite': exercise.isFavorite,
        'type': exercise.type,
        'videoUrl': exercise.workout?['videoUrl'],
        'youtubeId': exercise.workout?['youtubeId'],
        'thumbnailUrl': exercise.workout?['thumbnailUrl'],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to save custom workout: $e');
    }
  }

  /// Get user's custom workouts
  Future<List<Exercise>> getUserCustomWorkouts() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('customWorkouts')
          .get();
      return snapshot.docs.map(_documentToCustomExercise).toList();
    } catch (e) {
      throw Exception('Failed to get custom workouts: $e');
    }
  }

  /// Helper method to convert Firestore document to Exercise
  Exercise _documentToExercise(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id;
    return Exercise.fromJson(data);
  }

  /// Helper method to convert workout document to Exercise
  Exercise _documentToWorkoutExercise(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id;

    // Convert workout data to Exercise format
    return Exercise(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      imageUrl: data['image'],
      muscleGroups: List<String>.from(data['muscleGroups'] ?? []),
      instructions:
          data['description'] ?? '', // Use description as instructions
      difficulty: data['difficulty'],
      equipment: data['equipment'],
      duration: data['duration'],
      calories: data['calories'],
      steps: data['steps'] != null
          ? (data['steps'] as List)
                .map((step) => WorkoutStep.fromJson(step))
                .toList()
          : null,
      isFavorite: data['isFavorite'] ?? false,
      completedAt: data['completedAt']?.toDate(),
      type: 'workout',
      workout: data, // This contains videoUrl
    );
  }

  /// Helper: convert a user's custom workout document to Exercise
  Exercise _documentToCustomExercise(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id;

    return Exercise(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? 'Custom',
      imageUrl: data['image'] ?? data['thumbnailUrl'],
      muscleGroups: List<String>.from(data['muscleGroups'] ?? []),
      instructions: data['description'] ?? '',
      difficulty: data['difficulty'],
      equipment: data['equipment'],
      duration: data['duration'],
      calories: data['calories'],
      steps: null,
      isFavorite: data['isFavorite'] ?? false,
      completedAt: data['completedAt'] is Timestamp
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
      type: data['type'] ?? 'custom',
      workout: data,
    );
  }
}
