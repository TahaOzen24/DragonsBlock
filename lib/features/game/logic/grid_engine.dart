import 'dart:math';
import 'package:flutter/material.dart';
import '../../quests/services/quest_manager.dart';
import '../models/board_realm.dart';
import '../models/grid_cell.dart';
import '../models/in_game_blessing.dart';
import '../models/polyomino_shape.dart';
import '../models/relic.dart';
import 'engine_helpers.dart';

class ClearedCellInfo {
  final Point<int> pos;
  final Color color;

  const ClearedCellInfo({
    required this.pos,
    required this.color,
  });
}

class PlacementResult {
  final bool success;
  final int linesCleared;
  final int pointsEarned;
  final int comboStreak;
  final List<Point<int>> clearedCells;
  final List<ClearedCellInfo> clearedCellDetails;
  final List<Point<int>> elementalBlastCells;
  final List<int> clearedRows;
  final List<int> clearedCols;
  final List<String> triggerMessages;
  final bool isPerfectClear;
  final int goldShardsEarned;
  final bool hyperdriveTriggered;

  PlacementResult({
    required this.success,
    this.linesCleared = 0,
    this.pointsEarned = 0,
    this.comboStreak = 0,
    this.clearedCells = const [],
    this.clearedCellDetails = const [],
    this.elementalBlastCells = const [],
    this.clearedRows = const [],
    this.clearedCols = const [],
    this.triggerMessages = const [],
    this.isPerfectClear = false,
    this.goldShardsEarned = 0,
    this.hyperdriveTriggered = false,
  });
}

class GridSnapshot {
  final List<List<GridCell>> gridCopy;
  final int score;
  final int combo;
  final int lines;
  final int shards;
  final double energy;
  final bool emergency;
  final double hyperdriveEnergy;
  final bool isHyperdriveActive;
  final int hyperdriveMovesLeft;
  final int allClearSurgeMovesLeft;
  final bool isPristineHandQueued;
  final BoardRealm activeRealm;
  final double realmMorphProgress;

  GridSnapshot({
    required this.gridCopy,
    required this.score,
    required this.combo,
    required this.lines,
    required this.shards,
    required this.energy,
    required this.emergency,
    required this.hyperdriveEnergy,
    required this.isHyperdriveActive,
    required this.hyperdriveMovesLeft,
    required this.allClearSurgeMovesLeft,
    required this.isPristineHandQueued,
    required this.activeRealm,
    required this.realmMorphProgress,
  });
}

class GridEngine {
  static const int gridSize = 8;
  late List<List<GridCell>> grid;
  int currentScore = 0;
  int highScore = 0;
  int totalGoldShardsEarnedInRun = 0;
  int get goldShards => totalGoldShardsEarnedInRun;
  set goldShards(int val) => totalGoldShardsEarnedInRun = val;
  int comboStreak = 0;
  int comboGraceMoves = 0;
  int totalLinesCleared = 0;
  double comboEnergy = 0.0; // 0.0 to 100.0
  bool emergencyUsed = false;

  // Hyperdrive Fever Mode state
  double hyperdriveEnergy = 0.0; // 0.0 to 100.0
  bool isHyperdriveActive = false;
  int hyperdriveMovesLeft = 0;

  // All-Clear Advantage & Surge State
  int allClearSurgeMovesLeft = 0;
  bool isPristineHandQueued = false;

  // Active In-Game Roguelike Blessings
  List<InGameBlessing> activeBlessings = [];

  // Global Board Realm State
  BoardRealm activeRealm = BoardRealm.jewelSpectrum;
  double realmMorphProgress = 1.0;
  final Map<Point<int>, Color> sourceMorphColors = {};
  final Map<Point<int>, Color> targetMorphColors = {};

  // External run modifiers (e.g. Daily Challenge). Applied on top of relic bonuses.
  double runScoreMultiplier = 1.0;
  double runEnergyMultiplier = 1.0;

  GridEngine() {
    reset();
  }

  void reset() {
    grid = List.generate(
      gridSize,
      (_) => List.generate(gridSize, (_) => GridCell()),
    );
    currentScore = 0;
    comboStreak = 0;
    comboGraceMoves = 0;
    totalLinesCleared = 0;
    totalGoldShardsEarnedInRun = 0;
    comboEnergy = 30.0;
    emergencyUsed = false;
    hyperdriveEnergy = 0.0;
    isHyperdriveActive = false;
    hyperdriveMovesLeft = 0;
    allClearSurgeMovesLeft = 0;
    isPristineHandQueued = false;
    activeBlessings = [];
  }

