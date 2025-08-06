import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/exercise.dart';

class GymVisualService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
      final batch = _firestore.batch();

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

        final docRef = _firestore.collection('exercises').doc(exercise.id);
        batch.set(docRef, {
          ...exercise.toJson(),
          'source': exerciseData['source'],
          'equipment': exerciseData['equipment'],
          'difficulty': exerciseData['difficulty'],
          'importedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      print(
        'Successfully imported ${gymVisualExercises.length} GymVisual exercises',
      );
    } catch (e) {
      throw Exception('Failed to import GymVisual exercises: $e');
    }
  }

  // Get exercises by source (GymVisual)
  Future<List<Exercise>> getGymVisualExercises() async {
    try {
      final querySnapshot = await _firestore
          .collection('exercises')
          .where('source', isEqualTo: 'GymVisual')
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => Exercise.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get GymVisual exercises: $e');
    }
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
    try {
      await _firestore.collection('exercises').doc(exerciseId).update({
        'gymVisualData': gymVisualData,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update exercise with GymVisual data: $e');
    }
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
