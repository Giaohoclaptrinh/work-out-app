import 'package:cloud_firestore/cloud_firestore.dart';

class SampleData {
  static final List<Map<String, dynamic>> workouts = [
    {
      'name': 'Full Body Strength',
      'description':
          'A comprehensive full body workout targeting all major muscle groups with compound exercises.',
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
          'description':
              '3 sets of 12-15 reps. Keep your body straight and lower your chest to the ground.',
          'duration': 180,
          'reps': 15,
          'sets': 3,
        },
        {
          'stepNumber': 3,
          'title': 'Squats',
          'description':
              '4 sets of 15-20 reps. Keep your feet shoulder-width apart and lower your hips.',
          'duration': 240,
          'reps': 20,
          'sets': 4,
        },
        {
          'stepNumber': 4,
          'title': 'Plank',
          'description': 'Hold plank position for 30-60 seconds, 3 sets',
          'duration': 180,
          'reps': 1,
          'sets': 3,
        },
      ],
    },
    {
      'name': 'Cardio HIIT',
      'description':
          'High-intensity interval training to boost your cardiovascular fitness and burn calories.',
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
        {
          'stepNumber': 3,
          'title': 'Burpees',
          'description':
              '30 seconds high intensity, 30 seconds rest. Repeat 4 times.',
          'duration': 240,
          'reps': 4,
          'sets': 1,
        },
        {
          'stepNumber': 4,
          'title': 'Mountain Climbers',
          'description':
              '30 seconds high intensity, 30 seconds rest. Repeat 4 times.',
          'duration': 240,
          'reps': 4,
          'sets': 1,
        },
      ],
    },
    {
      'name': 'Core Focus',
      'description':
          'Target your abdominal muscles with this focused core workout.',
      'image': 'assets/img/Workout3.png',
      'category': 'Strength',
      'duration': 25,
      'calories': 200,
      'difficulty': 'Beginner',
      'muscleGroups': ['Abs', 'Core'],
      'steps': [
        {
          'stepNumber': 1,
          'title': 'Crunches',
          'description': '3 sets of 15-20 reps. Focus on engaging your core.',
          'duration': 180,
          'reps': 20,
          'sets': 3,
        },
        {
          'stepNumber': 2,
          'title': 'Russian Twists',
          'description':
              '3 sets of 20 reps (10 each side). Keep your feet off the ground.',
          'duration': 180,
          'reps': 20,
          'sets': 3,
        },
        {
          'stepNumber': 3,
          'title': 'Leg Raises',
          'description': '3 sets of 12-15 reps. Keep your legs straight.',
          'duration': 180,
          'reps': 15,
          'sets': 3,
        },
        {
          'stepNumber': 4,
          'title': 'Plank Hold',
          'description': 'Hold plank position for 45 seconds, 3 sets',
          'duration': 135,
          'reps': 1,
          'sets': 3,
        },
      ],
    },
    {
      'name': 'Yoga Flow',
      'description':
          'A gentle yoga sequence to improve flexibility and reduce stress.',
      'image': 'assets/img/Workout1.png',
      'category': 'Yoga',
      'duration': 40,
      'calories': 150,
      'difficulty': 'Beginner',
      'muscleGroups': ['Full Body', 'Flexibility'],
      'steps': [
        {
          'stepNumber': 1,
          'title': 'Child\'s Pose',
          'description': 'Hold for 5 breaths to center yourself',
          'duration': 30,
        },
        {
          'stepNumber': 2,
          'title': 'Cat-Cow Stretch',
          'description': 'Flow between cat and cow poses for 10 breaths',
          'duration': 60,
        },
        {
          'stepNumber': 3,
          'title': 'Downward Dog',
          'description': 'Hold for 5 breaths, then walk your feet forward',
          'duration': 30,
        },
        {
          'stepNumber': 4,
          'title': 'Warrior I',
          'description': 'Hold each side for 5 breaths',
          'duration': 60,
        },
      ],
    },
  ];

  static final List<Map<String, dynamic>> tips = [
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

  static Future<void> addSampleData() async {
    final firestore = FirebaseFirestore.instance;

    // Add workouts
    for (final workout in workouts) {
      await firestore.collection('workouts').add(workout);
    }

    // Add tips
    for (final tip in tips) {
      await firestore.collection('workoutTips').add(tip);
    }

    print('Sample data added successfully!');
  }
}
