import 'package:flutter/material.dart';
import '../common/color_extension.dart';
import '../utils/settings_helper.dart';

class DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;
  final double progress;
  final VoidCallback? onTap;

  const DashboardCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
    this.progress = 0.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableH = constraints.maxHeight.isFinite
              ? constraints.maxHeight
              : 9999.0;
          final ultraCompact = availableH < 120;
          final compact = !ultraCompact && availableH < 140;

          final double ringSize = ultraCompact ? 24 : (compact ? 28 : 40);
          final double valueFs = ultraCompact ? 20 : (compact ? 22 : 28);
          final double titleFs = ultraCompact ? 11 : (compact ? 12 : 14);
          final double topGap = ultraCompact ? 4 : (compact ? 6 : 8);
          final double midGap = ultraCompact ? 4 : (compact ? 4 : 6);
          final double paddingAll = ultraCompact ? 6 : (compact ? 8 : 12);
          final double stroke = ultraCompact ? 2.5 : (compact ? 3 : 4);

          return Container(
            padding: EdgeInsets.all(paddingAll),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hàng icon + progress ring (co giãn theo chiều cao khả dụng)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(icon, color: color, size: 20),
                    if (progress > 0)
                      SizedBox(
                        width: ringSize,
                        height: ringSize,
                        child: CircularProgressIndicator(
                          value: progress.clamp(0.0, 1.0),
                          strokeWidth: stroke,
                          backgroundColor: color.withOpacity(0.15),
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: topGap),

                // Value + unit (được ràng chiều cao để tránh overflow theo chiều dọc)
                _ClampTextScale(
                  maxScale: 1.08,
                  child: SizedBox(
                    height: valueFs * 1.10, // khớp với công thức tính chiều cao
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            value,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: valueFs,
                              fontWeight: FontWeight.w700,
                              color: SettingsHelper.getTextColor(context),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            unit,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: ultraCompact ? 11 : (compact ? 12 : 13),
                              color: SettingsHelper.getSecondaryTextColor(context),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: midGap),

                // Title (tự động rút xuống 1 dòng nếu không gian thấp)
                Text(
                  title,
                  maxLines: compact ? 1 : 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: titleFs,
                    height: 1.05,
                    fontWeight: FontWeight.w600,
                    color: SettingsHelper.getTextColor(context),
                  ),
                ),
              ],
            ),
          );
        },
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
