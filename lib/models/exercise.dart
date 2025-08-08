import 'package:cloud_firestore/cloud_firestore.dart';

class Exercise {
  final String id;
  final String name;
  final String description;
  final String category;
  final String? imageUrl;
  final List<String> muscleGroups;
  final String instructions;

  // 🔽 Các trường mới để hỗ trợ dữ liệu từ GymVisual / Firestore
  final String? difficulty;
  final String? equipment;
  final String? source;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  final Map<String, dynamic>? gymVisualData; // Dữ liệu phụ nếu có

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
    this.gymVisualData,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString(),
      muscleGroups: (json['muscleGroups'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      instructions: json['instructions']?.toString() ?? '',
      difficulty: json['difficulty']?.toString(),
      equipment: json['equipment']?.toString(),
      source: json['source']?.toString(),
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
      gymVisualData: json['gymVisualData'] as Map<String, dynamic>?,
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
      'difficulty': difficulty,
      'equipment': equipment,
      'source': source,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'gymVisualData': gymVisualData,
    };
  }

  // 🔽 Helper để parse thời gian
  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is String) return DateTime.tryParse(value);
    if (value is Timestamp) return value.toDate(); // Firestore support
    return null;
  }
}
  