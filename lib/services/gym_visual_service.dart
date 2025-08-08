import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/exercise.dart';
import 'exercise_service.dart';

class GymVisualService {
  // Upload sample exercises to Firestore
  Future<void> uploadSampleExercisesToFirestore() async {
    final CollectionReference exercisesCollection = _firestore.collection(
      'exercises',
    );
    final List<Map<String, dynamic>> workoutExercises = [
      {
        "title": "Push-Up",
        "muscleGroup": "Chest",
        "videoUrl": "https://www.youtube.com/embed/IODxDxX7oi4",
        "thumbnail": "https://img.youtube.com/vi/IODxDxX7oi4/0.jpg",
        "description":
            "The push-up is a fundamental bodyweight exercise that strengthens the chest, triceps, and shoulders. Begin in a high plank position with your hands slightly wider than shoulder-width apart. Lower your body until your chest is just above the ground, then push yourself back up. Keep your core tight and body aligned throughout the movement. For beginners, you can perform push-ups on your knees or against a wall to build strength.",
        "equipment": "Bodyweight",
      },
      {
        "title": "Bodyweight Squat",
        "muscleGroup": "Legs",
        "videoUrl": "https://www.youtube.com/embed/aclHkVaku9U",
        "thumbnail": "https://img.youtube.com/vi/aclHkVaku9U/0.jpg",
        "description":
            "Bodyweight squats are a lower-body exercise that strengthens the quads, hamstrings, glutes, and calves. Stand with your feet shoulder-width apart, lower your hips back and down as if sitting into a chair, then return to standing. Keep your chest lifted and knees aligned with your toes. Focus on controlled movement and a full range of motion.",
        "equipment": "Bodyweight",
      },
      {
        "title": "Plank",
        "muscleGroup": "Core",
        "videoUrl": "https://www.youtube.com/embed/ASdvN_Xtlck",
        "thumbnail": "https://img.youtube.com/vi/ASdvN_Xtlck/0.jpg",
        "description":
            "The plank is an excellent exercise for strengthening your entire core, including your abs, obliques, and lower back. Start in a push-up position, then lower onto your forearms, keeping your body in a straight line from head to heels. Engage your core and avoid letting your hips sag or rise too high. Hold this position for as long as you can maintain proper form.",
        "equipment": "Bodyweight",
      },
      {
        "title": "Lunges",
        "muscleGroup": "Legs",
        "videoUrl": "https://www.youtube.com/embed/QO8_g_9Q_lQ",
        "thumbnail": "https://img.youtube.com/vi/QO8_g_9Q_lQ/0.jpg",
        "description":
            "Lunges are a fantastic exercise for building lower body strength and improving balance. Stand with your feet hip-width apart. Step forward with one leg, lowering your hips until both knees are bent at approximately a 90-degree angle. Ensure your front knee is directly above your ankle and your back knee hovers just above the ground. Push off your front foot to return to the starting position and alternate legs.",
        "equipment": "Bodyweight",
      },
      {
        "title": "Dumbbell Row",
        "muscleGroup": "Back",
        "videoUrl": "https://www.youtube.com/embed/roC_d_z_42o",
        "thumbnail": "https://img.youtube.com/vi/roC_d_z_42o/0.jpg",
        "description":
            "The dumbbell row targets your back muscles, particularly the lats, and also works your biceps. Place one hand and one knee on a bench for support, keeping your back flat. With a dumbbell in your free hand, pull the weight up towards your chest, squeezing your shoulder blade. Lower the dumbbell with control. This exercise helps improve posture and upper body pulling strength.",
        "equipment": "Dumbbell, Bench",
      },
      {
        "title": "Overhead Press (Dumbbell)",
        "muscleGroup": "Shoulders",
        "videoUrl": "https://www.youtube.com/embed/B-mQ20Q_g0Q",
        "thumbnail": "https://img.youtube.com/vi/B-mQ20Q_g0Q/0.jpg",
        "description":
            "The dumbbell overhead press is a great exercise for building strong shoulders and triceps. Sit or stand with a dumbbell in each hand at shoulder height, palms facing forward. Press the dumbbells directly overhead until your arms are fully extended, but don't lock your elbows. Slowly lower the dumbbells back to the starting position. Keep your core engaged to protect your lower back.",
        "equipment": "Dumbbell",
      },
      {
        "title": "Bicep Curl (Dumbbell)",
        "muscleGroup": "Biceps",
        "videoUrl": "https://www.youtube.com/embed/in7Rz5K_F54",
        "thumbnail": "https://img.youtube.com/vi/in7Rz5K_F54/0.jpg",
        "description":
            "The dumbbell bicep curl is a classic exercise for isolating and strengthening the biceps. Stand or sit with a dumbbell in each hand, palms facing forward. Keeping your elbows tucked close to your body, curl the dumbbells up towards your shoulders. Squeeze your biceps at the top of the movement, then slowly lower the weights back down. Avoid swinging your body to lift the weights.",
        "equipment": "Dumbbell",
      },
      {
        "title": "Triceps Extension (Overhead Dumbbell)",
        "muscleGroup": "Triceps",
        "videoUrl": "https://www.youtube.com/embed/nRi_y_2_j7c",
        "thumbnail": "https://img.youtube.com/vi/nRi_y_2_j7c/0.jpg",
        "description":
            "The overhead dumbbell triceps extension effectively targets all three heads of the triceps. Hold one dumbbell with both hands and extend it overhead. Keeping your elbows close to your head, slowly lower the dumbbell behind you by bending your elbows. Extend your arms back up to the starting position, feeling the contraction in your triceps. Maintain a stable core throughout the exercise.",
        "equipment": "Dumbbell",
      },
      {
        "title": "Glute Bridge",
        "muscleGroup": "Glutes",
        "videoUrl": "https://www.youtube.com/embed/W_l4B8D-c70",
        "thumbnail": "https://img.youtube.com/vi/W_l4B8D-c70/0.jpg",
        "description":
            "The glute bridge is a simple yet effective exercise for strengthening the glutes and hamstrings, and it's great for beginners. Lie on your back with your knees bent and feet flat on the floor, hip-width apart. Press through your heels to lift your hips off the ground until your body forms a straight line from your shoulders to your knees. Squeeze your glutes at the top, then slowly lower back down.",
        "equipment": "Bodyweight",
      },
      {
        "title": "Bird-Dog",
        "muscleGroup": "Core, Back",
        "videoUrl": "https://www.youtube.com/embed/wiFNA3qb_FU",
        "thumbnail": "https://img.youtube.com/vi/wiFNA3qb_FU/0.jpg",
        "description":
            "The bird-dog is a fantastic exercise for improving core stability, balance, and strengthening the lower back. Start on all fours, with your hands directly under your shoulders and knees under your hips. Slowly extend one arm straight forward and the opposite leg straight back, keeping your core tight and hips level. Hold briefly, then return to the starting position and alternate sides. Focus on controlled movement and avoiding any rocking.",
        "equipment": "Bodyweight",
      },
    ];

    for (var exerciseData in workoutExercises) {
      await exercisesCollection.add({
        'title': exerciseData['title'],
        'muscleGroup': exerciseData['muscleGroup'],
        'videoUrl': exerciseData['videoUrl'],
        'thumbnail': exerciseData['thumbnail'],
        'description': exerciseData['description'],
        'equipment': exerciseData['equipment'],
        'createdAt': FieldValue.serverTimestamp(),
        'source': 'Sample',
      });
    }
    debugPrint('All sample exercises uploaded to Firestore!');
  }

