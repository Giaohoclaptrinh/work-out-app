import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../common/color_extension.dart';

class SettingsHelper {
  static SettingsProvider getSettingsProvider(BuildContext context) {
    return Provider.of<SettingsProvider>(context, listen: false);
  }

  static bool isDarkMode(BuildContext context) {
    return Provider.of<SettingsProvider>(context, listen: true).isDarkMode;
  }

  static double getFontSize(BuildContext context) {
    return Provider.of<SettingsProvider>(context, listen: true).fontSize;
  }

  static String getLanguage(BuildContext context) {
    return Provider.of<SettingsProvider>(context, listen: true).language;
  }

  static String getUnits(BuildContext context) {
    return Provider.of<SettingsProvider>(context, listen: true).units;
  }

  static String getWorkoutDifficulty(BuildContext context) {
    return Provider.of<SettingsProvider>(
      context,
      listen: true,
    ).workoutDifficulty;
  }

  static bool getPushNotifications(BuildContext context) {
    return Provider.of<SettingsProvider>(
      context,
      listen: true,
    ).pushNotifications;
  }

  static bool getWorkoutReminders(BuildContext context) {
    return Provider.of<SettingsProvider>(
      context,
      listen: true,
    ).workoutReminders;
  }

  static bool getMealReminders(BuildContext context) {
    return Provider.of<SettingsProvider>(context, listen: true).mealReminders;
  }

  static bool getSoundEffects(BuildContext context) {
    return Provider.of<SettingsProvider>(context, listen: true).soundEffects;
  }

  static bool getHapticFeedback(BuildContext context) {
    return Provider.of<SettingsProvider>(context, listen: true).hapticFeedback;
  }

  static bool getAutoSync(BuildContext context) {
    return Provider.of<SettingsProvider>(context, listen: true).autoSync;
  }

  static bool getShowTips(BuildContext context) {
    return Provider.of<SettingsProvider>(context, listen: true).showTips;
  }

  // Helper methods for applying settings
  static Color getBackgroundColor(BuildContext context) =>
      Theme.of(context).scaffoldBackgroundColor;

  static Color getCardColor(BuildContext context) =>
      Theme.of(context).cardColor;

  static Color getTextColor(BuildContext context) {
    return isDarkMode(context) ? Colors.grey[100]! : Colors.black;
  }

  static Color getSecondaryTextColor(BuildContext context) {
    return isDarkMode(context) ? Colors.grey[400]! : Colors.grey[600]!;
  }

  // Additional color helpers for better dark mode experience
  static Color getPrimaryColor(BuildContext context) {
    return isDarkMode(context) ? Colors.purple[300]! : TColor.primaryColor1;
  }

  static Color getAccentColor(BuildContext context) {
    return isDarkMode(context) ? Colors.purple[200]! : TColor.primaryColor2;
  }

  static Color getBorderColor(BuildContext context) {
    return isDarkMode(context) ? Colors.grey[700]! : Colors.grey[300]!;
  }

  static Color getShadowColor(BuildContext context) {
    return isDarkMode(context)
        ? Colors.black.withValues(alpha: 0.3)
        : Colors.black.withValues(alpha: 0.1);
  }

  static TextStyle getTextStyle(
    BuildContext context, {
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
  }) {
    // Use relative font sizes instead of absolute sizes
    // Let MediaQuery handle the scaling
    final relativeSize = fontSize ?? 16.0; // Base size
    return TextStyle(
      fontSize: relativeSize,
      fontWeight: fontWeight ?? FontWeight.normal,
      color: color ?? getTextColor(context),
    );
  }

  static TextStyle getTitleStyle(
    BuildContext context, {
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
  }) {
    // Use relative font sizes instead of absolute sizes
    final relativeSize = fontSize ?? 18.0; // Base title size
    return TextStyle(
      fontSize: relativeSize,
      fontWeight: fontWeight ?? FontWeight.w600,
      color: color ?? getTextColor(context),
    );
  }

  static TextStyle getSubtitleStyle(
    BuildContext context, {
    double? fontSize,
    Color? color,
  }) {
    // Use relative font sizes instead of absolute sizes
    final relativeSize = fontSize ?? 14.0; // Base subtitle size
    return TextStyle(
      fontSize: relativeSize,
      color: color ?? getSecondaryTextColor(context),
    );
  }

  // Apply haptic feedback if enabled
  static void applyHapticFeedback(BuildContext context) {
    if (getHapticFeedback(context)) {
      HapticFeedback.lightImpact();
    }
  }

