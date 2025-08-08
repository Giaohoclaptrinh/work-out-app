import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/exercise.dart';

class ExerciseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get all exercises (sorted by name)
  Future<List<Exercise>> getAllExercises() async {
    try {
      final querySnapshot = await _firestore
          .collection('exercises')
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => Exercise.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get exercises: $e');
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
        return Exercise.fromJson(doc.data()!);
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

      return querySnapshot.docs
          .map((doc) => Exercise.fromJson(doc.data()))
          .toList();
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

      return querySnapshot.docs
          .map((doc) => Exercise.fromJson(doc.data()))
          .toList();
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

      return querySnapshot.docs
          .map((doc) => Exercise.fromJson(doc.data()))
          .toList();
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
      await _firestore
          .collection('exercises')
          .doc(exerciseId)
          .delete();
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
        final exercise = Exercise.fromJson(doc.data());
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
        final exercise = Exercise.fromJson(doc.data());
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
        .map((snapshot) =>
            snapshot.docs.map((doc) => Exercise.fromJson(doc.data())).toList());
  }
}
