import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../core/storage/app_prefs.dart';

/// Manages player lives (energy/hearts), timer regeneration, and replenishment.
class LivesManager extends ChangeNotifier {
  static final LivesManager instance = LivesManager._();
  LivesManager._();

  static const int maxLives = 5;
  static const int regenMinutes = 15;

  int _currentLives = maxLives;
  DateTime? _lastRegenTime;
  Timer? _timer;

  int get currentLives => _currentLives;
  bool get isFull => _currentLives >= maxLives;
  bool get hasLives => _currentLives > 0;

  String get timeUntilNextLifeFormatted {
    if (isFull || _lastRegenTime == null) return 'FULL';
    final nextLifeTime = _lastRegenTime!.add(const Duration(minutes: regenMinutes));
    final remaining = nextLifeTime.difference(DateTime.now());
    if (remaining.isNegative) return '00:00';
    final mins = remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final secs = remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  AppPrefs get _p => AppPrefs.instance;

  Future<void> loadFromPrefs() async {
    await _p.init();
    _currentLives = _p.getInt(AppPrefs.kPlayerLives) ?? maxLives;
    final lastTimeStr = _p.getString(AppPrefs.kLastLivesRegen);
    if (lastTimeStr != null) {
      _lastRegenTime = DateTime.tryParse(lastTimeStr);
    } else {
      _lastRegenTime = DateTime.now();
    }

    _calculateOfflineRegen();
    _startTimer();
    notifyListeners();
  }

  void _calculateOfflineRegen() {
    if (_currentLives >= maxLives) {
      _lastRegenTime = DateTime.now();
      return;
    }

    if (_lastRegenTime != null) {
      final now = DateTime.now();
      final diffMinutes = now.difference(_lastRegenTime!).inMinutes;
      final recovered = diffMinutes ~/ regenMinutes;

      if (recovered > 0) {
        _currentLives = (_currentLives + recovered).clamp(0, maxLives);
        _lastRegenTime = _lastRegenTime!.add(Duration(minutes: recovered * regenMinutes));
        _saveToPrefs();
      }
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentLives < maxLives && _lastRegenTime != null) {
        final now = DateTime.now();
        if (now.difference(_lastRegenTime!).inMinutes >= regenMinutes) {
          _currentLives = (_currentLives + 1).clamp(0, maxLives);
          _lastRegenTime = now;
          _saveToPrefs();
          notifyListeners();
        } else {
          notifyListeners();
        }
      }
    });
  }

  Future<bool> consumeLife() async {
    if (_currentLives > 0) {
      _currentLives--;
      if (_currentLives == maxLives - 1) {
        _lastRegenTime = DateTime.now();
      }
      await _saveToPrefs();
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> refillLives() async {
    _currentLives = maxLives;
    _lastRegenTime = DateTime.now();
    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> addLives(int count) async {
    _currentLives = (_currentLives + count).clamp(0, maxLives + 5);
    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    await _p.setInt(AppPrefs.kPlayerLives, _currentLives);
    if (_lastRegenTime != null) {
      await _p.setString(AppPrefs.kLastLivesRegen, _lastRegenTime!.toIso8601String());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
