import 'package:flutter/material.dart';

import 'package:workout_app/common/color_extension.dart';
import '../utils/settings_helper.dart';

class TitleSubtitleCell extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color? titleColor;
  final Color? subtitleColor;
  final double minHeight;

  const TitleSubtitleCell({
    super.key,
    required this.title,
    required this.subtitle,
    this.titleColor,
    this.subtitleColor,
    this.minHeight = 90,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
      constraints: BoxConstraints(minHeight: minHeight),
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
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: Text(
              title,
              style: SettingsHelper.getTitleStyle(
                context,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: titleColor ?? SettingsHelper.getTextColor(context),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ),
          const SizedBox(height: 4),
          _ClampTextScale(
            maxScale: 1.08,
            child: Text(
              subtitle,
              style: SettingsHelper.getSubtitleStyle(
                context,
                fontSize: 14,
                color:
                    subtitleColor ??
                    SettingsHelper.getSecondaryTextColor(context),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
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
