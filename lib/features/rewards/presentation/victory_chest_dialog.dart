import 'package:flutter/material.dart';
import '../../../core/haptics/haptic_service.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/ads/ad_service.dart';
import '../../../core/audio/procedural_audio.dart';
import '../../../core/localization/locale_manager.dart';
import '../../../core/theme/game_theme.dart';
import '../../shop/services/shop_manager.dart';

class VictoryChestDialog extends StatefulWidget {
  final String title;
  final String subtitle;
  final int baseReward;

  const VictoryChestDialog({
    super.key,
    required this.title,
    required this.subtitle,
    this.baseReward = 500,
  });

  @override
  State<VictoryChestDialog> createState() => _VictoryChestDialogState();
}

class _VictoryChestDialogState extends State<VictoryChestDialog> {
  bool _isOpened = false;
  bool _isDoubled = false;
  int _currentReward = 0;

  @override
  void initState() {
    super.initState();
    _currentReward = widget.baseReward;
  }

  void _openChest() {
    if (_isOpened) return;
    AppHaptics.heavy();
    ProceduralAudio.instance.playExplosion();
    ProceduralAudio.instance.playRewardClaim();

    setState(() {
      _isOpened = true;
    });

    ShopManager.instance.addShards(_currentReward);
  }

  Future<void> _doubleReward() async {
    if (_isDoubled) return;
    final watched = await AdService.instance.showRewardedAd();
    if (!watched || !mounted) return;

    final bonus = widget.baseReward;
    await ShopManager.instance.addShards(bonus);
    ProceduralAudio.instance.playRewardClaim();

    setState(() {
      _isDoubled = true;
      _currentReward += bonus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: GameTheme.bgDark.withValues(alpha: 0.98),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: GameTheme.goldAccent, width: 2.2),
            boxShadow: [
              BoxShadow(
                color: GameTheme.goldAccent.withValues(alpha: 0.4),
                blurRadius: 32,
                spreadRadius: 4,
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              // Title
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: GameTheme.goldAccent,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.subtitle,
                textAlign: TextAlign.center,
                style: GameTheme.bodyMedium.copyWith(fontSize: 12, color: GameTheme.textMuted),
              ),
              const SizedBox(height: 20),

              // Interactive Chest
              GestureDetector(
                onTap: _openChest,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isOpened
                        ? GameTheme.goldAccent.withValues(alpha: 0.2)
                        : GameTheme.bgSurface,
                    border: Border.all(
                      color: _isOpened ? GameTheme.goldAccent : GameTheme.gridBorder,
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _isOpened
                            ? GameTheme.goldAccent.withValues(alpha: 0.6)
                            : Colors.black.withValues(alpha: 0.4),
                        blurRadius: _isOpened ? 28 : 12,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: _isOpened
                      ? Image.asset('assets/images/ui/icon_rank.png', width: 85, height: 85, fit: BoxFit.contain, filterQuality: FilterQuality.high)
                      : Image.asset('assets/images/ui/icon_gift.png', width: 85, height: 85, fit: BoxFit.contain, filterQuality: FilterQuality.high),
                )
                    .animate(
                      target: _isOpened ? 1.0 : 0.0,
                      onPlay: (controller) {
                        if (!_isOpened) controller.repeat(reverse: true);
                      },
                    )
                    .scale(
                      begin: const Offset(1.0, 1.0),
                      end: const Offset(1.08, 1.08),
                      duration: 600.ms,
                    ),
              ),

              const SizedBox(height: 16),

              if (!_isOpened) ...[
                Text(
                  AppStrings.tapToOpen,
                  style: const TextStyle(
                    color: GameTheme.neonCyan,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ).animate(onPlay: (c) => c.repeat(reverse: true)).fadeIn().scale(),
              ] else ...[
                // Revealed Reward
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/ui/icon_coin.png', width: 28, height: 28, filterQuality: FilterQuality.high),
                    const SizedBox(width: 8),
                    Text(
                      '+$_currentReward',
                      style: const TextStyle(
                        color: GameTheme.goldAccent,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
                const SizedBox(height: 14),

                // 2X Double Reward Button
                if (!_isDoubled)
                  ElevatedButton.icon(
                    onPressed: _doubleReward,
                    icon: const Icon(Icons.smart_display_rounded, color: Colors.black, size: 20),
                    label: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        AppStrings.doubleRewardWatchAd,
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GameTheme.emeraldGreen,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 44),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),

                const SizedBox(height: 10),

                // Claim / Close Button
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: GameTheme.gridBorder),
                    minimumSize: const Size(double.infinity, 40),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    AppStrings.claimAndClose,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  );
  }
}
