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
      "thumbnail": "https://img.youtube.com/vi/IODxDxX7oi4/maxresdefault.jpg",
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
      "videoUrl": "https://www.youtube.com/embed/pSHjTRCQxIw",
      "thumbnail": "https://img.youtube.com/vi/pSHjTRCQxIw/hqdefault.jpg",
      "description":
          "The plank is an excellent exercise for strengthening your entire core, including your abs, obliques, and lower back. Start in a push-up position, then lower onto your forearms, keeping your body in a straight line from head to heels. Engage your core and avoid letting your hips sag or rise too high. Hold this position for as long as you can maintain proper form.",
      "equipment": "Bodyweight",
    },
    {
      "title": "Lunges",
      "muscleGroup": "Legs",
      "videoUrl": "https://www.youtube.com/embed/D7KaRcUTQeE",
      "thumbnail": "https://img.youtube.com/vi/D7KaRcUTQeE/hqdefault.jpg",
      "description":
          "Lunges are a fantastic exercise for building lower body strength and improving balance. Stand with your feet hip-width apart. Step forward with one leg, lowering your hips until both knees are bent at approximately a 90-degree angle. Ensure your front knee is directly above your ankle and your back knee hovers just above the ground. Push off your front foot to return to the starting position and alternate legs.",
      "equipment": "Bodyweight",
    },
    {
      "title": "Dumbbell Row",
      "muscleGroup": "Back",
      "videoUrl": "https://www.youtube.com/embed/6TSP1TRMUzs",
      "thumbnail": "https://img.youtube.com/vi/6TSP1TRMUzs/hqdefault.jpg",
      "description":
          "The dumbbell row targets your back muscles, particularly the lats, and also works your biceps. Place one hand and one knee on a bench for support, keeping your back flat. With a dumbbell in your free hand, pull the weight up towards your chest, squeezing your shoulder blade. Lower the dumbbell with control. This exercise helps improve posture and upper body pulling strength.",
      "equipment": "Dumbbell, Bench",
    },
    {
      "title": "Overhead Press (Dumbbell)",
      "muscleGroup": "Shoulders",
      "videoUrl": "https://www.youtube.com/embed/qEwKCR5JCog",
      "thumbnail": "https://img.youtube.com/vi/qEwKCR5JCog/hqdefault.jpg",
      "description":
          "The dumbbell overhead press is a great exercise for building strong shoulders and triceps. Sit or stand with a dumbbell in each hand at shoulder height, palms facing forward. Press the dumbbells directly overhead until your arms are fully extended, but don't lock your elbows. Slowly lower the dumbbells back to the starting position. Keep your core engaged to protect your lower back.",
      "equipment": "Dumbbell",
    },
    {
      "title": "Bicep Curl (Dumbbell)",
      "muscleGroup": "Biceps",
      "videoUrl": "https://www.youtube.com/embed/ykJmrZ5v0Oo",
      "thumbnail": "https://img.youtube.com/vi/ykJmrZ5v0Oo/hqdefault.jpg",
      "description":
          "The dumbbell bicep curl is a classic exercise for isolating and strengthening the biceps. Stand or sit with a dumbbell in each hand, palms facing forward. Keeping your elbows tucked close to your body, curl the dumbbells up towards your shoulders. Squeeze your biceps at the top of the movement, then slowly lower the weights back down. Avoid swinging your body to lift the weights.",
      "equipment": "Dumbbell",
    },
    {
      "title": "Triceps Extension (Overhead Dumbbell)",
      "muscleGroup": "Triceps",
      "videoUrl": "https://www.youtube.com/embed/_gsUck-7M74",
      "thumbnail": "https://img.youtube.com/vi/_gsUck-7M74/hqdefault.jpg",
      "description":
          "The overhead dumbbell triceps extension effectively targets all three heads of the triceps. Hold one dumbbell with both hands and extend it overhead. Keeping your elbows close to your head, slowly lower the dumbbell behind you by bending your elbows. Extend your arms back up to the starting position, feeling the contraction in your triceps. Maintain a stable core throughout the exercise.",
      "equipment": "Dumbbell",
    },
    {
      "title": "Glute Bridge",
      "muscleGroup": "Glutes",
      "videoUrl": "https://www.youtube.com/embed/OUgsJ8-Vi0E",
      "thumbnail": "https://img.youtube.com/vi/OUgsJ8-Vi0E/hqdefault.jpg",
      "description":
          "The glute bridge is a simple yet effective exercise for strengthening the glutes and hamstrings, and it's great for beginners. Lie on your back with your knees bent and feet flat on the floor, hip-width apart. Press through your heels to lift your hips off the ground until your body forms a straight line from your shoulders to your knees. Squeeze your glutes at the top, then slowly lower back down.",
      "equipment": "Bodyweight",
    },
    {
      "title": "Bird-Dog",
      "muscleGroup": "Core, Back",
      "videoUrl": "https://www.youtube.com/embed/wqzrb67Dwf8",
      "thumbnail": "https://img.youtube.com/vi/wqzrb67Dwf8/hqdefault.jpg",
      "description":
          "The bird-dog is a fantastic exercise for improving core stability, balance, and strengthening the lower back. Start on all fours, with your hands directly under your shoulders and knees under your hips. Slowly extend one arm straight forward and the opposite leg straight back, keeping your core tight and hips level. Hold briefly, then return to the starting position and alternate sides. Focus on controlled movement and avoiding any rocking.",
      "equipment": "Bodyweight",
    },
  ];

  for (var exerciseData in workoutExercises) {
    await exercisesCollection.add({
      'name': exerciseData['title'], // Sử dụng 'name' thay vì 'title'
      'title': exerciseData['title'], // Giữ lại title để tương thích
      'category': _mapMuscleGroupToCategory(exerciseData['muscleGroup']),
      'muscleGroups': [exerciseData['muscleGroup']], // Array of muscle groups
      'videoUrl': exerciseData['videoUrl'],
      'imageUrl': _generateYouTubeThumbnail(
        _extractYouTubeVideoId(exerciseData['videoUrl']),
      ), // Generate thumbnail từ video ID
      'image': _generateYouTubeThumbnail(
        _extractYouTubeVideoId(exerciseData['videoUrl']),
      ), // Để tương thích
      'description': exerciseData['description'],
      'equipment': exerciseData['equipment'],
      'type': 'workout', // Đánh dấu đây là workout
      'duration': _estimateDuration(
        exerciseData['title'],
      ), // Ước tính thời gian
      'calories': _estimateCalories(exerciseData['title']), // Ước tính calories
      'difficulty': 'Beginner', // Mặc định là Beginner
      'isFavorite': false,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'source': 'Sample',
      'steps': _createWorkoutSteps(exerciseData), // Tạo workout steps
      // ✅ TRƯỜNG WORKOUT - Lưu toàn bộ dữ liệu workout
      'workout': {
        'title': exerciseData['title'],
        'muscleGroup': exerciseData['muscleGroup'],
        'videoUrl': exerciseData['videoUrl'],
        'thumbnail': _generateYouTubeThumbnail(
          _extractYouTubeVideoId(exerciseData['videoUrl']),
        ),
        'description': exerciseData['description'],
        'equipment': exerciseData['equipment'],
        'duration': _estimateDuration(exerciseData['title']),
        'calories': _estimateCalories(exerciseData['title']),
        'difficulty': 'Beginner',
        'steps': _createWorkoutSteps(exerciseData),
        'videoMetadata': {
          'platform': 'youtube',
          'videoId': _extractYouTubeVideoId(exerciseData['videoUrl']),
          'embedUrl': exerciseData['videoUrl'],
          'thumbnailUrl': _generateYouTubeThumbnail(
            _extractYouTubeVideoId(exerciseData['videoUrl']),
          ),
          'canPlayInApp': true,
        },
      },
    });
  }
  debugPrint('All exercises uploaded to Firestore!');
}

