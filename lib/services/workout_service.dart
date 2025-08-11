import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/workout.dart';

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
        print('Workout $workoutId does not exist in Firestore');
        // Workout doesn't exist, could create a default one or handle appropriately
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
          .where('name', isLessThan: '$query\uf8ff')
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
