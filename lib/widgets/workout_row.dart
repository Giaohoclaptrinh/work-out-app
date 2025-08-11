import 'package:workout_app/common/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:simple_animation_progress_bar/simple_animation_progress_bar.dart';

class WorkoutRow extends StatelessWidget {
  final Map wObj;
  final VoidCallback? onPressed;
  final bool showStartButton;

  const WorkoutRow({
    super.key,
    required this.wObj,
    this.onPressed,
    this.showStartButton = true,
  });

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      decoration: BoxDecoration(
        color: TColor.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: wObj["image"]?.toString().startsWith('http') == true
                ? Image.network(
                    wObj["image"]?.toString() ?? "assets/img/Workout1.png",
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        "assets/img/Workout1.png",
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      );
                    },
                  )
                : Image.asset(
                    wObj["image"]?.toString() ?? "assets/img/Workout1.png",
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
          ),

          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  wObj["name"]?.toString() ?? "Workout",
                  style: TextStyle(color: TColor.black, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                Text(
                  "${wObj["kcal"]?.toString() ?? "0"} Calories Burn | ${wObj["time"]?.toString() ?? "0"} minutes",
                  style: TextStyle(color: TColor.gray, fontSize: 10),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 4),

                LayoutBuilder(
                  builder: (context, constraints) {
                    return SimpleAnimationProgressBar(
                      height: 15,
                      width: constraints.maxWidth > 0
                          ? constraints.maxWidth
                          : media.width * 0.4,
                      backgroundColor: Colors.grey.shade100,
                      foregroundColor: Colors.purple,
                      ratio: wObj["progress"] as double? ?? 0.0,
                      direction: Axis.horizontal,
                      curve: Curves.fastLinearToSlowEaseIn,
                      duration: const Duration(seconds: 3),
                      borderRadius: BorderRadius.circular(7.5),
                      gradientColor: LinearGradient(
                        colors: TColor.primaryG,
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Button section
          if (showStartButton) ...[
            // Start button with Play icon
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: TColor.primaryG),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: TColor.primaryColor1.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap:
                      onPressed ??
                      () {
                        // Default action - navigate to workout detail
                        if (wObj["id"] != null) {
                          // You can add navigation logic here
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Starting ${wObj["name"]} workout...',
                              ),
                              backgroundColor: TColor.primaryColor1,
                            ),
                          );
                        }
                      },
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          "assets/img/Play.png",
                          width: 20,
                          height: 20,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "Start",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ] else ...[
            // Simple arrow button for navigation
            IconButton(
              onPressed:
                  onPressed ??
                  () {
                    // Default navigation action
                    if (wObj["id"] != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Viewing ${wObj["name"]} details...'),
                          backgroundColor: TColor.primaryColor1,
                        ),
                      );
                    }
                  },
              icon: Image.asset(
                "assets/img/next_icon.png",
                width: 30,
                height: 30,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
