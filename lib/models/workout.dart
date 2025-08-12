import 'exercise.dart';

class WorkoutSet {
  final int reps;
  final double? weight;
  final int? duration; // in seconds
  final bool completed;

  const WorkoutSet({
    required this.reps,
    this.weight,
    this.duration,
    this.completed = false,
  });

  WorkoutSet copyWith({
    int? reps,
    double? weight,
    int? duration,
    bool? completed,
  }) {
    return WorkoutSet(
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      duration: duration ?? this.duration,
      completed: completed ?? this.completed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reps': reps,
      'weight': weight,
      'duration': duration,
      'completed': completed,
    };
  }

  factory WorkoutSet.fromJson(Map<String, dynamic> json) {
    return WorkoutSet(
      reps: json['reps'] as int,
      weight: json['weight'] as double?,
      duration: json['duration'] as int?,
      completed: json['completed'] as bool? ?? false,
    );
  }
}

class WorkoutExercise {
  final Exercise exercise;
  final List<WorkoutSet> sets;
  final String? notes;

  const WorkoutExercise({
    required this.exercise,
    required this.sets,
    this.notes,
  });

  WorkoutExercise copyWith({
    Exercise? exercise,
    List<WorkoutSet>? sets,
    String? notes,
  }) {
    return WorkoutExercise(
      exercise: exercise ?? this.exercise,
      sets: sets ?? this.sets,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exercise': exercise.toJson(),
      'sets': sets.map((set) => set.toJson()).toList(),
      'notes': notes,
    };
  }

  factory WorkoutExercise.fromJson(Map<String, dynamic> json) {
    return WorkoutExercise(
      exercise: Exercise.fromJson(json['exercise'] as Map<String, dynamic>),
      sets: (json['sets'] as List)
          .map(
            (setJson) => WorkoutSet.fromJson(setJson as Map<String, dynamic>),
          )
          .toList(),
      notes: json['notes'] as String?,
    );
  }
}

class Workout {
  final String id;
  final String name;
  final String description;
  final String image;
  final String category;
  final int duration; // minutes
  final int calories;
  final String? difficulty;
  final List<String> muscleGroups;
  final List<WorkoutStep> steps;
  final bool isFavorite;
  final DateTime? completedAt;
  final String? videoUrl;
  final String? equipment;

  Workout({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.category,
    required this.duration,
    required this.calories,
    this.difficulty,
    required this.muscleGroups,
    required this.steps,
    this.isFavorite = false,
    this.completedAt,
    this.videoUrl,
    this.equipment,
  });

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      category: json['category'] ?? '',
      duration: json['duration'] ?? 0,
      calories: json['calories'] ?? 0,
      difficulty: json['difficulty'],
      muscleGroups: List<String>.from(json['muscleGroups'] ?? []),
      steps: (json['steps'] as List? ?? [])
          .map((step) => WorkoutStep.fromJson(step))
          .toList(),
      isFavorite: json['isFavorite'] ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      videoUrl: json['videoUrl'],
      equipment: json['equipment'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image': image,
      'category': category,
      'duration': duration,
      'calories': calories,
      'difficulty': difficulty,
      'muscleGroups': muscleGroups,
      'steps': steps.map((step) => step.toJson()).toList(),
      'isFavorite': isFavorite,
      'completedAt': completedAt?.toIso8601String(),
      'videoUrl': videoUrl,
      'equipment': equipment,
    };
  }

  Workout copyWith({
    String? id,
    String? name,
    String? description,
    String? image,
    String? category,
    int? duration,
    int? calories,
    String? difficulty,
    List<String>? muscleGroups,
    List<WorkoutStep>? steps,
    bool? isFavorite,
    DateTime? completedAt,
    String? videoUrl,
    String? equipment,
  }) {
    return Workout(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      image: image ?? this.image,
      category: category ?? this.category,
      duration: duration ?? this.duration,
      calories: calories ?? this.calories,
      difficulty: difficulty ?? this.difficulty,
      muscleGroups: muscleGroups ?? this.muscleGroups,
      steps: steps ?? this.steps,
      isFavorite: isFavorite ?? this.isFavorite,
      completedAt: completedAt ?? this.completedAt,
      videoUrl: videoUrl ?? this.videoUrl,
      equipment: equipment ?? this.equipment,
    );
  }
}

class WorkoutStep {
  final int stepNumber;
  final String title;
  final String description;
  final String? image;
  final int duration; // seconds
  final int? reps;
  final int? sets;

  WorkoutStep({
    required this.stepNumber,
    required this.title,
    required this.description,
    this.image,
    required this.duration,
    this.reps,
    this.sets,
  });

  factory WorkoutStep.fromJson(Map<String, dynamic> json) {
    return WorkoutStep(
      stepNumber: json['stepNumber'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      image: json['image'],
      duration: json['duration'] ?? 0,
      reps: json['reps'],
      sets: json['sets'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stepNumber': stepNumber,
      'title': title,
      'description': description,
      'image': image,
      'duration': duration,
      'reps': reps,
      'sets': sets,
    };
  }
}
