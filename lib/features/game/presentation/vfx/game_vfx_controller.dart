import 'dart:async';
import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import '../../../../core/config/game_config.dart';
import '../../../../core/haptics/haptic_service.dart';
import '../../../../core/particles/particle_system.dart';
import '../../../../core/theme/game_theme.dart';
import '../../../../core/vfx/screen_shake.dart';
import '../../../dragon/models/dragon.dart';
import '../../logic/grid_engine.dart';
import '../../models/block_skin_style.dart';
import '../../models/clearing_animation.dart';
import 'game_board_geometry.dart';

/// Clear / surge / stinger / flash / frenzy / confetti animasyonları.
class GameVfxController {
  GameVfxController({
    required TickerProvider vsync,
    required this.onChanged,
    required this.geometry,
    required this.particles,
    required this.shake,
    required this.onFrenzyExpired,
  }) {
    worldMorphController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 550),
    )..value = 1.0;

    boardRevealController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 600),
    )..addListener(() {
        boardRevealProgress = boardRevealController.value;
        onChanged();
      });

    confettiController = ConfettiController(duration: const Duration(seconds: 2));

    realmMorphController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 2400),
    );

    tickerController = AnimationController(
      vsync: vsync,
      duration: const Duration(seconds: 1),
    )..addListener(_onTickerTick);

    clearController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 440),
    )
      ..addListener(_onClearTick)
      ..addStatusListener(_onClearStatus);

    screenFlashController = AnimationController(
      vsync: vsync,
      value: 1.0,
      duration: const Duration(milliseconds: 100),
    );
  }

  final VoidCallback onChanged;
  final GameBoardGeometry geometry;
  final ParticleSystem particles;
  final ScreenShakeController shake;
  final VoidCallback onFrenzyExpired;

  late final AnimationController tickerController;
  late final AnimationController clearController;
  late final AnimationController screenFlashController;
  late final AnimationController worldMorphController;
  late final AnimationController boardRevealController;
  late final AnimationController realmMorphController;
  late final ConfettiController confettiController;

  final List<ClearingCellAnim> clearingCells = [];
  final List<ClearingLineSlice> clearingLineSlices = [];
  double allClearSurgeProgress = 0.0;
  bool hasAllClearCrest = false;
  String? stingerText;
  Color stingerColor = GameTheme.goldAccent;
  Color screenFlashColor = Colors.white;
  double frenzyProgress = 0.0;
  double boardRevealProgress = 0.0;
  List<Point<int>> recentlyPlacedCells = [];
  double placementFlashProgress = 0.0;

  Timer? _stingerTimer;
  Timer? _frenzyTimer;
  Timer? _clearAnimTimer;
  Timer? _allClearTimer;
  double _frenzyTotalDurationMs = 0.0;
  double _lastFrenzyMultiplier = 1.0;

  void start() {
    boardRevealController.forward();
    tickerController.repeat();
  }

  void pauseLoops() {
    tickerController.stop();
    _frenzyTimer?.cancel();
  }

  void resumeLoops({required bool gameActive}) {
    if (!gameActive) return;
    tickerController.repeat();
    resumeFrenzyTimer();
  }

  void stopOnPop() {
    tickerController.stop();
    _frenzyTimer?.cancel();
    _clearAnimTimer?.cancel();
  }

  void _onTickerTick() {
    particles.update();
    if (placementFlashProgress > 0.0) {
      placementFlashProgress = (placementFlashProgress * 0.82).clamp(0.0, 1.0);
      if (placementFlashProgress < 0.02) {
        placementFlashProgress = 0.0;
        recentlyPlacedCells.clear();
      }
    }
  }

  void _onClearTick() {
    final p = clearController.value;
    for (final c in clearingCells) {
      c.progress = p;
    }
    for (final s in clearingLineSlices) {
      s.progress = (p * 1.35).clamp(0.0, 1.0);
    }
  }

  void _onClearStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      clearingCells.clear();
      clearingLineSlices.clear();
      onChanged();
    }
  }

  void markPlacementFlash(List<Point<int>> placedPoints) {
    recentlyPlacedCells = placedPoints;
    placementFlashProgress = 1.0;
  }

  void triggerClearingAnimation({
    required List<ClearedCellInfo> cellDetails,
    required List<int> clearedRows,
    required List<int> clearedCols,
    required Color fallbackColor,
    required BlockSkinStyle blockSkinStyle,
    required DragonEggType dragonType,
    required Color dragonThemeColor,
    int linesCleared = 1,
    int comboStreak = 0,
    bool isDragonPower = false,
  }) {
    clearingCells.clear();
    clearingLineSlices.clear();

    final ClearVfxStyle chosenVfx;
    if (isDragonPower) {
      chosenVfx = ClearVfxStyle.dragonElemental;
    } else if (linesCleared >= 4 || comboStreak >= 5) {
      chosenVfx = ClearVfxStyle.supernova;
    } else if (linesCleared >= 2 || comboStreak >= 3) {
      chosenVfx = ClearVfxStyle.laserVaporize;
    } else {
      chosenVfx = ClearVfxStyle.candyPop;
    }

    final double originR = clearedRows.isNotEmpty ? clearedRows.first.toDouble() : 3.5;
    final double originC = clearedCols.isNotEmpty ? clearedCols.first.toDouble() : 3.5;

    for (final info in cellDetails) {
      final double delay;
      if (clearedRows.isNotEmpty && clearedCols.isEmpty) {
        final distFromCenter = (info.pos.y - 3.5).abs();
        delay = (distFromCenter / 3.5 * 0.26).clamp(0.0, 0.26);
      } else if (clearedCols.isNotEmpty && clearedRows.isEmpty) {
        final distFromCenter = (info.pos.x - 3.5).abs();
        delay = (distFromCenter / 3.5 * 0.26).clamp(0.0, 0.26);
      } else {
        final dist = sqrt(pow(info.pos.x - originR, 2) + pow(info.pos.y - originC, 2));
        delay = (dist / 8.0 * 0.30).clamp(0.0, 0.30);
      }

      clearingCells.add(ClearingCellAnim(
        r: info.pos.x,
        c: info.pos.y,
        color: info.color,
        style: blockSkinStyle,
        vfxStyle: chosenVfx,
        dragonType: dragonType,
        elementalColor: dragonThemeColor,
        delayNormalized: delay,
        progress: 0.0,
      ));
    }

    for (final r in clearedRows) {
      final cellCenter = geometry.cellCenter(r, 3);
      particles.spawnBlockShatter(
        cellCenter.dx,
        cellCenter.dy,
        fallbackColor,
        style: blockSkinStyle,
      );
    }
    for (final c in clearedCols) {
      final cellCenter = geometry.cellCenter(3, c);
      particles.spawnBlockShatter(
        cellCenter.dx,
        cellCenter.dy,
        fallbackColor,
        style: blockSkinStyle,
      );
    }

    for (final r in clearedRows) {
      clearingLineSlices.add(ClearingLineSlice(
        isRow: true,
        index: r,
        color: fallbackColor,
        progress: 0.0,
      ));
    }
    for (final c in clearedCols) {
      clearingLineSlices.add(ClearingLineSlice(
        isRow: false,
        index: c,
        color: fallbackColor,
        progress: 0.0,
      ));
    }

    final totalLines = clearedRows.length + clearedCols.length;
    if (totalLines >= 2) {
      final center = geometry.gridCenter();
      particles.spawnExplosion(center.dx, center.dy, GameTheme.goldAccent, count: 14);
    }

    _clearAnimTimer?.cancel();
    onChanged();

    if (totalLines >= 3) {
      AppHaptics.heavy();
      shake.trigger(intensity: 3.5, trauma: 0.35);
    }
    clearController.forward(from: 0.0);
  }

  void triggerAllClearSurge() {
    hasAllClearCrest = true;
    _allClearTimer?.cancel();
    int elapsedMs = 0;
    const totalMs = 600;
    _allClearTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      elapsedMs += 16;
      allClearSurgeProgress = (elapsedMs / totalMs).clamp(0.0, 1.0);
      onChanged();
      if (elapsedMs >= totalMs) {
        timer.cancel();
        allClearSurgeProgress = 0.0;
        onChanged();
      }
    });
  }

  void resetAllClearCrest() {
    hasAllClearCrest = false;
  }

  void triggerStinger(String text, Color color, {bool isCrucialMilestone = false}) {
    if (!isCrucialMilestone) return;
    _stingerTimer?.cancel();
    stingerText = text;
    stingerColor = color;
    onChanged();
    _stingerTimer = Timer(const Duration(milliseconds: 1400), () {
      stingerText = null;
      onChanged();
    });
  }

  void showScreenFlash(Color color, {int duration = 100}) {
    screenFlashColor = color;
    screenFlashController.duration = Duration(milliseconds: duration);
    screenFlashController.forward(from: 0.0);
  }

  void playConfetti() => confettiController.play();

  void resetFrenzyTimer({
    bool resetProgress = true,
    double durationMultiplier = 1.0,
  }) {
    _frenzyTimer?.cancel();
    _lastFrenzyMultiplier = durationMultiplier;
    if (resetProgress) {
      frenzyProgress = 1.0;
      onChanged();
    }
    const tick = Duration(milliseconds: 50);
    _frenzyTotalDurationMs = GameConfig.frenzyBaseDurationMs * durationMultiplier;
    _frenzyTimer = Timer.periodic(tick, (timer) {
      frenzyProgress = max(0.0, frenzyProgress - (50.0 / _frenzyTotalDurationMs));
      if (frenzyProgress <= 0.0) {
        _frenzyTimer?.cancel();
        onFrenzyExpired();
      }
      onChanged();
    });
  }

  void resumeFrenzyTimer({double? durationMultiplier}) {
    if (frenzyProgress <= 0.0 || _frenzyTotalDurationMs <= 0.0) return;
    resetFrenzyTimer(
      resetProgress: false,
      durationMultiplier: durationMultiplier ?? _lastFrenzyMultiplier,
    );
  }

  void dispose() {
    _stingerTimer?.cancel();
    _frenzyTimer?.cancel();
    _clearAnimTimer?.cancel();
    _allClearTimer?.cancel();
    realmMorphController.dispose();
    worldMorphController.dispose();
    boardRevealController.dispose();
    confettiController.dispose();
    tickerController.dispose();
    clearController.dispose();
    screenFlashController.dispose();
  }
}
