import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/exercise.dart';

class ExerciseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Helper method to convert Firestore document to Exercise with proper ID
  Exercise _documentToExercise(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    data['id'] = doc.id; // Ensure document ID is included
    return Exercise.fromJson(data);
  }

  /// Get all exercises (both basic exercises and workouts)
  Future<List<Exercise>> getAllExercises() async {
    try {
      final querySnapshot = await _firestore
          .collection('exercises')
          .orderBy('name')
          .get();

      return querySnapshot.docs.map(_documentToExercise).toList();
    } catch (e) {
      throw Exception('Failed to get exercises: $e');
    }
  }

  /// Get only workout-type exercises
  Future<List<Exercise>> getAllWorkouts() async {
    try {
      final querySnapshot = await _firestore
          .collection('exercises')
          .where('type', isEqualTo: 'workout')
          .get();

      final exercises = querySnapshot.docs.map(_documentToExercise).toList();

      // Sort in memory
      exercises.sort((a, b) => a.name.compareTo(b.name));
      return exercises;
    } catch (e) {
      throw Exception('Failed to get workouts: $e');
    }
  }

  /// Get only basic exercise-type exercises
  Future<List<Exercise>> getBasicExercises() async {
    try {
      final querySnapshot = await _firestore
          .collection('exercises')
          .where('type', isEqualTo: 'exercise')
          .get();

      final exercises = querySnapshot.docs.map(_documentToExercise).toList();

      // Sort in memory
      exercises.sort((a, b) => a.name.compareTo(b.name));
      return exercises;
    } catch (e) {
      throw Exception('Failed to get basic exercises: $e');
    }
  }

  /// Get exercise by ID
  Future<Exercise?> getExercise(String exerciseId) async {
    try {
      final doc = await _firestore
          .collection('exercises')
          .doc(exerciseId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id; // Add document ID
        return Exercise.fromJson(data);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get exercise: $e');
    }
  }

  /// Get exercises by category
  Future<List<Exercise>> getExercisesByCategory(String category) async {
    try {
      final querySnapshot = await _firestore
          .collection('exercises')
          .where('category', isEqualTo: category)
          .orderBy('name')
          .get();

      return querySnapshot.docs.map(_documentToExercise).toList();
    } catch (e) {
      throw Exception('Failed to get exercises by category: $e');
    }
  }

  /// Get exercises by muscle group
  Future<List<Exercise>> getExercisesByMuscleGroup(String muscleGroup) async {
    try {
      final querySnapshot = await _firestore
          .collection('exercises')
          .where('muscleGroups', arrayContains: muscleGroup)
          .orderBy('name')
          .get();

      return querySnapshot.docs.map(_documentToExercise).toList();
    } catch (e) {
      throw Exception('Failed to get exercises by muscle group: $e');
    }
  }

  /// Search exercises by name
  Future<List<Exercise>> searchExercises(String query) async {
    try {
      final querySnapshot = await _firestore
          .collection('exercises')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: '$query\uf8ff')
          .orderBy('name')
          .get();

      return querySnapshot.docs.map(_documentToExercise).toList();
    } catch (e) {
      throw Exception('Failed to search exercises: $e');
    }
  }

  /// Create new exercise (admin)
  Future<void> createExercise(Exercise exercise) async {
    try {
      await _firestore
          .collection('exercises')
          .doc(exercise.id)
          .set(exercise.toJson());
    } catch (e) {
      throw Exception('Failed to create exercise: $e');
    }
  }

  /// Update existing exercise (admin)
  Future<void> updateExercise(Exercise exercise) async {
    try {
      await _firestore
          .collection('exercises')
          .doc(exercise.id)
          .update(exercise.toJson());
    } catch (e) {
      throw Exception('Failed to update exercise: $e');
    }
  }

  /// Delete exercise (admin)
  Future<void> deleteExercise(String exerciseId) async {
    try {
      await _firestore.collection('exercises').doc(exerciseId).delete();
    } catch (e) {
      throw Exception('Failed to delete exercise: $e');
    }
  }

  /// Get all unique categories
  Future<List<String>> getAllCategories() async {
    try {
      final querySnapshot = await _firestore.collection('exercises').get();

      final categories = <String>{};
      for (final doc in querySnapshot.docs) {
        final exercise = _documentToExercise(doc);
        categories.add(exercise.category);
      }

      return categories.toList()..sort();
    } catch (e) {
      throw Exception('Failed to get categories: $e');
    }
  }

  /// Get all unique muscle groups
  Future<List<String>> getAllMuscleGroups() async {
    try {
      final querySnapshot = await _firestore.collection('exercises').get();

      final muscleGroups = <String>{};
      for (final doc in querySnapshot.docs) {
        final exercise = _documentToExercise(doc);
        muscleGroups.addAll(exercise.muscleGroups);
      }

      return muscleGroups.toList()..sort();
    } catch (e) {
      throw Exception('Failed to get muscle groups: $e');
    }
  }

  /// Stream all exercises (real-time updates)
  Stream<List<Exercise>> streamAllExercises() {
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

  /// Mark workout as completed
  Future<void> completeWorkout(String exerciseId) async {
    try {
      await _firestore.collection('exercises').doc(exerciseId).update({
        'completedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
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
}
