import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/audio/procedural_audio.dart';
import '../../../../../core/haptics/haptic_service.dart';
import '../../../../../core/theme/game_theme.dart';
import '../../../models/game_mode.dart';

/// Clean home lobby — brand, mode, play only.
/// Rewards live in Shop; quests live in the top status bar.
class MenuHomePlayableTab extends StatelessWidget {
  final GameMode selectedGameMode;
  final ValueChanged<GameMode> onModeChanged;
  final int highScore;
  final int adventureLevel;
  final VoidCallback onStartGame;

  const MenuHomePlayableTab({
    super.key,
    required this.selectedGameMode,
    required this.onModeChanged,
    required this.highScore,
    required this.adventureLevel,
    required this.onStartGame,
  });

  @override
  Widget build(BuildContext context) {
    final accent = selectedGameMode.themeColor;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 🐉 Grand DragonsBlock Brand Emblem with Radiant Halo
              Expanded(
                child: Center(
                  child: _buildBrand(constraints),
                ),
              ),

              const SizedBox(height: 8),

              // Game Mode Picker (Classic / Adventure)
              _buildModePicker(),

              const SizedBox(height: 14),

              // Tactical Play Button
              _buildPlayButton(accent),

              const SizedBox(height: 6),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBrand(BoxConstraints constraints) {
    // Dynamically calculate responsive dimensions so it's as big as possible without overflow
    final double maxW = (constraints.maxWidth * 0.88).clamp(260.0, 360.0);
    final double maxH = (constraints.maxHeight * 0.62).clamp(240.0, 370.0);

    return FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(
        width: maxW,
        height: maxH,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Soft Radial Mythic Ambient Glow Behind Emblem
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFFFD54F).withValues(alpha: 0.28),
                      const Color(0xFF38BDF8).withValues(alpha: 0.18),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.45, 0.85],
                  ),
                ),
              ),
            ),

            // High-Resolution 3D Masterpiece DragonsBlock Logo Asset
            Image.asset(
              'assets/images/dragons_block_logo.png',
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 480.ms)
        .scale(
          begin: const Offset(0.88, 0.88),
          end: const Offset(1.0, 1.0),
          curve: Curves.easeOutBack,
          duration: 600.ms,
        )
        .then()
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
          begin: const Offset(1.0, 1.0),
          end: const Offset(1.025, 1.025),
          curve: Curves.easeInOutSine,
          duration: 2200.ms,
        );
  }

  Widget _buildModePicker() {
    return Row(
      children: [
        Expanded(
          child: _ModeTile(
            title: 'KLASİK',
            subtitle: highScore > 999
                ? 'Rekor ${(highScore / 1000).toStringAsFixed(1)}K'
                : 'Rekor $highScore',
            icon: Icons.all_inclusive_rounded,
            selected: selectedGameMode == GameMode.classic,
            accent: const Color(0xFF38BDF8),
            onTap: () {
              if (selectedGameMode != GameMode.classic) {
                AppHaptics.selection();
                ProceduralAudio.instance.playButtonClick();
                onModeChanged(GameMode.classic);
              }
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ModeTile(
            title: 'MACERA',
            subtitle: 'Bölüm $adventureLevel',
            icon: Icons.map_rounded,
            selected: selectedGameMode == GameMode.adventure,
            accent: const Color(0xFFF59E0B),
            onTap: () {
              if (selectedGameMode != GameMode.adventure) {
                AppHaptics.selection();
                ProceduralAudio.instance.playButtonClick();
                onModeChanged(GameMode.adventure);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPlayButton(Color accent) {
    return GestureDetector(
      onTap: () {
        AppHaptics.medium();
        onStartGame();
      },
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.lerp(Colors.white, accent, 0.25)!,
              accent,
              Color.lerp(accent, const Color(0xFF0B1220), 0.35)!,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.4),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 30),
            const SizedBox(width: 4),
            Text(
              'OYNA',
              style: TextStyle(
                fontFamily: GameTheme.fontSpaceGrotesk,
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 3.5,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.012, 1.012),
          duration: 1600.ms,
        );
  }
}

class _ModeTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  const _ModeTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
        decoration: BoxDecoration(
          color: selected
              ? accent.withValues(alpha: 0.16)
              : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? accent : Colors.white.withValues(alpha: 0.12),
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 22, color: selected ? accent : Colors.white54),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontFamily: GameTheme.fontSpaceGrotesk,
                color: selected ? Colors.white : Colors.white70,
                fontSize: 15,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontFamily: GameTheme.fontOutfit,
                color: selected ? accent.withValues(alpha: 0.95) : Colors.white38,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
