import 'dart:math';
import '../../../core/haptics/haptic_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/ads/ad_service.dart';
import '../../../../core/audio/procedural_audio.dart';
import '../../../../core/localization/locale_manager.dart';
import '../../../../core/storage/app_prefs.dart';
import '../../../../core/theme/game_theme.dart';
import '../../shop/services/shop_manager.dart';

class WheelPrize {
  final String label;
  final String icon;
  final int shards;
  final Color color;
  final bool isJackpot;

  const WheelPrize({
    required this.label,
    required this.icon,
    required this.shards,
    required this.color,
    this.isJackpot = false,
  });
}

class LuckyWheelDialog extends StatefulWidget {
  const LuckyWheelDialog({super.key});

  @override
  State<LuckyWheelDialog> createState() => _LuckyWheelDialogState();
}

class _LuckyWheelDialogState extends State<LuckyWheelDialog> with SingleTickerProviderStateMixin {
  late AnimationController _spinController;
  late Animation<double> _spinAnimation;

  double _startAngle = 0.0;
  double _targetAngle = 0.0;
  bool _isSpinning = false;
  bool _canFreeSpin = true;
  WheelPrize? _wonPrize;

  static const List<WheelPrize> prizes = [
    WheelPrize(label: '+100 🪙', icon: '🪙', shards: 100, color: GameTheme.neonCyan),
    WheelPrize(label: '+150 ⚡', icon: '⚡', shards: 150, color: GameTheme.lightningYellow),
    WheelPrize(label: '+250 🔮', icon: '🔮', shards: 250, color: GameTheme.voidPurple),
    WheelPrize(label: '+300 ❄️', icon: '❄️', shards: 300, color: GameTheme.frostCyan),
    WheelPrize(label: '+500 🔥', icon: '🔥', shards: 500, color: GameTheme.fireOrange),
    WheelPrize(label: '+150 🪙', icon: '🪙', shards: 150, color: Colors.tealAccent),
    WheelPrize(label: '+750 💎', icon: '💎', shards: 750, color: Colors.pinkAccent),
    WheelPrize(label: '+1000 👑', icon: '👑', shards: 1000, color: GameTheme.goldAccent, isJackpot: true),
  ];