  // Apply sound effects if enabled
  static void applySoundEffect(BuildContext context) {
    if (getSoundEffects(context)) {
      // Add sound effect logic here
      // For now, just a placeholder
    }
  }

  // Get localized text based on language setting
  static String getLocalizedText(
    BuildContext context,
    Map<String, String> translations,
  ) {
    final language = getLanguage(context);
    return translations[language] ??
        translations['Tiếng Việt'] ??
        translations.values.first;
  }

  // Convert units based on setting
  static String formatWeight(BuildContext context, double weightKg) {
    final units = getUnits(context);
    if (units == 'Imperial') {
      final lbs = weightKg * 2.20462;
      return '${lbs.toStringAsFixed(1)} lbs';
    }
    return '${weightKg.toStringAsFixed(1)} kg';
  }

  static String formatHeight(BuildContext context, double heightCm) {
    final units = getUnits(context);
    if (units == 'Imperial') {
      final feet = heightCm / 30.48;
      final inches = (feet - feet.floor()) * 12;
      return '${feet.floor()}\' ${inches.toStringAsFixed(1)}"';
    }
    return '${heightCm.toStringAsFixed(1)} cm';
  }

  static String formatDistance(BuildContext context, double distanceKm) {
    final units = getUnits(context);
    if (units == 'Imperial') {
      final miles = distanceKm * 0.621371;
      return '${miles.toStringAsFixed(1)} mi';
    }
    return '${distanceKm.toStringAsFixed(1)} km';
  }

  // Helper method to force text scaling in specific areas
  static Widget withTextScaling(
    BuildContext context,
    Widget child, {
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
  }) {
    return DefaultTextStyle.merge(
      style: getTextStyle(
        context,
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      ),
      child: child,
    );
  }

  // Helper method for title text with forced scaling
  static Widget withTitleScaling(
    BuildContext context,
    Widget child, {
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
  }) {
    return DefaultTextStyle.merge(
      style: getTitleStyle(
        context,
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      ),
      child: child,
    );
  }

  // Helper method for subtitle text with forced scaling
  static Widget withSubtitleScaling(
    BuildContext context,
    Widget child, {
    double? fontSize,
    Color? color,
  }) {
    return DefaultTextStyle.merge(
      style: getSubtitleStyle(context, fontSize: fontSize, color: color),
      child: child,
    );
  }

  // Helper methods for overflow handling
  static TextStyle getTextStyleWithOverflow(
    BuildContext context, {
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    int maxLines = 1,
  }) {
    return getTextStyle(
      context,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    ).copyWith(overflow: TextOverflow.ellipsis);
  }

  static TextStyle getTitleStyleWithOverflow(
    BuildContext context, {
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    int maxLines = 1,
  }) {
    return getTitleStyle(
      context,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    ).copyWith(overflow: TextOverflow.ellipsis);
  }

  static TextStyle getSubtitleStyleWithOverflow(
    BuildContext context, {
    double? fontSize,
    Color? color,
    int maxLines = 1,
  }) {
    return getSubtitleStyle(
      context,
      fontSize: fontSize,
      color: color,
    ).copyWith(overflow: TextOverflow.ellipsis);
  }

  // Helper method to create responsive text widget
  static Widget createResponsiveText(
    BuildContext context,
    String text, {
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    int maxLines = 1,
    TextAlign textAlign = TextAlign.start,
  }) {
    return Text(
      text,
      style: getTextStyle(
        context,
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      ),
      overflow: TextOverflow.ellipsis,
      maxLines: maxLines,
      textAlign: textAlign,
    );
  }

  // Helper method to create responsive container with flexible height
  static Widget createResponsiveContainer(
    BuildContext context, {
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    BoxDecoration? decoration,
    double? width,
    double? minHeight,
    double? maxHeight,
    AlignmentGeometry? alignment,
  }) {
    return Container(
      width: width,
      constraints: BoxConstraints(
        minHeight: minHeight ?? 0,
        maxHeight: maxHeight ?? double.infinity,
      ),
      padding: padding,
      margin: margin,
      decoration: decoration,
      alignment: alignment,
      child: child,
    );
  }

  // Helper method to create flexible column that avoids overflow
  static Widget createFlexibleColumn({
    required List<Widget> children,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
    MainAxisSize mainAxisSize = MainAxisSize.min,
  }) {
    return Column(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: children,
    );
  }

  // Helper method to create safe text widget with automatic overflow handling
  static Widget createSafeText(
    String text, {
    TextStyle? style,
    int maxLines = 1,
    TextAlign textAlign = TextAlign.start,
    TextOverflow overflow = TextOverflow.ellipsis,
  }) {
    return Text(
      text,
      style: style,
      maxLines: maxLines,
      textAlign: textAlign,
      overflow: overflow,
    );
  }

