import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/workout.dart';
import 'dart:convert'; // Added for json.decode
import 'package:flutter/services.dart'; // Added for rootBundle

class WorkoutService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Lấy danh sách tất cả workouts
  Future<List<Workout>> getAllWorkouts() async {
    try {
      // First try to get from Firestore
      final snapshot = await _firestore.collection('workouts').get();
      List<Workout> workouts = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Workout.fromJson(data);
      }).toList();

      print('Found ${workouts.length} workouts in Firestore');

      // Return workouts from Firestore
      if (workouts.isEmpty) {
        print('No workouts found in Firestore');
      }

      print('Returning ${workouts.length} total workouts');
      return workouts;
    } catch (e) {
      print('Error fetching workouts: $e');
      return [];
    }
  }

  // Lấy workouts theo category
  Future<List<Workout>> getWorkoutsByCategory(String category) async {
    try {
      final snapshot = await _firestore
          .collection('workouts')
          .where('category', isEqualTo: category)
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Workout.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error fetching workouts by category: $e');
      return [];
    }
  }

  // Lấy workout chi tiết theo ID
  Future<Workout?> getWorkoutById(String workoutId) async {
    try {
      print('Fetching workout by ID: $workoutId');
      final doc = await _firestore.collection('workouts').doc(workoutId).get();
      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        final workout = Workout.fromJson(data);
        print('Found workout: ${workout.name}');
        return workout;
      }
      print('Workout not found in Firestore: $workoutId');
      return null;
    } catch (e) {
      print('Error fetching workout by ID: $e');
      return null;
    }
  }

  // Lấy workouts yêu thích của user
  Future<List<Workout>> getFavoriteWorkouts() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .get();

      List<Workout> favorites = [];
      for (var doc in snapshot.docs) {
        final workout = await getWorkoutById(doc.id);
        if (workout != null) {
          favorites.add(workout.copyWith(isFavorite: true));
        }
      }
      return favorites;
    } catch (e) {
      print('Error fetching favorite workouts: $e');
      return [];
    }
  }

  // Thêm workout vào favorites
  Future<void> addToFavorites(String workoutId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(workoutId)
          .set({'addedAt': FieldValue.serverTimestamp()});
    } catch (e) {
      print('Error adding to favorites: $e');
    }
  }

  // Xóa workout khỏi favorites
  Future<void> removeFromFavorites(String workoutId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(workoutId)
          .delete();
    } catch (e) {
      print('Error removing from favorites: $e');
    }
  }

  // Kiểm tra workout có trong favorites không
  Future<bool> isFavorite(String workoutId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(workoutId)
          .get();

      return doc.exists;
    } catch (e) {
      print('Error checking favorite status: $e');
      return false;
    }
  }

  // Lấy lịch sử workouts đã hoàn thành
  Future<List<Workout>> getWorkoutHistory() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('User not authenticated for history');
        return [];
      }

      print('Fetching workout history for user: ${user.uid}');

      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('workoutHistory')
          .orderBy('completedAt', descending: true)
          .get();

      print('Found ${snapshot.docs.length} completed workouts');

      List<Workout> history = [];
      for (var doc in snapshot.docs) {
        print('Processing history doc: ${doc.id}');
        final data = doc.data();
        final workoutId = data['workoutId'] as String?;

        if (workoutId != null) {
          print('Looking for workout with ID: $workoutId');
          final workout = await getWorkoutById(workoutId);
          if (workout != null) {
            history.add(
              workout.copyWith(completedAt: data['completedAt']?.toDate()),
            );
            print('Added workout to history: ${workout.name}');
          } else {
            print('Workout not found for ID: $workoutId');
          }
        } else {
          print('No workoutId found in history doc: ${doc.id}');
        }
      }

      print('Returning ${history.length} workouts in history');
      return history;
    } catch (e) {
      print('Error fetching workout history: $e');
      return [];
    }
  }

  // Thêm workout vào lịch sử (hoàn thành)
  Future<void> completeWorkout(String workoutId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('User not authenticated');
        return;
      }

      print('Completing workout: $workoutId for user: ${user.uid}');

      // Cập nhật trực tiếp vào workout document với completedAt
      await _firestore.collection('workouts').doc(workoutId).update({
        'completedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('Workout completed successfully: $workoutId');
    } catch (e) {
      print('Error completing workout: $e');
    }
  }

  // Đảm bảo workout tồn tại trong Firestore
  Future<void> _ensureWorkoutExists(String workoutId) async {
    try {
      final doc = await _firestore.collection('workouts').doc(workoutId).get();
      if (!doc.exists) {
        print('Workout $workoutId does not exist in Firestore');
        // Workout doesn't exist, could create a default one or handle appropriately
      }
    } catch (e) {
      print('Error ensuring workout exists: $e');
    }
  }

  // Upload workout data from JSON to Firestore
  Future<void> uploadWorkoutDataFromJson() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/data/workouts.json',
      );
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> workouts = jsonData['workouts'];

      print('Found ${workouts.length} workouts to upload');

      for (int i = 0; i < workouts.length; i++) {
        final workout = workouts[i];

        // Convert steps if they exist
        List<Map<String, dynamic>> steps = [];
        if (workout['steps'] != null) {
          steps = (workout['steps'] as List)
              .map(
                (step) => {
                  'stepNumber': step['stepNumber'] ?? 1,
                  'title': step['title'] ?? 'Step ${step['stepNumber'] ?? 1}',
                  'description': step['description'] ?? '',
                  'image': step['image'],
                  'duration': step['duration'] ?? 30,
                  'reps': step['reps'],
                  'sets': step['sets'],
                },
              )
              .toList();
        }

        final workoutData = {
          'id': 'workout_${i + 1}',
          'name': workout['title'],
          'description': workout['description'],
          'category': workout['muscleGroup'],
          'image': workout['thumbnail'],
          'videoUrl': workout['videoUrl'],
          'equipment': workout['equipment'],
          'calories': 150 + (i * 10), // Random calories
          'duration': 10 + (i * 2), // Random duration in minutes
          'difficulty': 'Intermediate',
          'muscleGroups': [workout['muscleGroup']], // Convert to list
          'steps': steps,
          'isFavorite': false,
          'completedAt': null,
          'createdAt': FieldValue.serverTimestamp(),
        };

        await _firestore
            .collection('workouts')
            .doc('workout_${i + 1}')
            .set(workoutData);

        print('Uploaded workout ${i + 1}: ${workout['title']}');
      }

      print('Successfully uploaded ${workouts.length} workouts to Firestore!');
    } catch (e) {
      print('Error uploading workout data: $e');
      throw Exception('Failed to upload workout data: $e');
    }
  }

  // Import workouts from Firestore to local storage
  Future<List<Workout>> importWorkoutsFromFirestore() async {
    try {
      print('Importing workouts from Firestore...');

      final snapshot = await _firestore.collection('workouts').get();
      List<Workout> workouts = [];

      for (var doc in snapshot.docs) {
        try {
          final data = doc.data();
          data['id'] = doc.id;
          final workout = Workout.fromJson(data);
          workouts.add(workout);
          print('Imported workout: ${workout.name}');
        } catch (e) {
          print('Error parsing workout ${doc.id}: $e');
        }
      }

      print('Successfully imported ${workouts.length} workouts from Firestore');
      return workouts;
    } catch (e) {
      print('Error importing workouts from Firestore: $e');
      throw Exception('Failed to import workouts: $e');
    }
  }
}