  @override
  void initState() {
    super.initState();
    _checkDailySpin();

    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3800),
    );

    _spinAnimation = CurvedAnimation(
      parent: _spinController,
      curve: Curves.easeOutCubic,
    )..addListener(() {
        if (_isSpinning && _spinController.value < 0.95) {
          final currentTick = (_spinController.value * 24).floor();
          if (currentTick % 3 == 0) {
            AppHaptics.selection();
          }
        }
      })..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _onSpinFinished();
        }
      });
  }

  Future<void> _checkDailySpin() async {
    await AppPrefs.instance.init();
    final lastSpinTs = AppPrefs.instance.getInt(AppPrefs.kLastLuckyWheelTs) ?? 0;
    final now = DateTime.now();
    final lastDate = DateTime.fromMillisecondsSinceEpoch(lastSpinTs);

    final isSameDay = lastSpinTs > 0 &&
        now.year == lastDate.year &&
        now.month == lastDate.month &&
        now.day == lastDate.day;

    setState(() {
      _canFreeSpin = !isSameDay;
    });
  }

  void _spinWheel() async {
    if (_isSpinning) return;

    setState(() {
      _isSpinning = true;
      _wonPrize = null;
    });

    ProceduralAudio.instance.playButtonClick();

    // Determine random winning slice (0 to 7)
    final rng = Random();
    final winningIndex = rng.nextInt(prizes.length);
    final sliceAngle = (2 * pi) / prizes.length;

    // Full rotations (5 to 7 full circles) + angle to slice center
    final fullRotations = 5 + rng.nextInt(3);
    final sliceCenter = (prizes.length - 1 - winningIndex) * sliceAngle + (sliceAngle / 2);
    _targetAngle = _startAngle + (fullRotations * 2 * pi) + sliceCenter;

    _spinAnimation = Tween<double>(begin: _startAngle, end: _targetAngle).animate(
      CurvedAnimation(parent: _spinController, curve: Curves.easeOutCubic),
    );

    _spinController.forward(from: 0.0);
  }

  void _onSpinFinished() async {
    _startAngle = _targetAngle % (2 * pi);

    final sliceAngle = (2 * pi) / prizes.length;
    final normalizedAngle = (2 * pi - (_startAngle % (2 * pi))) % (2 * pi);
    final winningIndex = ((normalizedAngle / sliceAngle).floor()) % prizes.length;

    final prize = prizes[winningIndex];

    await ShopManager.instance.addShards(prize.shards);
    AppHaptics.reward();
    ProceduralAudio.instance.playRewardClaim();

    await AppPrefs.instance.setInt(AppPrefs.kLastLuckyWheelTs, DateTime.now().millisecondsSinceEpoch);

    setState(() {
      _isSpinning = false;
      _canFreeSpin = false;
      _wonPrize = prize;
    });
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: GameTheme.bgDark.withValues(alpha: 0.98),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: GameTheme.goldAccent.withValues(alpha: 0.7), width: 1.8),
          boxShadow: GameTheme.goldGlow(blur: 28, spread: 2),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Image.asset('assets/images/ui/icon_spin.png', width: 26, height: 26, fit: BoxFit.contain, filterQuality: FilterQuality.high),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          AppStrings.luckyRunicWheel,
                          style: GameTheme.titleLarge.copyWith(
                            fontSize: 16,
                            color: GameTheme.goldAccent,
                            letterSpacing: 1.0,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                InkWell(
                  onTap: _isSpinning ? null : () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: GameTheme.bgDarkest,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24, width: 1.0),
                    ),
                    child: const Center(
                      child: Icon(Icons.close_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Wheel Canvas Stack with Needle Indicator
            SizedBox(
              width: 250,
              height: 250,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Animated Rotating Wheel
                  AnimatedBuilder(
                    animation: _spinController,
                    builder: (context, child) {
                      final currentAngle = _spinAnimation.value;
                      return Transform.rotate(
                        angle: currentAngle,
                        child: CustomPaint(
                          size: const Size(240, 240),
                          painter: _WheelPainter(prizes: prizes),
                        ),
                      );
                    },
                  ),

                  // Center Gold Hub
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: GameTheme.bgDarkest,
                      border: Border.all(color: GameTheme.goldAccent, width: 2.5),
                      boxShadow: GameTheme.goldGlow(blur: 14),
                    ),
                    alignment: Alignment.center,
                    child: const Text('✨', style: TextStyle(fontSize: 22)),
                  ),

                  // Top Needle Pointer
                  Positioned(
                    top: 0,
                    child: Container(
                      width: 20,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
                        boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 4)],
                      ),
                      alignment: Alignment.center,
                      child: const Text('▼', style: TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Won Prize Banner or Status
            if (_wonPrize != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: _wonPrize!.color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _wonPrize!.color),
                  boxShadow: [BoxShadow(color: _wonPrize!.color.withValues(alpha: 0.3), blurRadius: 10)],
                ),
                child: Text(
                  AppStrings.wonPrize(_wonPrize!.label),
                  style: TextStyle(
                    color: _wonPrize!.color,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
              ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
              const SizedBox(height: 10),
            ],

            // Spin CTA Button
            ElevatedButton(
              onPressed: _isSpinning
                  ? null
                  : () async {
                      if (_canFreeSpin) {
                        _spinWheel();
                      } else {
                        final watched = await AdService.instance.showRewardedAd();
                        if (watched && mounted) {
                          _spinWheel();
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: GameTheme.goldAccent,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 46),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 6,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_canFreeSpin ? '🎁' : '📺', style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Text(
                    _isSpinning
                        ? AppStrings.spinning
                        : (_canFreeSpin
                            ? AppStrings.freeSpin
                            : AppStrings.extraSpinAd),
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                  ),
                ],
              ),
            ).animate(target: !_isSpinning && _canFreeSpin ? 1 : 0).shimmer(duration: 1200.ms),
          ],
        ),
      ),
    ),
  );
  }
}

class _WheelPainter extends CustomPainter {
  final List<WheelPrize> prizes;

  _WheelPainter({required this.prizes});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final sliceAngle = (2 * pi) / prizes.length;

    final paint = Paint()..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = GameTheme.gridBorder
      ..strokeWidth = 1.5;

    for (int i = 0; i < prizes.length; i++) {
      final startAngle = i * sliceAngle;
      paint.color = i.isEven
          ? prizes[i].color.withValues(alpha: 0.4)
          : prizes[i].color.withValues(alpha: 0.22);

      // Draw Slice
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sliceAngle,
        true,
        paint,
      );
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sliceAngle,
        true,
        borderPaint,
      );

      // Draw Slice Text/Icon
      canvas.save();
      final textAngle = startAngle + sliceAngle / 2;
      canvas.translate(center.dx, center.dy);
      canvas.rotate(textAngle);

      final textSpan = TextSpan(
        text: '${prizes[i].icon} ${prizes[i].shards}',
        style: TextStyle(
          color: prizes[i].color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(canvas, Offset(radius * 0.45, -textPainter.height / 2));
      canvas.restore();
    }

    // Outer wheel border ring
    final outerRing = Paint()
      ..style = PaintingStyle.stroke
      ..color = GameTheme.goldAccent.withValues(alpha: 0.6)
      ..strokeWidth = 3.0;
    canvas.drawCircle(center, radius, outerRing);
  }

  @override
  bool shouldRepaint(covariant _WheelPainter oldDelegate) => false;
}