  // Helper method to create safe row with flexible children
  static Widget createSafeRow({
    required List<Widget> children,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    MainAxisSize mainAxisSize = MainAxisSize.max,
  }) {
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: children,
    );
  }

  // Helper method to wrap text in Expanded to prevent overflow
  static Widget createExpandedText(
    String text, {
    TextStyle? style,
    int maxLines = 1,
    TextAlign textAlign = TextAlign.start,
    TextOverflow overflow = TextOverflow.ellipsis,
  }) {
    return Expanded(
      child: Text(
        text,
        style: style,
        maxLines: maxLines,
        textAlign: textAlign,
        overflow: overflow,
      ),
    );
  }

  // Helper method to create responsive grid layout
  static Widget createResponsiveGrid({
    required List<Widget> children,
    required int crossAxisCount,
    double crossAxisSpacing = 15,
    double mainAxisSpacing = 15,
    double defaultChildAspectRatio = 1.4,
    EdgeInsetsGeometry? padding,
    BuildContext? context,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive childAspectRatio based on screen width and font size
        double childAspectRatio = defaultChildAspectRatio;

        // Adjust based on screen width
        if (constraints.maxWidth > 400) {
          childAspectRatio = 1.6; // Wider screens get more horizontal space
        } else if (constraints.maxWidth < 300) {
          childAspectRatio = 1.2; // Narrow screens get less horizontal space
        }

        // Adjust based on font size if context is provided
        if (context != null) {
          final fontSize = getFontSize(context);
          if (fontSize > 18) {
            childAspectRatio *= 1.2; // Larger font needs more height
          } else if (fontSize < 14) {
            childAspectRatio *= 0.9; // Smaller font can use less height
          }
        }

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: crossAxisSpacing,
          mainAxisSpacing: mainAxisSpacing,
          childAspectRatio: childAspectRatio,
          padding: padding,
          children: children,
        );
      },
    );
  }

  // Helper method to create safe container with flexible constraints
  static Widget createSafeContainer({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    BoxDecoration? decoration,
    double? width,
    double? height,
    double? minHeight,
    double? maxHeight,
    AlignmentGeometry? alignment,
  }) {
    return Container(
      width: width,
      height: height,
      constraints: BoxConstraints(
        minHeight: minHeight ?? 0,
        maxHeight: maxHeight ?? double.infinity,
      ),
      padding: padding,
      margin: margin,
      decoration: decoration,
      alignment: alignment,
      child: child,
    );
  }

  // Helper method to create Today Overview section
  static Widget createTodayOverviewSection({
    required String title,
    required List<Widget> dashboardCards,
    required VoidCallback onRefresh,
    EdgeInsetsGeometry? padding,
    double spacing = 15,
    BuildContext? context,
  }) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 0,
        maxHeight: double.infinity,
      ),
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: context != null
                      ? createResponsiveTitleStyle(context)
                      : const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              IconButton(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh, size: 20),
                tooltip: 'Refresh dashboard data',
              ),
            ],
          ),
          SizedBox(height: spacing),
          createFlexibleGrid(
            crossAxisCount: 2,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            defaultChildAspectRatio: 1.4,
            children: dashboardCards,
            context: context,
          ),
        ],
      ),
    );
  }

  // Helper method to create responsive text style based on screen size
  static TextStyle createResponsiveTextStyle(
    BuildContext context, {
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? minFontSize,
    double? maxFontSize,
  }) {
    final media = MediaQuery.of(context).size;
    final baseFontSize = fontSize ?? 16.0;

    // Calculate responsive font size based on screen width
    double responsiveFontSize = baseFontSize;
    if (media.width < 350) {
      responsiveFontSize = baseFontSize * 0.9; // Small screens
    } else if (media.width > 600) {
      responsiveFontSize = baseFontSize * 1.1; // Large screens
    }

    // Apply min/max constraints
    if (minFontSize != null) {
      responsiveFontSize = responsiveFontSize.clamp(
        minFontSize,
        double.infinity,
      );
    }
    if (maxFontSize != null) {
      responsiveFontSize = responsiveFontSize.clamp(0, maxFontSize);
    }

    return TextStyle(
      fontSize: responsiveFontSize,
      fontWeight: fontWeight ?? FontWeight.normal,
      color: color ?? getTextColor(context),
    );
  }

  // Helper method to create responsive title style
  static TextStyle createResponsiveTitleStyle(
    BuildContext context, {
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
  }) {
    return createResponsiveTextStyle(
      context,
      fontSize: fontSize ?? 18.0,
      fontWeight: fontWeight ?? FontWeight.w600,
      color: color,
      minFontSize: 16.0,
      maxFontSize: 24.0,
    );
  }

  // Helper method to create responsive container with flexible height
  static Widget createFlexibleContainer({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    BoxDecoration? decoration,
    double? width,
    double? minHeight,
    double? maxHeight,
    AlignmentGeometry? alignment,
  }) {
    return Container(
      width: width,
      constraints: BoxConstraints(
        minHeight: minHeight ?? 0,
        maxHeight: maxHeight ?? double.infinity,
      ),
      padding: padding,
      margin: margin,
      decoration: decoration,
      alignment: alignment,
      child: child,
    );
  }

  // Helper method to create responsive grid with flexible height
  static Widget createFlexibleGrid({
    required List<Widget> children,
    required int crossAxisCount,
    double crossAxisSpacing = 15,
    double mainAxisSpacing = 15,
    double defaultChildAspectRatio = 1.4,
    EdgeInsetsGeometry? padding,
    BuildContext? context,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive childAspectRatio based on screen width and font size
        double childAspectRatio = defaultChildAspectRatio;

        // Adjust based on screen width
        if (constraints.maxWidth > 400) {
          childAspectRatio = 1.6; // Wider screens get more horizontal space
        } else if (constraints.maxWidth < 300) {
          childAspectRatio = 1.2; // Narrow screens get less horizontal space
        }

        // Adjust based on font size if context is provided
        if (context != null) {
          final fontSize = getFontSize(context);
          if (fontSize > 16) {
            childAspectRatio *=
                1.1; // Slight increase for larger fonts (max 16)
          } else if (fontSize < 12) {
            childAspectRatio *= 0.9; // Slight decrease for smaller fonts
          }
        }

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: crossAxisSpacing,
          mainAxisSpacing: mainAxisSpacing,
          childAspectRatio: childAspectRatio,
          padding: padding,
          children: children,
        );
      },
    );
  }

  // Helper method to create Today Overview section with flexible height
  static Widget createFlexibleTodayOverviewSection({
    required String title,
    required List<Widget> dashboardCards,
    required VoidCallback onRefresh,
    EdgeInsetsGeometry? padding,
    double spacing = 15,
    BuildContext? context,
  }) {
    return createFlexibleContainer(
      minHeight: 200,
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: context != null
                      ? createResponsiveTitleStyle(context)
                      : const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              IconButton(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh, size: 20),
                tooltip: 'Refresh dashboard data',
              ),
            ],
          ),
          SizedBox(height: spacing),
          createFlexibleGrid(
            crossAxisCount: 2,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            defaultChildAspectRatio: 1.4,
            children: dashboardCards,
            context: context,
          ),
        ],
      ),
    );
  }

  // Helper method to create Today Overview section with limited font size
  static Widget createLimitedFontTodayOverviewSection({
    required String title,
    required List<Widget> dashboardCards,
    required VoidCallback onRefresh,
    EdgeInsetsGeometry? padding,
    double spacing = 15,
    BuildContext? context,
  }) {
    return createFlexibleContainer(
      minHeight: 180,
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: context != null
                      ? createResponsiveTextStyle(
                          context,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          maxFontSize: 18, // Giới hạn title font size
                        )
                      : const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              IconButton(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh, size: 20),
                tooltip: 'Refresh dashboard data',
              ),
            ],
          ),
          SizedBox(height: spacing),
          createFlexibleGrid(
            crossAxisCount: 2,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            defaultChildAspectRatio:
                1.5, // Tăng aspect ratio để có thêm không gian
            children: dashboardCards,
            context: context,
          ),
        ],
      ),
    );
  }

  // Helper method to create limited font text style for dashboard cards
  static TextStyle createLimitedFontTextStyle(
    BuildContext context, {
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double maxFontSize = 16.0, // Default max font size
  }) {
    final media = MediaQuery.of(context).size;
    final baseFontSize = fontSize ?? 16.0;

    // Calculate responsive font size based on screen width
    double responsiveFontSize = baseFontSize;
    if (media.width < 350) {
      responsiveFontSize = baseFontSize * 0.9; // Small screens
    } else if (media.width > 600) {
      responsiveFontSize = baseFontSize * 1.0; // Large screens (no increase)
    }

    // Apply max constraint to prevent overflow
    responsiveFontSize = responsiveFontSize.clamp(0, maxFontSize);

    return TextStyle(
      fontSize: responsiveFontSize,
      fontWeight: fontWeight ?? FontWeight.normal,
      color: color ?? getTextColor(context),
    );
  }

  // Helper method to create Today Overview section with strict font size limits
  static Widget createStrictFontTodayOverviewSection({
    required String title,
    required List<Widget> dashboardCards,
    required VoidCallback onRefresh,
    EdgeInsetsGeometry? padding,
    double spacing = 15,
    BuildContext? context,
  }) {
    return createFlexibleContainer(
      minHeight: 220, // Tăng từ 160 lên 220 để có thêm không gian
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: context != null
                      ? createLimitedFontTextStyle(
                          context,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          maxFontSize: 18, // Strict limit for title
                        )
                      : const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              IconButton(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh, size: 20),
                tooltip: 'Refresh dashboard data',
              ),
            ],
          ),
          SizedBox(height: spacing),
          LayoutBuilder(
            builder: (context, constraints) {
              // Calculate optimal childAspectRatio for 4 cards
              double childAspectRatio =
                  2.2; // Tăng đáng kể để có thêm không gian cho text

              if (constraints.maxWidth < 350) {
                childAspectRatio = 1.8; // Smaller screens
              } else if (constraints.maxWidth > 500) {
                childAspectRatio = 2.5; // Larger screens - tăng thêm không gian
              }

              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
                childAspectRatio: childAspectRatio,
                children: dashboardCards,
              );
            },
          ),
        ],
      ),
    );
  }

  // Helper method to create text styles with fixed font sizes (no scaling)
  static TextStyle createFixedFontTextStyle({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
  }) {
    return TextStyle(
      fontSize: fontSize ?? 16.0,
      fontWeight: fontWeight ?? FontWeight.normal,
      color: color ?? Colors.black,
    );
  }

  // Helper method to create Today Overview section with fixed font sizes
  static Widget createFixedFontTodayOverviewSection({
    required String title,
    required List<Widget> dashboardCards,
    required VoidCallback onRefresh,
    EdgeInsetsGeometry? padding,
    double spacing = 20,
    BuildContext? context,
    double maxScale = 1, // Giới hạn cứng ở 80% để tránh overflow
  }) {
    return createFlexibleContainer(
      minHeight: 320, // Tăng chiều cao hơn nữa
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18, // Title có thể scale theo global font
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                onPressed: onRefresh,
                icon: Icon(
                  Icons.refresh,
                  size: 20,
                  color: Theme.of(context!).colorScheme.primary,
                ),
                tooltip: 'Refresh dashboard data',
              ),
            ],
          ),
          SizedBox(height: spacing),
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 360;
              final baseH = SettingsHelper.computeOverviewCardHeight(
                context,
                valueFs: 28,
                titleFs: 14,
                twoLineTitle: true,
                ring: 40,
              );
              // giữ trong khoảng an toàn để đẹp mắt
              final itemH = baseH.clamp(132.0, 176.0).toDouble();

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: dashboardCards.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isNarrow ? 1 : 2,
                  crossAxisSpacing: spacing,
                  mainAxisSpacing: spacing,
                  mainAxisExtent: itemH, // <-- FIX QUAN TRỌNG
                ),
                // cho text nhích nhẹ theo global scale, không vỡ layout
                itemBuilder: (_, i) =>
                    _ClampTextScale(maxScale: 1.08, child: dashboardCards[i]),
              );
            },
          ),
        ],
      ),
    );
  }

  // Tính chiều cao card dựa trên font + scale hiện tại
  static double computeOverviewCardHeight(
    BuildContext context, {
    double valueFs = 28, // font size của số
    double titleFs = 14, // font size của tiêu đề (2 dòng)
    bool twoLineTitle = true,
    double ring = 40, // đường kính progress ring
    double verticalGaps = 12 + 8 + 6 + 8, // padding + các SizedBox
  }) {
    final scale = MediaQuery.textScaleFactorOf(context);
    const topRowH = 40.0; // hàng icon + ring
    final valueH = valueFs * 1.10 * scale;
    final titleH = titleFs * 1.05 * scale * (twoLineTitle ? 2 : 1);
    return topRowH + verticalGaps + valueH + titleH;
  }
}

class _ClampTextScale extends StatelessWidget {
  final double maxScale;
  final Widget child;
  const _ClampTextScale({required this.maxScale, required this.child});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final s = mq.textScaler.scale(1.0);
    final clamped = s > maxScale ? maxScale : s;
    return MediaQuery(
      data: mq.copyWith(textScaler: TextScaler.linear(clamped)),
      child: child,
    );
  }
}
