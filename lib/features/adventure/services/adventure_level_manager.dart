import 'dart:math';
import 'package:flutter/foundation.dart';
import '../../shop/services/shop_manager.dart';
import '../../dragon/services/dragon_manager.dart';
import '../../achievements/services/achievement_manager.dart';
import '../models/adventure_level.dart';
import '../models/boss.dart';

/// Snapshot of in-run objective progress for adventure levels.
class AdventureRunState {
  final int score;
  final int movesLeft;
  final int maxMoves;
  final int iceRemaining;
  final int linesCleared;
  final int bossHp;
  final bool handBlocked;
  final bool outOfMoves;

  const AdventureRunState({
    required this.score,
    required this.movesLeft,
    required this.maxMoves,
    required this.iceRemaining,
    required this.linesCleared,
    required this.bossHp,
    required this.handBlocked,
    required this.outOfMoves,
  });
}

enum AdventureOutcomeKind { none, victory, defeat }

class AdventureOutcome {
  final AdventureOutcomeKind kind;
  final int stars;
  final int rewardShards;
  final String? defeatReasonKey; // 'moves' | 'board'

  const AdventureOutcome({
    required this.kind,
    this.stars = 0,
    this.rewardShards = 0,
    this.defeatReasonKey,
  });

  static const none = AdventureOutcome(kind: AdventureOutcomeKind.none);
}

/// Central level progression, objective evaluation, stars & unlocks.
class AdventureLevelManager extends ChangeNotifier {
  static final AdventureLevelManager instance = AdventureLevelManager._();
  AdventureLevelManager._();

  int unlockedLevel = 1;
  Map<int, int> starsByLevel = {};
  int totalStars = 0;

  Future<void> loadProgress() async {
    unlockedLevel = await AdventureLevel.getUnlockedLevel();
    starsByLevel = await AdventureLevel.getAllStars();
    totalStars = await AdventureLevel.getTotalStars();
    notifyListeners();
  }

  AdventureLevel levelFor(int floor) => AdventureLevel.getLevel(floor);

  bool isFloorUnlocked(int floor) => floor <= unlockedLevel;

  /// Evaluate win/lose without mutating persistence.
  AdventureOutcome evaluate(AdventureLevel level, AdventureRunState state) {
    final victory = _isObjectiveMet(level, state);
    if (victory) {
      final stars = computeStars(state.movesLeft, state.maxMoves);
      return AdventureOutcome(
        kind: AdventureOutcomeKind.victory,
        stars: stars,
        rewardShards: level.rewardShards,
      );
    }

    if (state.outOfMoves) {
      return const AdventureOutcome(
        kind: AdventureOutcomeKind.defeat,
        defeatReasonKey: 'moves',
      );
    }
    if (state.handBlocked) {
      return const AdventureOutcome(
        kind: AdventureOutcomeKind.defeat,
        defeatReasonKey: 'board',
      );
    }
    return AdventureOutcome.none;
  }

  bool _isObjectiveMet(AdventureLevel level, AdventureRunState state) {
    switch (level.objectiveType) {
      case ObjectiveType.scoreTarget:
        return state.score >= level.targetScore;
      case ObjectiveType.shatterIce:
        return state.iceRemaining <= 0;
      case ObjectiveType.clearLines:
      case ObjectiveType.treasureChest:
        return state.linesCleared >= level.targetLineCount;
      case ObjectiveType.bossBattle:
        return state.bossHp <= 0;
    }
  }

  /// 3★ if ≥35% moves left, 2★ if ≥15%, else 1★.
  static int computeStars(int movesLeft, int maxMoves) {
    if (maxMoves <= 0) return 1;
    final ratio = movesLeft / maxMoves;
    if (ratio >= 0.35) return 3;
    if (ratio >= 0.15) return 2;
    return 1;
  }

  /// Persist victory: shards, stars, unlock next floor, boss flags.
  Future<AdventureOutcome> commitVictory({
    required AdventureLevel level,
    required int movesLeft,
  }) async {
    final stars = computeStars(movesLeft, level.maxMoves);
    final reward = level.rewardShards;

    await ShopManager.instance.addShards(reward);
    await AdventureLevel.saveStarsForLevel(level.levelIndex, stars);
    await AdventureLevel.unlockNextLevel(level.levelIndex);
    await DragonManager.instance.addDragonExp(level.boss != null ? 100 : 50);

    if (level.boss != null) {
      await Boss.markBossDefeated(level.boss!.id);
      await AchievementManager.instance.updateProgress('boss_slayer', 1);
    }

    await loadProgress();

    return AdventureOutcome(
      kind: AdventureOutcomeKind.victory,
      stars: stars,
      rewardShards: reward,
    );
  }

  /// Human-readable objective summary (TR/EN via caller locale).
  static String objectiveLabel(AdventureLevel level, {required bool isTurkish}) {
    switch (level.objectiveType) {
      case ObjectiveType.scoreTarget:
        return isTurkish
            ? 'Hedef skor: ${level.targetScore}'
            : 'Score target: ${level.targetScore}';
      case ObjectiveType.shatterIce:
        return isTurkish
            ? 'Buzları temizle: ${level.targetIceCount}'
            : 'Shatter ice: ${level.targetIceCount}';
      case ObjectiveType.clearLines:
        return isTurkish
            ? 'Satır/sütun temizle: ${level.targetLineCount}'
            : 'Clear lines: ${level.targetLineCount}';
      case ObjectiveType.treasureChest:
        return isTurkish
            ? 'Hazine için ${level.targetLineCount} hat temizle'
            : 'Clear ${level.targetLineCount} lines for the chest';
      case ObjectiveType.bossBattle:
        return isTurkish
            ? 'Boss HP\'sini sıfırla'
            : 'Reduce boss HP to zero';
    }
  }

  static String progressLabel(
    AdventureLevel level,
    AdventureRunState state, {
    required bool isTurkish,
  }) {
    switch (level.objectiveType) {
      case ObjectiveType.scoreTarget:
        return '${state.score} / ${level.targetScore}';
      case ObjectiveType.shatterIce:
        final done = max(0, level.targetIceCount - state.iceRemaining);
        return '$done / ${level.targetIceCount}';
      case ObjectiveType.clearLines:
      case ObjectiveType.treasureChest:
        return '${state.linesCleared} / ${level.targetLineCount}';
      case ObjectiveType.bossBattle:
        final maxHp = level.boss?.maxHp ?? 1;
        return '${max(0, state.bossHp)} / $maxHp HP';
    }
  }
}
