import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/gym_visual_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreHelper {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Thêm GymVisual exercises vào Firestore
  static Future<void> addGymVisualExercisesToFirestore() async {
    try {
      final gymVisualService = GymVisualService();
      await gymVisualService.importGymVisualExercises();
      print('GymVisual exercises added to Firestore successfully!');
    } catch (e) {
      print('Error adding GymVisual exercises: $e');
    }
  }

  // Thêm sample workouts vào Firestore
  static Future<void> addSampleWorkoutsToFirestore() async {
    try {
      final batch = _firestore.batch();

      final sampleWorkouts = [
        {
          'name': 'Full Body Strength',
          'description':
              'A comprehensive full body workout targeting all major muscle groups.',
          'image': 'assets/img/Workout1.png',
          'category': 'Strength',
          'duration': 45,
          'calories': 350,
          'difficulty': 'Intermediate',
          'muscleGroups': ['Chest', 'Back', 'Legs', 'Shoulders', 'Arms'],
          'steps': [
            {
              'stepNumber': 1,
              'title': 'Warm-up',
              'description':
                  'Start with 5 minutes of light cardio and dynamic stretching',
              'duration': 300,
            },
            {
              'stepNumber': 2,
              'title': 'Push-ups',
              'description': '3 sets of 12-15 reps. Keep your body straight.',
              'duration': 180,
              'reps': 15,
              'sets': 3,
            },
          ],
        },
        {
          'name': 'Cardio HIIT',
          'description':
              'High-intensity interval training to boost cardiovascular fitness.',
          'image': 'assets/img/Workout2.png',
          'category': 'Cardio',
          'duration': 30,
          'calories': 400,
          'difficulty': 'Advanced',
          'muscleGroups': ['Cardiovascular', 'Core'],
          'steps': [
            {
              'stepNumber': 1,
              'title': 'Warm-up',
              'description': '5 minutes of light jogging in place',
              'duration': 300,
            },
            {
              'stepNumber': 2,
              'title': 'High Knees',
              'description':
                  '30 seconds high intensity, 30 seconds rest. Repeat 4 times.',
              'duration': 240,
              'reps': 4,
              'sets': 1,
            },
          ],
        },
      ];

      for (final workout in sampleWorkouts) {
        final docRef = _firestore.collection('workouts').doc();
        batch.set(docRef, {
          ...workout,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      print('Sample workouts added to Firestore successfully!');
    } catch (e) {
      print('Error adding sample workouts: $e');
    }
  }

  // Thêm sample tips vào Firestore
  static Future<void> addSampleTipsToFirestore() async {
    try {
      final batch = _firestore.batch();

      final sampleTips = [
        {
          'title': 'How to do a proper push-up',
          'exercises': '3 exercises',
          'time': '5 min',
          'image': 'assets/img/Workout1.png',
          'description':
              'Learn the correct form for push-ups to maximize effectiveness.',
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
      ];

      for (final tip in sampleTips) {
        final docRef = _firestore.collection('workoutTips').doc();
        batch.set(docRef, {...tip, 'createdAt': FieldValue.serverTimestamp()});
      }

      await batch.commit();
      print('Sample tips added to Firestore successfully!');
    } catch (e) {
      print('Error adding sample tips: $e');
    }
  }

  // Thêm tất cả sample data
  static Future<void> addAllSampleData() async {
    try {
      await Future.wait([
        addGymVisualExercisesToFirestore(),
        addSampleWorkoutsToFirestore(),
        addSampleTipsToFirestore(),
      ]);
      print('All sample data added to Firestore successfully!');
    } catch (e) {
      print('Error adding sample data: $e');
    }
  }

  // Clear all data
  static Future<void> clearAllData() async {
    try {
      final batch = FirebaseFirestore.instance.batch();

      // Clear workouts
      final workoutsSnapshot = await FirebaseFirestore.instance
          .collection('workouts')
          .get();
      for (var doc in workoutsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Clear workout tips
      final tipsSnapshot = await FirebaseFirestore.instance
          .collection('workoutTips')
          .get();
      for (var doc in tipsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print('All data cleared successfully');
    } catch (e) {
      print('Error clearing data: $e');
    }
  }

  // Clear workout history for current user
  static Future<void> clearWorkoutHistory() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('No user logged in');
        return;
      }

      final batch = FirebaseFirestore.instance.batch();
      final historySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('workoutHistory')
          .get();

      for (var doc in historySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print('Workout history cleared for user: ${user.uid}');
    } catch (e) {
      print('Error clearing workout history: $e');
    }
  }
}
