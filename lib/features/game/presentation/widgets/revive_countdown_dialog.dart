import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/audio/procedural_audio.dart';
import '../../../../core/haptics/haptic_service.dart';
import '../../../../core/localization/locale_manager.dart';
import '../../../shop/services/shop_manager.dart';

class ReviveCountdownDialog extends StatefulWidget {
  final int totalSeconds;
  final VoidCallback onWatchAd;
  final VoidCallback? onPayGold;
  final VoidCallback onTimeoutOrSkip;
  final int currentScore;
  final int comboStreak;

  const ReviveCountdownDialog({
    super.key,
    this.totalSeconds = 5,
    required this.onWatchAd,
    this.onPayGold,
    required this.onTimeoutOrSkip,
    this.currentScore = 0,
    this.comboStreak = 0,
  });

  @override
  State<ReviveCountdownDialog> createState() => _ReviveCountdownDialogState();
}

class _ReviveCountdownDialogState extends State<ReviveCountdownDialog> {
  late int _remainingSeconds;
  Timer? _timer;
  bool _actionTaken = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.totalSeconds;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_remainingSeconds > 1) {
        setState(() {
          _remainingSeconds--;
        });
        AppHaptics.selection();
      } else {
        _timer?.cancel();
        _handleTimeout();
      }
    });
  }

  void _handleTimeout() {
    if (_actionTaken) return;
    _actionTaken = true;
    Navigator.of(context).pop();
    widget.onTimeoutOrSkip();
  }

  void _handleWatchAd() {
    if (_actionTaken) return;
    _actionTaken = true;
    _timer?.cancel();
    AppHaptics.heavy();
    ProceduralAudio.instance.playRewardClaim();
    Navigator.of(context).pop();
    widget.onWatchAd();
  }

  void _handlePayGold() async {
    if (_actionTaken) return;
    final spent = await ShopManager.instance.spendShards(200);
    if (!spent || !mounted) return;
    _actionTaken = true;
    _timer?.cancel();
    AppHaptics.heavy();
    ProceduralAudio.instance.playRewardClaim();
    Navigator.of(context).pop();
    widget.onPayGold?.call();
  }

  void _handleSkip() {
    if (_actionTaken) return;
    _actionTaken = true;
    _timer?.cancel();
    AppHaptics.light();
    Navigator.of(context).pop();
    widget.onTimeoutOrSkip();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = _remainingSeconds / widget.totalSeconds;
    final isTr = LocaleManager.instance.isTurkish;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleSkip();
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFFF43F5E), width: 2.0),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF43F5E).withValues(alpha: 0.35),
              blurRadius: 30,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Circular Animated Countdown with Phoenix Revive Relic
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 78,
                    height: 78,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF43F5E).withValues(alpha: 0.5),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/ui/relic_revive_heart.jpg',
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 86,
                    height: 86,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 4,
                      backgroundColor: Colors.black45,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _remainingSeconds <= 2 ? const Color(0xFFEF4444) : const Color(0xFFFBBF24),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white24, width: 1),
                    ),
                    child: Text(
                      '$_remainingSeconds',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ).animate(onPlay: (c) => c.repeat(reverse: true)).scaleXY(begin: 1.0, end: 1.05, duration: 600.ms),

              const SizedBox(height: 18),

              // Title
              Text(
                isTr ? 'HAMLE KALMADI!' : 'NO MOVES LEFT!',
                style: const TextStyle(
                  color: Color(0xFFF43F5E),
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              
              // Score & Combo display for loss aversion
              if (widget.currentScore > 0 || widget.comboStreak > 1)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.currentScore > 0) ...[
                        const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 18),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.currentScore}',
                          style: const TextStyle(
                            color: Color(0xFFF59E0B),
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                      if (widget.currentScore > 0 && widget.comboStreak > 1)
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text('|', style: TextStyle(color: Colors.white24, fontSize: 14)),
                        ),
                      if (widget.comboStreak > 1) ...[
                        const Icon(Icons.local_fire_department_rounded, color: Color(0xFFEF4444), size: 18),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.comboStreak}x COMBO',
                          style: const TextStyle(
                            color: Color(0xFFEF4444),
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              
              Text(
                isTr
                    ? 'Video izleyerek alt satırları erit ve oyuna kaldığın yerden devam et!'
                    : 'Watch a short video to melt bottom rows and continue your game!',
                style: const TextStyle(
                  color: Color(0xFFCBD5E1),
                  fontSize: 12.5,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 18),

              // Option 1: Pay Gold & Revive Immediately (If player has >= 200 gold)
              if (ShopManager.instance.goldShards >= 200) ...[
                InkWell(
                  onTap: _handlePayGold,
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.45),
                          blurRadius: 14,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.monetization_on_rounded, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            isTr ? '200 ALTIN İLE CANLAN' : 'REVIVE WITH 200 GOLD',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],

              // Option 2: Watch Ad & Revive Button
              InkWell(
                onTap: _handleWatchAd,
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF059669)],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withValues(alpha: 0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.smart_display_rounded, color: Colors.white, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          isTr ? 'REKLAM İZLE & DEVAM ET' : 'WATCH AD & REVIVE',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Skip Button
              TextButton(
                onPressed: _handleSkip,
                child: Text(
                  isTr ? 'Pas Geç (Oyunu Bitir)' : 'Skip (End Game)',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ).animate().scale(duration: 250.ms, curve: Curves.easeOutBack),
      ),
    );
  }
}