  final ExerciseService _exerciseService = ExerciseService();

  // GymVisual exercise data structure
  static const Map<String, dynamic> gymVisualExercises = {
    "186012": {
      "id": "186012",
      "name": "Hyperextension (VERSION 2)",
      "description": "Lower back exercise performed on a hyperextension bench",
      "category": "Strength",
      "muscleGroups": ["Lower Back", "Glutes", "Hamstrings"],
      "instructions":
          "1. Position yourself on the hyperextension bench\n2. Cross your arms over your chest\n3. Lower your upper body down\n4. Raise your upper body back to starting position\n5. Repeat for desired number of reps",
      "imageUrl": "https://gymvisual.com/exercises/hyperextension-v2",
      "equipment": "Hyperextension Bench",
      "difficulty": "Intermediate",
      "source": "GymVisual",
    },
    "2043": {
      "id": "2043",
      "name": "Rectus Abdominis",
      "description": "Anatomical reference for the rectus abdominis muscle",
      "category": "Anatomy",
      "muscleGroups": ["Abs", "Core"],
      "instructions":
          "This is an anatomical reference showing the rectus abdominis muscle",
      "imageUrl": "https://gymvisual.com/anatomy/rectus-abdominis",
      "equipment": "None",
      "difficulty": "Beginner",
      "source": "GymVisual",
    },
    "1024": {
      "id": "1024",
      "name": "Side Relaxed Pose",
      "description": "Reference pose showing muscular development",
      "category": "Reference",
      "muscleGroups": ["Full Body"],
      "instructions": "Reference pose for bodybuilding and fitness assessment",
      "imageUrl": "https://gymvisual.com/poses/side-relaxed",
      "equipment": "None",
      "difficulty": "Beginner",
      "source": "GymVisual",
    },
    "1250": {
      "id": "1250",
      "name": "Weighted Crunch (behind head)",
      "description": "Advanced abdominal exercise with weight behind the head",
      "category": "Strength",
      "muscleGroups": ["Abs", "Core"],
      "instructions":
          "1. Lie on an incline bench\n2. Hold weight behind your head\n3. Perform crunch motion\n4. Return to starting position\n5. Repeat for desired reps",
      "imageUrl": "https://gymvisual.com/exercises/weighted-crunch-behind-head",
      "equipment": "Incline Bench, Weight",
      "difficulty": "Advanced",
      "source": "GymVisual",
    },
    "1251": {
      "id": "1251",
      "name": "Weighted Crunch",
      "description": "Basic weighted crunch exercise for abs",
      "category": "Strength",
      "muscleGroups": ["Abs", "Core"],
      "instructions":
          "1. Lie on your back\n2. Hold weight on your chest\n3. Perform crunch motion\n4. Return to starting position\n5. Repeat for desired reps",
      "imageUrl": "https://gymvisual.com/exercises/weighted-crunch",
      "equipment": "Weight",
      "difficulty": "Intermediate",
      "source": "GymVisual",
    },
  };