/// Map muscle group to category for workout organization
String _mapMuscleGroupToCategory(String muscleGroup) {
  switch (muscleGroup.toLowerCase()) {
    case 'chest':
    case 'back':
    case 'shoulders':
    case 'biceps':
    case 'triceps':
      return 'Strength';
    case 'legs':
    case 'glutes':
      return 'Strength';
    case 'core':
      return 'Core';
    default:
      return 'Strength';
  }
}

/// Estimate workout duration based on exercise type
int _estimateDuration(String exerciseName) {
  final name = exerciseName.toLowerCase();
  if (name.contains('plank') || name.contains('bridge')) {
    return 10; // Hold exercises: 10 minutes
  } else if (name.contains('curl') || name.contains('extension')) {
    return 15; // Isolation exercises: 15 minutes
  } else {
    return 20; // Compound exercises: 20 minutes
  }
}

/// Estimate calories burned based on exercise type
int _estimateCalories(String exerciseName) {
  final name = exerciseName.toLowerCase();
  if (name.contains('plank') || name.contains('bridge')) {
    return 50; // Core exercises: 50 calories
  } else if (name.contains('squat') || name.contains('lunge')) {
    return 100; // Leg exercises: 100 calories
  } else if (name.contains('push-up') || name.contains('row')) {
    return 80; // Upper body compound: 80 calories
  } else {
    return 60; // Isolation exercises: 60 calories
  }
}

/// Extract YouTube video ID from URL
String _extractYouTubeVideoId(String videoUrl) {
  // Handle embed URLs like: https://www.youtube.com/embed/IODxDxX7oi4
  if (videoUrl.contains('/embed/')) {
    return videoUrl.split('/embed/')[1].split('?')[0];
  }
  // Handle watch URLs like: https://www.youtube.com/watch?v=IODxDxX7oi4
  if (videoUrl.contains('v=')) {
    return videoUrl.split('v=')[1].split('&')[0];
  }
  // Handle short URLs like: https://youtu.be/IODxDxX7oi4
  if (videoUrl.contains('youtu.be/')) {
    return videoUrl.split('youtu.be/')[1].split('?')[0];
  }
  // Fallback - return as is
  return videoUrl;
}

/// Generate YouTube thumbnail URL from video ID
String _generateYouTubeThumbnail(String videoId) {
  // Try multiple thumbnail formats in order of preference
  // maxresdefault.jpg (1280x720) - highest quality
  // hqdefault.jpg (480x360) - high quality fallback
  // mqdefault.jpg (320x180) - medium quality fallback
  // default.jpg (120x90) - always available
  return "https://img.youtube.com/vi/$videoId/hqdefault.jpg";
}

/// Create workout steps from exercise data
List<Map<String, dynamic>> _createWorkoutSteps(
  Map<String, dynamic> exerciseData,
) {
  return [
    {
      'stepNumber': 1,
      'title': 'Warm-up',
      'description': '5 minutes light warm-up and stretching',
      'duration': 300, // 5 minutes in seconds
      'image': null,
      'reps': null,
      'sets': null,
    },
    {
      'stepNumber': 2,
      'title': exerciseData['title'],
      'description': exerciseData['description'],
      'duration':
          (_estimateDuration(exerciseData['title']) - 10) *
          60, // convert to seconds
      'image': exerciseData['thumbnail'],
      'reps': 12,
      'sets': 3,
    },
    {
      'stepNumber': 3,
      'title': 'Cool Down',
      'description': '5 minutes stretching and relaxation',
      'duration': 300, // 5 minutes in seconds
      'image': null,
      'reps': null,
      'sets': null,
    },
  ];
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
