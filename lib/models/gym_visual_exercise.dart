import 'package:flutter/material.dart';
import 'exercise.dart';

class GymVisualExercise extends Exercise {
  final String source;
  final String equipment;
  final String difficulty;
  final String? gymVisualId;
  final DateTime? importedAt;
  final Map<String, dynamic>? additionalData;

  const GymVisualExercise({
    required super.id,
    required super.name,
    required super.description,
    required super.category,
    super.imageUrl,
    required super.muscleGroups,
    required super.instructions,
    required this.source,
    required this.equipment,
    required this.difficulty,
    this.gymVisualId,
    this.importedAt,
    this.additionalData,
  });

  factory GymVisualExercise.fromExercise(Exercise exercise, {
    required String source,
    required String equipment,
    required String difficulty,
    String? gymVisualId,
    DateTime? importedAt,
    Map<String, dynamic>? additionalData,
  }) {
    return GymVisualExercise(
      id: exercise.id,
      name: exercise.name,
      description: exercise.description,
      category: exercise.category,
      imageUrl: exercise.imageUrl,
      muscleGroups: exercise.muscleGroups,
      instructions: exercise.instructions,
      source: source,
      equipment: equipment,
      difficulty: difficulty,
      gymVisualId: gymVisualId,
      importedAt: importedAt,
      additionalData: additionalData,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'source': source,
      'equipment': equipment,
      'difficulty': difficulty,
      'gymVisualId': gymVisualId,
      'importedAt': importedAt?.toIso8601String(),
      'additionalData': additionalData,
    };
  }

  factory GymVisualExercise.fromJson(Map<String, dynamic> json) {
    final exercise = Exercise.fromJson(json);
    return GymVisualExercise(
      id: exercise.id,
      name: exercise.name,
      description: exercise.description,
      category: exercise.category,
      imageUrl: exercise.imageUrl,
      muscleGroups: exercise.muscleGroups,
      instructions: exercise.instructions,
      source: json['source'] as String,
      equipment: json['equipment'] as String,
      difficulty: json['difficulty'] as String,
      gymVisualId: json['gymVisualId'] as String?,
      importedAt: json['importedAt'] != null
          ? DateTime.parse(json['importedAt'] as String)
          : null,
      additionalData: json['additionalData'] as Map<String, dynamic>?,
    );
  }

  GymVisualExercise copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? imageUrl,
    List<String>? muscleGroups,
    String? instructions,
    String? source,
    String? equipment,
    String? difficulty,
    String? gymVisualId,
    DateTime? importedAt,
    Map<String, dynamic>? additionalData,
  }) {
    return GymVisualExercise(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      muscleGroups: muscleGroups ?? this.muscleGroups,
      instructions: instructions ?? this.instructions,
      source: source ?? this.source,
      equipment: equipment ?? this.equipment,
      difficulty: difficulty ?? this.difficulty,
      gymVisualId: gymVisualId ?? this.gymVisualId,
      importedAt: importedAt ?? this.importedAt,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  // Get difficulty color
  Color get difficultyColor {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Get equipment icon
  IconData get equipmentIcon {
    switch (equipment.toLowerCase()) {
      case 'none':
        return Icons.person;
      case 'weight':
        return Icons.fitness_center;
      case 'hyperextension bench':
        return Icons.airline_seat_flat;
      case 'incline bench, weight':
        return Icons.airline_seat_flat_angled;
      default:
        return Icons.fitness_center;
    }
  }

  // Check if exercise requires equipment
  bool get requiresEquipment {
    return equipment.toLowerCase() != 'none';
  }

  // Get formatted import date
  String get formattedImportDate {
    if (importedAt == null) return 'Not imported';
    return 'Imported on ${importedAt!.day}/${importedAt!.month}/${importedAt!.year}';
  }
} 