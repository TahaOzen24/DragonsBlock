import 'dart:async';
import '../../../core/haptics/haptic_service.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/audio/procedural_audio.dart';
import '../../../core/localization/locale_manager.dart';
import '../../../core/settings/settings_manager.dart';
import '../../../core/theme/game_theme.dart';

class JukeboxDialog extends StatefulWidget {
  const JukeboxDialog({super.key});

  @override
  State<JukeboxDialog> createState() => _JukeboxDialogState();
}

class _JukeboxDialogState extends State<JukeboxDialog> {
  final ProceduralAudio _audio = ProceduralAudio.instance;
  final SettingsManager _settings = SettingsManager.instance;
  Timer? _waveformTimer;
  final List<double> _barHeights = List.generate(12, (_) => 0.3);
  final Random _rng = Random();

  @override
  void initState() {
    super.initState();
    _waveformTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (!mounted) return;
      if (_settings.isMusicEnabled) {
        setState(() {
          for (int i = 0; i < _barHeights.length; i++) {
            _barHeights[i] = 0.15 + _rng.nextDouble() * 0.85;
          }
        });
      } else {
        setState(() {
          for (int i = 0; i < _barHeights.length; i++) {
            _barHeights[i] = 0.08;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _waveformTimer?.cancel();
    super.dispose();
  }

  void _toggleMusic(bool value) async {
    AppHaptics.medium();
    await _settings.setMusic(value);
    setState(() {});
  }

  void _selectSoundscape(AudioSoundscape soundscape) async {
    AppHaptics.heavy();
    _audio.playButtonClick();
    await _settings.setSoundscape(soundscape);
    if (!_settings.isMusicEnabled) {
      await _settings.setMusic(true);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final currentSoundscape = _settings.soundscape;

    final soundscapes = [
      {
        'type': AudioSoundscape.lofi,
        'name': 'Lo-Fi Chill Synth',
        'desc': AppStrings.lofiDesc,
        'icon': '🎵',
        'color': GameTheme.neonCyan,
      },
      {
        'type': AudioSoundscape.cyber,
        'name': 'Cyberpunk Synthwave',
        'desc': AppStrings.cyberDesc,
        'icon': '⚡',
        'color': GameTheme.goldAccent,
      },
      {
        'type': AudioSoundscape.zen,
        'name': 'Zen Ambient Meditation',
        'desc': AppStrings.zenDesc,
        'icon': '🧘',
        'color': const Color(0xFF81C784),
      },
    ];

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      child: Container(
        constraints: BoxConstraints(maxHeight: screenHeight * 0.85),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: GameTheme.bgDark.withValues(alpha: 0.98),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: GameTheme.neonCyan, width: 2.0),
          boxShadow: [
            BoxShadow(
              color: GameTheme.neonCyan.withValues(alpha: 0.35),
              blurRadius: 28,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Top Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Text('📻', style: TextStyle(fontSize: 22)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.runicJukebox,
                              style: const TextStyle(
                                color: GameTheme.neonCyan,
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.1,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              AppStrings.proceduralSoundscapes,
                              style: const TextStyle(color: GameTheme.textMuted, fontSize: 10),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: GameTheme.bgDarkest,
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
            const SizedBox(height: 12),

            // 2. Animated Waveform & Master Play/Stop Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: GameTheme.bgDarkest,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _settings.isMusicEnabled ? GameTheme.neonCyan : GameTheme.gridBorder),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            _settings.isMusicEnabled ? '▶️ ÇALIYOR' : '⏸️ DURDURULDU',
                            style: TextStyle(
                              color: _settings.isMusicEnabled ? GameTheme.neonCyan : GameTheme.textMuted,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        value: _settings.isMusicEnabled,
                        onChanged: _toggleMusic,
                        activeThumbColor: GameTheme.neonCyan,
                        activeTrackColor: GameTheme.neonCyan.withValues(alpha: 0.3),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // 12 Animated Waveform Bars
                  SizedBox(
                    height: 38,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(_barHeights.length, (idx) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 90),
                          width: 8,
                          height: 38 * _barHeights[idx],
                          decoration: BoxDecoration(
                            color: _settings.isMusicEnabled
                                ? (idx % 2 == 0 ? GameTheme.neonCyan : GameTheme.goldAccent)
                                : Colors.white12,
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: _settings.isMusicEnabled
                                ? [
                                    BoxShadow(
                                      color: GameTheme.neonCyan.withValues(alpha: 0.4),
                                      blurRadius: 4,
                                    ),
                                  ]
                                : null,
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 3. Soundscapes Selection List
            Flexible(
              child: ListView(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                children: soundscapes.map((s) {
                  final type = s['type'] as AudioSoundscape;
                  final isCurrent = currentSoundscape == type && _settings.isMusicEnabled;
                  final color = s['color'] as Color;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isCurrent ? color.withValues(alpha: 0.15) : GameTheme.bgSurface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isCurrent ? color : GameTheme.gridBorder,
                        width: isCurrent ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: color.withValues(alpha: 0.2),
                            border: Border.all(color: color),
                          ),
                          alignment: Alignment.center,
                          child: Text(s['icon'] as String, style: const TextStyle(fontSize: 18)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s['name'] as String,
                                style: TextStyle(
                                  color: isCurrent ? color : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                s['desc'] as String,
                                style: const TextStyle(color: GameTheme.textMuted, fontSize: 9.5),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => _selectSoundscape(type),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isCurrent ? color : GameTheme.bgDarkest,
                            foregroundColor: isCurrent ? Colors.black : color,
                            side: BorderSide(color: color),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            minimumSize: const Size(60, 28),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text(
                            isCurrent ? AppStrings.playing : AppStrings.playSel,
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 9.5),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
