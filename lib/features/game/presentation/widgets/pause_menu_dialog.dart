import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/audio/procedural_audio.dart';
import '../../../../core/haptics/haptic_service.dart';
import '../../../../core/localization/locale_manager.dart';
import '../../../../core/settings/settings_dialog.dart';
import '../../../../core/settings/settings_manager.dart';

/// AAA Glassmorphic Neon Pause Menu Dialog
class PauseMenuDialog extends StatefulWidget {
  final VoidCallback onRestart;
  final VoidCallback onQuit;

  const PauseMenuDialog({
    super.key,
    required this.onRestart,
    required this.onQuit,
  });

  @override
  State<PauseMenuDialog> createState() => _PauseMenuDialogState();
}

class _PauseMenuDialogState extends State<PauseMenuDialog> {
  final SettingsManager _settings = SettingsManager.instance;

  @override
  Widget build(BuildContext context) {
    final isTr = LocaleManager.instance.isTurkish;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
          decoration: BoxDecoration(
            color: const Color(0xFF070D1E).withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: const Color(0xFF0284C7).withValues(alpha: 0.75),
              width: 1.6,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0284C7).withValues(alpha: 0.35),
                blurRadius: 28,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.70),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Glowing Pause Emblem + Top-Right Settings Button
              Stack(
                alignment: Alignment.center,
                children: [
                  Center(
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0284C7), Color(0xFF0F172A)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        border: Border.all(
                          color: const Color(0xFF38BDF8),
                          width: 2.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF38BDF8).withValues(alpha: 0.5),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.pause_rounded,
                          color: Colors.white,
                          size: 34,
                        ),
                      ),
                    ).animate().scale(curve: Curves.elasticOut, duration: 600.ms),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: IconButton(
                      tooltip: isTr ? 'Tüm Ayarlar' : 'All Settings',
                      icon: const Icon(Icons.settings_rounded, color: Colors.white70, size: 22),
                      onPressed: () {
                        AppHaptics.light();
                        ProceduralAudio.instance.playDialogPop();
                        showDialog(
                          context: context,
                          builder: (_) => const SettingsDialog(),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Title
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Colors.white, Color(0xFFBAE6FD), Color(0xFF38BDF8)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ).createShader(bounds),
                child: Text(
                  isTr ? 'OYUN DURAKLATILDI' : 'GAME PAUSED',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Quick Audio & Haptics Toggles
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B162C),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF1E3A8A).withValues(alpha: 0.6),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildToggleIcon(
                      icon: _settings.isSoundEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                      label: isTr ? 'Ses' : 'SFX',
                      isActive: _settings.isSoundEnabled,
                      onTap: () {
                        AppHaptics.selection();
                        _settings.setSound(!_settings.isSoundEnabled);
                        setState(() {});
                      },
                    ),
                    Container(width: 1, height: 28, color: Colors.white12),
                    _buildToggleIcon(
                      icon: _settings.isMusicEnabled ? Icons.music_note_rounded : Icons.music_off_rounded,
                      label: isTr ? 'Müzik' : 'BGM',
                      isActive: _settings.isMusicEnabled,
                      onTap: () {
                        AppHaptics.selection();
                        _settings.setMusic(!_settings.isMusicEnabled);
                        setState(() {});
                      },
                    ),
                    Container(width: 1, height: 28, color: Colors.white12),
                    _buildToggleIcon(
                      icon: _settings.isHapticsEnabled ? Icons.vibration_rounded : Icons.smartphone_rounded,
                      label: isTr ? 'Titreşim' : 'Haptics',
                      isActive: _settings.isHapticsEnabled,
                      onTap: () {
                        final next = !_settings.isHapticsEnabled;
                        _settings.setHaptics(next);
                        if (next) {
                          AppHaptics.testPreview(_settings.hapticProfile);
                        }
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),

              // Vibration Mode / Model Selector (When Haptics is Active)
              if (_settings.isHapticsEnabled) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF081224),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFF1E3A8A).withValues(alpha: 0.45),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        'Model:',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Row(
                          children: HapticProfile.values.map((profile) {
                            final isSelected = _settings.hapticProfile == profile;
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 2),
                                child: InkWell(
                                  onTap: () {
                                    _settings.setHapticProfile(profile);
                                    AppHaptics.testPreview(profile);
                                    setState(() {});
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(vertical: 5.5),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(0xFF00E5FF).withValues(alpha: 0.22)
                                          : Colors.white.withValues(alpha: 0.04),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isSelected
                                            ? const Color(0xFF00E5FF)
                                            : Colors.white10,
                                        width: isSelected ? 1.4 : 1.0,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${profile.emoji} ${profile.shortName}',
                                        style: TextStyle(
                                          color: isSelected ? const Color(0xFF00E5FF) : Colors.white70,
                                          fontSize: 11,
                                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 22),

              // 1. Devam Et Primary Button
              _buildActionButton(
                label: isTr ? 'DEVAM ET' : 'RESUME',
                icon: Icons.play_arrow_rounded,
                gradient: const LinearGradient(
                  colors: [Color(0xFF00E676), Color(0xFF00C853)],
                ),
                shadowColor: const Color(0xFF00E676),
                onTap: () {
                  ProceduralAudio.instance.playButtonClick();
                  Navigator.of(context).pop();
                },
              ),

              const SizedBox(height: 12),

              // 2. Yeniden Başlat Button
              _buildActionButton(
                label: isTr ? 'YENİDEN BAŞLAT' : 'RESTART',
                icon: Icons.replay_rounded,
                gradient: const LinearGradient(
                  colors: [Color(0xFF0091FF), Color(0xFF0066FF)],
                ),
                shadowColor: const Color(0xFF0091FF),
                onTap: () {
                  ProceduralAudio.instance.playButtonClick();
                  Navigator.of(context).pop();
                  widget.onRestart();
                },
              ),

              const SizedBox(height: 12),

              // 3. Ana Menü Button
              _buildActionButton(
                label: isTr ? 'ANA MENÜ' : 'MAIN MENU',
                icon: Icons.home_rounded,
                isOutlined: true,
                onTap: () {
                  ProceduralAudio.instance.playButtonClick();
                  Navigator.of(context).pop();
                  widget.onQuit();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleIcon({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final activeColor = isActive ? const Color(0xFF38BDF8) : Colors.white38;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: activeColor, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: activeColor,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    LinearGradient? gradient,
    Color? shadowColor,
    bool isOutlined = false,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        gradient: gradient,
        color: isOutlined ? const Color(0xFF0F172A) : null,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOutlined
              ? const Color(0xFF334155)
              : Colors.white.withValues(alpha: 0.30),
          width: 1.4,
        ),
        boxShadow: shadowColor != null
            ? [
                BoxShadow(
                  color: shadowColor.withValues(alpha: 0.45),
                  blurRadius: 16,
                  offset: const Offset(0, 3),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            AppHaptics.light();
            onTap();
          },
          child: Stack(
            children: [
              if (gradient != null)
                Positioned(
                  top: 2,
                  left: 14,
                  right: 14,
                  height: 10,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(alpha: 0.35),
                          Colors.white.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon, color: Colors.white, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                            shadows: [
                              Shadow(
                                color: Colors.black45,
                                blurRadius: 6,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
