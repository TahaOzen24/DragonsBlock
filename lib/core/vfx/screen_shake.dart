import 'dart:math';
import 'package:flutter/material.dart';
import '../settings/settings_manager.dart';

class ScreenShakeController {
  VoidCallback? _triggerCallback;
  double _trauma = 0.0; // 0.0 to 1.0
  double _intensity = 6.0;

  void trigger({double intensity = 6.0, double trauma = 0.5}) {
    if (!SettingsManager.instance.isScreenShakeEnabled) return;
    _trauma = trauma.clamp(0.0, 1.0);
    _intensity = intensity.clamp(1.0, 16.0);
    _triggerCallback?.call();
  }

  void _attach(VoidCallback callback) {
    _triggerCallback = callback;
  }

  void _detach() {
    _triggerCallback = null;
  }
}

class ScreenShakeWidget extends StatefulWidget {
  final ScreenShakeController controller;
  final Widget child;

  const ScreenShakeWidget({
    super.key,
    required this.controller,
    required this.child,
  });

  @override
  State<ScreenShakeWidget> createState() => _ScreenShakeWidgetState();
}

class _ScreenShakeWidgetState extends State<ScreenShakeWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  final Random _rng = Random();

  Offset _shakeOffset = Offset.zero;
  double _shakeAngle = 0.0;
  double _shakeScale = 1.0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    )..addListener(() {
        if (_animController.isAnimating) {
          final progress = 1.0 - _animController.value;
          // Non-linear quadratic trauma decay (T^2) scaled by intensity
          final trauma = (widget.controller._trauma * progress);
          final shakeForce = trauma * trauma * (widget.controller._intensity / 8.0);

          final maxOffset = 16.0 * shakeForce;
          final maxAngle = 0.04 * shakeForce;
          final scalePunch = 1.0 + (0.025 * shakeForce);

          setState(() {
            _shakeOffset = Offset(
              (_rng.nextDouble() * 2 - 1) * maxOffset,
              (_rng.nextDouble() * 2 - 1) * maxOffset,
            );
            _shakeAngle = (_rng.nextDouble() * 2 - 1) * maxAngle;
            _shakeScale = scalePunch;
          });
        } else {
          setState(() {
            _shakeOffset = Offset.zero;
            _shakeAngle = 0.0;
            _shakeScale = 1.0;
          });
        }
      });

    widget.controller._attach(() {
      _animController.forward(from: 0.0);
    });
  }

  @override
  void dispose() {
    widget.controller._detach();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final matrix = Matrix4.translationValues(_shakeOffset.dx, _shakeOffset.dy, 0.0)
      ..rotateZ(_shakeAngle)
      // ignore: deprecated_member_use
      ..scale(_shakeScale, _shakeScale);

    return Transform(
      transform: matrix,
      alignment: Alignment.center,
      child: widget.child,
    );
  }
}
