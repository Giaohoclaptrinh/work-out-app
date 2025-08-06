import 'package:flutter/material.dart';

class TColor {
  static Color get primaryColor1 => const Color(0xff92A3FD);
  static Color get primaryColor2 => const Color(0xff9DCEFF);

  static Color get secondaryColor1 => const Color(0xffC58BF2);
  static Color get secondaryColor2 => const Color(0xffEEA4CE);

  static List<Color> get primaryG => [primaryColor2, primaryColor1];
  static List<Color> get secondaryG => [secondaryColor2, secondaryColor1];

  static Color get black => const Color(0xff1D1617);
  static Color get gray => const Color(0xff786F72);
  static Color get white => Colors.white;
  static Color get lightGray => const Color(0xffF7F8F8);
  static Color get midGray => const Color(0xffAAA4B2);
  static Color get darkGray => const Color(0xff7B6F72);

  // Workout specific colors
  static Color get workoutPrimary => const Color(0xffFF6B6B);
  static Color get workoutSecondary => const Color(0xffFFE66D);
  
  // Meal specific colors
  static Color get mealPrimary => const Color(0xff4ECDC4);
  static Color get mealSecondary => const Color(0xff44A08D);
  
  // Sleep specific colors
  static Color get sleepPrimary => const Color(0xff667eea);
  static Color get sleepSecondary => const Color(0xff764ba2);
}