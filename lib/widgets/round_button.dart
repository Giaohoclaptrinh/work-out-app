import 'package:flutter/material.dart';

import 'package:workout_app/common/color_extension.dart';
import 'package:workout_app/utils/settings_helper.dart';

enum RoundButtonType { bgGradient, bgSGradient, textGradient }

class RoundButton extends StatelessWidget {
  final String title;
  final RoundButtonType type;
  final VoidCallback onPressed;
  final double fontSize;
  final double elevation;
  final FontWeight fontWeight;

  const RoundButton({
    super.key,
    required this.title,
    this.type = RoundButtonType.bgGradient,
    this.fontSize = 16,
    this.elevation = 1,
    this.fontWeight = FontWeight.w700,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Use relative font size that will be scaled by MediaQuery
    final relativeFontSize = fontSize;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: type == RoundButtonType.bgSGradient
              ? TColor.secondaryG
              : TColor.primaryG,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow:
            type == RoundButtonType.bgGradient ||
                type == RoundButtonType.bgSGradient
            ? const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 0.5,
                  offset: Offset(0, 0.5),
                ),
              ]
            : null,
      ),
      child: MaterialButton(
        onPressed: onPressed,
        height: 50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        textColor: SettingsHelper.getPrimaryColor(context),
        minWidth: 0,
        elevation:
            type == RoundButtonType.bgGradient ||
                type == RoundButtonType.bgSGradient
            ? 0
            : elevation,
        color:
            type == RoundButtonType.bgGradient ||
                type == RoundButtonType.bgSGradient
            ? Colors.transparent
            : TColor.white,
        child:
            type == RoundButtonType.bgGradient ||
                type == RoundButtonType.bgSGradient
            ? Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: relativeFontSize,
                  fontWeight: fontWeight,
                ),
              )
            : ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) {
                  return LinearGradient(
                    colors: TColor.primaryG,
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ).createShader(
                    Rect.fromLTRB(0, 0, bounds.width, bounds.height),
                  );
                },
                child: Text(
                  title,
                  style: TextStyle(
                    color: TColor.primaryColor1,
                    fontSize: relativeFontSize,
                    fontWeight: fontWeight,
                  ),
                ),
              ),
      ),
    );
  }
}
