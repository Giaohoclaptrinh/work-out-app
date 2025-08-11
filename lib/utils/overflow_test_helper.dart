import 'package:flutter/material.dart';

class OverflowTestHelper {
  // Helper to wrap widgets with overflow debugging
  static Widget withOverflowDebug(Widget child, {String? name}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.red.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: child,
        );
      },
    );
  }

  // Helper to create a safe container that prevents overflow
  static Widget createSafeContainer({
    required Widget child,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    BoxDecoration? decoration,
  }) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      decoration: decoration,
      child: SingleChildScrollView(child: child),
    );
  }

  // Helper to create flexible text that adapts to container size
  static Widget createFlexibleText(
    String text, {
    TextStyle? style,
    int maxLines = 1,
    TextAlign textAlign = TextAlign.start,
  }) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        text,
        style: style,
        maxLines: maxLines,
        textAlign: textAlign,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  // Helper to check if widget might overflow
  static bool mightOverflow(Size containerSize, Size contentSize) {
    return contentSize.width > containerSize.width ||
        contentSize.height > containerSize.height;
  }
}
