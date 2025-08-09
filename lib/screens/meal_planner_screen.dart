import 'package:flutter/material.dart';
import '../common/color_extension.dart';
import '../models/meal.dart';
import '../services/meal_service.dart';
import '../utils/firestore_helper.dart';
import '../widgets/round_button.dart';
import '../widgets/meal_row.dart';

class MealPlannerScreen extends StatefulWidget {
  const MealPlannerScreen({super.key});

  @override
  State<MealPlannerScreen> createState() => _MealPlannerScreenState();
}

class _MealPlannerScreenState extends State<MealPlannerScreen> {
  final MealService _mealService = MealService();
  DateTime _selectedDate = DateTime.now();
  MealPlan? _currentMealPlan;
  List<Meal> _allMeals = [];
  bool _isLoading = true;

  final List<String> _categories = ['breakfast', 'lunch', 'dinner', 'snack'];

  final Map<String, String> _categoryNames = {
    'breakfast': 'Breakfast',
    'lunch': 'Lunch',
    'dinner': 'Dinner',
    'snack': 'Snack',
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final futures = await Future.wait([
        _mealService.getAllMeals(),
        _mealService.getMealPlanForDate(_selectedDate),
      ]);

      if (mounted) {
        setState(() {
          _allMeals = futures[0] as List<Meal>;
          _currentMealPlan = futures[1] as MealPlan?;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading meal data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadData();
    }
  }

  void _addMeal(String category) {
    final availableMeals = _allMeals
        .where((meal) => meal.category == category)
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Chọn món cho ${_categoryNames[category]}',
                      style: TextStyle(
                        color: TColor.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: availableMeals.length,
                itemBuilder: (context, index) {
                  final meal = availableMeals[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: MealRow(
                      meal: meal,
                      onTap: () {
                        _addMealToPlan(category, meal);
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addMealToPlan(String category, Meal meal) async {
    await _mealService.addMealToPlan(_selectedDate, category, meal);
    _loadData();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã thêm ${meal.name} vào ${_categoryNames[category]}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _removeMeal(String category, String mealId) async {
    await _mealService.removeMealFromPlan(_selectedDate, category, mealId);
    _loadData();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã xóa món ăn khỏi kế hoạch'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _importSampleMeals() async {
    try {
      await FirestoreHelper.addSampleMealsToFirestore();
      await _loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sample meals imported successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error importing meals: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.white,
      appBar: AppBar(
        backgroundColor: TColor.white,
        centerTitle: true,
        elevation: 0,
        title: Text(
          'Meal Planner',
          style: TextStyle(
            color: TColor.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: TColor.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: TColor.primaryColor1),
            onPressed: _importSampleMeals,
            tooltip: 'Import Sample Meals',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  // Date Selector
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.chevron_left,
                            color: TColor.primaryColor1,
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedDate = _selectedDate.subtract(
                                const Duration(days: 1),
                              );
                            });
                            _loadData();
                          },
                        ),
                        Expanded(
                          child: Center(
                            child: GestureDetector(
                              onTap: _selectDate,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: TColor.primaryColor1,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.chevron_right,
                            color: TColor.primaryColor1,
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedDate = _selectedDate.add(
                                const Duration(days: 1),
                              );
                            });
                            _loadData();
                          },
                        ),
                      ],
                    ),
                  ),

                  // Calories Summary
                  if (_currentMealPlan != null)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: TColor.primaryColor1.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Calories',
                                style: TextStyle(
                                  color: TColor.gray,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '${_currentMealPlan!.totalCalories}',
                                style: TextStyle(
                                  color: TColor.black,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Icon(
                            Icons.local_fire_department,
                            color: TColor.primaryColor1,
                            size: 32,
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Meal Categories
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        final meals = _currentMealPlan?.meals[category] ?? [];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      _categoryNames[category]!,
                                      style: TextStyle(
                                        color: TColor.black,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  SizedBox(
                                    width: 100,
                                    child: RoundButton(
                                      title: 'Add Meal',
                                      onPressed: () => _addMeal(category),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              if (meals.isEmpty)
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: TColor.gray.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.restaurant,
                                          size: 48,
                                          color: TColor.gray,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Chưa có món nào',
                                          style: TextStyle(
                                            color: TColor.gray,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              else
                                ...meals.map(
                                  (meal) => Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: MealRow(
                                      meal: meal,
                                      onTap: () =>
                                          _removeMeal(category, meal.id),
                                      showRemoveButton: true,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
