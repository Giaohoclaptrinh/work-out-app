import 'package:flutter/material.dart';
import '../common/color_extension.dart';
import '../models/meal.dart';

class MealRow extends StatelessWidget {
  final Meal meal;
  final VoidCallback? onTap;
  final bool showRemoveButton;

  const MealRow({
    super.key,
    required this.meal,
    this.onTap,
    this.showRemoveButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Meal Image
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: AssetImage(meal.image),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Meal Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.name,
                  style: TextStyle(
                    color: TColor.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  meal.description,
                  style: TextStyle(color: TColor.gray, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Calories and Prep Time in a more compact layout
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: TColor.primaryColor1.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.local_fire_department,
                              size: 14,
                              color: TColor.primaryColor1,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                '${meal.calories} cal',
                                style: TextStyle(
                                  color: TColor.primaryColor1,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: TColor.secondaryColor1.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: TColor.secondaryColor1,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                '${meal.prepTime} min',
                                style: TextStyle(
                                  color: TColor.secondaryColor1,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Tags with limited height
                if (meal.tags.isNotEmpty)
                  SizedBox(
                    height: 24,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: meal.tags.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(right: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: TColor.gray.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            meal.tags[index],
                            style: TextStyle(color: TColor.gray, fontSize: 10),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          // Action Button
          if (showRemoveButton)
            Container(
              margin: const EdgeInsets.only(left: 8),
              child: IconButton(
                icon: Icon(
                  Icons.remove_circle_outline,
                  color: Colors.red,
                  size: 24,
                ),
                onPressed: onTap,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
            )
          else if (onTap != null)
            Container(
              margin: const EdgeInsets.only(left: 8),
              child: IconButton(
                icon: Icon(
                  Icons.add_circle_outline,
                  color: TColor.primaryColor1,
                  size: 24,
                ),
                onPressed: onTap,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
            ),
        ],
      ),
    );
  }
}
