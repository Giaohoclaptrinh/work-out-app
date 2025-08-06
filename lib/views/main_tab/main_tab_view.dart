import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import '../../common/color_extension.dart';
import '../home/home_view.dart';
import '../workout/workout_tracker_view.dart';
import '../meal/meal_planner_view.dart';
import '../sleep/sleep_tracker_view.dart';
import '../profile/profile_view.dart';

class MainTabView extends StatefulWidget {
  const MainTabView({super.key});

  @override
  State<MainTabView> createState() => _MainTabViewState();
}

class _MainTabViewState extends State<MainTabView> {
  int selectTab = 0;
  PageController controller = PageController();

  List<IconData> iconList = [
    Icons.home,
    Icons.fitness_center,
    Icons.restaurant,
    Icons.bedtime,
  ];

  @override
  void initState() {
    super.initState();
    controller = PageController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.white,
      floatingActionButton: InkWell(
        onTap: () {},
        child: Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: TColor.secondaryG),
            borderRadius: BorderRadius.circular(27.5),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 2,
              ),
            ],
          ),
          child: Icon(
            Icons.search,
            color: TColor.white,
            size: 20,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar(
        icons: iconList,
        activeIndex: selectTab,
        height: 90,
        splashSpeedInMilliseconds: 300,
        gapLocation: GapLocation.center,
        activeColor: TColor.primaryColor1,
        inactiveColor: TColor.gray,
        onTap: (index) {
          selectTab = index;
          controller.jumpToPage(index);
          setState(() {});
        },
      ),
      body: PageView(
        controller: controller,
        onPageChanged: (index) {
          selectTab = index;
          setState(() {});
        },
        children: const [
          HomeView(),
          WorkoutTrackerView(),
          MealPlannerView(),
          SleepTrackerView(),
        ],
      ),
    );
  }
}

class ProfileTabView extends StatelessWidget {
  const ProfileTabView({super.key});

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
          "Profile",
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
      body: const ProfileView(),
    );
  }
}