class Exercise {
  final String id;
  final String name;
  final String description;
  final String category;
  final String? imageUrl;
  final List<String> muscleGroups;
  final String instructions;

  const Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.imageUrl,
    required this.muscleGroups,
    required this.instructions,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      imageUrl: json['imageUrl'] as String?,
      muscleGroups: List<String>.from(json['muscleGroups'] as List),
      instructions: json['instructions'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'imageUrl': imageUrl,
      'muscleGroups': muscleGroups,
      'instructions': instructions,
    };
  }
}

// Sample exercises for demo purposes
class SampleExercises {
  static final List<Exercise> exercises = [
    Exercise(
      id: '1',
      name: 'Push-ups',
      description:
          'Classic bodyweight exercise for chest, shoulders, and triceps',
      category: 'Bodyweight',
      muscleGroups: ['Chest', 'Shoulders', 'Triceps'],
      instructions:
          '1. Start in plank position\n2. Lower body until chest nearly touches floor\n3. Push back up to starting position\n4. Repeat',
    ),
    Exercise(
      id: '2',
      name: 'Squats',
      description: 'Fundamental lower body exercise',
      category: 'Bodyweight',
      muscleGroups: ['Quadriceps', 'Glutes', 'Hamstrings'],
      instructions:
          '1. Stand with feet shoulder-width apart\n2. Lower body as if sitting back into a chair\n3. Keep chest up and knees behind toes\n4. Return to starting position',
    ),
    Exercise(
      id: '3',
      name: 'Plank',
      description: 'Core strengthening exercise',
      category: 'Core',
      muscleGroups: ['Core', 'Shoulders'],
      instructions:
          '1. Start in push-up position\n2. Lower to forearms\n3. Keep body straight from head to heels\n4. Hold position',
    ),
  ];
}