  /// Place a few random blocks at game start so the board isn't completely empty.
  void placeStartingBlocks({int count = 6, Color? color}) {
    final rng = Random();
    final colors = [
      const Color(0xFFEF4444), // Ruby Red
      const Color(0xFF3B82F6), // Sapphire Blue
      const Color(0xFF10B981), // Emerald Green
      const Color(0xFFF59E0B), // Topaz Gold
      const Color(0xFF8B5CF6), // Amethyst Purple
    ];
    
    int placed = 0;
    int attempts = 0;
    while (placed < count && attempts < 100) {
      attempts++;
      final r = rng.nextInt(gridSize);
      final c = rng.nextInt(gridSize);
      if (!grid[r][c].isOccupied) {
        grid[r][c].occupy(
          color: color ?? colors[rng.nextInt(colors.length)],
        );
        placed++;
      }
    }
  }

  GridSnapshot createSnapshot() {
    final List<List<GridCell>> gridCopy = List.generate(
      gridSize,
      (r) => List.generate(gridSize, (c) => grid[r][c].clone()),
    );
    return GridSnapshot(
      gridCopy: gridCopy,
      score: currentScore,
      combo: comboStreak,
      lines: totalLinesCleared,
      shards: totalGoldShardsEarnedInRun,
      energy: comboEnergy,
      emergency: emergencyUsed,
      hyperdriveEnergy: hyperdriveEnergy,
      isHyperdriveActive: isHyperdriveActive,
      hyperdriveMovesLeft: hyperdriveMovesLeft,
      allClearSurgeMovesLeft: allClearSurgeMovesLeft,
      isPristineHandQueued: isPristineHandQueued,
      activeRealm: activeRealm,
      realmMorphProgress: realmMorphProgress,
    );
  }

  void restoreSnapshot(GridSnapshot snapshot) {
    grid = List.generate(
      gridSize,
      (r) => List.generate(gridSize, (c) => snapshot.gridCopy[r][c].clone()),
    );
    currentScore = snapshot.score;
    comboStreak = snapshot.combo;
    totalLinesCleared = snapshot.lines;
    totalGoldShardsEarnedInRun = snapshot.shards;
    comboEnergy = snapshot.energy;
    emergencyUsed = snapshot.emergency;
    hyperdriveEnergy = snapshot.hyperdriveEnergy;
    isHyperdriveActive = snapshot.isHyperdriveActive;
    hyperdriveMovesLeft = snapshot.hyperdriveMovesLeft;
    allClearSurgeMovesLeft = snapshot.allClearSurgeMovesLeft;
    isPristineHandQueued = snapshot.isPristineHandQueued;
    activeRealm = snapshot.activeRealm;
    realmMorphProgress = snapshot.realmMorphProgress;
  }

  bool canPlace(PolyominoShape shape, int startRow, int startCol) {
    if (startRow < 0 || startCol < 0) return false;
    if (startRow + shape.rowCount > gridSize || startCol + shape.colCount > gridSize) {
      return false;
    }

    for (int r = 0; r < shape.rowCount; r++) {
      for (int c = 0; c < shape.colCount; c++) {
        if (shape.matrix[r][c] == 1) {
          int targetR = startRow + r;
          int targetC = startCol + c;
          final cell = grid[targetR][targetC];
          if (cell.isOccupied || cell.frozenTurns > 0) {
            return false;
          }
        }
      }
    }
    return true;
  }

  bool canPlaceShapeAnywhere(PolyominoShape shape) {
    for (int r = 0; r <= gridSize - shape.rowCount; r++) {
      for (int c = 0; c <= gridSize - shape.colCount; c++) {
        if (canPlace(shape, r, c)) {
          return true;
        }
      }
    }
    return false;
  }

  bool hasAnyValidMoves(List<PolyominoShape> availableShapes) {
    for (var shape in availableShapes) {
      if (canPlaceShapeAnywhere(shape)) {
        return true;
      }
    }
    return false;
  }

