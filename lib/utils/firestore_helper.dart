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

  // Add all GymVisual workouts to Firestore
  static Future<void> addAllGymVisualWorkoutsToFirestore() async {
    try {
      final batch = FirebaseFirestore.instance.batch();

      final exercises = GymVisualService.gymVisualExercises.values.toList();

      for (int i = 0; i < exercises.length; i++) {
        final exercise = exercises[i];

        final workout = {
          'id': exercise['id'],
          'name': exercise['name'],
          'description': exercise['description'],
          'image': 'assets/img/Workout${(i % 3) + 1}.png',
          'category': exercise['category'],
          'duration': 20 + (i * 5),
          'calories': 150 + (i * 25),
          'difficulty': exercise['difficulty'],
          'muscleGroups': exercise['muscleGroups'],
          'steps': _createWorkoutSteps(exercise['instructions']),
          'source': 'GymVisual',
          'importedAt': FieldValue.serverTimestamp(),
        };

        final docRef = FirebaseFirestore.instance
            .collection('workouts')
            .doc(exercise['id'] as String);
        batch.set(docRef, workout);
      }

      await batch.commit();
      print(
        'All ${exercises.length} GymVisual workouts added to Firestore successfully',
      );
    } catch (e) {
      print('Error adding GymVisual workouts: $e');
    }
  }

  // Create workout steps from instructions
  static List<Map<String, dynamic>> _createWorkoutSteps(String instructions) {
    final lines = instructions.split('\n');
    List<Map<String, dynamic>> steps = [];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isNotEmpty && line.contains('.')) {
        final stepNumber = i + 1;
        final title = line.split('.')[0].trim();
        final description = line;

        steps.add({
          'stepNumber': stepNumber,
          'title': title,
          'description': description,
          'duration': 30 + (stepNumber * 10),
        });
      }
    }

    // If no steps created, add a default step
    if (steps.isEmpty) {
      steps.add({
        'stepNumber': 1,
        'title': 'Follow Instructions',
        'description': instructions,
        'duration': 60,
      });
    }

    return steps;
  }

  // Add sample meals to Firestore
  static Future<void> addSampleMealsToFirestore() async {
    try {
      final batch = FirebaseFirestore.instance.batch();

      final meals = [
        {
          'id': 'b1',
          'name': 'Oatmeal with Berries',
          'description': 'Healthy oatmeal topped with fresh berries and honey',
          'image': 'assets/img/oatmeal.png',
          'calories': 250,
          'category': 'breakfast',
          'tags': ['low-carb', 'high-fiber'],
          'prepTime': 10,
        },
        {
          'id': 'b2',
          'name': 'Scrambled Eggs',
          'description': 'Fluffy scrambled eggs with whole grain toast',
          'image': 'assets/img/eggs.png',
          'calories': 300,
          'category': 'breakfast',
          'tags': ['high-protein'],
          'prepTime': 15,
        },
        {
          'id': 'b3',
          'name': 'Smoothie Bowl',
          'description': 'Colorful smoothie bowl with granola and fruits',
          'image': 'assets/img/pancake_1.png',
          'calories': 280,
          'category': 'breakfast',
          'tags': ['vegan', 'gluten-free'],
          'prepTime': 8,
        },
        {
          'id': 'l1',
          'name': 'Grilled Chicken Salad',
          'description': 'Fresh salad with grilled chicken breast',
          'image': 'assets/img/chicken.png',
          'calories': 350,
          'category': 'lunch',
          'tags': ['high-protein', 'low-carb'],
          'prepTime': 20,
        },
        {
          'id': 'l2',
          'name': 'Quinoa Bowl',
          'description': 'Nutritious quinoa bowl with vegetables',
          'image': 'assets/img/m_1.png',
          'calories': 320,
          'category': 'lunch',
          'tags': ['vegan', 'gluten-free'],
          'prepTime': 25,
        },
        {
          'id': 'l3',
          'name': 'Turkey Sandwich',
          'description': 'Whole grain sandwich with turkey and avocado',
          'image': 'assets/img/m_2.png',
          'calories': 380,
          'category': 'lunch',
          'tags': ['high-protein'],
          'prepTime': 12,
        },
        {
          'id': 'd1',
          'name': 'Salmon with Vegetables',
          'description': 'Baked salmon with roasted vegetables',
          'image': 'assets/img/m_3.png',
          'calories': 420,
          'category': 'dinner',
          'tags': ['high-protein', 'omega-3'],
          'prepTime': 30,
        },
        {
          'id': 'd2',
          'name': 'Pasta Primavera',
          'description': 'Fresh pasta with seasonal vegetables',
          'image': 'assets/img/m_4.png',
          'calories': 380,
          'category': 'dinner',
          'tags': ['vegetarian'],
          'prepTime': 25,
        },
        {
          'id': 'd3',
          'name': 'Beef Stir Fry',
          'description': 'Lean beef stir fry with brown rice',
          'image': 'assets/img/nigiri.png',
          'calories': 450,
          'category': 'dinner',
          'tags': ['high-protein'],
          'prepTime': 20,
        },
        {
          'id': 's1',
          'name': 'Greek Yogurt',
          'description': 'Greek yogurt with honey and nuts',
          'image': 'assets/img/glass-of-milk 1.png',
          'calories': 150,
          'category': 'snack',
          'tags': ['high-protein', 'probiotic'],
          'prepTime': 2,
        },
        {
          'id': 's2',
          'name': 'Apple with Peanut Butter',
          'description': 'Fresh apple slices with natural peanut butter',
          'image': 'assets/img/apple_pie.png',
          'calories': 180,
          'category': 'snack',
          'tags': ['high-fiber', 'protein'],
          'prepTime': 5,
        },
        {
          'id': 's3',
          'name': 'Mixed Nuts',
          'description': 'Assorted nuts and dried fruits',
          'image': 'assets/img/orange.png',
          'calories': 200,
          'category': 'snack',
          'tags': ['healthy-fats', 'protein'],
          'prepTime': 1,
        },
      ];

      for (final meal in meals) {
        final docRef = FirebaseFirestore.instance
            .collection('meals')
            .doc(meal['id'] as String);
        batch.set(docRef, meal);
      }

      await batch.commit();
      print('Sample meals added to Firestore successfully');
    } catch (e) {
      print('Error adding sample meals: $e');
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
