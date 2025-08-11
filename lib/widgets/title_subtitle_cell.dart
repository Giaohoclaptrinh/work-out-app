import 'package:flutter/material.dart';

import 'package:workout_app/common/color_extension.dart';
import '../utils/settings_helper.dart';

class TitleSubtitleCell extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color? titleColor;
  final Color? subtitleColor;

  const TitleSubtitleCell({
    super.key,
    required this.title,
    required this.subtitle,
    this.titleColor,
    this.subtitleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
      decoration: BoxDecoration(
        color: SettingsHelper.getCardColor(context),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: SettingsHelper.getBorderColor(context),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: SettingsHelper.getShadowColor(context),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: SettingsHelper.getTitleStyle(
              context,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: titleColor ?? SettingsHelper.getTextColor(context),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: SettingsHelper.getSubtitleStyle(
              context,
              fontSize: 14,
              color:
                  subtitleColor ??
                  SettingsHelper.getSecondaryTextColor(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
