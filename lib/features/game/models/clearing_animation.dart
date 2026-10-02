import 'dart:math';
import 'package:flutter/material.dart';
import '../../dragon/models/dragon.dart';
import 'block_skin_style.dart';

enum ClearVfxStyle {
  candyPop,       // 🍬 Block Blast Klasik Şeker Küpü Patlaması (Candy Chiclet Burst)
  laserVaporize,  // ⚡ 2-3 Hat Lazer Buharlaşması (High-voltage Laser Slice & Stream)
  supernova,      // 🌌 4+ Hat / Mega Kombo Süpernova Patlaması (Radial Starburst & Fireworks)
  dragonElemental,// 🐉 Ejderha Nefesi Patlaması (Ateş Alevi / Buz Kristali / Yıldırım / Altın Toprak)
  shatter,        // 💎 Klasik Kristal Kırılma
  melt,           // 🫠 Eriyip Gitme
}

/// Precomputed faceted shard geometry to avoid per-frame allocations.
class CrystalShardTemplate {
  final double angle;
  final double speed;
  final double rotationSpeed;
  final double sizeMultiplier;
  final List<Offset> normalizedPoints;

  const CrystalShardTemplate({
    required this.angle,
    required this.speed,
    required this.rotationSpeed,
    required this.sizeMultiplier,
    required this.normalizedPoints,
  });

  // 4 Asymmetrical Sets of Faceted Crystal Shards (5-6 polygonal shards each)
  static final List<List<CrystalShardTemplate>> shardSets = [
    [
      CrystalShardTemplate(
        angle: -pi * 0.75,
        speed: 1.2,
        rotationSpeed: -4.0,
        sizeMultiplier: 0.45,
        normalizedPoints: [Offset(-0.4, -0.4), Offset(0.2, -0.5), Offset(0.0, 0.1), Offset(-0.4, 0.2)],
      ),
      CrystalShardTemplate(
        angle: -pi * 0.25,
        speed: 1.35,
        rotationSpeed: 3.5,
        sizeMultiplier: 0.42,
        normalizedPoints: [Offset(-0.1, -0.5), Offset(0.5, -0.4), Offset(0.4, 0.1), Offset(0.0, 0.0)],
      ),
      CrystalShardTemplate(
        angle: pi * 0.30,
        speed: 1.1,
        rotationSpeed: -2.8,
        sizeMultiplier: 0.40,
        normalizedPoints: [Offset(0.0, 0.0), Offset(0.4, 0.1), Offset(0.3, 0.5), Offset(-0.1, 0.4)],
      ),
      CrystalShardTemplate(
        angle: pi * 0.65,
        speed: 1.3,
        rotationSpeed: -3.5,
        sizeMultiplier: 0.36,
        normalizedPoints: [Offset(0.0, -0.4), Offset(0.4, 0.2), Offset(-0.3, 0.4)],
      ),
      CrystalShardTemplate(
        angle: -pi * 0.95,
        speed: 1.7,
        rotationSpeed: 2.9,
        sizeMultiplier: 0.40,
        normalizedPoints: [Offset(-0.4, -0.3), Offset(0.2, -0.4), Offset(0.4, 0.3), Offset(-0.2, 0.4)],
      ),
    ],
    // Set 1
    [
      CrystalShardTemplate(
        angle: -pi * 0.85,
        speed: 1.5,
        rotationSpeed: -3.0,
        sizeMultiplier: 0.39,
        normalizedPoints: [Offset(-0.4, -0.5), Offset(0.2, -0.4), Offset(0.0, 0.3), Offset(-0.3, 0.2)],
      ),
      CrystalShardTemplate(
        angle: -pi * 0.10,
        speed: 1.7,
        rotationSpeed: 3.4,
        sizeMultiplier: 0.45,
        normalizedPoints: [Offset(-0.1, -0.6), Offset(0.4, -0.2), Offset(0.3, 0.3)],
      ),
      CrystalShardTemplate(
        angle: pi * 0.35,
        speed: 1.3,
        rotationSpeed: -2.6,
        sizeMultiplier: 0.37,
        normalizedPoints: [Offset(-0.3, -0.1), Offset(0.3, 0.0), Offset(0.1, 0.5), Offset(-0.4, 0.2)],
      ),
      CrystalShardTemplate(
        angle: pi * 0.80,
        speed: 1.6,
        rotationSpeed: 2.8,
        sizeMultiplier: 0.41,
        normalizedPoints: [Offset(0.1, -0.4), Offset(0.5, 0.3), Offset(-0.2, 0.3)],
      ),
      CrystalShardTemplate(
        angle: -pi * 0.45,
        speed: 1.4,
        rotationSpeed: -3.6,
        sizeMultiplier: 0.38,
        normalizedPoints: [Offset(-0.3, -0.3), Offset(0.3, -0.5), Offset(0.2, 0.3), Offset(-0.3, 0.4)],
      ),
    ],
  ];
}

/// Animation model for clearing cells tailored to the active block skin style.
class ClearingCellAnim {
  final int r;
  final int c;
  final Color color;
  final BlockSkinStyle style;
  final ClearVfxStyle vfxStyle;
  final double delayNormalized; // 0.0 to ~0.35 (staggered cascade delay)
  double progress; // 0.0 to 1.0
  bool hasTriggeredParticleBurst;
  final List<CrystalShardTemplate> shards;
  final double tiltAngle;
  final double tumbleDx;
  final DragonEggType? dragonType;
  final Color? elementalColor;

  ClearingCellAnim({
    required this.r,
    required this.c,
    required this.color,
    this.style = BlockSkinStyle.minimalGlass,
    this.vfxStyle = ClearVfxStyle.candyPop,
    this.delayNormalized = 0.0,
    this.progress = 0.0,
    this.hasTriggeredParticleBurst = false,
    this.dragonType,
    this.elementalColor,
  })  : shards = CrystalShardTemplate.shardSets[(r * 8 + c) % CrystalShardTemplate.shardSets.length],
        tiltAngle = (((r * 7 + c * 13) % 25) - 12) * (pi / 180.0), // -12° to +12° tilt
        tumbleDx = (((r * 11 + c * 17) % 19) - 9) * 0.8; // subtle horizontal drift

  /// The active local phase progress (0.0 to 1.0) after accounting for stagger delay
  double get localProgress {
    if (progress <= delayNormalized) return 0.0;
    return ((progress - delayNormalized) / (1.0 - delayNormalized)).clamp(0.0, 1.0);
  }

  bool get isFinished => progress >= 1.0;
}

/// Dynamic laser blade slice drawn across an entire cleared row or column.
class ClearingLineSlice {
  final bool isRow;
  final int index;
  final Color color;
  double progress; // 0.0 to 1.0

  ClearingLineSlice({
    required this.isRow,
    required this.index,
    required this.color,
    this.progress = 0.0,
  });

  bool get isFinished => progress >= 1.0;
}
