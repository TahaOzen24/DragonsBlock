/// Centralized gameplay & economy tuning values.
class GameConfig {
  GameConfig._();

  // ─── Scoring / Milestone Thresholds ──────────────────────────────────────
  // Max 3 perks per entire run (triggered at 3000, 7500, 15000)
  static const int blessingScoreThreshold = 3000;
  static const int blessingThresholdStepHigh = 4500;
  static const int maxBlessingsPerRun = 3;

  // ─── Ultimate Energy ──────────────────────────────────────────────────────
  static const double startingUltimateEnergy = 35.0;
  static const double maxUltimateEnergy = 100.0;
  static const double ultimateEnergyPerLine = 25.0;
  static const double ultimateEnergyPerCombo = 10.0;

  // ─── Blitz Mode ───────────────────────────────────────────────────────────
  static const int blitzDurationSeconds = 60;
  static const int blitzMaxSeconds = 99;
  static const int blitzBonusPerLine = 3;
  static const int blitzBonusOnBoss = 15;
  static const int blitzBonusOnPowerup = 20;
  static const int blitzComboBonus = 2;

  // ─── Frenzy ───────────────────────────────────────────────────────────────
  static const double frenzyBaseDurationMs = 6000.0;

  // ─── Idle Vault ───────────────────────────────────────────────────────────
  static const int idleVaultShardsPerHour = 50;
  static const int idleVaultMaxHours = 8;
}

/// All tunable game parameters in one place. Data-driven, no magic numbers.
class GameTuning {
  GameTuning._();

  // ─── Board ──────────────────────────────────────────────────────────────
  static const int gridSize = 8;
  static const int shapesPerHand = 3;
  static const int nextQueueSize = 3;

  // ─── Scoring ────────────────────────────────────────────────────────────
  static const int basePointsPerBlock = 10;
  static const int tetraMasterBonusBlocks = 4;
  static const int tetraMasterBonusScore = 250;
  static const Map<int, int> lineClearPoints = {
    1: 75,
    2: 200,
    3: 500,
    4: 1200,
    5: 2500,
  };
  static const int crossClearBonusPerIntersection = 500;
  static const int perfectClearBaseBonus = 4000;
  static const int almostClearBonus = 50;

  // ─── Combo ──────────────────────────────────────────────────────────────
  static const int comboFrenzyBaseDurationMs = 6000;
  static const int hyperdriveEnergyThreshold = 90;
  static const int hyperdriveDurationMoves = 3;
  static const int hyperdriveDurationMovesWithBlessing = 5;
  static const double feverMultiplier = 2.0;

  // ─── Dynamic Difficulty ─────────────────────────────────────────────────
  static const int earlyGameMoves = 10;
  static const int midGameMoves = 25;
  static const double spaciousThreshold = 0.35;
  static const double crowdedThreshold = 0.60;
  static const int solverActivationDrought = 5;
  static const int rescueActivationDrought = 8;

  // ─── Early Game Safety ──────────────────────────────────────────────────
  static const int guaranteedClearMoves = 5;
  static const double earlyGameWeightBoost = 1.5;

  // ─── Rescue ─────────────────────────────────────────────────────────────
  static const int maxShufflesPerGame = 2;
  static const int maxRevivesPerGame = 1;
  static const int reviveCostGold = 200;
  static const int reviveClearsBottomRows = 3;
  static const int minScoreForRevive = 500;
  static const int reviveCountdownSeconds = 5;

  // ─── Economy ────────────────────────────────────────────────────────────
  static const int startingGoldShards = 100;
  static const int dailyBonusShards = 50;
  static const int idleVaultShardsPerHour = 50;
  static const int idleVaultMaxHours = 8;

  // ─── Visual ─────────────────────────────────────────────────────────────
  static const int nearCompleteThreshold = 7;
  static const int startingBlocksCount = 6;
  static const int tutorialHintDurationSeconds = 5;
  static const int frenzyTimerTickMs = 50;

