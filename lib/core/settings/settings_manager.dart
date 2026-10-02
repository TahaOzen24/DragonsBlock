import 'package:flutter/foundation.dart';
import '../audio/procedural_audio.dart';
import '../storage/app_prefs.dart';

enum HapticProfile {
  arcade,
  zen,
  cyber;

  String get displayName {
    switch (this) {
      case HapticProfile.arcade:
        return 'Arcade Tok 🎮';
      case HapticProfile.zen:
        return 'Zen İpeksi 🍃';
      case HapticProfile.cyber:
        return 'Cyber Keskin ⚡';
    }
  }

  String get shortName {
    switch (this) {
      case HapticProfile.arcade:
        return 'Arcade';
      case HapticProfile.zen:
        return 'Zen';
      case HapticProfile.cyber:
        return 'Cyber';
    }
  }

  String get emoji {
    switch (this) {
      case HapticProfile.arcade:
        return '🎮';
      case HapticProfile.zen:
        return '🍃';
      case HapticProfile.cyber:
        return '⚡';
    }
  }

  String get subtitle {
    switch (this) {
      case HapticProfile.arcade:
        return 'Dengeli & net vuruş hissi';
      case HapticProfile.zen:
        return 'Yumuşak & dinlendirici hafif tıklama';
      case HapticProfile.cyber:
        return 'Güçlü & keskin titreşim darbesi';
    }
  }
}

class SettingsManager extends ChangeNotifier {
  static final SettingsManager instance = SettingsManager._();
  SettingsManager._();

  bool _isSoundEnabled = true;
  bool _isMusicEnabled = true;
  bool _isHapticsEnabled = true;
  HapticProfile _hapticProfile = HapticProfile.arcade;
  bool _isScreenShakeEnabled = true;
  bool _isBatterySaver = false;
  AudioSoundscape _soundscape = AudioSoundscape.lofi;

  bool get isSoundEnabled => _isSoundEnabled;
  bool get isMusicEnabled => _isMusicEnabled;
  bool get isHapticsEnabled => _isHapticsEnabled;
  HapticProfile get hapticProfile => _hapticProfile;
  AudioSoundscape get soundscape => _soundscape;
  bool get isScreenShakeEnabled => _isScreenShakeEnabled;
  bool get isBatterySaver => _isBatterySaver;

  AppPrefs get _p => AppPrefs.instance;

  Future<void> loadSettings() async {
    await _p.init();
    _isSoundEnabled = _p.getBool(AppPrefs.kSettingSound) ?? true;
    _isMusicEnabled = _p.getBool(AppPrefs.kSettingMusic) ?? true;
    _isHapticsEnabled = _p.getBool(AppPrefs.kSettingHaptics) ?? true;
    final hapticIndex = _p.getInt(AppPrefs.kSettingHapticProfile) ?? 0;
    _hapticProfile = HapticProfile.values[hapticIndex.clamp(0, HapticProfile.values.length - 1)];
    final soundscapeIndex = _p.getInt(AppPrefs.kSettingSoundscape) ?? 0;
    _soundscape = AudioSoundscape.values[soundscapeIndex.clamp(0, AudioSoundscape.values.length - 1)];
    _isScreenShakeEnabled = _p.getBool(AppPrefs.kSettingScreenShake) ?? true;
    _isBatterySaver = _p.getBool(AppPrefs.kSettingBatterySaver) ?? false;

    ProceduralAudio.instance.isSoundEnabled = _isSoundEnabled;
    ProceduralAudio.instance.isMusicEnabled = _isMusicEnabled;
    ProceduralAudio.instance.isHapticsEnabled = _isHapticsEnabled;
    ProceduralAudio.instance.currentSoundscape = _soundscape;

    if (_isMusicEnabled) {
      ProceduralAudio.instance.startBackgroundMusic();
    }
    notifyListeners();
  }

  Future<void> setSound(bool value) async {
    _isSoundEnabled = value;
    ProceduralAudio.instance.isSoundEnabled = value;
    await _p.setBool(AppPrefs.kSettingSound, value);
    notifyListeners();
  }

  Future<void> setMusic(bool value) async {
    _isMusicEnabled = value;
    ProceduralAudio.instance.setMusic(value);
    await _p.setBool(AppPrefs.kSettingMusic, value);
    notifyListeners();
  }

  Future<void> setSoundscape(AudioSoundscape soundscape) async {
    _soundscape = soundscape;
    ProceduralAudio.instance.setSoundscape(soundscape);
    await _p.setInt(AppPrefs.kSettingSoundscape, soundscape.index);
    notifyListeners();
  }

  Future<void> setHaptics(bool value) async {
    _isHapticsEnabled = value;
    ProceduralAudio.instance.isHapticsEnabled = value;
    await _p.setBool(AppPrefs.kSettingHaptics, value);
    notifyListeners();
  }

  Future<void> setHapticProfile(HapticProfile profile) async {
    _hapticProfile = profile;
    await _p.setInt(AppPrefs.kSettingHapticProfile, profile.index);
    notifyListeners();
  }

  Future<void> setScreenShake(bool value) async {
    _isScreenShakeEnabled = value;
    await _p.setBool(AppPrefs.kSettingScreenShake, value);
    notifyListeners();
  }

  Future<void> setBatterySaver(bool value) async {
    _isBatterySaver = value;
    await _p.setBool(AppPrefs.kSettingBatterySaver, value);
    notifyListeners();
  }
}
