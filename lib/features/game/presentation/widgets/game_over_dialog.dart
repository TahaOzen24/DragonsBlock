import 'package:flutter/material.dart';
import '../../../../core/haptics/haptic_service.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/audio/procedural_audio.dart';
import '../../../../core/localization/locale_manager.dart';
import '../../../../core/theme/game_theme.dart';
import '../../../shop/services/shop_manager.dart';
import '../painters/stat_bar_vector_icons.dart';
import 'game_top_stat_bars.dart';
import 'viral_share_card_dialog.dart';

/// Fullscreen AAA Studio Game Over Screen:
/// - Top status bar with High Score and Coin balances
/// - Epic stylized "GAME OVER" typography crest with glowing neon aura
/// - Huge crisp final score with "YENİ REKOR!" banner when applicable
/// - Dark glassmorphic stats card with pure vector icons
/// - High-contrast action buttons: Hayata Dön (1 Can), 2X Kazanç, Paylaş
/// - Clean bottom row: Menü and Tekrar Oyna buttons (NO cutting lines!)
class GameOverDialog extends StatelessWidget {
  final int finalScore;
  final int highScore;
  final int linesCleared;
  final int shardsEarned;
  final bool isNewHighScore;
  final bool canRevive;
  final VoidCallback onRevive;
  final VoidCallback onDoubleShards;
  final VoidCallback? onShareScore;
  final VoidCallback onRestart;
  final VoidCallback onMainMenu;

  const GameOverDialog({
    super.key,
    required this.finalScore,
    required this.highScore,
    required this.linesCleared,
    required this.shardsEarned,
    required this.isNewHighScore,
    this.canRevive = true,
    required this.onRevive,
    required this.onDoubleShards,
    this.onShareScore,
    required this.onRestart,
    required this.onMainMenu,
  });

  String _formatScore(int score) {
    return score.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final goldBalance = ShopManager.instance.goldShards;

    return Dialog.fullscreen(
          backgroundColor: GameTheme.bgDeep,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          onMainMenu();
        },
        child: Scaffold(
      backgroundColor: GameTheme.bgDeep,
          body: Stack(
            children: [
              // 1. Living Atmospheric Radial Backdrop (Deep Cosmic Navy & Subtle Indigo Glow)
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(0.0, -0.3),
                      radius: 1.1,
                      colors: [
                        Color(0xFF0F1E3D),
                        Color(0xFF060B1A),
                        Color(0xFF02040A),
                      ],
                      stops: [0.0, 0.55, 1.0],
                    ),
                  ),
                ),
              ),

