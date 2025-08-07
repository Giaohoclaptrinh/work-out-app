import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/workout.dart';
import 'gym_visual_service.dart';

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

      // If no workouts in Firestore, create from GymVisual exercises
      if (workouts.isEmpty) {
        workouts = await _createWorkoutsFromGymVisual();
      }

      return workouts;
    } catch (e) {
      print('Error fetching workouts: $e');
      return [];
    }
  }

  // Tạo workouts từ GymVisual exercises
  Future<List<Workout>> _createWorkoutsFromGymVisual() async {
    try {
      final exercises = GymVisualService.gymVisualExercises.values.toList();

      List<Workout> workouts = [];

      for (int i = 0; i < exercises.length; i++) {
        final exercise = exercises[i];

        // Tạo workout từ exercise
        final workout = Workout(
          id: exercise['id'],
          name: exercise['name'],
          description: exercise['description'],
          image: 'assets/img/Workout${(i % 3) + 1}.png', // Use available images
          category: exercise['category'],
          duration: 20 + (i * 5), // Vary duration
          calories: 150 + (i * 25), // Vary calories
          difficulty: exercise['difficulty'],
          muscleGroups: List<String>.from(exercise['muscleGroups']),
          steps: _createStepsFromInstructions(exercise['instructions']),
        );

        workouts.add(workout);
      }

      return workouts;
    } catch (e) {
      print('Error creating workouts from GymVisual: $e');
      return [];
    }
  }

  // Tạo steps từ instructions
  List<WorkoutStep> _createStepsFromInstructions(String instructions) {
    final lines = instructions.split('\n');
    List<WorkoutStep> steps = [];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isNotEmpty && line.contains('.')) {
        final stepNumber = i + 1;
        final title = line.split('.')[0].trim();
        final description = line;

        steps.add(
          WorkoutStep(
            stepNumber: stepNumber,
            title: title,
            description: description,
            duration: 30 + (stepNumber * 10), // Vary duration
          ),
        );
      }
    }

    // If no steps created, add a default step
    if (steps.isEmpty) {
      steps.add(
        WorkoutStep(
          stepNumber: 1,
          title: 'Follow Instructions',
          description: instructions,
          duration: 60,
        ),
      );
    }

    return steps;
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

      // Tạo document ID unique để tránh conflict
      final historyDocId =
          '${user.uid}_${workoutId}_${DateTime.now().millisecondsSinceEpoch}';

      // Đảm bảo workout tồn tại trong Firestore trước khi lưu history
      await _ensureWorkoutExists(workoutId);

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('workoutHistory')
          .doc(historyDocId)
          .set({
            'completedAt': FieldValue.serverTimestamp(),
            'workoutId': workoutId,
            'userId': user.uid,
          });

      print(
        'Workout completed successfully: $workoutId with doc ID: $historyDocId',
      );
    } catch (e) {
      print('Error completing workout: $e');
    }
  }

  // Đảm bảo workout tồn tại trong Firestore
  Future<void> _ensureWorkoutExists(String workoutId) async {
    try {
      final doc = await _firestore.collection('workouts').doc(workoutId).get();
      if (!doc.exists) {
        // Tìm workout trong GymVisual data
        final gymVisualData = GymVisualService.gymVisualExercises;
        final exercise = gymVisualData[workoutId];

        if (exercise != null) {
          print('Creating workout from GymVisual data: $workoutId');

          // Tạo Workout object từ GymVisual data
          final workout = Workout(
            id: workoutId,
            name: exercise['name'] ?? 'Unknown Exercise',
            description: exercise['description'] ?? '',
            image: exercise['image'] ?? 'assets/img/Workout1.png',
            category: exercise['category'] ?? 'General',
            duration: 15, // Default duration
            calories: 100, // Default calories
            difficulty: 'Beginner',
            muscleGroups: exercise['muscleGroups'] ?? ['General'],
            steps: _createStepsFromInstructions(
              exercise['instructions']?.toString() ?? '',
            ),
          );

          // Lưu vào Firestore
          await _firestore
              .collection('workouts')
              .doc(workoutId)
              .set(workout.toJson());

          print('Workout saved to Firestore: ${workout.name}');
        }
      }
    } catch (e) {
      print('Error ensuring workout exists: $e');
    }
  }

  // Lấy tips từ Firestore
  Future<List<Map<String, dynamic>>> getWorkoutTips() async {
    try {
      final snapshot = await _firestore.collection('workoutTips').get();
      List<Map<String, dynamic>> tips = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      // If no tips in Firestore, return sample tips
      if (tips.isEmpty) {
        tips = _getSampleTips();
      }

      return tips;
    } catch (e) {
      print('Error fetching workout tips: $e');
      return _getSampleTips();
    }
  }

  // Sample tips
  List<Map<String, dynamic>> _getSampleTips() {
    return [
      {
        'title': 'How to do a proper push-up',
        'exercises': '3 exercises',
        'time': '5 min',
        'image': 'assets/img/Workout1.png',
        'description':
            'Learn the correct form for push-ups to maximize effectiveness and prevent injury.',
      },
      {
        'title': 'Best exercises for abs',
        'exercises': '4 exercises',
        'time': '8 min',
        'image': 'assets/img/Workout2.png',
        'description':
            'Target your core with these effective abdominal exercises.',
      },
      {
        'title': 'Cardio workout guide',
        'exercises': '5 exercises',
        'time': '12 min',
        'image': 'assets/img/Workout3.png',
        'description':
            'Boost your cardiovascular fitness with these cardio exercises.',
      },
      {
        'title': 'Stretching routine',
        'exercises': '6 exercises',
        'time': '10 min',
        'image': 'assets/img/Workout1.png',
        'description':
            'Improve flexibility and prevent injury with this stretching routine.',
      },
    ];
  }

  // Tìm kiếm workouts
  Future<List<Workout>> searchWorkouts(String query) async {
    try {
      final snapshot = await _firestore
          .collection('workouts')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: query + '\uf8ff')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Workout.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error searching workouts: $e');
      return [];
    }
  }
}
