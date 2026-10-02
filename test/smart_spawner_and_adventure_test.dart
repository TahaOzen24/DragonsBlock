import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dragons_block/core/storage/app_prefs.dart';
import 'package:dragons_block/features/game/logic/grid_engine.dart';
import 'package:dragons_block/features/game/logic/shape_spawner_engine.dart';
import 'package:dragons_block/features/adventure/models/adventure_level.dart';
import 'package:dragons_block/features/adventure/services/adventure_level_manager.dart';
import 'package:dragons_block/features/game/models/polyomino_shape.dart';

void main() {
  group('Smart Spawner anti-softlock', () {
    test('dealt hand always has ≥1 placeable piece on a living board', () {
      final rng = Random(42);
      final engine = GridEngine();
      // Fill board in a sparse pattern that still allows small pieces
      for (int r = 0; r < 8; r++) {
        for (int c = 0; c < 8; c++) {
          if ((r + c) % 3 == 0) {
            engine.grid[r][c].occupy(color: Colors.blue);
          }
        }
      }

      final spawner = ShapeSpawnerEngine(rng: rng);
      for (int i = 0; i < 40; i++) {
        final hand = spawner.generateBalancedHand(
          gridEngine: engine,
          currentScore: 1000 + i * 50,
          movesCount: 10 + i,
          gamesPlayed: 5,
        );
        expect(hand.length, 3);
        expect(
          hand.any(engine.canPlaceShapeAnywhere),
          isTrue,
          reason: 'Iteration $i dealt an unplayable hand on a living board',
        );
      }
    });

    test('crowded board prefers placeable rescue pieces', () {
      final engine = GridEngine();
      // Almost full — leave a few 2-cell gaps
      for (int r = 0; r < 8; r++) {
        for (int c = 0; c < 8; c++) {
          if (!(r == 7 && (c == 0 || c == 1)) && !(r == 0 && c == 7)) {
            engine.grid[r][c].occupy(color: Colors.red);
          }
        }
      }

      final spawner = ShapeSpawnerEngine(rng: Random(7));
      final hand = spawner.generateBalancedHand(
        gridEngine: engine,
        currentScore: 5000,
        movesCount: 40,
        gamesPlayed: 10,
      );
      expect(hand.any(engine.canPlaceShapeAnywhere), isTrue);
    });
    test('crowded board hand pieces are all placeable when possible', () {
      final engine = GridEngine();
      // Dense board — leave scattered 1–2 cell gaps
      for (int r = 0; r < 8; r++) {
        for (int c = 0; c < 8; c++) {
          if (!((r == 7 && c < 2) || (r == 3 && c == 3) || (r == 0 && c == 7))) {
            engine.grid[r][c].occupy(color: Colors.indigo);
          }
        }
      }
      expect(engine.occupancyRate, greaterThan(0.7));

      final spawner = ShapeSpawnerEngine(rng: Random(99));
      for (int i = 0; i < 25; i++) {
        final hand = spawner.generateBalancedHand(
          gridEngine: engine,
          currentScore: 8000,
          movesCount: 50,
          gamesPlayed: 20,
        );
        for (final piece in hand) {
          expect(
            engine.canPlaceShapeAnywhere(piece),
            isTrue,
            reason: 'Crowded hand piece ${piece.name} was unplaceable (iter $i)',
          );
        }
      }
    });

    test('mid-tray rescue rewrites dead leftover pieces', () {
      final engine = GridEngine();
      for (int r = 0; r < 8; r++) {
        for (int c = 0; c < 8; c++) {
          if (!(r == 7 && (c == 0 || c == 1))) {
            engine.grid[r][c].occupy(color: Colors.teal);
          }
        }
      }

      final big = PolyominoShape(
        id: 'dead_big',
        name: 'square_2x2',
        matrix: const [
          [1, 1],
          [1, 1],
        ],
        baseColor: Colors.red,
      );
      final slots = <PolyominoShape?>[big, big, null];
      expect(engine.canPlaceShapeAnywhere(big), isFalse);

      final spawner = ShapeSpawnerEngine(rng: Random(3));
      final changed = spawner.rescueUnplaceableSlots(
        gridEngine: engine,
        slots: slots,
      );
      expect(changed, isTrue);
      expect(slots[0], isNotNull);
      expect(engine.canPlaceShapeAnywhere(slots[0]!), isTrue);
      expect(engine.canPlaceShapeAnywhere(slots[1]!), isTrue);
    });
  });

  group('Ice shatter', () {
    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      await AppPrefs.instance.init();
    });

    test('permanent ice breaks when its row clears', () {
      final engine = GridEngine();
      const row = 3;
      for (int c = 0; c < 8; c++) {
        if (c == 3) {
          engine.grid[row][c].occupy(color: Colors.cyan);
          engine.grid[row][c].frozenTurns = 999;
        } else {
          engine.grid[row][c].occupy(color: Colors.blue);
        }
      }

      final mono = PolyominoShape(
        id: 'mono',
        name: 'mono',
        matrix: const [
          [1],
        ],
        baseColor: Colors.green,
      );
      final result = engine.placeShape(mono, 0, 0, const []);
      expect(result.linesCleared, greaterThan(0));
      expect(engine.grid[row][3].frozenTurns, 0);
      expect(engine.grid[row][3].isOccupied, isFalse);
    });

    test('permanent ice breaks when adjacent row clears', () {
      final engine = GridEngine();
      engine.grid[1][1].occupy(color: Colors.cyan);
      engine.grid[1][1].frozenTurns = 999;

      for (int c = 0; c < 8; c++) {
        engine.grid[0][c].occupy(color: Colors.blue);
      }

      final mono = PolyominoShape(
        id: 'mono',
        name: 'mono',
        matrix: const [
          [1],
        ],
        baseColor: Colors.green,
      );
      engine.placeShape(mono, 7, 0, const []);
      expect(engine.grid[1][1].frozenTurns, 0);
      expect(engine.grid[1][1].isOccupied, isFalse);
    });
  });

  group('AdventureLevelManager', () {
    test('score target victory & star thresholds', () {
      final level = AdventureLevel.getLevel(1); // score target warmup
      expect(level.objectiveType, ObjectiveType.scoreTarget);

      final win = AdventureLevelManager.instance.evaluate(
        level,
        AdventureRunState(
          score: level.targetScore,
          movesLeft: (level.maxMoves * 0.4).round(),
          maxMoves: level.maxMoves,
          iceRemaining: 0,
          linesCleared: 0,
          bossHp: 1,
          handBlocked: false,
          outOfMoves: false,
        ),
      );
      expect(win.kind, AdventureOutcomeKind.victory);
      expect(win.stars, 3);

      final defeat = AdventureLevelManager.instance.evaluate(
        level,
        const AdventureRunState(
          score: 0,
          movesLeft: 0,
          maxMoves: 30,
          iceRemaining: 0,
          linesCleared: 0,
          bossHp: 1,
          handBlocked: false,
          outOfMoves: true,
        ),
      );
      expect(defeat.kind, AdventureOutcomeKind.defeat);
      expect(defeat.defeatReasonKey, 'moves');
    });

    test('ice & line objectives', () {
      final iceLevel = AdventureLevel.getLevel(3);
      expect(iceLevel.objectiveType, ObjectiveType.shatterIce);
      final iceWin = AdventureLevelManager.instance.evaluate(
        iceLevel,
        AdventureRunState(
          score: 0,
          movesLeft: 10,
          maxMoves: iceLevel.maxMoves,
          iceRemaining: 0,
          linesCleared: 0,
          bossHp: 1,
          handBlocked: false,
          outOfMoves: false,
        ),
      );
      expect(iceWin.kind, AdventureOutcomeKind.victory);

      final lineLevel = AdventureLevel.getLevel(2);
      expect(lineLevel.objectiveType, ObjectiveType.clearLines);
      final lineWin = AdventureLevelManager.instance.evaluate(
        lineLevel,
        AdventureRunState(
          score: 0,
          movesLeft: 5,
          maxMoves: lineLevel.maxMoves,
          iceRemaining: 0,
          linesCleared: lineLevel.targetLineCount,
          bossHp: 1,
          handBlocked: false,
          outOfMoves: false,
        ),
      );
      expect(lineWin.kind, AdventureOutcomeKind.victory);
    });
  });
}
