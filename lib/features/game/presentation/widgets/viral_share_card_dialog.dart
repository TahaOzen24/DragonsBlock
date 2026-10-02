import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/audio/procedural_audio.dart';
import '../../../../core/haptics/haptic_service.dart';
import '../../../../core/ui/game_toast.dart';
import '../../../../core/ui/vector_assets/vector_assets.dart';
import '../../../dragon/models/dragon.dart';
import '../../../dragon/services/dragon_manager.dart';

/// 📱 Viral Social Share & Brag Poster Dialog
/// Generates a viral, shareable graphic card formatted for Instagram/TikTok/WhatsApp
/// showing the player's score, max combo, active Dragon, and evolution rank.
class ViralShareCardDialog extends StatelessWidget {
  final int score;
  final int linesCleared;
  final bool isNewHighScore;

  const ViralShareCardDialog({
    super.key,
    required this.score,
    required this.linesCleared,
    this.isNewHighScore = false,
  });

  String _formatScore(int num) {
    return num.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  void _copyToClipboard(BuildContext context) {
    AppHaptics.medium();
    ProceduralAudio.instance.playRewardClaim();

    final dragon = DragonManager.instance.activeDragon;
    final stage = DragonManager.instance.currentStage;
    final stageName = stage.displayName;

    final shareText = '''
🎮 DragonsBlock
🏆 Skor: ${_formatScore(score)} Puan!
🐉 Ejderham: ${dragon.name} (${dragon.getEmojiForStage(stage)})
⚔️ Temizlenen Hat: $linesCleared | Kademe: $stageName
Sen de kendi ejderhanı büyüt ve rekorumu kır! 🔥
''';

    Clipboard.setData(ClipboardData(text: shareText));
    GameToast.showSuccess(context, 'Skor metni panoya kopyalandı!', title: 'PAYLAŞIMA HAZIR 🚀');
  }

  @override
  Widget build(BuildContext context) {
    final dragon = DragonManager.instance.activeDragon;
    final stage = DragonManager.instance.currentStage;
    final level = DragonManager.instance.dragonLevel;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 360),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E1B4B),
              Color(0xFF0F172A),
              Color(0xFF020617),
            ],
          ),
          border: Border.all(color: dragon.themeColor, width: 2.0),
          boxShadow: [
            BoxShadow(
              color: dragon.themeColor.withValues(alpha: 0.45),
              blurRadius: 32,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Poster Top Artwork & Brand
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [dragon.themeColor.withValues(alpha: 0.35), Colors.transparent],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  children: [
                    // Brand Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: dragon.themeColor.withValues(alpha: 0.6)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          VectorDragonEgg(eggType: dragon.eggType, size: 16),
                          const SizedBox(width: 6),
                          const Text(
                            'DRAGONSBLOCK',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Dragon Large Avatar
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: dragon.themeColor, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: dragon.themeColor.withValues(alpha: 0.5),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          dragon.getImageForStage(stage),
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                    )
                        .animate()
                        .scale(
                          begin: const Offset(0.8, 0.8),
                          end: const Offset(1.0, 1.0),
                          duration: 400.ms,
                          curve: Curves.easeOutBack,
                        ),
                    const SizedBox(height: 8),

                    // Dragon Info
                    Text(
                      '${dragon.name} • Lv.$level',
                      style: TextStyle(
                        color: dragon.themeColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.6,
                      ),
                    ),
                    Text(
                      stage.displayName,
                      style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10.5, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              // 2. Score & Stats Box
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    children: [
                      if (isNewHighScore) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFFFBBF24), Color(0xFFD97706)]),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            '👑 YENİ REKOR!',
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 10),
                          ),
                        ),
                        const SizedBox(height: 6),
                      ],
                      Text(
                        _formatScore(score),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const Text(
                        'TOPLAM PUAN',
                        style: TextStyle(color: Color(0xFF38BDF8), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                      ),
                      const Divider(color: Colors.white12, height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatPill('🧱 Hatlar', '$linesCleared'),
                          _buildStatPill('🐉 Element', dragon.name),
                          _buildStatPill('⚡ Pasif', dragon.passiveName),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 3. Action Buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _copyToClipboard(context),
                        icon: const Icon(Icons.share_rounded, size: 16),
                        label: const Text(
                          'SKORU KOPYALA / PAYLAŞ',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: dragon.themeColor,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded, color: Colors.white70),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white10,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatPill(String label, String val) {
    return Column(
      children: [
        Text(val, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11.5), maxLines: 1),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 9)),
      ],
    );
  }
}
