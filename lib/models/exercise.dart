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
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString(),
      muscleGroups:
          (json['muscleGroups'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      instructions: json['instructions']?.toString() ?? '',
    );
  }

  String? get difficulty => null;

  String? get equipment => null;

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
