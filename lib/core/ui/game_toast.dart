import 'package:flutter/material.dart';
import '../haptics/haptic_service.dart';
import 'package:flutter_animate/flutter_animate.dart';

enum ToastType {
  success,
  gold,
  error,
  info,
  warning,
}

class GameToast {
  static OverlayEntry? _currentEntry;

  static void show(
    BuildContext context, {
    required String message,
    String? title,
    String? icon,
    ToastType type = ToastType.info,
    Duration duration = const Duration(milliseconds: 2600),
  }) {
    _currentEntry?.remove();
    _currentEntry = null;

    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    AppHaptics.light();

    Color primaryColor;
    Color gradientStart;
    Color gradientEnd;
    String defaultIcon;

    switch (type) {
      case ToastType.success:
        primaryColor = const Color(0xFF4ADE80);
        gradientStart = const Color(0xFF14532D);
        gradientEnd = const Color(0xFF064E3B);
        defaultIcon = '🎉';
        break;
      case ToastType.gold:
        primaryColor = const Color(0xFFFBBF24);
        gradientStart = const Color(0xFF78350F);
        gradientEnd = const Color(0xFF451A03);
        defaultIcon = '🪙';
        break;
      case ToastType.error:
        primaryColor = const Color(0xFFEF4444);
        gradientStart = const Color(0xFF7F1D1D);
        gradientEnd = const Color(0xFF450A0A);
        defaultIcon = '⚠️';
        break;
      case ToastType.warning:
        primaryColor = const Color(0xFFF97316);
        gradientStart = const Color(0xFF7C2D12);
        gradientEnd = const Color(0xFF431407);
        defaultIcon = '🔔';
        break;
      case ToastType.info:
        primaryColor = const Color(0xFF38BDF8);
        gradientStart = const Color(0xFF1E3A8A);
        gradientEnd = const Color(0xFF0F172A);
        defaultIcon = '✨';
        break;
    }

    final displayIcon = icon ?? defaultIcon;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => _ToastWidget(
        message: message,
        title: title,
        icon: displayIcon,
        primaryColor: primaryColor,
        gradientStart: gradientStart,
        gradientEnd: gradientEnd,
        duration: duration,
        onDismiss: () {
          if (_currentEntry == entry) {
            entry.remove();
            _currentEntry = null;
          }
        },
      ),
    );

    _currentEntry = entry;
    overlay.insert(entry);
  }

  static void showSuccess(BuildContext context, String message, {String? title}) {
    show(context, message: message, title: title, type: ToastType.success);
  }

  static void showGold(BuildContext context, String message, {String? title}) {
    show(context, message: message, title: title, type: ToastType.gold);
  }

  static void showError(BuildContext context, String message, {String? title}) {
    show(context, message: message, title: title, type: ToastType.error);
  }

  static void showInfo(BuildContext context, String message, {String? title}) {
    show(context, message: message, title: title, type: ToastType.info);
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final String? title;
  final String icon;
  final Color primaryColor;
  final Color gradientStart;
  final Color gradientEnd;
  final Duration duration;
  final VoidCallback onDismiss;

  const _ToastWidget({
    required this.message,
    this.title,
    required this.icon,
    required this.primaryColor,
    required this.gradientStart,
    required this.gradientEnd,
    required this.duration,
    required this.onDismiss,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget> {
  bool _dismissing = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.duration, () {
      if (mounted && !_dismissing) {
        _handleDismiss();
      }
    });
  }

  void _handleDismiss() {
    if (_dismissing) return;
    setState(() => _dismissing = true);
    Future.delayed(const Duration(milliseconds: 250), () {
      widget.onDismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final topPadding = media.padding.top > 0 ? media.padding.top + 8 : 16.0;

    return Positioned(
      top: topPadding,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onVerticalDragEnd: (details) {
            if (details.primaryVelocity != null && details.primaryVelocity! < 0) {
              _handleDismiss();
            }
          },
          onTap: _handleDismiss,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 220),
            opacity: _dismissing ? 0.0 : 1.0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.gradientStart,
                    widget.gradientEnd,
                    const Color(0xFF060918),
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: widget.primaryColor.withValues(alpha: 0.8),
                  width: 1.6,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.primaryColor.withValues(alpha: 0.35),
                    blurRadius: 18,
                    spreadRadius: 1.5,
                    offset: const Offset(0, 4),
                  ),
                  const BoxShadow(
                    color: Colors.black54,
                    blurRadius: 10,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Icon Circle
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.primaryColor.withValues(alpha: 0.22),
                      border: Border.all(color: widget.primaryColor, width: 1.3),
                    ),
                    alignment: Alignment.center,
                    child: Text(widget.icon, style: const TextStyle(fontSize: 19)),
                  ),
                  const SizedBox(width: 12),

                  // Message Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.title != null) ...[
                          Text(
                            widget.title!,
                            style: TextStyle(
                              color: widget.primaryColor,
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(height: 1),
                        ],
                        Text(
                          widget.message,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Close button
                  GestureDetector(
                    onTap: _handleDismiss,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: Icon(Icons.close_rounded, size: 16, color: Colors.white.withValues(alpha: 0.7)),
                    ),
                  ),
                ],
              ),
            ),
          )
              .animate()
              .slideY(begin: -0.8, end: 0.0, duration: 280.ms, curve: Curves.easeOutBack)
              .fadeIn(duration: 200.ms),
        ),
      ),
    );
  }
}
