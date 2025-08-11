import 'package:flutter/material.dart';
import '../utils/settings_helper.dart';

class OverflowSafeText extends StatelessWidget {
  final String text;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final int maxLines;
  final TextAlign textAlign;
  final bool isTitle;
  final bool isSubtitle;

  const OverflowSafeText(
    this.text, {
    super.key,
    this.fontSize,
    this.fontWeight,
    this.color,
    this.maxLines = 1,
    this.textAlign = TextAlign.start,
    this.isTitle = false,
    this.isSubtitle = false,
  });

  @override
  Widget build(BuildContext context) {
    TextStyle style;

    if (isTitle) {
      style = SettingsHelper.getTitleStyleWithOverflow(
        context,
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      );
    } else if (isSubtitle) {
      style = SettingsHelper.getSubtitleStyleWithOverflow(
        context,
        fontSize: fontSize,
        color: color,
      );
    } else {
      style = SettingsHelper.getTextStyleWithOverflow(
        context,
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      );
    }

    return Text(text, style: style, maxLines: maxLines, textAlign: textAlign);
  }
}

class OverflowSafeContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BoxDecoration? decoration;
  final double? width;
  final double? height;
  final AlignmentGeometry? alignment;

  const OverflowSafeContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.decoration,
    this.width,
    this.height,
    this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      decoration: decoration,
      alignment: alignment,
      child: child,
    );
  }
}
