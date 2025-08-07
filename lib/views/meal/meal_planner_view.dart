import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../common/color_extension.dart';
import '../../common/common_widgets.dart';
import '../../widgets/meal_category_cell.dart';
import '../../widgets/today_meal_row.dart';
import '../../widgets/popular_meal_row.dart';
import '../../widgets/find_eat_cell.dart';
import '../../widgets/meal_recommed_cell.dart';

class MealPlannerView extends StatefulWidget {
  const MealPlannerView({super.key});

  @override
  State<MealPlannerView> createState() => _MealPlannerViewState();
}

class _MealPlannerViewState extends State<MealPlannerView> {
  List<FlSpot> nutritionSpots = [];
  List<Map<String, dynamic>> mealArr = [];
  List<Map<String, dynamic>> todayMealArr = [];
  List<Map<String, dynamic>> popularMeals = [];
  List<Map<String, dynamic>> recommendedMeals = [];
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _initializeData() {
    if (_disposed) return;

    // Xóa dữ liệu mẫu nutrition chart
    nutritionSpots = [];

    // Meal Schedule
    mealArr = [
      {'name': 'Breakfast', 'time': '08:00 AM', 'image': 'assets/img/m_1.png'},
      {'name': 'Lunch', 'time': '12:00 PM', 'image': 'assets/img/m_2.png'},
      {'name': 'Snacks', 'time': '03:00 PM', 'image': 'assets/img/m_3.png'},
      {'name': 'Dinner', 'time': '07:00 PM', 'image': 'assets/img/m_4.png'},
    ];

    // Clear sample data - will be populated from real data
    todayMealArr = [];
    popularMeals = [];
    recommendedMeals = [];

    if (!_disposed) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: TColor.white,
        centerTitle: true,
        elevation: 0,
        leadingWidth: 0,
        leading: const SizedBox(),
        title: Text(
          "Meal Planner",
          style: TextStyle(
            color: TColor.black,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.more_horiz, color: TColor.black, size: 20),
          ),
        ],
      ),
      backgroundColor: TColor.white,
      body: RefreshIndicator(
        onRefresh: () async => _initializeData(),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Nutrition Chart
              if (nutritionSpots.isNotEmpty) _buildNutritionChart(),

              /// Meal Schedule Box
              _buildMealScheduleBox(),

              /// Meal Categories
              if (mealArr.isNotEmpty) _buildMealCategories(),

              /// Today Meals
              if (todayMealArr.isNotEmpty)
                _buildSection(
                  "Today Meals",
                  todayMealArr.map((meal) => TodayMealRow(mObj: meal)).toList(),
                ),

              /// Popular Meals
              if (popularMeals.isNotEmpty)
                _buildSection(
                  "Popular Meals",
                  popularMeals
                      .map((meal) => PopularMealRow(mObj: meal))
                      .toList(),
                ),

              /// Recommended Meals
              if (recommendedMeals.isNotEmpty)
                _buildSection(
                  "Recommended",
                  recommendedMeals
                      .asMap()
                      .entries
                      .map(
                        (entry) => MealRecommendCell(
                          index: entry.key,
                          fObj: entry.value,
                        ),
                      )
                      .toList(),
                ),

              /// Find What to Eat
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Text(
                  "Find What to Eat",
                  style: TextStyle(
                    color: TColor.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              FindEatCell(
                index: 0,
                fObj: {
                  'name': 'Search for meals',
                  'number': 'Find healthy recipes',
                  'image': 'assets/img/m_1.png',
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNutritionChart() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      padding: const EdgeInsets.all(15),
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: TColor.primaryG),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Daily Nutrition",
            style: TextStyle(
              color: TColor.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Calories consumed today",
            style: TextStyle(
              color: TColor.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots: nutritionSpots,
                    isCurved: true,
                    color: TColor.white,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    belowBarData: BarAreaData(
                      show: true,
                      color: TColor.white.withOpacity(0.2),
                    ),
                  ),
                ],
                minY: 1000,
                maxY: 3000,
                titlesData: const FlTitlesData(show: false),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealScheduleBox() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      decoration: BoxDecoration(
        color: TColor.mealPrimary.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Daily Meal Schedule",
            style: TextStyle(
              color: TColor.black,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(
            width: 70,
            height: 25,
            child: RoundButton(title: "Check", fontSize: 10, onPressed: () {}),
          ),
        ],
      ),
    );
  }

  Widget _buildMealCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Meal Categories",
            style: TextStyle(
              color: TColor.black,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(
          height: 120,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            scrollDirection: Axis.horizontal,
            itemCount: mealArr.length,
            itemBuilder: (context, index) {
              var mObj = mealArr[index];
              return MealCategoryCell(index: index, cObj: mObj);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: TColor.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  "See More",
                  style: TextStyle(color: TColor.gray, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
        ...children,
      ],
    );
  }
}
