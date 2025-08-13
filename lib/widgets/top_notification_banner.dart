import 'package:flutter/material.dart';
import '../common/color_extension.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

/// Shows a styled notification banner sliding in from the top.
///
/// Wrapped inside a SizedBox to keep a consistent height and layout.
void showTopBanner(
  BuildContext context, {
  String? title,
  required String message,
  Color? backgroundColor,
  Color? foregroundColor,
  IconData icon = Icons.info_outline,
  Duration duration = const Duration(seconds: 3),
}) {
  // Honor user preference: only show if push/pop-up notifications are enabled
  try {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    if (!settings.pushNotifications) {
      return;
    }
  } catch (_) {
    // If provider isn't available, fall back to showing the banner
  }

  final overlay = Overlay.of(context);
  if (overlay == null) return;

  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) => _TopBanner(
      title: title,
      message: message,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      icon: icon,
      duration: duration,
      onDismiss: () {
        try {
          entry.remove();
        } catch (_) {}
      },
    ),
  );

  overlay.insert(entry);
}

class _TopBanner extends StatefulWidget {
  final String? title;
  final String message;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final IconData icon;
  final Duration duration;
  final VoidCallback onDismiss;

  const _TopBanner({
    required this.title,
    required this.message,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.icon,
    required this.duration,
    required this.onDismiss,
  });

  @override
  State<_TopBanner> createState() => _TopBannerState();
}

class _TopBannerState extends State<_TopBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _offset = Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();

    Future.delayed(widget.duration, () async {
      if (!mounted) return;
      await _controller.reverse();
      if (mounted) widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.backgroundColor ?? TColor.primaryColor1;
    final fg = widget.foregroundColor ?? Colors.white;

    final mq = MediaQuery.of(context);
    // Clamp text scale to avoid overflow on accessibility large fonts
    final clamped = mq.textScaler;

    return MediaQuery(
      data: mq.copyWith(textScaler: const TextScaler.linear(1.0)),
      child: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: SlideTransition(
            position: _offset,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: 56,
                  maxWidth: MediaQuery.of(context).size.width,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () async {
                      await _controller.reverse();
                      if (mounted) widget.onDismiss();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: bg.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(widget.icon, color: fg),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (widget.title != null && widget.title!.isNotEmpty)
                                  Text(
                                    widget.title!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: fg,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                Text(
                                  widget.message,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: fg.withOpacity(0.95),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.keyboard_arrow_up, color: fg),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


