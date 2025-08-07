import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/meal.dart';

class MealService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Lấy tất cả meals
  Future<List<Meal>> getAllMeals() async {
    try {
      final snapshot = await _firestore.collection('meals').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Meal.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error fetching meals: $e');
      return _getSampleMeals();
    }
  }

  // Lấy meals theo category
  Future<List<Meal>> getMealsByCategory(String category) async {
    try {
      final snapshot = await _firestore
          .collection('meals')
          .where('category', isEqualTo: category)
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Meal.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error fetching meals by category: $e');
      return _getSampleMeals()
          .where((meal) => meal.category == category)
          .toList();
    }
  }

  // Lấy meal plan cho ngày cụ thể
  Future<MealPlan?> getMealPlanForDate(DateTime date) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final dateString = date.toIso8601String().split('T')[0];
      print('Fetching meal plan for date: $dateString');

      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('mealPlans')
          .where('date', isEqualTo: dateString)
          .get();

      print('Found ${snapshot.docs.length} meal plans for date $dateString');

      if (snapshot.docs.isEmpty) {
        print('No meal plan found for date $dateString');
        return null;
      }

      final data = snapshot.docs.first.data();
      print('Meal plan data: $data');

      return MealPlan.fromJson(data);
    } catch (e) {
      print('Error fetching meal plan: $e');
      return null;
    }
  }

  // Tạo meal plan cho ngày cụ thể
  Future<void> createMealPlanForDate(
    DateTime date,
    Map<String, List<Meal>> meals,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final dateString = date.toIso8601String().split('T')[0];
      final mealPlan = MealPlan(
        id: dateString,
        date: date,
        meals: meals,
        totalCalories: _calculateTotalCalories(meals),
      );

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('mealPlans')
          .doc(dateString)
          .set(mealPlan.toJson());

      print('Meal plan created for date: $dateString');
    } catch (e) {
      print('Error creating meal plan: $e');
    }
  }

  // Cập nhật meal plan
  Future<void> updateMealPlan(
    String planId,
    Map<String, List<Meal>> meals,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final mealPlan = MealPlan(
        id: planId,
        date: DateTime.parse(planId),
        meals: meals,
        totalCalories: _calculateTotalCalories(meals),
      );

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('mealPlans')
          .doc(planId)
          .set(mealPlan.toJson());

      print('Meal plan updated: $planId');
    } catch (e) {
      print('Error updating meal plan: $e');
    }
  }

  // Xóa meal plan
  Future<void> deleteMealPlan(String planId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('mealPlans')
          .doc(planId)
          .delete();

      print('Meal plan deleted: $planId');
    } catch (e) {
      print('Error deleting meal plan: $e');
    }
  }

  // Thêm meal vào plan
  Future<void> addMealToPlan(DateTime date, String category, Meal meal) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final dateString = date.toIso8601String().split('T')[0];
      final docRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('mealPlans')
          .doc(dateString);

      print(
        'Adding meal ${meal.name} to category $category for date $dateString',
      );

      final doc = await docRef.get();
      if (doc.exists) {
        // Update existing plan
        final data = doc.data()!;
        print('Existing plan found, updating...');

        // Parse existing meals properly
        final mealsMap = <String, List<Meal>>{};
        final mealsData = data['meals'] as Map<String, dynamic>? ?? {};

        mealsData.forEach((cat, mealsList) {
          if (mealsList is List) {
            mealsMap[cat] = mealsList
                .map((meal) => Meal.fromJson(meal as Map<String, dynamic>))
                .toList();
          }
        });

        // Add new meal to the category
        mealsMap[category] = [...(mealsMap[category] ?? []), meal];

        await docRef.update({
          'meals': mealsMap.map(
            (key, value) =>
                MapEntry(key, value.map((m) => m.toJson()).toList()),
          ),
          'totalCalories': _calculateTotalCalories(mealsMap),
        });
        print('Plan updated successfully');
      } else {
        // Create new plan
        print('Creating new plan...');
        final meals = {
          category: [meal],
        };
        await docRef.set({
          'date': dateString,
          'meals': meals.map(
            (key, value) =>
                MapEntry(key, value.map((m) => m.toJson()).toList()),
          ),
          'totalCalories': _calculateTotalCalories(meals),
        });
        print('New plan created successfully');
      }
    } catch (e) {
      print('Error adding meal to plan: $e');
    }
  }

  // Xóa meal khỏi plan
  Future<void> removeMealFromPlan(
    DateTime date,
    String category,
    String mealId,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final dateString = date.toIso8601String().split('T')[0];
      final docRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('mealPlans')
          .doc(dateString);

      print(
        'Removing meal $mealId from category $category for date $dateString',
      );

      final doc = await docRef.get();
      if (doc.exists) {
        final data = doc.data()!;

        // Parse existing meals properly
        final mealsMap = <String, List<Meal>>{};
        final mealsData = data['meals'] as Map<String, dynamic>? ?? {};

        mealsData.forEach((cat, mealsList) {
          if (mealsList is List) {
            mealsMap[cat] = mealsList
                .map((meal) => Meal.fromJson(meal as Map<String, dynamic>))
                .toList();
          }
        });

        // Remove meal from the category
        mealsMap[category] = (mealsMap[category] ?? [])
            .where((meal) => meal.id != mealId)
            .toList();

        await docRef.update({
          'meals': mealsMap.map(
            (key, value) =>
                MapEntry(key, value.map((m) => m.toJson()).toList()),
          ),
          'totalCalories': _calculateTotalCalories(mealsMap),
        });
        print('Meal removed successfully');
      }
    } catch (e) {
      print('Error removing meal from plan: $e');
    }
  }

  // Tính tổng calories
  int _calculateTotalCalories(Map<String, List<Meal>> meals) {
    int total = 0;
    meals.values.forEach((mealList) {
      total += mealList.fold(0, (sum, meal) => sum + meal.calories);
    });
    return total;
  }

  // Lấy danh sách mẫu meals
  List<Meal> _getSampleMeals() {
    return [
      // Breakfast
      Meal(
        id: 'b1',
        name: 'Oatmeal with Berries',
        description: 'Healthy oatmeal topped with fresh berries and honey',
        image: 'assets/img/oatmeal.png',
        calories: 250,
        category: 'breakfast',
        tags: ['low-carb', 'high-fiber'],
        prepTime: 10,
      ),
      Meal(
        id: 'b2',
        name: 'Scrambled Eggs',
        description: 'Fluffy scrambled eggs with whole grain toast',
        image: 'assets/img/eggs.png',
        calories: 300,
        category: 'breakfast',
        tags: ['high-protein'],
        prepTime: 15,
      ),
      Meal(
        id: 'b3',
        name: 'Smoothie Bowl',
        description: 'Colorful smoothie bowl with granola and fruits',
        image: 'assets/img/pancake_1.png',
        calories: 280,
        category: 'breakfast',
        tags: ['vegan', 'gluten-free'],
        prepTime: 8,
      ),

      // Lunch
      Meal(
        id: 'l1',
        name: 'Grilled Chicken Salad',
        description: 'Fresh salad with grilled chicken breast',
        image: 'assets/img/chicken.png',
        calories: 350,
        category: 'lunch',
        tags: ['high-protein', 'low-carb'],
        prepTime: 20,
      ),
      Meal(
        id: 'l2',
        name: 'Quinoa Bowl',
        description: 'Nutritious quinoa bowl with vegetables',
        image: 'assets/img/m_1.png',
        calories: 320,
        category: 'lunch',
        tags: ['vegan', 'gluten-free'],
        prepTime: 25,
      ),
      Meal(
        id: 'l3',
        name: 'Turkey Sandwich',
        description: 'Whole grain sandwich with turkey and avocado',
        image: 'assets/img/m_2.png',
        calories: 380,
        category: 'lunch',
        tags: ['high-protein'],
        prepTime: 12,
      ),

      // Dinner
      Meal(
        id: 'd1',
        name: 'Salmon with Vegetables',
        description: 'Baked salmon with roasted vegetables',
        image: 'assets/img/m_3.png',
        calories: 420,
        category: 'dinner',
        tags: ['high-protein', 'omega-3'],
        prepTime: 30,
      ),
      Meal(
        id: 'd2',
        name: 'Pasta Primavera',
        description: 'Fresh pasta with seasonal vegetables',
        image: 'assets/img/m_4.png',
        calories: 380,
        category: 'dinner',
        tags: ['vegetarian'],
        prepTime: 25,
      ),
      Meal(
        id: 'd3',
        name: 'Beef Stir Fry',
        description: 'Lean beef stir fry with brown rice',
        image: 'assets/img/nigiri.png',
        calories: 450,
        category: 'dinner',
        tags: ['high-protein'],
        prepTime: 20,
      ),

      // Snacks
      Meal(
        id: 's1',
        name: 'Greek Yogurt',
        description: 'Greek yogurt with honey and nuts',
        image: 'assets/img/glass-of-milk 1.png',
        calories: 150,
        category: 'snack',
        tags: ['high-protein', 'probiotic'],
        prepTime: 2,
      ),
      Meal(
        id: 's2',
        name: 'Apple with Peanut Butter',
        description: 'Fresh apple slices with natural peanut butter',
        image: 'assets/img/apple_pie.png',
        calories: 180,
        category: 'snack',
        tags: ['high-fiber', 'protein'],
        prepTime: 5,
      ),
      Meal(
        id: 's3',
        name: 'Mixed Nuts',
        description: 'Assorted nuts and dried fruits',
        image: 'assets/img/orange.png',
        calories: 200,
        category: 'snack',
        tags: ['healthy-fats', 'protein'],
        prepTime: 1,
      ),
    ];
  }
}
