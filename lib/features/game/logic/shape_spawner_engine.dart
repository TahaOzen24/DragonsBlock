import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/config/game_config.dart';
import '../models/polyomino_shape.dart';
import 'grid_engine.dart';

/// Broad visual family — used to limit duplicate archetypes in one hand.
enum ShapeFamily {
  line,
  lShape,
  block,
  branch,
}

class ShapeArchetype {
  final String id;
  final ShapeFamily family;
  final int totalBlocks;
  final List<List<List<int>>> variants;

  const ShapeArchetype({
    required this.id,
    required this.family,
    required this.totalBlocks,
    required this.variants,
  });
}

class _PlaceableOption {
  final ShapeArchetype archetype;
  final List<List<int>> variant;
  final int clearPotential;

  const _PlaceableOption({
    required this.archetype,
    required this.variant,
    required this.clearPotential,
  });
}

/// Board-aware spawner with hard anti-softlock:
/// at least one dealt piece is always placeable when any catalog piece fits.
class ShapeSpawnerEngine {
  final Random _rng;
  final ShapeDroughtTracker _droughtTracker = ShapeDroughtTracker();

  ShapeSpawnerEngine({Random? rng}) : _rng = rng ?? Random();

  ShapeDroughtTracker get droughtTracker => _droughtTracker;

  static const ShapeArchetype line2 = ShapeArchetype(
    id: 'line_2',
    family: ShapeFamily.line,
    totalBlocks: 2,
    variants: [
      [[1, 1]],
      [[1], [1]],
    ],
  );

  static const ShapeArchetype line3 = ShapeArchetype(
    id: 'line_3',
    family: ShapeFamily.line,
    totalBlocks: 3,
    variants: [
      [[1, 1, 1]],
      [[1], [1], [1]],
    ],
  );

  static const ShapeArchetype line4 = ShapeArchetype(
    id: 'line_4',
    family: ShapeFamily.line,
    totalBlocks: 4,
    variants: [
      [[1, 1, 1, 1]],
      [[1], [1], [1], [1]],
    ],
  );

  static const ShapeArchetype corner3 = ShapeArchetype(
    id: 'corner_3',
    family: ShapeFamily.lShape,
    totalBlocks: 3,
    variants: [
      [[1, 1], [1, 0]],
      [[1, 1], [0, 1]],
      [[1, 0], [1, 1]],
      [[0, 1], [1, 1]],
    ],
  );

  static const ShapeArchetype lShape4 = ShapeArchetype(
    id: 'l_shape_4',
    family: ShapeFamily.lShape,
    totalBlocks: 4,
    variants: [
      [[1, 0], [1, 0], [1, 1]],
      [[0, 1], [0, 1], [1, 1]],
      [[1, 1], [1, 0], [1, 0]],
      [[1, 1], [0, 1], [0, 1]],
    ],
  );

  static const ShapeArchetype square2x2 = ShapeArchetype(
    id: 'square_2x2',
    family: ShapeFamily.block,
    totalBlocks: 4,
    variants: [
      [[1, 1], [1, 1]],
    ],
  );

  static const ShapeArchetype tShape = ShapeArchetype(
    id: 't_shape',
    family: ShapeFamily.branch,
    totalBlocks: 4,
    variants: [
      [[1, 1, 1], [0, 1, 0]],
      [[0, 1, 0], [1, 1, 1]],
      [[1, 0], [1, 1], [1, 0]],
      [[0, 1], [1, 1], [0, 1]],
    ],
  );

  static const ShapeArchetype line5 = ShapeArchetype(
    id: 'line_5',
    family: ShapeFamily.line,
    totalBlocks: 5,
    variants: [
      [[1, 1, 1, 1, 1]],
      [[1], [1], [1], [1], [1]],
    ],
  );

  static const ShapeArchetype square3x3 = ShapeArchetype(
    id: 'square_3x3',
    family: ShapeFamily.block,
    totalBlocks: 9,
    variants: [
      [
        [1, 1, 1],
        [1, 1, 1],
        [1, 1, 1],
      ],
    ],
  );