  // ─── Shape Weight Profiles ──────────────────────────────────────────────
  // Order: domino, triomino, line4, line5, cornerSmall, lMedium, lBig,
  //        uShape, square2x2, rectangle, square3x3, tShape, szShape, plusCross, diagonal
  static const Map<String, List<double>> shapeWeights = {
    'early': [25, 20, 15, 0, 10, 5, 0, 0, 10, 2, 0, 8, 5, 0, 0],
    'mid': [15, 15, 18, 5, 8, 10, 5, 3, 10, 3, 2, 10, 5, 2, 2],
    'late': [10, 12, 20, 10, 5, 12, 8, 5, 8, 5, 3, 10, 5, 3, 4],
    'emergency': [30, 25, 10, 0, 10, 0, 0, 0, 15, 0, 0, 5, 5, 0, 0],
  };
}

/// Tracks drought and shape variety to prevent stale hands.
class ShapeDroughtTracker {
  int movesSinceLastClear = 0;
  int movesSinceSmallPiece = 0;
  int consecutiveBadMoves = 0;
  final Map<String, int> _recentFamilyCounts = {};

  void recordPiece(String familyName, bool clearedLine, int pieceBlocks) {
    movesSinceLastClear = clearedLine ? 0 : movesSinceLastClear + 1;
    consecutiveBadMoves = clearedLine ? 0 : consecutiveBadMoves + 1;
    if (pieceBlocks <= 3) {
      movesSinceSmallPiece = 0;
    } else {
      movesSinceSmallPiece++;
    }
    _recentFamilyCounts[familyName] = (_recentFamilyCounts[familyName] ?? 0) + 1;
  }

  bool get needsSolver => movesSinceLastClear >= GameTuning.solverActivationDrought;
  bool get needsSmallPiece => movesSinceSmallPiece >= 3;
  bool get needsRescue => movesSinceLastClear >= GameTuning.rescueActivationDrought;

  bool isFamilyOverused(String familyName, {int threshold = 2}) {
    return (_recentFamilyCounts[familyName] ?? 0) >= threshold;
  }

  void resetAfterClear() {
    _recentFamilyCounts.clear();
  }

  void fullReset() {
    movesSinceLastClear = 0;
    movesSinceSmallPiece = 0;
    consecutiveBadMoves = 0;
    _recentFamilyCounts.clear();
  }
}

/// Calculates the player's emotional flow state for dynamic difficulty.
class DynamicDifficulty {
  DynamicDifficulty._();

  static double calculateFlowState({
    required double occupancyRate,
    required int movesSinceLastClear,
    required int comboStreak,
    required int totalLinesCleared,
    required int movesCount,
  }) {
    double flow = 1.0;
    flow -= (occupancyRate - 0.4).clamp(0.0, 0.6) * 1.5;
    flow += (comboStreak * 0.08).clamp(0.0, 0.3);
    flow -= (movesSinceLastClear * 0.12).clamp(0.0, 0.5);
    final experienceFactor = (totalLinesCleared / 50.0).clamp(0.0, 0.2);
    flow += experienceFactor;
    return flow.clamp(0.0, 1.0);
  }

  static String getDifficultyProfile(double flowState, RescueLevel rescue) {
    if (rescue == RescueLevel.critical || rescue == RescueLevel.warning) {
      return 'emergency';
    }
    if (rescue == RescueLevel.watchful) return 'defensive';
    if (flowState > 0.7) return 'aggressive';
    if (flowState > 0.4) return 'balanced';
    return 'defensive';
  }

  static RescueLevel getRescueLevel(double flowState, int consecutiveBadMoves) {
    if (flowState < 0.1 && consecutiveBadMoves >= 3) return RescueLevel.critical;
    if (flowState < 0.25 && consecutiveBadMoves >= 2) return RescueLevel.warning;
    if (flowState < 0.4) return RescueLevel.watchful;
    return RescueLevel.none;
  }
}

enum RescueLevel { none, watchful, warning, critical }