  // Import GymVisual exercises to Firestore
  Future<void> importGymVisualExercises() async {
    try {
      for (final exerciseData in gymVisualExercises.values) {
        final exercise = Exercise(
          id: exerciseData['id'],
          name: exerciseData['name'],
          description: exerciseData['description'],
          category: exerciseData['category'],
          imageUrl: exerciseData['imageUrl'],
          muscleGroups: List<String>.from(exerciseData['muscleGroups']),
          instructions: exerciseData['instructions'],
        );
        await _exerciseService.createExercise(
          Exercise(
            id: exercise.id,
            name: exercise.name,
            description: exercise.description,
            category: exercise.category,
            imageUrl: exercise.imageUrl,
            muscleGroups: exercise.muscleGroups,
            instructions: exercise.instructions,
          ),
        );
        await _exerciseService.updateGymVisualData(exercise.id, exerciseData);
      }
      debugPrint(
        'Successfully imported ${gymVisualExercises.length} GymVisual exercises',
      );
    } catch (e) {
      throw Exception('Failed to import GymVisual exercises: $e');
    }
  }

  // Get exercises by source (GymVisual)
  Future<List<Exercise>> getGymVisualExercises() async {
    return await _exerciseService.getAllExercises();
  }

  // Search exercises by GymVisual ID
  Future<Exercise?> getExerciseByGymVisualId(String gymVisualId) async {
    try {
      final doc = await _firestore
          .collection('exercises')
          .doc(gymVisualId)
          .get();

      if (doc.exists) {
        return Exercise.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get exercise by GymVisual ID: $e');
    }
  }

  // Get exercises by difficulty level
  Future<List<Exercise>> getExercisesByDifficulty(String difficulty) async {
    try {
      final querySnapshot = await _firestore
          .collection('exercises')
          .where('source', isEqualTo: 'GymVisual')
          .where('difficulty', isEqualTo: difficulty)
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => Exercise.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get exercises by difficulty: $e');
    }
  }

  // Get exercises by equipment
  Future<List<Exercise>> getExercisesByEquipment(String equipment) async {
    try {
      final querySnapshot = await _firestore
          .collection('exercises')
          .where('source', isEqualTo: 'GymVisual')
          .where('equipment', isEqualTo: equipment)
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => Exercise.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get exercises by equipment: $e');
    }
  }

  // Update exercise with GymVisual data
  Future<void> updateExerciseWithGymVisualData(
    String exerciseId,
    Map<String, dynamic> gymVisualData,
  ) async {
    await _exerciseService.updateGymVisualData(exerciseId, gymVisualData);
  }

  // Get all GymVisual exercise IDs
  List<String> getAllGymVisualIds() {
    return gymVisualExercises.keys.toList();
  }

  // Check if exercise exists in GymVisual
  bool isGymVisualExercise(String exerciseId) {
    return gymVisualExercises.containsKey(exerciseId);
  }

  // Get GymVisual exercise data by ID
  Map<String, dynamic>? getGymVisualExerciseData(String exerciseId) {
    return gymVisualExercises[exerciseId];
  }

  // Stream GymVisual exercises
  Stream<List<Exercise>> streamGymVisualExercises() {
    return _firestore
        .collection('exercises')
        .where('source', isEqualTo: 'GymVisual')
        .orderBy('name')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Exercise.fromJson(doc.data()))
              .toList(),
        );
  }
}
