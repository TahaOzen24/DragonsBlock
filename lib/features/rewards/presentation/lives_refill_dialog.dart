import 'package:flutter/material.dart';
import '../../../core/haptics/haptic_service.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/ads/ad_service.dart';
import '../../../../core/audio/procedural_audio.dart';
import '../../../../core/ui/game_toast.dart';
import '../../shop/services/shop_manager.dart';
import '../services/lives_manager.dart';

class LivesRefillDialog extends StatelessWidget {
  const LivesRefillDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final lives = LivesManager.instance;
    final shop = ShopManager.instance;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFF38BDF8), width: 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF38BDF8).withValues(alpha: 0.3),
              blurRadius: 24,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title & Close
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Row(
                    children: [
                      Text('❤️', style: TextStyle(fontSize: 24)),
                      SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'CAN YENİLEME',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.1,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24, width: 1.0),
                    ),
                    child: const Center(
                      child: Icon(Icons.close_rounded, color: Colors.white70, size: 18),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Heart Visual Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(LivesManager.maxLives, (index) {
                final isFilled = index < lives.currentLives;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: isFilled
                          ? const Color(0xFFEF4444).withValues(alpha: 0.2)
                          : Colors.white.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isFilled ? const Color(0xFFEF4444) : Colors.white24,
                        width: 2,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      isFilled ? '❤️' : '🖤',
                      style: TextStyle(
                        fontSize: 20,
                        color: isFilled ? null : Colors.white38,
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),

            Text(
              lives.isFull
                  ? 'Canların tamamen dolu!'
                  : 'Sıradaki Can: ${lives.timeUntilNextLifeFormatted}',
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),

            // Refill with Gold Option
            ElevatedButton(
              onPressed: lives.isFull
                  ? null
                  : () async {
                      if (shop.goldShards >= 100) {
                        await shop.spendGold(100);
                        await lives.refillLives();
                        AppHaptics.heavy();
                        ProceduralAudio.instance.playRewardClaim();
                        if (context.mounted) {
                          Navigator.of(context).pop();
                          GameToast.showSuccess(context, 'Tüm canların tamamen doldu! ❤️', title: 'CANLAR YENİLENDİ');
                        }
                      } else {
                        GameToast.showError(context, 'Yetersiz altın! En az 100 altın gerekli.', title: 'BAKİYE YETERSİZ');
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF22C55E),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('🪙 100 ALTIN', style: TextStyle(fontWeight: FontWeight.w900)),
                  SizedBox(width: 8),
                  Text('İle Full Doldur', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Watch Ad for Free Life
            OutlinedButton(
              onPressed: lives.isFull
                  ? null
                  : () async {
                      ProceduralAudio.instance.playButtonClick();
                      final rewarded = await AdService.instance.showRewardedAd();
                      if (rewarded) {
                        await lives.addLives(1);
                        ProceduralAudio.instance.playRewardClaim();
                        if (context.mounted) Navigator.of(context).pop();
                      }
                    },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF38BDF8),
                side: const BorderSide(color: Color(0xFF38BDF8), width: 1.5),
                minimumSize: const Size(double.infinity, 46),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_circle_fill_rounded, size: 20),
                  SizedBox(width: 8),
                  Text('Video İzle (+1 ❤️ Kazan)', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().scale(duration: 200.ms, curve: Curves.easeOutBack);
  }
}
