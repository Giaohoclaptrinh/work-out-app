import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';

import '../../common/color_extension.dart';
import '../home/home_view.dart';
import '../workout/workout_tracker_view.dart';
import '../meal/meal_planner_view.dart';
import '../profile/profile_view.dart';

class MainTabView extends StatefulWidget {
  const MainTabView({super.key});

  @override
  State<MainTabView> createState() => _MainTabViewState();
}

class _MainTabViewState extends State<MainTabView> {
  int selectedTabIndex = 0;
  late PageController controller;

  final List<IconData> iconList = [
    Icons.home,
    Icons.fitness_center,
    Icons.restaurant,
    Icons.person,
  ];

  @override
  void initState() {
    super.initState();
    controller = PageController(initialPage: selectedTabIndex);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void onTabSelected(int index) {
    setState(() {
      selectedTabIndex = index;
    });
    controller.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.white,
      floatingActionButton: InkWell(
        onTap: () {
          // Future: implement search or central action here
        },
        child: Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: TColor.secondaryG),
            borderRadius: BorderRadius.circular(27.5),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          child: Icon(Icons.search, color: TColor.white, size: 24),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar(
        icons: iconList,
        activeIndex: selectedTabIndex,
        gapLocation: GapLocation.center,
        activeColor: TColor.primaryColor1,
        inactiveColor: TColor.gray,
        splashSpeedInMilliseconds: 300,
        onTap: onTabSelected,
        backgroundColor: Colors.white,
        height: 70,
      ),
      body: PageView(
        controller: controller,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            selectedTabIndex = index;
          });
        },
        children: const [
          HomeView(),
          WorkoutTrackerView(),
          MealPlannerView(),
          ProfileTabView(),
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
      backgroundColor: TColor.white,
      appBar: AppBar(
        backgroundColor: TColor.white,
        elevation: 0,
        centerTitle: true,
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
          IconButton(
            onPressed: () {
              // Future: Show more options
            },
            icon: Icon(Icons.more_horiz, color: TColor.black),
          ),
        ],
      ),
      body:  ProfileView(),
    );
  }
}
