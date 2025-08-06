import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../common/color_extension.dart';
import '../../common/common_widgets.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  List<int> showingTooltipOnSpots = [];

  List<FlSpot> allSpots = []; // Will be populated from real data

  Widget bottomTitleWidgets(double value, TitleMeta meta, double chartWidth) {
    if (value % 1 != 0) return Container();
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.grey,
      fontFamily: 'Digital',
      fontSize: 18,
    );

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    if (value.toInt() < 0 || value.toInt() >= months.length) return Container();

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(months[value.toInt()], style: style),
    );
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: TColor.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome Back,",
                          style: TextStyle(color: TColor.gray, fontSize: 12),
                        ),
                        Text(
                          "User", // Use real user name
                          style: TextStyle(
                            color: TColor.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.notifications_outlined,
                        color: TColor.black,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: media.width * 0.05),

                // BMI Card Placeholder
                Container(
                  height: media.width * 0.4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: TColor.primaryG),
                    borderRadius: BorderRadius.circular(media.width * 0.075),
                  ),
                  child: Center(
                    child: Text(
                      "BMI Data will appear here",
                      style: TextStyle(color: TColor.white, fontSize: 16),
                    ),
                  ),
                ),

                SizedBox(height: media.width * 0.05),

                // Today Target Placeholder
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 15,
                  ),
                  decoration: BoxDecoration(
                    color: TColor.primaryColor2.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Today Target",
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
                      ),
                    ],
                  ),
                ),

                SizedBox(height: media.width * 0.05),

                // Activity Status (Chart)
                Text(
                  "Activity Status",
                  style: TextStyle(
                    color: TColor.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  height: 200,
                  padding: const EdgeInsets.only(left: 15),
                  child: allSpots.isEmpty
                      ? Center(child: Text("No activity data"))
                      : LineChart(
                          LineChartData(
                            showingTooltipIndicators: showingTooltipOnSpots.map(
                              (index) {
                                return ShowingTooltipIndicators([
                                  LineBarSpot(
                                    LineChartBarData(spots: allSpots),
                                    0,
                                    allSpots[index],
                                  ),
                                ]);
                              },
                            ).toList(),
                            lineTouchData: LineTouchData(enabled: true),
                            lineBarsData: [
                              LineChartBarData(
                                spots: allSpots,
                                isCurved: true,
                                gradient: LinearGradient(
                                  colors: TColor.primaryG,
                                ),
                                barWidth: 4,
                                belowBarData: BarAreaData(
                                  show: true,
                                  gradient: LinearGradient(
                                    colors: TColor.primaryG
                                        .map((e) => e.withOpacity(0.3))
                                        .toList(),
                                  ),
                                ),
                              ),
                            ],
                            minY: 0,
                            maxY: 100,
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 32,
                                  interval: 1,
                                  getTitlesWidget: (value, meta) =>
                                      bottomTitleWidgets(value, meta, 0),
                                ),
                              ),
                            ),
                            gridData: FlGridData(show: false),
                            borderData: FlBorderData(show: false),
                          ),
                        ),
                ),

                SizedBox(height: media.width * 0.05),

                // Latest Workout List Placeholder
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Latest Workout",
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
                const SizedBox(height: 10),
                Center(child: Text("No workouts yet")),

                SizedBox(height: media.width * 0.1),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return []; // Empty until actual BMI data is provided
  }
}
