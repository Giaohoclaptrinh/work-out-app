import 'package:flutter/material.dart';
import 'package:simple_animation_progress_bar/simple_animation_progress_bar.dart';
import 'package:workout_app/common/color_extension.dart';

class NutritionRow extends StatelessWidget {
  final Map nObj;
  const NutritionRow({super.key, required this.nObj});

  @override
  Widget build(BuildContext context) {
          final val = double.tryParse(nObj["value"]?.toString() ?? "1") ?? 1;
      final maxVal = double.tryParse(nObj["max_value"]?.toString() ?? "1") ?? 1;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 15),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                nObj["title"]?.toString() ?? "",
                style: TextStyle(
                  color: TColor.black,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              if (nObj["image"] != null)
                Image.asset(
                  nObj["image"]?.toString() ?? "assets/img/c_1.png",
                  width: 15,
                  height: 15,
                ),
              const Spacer(),
              Text(
                "${nObj["value"]?.toString() ?? "0"} ${nObj["unit_name"]?.toString() ?? "g"}",
                style: TextStyle(
                  color: TColor.gray,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SimpleAnimationProgressBar(
            height: 10,
            width: MediaQuery.of(context).size.width - 30,
            backgroundColor: Colors.grey.shade100,
            foregroundColor: Colors.purple, // FIXED typo here
            ratio: val / maxVal,
            direction: Axis.horizontal,
            curve: Curves.fastLinearToSlowEaseIn,
            duration: const Duration(seconds: 3),
            borderRadius: BorderRadius.circular(7.5),
            gradientColor: LinearGradient(
              colors: TColor.primaryG,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ],
      ),
    );
  }
}
