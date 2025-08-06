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
