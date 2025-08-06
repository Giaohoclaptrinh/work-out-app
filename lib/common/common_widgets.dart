import 'package:flutter/material.dart';
import 'color_extension.dart';

class RoundButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final double elevation;
  final Color? backgroundColor;
  final Color? textColor;
  final double fontSize;
  final FontWeight fontWeight;
  final double height;
  final double width;

  const RoundButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.elevation = 1,
    this.backgroundColor,
    this.textColor,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w700,
    this.height = 50,
    this.width = double.maxFinite,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: backgroundColor != null 
            ? [backgroundColor!, backgroundColor!]
            : TColor.primaryG,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: elevation,
            offset: Offset(0, elevation),
          ),
        ],
      ),
      child: MaterialButton(
        onPressed: onPressed,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        textColor: textColor ?? TColor.white,
        minWidth: double.maxFinite,
        elevation: 0,
        color: Colors.transparent,
        child: Text(
          title,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
          ),
        ),
      ),
    );
  }
}

class SettingRow extends StatelessWidget {
  final String icon;
  final String title;
  final VoidCallback onPressed;

  const SettingRow({
    super.key,
    required this.icon,
    required this.title,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              icon,
              height: 25,
              width: 25,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: TColor.black,
                  fontSize: 14,
                ),
              ),
            ),
            SizedBox(
              width: 25,
              height: 25,
              child: Image.asset(
                "assets/img/p_next.png",
                width: 12,
                height: 12,
                fit: BoxFit.contain,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class TitleSubtitleCell extends StatelessWidget {
  final String title;
  final String subtitle;

  const TitleSubtitleCell({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: TColor.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: TColor.gray,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}