  static const ShapeArchetype corner5 = ShapeArchetype(
    id: 'corner_5',
    family: ShapeFamily.lShape,
    totalBlocks: 5,
    variants: [
      [
        [1, 0, 0],
        [1, 0, 0],
        [1, 1, 1],
      ],
      [
        [0, 0, 1],
        [0, 0, 1],
        [1, 1, 1],
      ],
      [
        [1, 1, 1],
        [1, 0, 0],
        [1, 0, 0],
      ],
      [
        [1, 1, 1],
        [0, 0, 1],
        [0, 0, 1],
      ],
    ],
  );

  static const ShapeArchetype rect2x3 = ShapeArchetype(
    id: 'rect_2x3',
    family: ShapeFamily.block,
    totalBlocks: 6,
    variants: [
      [
        [1, 1, 1],
        [1, 1, 1],
      ],
      [
        [1, 1],
        [1, 1],
        [1, 1],
      ],
    ],
  );

  static const List<ShapeArchetype> allArchetypes = [
    line2,
    line3,
    line4,
    line5,
    corner3,
    lShape4,
    corner5,
    square2x2,
    square3x3,
    rect2x3,
    tShape,
  ];

  /// Compact rescue pool — preferred when board is tight.
  static const List<ShapeArchetype> rescueArchetypes = [
    line2,
    line3,
    corner3,
    square2x2,
  ];

  // ─── Placeability scan ───────────────────────────────────────────────────

  List<_PlaceableOption> _enumeratePlaceable(
    GridEngine gridEngine, {
    Set<ShapeFamily>? excludeFamilies,
    List<ShapeArchetype>? pool,
  }) {
    final options = <_PlaceableOption>[];
    final archetypes = pool ?? allArchetypes;

    for (final arch in archetypes) {
      if (excludeFamilies != null && excludeFamilies.contains(arch.family)) continue;
      for (final variant in arch.variants) {
        final test = PolyominoShape(
          id: 'scan',
          name: arch.id,
          matrix: variant,
          baseColor: Colors.white,
        );
        if (!gridEngine.canPlaceShapeAnywhere(test)) continue;

        int bestClear = 0;
        for (int r = 0; r <= GridEngine.gridSize - test.rowCount; r++) {
          for (int c = 0; c <= GridEngine.gridSize - test.colCount; c++) {
            if (!gridEngine.canPlace(test, r, c)) continue;
            final clears = gridEngine.getRowsClearedIfPlaced(test, r, c).length +
                gridEngine.getColsClearedIfPlaced(test, r, c).length;
            if (clears > bestClear) bestClear = clears;
          }
        }
        options.add(_PlaceableOption(
          archetype: arch,
          variant: variant,
          clearPotential: bestClear,
        ));
      }
    }
    return options;
  }

  bool boardHasAnyLegalCatalogMove(GridEngine gridEngine) {
    return _enumeratePlaceable(gridEngine, pool: rescueArchetypes).isNotEmpty ||
        _enumeratePlaceable(gridEngine).isNotEmpty;
  }

  double _weightFor(
    ShapeArchetype arch, {
    required double occupancy,
    required bool isNewPlayer,
    required bool forceSmall,
    required int clearPotential,
  }) {
    double w = 10;

    // Size vs board fullness
    if (occupancy >= GameTuning.crowdedThreshold) {
      if (arch.totalBlocks <= 2) {
        w *= 3.5;
      } else if (arch.totalBlocks <= 3) {
        w *= 2.2;
      } else if (arch.totalBlocks >= 5) {
        w *= 0.15;
      } else {
        w *= 0.55;
      }
    } else if (occupancy < GameTuning.spaciousThreshold) {
      if (arch.totalBlocks >= 5) {
        w *= isNewPlayer ? 0.4 : 1.4;
      } else if (arch.totalBlocks <= 2) {
        w *= 0.7;
      }
    } else {
      if (arch.totalBlocks >= 6) w *= 0.6;
      if (arch.totalBlocks == 4) w *= 1.15;
    }

    if (forceSmall && arch.totalBlocks <= 3) w *= 2.5;
    if (isNewPlayer && arch.totalBlocks >= 5) w *= 0.2;

    // Prefer pieces that clear lines when droughting
    if (clearPotential > 0) {
      w *= 1.0 + clearPotential * 0.85;
    }

    if (droughtTracker.isFamilyOverused(arch.family.name)) {
      w *= 0.45;
    }

    return w.clamp(0.05, 100.0);
  }