              // 2. Main Scrollable Content
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: constraints.maxHeight),
                        child: IntrinsicHeight(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            child: Column(
                              children: [
                                // Top Status Bar (High Score & Coins & Pause)
                                _buildTopBar(goldBalance),

                                const SizedBox(height: 20),

                                // Epic Stylized "GAME OVER" Crest & Header
                                _buildGameOverHeader(),

                                const SizedBox(height: 10),

                                // Huge Heroic Score
                                _buildScoreDisplay(),

                                const SizedBox(height: 20),

                                // Dark Glassmorphic Statistics Card with Vector Icons
                                _buildStatsCard(),

                                const SizedBox(height: 16),

                                // Action Buttons Stack
                                if (canRevive) ...[
                                  _buildReviveButton(context),
                                  const SizedBox(height: 12),
                                ],

                                _buildDoubleShardsButton(context),
                                const SizedBox(height: 12),

                                _buildShareButton(context),
                                const SizedBox(height: 18),

                                const Spacer(),

                                // Bottom Row: Menü & Tekrar Oyna (Clean, no lines overlapping!)
                                _buildBottomActionRow(context),

                                const SizedBox(height: 12),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── 1. TOP STATUS BAR ───────────────────────────────────────────────────
  Widget _buildTopBar(int goldBalance) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Max Puan Barı
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: MaxScoreBar(highScore: highScore, height: 44),
          ),
        ),
        const SizedBox(width: 12),
        // Right side: Altın Barı
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerRight,
          child: GoldCoinsBar(goldCoins: goldBalance, showPlusBadge: false, height: 44),
        ),
      ],
    );
  }

  // ─── 2. STYLIZED "GAME OVER" CREST & HEADER ──────────────────────────────
  Widget _buildGameOverHeader() {
    final isTr = LocaleManager.instance.isTurkish;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Glowing Crystal Shield / Emblem Icon
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1E3A8A),
                Color(0xFF0F172A),
              ],
            ),
            border: Border.all(
              color: const Color(0xFF38BDF8),
              width: 2.0,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0284C7).withValues(alpha: 0.55),
                blurRadius: 24,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.sports_esports_rounded,
              color: Color(0xFF38BDF8),
              size: 38,
            ),
          ),
        ).animate().scale(curve: Curves.elasticOut, duration: 700.ms),

        const SizedBox(height: 14),

        // Stylized "GAME OVER" Text with Gradient Shader & Glow
        ShaderMask(
          shaderCallback: (bounds) {
            return const LinearGradient(
              colors: [
                Color(0xFFFFFFFF),
                Color(0xFFE2E8F0),
                Color(0xFF93C5FD),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ).createShader(bounds);
          },
          child: const Text(
            'GAME OVER',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: 4.0,
              shadows: [
                Shadow(
                  color: Color(0xFF0284C7),
                  blurRadius: 20,
                ),
              ],
            ),
          ),
        ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0),

        if (isNewHighScore) ...[
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 16),
                const SizedBox(width: 5),
                Text(
                  isTr ? 'YENİ REKOR!' : 'NEW RECORD!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true)).shimmer(duration: 1500.ms),
        ],
      ],
    );
  }

  // ─── 3. HEROIC FINAL SCORE ───────────────────────────────────────────────
  Widget _buildScoreDisplay() {
    final bool isRecord = isNewHighScore;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: isRecord
                  ? [
                      const Color(0xFFFFF7ED),
                      const Color(0xFFFDE047),
                      const Color(0xFFF59E0B),
                    ]
                  : [
                      Colors.white,
                      const Color(0xFFE0F2FE),
                      const Color(0xFF7DD3FC),
                    ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ).createShader(bounds);
          },
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _formatScore(finalScore),
              style: TextStyle(
                color: Colors.white,
                fontSize: 68,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                height: 1.1,
                shadows: [
                  Shadow(
                    color: isRecord ? const Color(0xFFD97706) : const Color(0xFF0284C7),
                    blurRadius: 28,
                    offset: const Offset(0, 3),
                  ),
                  const Shadow(
                    color: Colors.black87,
                    blurRadius: 14,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
        ).animate().fadeIn(delay: 150.ms, duration: 500.ms).scale(
              begin: const Offset(0.85, 0.85),
              curve: Curves.easeOutBack,
            ),

        const SizedBox(height: 8),

        // Glowing Accent Capsule
        Container(
          width: 52,
          height: 4,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isRecord
                  ? [const Color(0xFFF59E0B), const Color(0xFFFDE047)]
                  : [const Color(0xFF0284C7), const Color(0xFF38BDF8)],
            ),
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(
                color: (isRecord ? const Color(0xFFF59E0B) : const Color(0xFF38BDF8)).withValues(alpha: 0.8),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── 4. STATISTICS CARD WITH PURE VECTOR ICONS ───────────────────────────
  Widget _buildStatsCard() {
    final isTr = LocaleManager.instance.isTurkish;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF091124).withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFF1E3A8A).withValues(alpha: 0.75),
          width: 1.4,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 18,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Row 1: En Yüksek Skor (with Vector Crown)
          _buildStatRow(
            icon: const VectorCrownIcon(size: 20),
            label: isTr ? 'En Yüksek Skor' : 'High Score',
            valueText: _formatScore(highScore),
            valueColor: const Color(0xFFFBBF24),
          ),

          Divider(color: GameTheme.divider, height: 22, thickness: 1),

          // Row 2: Temizlenen Çizgi
          _buildStatRow(
            icon: const Icon(Icons.track_changes_rounded, color: Color(0xFF38BDF8), size: 20),
            label: isTr ? 'Temizlenen Çizgi' : 'Lines Cleared',
            valueText: '$linesCleared',
            valueColor: const Color(0xFF38BDF8),
          ),

          Divider(color: GameTheme.divider, height: 22, thickness: 1),

          // Row 3: Kazanılan Altın (with Vector Coin)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const VectorCoinIcon(size: 20),
                  const SizedBox(width: 14),
                  Text(
                    isTr ? 'Kazanılan Altın' : 'Gold Earned',
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '+$shardsEarned',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const VectorCoinIcon(size: 18),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow({
    required Widget icon,
    required String label,
    required String valueText,
    required Color valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            const SizedBox(width: 14),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Text(
          valueText,
          style: TextStyle(
            color: valueColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }

  // ─── 5. HAYATA DÖN (1 CAN) PRIMARY BUTTON ─────────────────────────────────
  Widget _buildReviveButton(BuildContext context) {
    final isTr = LocaleManager.instance.isTurkish;
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF00E676),
            Color(0xFF00C853),
          ],
        ),
        borderRadius: BorderRadius.circular(27),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E676).withValues(alpha: 0.45),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(27),
          onTap: () {
            AppHaptics.medium();
            ProceduralAudio.instance.playDialogPop();
            onRevive();
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const VectorHeartIcon(size: 22),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 14),
                width: 1.2,
                height: 22,
                color: Colors.white.withValues(alpha: 0.35),
              ),
              Text(
                isTr ? 'HAYATA DÖN (1 CAN)' : 'REVIVE (1 LIFE)',
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
    ).animate(onPlay: (c) => c.repeat(reverse: true)).shimmer(duration: 1800.ms);
  }

  // ─── 6. 2X KAZANÇ (REKLAM) BUTTON ─────────────────────────────────────────
  Widget _buildDoubleShardsButton(BuildContext context) {
    final isTr = LocaleManager.instance.isTurkish;
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFF0B1429),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: const Color(0xFF1E3A8A).withValues(alpha: 0.85),
          width: 1.3,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(25),
          onTap: () {
            AppHaptics.light();
            ProceduralAudio.instance.playDialogPop();
            onDoubleShards();
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const VectorCoinIcon(size: 22),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 14),
                width: 1.2,
                height: 20,
                color: Colors.white.withValues(alpha: 0.20),
              ),
              Text(
                isTr ? '2X KAZANÇ (REKLAM)' : '2X REWARD (AD)',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── 7. SKOR KARTINI PAYLAŞ BUTTON ────────────────────────────────────────
  Widget _buildShareButton(BuildContext context) {
    final isTr = LocaleManager.instance.isTurkish;
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFF0B1429),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: const Color(0xFF1E3A8A).withValues(alpha: 0.85),
          width: 1.3,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(25),
          onTap: () {
            AppHaptics.light();
            ProceduralAudio.instance.playDialogPop();
            if (onShareScore != null) {
              onShareScore!();
            } else {
              showDialog(
                context: context,
                builder: (_) => ViralShareCardDialog(
                  score: finalScore,
                  linesCleared: linesCleared,
                  isNewHighScore: isNewHighScore,
                ),
              );
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.share_rounded,
                color: Colors.white70,
                size: 20,
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 14),
                width: 1.2,
                height: 20,
                color: Colors.white.withValues(alpha: 0.20),
              ),
              Text(
                isTr ? 'SKOR KARTINI PAYLAŞ' : 'SHARE SCORE CARD',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── 8. BOTTOM MENÜ & TEKRAR OYNA (JUICY CANDY-GEM STYLING) ─────────────
  Widget _buildBottomActionRow(BuildContext context) {
    final isTr = LocaleManager.instance.isTurkish;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Primary: Tekrar Oyna Button (Full width, pulsing, prominent)
        SizedBox(
          width: double.infinity,
          height: 60,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0284C7),
                  Color(0xFF0369A1),
                  Color(0xFF075985),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF38BDF8).withValues(alpha: 0.8),
                width: 1.6,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0284C7).withValues(alpha: 0.60),
                  blurRadius: 22,
                  offset: const Offset(0, 5),
                ),
                const BoxShadow(
                  color: Colors.black38,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  AppHaptics.medium();
                  ProceduralAudio.instance.playDialogPop();
                  onRestart();
                },
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
                        const SizedBox(width: 8),
                        Text(
                          isTr ? 'TEKRAR OYNA' : 'PLAY AGAIN',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true)).scaleXY(begin: 1.0, end: 1.02, duration: 800.ms),
        ),

        const SizedBox(height: 10),

        // Secondary: Menü Button (Smaller, subtle)
        SizedBox(
          width: double.infinity,
          height: 44,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1E293B),
                  Color(0xFF0F172A),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF334155),
                width: 1.2,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  AppHaptics.light();
                  ProceduralAudio.instance.playDialogPop();
                  onMainMenu();
                },
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.home_rounded, color: Colors.white70, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            isTr ? 'MENÜ' : 'MENU',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
