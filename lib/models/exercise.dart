import 'package:cloud_firestore/cloud_firestore.dart';

// Forward declaration for WorkoutStep
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

class Exercise {
  final String id;
  final String name;
  final String description;
  final String category;
  final String?
  imageUrl; // Có thể là image từ workout hoặc imageUrl từ exercise
  final List<String> muscleGroups;
  final String instructions;

  // 🔽 Additional fields for enhanced exercise data
  final String? difficulty;
  final String? equipment;
  final String? source;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // 🔽 Workout-specific fields (optional)
  final int? duration; // minutes - từ workout
  final int? calories; // từ workout
  final List<WorkoutStep>? steps; // từ workout
  final bool isFavorite; // từ workout
  final DateTime? completedAt; // từ workout

  // 🔽 Exercise type - để phân biệt loại
  final String type; // 'exercise' hoặc 'workout'

  // 🔽 Workout data field - chứa toàn bộ dữ liệu workout
  final Map<String, dynamic>? workout; // Dữ liệu workout đầy đủ

  final Map<String, dynamic>? additionalData; // Dữ liệu phụ

  const Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.imageUrl,
    required this.muscleGroups,
    required this.instructions,
    this.difficulty,
    this.equipment,
    this.source,
    this.createdAt,
    this.updatedAt,
    this.duration,
    this.calories,
    this.steps,
    this.isFavorite = false,
    this.completedAt,
    this.type = 'exercise',
    this.workout,
    this.additionalData,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? json['image']?.toString(),
      muscleGroups:
          (json['muscleGroups'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      instructions: json['instructions']?.toString() ?? '',
      difficulty: json['difficulty']?.toString(),
      equipment: json['equipment']?.toString(),
      source: json['source']?.toString(),
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
      duration: json['duration'] as int?,
      calories: json['calories'] as int?,
      steps: (json['steps'] as List?)
          ?.map((step) => WorkoutStep.fromJson(step as Map<String, dynamic>))
          .toList(),
      isFavorite: json['isFavorite'] as bool? ?? false,
      completedAt: _parseDate(json['completedAt']),
      type: json['type']?.toString() ?? 'exercise',
      workout: json['workout'] as Map<String, dynamic>?,
      additionalData: json['additionalData'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'imageUrl': imageUrl,
      'image': imageUrl, // Backward compatibility
      'muscleGroups': muscleGroups,
      'instructions': instructions,
      'difficulty': difficulty,
      'equipment': equipment,
      'source': source,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'duration': duration,
      'calories': calories,
      'steps': steps?.map((step) => step.toJson()).toList(),
      'isFavorite': isFavorite,
      'completedAt': completedAt?.toIso8601String(),
      'type': type,
      'workout': workout,
      'additionalData': additionalData,
    };
  }

  // 🔽 Helper để parse thời gian
  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is String) return DateTime.tryParse(value);
    if (value is Timestamp) return value.toDate(); // Firestore support
    return null;
  }

  // 🔽 Helper methods để tạo Exercise từ Workout data
  factory Exercise.fromWorkout({
    required String id,
    required String name,
    required String description,
    required String image,
    required String category,
    required int duration,
    required int calories,
    required String difficulty,
    required List<String> muscleGroups,
    required List<WorkoutStep> steps,
    bool isFavorite = false,
    DateTime? completedAt,
  }) {
    return Exercise(
      id: id,
      name: name,
      description: description,
      category: category,
      imageUrl: image,
      muscleGroups: muscleGroups,
      instructions: steps.map((step) => step.description).join('\n'),
      difficulty: difficulty,
      duration: duration,
      calories: calories,
      steps: steps,
      isFavorite: isFavorite,
      completedAt: completedAt,
      type: 'workout',
      createdAt: DateTime.now(),
    );
  }

  // 🔽 Check if this is a workout-type exercise
  bool get isWorkout => type == 'workout';
  bool get isBasicExercise => type == 'exercise';

  // 🔽 Get display image
  String get displayImage => imageUrl ?? 'assets/img/Workout1.png';

  // 🔽 CopyWith method
  Exercise copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? imageUrl,
    List<String>? muscleGroups,
    String? instructions,
    String? difficulty,
    String? equipment,
    String? source,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? duration,
    int? calories,
    List<WorkoutStep>? steps,
    bool? isFavorite,
    DateTime? completedAt,
    String? type,
    Map<String, dynamic>? workout,
    Map<String, dynamic>? additionalData,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      muscleGroups: muscleGroups ?? this.muscleGroups,
      instructions: instructions ?? this.instructions,
      difficulty: difficulty ?? this.difficulty,
      equipment: equipment ?? this.equipment,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      duration: duration ?? this.duration,
      calories: calories ?? this.calories,
      steps: steps ?? this.steps,
      isFavorite: isFavorite ?? this.isFavorite,
      completedAt: completedAt ?? this.completedAt,
      type: type ?? this.type,
      workout: workout ?? this.workout,
      additionalData: additionalData ?? this.additionalData,
    );
  }
}