  _PlaceableOption _pickWeighted(List<_PlaceableOption> options, {
    required double occupancy,
    required bool isNewPlayer,
    required bool forceSmall,
  }) {
    assert(options.isNotEmpty);
    double total = 0;
    final weights = <double>[];
    for (final o in options) {
      final w = _weightFor(
        o.archetype,
        occupancy: occupancy,
        isNewPlayer: isNewPlayer,
        forceSmall: forceSmall,
        clearPotential: o.clearPotential,
      );
      weights.add(w);
      total += w;
    }
    var roll = _rng.nextDouble() * total;
    for (int i = 0; i < options.length; i++) {
      roll -= weights[i];
      if (roll <= 0) return options[i];
    }
    return options.last;
  }

  // ─── Public API ──────────────────────────────────────────────────────────

  List<PolyominoShape> generateBalancedHand({
    required GridEngine gridEngine,
    required int currentScore,
    required int movesCount,
    List<Color>? forcedPalette,
    int gamesPlayed = 0,
  }) {
    final isNewPlayer = gamesPlayed < 3;
    final occupancy = gridEngine.occupancyRate;
    final isCrowded = occupancy >= GameTuning.crowdedThreshold;
    final forceSmall = isCrowded ||
        droughtTracker.needsSmallPiece ||
        droughtTracker.needsRescue;

    // Pristine / empty board starter
    if (gridEngine.isPristineHandQueued || gridEngine.isBoardCompletelyEmpty()) {
      gridEngine.isPristineHandQueued = false;
      return _buildPristineHand(isNewPlayer, forcedPalette);
    }

    final usedFamilies = <ShapeFamily>{};
    final hand = <PolyominoShape>[];

    // SLOT 0 — HARD GUARANTEE: must be placeable if anything is placeable
    final placeable = _enumeratePlaceable(
      gridEngine,
      pool: forceSmall ? rescueArchetypes : null,
    );
    final placeableAll = placeable.isNotEmpty
        ? placeable
        : _enumeratePlaceable(gridEngine);

    if (placeableAll.isEmpty) {
      // True board death — no catalog piece fits. Deal rescue shapes anyway;
      // caller will detect softlock / game over.
      return [
        _buildFromVariant(line2, line2.variants.first, forcedPalette),
        _buildFromVariant(corner3, corner3.variants.first, forcedPalette),
        _buildFromVariant(line3, line3.variants.first, forcedPalette),
      ];
    }

    // Prefer a clearing move early / on drought
    _PlaceableOption guaranteed;
    final clearers = placeableAll.where((o) => o.clearPotential > 0).toList();
    final wantClear = droughtTracker.needsSolver ||
        movesCount < GameTuning.guaranteedClearMoves ||
        (isCrowded && _rng.nextDouble() < 0.7) ||
        (!isCrowded && _rng.nextDouble() < 0.45);

    if (wantClear && clearers.isNotEmpty) {
      guaranteed = _pickWeighted(
        clearers,
        occupancy: occupancy,
        isNewPlayer: isNewPlayer,
        forceSmall: forceSmall,
      );
    } else {
      guaranteed = _pickWeighted(
        placeableAll,
        occupancy: occupancy,
        isNewPlayer: isNewPlayer,
        forceSmall: forceSmall,
      );
    }

    usedFamilies.add(guaranteed.archetype.family);
    hand.add(_buildFromVariant(guaranteed.archetype, guaranteed.variant, forcedPalette));

    // SLOTS 1–2 — on crowded boards, only deal placeable pieces (no softlock leftovers).
    // On open boards, light tension is OK but still prefer placeable when available.
    while (hand.length < GameTuning.shapesPerHand) {
      final remainingPlaceable = _enumeratePlaceable(
        gridEngine,
        excludeFamilies: usedFamilies,
        pool: forceSmall ? [...rescueArchetypes, line4, tShape, lShape4] : null,
      );
      final anyPlaceable = remainingPlaceable.isNotEmpty
          ? remainingPlaceable
          : _enumeratePlaceable(
              gridEngine,
              pool: forceSmall ? rescueArchetypes : null,
            );
      final placeablePool = anyPlaceable.isNotEmpty
          ? anyPlaceable
          : _enumeratePlaceable(gridEngine);

      final mustBePlaceable = forceSmall || isCrowded;
      final preferPlaceable = mustBePlaceable || _rng.nextDouble() < 0.88;

      if (preferPlaceable && placeablePool.isNotEmpty) {
        final pick = _pickWeighted(
          placeablePool,
          occupancy: occupancy,
          isNewPlayer: isNewPlayer,
          forceSmall: forceSmall,
        );
        usedFamilies.add(pick.archetype.family);
        hand.add(_buildFromVariant(pick.archetype, pick.variant, forcedPalette));
        continue;
      }

      if (mustBePlaceable) {
        // No tension on crowded boards — pad with guaranteed placeable duplicates if needed
        final pick = placeableAll[_rng.nextInt(placeableAll.length)];
        hand.add(_buildFromVariant(pick.archetype, pick.variant, forcedPalette));
        continue;
      }

      // Open-board tension piece (may be unplaceable)
      final pool = allArchetypes
          .where((a) => !usedFamilies.contains(a.family))
          .where((a) => !isNewPlayer || a.totalBlocks <= 4)
          .toList();
      if (pool.isEmpty) {
        final pick = placeableAll[_rng.nextInt(placeableAll.length)];
        hand.add(_buildFromVariant(pick.archetype, pick.variant, forcedPalette));
        continue;
      }

      double total = 0;
      final ws = <double>[];
      for (final a in pool) {
        final w = _weightFor(
          a,
          occupancy: occupancy,
          isNewPlayer: isNewPlayer,
          forceSmall: forceSmall,
          clearPotential: 0,
        );
        ws.add(w);
        total += w;
      }
      var roll = _rng.nextDouble() * total;
      ShapeArchetype chosen = pool.last;
      for (int i = 0; i < pool.length; i++) {
        roll -= ws[i];
        if (roll <= 0) {
          chosen = pool[i];
          break;
        }
      }
      usedFamilies.add(chosen.family);

      final placeableVariants = _enumeratePlaceable(
        gridEngine,
        pool: [chosen],
      );
      final variant = placeableVariants.isNotEmpty
          ? placeableVariants[_rng.nextInt(placeableVariants.length)].variant
          : chosen.variants[_rng.nextInt(chosen.variants.length)];
      hand.add(_buildFromVariant(chosen, variant, forcedPalette));
    }

    while (hand.length < GameTuning.shapesPerHand) {
      final pick = placeableAll[_rng.nextInt(placeableAll.length)];
      hand.add(_buildFromVariant(pick.archetype, pick.variant, forcedPalette));
    }

    // Final safety: every slot that can be made placeable should be placeable when crowded
    if (forceSmall || isCrowded) {
      for (int i = 0; i < hand.length; i++) {
        if (gridEngine.canPlaceShapeAnywhere(hand[i])) continue;
        final pick = placeableAll[_rng.nextInt(placeableAll.length)];
        hand[i] = _buildFromVariant(pick.archetype, pick.variant, forcedPalette);
      }
    }

    if (!hand.any(gridEngine.canPlaceShapeAnywhere)) {
      hand[0] = _buildFromVariant(
        placeableAll.first.archetype,
        placeableAll.first.variant,
        forcedPalette,
      );
    }

    assert(
      placeableAll.isEmpty || hand.any(gridEngine.canPlaceShapeAnywhere),
      'Anti-softlock violated: dealt unplayable hand on a living board',
    );

    return hand;
  }

