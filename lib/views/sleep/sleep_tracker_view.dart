import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../common/color_extension.dart';
import '../../common/common_widgets.dart';

class SleepTrackerView extends StatefulWidget {
  const SleepTrackerView({super.key});

  @override
  State<SleepTrackerView> createState() => _SleepTrackerViewState();
}

class _SleepTrackerViewState extends State<SleepTrackerView> {
  List<FlSpot> get sleepSpots => const [
    FlSpot(0, 7.5),
    FlSpot(1, 8.2),
    FlSpot(2, 6.8),
    FlSpot(3, 7.9),
    FlSpot(4, 8.5),
    FlSpot(5, 7.2),
    FlSpot(6, 8.0),
  ];

  List sleepArr = [
    {
      "name": "Bedtime",
      "image": "assets/img/bed.png",
      "time": "09:00pm",
      "duration": "in 6hours 22minutes"
    },
    {
      "name": "Alarm",
      "image": "assets/img/alaarm.png", 
      "time": "05:10am",
      "duration": "in 14hours 30minutes"
    },
  ];

  List todaySleepArr = [
    {
      "name": "Sleep",
      "image": "assets/img/sleep_1.png",
      "time": "Last night 02:30am",
      "duration": "8h 20m"
    },
    {
      "name": "Deep Sleep",
      "image": "assets/img/sleep_2.png", 
      "time": "Last night 03:30am",
      "duration": "2h 30m"
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
          "Sleep Tracker",
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
            // Sleep Chart
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              padding: const EdgeInsets.all(15),
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  TColor.sleepPrimary,
                  TColor.sleepSecondary,
                ]),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Sleep Quality",
                    style: TextStyle(
                      color: TColor.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Average 8h 20m per night",
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
                            spots: sleepSpots,
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
                        minY: 6,
                        maxY: 9,
                        titlesData: const FlTitlesData(show: false),
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Sleep Schedule
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              decoration: BoxDecoration(
                color: TColor.sleepPrimary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Sleep Schedule",
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
            
            // Sleep Stats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: TColor.lightGray,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.bedtime,
                            color: TColor.sleepPrimary,
                            size: 30,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "8h 20m",
                            style: TextStyle(
                              color: TColor.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            "Sleep Duration",
                            style: TextStyle(
                              color: TColor.gray,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: TColor.lightGray,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.nights_stay,
                            color: TColor.sleepSecondary,
                            size: 30,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "2h 30m",
                            style: TextStyle(
                              color: TColor.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            "Deep Sleep",
                            style: TextStyle(
                              color: TColor.gray,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Sleep Schedule List
            ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: sleepArr.length,
              itemBuilder: (context, index) {
                var sObj = sleepArr[index] as Map? ?? {};
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
                          color: TColor.sleepPrimary.withOpacity(0.3),
                          child: Icon(
                            index == 0 ? Icons.bedtime : Icons.alarm,
                            color: TColor.sleepPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sObj["name"].toString(),
                              style: TextStyle(
                                color: TColor.black,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              "${sObj["time"]} | ${sObj["duration"]}",
                              style: TextStyle(
                                color: TColor.gray,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: true,
                        onChanged: (value) {},
                        activeColor: TColor.sleepPrimary,
                      ),
                    ],
                  ),
                );
              },
            ),
            
            // Last Night Sleep
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Last Night Sleep",
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
              itemCount: todaySleepArr.length,
              itemBuilder: (context, index) {
                var sObj = todaySleepArr[index] as Map? ?? {};
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
                            index == 0 ? Icons.bedtime : Icons.nights_stay,
                            color: TColor.sleepPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sObj["name"].toString(),
                              style: TextStyle(
                                color: TColor.black,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              "${sObj["time"]} | ${sObj["duration"]}",
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
}