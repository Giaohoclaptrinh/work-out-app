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
  List<int> showingTooltipOnSpots = [5];

  List<FlSpot> get allSpots => const [
    FlSpot(0, 20),
    FlSpot(1, 25),
    FlSpot(2, 40),
    FlSpot(3, 30),
    FlSpot(4, 25),
    FlSpot(5, 35),
    FlSpot(6, 40),
    FlSpot(7, 30),
    FlSpot(8, 24),
    FlSpot(9, 40),
    FlSpot(10, 35),
    FlSpot(11, 40),
  ];

  Widget bottomTitleWidgets(double value, TitleMeta meta, double chartWidth) {
    if (value % 1 != 0) {
      return Container();
    }
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.grey,
      fontFamily: 'Digital',
      fontSize: 18,
    );
    String text;
    switch (value.toInt()) {
      case 0:
        text = 'Jan';
        break;
      case 1:
        text = 'Feb';
        break;
      case 2:
        text = 'Mar';
        break;
      case 3:
        text = 'Apr';
        break;
      case 4:
        text = 'May';
        break;
      case 5:
        text = 'Jun';
        break;
      case 6:
        text = 'Jul';
        break;
      case 7:
        text = 'Aug';
        break;
      case 8:
        text = 'Sep';
        break;
      case 9:
        text = 'Oct';
        break;
      case 10:
        text = 'Nov';
        break;
      case 11:
        text = 'Dec';
        break;
      default:
        return Container();
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(text, style: style),
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
                          "Stefani Wong",
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
                        size: 25,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: media.width * 0.05),

                // BMI Card
                Container(
                  height: media.width * 0.4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: TColor.primaryG),
                    borderRadius: BorderRadius.circular(media.width * 0.075),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        "assets/img/bg_dots.png",
                        height: media.width * 0.4,
                        width: double.maxFinite,
                        fit: BoxFit.fitHeight,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 25,
                          horizontal: 25,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "BMI (Body Mass Index)",
                                  style: TextStyle(
                                    color: TColor.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  "You have a normal weight",
                                  style: TextStyle(
                                    color: TColor.white.withOpacity(0.7),
                                    fontSize: 12,
                                  ),
                                ),
                                SizedBox(height: media.width * 0.05),
                                SizedBox(
                                  width: 120,
                                  height: 35,
                                  child: RoundButton(
                                    title: "View More",
                                    backgroundColor: TColor.white,
                                    textColor: TColor.primaryColor1,
                                    onPressed: () {},
                                  ),
                                ),
                              ],
                            ),
                            AspectRatio(
                              aspectRatio: 1,
                              child: PieChart(
                                PieChartData(
                                  pieTouchData: PieTouchData(
                                    touchCallback:
                                        (
                                          FlTouchEvent event,
                                          pieTouchResponse,
                                        ) {},
                                  ),
                                  startDegreeOffset: 250,
                                  borderData: FlBorderData(show: false),
                                  sectionsSpace: 1,
                                  centerSpaceRadius: 0,
                                  sections: showingSections(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: media.width * 0.05),

                // Today Target
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

                // Activity Status
                Text(
                  "Activity Status",
                  style: TextStyle(
                    color: TColor.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                SizedBox(height: media.width * 0.02),

                // Line Chart
                Container(
                  height: 200,
                  padding: const EdgeInsets.only(left: 15),
                  child: LineChart(
                    LineChartData(
                      showingTooltipIndicators: showingTooltipOnSpots
                          .where(
                            (index) => index >= 0 && index < allSpots.length,
                          )
                          .map((index) {
                            return ShowingTooltipIndicators([
                              LineBarSpot(
                                LineChartBarData(
                                  spots: allSpots,
                                  isCurved: true,
                                  gradient: LinearGradient(
                                    colors: TColor.primaryG,
                                  ),
                                  barWidth: 4,
                                  isStrokeCapRound: true,
                                  belowBarData: BarAreaData(
                                    show: true,
                                    gradient: LinearGradient(
                                      colors: TColor.primaryG
                                          .map(
                                            (color) => color.withOpacity(0.3),
                                          )
                                          .toList(),
                                    ),
                                  ),
                                ),
                                0,
                                allSpots[index],
                              ),
                            ]);
                          })
                          .toList(),
                      lineTouchData: LineTouchData(
                        enabled: true,
                        handleBuiltInTouches: false,
                        touchCallback:
                            (FlTouchEvent event, LineTouchResponse? response) {
                              if (response == null ||
                                  response.lineBarSpots == null) {
                                return;
                              }
                              if (event is FlTapUpEvent) {
                                final spotIndex =
                                    response.lineBarSpots!.first.spotIndex;
                                if (spotIndex >= 0 &&
                                    spotIndex < allSpots.length) {
                                  showingTooltipOnSpots.clear();
                                  showingTooltipOnSpots.add(spotIndex);
                                  setState(() {});
                                }
                              }
                            },
                        mouseCursorResolver:
                            (FlTouchEvent event, LineTouchResponse? response) {
                              if (response == null ||
                                  response.lineBarSpots == null) {
                                return SystemMouseCursors.basic;
                              }
                              return SystemMouseCursors.click;
                            },
                        getTouchedSpotIndicator:
                            (LineChartBarData barData, List<int> spotIndexes) {
                              return spotIndexes.map((index) {
                                return TouchedSpotIndicatorData(
                                  FlLine(color: Colors.grey, strokeWidth: 1),
                                  FlDotData(
                                    show: true,
                                    getDotPainter:
                                        (spot, percent, barData, index) =>
                                            FlDotCirclePainter(
                                              radius: 3,
                                              color: Colors.white,
                                              strokeWidth: 3,
                                              strokeColor:
                                                  TColor.secondaryColor1,
                                            ),
                                  ),
                                );
                              }).toList();
                            },
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipColor: (touchedSpot) =>
                              TColor.secondaryColor1,
                          tooltipRoundedRadius: 20,
                          getTooltipItems: (List<LineBarSpot> lineBarsSpot) {
                            return lineBarsSpot.map((lineBarSpot) {
                              return LineTooltipItem(
                                "${lineBarSpot.y.toInt()} mins ago",
                                const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }).toList();
                          },
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: allSpots,
                          isCurved: true,
                          gradient: LinearGradient(colors: TColor.primaryG),
                          barWidth: 4,
                          isStrokeCapRound: true,
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: TColor.primaryG
                                  .map((color) => color.withOpacity(0.3))
                                  .toList(),
                            ),
                          ),
                        ),
                      ],
                      minY: 0,
                      maxY: 50,
                      titlesData: FlTitlesData(
                        show: true,
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 32,
                            interval: 1,
                            getTitlesWidget: (value, meta) =>
                                bottomTitleWidgets(value, meta, 0),
                          ),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 25,
                        checkToShowHorizontalLine: (double value) {
                          return value == 25;
                        },
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(color: Colors.transparent),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: media.width * 0.05),

                // Latest Workout
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

                ListView.builder(
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    var workoutData = [
                      {
                        "name": "Fullbody Workout",
                        "image": "assets/img/Workout1.png",
                        "kcal": "180",
                        "time": "20",
                        "progress": 0.3,
                      },
                      {
                        "name": "Lowerbody Workout",
                        "image": "assets/img/Workout2.png",
                        "kcal": "200",
                        "time": "30",
                        "progress": 0.4,
                      },
                      {
                        "name": "Ab Workout",
                        "image": "assets/img/Workout3.png",
                        "kcal": "300",
                        "time": "40",
                        "progress": 0.7,
                      },
                    ];

                    var wObj = workoutData[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: TColor.lightGray,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              height: 50,
                              width: 50,
                              color: TColor.primaryColor2.withOpacity(0.3),
                              child: Icon(
                                Icons.fitness_center,
                                color: TColor.primaryColor1,
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  wObj["name"].toString(),
                                  style: TextStyle(
                                    color: TColor.black,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  "${wObj["kcal"]} kCal | ${wObj["time"]} minutes",
                                  style: TextStyle(
                                    color: TColor.gray,
                                    fontSize: 10,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                LinearPercentIndicator(
                                  width: media.width - 140,
                                  lineHeight: 4.0,
                                  percent:
                                      double.tryParse(
                                        wObj["progress"].toString(),
                                      ) ??
                                      0.0,
                                  progressColor: TColor.primaryColor1,
                                  backgroundColor: TColor.lightGray,
                                  barRadius: const Radius.circular(2),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.more_horiz, color: TColor.gray),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                SizedBox(height: media.width * 0.1),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(2, (i) {
      var color0 = TColor.secondaryColor1;
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: color0,
            value: 33,
            title: '',
            radius: 55,
            titlePositionPercentageOffset: 0.55,
            badgeWidget: Text(
              "20.1",
              style: TextStyle(
                color: TColor.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          );
        case 1:
          return PieChartSectionData(
            color: Colors.white,
            value: 75,
            title: '',
            radius: 45,
            titlePositionPercentageOffset: 0.55,
          );
        default:
          throw Error();
      }
    });
  }
}