  int get occupiedCellCount {
    int count = 0;
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        if (grid[r][c].isOccupied) count++;
      }
    }
    return count;
  }

  double get occupancyRate => occupiedCellCount / (gridSize * gridSize);

  int countValidPlacements(PolyominoShape shape) {
    int valid = 0;
    for (int r = 0; r <= gridSize - shape.rowCount; r++) {
      for (int c = 0; c <= gridSize - shape.colCount; c++) {
        if (canPlace(shape, r, c)) valid++;
      }
    }
    return valid;
  }

  List<int> get nearCompleteRows {
    List<int> result = [];
    for (int r = 0; r < gridSize; r++) {
      int occupied = 0;
      for (int c = 0; c < gridSize; c++) {
        if (grid[r][c].isOccupied) occupied++;
      }
      if (occupied >= gridSize - 2 && occupied < gridSize) {
        result.add(r);
      }
    }
    return result;
  }

  List<int> get nearCompleteCols {
    List<int> result = [];
    for (int c = 0; c < gridSize; c++) {
      int occupied = 0;
      for (int r = 0; r < gridSize; r++) {
        if (grid[r][c].isOccupied) occupied++;
      }
      if (occupied >= gridSize - 2 && occupied < gridSize) {
        result.add(c);
      }
    }
    return result;
  }

  List<int> getRowsClearedIfPlaced(PolyominoShape shape, int startRow, int startCol) {
    if (!canPlace(shape, startRow, startCol)) return const [];
    List<int> fullRows = [];
    for (int r = 0; r < gridSize; r++) {
      bool full = true;
      for (int c = 0; c < gridSize; c++) {
        final bool isPlacedHere = (r >= startRow &&
            r < startRow + shape.rowCount &&
            c >= startCol &&
            c < startCol + shape.colCount &&
            shape.matrix[r - startRow][c - startCol] == 1);
        if (!grid[r][c].isOccupied && !isPlacedHere) {
          full = false;
          break;
        }
      }
      if (full) fullRows.add(r);
    }
    return fullRows;
  }

  List<int> getColsClearedIfPlaced(PolyominoShape shape, int startRow, int startCol) {
    if (!canPlace(shape, startRow, startCol)) return const [];
    List<int> fullCols = [];
    for (int c = 0; c < gridSize; c++) {
      bool full = true;
      for (int r = 0; r < gridSize; r++) {
        final bool isPlacedHere = (r >= startRow &&
            r < startRow + shape.rowCount &&
            c >= startCol &&
            c < startCol + shape.colCount &&
            shape.matrix[r - startRow][c - startCol] == 1);
        if (!grid[r][c].isOccupied && !isPlacedHere) {
          full = false;
          break;
        }
      }
      if (full) fullCols.add(c);
    }
    return fullCols;
  }

  PlacementResult placeShape(
    PolyominoShape shape,
    int startRow,
    int startCol,
    List<Relic> activeRelics,
    {bool recordProgress = true}
  ) {
    if (!canPlace(shape, startRow, startCol)) {
      return PlacementResult(success: false);
    }

    int placedBlocks = 0;
    List<Point<int>> placedPositions = [];

    // Occupy grid cells
    for (int r = 0; r < shape.rowCount; r++) {
      for (int c = 0; c < shape.colCount; c++) {
        if (shape.matrix[r][c] == 1) {
          int targetR = startRow + r;
          int targetC = startCol + c;

          grid[targetR][targetC].occupy(
            color: shape.baseColor,
            assignedClassicColor: shape.baseColor,
          );
          placedBlocks++;
          placedPositions.add(Point(targetR, targetC));
        }
      }
    }

    // Base placement score
    int baseScore = placedBlocks * 10;

    // Relic buff: Tetra Master (+250 if 4+ blocks)
    bool hasTetra = activeRelics.any((r) => r.id == 'tetra_master');
    if (hasTetra && placedBlocks >= 4) {
      baseScore += 250;
    }

    // Relic multipliers (plus any external run multiplier)
    double globalMultiplier = runScoreMultiplier;
    for (var relic in activeRelics) {
      globalMultiplier *= relic.scoreMultiplier;
    }

    // Check full rows and columns
    List<int> fullRows = [];
    List<int> fullCols = [];

    for (int r = 0; r < gridSize; r++) {
      bool rowFull = true;
      for (int c = 0; c < gridSize; c++) {
        if (!grid[r][c].isOccupied) {
          rowFull = false;
          break;
        }
      }
      if (rowFull) fullRows.add(r);
    }

    for (int c = 0; c < gridSize; c++) {
      bool colFull = true;
      for (int r = 0; r < gridSize; r++) {
        if (!grid[r][c].isOccupied) {
          colFull = false;
          break;
        }
      }
      if (colFull) fullCols.add(c);
    }

    int earnedGold = 0;
    List<String> triggerMessages = [];

    // Rainbow Rune Wildcard Trigger: Guarantees row and column clear at placement point
    if (shape.isRainbow) {
      if (!fullRows.contains(startRow)) fullRows.add(startRow);
      if (!fullCols.contains(startCol)) fullCols.add(startCol);
      earnedGold += 100;
      triggerMessages.add("🌈 RAINBOW WILDCARD SURGE!");
    }

    int linesCleared = fullRows.length + fullCols.length;
    List<Point<int>> clearedCells = [];
    int bonusScore = 0;

    if (linesCleared > 0) {
      comboStreak++;
      comboGraceMoves = 1; // Block Blast 1-move grace window!
      totalLinesCleared += linesCleared;
      comboEnergy = (comboEnergy + (linesCleared * 25.0 * runEnergyMultiplier)).clamp(0.0, 100.0);

      bool hyperdriveTriggered = false;

      // Handle Hyperdrive charging (lowered threshold for more frequent activation)
      if (!isHyperdriveActive) {
        hyperdriveEnergy = (hyperdriveEnergy + (linesCleared * 25.0) + (comboStreak * 15.0)).clamp(0.0, 100.0);
        if (hyperdriveEnergy >= 90.0) {
          isHyperdriveActive = true;
          hyperdriveMovesLeft = activeBlessings.any((b) => b.id == 'frenzy_master') ? 5 : 3;
          hyperdriveEnergy = 0.0;
          hyperdriveTriggered = true;
          triggerMessages.add("⚡ HYPERDRIVE ACTIVATED!");
        }
      }

      // Identify all cleared cells from lines
      Set<Point<int>> cellsToClear = {};
      for (int r in fullRows) {
        for (int c = 0; c < gridSize; c++) {
          cellsToClear.add(Point(r, c));
        }
      }
      for (int c in fullCols) {
        for (int r = 0; r < gridSize; r++) {
          cellsToClear.add(Point(r, c));
        }
      }

      List<ClearedCellInfo> clearedDetails = [];
      List<Point<int>> elementalBlasts = [];
      final iceToShatter = _collectIceToShatter(fullRows, fullCols);

      // Clear normal line cells; frozen cells shatter separately below
      for (var pt in cellsToClear) {
        final cell = grid[pt.x][pt.y];
        if (cell.frozenTurns > 0) continue;
        clearedDetails.add(ClearedCellInfo(
          pos: pt,
          color: cell.blockColor ?? shape.baseColor,
        ));
        cell.reset();
        clearedCells.add(pt);
      }

      for (var pt in iceToShatter) {
        final cell = grid[pt.x][pt.y];
        if (!cell.isOccupied) continue;
        clearedDetails.add(ClearedCellInfo(
          pos: pt,
          color: cell.blockColor ?? shape.baseColor,
        ));
        cell.reset();
        clearedCells.add(pt);
      }
      if (iceToShatter.isNotEmpty) {
        triggerMessages.add('❄️ BUZ KIRILDI!');
      }

      // ─── BLESSINGS PROCESSING ───
      if (activeBlessings.any((b) => b.id == 'midas_touch')) {
        earnedGold += 50;
      }

      // 1. Multi-Line Clear Scaled Base: Softer ramping for more frequent satisfaction
      int multiLineBase;
      if (linesCleared == 1) {
        multiLineBase = 75;
      } else if (linesCleared == 2) {
        multiLineBase = 200;
      } else if (linesCleared == 3) {
        multiLineBase = 500;
      } else if (linesCleared == 4) {
        multiLineBase = 1200;
      } else {
        multiLineBase = 2500 + (linesCleared - 5) * 1000;
      }

      // 2. Chain Reaction Streak Multiplier: Softer early, still rewarding late
      double streakMultiplier;
      if (comboStreak <= 1) {
        streakMultiplier = 1.0;
      } else if (comboStreak == 2) {
        streakMultiplier = 1.3;
      } else if (comboStreak == 3) {
        streakMultiplier = 1.8;
      } else if (comboStreak == 4) {
        streakMultiplier = 2.5;
      } else {
        streakMultiplier = 3.0 + (comboStreak - 5) * 0.5;
      }

      // 3. Cross-Clear Detonation Bonus: Triggered when both horizontal and vertical lines clear at once!
      int crossClearBonus = 0;
      if (fullRows.isNotEmpty && fullCols.isNotEmpty) {
        crossClearBonus = 500 * (fullRows.length * fullCols.length);
        triggerMessages.add("✚ ÇAPRAZ REAKSİYON (+$crossClearBonus)!");
      }

      // 4. Double Score Clean Surge (from previous All-Clear) & Hyperdrive Fever
      double feverMultiplier = isHyperdriveActive ? 2.0 : 1.0;
      double surgeMultiplier = allClearSurgeMovesLeft > 0 ? 2.0 : 1.0;
      if (allClearSurgeMovesLeft > 0) {
        allClearSurgeMovesLeft--;
        triggerMessages.add("⚡ ÇİFT SKOR KUTSAMASI (x2)!");
      }

      int lineClearPoints = (multiLineBase * streakMultiplier).toInt();
      int totalPoints = (((baseScore + lineClearPoints + crossClearBonus) * globalMultiplier * feverMultiplier * surgeMultiplier) + bonusScore).toInt();

      // 5. Board-Clear (All-Clear) Reward
      bool isPerfect = isBoardCompletelyEmpty();
      if (isPerfect) {
        int allClearReward = (4000 * streakMultiplier).toInt();
        totalPoints += allClearReward;
        allClearSurgeMovesLeft = 3;
        isPristineHandQueued = true;
        triggerMessages.add("🌟 MÜKEMMEL SÜPÜRME (ALL CLEAR)! +$allClearReward");
      }

      currentScore += totalPoints;

      // Gold check (Midas touch relic or gold runes)
      bool hasMidas = activeRelics.any((r) => r.id == 'midas_touch');
      if (hasMidas && Random().nextDouble() < 0.25) {
        const earned = 200;
        earnedGold += earned;
        triggerMessages.add("🪙 Midas Touch: +$earned Shards!");
      }

      // Alchemist Stone Relic (+300 shards on multi-line clear)
      bool hasAlchemist = activeRelics.any((r) => r.id == 'alchemist_stone');
      if (hasAlchemist && linesCleared >= 2) {
        const earned = 300;
        earnedGold += earned;
        triggerMessages.add("💎 Philosopher's Stone: +$earned Shards!");
      }

      if (isHyperdriveActive) {
        hyperdriveMovesLeft--;
        if (hyperdriveMovesLeft <= 0) {
          isHyperdriveActive = false;
        }
      }

      totalGoldShardsEarnedInRun += earnedGold;

      if (currentScore > highScore) {
        highScore = currentScore;
      }

      // Report quests only for real player moves; spawner simulations must be
      // side-effect free.
      if (recordProgress) {
        QuestManager.instance.reportProgress('block_placer', 1);
        QuestManager.instance.reportProgress('line_crusher', linesCleared);
        if (linesCleared >= 2) {
          QuestManager.instance.reportProgress('multi_clear_master', 1);
        }
        QuestManager.instance.reportProgress('combo_virtuoso', comboStreak, isAbsolute: true);
        QuestManager.instance.reportProgress('high_score_hunter', currentScore, isAbsolute: true);
      }

      // Decrement frozen turns for all frozen cells (except permanently frozen)
      for (int r = 0; r < gridSize; r++) {
        for (int c = 0; c < gridSize; c++) {
          final cell = grid[r][c];
          if (cell.frozenTurns > 0 && cell.frozenTurns < 999) {
            cell.frozenTurns--;
          }
        }
      }

      return PlacementResult(
        success: true,
        linesCleared: linesCleared,
        pointsEarned: totalPoints,
        comboStreak: comboStreak,
        clearedCells: clearedCells,
        clearedCellDetails: clearedDetails,
        elementalBlastCells: elementalBlasts,
        clearedRows: fullRows,
        clearedCols: fullCols,
        triggerMessages: triggerMessages,
        isPerfectClear: isPerfect,
        goldShardsEarned: earnedGold,
        hyperdriveTriggered: hyperdriveTriggered,
      );
    } else {
      // Block Blast Standard: Grace move permits 1 non-clearing preparatory move without breaking streak
      if (comboGraceMoves > 0) {
        comboGraceMoves--;
        triggerMessages.add("⏳ KOMBO BEKLEMEDE!");
      } else {
        comboStreak = 0;
      }
      int totalPoints = (baseScore * globalMultiplier).toInt();
      
      // Almost-clear bonus: reward players for filling 7/8 of a row or column
      int almostBonus = 0;
      for (int r = 0; r < gridSize; r++) {
        int filled = 0;
        for (int c = 0; c < gridSize; c++) {
          if (grid[r][c].isOccupied) filled++;
        }
        if (filled == 7) almostBonus += 50;
      }
      for (int c = 0; c < gridSize; c++) {
        int filled = 0;
        for (int r = 0; r < gridSize; r++) {
          if (grid[r][c].isOccupied) filled++;
        }
        if (filled == 7) almostBonus += 50;
      }
      totalPoints += almostBonus;
      
      currentScore += totalPoints;

      if (isHyperdriveActive) {
        hyperdriveMovesLeft--;
        if (hyperdriveMovesLeft <= 0) {
          isHyperdriveActive = false;
        }
      }

      if (currentScore > highScore) {
        highScore = currentScore;
      }

      if (recordProgress) {
        QuestManager.instance.reportProgress('block_placer', 1);
        QuestManager.instance.reportProgress('high_score_hunter', currentScore, isAbsolute: true);
      }

      // Decrement frozen turns for all frozen cells (except permanently frozen)
      for (int r = 0; r < gridSize; r++) {
        for (int c = 0; c < gridSize; c++) {
          final cell = grid[r][c];
          if (cell.frozenTurns > 0 && cell.frozenTurns < 999) {
            cell.frozenTurns--;
          }
        }
      }

      return PlacementResult(
        success: true,
        linesCleared: 0,
        pointsEarned: totalPoints,
        comboStreak: 0,
      );
    }
  }

  bool applyGravity() => applyGravityOp(grid, gridSize).isNotEmpty;

  List<Point<int>> applyVoidSingularity() => applyVoidSingularityOp(grid, gridSize);

  List<Point<int>> meltBottomRows(int count) => meltBottomRowsOp(grid, gridSize, count);

  bool applyChronoShield() => applyChronoShieldOp(grid, gridSize);

  /// Permanent adventure ice (999) shatters when a cleared line touches or
  /// runs adjacent to it. Temporary boss frost shatters when its line clears.
  Set<Point<int>> _collectIceToShatter(List<int> fullRows, List<int> fullCols) {
    final shattered = <Point<int>>{};
    if (fullRows.isEmpty && fullCols.isEmpty) return shattered;

    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        final cell = grid[r][c];
        if (cell.frozenTurns <= 0) continue;

        final inClearedLine = fullRows.contains(r) || fullCols.contains(c);
        final adjacentToClearedRow = fullRows.any((cr) => (cr - r).abs() == 1);
        final adjacentToClearedCol = fullCols.any((cc) => (cc - c).abs() == 1);

        if (cell.frozenTurns >= 999) {
          if (inClearedLine || adjacentToClearedRow || adjacentToClearedCol) {
            shattered.add(Point(r, c));
          }
        } else if (inClearedLine) {
          shattered.add(Point(r, c));
        }
      }
    }
    return shattered;
  }

  bool isBoardCompletelyEmpty() => isBoardCompletelyEmptyOp(grid, gridSize);

  bool tryEmergencySave(List<Relic> activeRelics) {
    if (emergencyUsed) return false;

    // Check Chrono Shield blessing first
    if (activeBlessings.any((b) => b.id == 'chrono_shield')) {
      if (applyChronoShieldOp(grid, gridSize)) {
        emergencyUsed = true;
        return true;
      }
    }

    bool hasPhoenix = activeRelics.any((r) => r.id == 'phoenix_feather');
    bool hasEmergency = activeRelics.any((r) => r.id == 'emergency_sledge');

    if (!hasPhoenix && !hasEmergency) return false;

    emergencyUsed = true;

    if (hasPhoenix) {
      for (int r = 2; r <= 5; r++) {
        for (int c = 2; c <= 5; c++) {
          grid[r][c].reset();
        }
      }
      return true;
    }

    List<Point<int>> center = [
      const Point(3, 3),
      const Point(3, 4),
      const Point(4, 3),
      const Point(4, 4),
      const Point(2, 3),
      const Point(2, 4),
    ];
    for (var pt in center) {
      grid[pt.x][pt.y].reset();
    }
    return true;
  }

  bool smashCell(int r, int c) {
    if (r >= 0 && r < gridSize && c >= 0 && c < gridSize) {
      if (grid[r][c].isOccupied) {
        grid[r][c].reset();
        return true;
      }
    }
    return false;
  }

  List<Point<int>> reviveClear() => reviveClearOp(grid, gridSize);

  List<Point<int>> meltRandomOccupiedCells(int count) =>
      meltRandomOccupiedCellsOp(grid, gridSize, count);

  /// Morphs all currently occupied cells into a rich multi-jewel color spectrum
  void morphAllOccupiedCells(List<Color> palette) {
    final activePalette = (palette.length >= 2) ? palette : PolyominoShape.palette;
    final rng = Random();
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        if (grid[r][c].isOccupied) {
          grid[r][c].blockColor = activePalette[rng.nextInt(activePalette.length)];
          grid[r][c].glowFactor = 1.0;
        }
      }
    }
  }
  void triggerRealmEvolution(BoardRealm newRealm) {
    activeRealm = newRealm;
    sourceMorphColors.clear();
    targetMorphColors.clear();
    final palette = newRealm.palette;
    final rng = Random();

    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        if (grid[r][c].isOccupied) {
          final pos = Point(r, c);
          sourceMorphColors[pos] = grid[r][c].blockColor ?? Colors.white;
          targetMorphColors[pos] = palette[rng.nextInt(palette.length)];
        }
      }
    }
    realmMorphProgress = 0.0;
  }

  /// Updates smooth color interpolation during active realm morphing
  void updateRealmMorph(double progress) {
    realmMorphProgress = progress.clamp(0.0, 1.0);
    targetMorphColors.forEach((pos, targetColor) {
      if (pos.x < gridSize && pos.y < gridSize && grid[pos.x][pos.y].isOccupied) {
        final sourceColor = sourceMorphColors[pos] ?? targetColor;
        final currentColor = Color.lerp(sourceColor, targetColor, realmMorphProgress)!;
        grid[pos.x][pos.y].blockColor = currentColor;
        // Peak glow at mid-point (progress = 0.5)
        final midGlow = 1.0 + (1.0 - (realmMorphProgress - 0.5).abs() * 2) * 0.9;
        grid[pos.x][pos.y].glowFactor = midGlow;
      }
    });
  }
  /// Shuffles the positions of all occupied cells on the grid (Dead Board auto-recovery)
  bool shuffleOccupiedCells() {
    final List<GridCell> occupiedCells = [];
    final List<Point<int>> occupiedPositions = [];
    final List<Point<int>> emptyPositions = [];

    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        if (grid[r][c].isOccupied) {
          occupiedPositions.add(Point(r, c));
          occupiedCells.add(grid[r][c]);
        } else {
          emptyPositions.add(Point(r, c));
        }
      }
    }

    if (occupiedPositions.length < 2) return false;
    if (emptyPositions.isEmpty) return false;

    for (final pos in occupiedPositions) {
      grid[pos.x][pos.y] = GridCell();
    }

    final allPositions = [...emptyPositions, ...occupiedPositions]..shuffle();
    final List<Point<int>> newPositions = allPositions.sublist(0, occupiedCells.length)..shuffle();

    for (int i = 0; i < occupiedCells.length; i++) {
      final pos = newPositions[i];
      grid[pos.x][pos.y] = occupiedCells[i];
    }
    return true;
  }

  /// Ignis Ultimate: Incinerates the densest 3x3 sector on the grid
  List<Point<int>> triggerIgnisMeteorRain() => findDensest3x3SectorOp(grid, gridSize);

  /// Voltur Ultimate: Clears horizontal & vertical cross axes
  List<Point<int>> triggerVolturLightningCross({int targetRow = 3, int targetCol = 3}) =>
      clearCrossAxesOp(grid, gridSize, targetRow: targetRow, targetCol: targetCol);

  /// Umbra Ultimate: Absorbs up to 6 isolated obstacle cells into a singularity
  List<Point<int>> triggerUmbraVoidSingularity({int maxCount = 6}) =>
      absorbIsolatedCellsOp(grid, gridSize, maxCount: maxCount);
}
