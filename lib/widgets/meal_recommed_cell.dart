import 'package:workout_app/widgets/round_button.dart';
import 'package:flutter/material.dart';

import 'package:workout_app/common/color_extension.dart';

class MealRecommendCell extends StatelessWidget {
  final Map fObj;
  final int index;
  const MealRecommendCell({super.key, required this.index, required this.fObj});

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    bool isEvent = index % 2 == 0;
    return Container(
      margin: const EdgeInsets.all(5),
      width: media.width * 0.5,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isEvent
              ? [
                  TColor.primaryColor2.withOpacity(0.5),
                  TColor.primaryColor1.withOpacity(0.5),
                ]
              : [
                  TColor.secondaryColor2.withOpacity(0.5),
                  TColor.secondaryColor1.withOpacity(0.5),
                ],
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            fObj["image"]?.toString() ?? "assets/img/f_1.png",
            width: media.width * 0.3,
            height: media.width * 0.25,
            fit: BoxFit.contain,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Text(
              fObj["name"],
              style: TextStyle(
                color: TColor.black,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Text(
              "${fObj["size"]?.toString() ?? "Medium"} | ${fObj["time"]?.toString() ?? "30 min"} | ${fObj["kcal"]?.toString() ?? "250"}",
              style: TextStyle(color: TColor.gray, fontSize: 12),
            ),
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: SizedBox(
              width: 90,
              height: 35,
              child: RoundButton(
                fontSize: 12,
                type: isEvent
                    ? RoundButtonType.bgGradient
                    : RoundButtonType.bgSGradient,
                title: "View",
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }
}
