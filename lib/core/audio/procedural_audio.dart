import 'dart:math';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import '../haptics/haptic_service.dart';

enum AudioSoundscape {
  lofi,
  cyber,
  zen;

  String get displayName {
    switch (this) {
      case AudioSoundscape.lofi:
        return 'Lo-Fi ğŸµ';
      case AudioSoundscape.cyber:
        return 'Cyber âš¡';
      case AudioSoundscape.zen:
        return 'Zen ğŸ§˜';
    }
  }
}

class ProceduralAudio {
  static final ProceduralAudio instance = ProceduralAudio._();
  ProceduralAudio._() {
    _precacheSounds();
    initSoLoud();
  }

  bool isSoundEnabled = true;
  double masterVolume = 0.8;

  void setMasterVolume(double volume) {
    masterVolume = volume.clamp(0.0, 1.0);
  }
  bool isMusicEnabled = true;
  bool isHapticsEnabled = true;
  AudioSoundscape currentSoundscape = AudioSoundscape.lofi;

  // â”€â”€â”€ SoLoud C++ Low-Latency Engine State â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  bool _isSoLoudReady = false;
  AudioSource? _popSource;
  AudioSource? _placeSource;
  AudioSource? _allClearSource;
  final List<AudioSource> _comboSources = [];

  // â”€â”€â”€ AudioPlayers Fallback Pool â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  final List<AudioPlayer> _playerPool = [];
  int _playerIndex = 0;
  static const int _poolSize = 8;
  bool _playersInitialized = false;

  AudioPlayer? _musicPlayer;
  Uint8List? _bgmBytes;
  bool _isBgmPlaying = false;

  final Map<String, Uint8List> _soundCache = {};

  bool _isSoLoudInitializing = false;

  Future<void> initSoLoud() async {
    if (_isSoLoudReady || _isSoLoudInitializing) return;
    _isSoLoudInitializing = true;
    try {
      if (!SoLoud.instance.isInitialized) {
        await SoLoud.instance.init();
      }
      _isSoLoudReady = true;

      // Safe loader: catches any decode anomaly per-file without bubbling to ZonedGuarded
      Future<AudioSource?> safeLoad(String path) async {
        try {
          return await SoLoud.instance.loadAsset(path);
        } catch (e) {
          debugPrint('SoLoud loadAsset notice ($path): $e');
          return null;
        }
      }

      _popSource = await safeLoad('assets/audio/pop_juicy.wav');
      _placeSource = await safeLoad('assets/audio/place_wood.wav');
      _allClearSource = await safeLoad('assets/audio/all_clear.wav');

      for (int i = 1; i <= 10; i++) {
        final src = await safeLoad('assets/audio/combo_$i.wav');
        if (src != null) {
          _comboSources.add(src);
        }
      }
    } catch (e) {
      debugPrint('SoLoud init fallback to AudioPlayers: $e');
    } finally {
      _isSoLoudInitializing = false;
    }
  }

  void _initPlayers() {
    if (_playersInitialized) return;
    _playersInitialized = true;
    try {
      for (int i = 0; i < _poolSize; i++) {
        final player = AudioPlayer();
        player.setReleaseMode(ReleaseMode.stop);
        _playerPool.add(player);
      }
      _createMusicPlayer();
    } catch (e) {
      debugPrint('AudioPlayers pool init: $e');
    }
  }

  void _createMusicPlayer() {
    try {
      _musicPlayer?.dispose();
    } catch (e) {
      debugPrint('BGM dispose: $e');
    }
    try {
      _musicPlayer = AudioPlayer(playerId: 'dragons_block_bgm');
      _musicPlayer?.setReleaseMode(ReleaseMode.loop);
      _musicPlayer?.setVolume(0.32);
    } catch (e) {
      debugPrint('BGM create: $e');
    }
  }

