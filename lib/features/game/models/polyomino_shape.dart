import 'dart:math';
import 'package:flutter/material.dart';
import '../../block_themes/services/block_theme_manager.dart';

class PolyominoShape {
  final String id;
  final String name;
  final List<List<int>> matrix; // 1 for solid, 0 for empty
  Color baseColor;
  final bool isRainbow;

  PolyominoShape({
    required this.id,
    required this.name,
    required this.matrix,
    required this.baseColor,
    this.isRainbow = false,
  });

  PolyominoShape copyWith({
    Color? baseColor,
    bool? isRainbow,
  }) {
    return PolyominoShape(
      id: id,
      name: name,
      matrix: matrix,
      baseColor: baseColor ?? this.baseColor,
      isRainbow: isRainbow ?? this.isRainbow,
    );
  }

  int get rowCount => matrix.length;
  int get colCount => matrix[0].length;

  int get totalBlocks {
    int count = 0;
    for (var row in matrix) {
      for (var cell in row) {
        if (cell == 1) count++;
      }
    }
    return count;
  }

  PolyominoShape rotated90() {
    final oldRows = rowCount;
    final oldCols = colCount;
    final List<List<int>> newMatrix = List.generate(
      oldCols,
      (newR) => List.generate(oldRows, (newC) => matrix[oldRows - 1 - newC][newR]),
    );

    return PolyominoShape(
      id: '${id}_rot',
      name: name,
      matrix: newMatrix,
      baseColor: baseColor,
      isRainbow: isRainbow,
    );
  }

  static PolyominoShape createRainbowRune() {
    return PolyominoShape(
      id: 'rainbow_${DateTime.now().microsecondsSinceEpoch}',
      name: 'Rainbow Block',
      matrix: [
        [1, 1],
        [1, 1],
      ],
      baseColor: Colors.amberAccent,
      isRainbow: true,
    );
  }

  // Pre-defined Shape Library
  static List<List<List<int>>> get shapeDefinitions => [
        // 1x2 and 2x1
        [
          [1, 1]
        ],
        [
          [1],
          [1]
        ],
        // 1x3 and 3x1
        [
          [1, 1, 1]
        ],
        [
          [1],
          [1],
          [1]
        ],
        // 1x4 and 4x1
        [
          [1, 1, 1, 1]
        ],
        [
          [1],
          [1],
          [1],
          [1]
        ],
        // 1x5 and 5x1
        [
          [1, 1, 1, 1, 1]
        ],
        [
          [1],
          [1],
          [1],
          [1],
          [1]
        ],
        // 2x2 Square
        [
          [1, 1],
          [1, 1]
        ],
        // 3x3 Square
        [
          [1, 1, 1],
          [1, 1, 1],
          [1, 1, 1]
        ],
        // 2x3 and 3x2 Rectangles
        [
          [1, 1, 1],
          [1, 1, 1]
        ],
        [
          [1, 1],
          [1, 1],
          [1, 1]
        ],
        // Small 2x2 L-shapes (Corners)
        [
          [1, 1],
          [1, 0]
        ],
        [
          [1, 1],
          [0, 1]
        ],
        [
          [1, 0],
          [1, 1]
        ],
        [
          [0, 1],
          [1, 1]
        ],
        // 3x3 L-Shapes
        [
          [1, 0, 0],
          [1, 0, 0],
          [1, 1, 1]
        ],
        [
          [0, 0, 1],
          [0, 0, 1],
          [1, 1, 1]
        ],
        [
          [1, 1, 1],
          [1, 0, 0],
          [1, 0, 0]
        ],
        [
          [1, 1, 1],
          [0, 0, 1],
          [0, 0, 1]
        ],
        // T-Shapes
        [
          [1, 1, 1],
          [0, 1, 0]
        ],
        [
          [0, 1, 0],
          [1, 1, 1]
        ],
        [
          [1, 0],
          [1, 1],
          [1, 0]
        ],
        [
          [0, 1],
          [1, 1],
          [0, 1]
        ],
        // Z & S Shapes
        [
          [1, 1, 0],
          [0, 1, 1]
        ],
        [
          [0, 1, 1],
          [1, 1, 0]
        ],
        [
          [1, 0],
          [1, 1],
          [0, 1]
        ],
        [
          [0, 1],
          [1, 1],
          [1, 0]
        ],
      ];

  static const List<Color> defaultPalette = [
    Color(0xFF2563EB), // Royal Cobalt Blue (from reference image)
    Color(0xFF22C55E), // Vibrant Emerald Green (from reference image)
    Color(0xFFF97316), // Radiant Orange
    Color(0xFFEF4444), // Crimson Ruby
    Color(0xFFA855F7), // Royal Violet
    Color(0xFF06B6D4), // Cyan Diamond
    Color(0xFFEAB308), // Amber Topaz
  ];

  static List<Color> get palette {
    try {
      final active = BlockThemeManager.instance.activePalette;
      if (active.isNotEmpty) return active;
    } catch (_) {}
    return defaultPalette;
  }

  // Easy Comfortable Shapes for high clearability early game
  static List<List<List<int>>> get easyComfortableShapes => [
        // 1x2 and 2x1
        [
          [1, 1]
        ],
        [
          [1],
          [1]
        ],
        // 1x3 and 3x1
        [
          [1, 1, 1]
        ],
        [
          [1],
          [1],
          [1]
        ],
        // 2x2 Square
        [
          [1, 1],
          [1, 1]
        ],
        // Small 2x2 Corners
        [
          [1, 1],
          [1, 0]
        ],
        [
          [1, 1],
          [0, 1]
        ],
        [
          [1, 0],
          [1, 1]
        ],
        [
          [0, 1],
          [1, 1]
        ],
        // 1x4 and 4x1 (line-completion helpers)
        [
          [1, 1, 1, 1]
        ],
        [
          [1],
          [1],
          [1],
          [1]
        ],
      ];

  static PolyominoShape generateRandom({
    Random? rng,
    int currentScore = 0,
    int movesCount = 0,
    List<Color>? forcedPalette,
  }) {
    final random = rng ?? Random();

    // Progression curve: In the beginning (score < 600 or moves < 12), favor comfortable clearable pieces
    final bool isEarlyGame = currentScore < 600 || movesCount < 12;
    final bool isMidGame = currentScore >= 600 && currentScore < 1600;

    List<List<int>> shapeMatrix;
    if (isEarlyGame) {
      // 85% chance of easy comfortable piece, 15% standard
      if (random.nextDouble() < 0.85) {
        shapeMatrix = easyComfortableShapes[random.nextInt(easyComfortableShapes.length)];
      } else {
        shapeMatrix = shapeDefinitions[random.nextInt(shapeDefinitions.length)];
      }
    } else if (isMidGame) {
      // 50% comfortable, 50% standard
      if (random.nextDouble() < 0.50) {
        shapeMatrix = easyComfortableShapes[random.nextInt(easyComfortableShapes.length)];
      } else {
        shapeMatrix = shapeDefinitions[random.nextInt(shapeDefinitions.length)];
      }
    } else {
      // Normal full-library distribution later
      shapeMatrix = shapeDefinitions[random.nextInt(shapeDefinitions.length)];
    }

    final activePalette = (forcedPalette != null && forcedPalette.isNotEmpty)
        ? forcedPalette
        : palette;
    final baseColor = activePalette[random.nextInt(activePalette.length)];

    return PolyominoShape(
      id: DateTime.now().microsecondsSinceEpoch.toString() + random.nextInt(999).toString(),
      name: 'Polyomino',
      matrix: shapeMatrix,
      baseColor: baseColor,
    );
  }
}
