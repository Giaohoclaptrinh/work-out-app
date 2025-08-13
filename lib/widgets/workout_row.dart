import 'package:flutter/material.dart';
import '../common/color_extension.dart';
import '../utils/settings_helper.dart';
import 'package:simple_animation_progress_bar/simple_animation_progress_bar.dart';

class WorkoutRow extends StatelessWidget {
  final Map wObj;
  final VoidCallback? onPressed;
  final bool showStartButton;

  const WorkoutRow({
    super.key,
    required this.wObj,
    this.onPressed,
    this.showStartButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    // Giới hạn textScaleFactor ở mức 1.0 cho riêng row này để tránh overflow
    final scaled = mq.textScaler.scale(1.0);
    final clamped = scaled > 1.0 ? 1.0 : scaled;

    // Chuẩn hóa dữ liệu hiển thị
    final name = (wObj['name'] ?? 'Workout').toString();
    final kcalStr = (wObj['kcal'] is num)
        ? (wObj['kcal'] as num).toStringAsFixed(0)
        : (wObj['kcal']?.toString() ?? '0');
    final timeStr = (wObj['time'] is num)
        ? (wObj['time'] as num).toStringAsFixed(0)
        : (wObj['time']?.toString() ?? '0');

    final rawImg = wObj['image'];
    final imgStr = (rawImg is String) ? rawImg.trim() : null;
    final isNetworkImage = imgStr != null && imgStr.startsWith('http');

    final progress = (wObj['progress'] as num?)?.toDouble() ?? 0.0;
    final safeProgress = progress.clamp(0.0, 1.0);

    return MediaQuery(
      data: mq.copyWith(textScaler: TextScaler.linear(clamped)),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        decoration: BoxDecoration(
          color: SettingsHelper.getCardColor(context),
          borderRadius: BorderRadius.circular(20),
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
        child: Row(
          children: [
            // Ảnh
            ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: isNetworkImage
                  ? Image.network(
                      imgStr!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Image.asset(
                        "assets/img/Workout1.png",
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Image.asset(
                      imgStr ?? "assets/img/Workout1.png",
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
            ),

            const SizedBox(width: 15),

            // Thông tin
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Không dùng Expanded cho Text để tránh bóp chiều cao
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: SettingsHelper.getTitleStyle(
                      context,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: TColor.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "$kcalStr Calories Burn | $timeStr minutes",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: SettingsHelper.getSubtitleStyle(
                      context,
                      fontSize: 13,
                      color: TColor.gray,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Progress bar: dùng LayoutBuilder để full-width an toàn
                  LayoutBuilder(
                                builder: (context, constraints) {
                                  // Ép kiểu rõ ràng về double
                                  final double barWidth =
                                      (constraints.maxWidth > 0) ? constraints.maxWidth : 160.0;

                                  return SimpleAnimationProgressBar(
                                    height: 12.0,                 // dùng double
                                    width: barWidth,              // giờ là double
                                    backgroundColor: Colors.grey.shade100,
                                    foregroundColor: TColor.primaryColor1,
                                    ratio: safeProgress,          // đã là double 0..1
                                    direction: Axis.horizontal,
                                    curve: Curves.fastLinearToSlowEaseIn,
                                    duration: const Duration(seconds: 1),
                                    borderRadius: BorderRadius.circular(6),
                                    gradientColor: LinearGradient(
                                      colors: TColor.primaryG,
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                  );
                                },
                              ),

                ],
              ),
            ),

            const SizedBox(width: 10),

            // Khu nút bấm
            if (showStartButton)
              // Cố định một độ rộng tối thiểu để tránh bị bóp
              SizedBox(
                width: 96,
                child: _StartButton(
                  label: "Start",
                  onTap: onPressed ??
                      () {
                        final id = wObj['id'];
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              id != null
                                  ? 'Starting $name...'
                                  : 'Starting workout...',
                            ),
                            backgroundColor: TColor.primaryColor1,
                          ),
                        );
                      },
                ),
              )
            else
              IconButton(
                onPressed: onPressed ??
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Viewing $name details...'),
                          backgroundColor: TColor.primaryColor1,
                        ),
                      );
                    },
                icon: Image.asset(
                  "assets/img/next_icon.png",
                  width: 30,
                  height: 30,
                  fit: BoxFit.contain,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StartButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _StartButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: TColor.primaryG),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: TColor.primaryColor1.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("assets/img/Play.png",
                    width: 18, height: 18, color: Colors.white),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14, // có thể hạ xuống 13 nếu màn bé
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
