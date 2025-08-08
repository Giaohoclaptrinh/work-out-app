import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

Future<void> uploadExercisesToFirestore() async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final CollectionReference exercisesCollection = firestore.collection(
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
  print('All exercises uploaded to Firestore!');
}

class UploadExercisesScreen extends StatelessWidget {
  const UploadExercisesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Exercises')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await uploadExercisesToFirestore();
          },
          child: const Text('Upload Exercises to Firestore'),
        ),
      ),
    );
  }
}
