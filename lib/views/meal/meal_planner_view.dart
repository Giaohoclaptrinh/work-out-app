import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../common/color_extension.dart';
import '../../common/common_widgets.dart';

class MealPlannerView extends StatefulWidget {
  const MealPlannerView({super.key});

  @override
  State<MealPlannerView> createState() => _MealPlannerViewState();
}

class _MealPlannerViewState extends State<MealPlannerView> {
  List<FlSpot> get nutritionSpots => const [
    FlSpot(0, 1200),
    FlSpot(1, 1400),
    FlSpot(2, 1100),
    FlSpot(3, 1600),
    FlSpot(4, 1300),
    FlSpot(5, 1500),
    FlSpot(6, 1400),
  ];

  List mealArr = [
    {
      "name": "Breakfast",
      "image": "assets/img/breakfast.png",
      "time": "1 meals | 230 calories",
    },
    {
      "name": "Lunch", 
      "image": "assets/img/lunch.png",
      "time": "2 meals | 500 calories",
    },
    {
      "name": "Snacks",
      "image": "assets/img/snack.png", 
      "time": "2 meals | 140 calories",
    },
    {
      "name": "Dinner",
      "image": "assets/img/dinner.png",
      "time": "2 meals | 120 calories",
    },
  ];

  List todayMealArr = [
    {
      "name": "Salmon Nigiri",
      "image": "assets/img/m_1.png",
      "time": "Today | 7am",
    },
    {
      "name": "Lowfat Milk",
      "image": "assets/img/m_2.png", 
      "time": "Today | 8am",
    },
  ];

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
          InkWell(
            onTap: () {},
            child: Container(
              margin: const EdgeInsets.all(8),
              height: 40,
              width: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: TColor.lightGray,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.more_horiz,
                color: TColor.black,
                size: 15,
              ),
            ),
          )
        ],
      ),
      backgroundColor: TColor.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nutrition Chart
            Container(
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
                        maxY: 1700,
                        titlesData: const FlTitlesData(show: false),
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Daily Meal Schedule
            Container(
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
                    child: RoundButton(
                      title: "Check",
                      fontSize: 10,
                      onPressed: () {},
                    ),
                  )
                ],
              ),
            ),
            
            // Meal Categories
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
                  var mObj = mealArr[index] as Map? ?? {};
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                    width: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: TColor.secondaryG),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          _getMealIcon(mObj["name"].toString()),
                          color: TColor.white,
                          size: 30,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          mObj["name"].toString(),
                          style: TextStyle(
                            color: TColor.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          mObj["time"].toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: TColor.white.withOpacity(0.7),
                            fontSize: 8,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            // Today's Meals
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Today Meals",
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
                      style: TextStyle(
                        color: TColor.gray,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: todayMealArr.length,
              itemBuilder: (context, index) {
                var mObj = todayMealArr[index] as Map? ?? {};
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Container(
                          height: 50,
                          width: 50,
                          color: TColor.lightGray,
                          child: Icon(
                            Icons.restaurant,
                            color: TColor.mealPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              mObj["name"].toString(),
                              style: TextStyle(
                                color: TColor.black,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              mObj["time"].toString(),
                              style: TextStyle(
                                color: TColor.gray,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.more_horiz,
                          color: TColor.gray,
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  
  IconData _getMealIcon(String mealName) {
    switch (mealName.toLowerCase()) {
      case 'breakfast':
        return Icons.free_breakfast;
      case 'lunch':
        return Icons.lunch_dining;
      case 'snacks':
        return Icons.cookie;
      case 'dinner':
        return Icons.dinner_dining;
      default:
        return Icons.restaurant;
    }
  }
}