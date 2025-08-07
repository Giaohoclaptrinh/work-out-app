class Meal {
  final String id;
  final String name;
  final String description;
  final String image;
  final int calories;
  final String category; // breakfast, lunch, dinner, snack
  final List<String> tags; // low-carb, high-protein, etc.
  final String? recipe;
  final int prepTime; // minutes

  Meal({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.calories,
    required this.category,
    required this.tags,
    this.recipe,
    required this.prepTime,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      calories: json['calories'] ?? 0,
      category: json['category'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      recipe: json['recipe'],
      prepTime: json['prepTime'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image': image,
      'calories': calories,
      'category': category,
      'tags': tags,
      'recipe': recipe,
      'prepTime': prepTime,
    };
  }
}

class MealPlan {
  final String id;
  final DateTime date;
  final Map<String, List<Meal>> meals; // category -> meals
  final int totalCalories;

  MealPlan({
    required this.id,
    required this.date,
    required this.meals,
    required this.totalCalories,
  });

  factory MealPlan.fromJson(Map<String, dynamic> json) {
    final mealsMap = <String, List<Meal>>{};
    final mealsData = json['meals'] as Map<String, dynamic>? ?? {};

    mealsData.forEach((category, mealsList) {
      if (mealsList is List) {
        mealsMap[category] = mealsList
            .map((meal) => Meal.fromJson(meal as Map<String, dynamic>))
            .toList();
      }
    });

    return MealPlan(
      id: json['id'] ?? '',
      date: DateTime.parse(json['date']),
      meals: mealsMap,
      totalCalories: json['totalCalories'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    final mealsData = <String, dynamic>{};
    meals.forEach((category, mealsList) {
      mealsData[category] = mealsList.map((meal) => meal.toJson()).toList();
    });

    return {
      'id': id,
      'date': date.toIso8601String(),
      'meals': mealsData,
      'totalCalories': totalCalories,
    };
  }
}
