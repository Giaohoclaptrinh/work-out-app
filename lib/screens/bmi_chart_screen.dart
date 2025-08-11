import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../common/color_extension.dart';
import '../widgets/round_button.dart';

class BMIChartScreen extends StatefulWidget {
  const BMIChartScreen({super.key});

  @override
  State<BMIChartScreen> createState() => _BMIChartScreenState();
}

class _BMIChartScreenState extends State<BMIChartScreen> {
  int touchedIndex = -1;
  double? userBMI;
  double? userWeight;
  double? userHeight;
  bool isLoading = true;

  // Sample BMI history data (could be from database)
  final List<BMIHistoryPoint> bmiHistory = [
    BMIHistoryPoint(DateTime(2024, 1, 1), 24.2),
    BMIHistoryPoint(DateTime(2024, 2, 1), 23.8),
    BMIHistoryPoint(DateTime(2024, 3, 1), 23.5),
    BMIHistoryPoint(DateTime(2024, 4, 1), 23.2),
    BMIHistoryPoint(DateTime(2024, 5, 1), 22.9),
    BMIHistoryPoint(DateTime(2024, 6, 1), 22.6),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (doc.exists && mounted) {
        final data = doc.data()!;
        setState(() {
          userWeight = data['weight']?.toDouble() ?? 70.0;
          userHeight = data['height']?.toDouble() ?? 175.0;
          _calculateCurrentBMI();
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        userWeight = 70.0; // Default values
        userHeight = 175.0;
        _calculateCurrentBMI();
        isLoading = false;
      });
    }
  }

  void _calculateCurrentBMI() {
    if (userHeight != null && userHeight! > 0 && userWeight != null) {
      final heightInMeters = userHeight! / 100;
      userBMI = userWeight! / (heightInMeters * heightInMeters);
    }
  }