  List<PolyominoShape> _buildPristineHand(bool isNewPlayer, List<Color>? forcedPalette) {
    final lineArch = (isNewPlayer || _rng.nextBool()) ? line4 : line3;
    final lArch = isNewPlayer ? corner3 : (_rng.nextBool() ? corner3 : lShape4);
    final flexArch = isNewPlayer ? square2x2 : (_rng.nextBool() ? square2x2 : tShape);
    return [
      _buildFromVariant(lineArch, lineArch.variants[_rng.nextInt(lineArch.variants.length)], forcedPalette),
      _buildFromVariant(lArch, lArch.variants[_rng.nextInt(lArch.variants.length)], forcedPalette),
      _buildFromVariant(flexArch, flexArch.variants[_rng.nextInt(flexArch.variants.length)], forcedPalette),
    ];
  }

  /// Replace every unplaceable remaining piece with a placeable one (mid-tray rescue).
  /// Returns true if any slot was rewritten.
  bool rescueUnplaceableSlots({
    required GridEngine gridEngine,
    required List<PolyominoShape?> slots,
    List<Color>? forcedPalette,
  }) {
    final remaining = slots.whereType<PolyominoShape>().toList();
    if (remaining.isEmpty) return false;
    if (gridEngine.hasAnyValidMoves(remaining)) {
      // Still rewrite individual dead slots if board has other legal catalog moves,
      // so the player isn't stuck with 1 placeable + 2 bricks.
      if (!boardHasAnyLegalCatalogMove(gridEngine)) return false;
      var changedSoft = false;
      final options = _enumeratePlaceable(gridEngine, pool: rescueArchetypes);
      final pool = options.isNotEmpty ? options : _enumeratePlaceable(gridEngine);
      if (pool.isEmpty) return false;
      for (int i = 0; i < slots.length; i++) {
        final s = slots[i];
        if (s == null) continue;
        if (gridEngine.canPlaceShapeAnywhere(s)) continue;
        final pick = pool[_rng.nextInt(pool.length)];
        slots[i] = _buildFromVariant(pick.archetype, pick.variant, forcedPalette);
        changedSoft = true;
      }
      return changedSoft;
    }
    if (!boardHasAnyLegalCatalogMove(gridEngine)) return false;

    final options = _enumeratePlaceable(gridEngine, pool: rescueArchetypes);
    final pool = options.isNotEmpty ? options : _enumeratePlaceable(gridEngine);
    if (pool.isEmpty) return false;

    var changed = false;
    for (int i = 0; i < slots.length; i++) {
      final s = slots[i];
      if (s == null) continue;
      if (gridEngine.canPlaceShapeAnywhere(s)) continue;
      final pick = pool[_rng.nextInt(pool.length)];
      slots[i] = _buildFromVariant(pick.archetype, pick.variant, forcedPalette);
      changed = true;
    }
    return changed;
  }

  PolyominoShape _buildFromVariant(
    ShapeArchetype archetype,
    List<List<int>> matrix,
    List<Color>? forcedPalette,
  ) {
    final activePalette = (forcedPalette != null && forcedPalette.isNotEmpty)
        ? forcedPalette
        : PolyominoShape.palette;
    final baseColor = activePalette[_rng.nextInt(activePalette.length)];

    return PolyominoShape(
      id: '${archetype.id}_${DateTime.now().microsecondsSinceEpoch}_${_rng.nextInt(9999)}',
      name: archetype.id,
      matrix: matrix,
      baseColor: baseColor,
    );
  }
}