  void _precacheSounds() {
    _soundCache['pickup'] = _generatePickupSound();
    _soundCache['place'] = _generatePlaceSound();
    _soundCache['explosion'] = _generateExplosionSound();
    _soundCache['powerup'] = _generatePowerUpSound();
    _soundCache['gameover'] = _generateGameOverSound();
    _soundCache['perfect'] = _generatePerfectSweepSound();
    _soundCache['btn_click'] = _generateButtonClickSound();
    _soundCache['dialog_pop'] = _generateDialogPopSound();
    _soundCache['tab_switch'] = _generateTabSwitchSound();
    _soundCache['purchase'] = _generatePurchaseSound();
    _soundCache['levelup'] = _generateLevelUpSound();
    _soundCache['quest_complete'] = _generateQuestCompleteSound();
    _soundCache['multiline_2'] = _generateMultiLineSound(2);
    _soundCache['multiline_3'] = _generateMultiLineSound(3);
    _soundCache['multiline_4'] = _generateMultiLineSound(4);

    for (int i = 1; i <= 15; i++) {
      _soundCache['combo_$i'] = _generateComboSound(i);
    }

    _bgmBytes = _generateBgmLoop(currentSoundscape);
  }

  // â”€â”€â”€ Background Music (BGM) Engine â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  void setMusic(bool value) {
    isMusicEnabled = value;
    if (value) {
      startBackgroundMusic();
    } else {
      stopBackgroundMusic();
    }
  }

  void setSoundscape(AudioSoundscape soundscape) {
    currentSoundscape = soundscape;
    _bgmBytes = _generateBgmLoop(soundscape);
    if (isMusicEnabled && _isBgmPlaying) {
      startBackgroundMusic();
    }
  }

  Future<void> startBackgroundMusic() async {
    if (!isMusicEnabled) return;
    _initPlayers();
    if (_musicPlayer == null) _createMusicPlayer();
    if (_musicPlayer == null) return;

    try {
      if (_musicPlayer?.state == PlayerState.playing) return;
      _bgmBytes ??= _generateBgmLoop(currentSoundscape);
      if (_bgmBytes != null) {
        await _musicPlayer!.setReleaseMode(ReleaseMode.loop);
        await _musicPlayer!.setVolume(0.32);
        await _musicPlayer!.play(BytesSource(_bgmBytes!));
        _isBgmPlaying = true;
      }
    } catch (e) {
      // Re-create player on Android native state machine error
      _createMusicPlayer();
      try {
        _bgmBytes ??= _generateBgmLoop(currentSoundscape);
        if (_bgmBytes != null && _musicPlayer != null) {
          await _musicPlayer!.play(BytesSource(_bgmBytes!));
          _isBgmPlaying = true;
        }
      } catch (_) {}
    }
  }

  Future<void> stopBackgroundMusic() async {
    try {
      if (_musicPlayer?.state == PlayerState.playing) {
        await _musicPlayer?.stop();
      }
      _isBgmPlaying = false;
    } catch (_) {}
  }

  Future<void> pauseBackgroundMusic() async {
    if (!_isBgmPlaying) return;
    try {
      await _musicPlayer?.pause();
    } catch (_) {}
  }

  Future<void> resumeBackgroundMusic() async {
    if (!_isBgmPlaying || !isMusicEnabled) return;
    try {
      await _musicPlayer?.resume();
    } catch (_) {}
  }

  void stopAllSfx() {
    for (final player in _playerPool) {
      try {
        if (player.state == PlayerState.playing) {
          player.stop();
        }
      } catch (_) {}
    }
  }

  /// Call this from a WidgetsBindingObserver when the app lifecycle changes.
  void handleAppLifecycle(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      pauseBackgroundMusic();
      stopAllSfx();
    } else if (state == AppLifecycleState.detached) {
      stopBackgroundMusic();
      stopAllSfx();
    } else if (state == AppLifecycleState.resumed) {
      resumeBackgroundMusic();
    }
  }

  // â”€â”€â”€ SFX Player Dispatcher (Ultra Low Latency) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  void _playSound(Uint8List? bytes, {double volume = 1.0}) {
    if (!isSoundEnabled || bytes == null) return;
    _initPlayers();
    if (_playerPool.isEmpty) return;

    try {
      final player = _playerPool[_playerIndex];
      _playerIndex = (_playerIndex + 1) % _poolSize;
      player.setVolume((volume * masterVolume).clamp(0.0, 1.0));
      player.play(BytesSource(bytes));
    } catch (_) {}
  }

  void playPickup() {
    AppHaptics.blockPickup();
    // Sound on pickup removed per user request (zero audio distraction when touching shapes)
  }

  void playPlace() {
    AppHaptics.blockPlace();
    if (!isSoundEnabled) return;
    if (_isSoLoudReady && _placeSource != null) {
      final microPitch = 0.98 + Random().nextDouble() * 0.04;
      SoLoud.instance.play(_placeSource!, volume: 0.98).then((handle) {
        try {
          SoLoud.instance.setRelativePlaySpeed(handle, microPitch);
        } catch (_) {}
      });
    } else {
      _playSound(_soundCache['place'], volume: 0.98);
    }
  }

  void playComboTone(int comboIndex) {
    final int safeIndex = comboIndex.clamp(1, 20);
    AppHaptics.combo(safeIndex);
    if (!isSoundEnabled) return;
    if (_isSoLoudReady && _comboSources.isNotEmpty) {
      if (safeIndex <= _comboSources.length) {
        SoLoud.instance.play(_comboSources[safeIndex - 1], volume: 0.98);
      } else {
        final lastSrc = _comboSources.last;
        final extraSteps = safeIndex - _comboSources.length;
        final speed = pow(2.0, (extraSteps * 2) / 12.0).toDouble();
        SoLoud.instance.play(lastSrc, volume: 0.98).then((handle) {
          try {
            SoLoud.instance.setRelativePlaySpeed(handle, speed);
          } catch (_) {}
        });
      }
    } else {
      final int clampedIndex = safeIndex.clamp(1, 15);
      _playSound(_soundCache['combo_$clampedIndex'], volume: 0.98);
    }
  }

  void playMultiLineClear(int linesCount) {
    AppHaptics.lineClear(linesCount);
    if (!isSoundEnabled) return;
    if (linesCount >= 4) {
      _playSound(_soundCache['multiline_4'], volume: 0.98);
    } else if (linesCount == 3) {
      _playSound(_soundCache['multiline_3'], volume: 0.98);
    } else if (linesCount == 2) {
      _playSound(_soundCache['multiline_2'], volume: 0.98);
    }
  }

  /// Extremely satisfying, juicy block pop & tactile thump (< 3ms latency via SoLoud).
  void playExplosion() {
    AppHaptics.lineClear(1);
    if (!isSoundEnabled) return;
    if (_isSoLoudReady && _popSource != null) {
      SoLoud.instance.play(_popSource!, volume: 0.98);
    } else {
      _playSound(_soundCache['explosion'], volume: 0.98);
    }
  }

  void playFrost() => playPowerUpUsed();
  void playLightning() => playPowerUpUsed();
  void playVoid() => playPowerUpUsed();
  void playFire() => playExplosion();
  void playGold() => playPurchase();

  void playButtonClick() {
    AppHaptics.selection();
    _playSound(_soundCache['btn_click'], volume: 0.75);
  }

  void playDialogPop() {
    AppHaptics.selection();
    _playSound(_soundCache['dialog_pop'], volume: 0.75);
  }

  void playTabSwitch() {
    AppHaptics.selection();
    _playSound(_soundCache['tab_switch'], volume: 0.75);
  }

  void playPurchase() {
    AppHaptics.medium();
    _playSound(_soundCache['purchase'], volume: 0.90);
  }

  void playLevelUp() {
    AppHaptics.heavy();
    _playSound(_soundCache['levelup'], volume: 0.95);
  }

  void playQuestComplete() {
    AppHaptics.medium();
    _playSound(_soundCache['quest_complete'], volume: 0.90);
  }

  void playPowerUpUsed() {
    AppHaptics.medium();
    _playSound(_soundCache['powerup'], volume: 0.90);
  }

  void playRewardClaim() {
    AppHaptics.heavy();
    _playSound(_soundCache['purchase'], volume: 0.90);
  }

  void playPerfectSweep() {
    AppHaptics.ultimate();
    if (!isSoundEnabled) return;
    if (_isSoLoudReady && _allClearSource != null) {
      SoLoud.instance.play(_allClearSource!, volume: 1.0);
    } else {
      _playSound(_soundCache['perfect'], volume: 1.0);
    }
  }

  void playGameOver() {
    AppHaptics.gameOver();
    _playSound(_soundCache['gameover'], volume: 0.90);
  }

  // â”€â”€â”€ Procedural Sound Synthesizers (Studio Quality, Zero Radio Static) â”€â”€â”€â”€â”€

  // 1. Pickup: Gentle, soothing acoustic bubble droplet
  static Uint8List _generatePickupSound() {
    const int sampleRate = 22050;
    const double duration = 0.055;
    final int totalSamples = (sampleRate * duration).round();
    final List<double> samples = List.filled(totalSamples, 0.0);

    for (int i = 0; i < totalSamples; i++) {
      final double t = i / totalSamples;
      final double carrier = 480.0 + (t * 440.0); // 480Hz -> 920Hz smooth sweep
      final double env = exp(-t * 20.0);
      final double val = sin(2 * pi * carrier * (i / sampleRate));
      samples[i] = val * env * 0.90;
    }
    return _createWav(samples, sampleRate: sampleRate);
  }

  // 2. Place: Punchy, warm, tactile Block Blast candy-wood pop
  static Uint8List _generatePlaceSound() {
    const int sampleRate = 22050;
    const double duration = 0.058; // 58ms crisp pop
    final int totalSamples = (sampleRate * duration).round();
    final List<double> samples = List.filled(totalSamples, 0.0);

    for (int i = 0; i < totalSamples; i++) {
      final double t = i / totalSamples;

      // Layer 1: Warm low-mid physical body (240Hz down to 135Hz with fast punch)
      final double bodyFreq = 240.0 * exp(-t * 10.0);
      final double body = sin(2 * pi * bodyFreq * (i / sampleRate)) * 0.82;

      // Layer 2: Organic candy bubble resonance (380Hz down to 240Hz)
      final double bubbleFreq = 380.0 * exp(-t * 14.0);
      final double bubble = sin(2 * pi * bubbleFreq * (i / sampleRate)) * 0.38;

      // Layer 3: Crisp tactile mallet tap (first 5ms transient)
      final double click = sin(2 * pi * 680.0 * (i / sampleRate)) * exp(-t * 45.0) * 0.28;

      final double env = exp(-t * 14.0);
      final double attack = (t < 0.002 ? t / 0.002 : 1.0);

      final double raw = (body + bubble + click) * env * attack;
      // Soft saturation for maximum clear loudness without clipping
      samples[i] = (raw / (1.0 + raw.abs() * 0.12)).clamp(-0.98, 0.98);
    }
    return _createWav(samples, sampleRate: sampleRate);
  }

  // 3. Combo Chimes: Ultra-satisfying celesta + bell shimmer progression
  static Uint8List _generateComboSound(int comboIndex) {
    const int sampleRate = 22050;
    const double duration = 0.44; // 440ms lingering resonance
    final int totalSamples = (sampleRate * duration).round();
    final List<double> samples = List.filled(totalSamples, 0.0);

    final List<double> diatonicFrequencies = [
      523.25, // 1: C5
      587.33, // 2: D5
      659.25, // 3: E5
      698.46, // 4: F5
      783.99, // 5: G5
      880.00, // 6: A5
      987.77, // 7: B5
      1046.50, // 8: C6
      1174.66, // 9: D6
      1318.51, // 10: E6
      1396.91, // 11: F6
      1567.98, // 12: G6
      1760.00, // 13: A6
      1975.53, // 14: B6
      2093.00, // 15: C7
    ];

    final double baseFreq = diatonicFrequencies[(comboIndex - 1).clamp(0, diatonicFrequencies.length - 1)];

    for (int i = 0; i < totalSamples; i++) {
      final double t = i / totalSamples;
      final double env = exp(-t * 4.8);
      final double attack = (t < 0.003 ? t / 0.003 : 1.0);

      // Layer 1: Warm fundamental chime
      final double fund = sin(2 * pi * baseFreq * (i / sampleRate)) * 0.65;
      // Layer 2: Octave overtone (bright bell shimmer)
      final double octave = sin(2 * pi * (baseFreq * 2.0) * (i / sampleRate)) * 0.35 * exp(-t * 6.0);
      // Layer 3: Fifth harmonic (rich celestial sparkle)
      final double fifth = sin(2 * pi * (baseFreq * 1.5) * (i / sampleRate)) * 0.20 * exp(-t * 7.5);
      // Layer 4: High sparkle 3rd harmonic
      final double sparkle = sin(2 * pi * (baseFreq * 3.0) * (i / sampleRate)) * 0.12 * exp(-t * 9.0);
      // Layer 5: Warm marimba wooden transient (first 8ms)
      final double mallet = sin(2 * pi * (baseFreq * 0.5) * (i / sampleRate)) * exp(-t * 28.0) * 0.30;

      final double raw = (fund + octave + fifth + sparkle + mallet) * env * attack;
      samples[i] = (raw / (1.0 + raw.abs() * 0.15)).clamp(-0.98, 0.98);
    }
    return _createWav(samples, sampleRate: sampleRate);
  }

  // 4. Multi-Line Clear Chords: Shimmering crystal major chords with warm bass
  static Uint8List _generateMultiLineSound(int lines) {
    const int sampleRate = 22050;
    const double duration = 0.45;
    final int totalSamples = (sampleRate * duration).round();
    final List<double> samples = List.filled(totalSamples, 0.0);

    List<double> chordFreqs = [];
    if (lines == 2) {
      chordFreqs = [523.25, 659.25, 783.99]; // C5, E5, G5
    } else if (lines == 3) {
      chordFreqs = [523.25, 659.25, 783.99, 1046.50]; // C5, E5, G5, C6
    } else {
      chordFreqs = [523.25, 659.25, 783.99, 1046.50, 1318.51, 1567.98]; // C5, E5, G5, C6, E6, G6
    }

    for (int i = 0; i < totalSamples; i++) {
      final double t = i / totalSamples;
      final double subBass = sin(2 * pi * (95.0 * exp(-t * 6.0)) * (i / sampleRate)) * exp(-t * 8.0) * 0.40;

      double chimeVal = 0.0;
      for (int c = 0; c < chordFreqs.length; c++) {
        final double noteDelay = c * 0.024;
        if (t >= noteDelay) {
          final double noteT = (t - noteDelay) / (1.0 - noteDelay);
          final double noteEnv = exp(-noteT * 5.0);
          final double f = chordFreqs[c];
          chimeVal += (sin(2 * pi * f * (i / sampleRate)) * 0.55 +
                  sin(2 * pi * (f * 2.0) * (i / sampleRate)) * 0.20) *
              noteEnv /
              chordFreqs.length;
        }
      }

      final double raw = subBass + chimeVal * 0.85;
      samples[i] = (raw / (1.0 + raw.abs() * 0.2)).clamp(-0.98, 0.98);
    }
    return _createWav(samples, sampleRate: sampleRate);
  }

  // 5. Line Clear / Block Blast: Enhanced juicy tactile pop & sub thump
  static Uint8List _generateExplosionSound() {
    const int sampleRate = 22050;
    const double duration = 0.32;
    final int totalSamples = (sampleRate * duration).round();
    final List<double> samples = List.filled(totalSamples, 0.0);

    for (int i = 0; i < totalSamples; i++) {
      final double t = i / totalSamples;

      // 1. Deep Sub-Punch: 130Hz -> 50Hz (satisfying physical thud)
      final double subFreq = 130.0 * exp(-t * 8.0);
      final double subWave = sin(2 * pi * subFreq * (i / sampleRate)) * exp(-t * 7.0) * 0.65;

      // 2. Juicy Candy Pop: 420Hz -> 260Hz
      final double popFreq = 420.0 * exp(-t * 12.0);
      final double popWave = sin(2 * pi * popFreq * (i / sampleRate)) * exp(-t * 14.0) * 0.45;

      // 3. Mallet Glass Tone (D5 + A5)
      final double mallet1 = sin(2 * pi * 587.33 * (i / sampleRate)) * 0.35;
      final double mallet2 = sin(2 * pi * 880.00 * (i / sampleRate)) * 0.20;
      final double malletEnv = exp(-t * 16.0);

      // 4. Crisp Transient Click
      final double click = sin(2 * pi * 2400.0 * (i / sampleRate)) * exp(-t * 60.0) * 0.25;

      final double raw = subWave + popWave + ((mallet1 + mallet2) * malletEnv) + click;
      samples[i] = (raw / (1.0 + raw.abs() * 0.20)).clamp(-0.98, 0.98);
    }
    return _createWav(samples, sampleRate: sampleRate);
  }

  // 6. Button Click
  static Uint8List _generateButtonClickSound() {
    const int sampleRate = 22050;
    const double duration = 0.035;
    final int totalSamples = (sampleRate * duration).round();
    final List<double> samples = List.filled(totalSamples, 0.0);

    for (int i = 0; i < totalSamples; i++) {
      final double t = i / totalSamples;
      final double f = 880.0 * exp(-t * 25.0);
      final double env = exp(-t * 35.0);
      samples[i] = sin(2 * pi * f * (i / sampleRate)) * env * 0.95;
    }
    return _createWav(samples, sampleRate: sampleRate);
  }

  // 7. Dialog Pop
  static Uint8List _generateDialogPopSound() {
    const int sampleRate = 22050;
    const double duration = 0.07;
    final int totalSamples = (sampleRate * duration).round();
    final List<double> samples = List.filled(totalSamples, 0.0);

    for (int i = 0; i < totalSamples; i++) {
      final double t = i / totalSamples;
      final double f = 400.0 + (t * 600.0);
      final double env = exp(-t * 18.0);
      samples[i] = sin(2 * pi * f * (i / sampleRate)) * env * 0.95;
    }
    return _createWav(samples, sampleRate: sampleRate);
  }

  // 8. Tab Switch
  static Uint8List _generateTabSwitchSound() {
    const int sampleRate = 22050;
    const double duration = 0.04;
    final int totalSamples = (sampleRate * duration).round();
    final List<double> samples = List.filled(totalSamples, 0.0);

    for (int i = 0; i < totalSamples; i++) {
      final double t = i / totalSamples;
      final double f = 660.0 + (t * 300.0);
      final double env = exp(-t * 30.0);
      samples[i] = sin(2 * pi * f * (i / sampleRate)) * env * 0.90;
    }
    return _createWav(samples, sampleRate: sampleRate);
  }

  // 9. Purchase / Reward
  static Uint8List _generatePurchaseSound() {
    const int sampleRate = 22050;
    const double duration = 0.35;
    final int totalSamples = (sampleRate * duration).round();
    final List<double> samples = List.filled(totalSamples, 0.0);

    final List<double> notes = [587.33, 880.00, 1174.66]; // D5, A5, D6
    final int noteLen = (totalSamples / notes.length).round();

    for (int i = 0; i < totalSamples; i++) {
      final int noteIdx = (i / noteLen).floor().clamp(0, notes.length - 1);
      final double freq = notes[noteIdx];
      final double noteT = (i % noteLen) / noteLen;
      final double env = exp(-noteT * 6.0);
      samples[i] = sin(2 * pi * freq * (i / sampleRate)) * env * 0.95;
    }
    return _createWav(samples, sampleRate: sampleRate);
  }

  // 10. Level Up
  static Uint8List _generateLevelUpSound() {
    const int sampleRate = 22050;
    const double duration = 0.45;
    final int totalSamples = (sampleRate * duration).round();
    final List<double> samples = List.filled(totalSamples, 0.0);

    final List<double> notes = [523.25, 659.25, 783.99, 1046.50]; // C5, E5, G5, C6
    final int noteLen = (totalSamples / notes.length).round();

    for (int i = 0; i < totalSamples; i++) {
      final int noteIdx = (i / noteLen).floor().clamp(0, notes.length - 1);
      final double freq = notes[noteIdx];
      final double noteT = (i % noteLen) / noteLen;
      final double env = exp(-noteT * 5.0);
      samples[i] = sin(2 * pi * freq * (i / sampleRate)) * env * 0.95;
    }
    return _createWav(samples, sampleRate: sampleRate);
  }

  // 11. Quest Complete
  static Uint8List _generateQuestCompleteSound() {
    const int sampleRate = 22050;
    const double duration = 0.38;
    final int totalSamples = (sampleRate * duration).round();
    final List<double> samples = List.filled(totalSamples, 0.0);

    final List<double> notes = [659.25, 783.99, 1046.50]; // E5, G5, C6
    final int noteLen = (totalSamples / notes.length).round();

    for (int i = 0; i < totalSamples; i++) {
      final int noteIdx = (i / noteLen).floor().clamp(0, notes.length - 1);
      final double freq = notes[noteIdx];
      final double noteT = (i % noteLen) / noteLen;
      final double env = exp(-noteT * 5.5);
      samples[i] = sin(2 * pi * freq * (i / sampleRate)) * env * 0.95;
    }
    return _createWav(samples, sampleRate: sampleRate);
  }

  // 12. Power Up
  static Uint8List _generatePowerUpSound() {
    const int sampleRate = 22050;
    const double duration = 0.28;
    final int totalSamples = (sampleRate * duration).round();
    final List<double> samples = List.filled(totalSamples, 0.0);

    for (int i = 0; i < totalSamples; i++) {
      final double t = i / totalSamples;
      final double f = 300.0 + (t * 800.0);
      final double env = exp(-t * 7.0);
      samples[i] = sin(2 * pi * f * (i / sampleRate)) * env * 0.95;
    }
    return _createWav(samples, sampleRate: sampleRate);
  }

  // 13. Game Over
  static Uint8List _generateGameOverSound() {
    const int sampleRate = 22050;
    const double duration = 0.70;
    final int totalSamples = (sampleRate * duration).round();
    final List<double> samples = List.filled(totalSamples, 0.0);

    for (int i = 0; i < totalSamples; i++) {
      final double t = i / totalSamples;
      final double freq = 260.0 * (1.0 - t * 0.65);
      final double env = exp(-t * 3.5);
      samples[i] = sin(2 * pi * freq * (i / sampleRate)) * env * 0.95;
    }
    return _createWav(samples, sampleRate: sampleRate);
  }

  // 14. Perfect Sweep Fanfare (Majestic Triumphant Chord)
  static Uint8List _generatePerfectSweepSound() {
    const int sampleRate = 22050;
    const double duration = 0.65;
    final int totalSamples = (sampleRate * duration).round();
    final List<double> samples = List.filled(totalSamples, 0.0);

    final List<double> notes = [523.25, 659.25, 783.99, 1046.50, 1318.51, 1567.98]; // C5 to G6
    final int noteLen = (totalSamples / notes.length).round();

    for (int i = 0; i < totalSamples; i++) {
      final int noteIdx = (i / noteLen).floor().clamp(0, notes.length - 1);
      final double freq = notes[noteIdx];
      final double noteT = (i % noteLen) / noteLen;
      final double env = exp(-noteT * 3.8);

      final double sub = sin(2 * pi * 80.0 * (i / sampleRate)) * exp(-i / totalSamples * 5.0) * 0.35;
      final double tone = sin(2 * pi * freq * (i / sampleRate)) * env * 0.65;
      samples[i] = (sub + tone).clamp(-0.95, 0.95);
    }
    return _createWav(samples, sampleRate: sampleRate);
  }

  // â”€â”€â”€ Procedural Background Ambient Music (BGM) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  static Uint8List _generateBgmLoop([AudioSoundscape soundscape = AudioSoundscape.lofi]) {
    const int sampleRate = 22050;
    const double duration = 12.0; // 12-second seamless loop
    final int totalSamples = (sampleRate * duration).round();
    final List<double> samples = List.filled(totalSamples, 0.0);

    List<double> rootNotes;
    switch (soundscape) {
      case AudioSoundscape.lofi:
        rootNotes = [261.63, 329.63, 392.00, 349.23]; // C4, E4, G4, F4
        break;
      case AudioSoundscape.cyber:
        rootNotes = [220.00, 261.63, 293.66, 329.63]; // A3, C4, D4, E4
        break;
      case AudioSoundscape.zen:
        rootNotes = [196.00, 220.00, 261.63, 293.66]; // G3, A3, C4, D4
        break;
    }

    final double barDuration = duration / rootNotes.length;

    for (int i = 0; i < totalSamples; i++) {
      final double t = i / sampleRate;
      final int barIdx = (t / barDuration).floor().clamp(0, rootNotes.length - 1);
      final double rootFreq = rootNotes[barIdx];
      final double barT = (t % barDuration) / barDuration;

      // Warm pad chord
      final double pad1 = sin(2 * pi * rootFreq * t);
      final double pad2 = sin(2 * pi * (rootFreq * 1.5) * t) * 0.60;
      final double pad3 = sin(2 * pi * (rootFreq * 2.0) * t) * 0.30;
      final double padEnv = (sin(barT * pi)).clamp(0.0, 1.0);

      // Gentle sub-bass pulse
      final double bassFreq = rootFreq * 0.5;
      final double bass = sin(2 * pi * bassFreq * t) * 0.40 * (sin(barT * pi * 2).abs());

      // Relaxing ethereal crystal shimmer (subtle Zen bell accent)
      final double crystal = soundscape == AudioSoundscape.zen
          ? sin(2 * pi * (rootFreq * 4.0) * t) * 0.09 * exp(-barT * 4.5)
          : 0.0;

      final double mixed = (pad1 + pad2 + pad3) * padEnv * 0.15 + bass * 0.18 + crystal;
      samples[i] = mixed.clamp(-0.95, 0.95);
    }

    return _createWav(samples, sampleRate: sampleRate);
  }

  // â”€â”€â”€ WAV File Header Generator â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  static Uint8List _createWav(List<double> samples, {required int sampleRate}) {
    final int numSamples = samples.length;
    final int byteRate = sampleRate * 2; // 16-bit mono
    final int blockAlign = 2;
    final int subChunk2Size = numSamples * 2;
    final int chunkSize = 36 + subChunk2Size;

    final ByteData byteData = ByteData(44 + subChunk2Size);

    // RIFF chunk descriptor
    byteData.setUint8(0, 0x52); // 'R'
    byteData.setUint8(1, 0x49); // 'I'
    byteData.setUint8(2, 0x46); // 'F'
    byteData.setUint8(3, 0x46); // 'F'
    byteData.setUint32(4, chunkSize, Endian.little);
    byteData.setUint8(8, 0x57);  // 'W'
    byteData.setUint8(9, 0x41);  // 'A'
    byteData.setUint8(10, 0x56); // 'V'
    byteData.setUint8(11, 0x45); // 'E'

    // "fmt " sub-chunk
    byteData.setUint8(12, 0x66); // 'f'
    byteData.setUint8(13, 0x6D); // 'm'
    byteData.setUint8(14, 0x74); // 't'
    byteData.setUint8(15, 0x20); // ' '
    byteData.setUint32(16, 16, Endian.little); // Subchunk1Size (16 for PCM)
    byteData.setUint16(20, 1, Endian.little);  // AudioFormat (1 for PCM)
    byteData.setUint16(22, 1, Endian.little);  // NumChannels (1 = mono)
    byteData.setUint32(24, sampleRate, Endian.little);
    byteData.setUint32(28, byteRate, Endian.little);
    byteData.setUint16(32, blockAlign, Endian.little);
    byteData.setUint16(34, 16, Endian.little); // BitsPerSample (16)

    // "data" sub-chunk
    byteData.setUint8(36, 0x64); // 'd'
    byteData.setUint8(37, 0x61); // 'a'
    byteData.setUint8(38, 0x74); // 't'
    byteData.setUint8(39, 0x61); // 'a'
    byteData.setUint32(40, subChunk2Size, Endian.little);

    // Audio PCM samples (16-bit signed integer)
    int offset = 44;
    for (int i = 0; i < numSamples; i++) {
      final int sample = (samples[i].clamp(-1.0, 1.0) * 32767).toInt();
      byteData.setInt16(offset, sample, Endian.little);
      offset += 2;
    }

    return byteData.buffer.asUint8List();
  }
}

