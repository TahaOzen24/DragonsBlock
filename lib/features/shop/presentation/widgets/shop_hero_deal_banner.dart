import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/audio/procedural_audio.dart';
import '../../../../core/haptics/haptic_service.dart';
import '../../../../core/iap/iap_service.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/ui/game_toast.dart';
import '../../../../core/ui/vector_assets/vector_assets.dart';
import '../../services/shop_manager.dart';
import 'shop_godray_painter.dart';

/// Flash Deal Hero Banner — persistent 24h countdown (prefs-backed).
class ShopHeroDealBanner extends StatefulWidget {
  final VoidCallback? onPurchased;

  const ShopHeroDealBanner({super.key, this.onPurchased});

  @override
  State<ShopHeroDealBanner> createState() => _ShopHeroDealBannerState();
}

class _ShopHeroDealBannerState extends State<ShopHeroDealBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  Timer? _timer;
  Duration _remaining = Duration.zero;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _bootDeadline();
  }

  Future<void> _bootDeadline() async {
    final end = await ShopManager.instance.ensureFlashDealDeadline();
    if (!mounted) return;
    setState(() {
      _remaining = end.difference(DateTime.now());
      if (_remaining.isNegative) _remaining = Duration.zero;
      _ready = true;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_remaining.inSeconds > 0) {
          _remaining = _remaining - const Duration(seconds: 1);
        }
      });
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours.toString().padLeft(2, '0');
    final minutes = (d.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final iap = IapService.instance;
    final item = IapService.catalog.firstWhere(
      (it) => it.id == 'shards_tier2_1500',
      orElse: () => IapService.catalog.first,
    );
    final localizedPrice = iap.getLocalizedPrice(item.id);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF3B0764),
            Color(0xFF1E1B4B),
            Color(0xFF0F172A),
          ],
        ),
        border: Border.all(color: const Color(0xFFA855F7), width: 1.6),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFA855F7).withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            Positioned.fill(
              child: ShopGodrayBackground(
                rayColor: const Color(0xFFA855F7),
                size: 220,
                speed: 12,
                child: const SizedBox.expand(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Row(
                children: [
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      final scale = 1.0 + (_pulseController.value * 0.06);
                      return Transform.scale(scale: scale, child: child);
                    },
                    child: const ShopGodrayBackground(
                      rayColor: Color(0xFFFBBF24),
                      size: 64,
                      speed: 7,
                      child: VectorTreasureChest(tier: ChestTier.silver, size: 48),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                AppStrings.shopTagPopular,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _ready ? _formatDuration(_remaining) : '--:--:--',
                              style: const TextStyle(
                                color: Color(0xFFFBBF24),
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppStrings.shopHeroDealTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          AppStrings.shopHeroDealSubtitle,
                          style: const TextStyle(
                            color: Color(0xFFD8B4FE),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      AppHaptics.heavy();
                      ProceduralAudio.instance.playButtonClick();
                      final success = await iap.buyProduct(item.id);
                      if (!mounted || !context.mounted) return;
                      if (success) {
                        GameToast.showGold(
                          context,
                          AppStrings.shopPaymentOpened,
                          title: AppStrings.shopPaymentTitle,
                        );
                      } else {
                        GameToast.showError(
                          context,
                          iap.lastError ?? AppStrings.shopPurchaseFailed,
                          title: AppStrings.shop,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFBBF24),
                      foregroundColor: Colors.black,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      localizedPrice,
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