  String _getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi >= 18.5 && bmi < 25) return 'Normal';
    if (bmi >= 25 && bmi < 30) return 'Overweight';
    return 'Obese';
  }

  Color _getBMIColor(double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi >= 18.5 && bmi < 25) return Colors.green;
    if (bmi >= 25 && bmi < 30) return Colors.orange;
    return Colors.red;
  }

  List<PieChartSectionData> _getBMIDistributionData() {
    return [
      PieChartSectionData(
        color: Colors.blue,
        value: 18.5,
        title: 'Underweight\n< 18.5',
        radius: touchedIndex == 0 ? 110 : 100,
        titleStyle: TextStyle(
          fontSize: touchedIndex == 0 ? 14 : 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: Colors.green,
        value: 6.5, // 25 - 18.5
        title: 'Normal\n18.5-25',
        radius: touchedIndex == 1 ? 110 : 100,
        titleStyle: TextStyle(
          fontSize: touchedIndex == 1 ? 14 : 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: Colors.orange,
        value: 5, // 30 - 25
        title: 'Overweight\n25-30',
        radius: touchedIndex == 2 ? 110 : 100,
        titleStyle: TextStyle(
          fontSize: touchedIndex == 2 ? 14 : 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: Colors.red,
        value: 10, // 40 - 30 (extended range)
        title: 'Obese\n> 30',
        radius: touchedIndex == 3 ? 110 : 100,
        titleStyle: TextStyle(
          fontSize: touchedIndex == 3 ? 14 : 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.white,
      appBar: AppBar(
        backgroundColor: TColor.white,
        centerTitle: true,
        elevation: 0,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            height: 40,
            width: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: TColor.lightGray,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Image.asset(
              "assets/img/ArrowLeft.png",
              width: 15,
              height: 15,
              fit: BoxFit.contain,
            ),
          ),
        ),
        title: Text(
          "BMI Analysis",
          style: TextStyle(
            color: TColor.black,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          InkWell(
            onTap: () {
              // TODO: Open BMI calculator
            },
            child: Container(
              margin: const EdgeInsets.all(8),
              height: 40,
              width: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: TColor.lightGray,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.calculate, color: TColor.black, size: 20),
            ),
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(color: TColor.primaryColor1),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 15),

                    // Current BMI Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: userBMI != null
                              ? [
                                  _getBMIColor(userBMI!),
                                  _getBMIColor(userBMI!).withOpacity(0.7),
                                ]
                              : TColor.primaryG,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        children: [
                          Text(
                            "Your Current BMI",
                            style: TextStyle(
                              color: TColor.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            userBMI?.toStringAsFixed(1) ?? "0.0",
                            style: TextStyle(
                              color: TColor.white,
                              fontSize: 48,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            userBMI != null
                                ? _getBMICategory(userBMI!)
                                : "Calculate BMI",
                            style: TextStyle(
                              color: TColor.white.withOpacity(0.9),
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildBMIDetail(
                                "Weight",
                                "${userWeight?.toStringAsFixed(1) ?? '0.0'} kg",
                              ),
                              Container(
                                width: 1,
                                height: 30,
                                color: TColor.white.withOpacity(0.3),
                              ),
                              _buildBMIDetail(
                                "Height",
                                "${userHeight?.toStringAsFixed(0) ?? '0'} cm",
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    // BMI Categories Chart
                    Text(
                      "BMI Categories",
                      style: TextStyle(
                        color: TColor.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 15),

                    Container(
                      height: 250,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: TColor.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 5,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: PieChart(
                        PieChartData(
                          pieTouchData: PieTouchData(
                            touchCallback:
                                (FlTouchEvent event, pieTouchResponse) {
                                  setState(() {
                                    if (!event.isInterestedForInteractions ||
                                        pieTouchResponse == null ||
                                        pieTouchResponse.touchedSection ==
                                            null) {
                                      touchedIndex = -1;
                                      return;
                                    }
                                    touchedIndex = pieTouchResponse
                                        .touchedSection!
                                        .touchedSectionIndex;
                                  });
                                },
                          ),
                          borderData: FlBorderData(show: false),
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                          sections: _getBMIDistributionData(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // BMI Progress Chart
                    Text(
                      "BMI Progress",
                      style: TextStyle(
                        color: TColor.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 15),

                    Container(
                      height: 200,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: TColor.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 5,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: 1,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: TColor.lightGray,
                                strokeWidth: 1,
                              );
                            },
                          ),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 35,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    value.toInt().toString(),
                                    style: TextStyle(
                                      color: TColor.gray,
                                      fontSize: 12,
                                    ),
                                  );
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                getTitlesWidget: (value, meta) {
                                  final months = [
                                    'Jan',
                                    'Feb',
                                    'Mar',
                                    'Apr',
                                    'May',
                                    'Jun',
                                  ];
                                  final index = value.toInt();
                                  if (index >= 0 && index < months.length) {
                                    return Text(
                                      months[index],
                                      style: TextStyle(
                                        color: TColor.gray,
                                        fontSize: 12,
                                      ),
                                    );
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          minX: 0,
                          maxX: 5,
                          minY: 20,
                          maxY: 26,
                          lineBarsData: [
                            LineChartBarData(
                              spots: bmiHistory.asMap().entries.map((entry) {
                                return FlSpot(
                                  entry.key.toDouble(),
                                  entry.value.bmi,
                                );
                              }).toList(),
                              isCurved: true,
                              gradient: LinearGradient(colors: TColor.primaryG),
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, barData, index) {
                                  return FlDotCirclePainter(
                                    radius: 4,
                                    color: TColor.primaryColor1,
                                    strokeWidth: 2,
                                    strokeColor: TColor.white,
                                  );
                                },
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  colors: TColor.primaryG
                                      .map((color) => color.withOpacity(0.1))
                                      .toList(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // BMI Tips
                    Text(
                      "Health Tips",
                      style: TextStyle(
                        color: TColor.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 15),

                    ...(_getBMITips()).map((tip) => _buildTipCard(tip)),

                    const SizedBox(height: 25),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: RoundButton(
                            title: "Update BMI",
                            onPressed: () {
                              // TODO: Navigate to BMI input screen
                            },
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: RoundButton(
                            title: "Set Goal",
                            type: RoundButtonType.bgGradient,
                            onPressed: () {
                              // TODO: Navigate to goal setting
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBMIDetail(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: TColor.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: TColor.white.withOpacity(0.7), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildTipCard(BMITip tip) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: tip.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tip.color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: tip.color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(tip.icon, color: TColor.white, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tip.title,
                  style: TextStyle(
                    color: TColor.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tip.description,
                  style: TextStyle(color: TColor.gray, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<BMITip> _getBMITips() {
    if (userBMI == null) return [];

    if (userBMI! < 18.5) {
      return [
        BMITip(
          icon: Icons.restaurant,
          title: "Increase Caloric Intake",
          description: "Focus on nutrient-dense, high-calorie foods",
          color: Colors.blue,
        ),
        BMITip(
          icon: Icons.fitness_center,
          title: "Strength Training",
          description: "Build muscle mass with resistance exercises",
          color: Colors.green,
        ),
      ];
    } else if (userBMI! >= 18.5 && userBMI! < 25) {
      return [
        BMITip(
          icon: Icons.favorite,
          title: "Maintain Your Weight",
          description: "Great job! Keep up your healthy lifestyle",
          color: Colors.green,
        ),
        BMITip(
          icon: Icons.directions_run,
          title: "Stay Active",
          description: "Continue regular exercise for optimal health",
          color: Colors.blue,
        ),
      ];
    } else if (userBMI! >= 25 && userBMI! < 30) {
      return [
        BMITip(
          icon: Icons.scale,
          title: "Gradual Weight Loss",
          description: "Aim for 1-2 pounds per week weight loss",
          color: Colors.orange,
        ),
        BMITip(
          icon: Icons.local_dining,
          title: "Balanced Diet",
          description: "Focus on portion control and nutritious foods",
          color: Colors.green,
        ),
      ];
    } else {
      return [
        BMITip(
          icon: Icons.medical_services,
          title: "Consult Healthcare Provider",
          description: "Consider professional guidance for weight management",
          color: Colors.red,
        ),
        BMITip(
          icon: Icons.trending_down,
          title: "Structured Weight Loss",
          description: "Combine diet modifications with regular exercise",
          color: Colors.purple,
        ),
      ];
    }
  }
}

class BMIHistoryPoint {
  final DateTime date;
  final double bmi;

  BMIHistoryPoint(this.date, this.bmi);
}

class BMITip {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  BMITip({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
