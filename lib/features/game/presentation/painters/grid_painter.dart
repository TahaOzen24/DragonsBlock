import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/game_theme.dart';
import '../../../dragon/models/dragon.dart';
import '../../../shop/models/board_skin.dart';
import '../../models/block_skin_style.dart';
import '../../models/board_era.dart';
import '../../models/clearing_animation.dart';
import '../../models/grid_cell.dart';
import '../../models/polyomino_shape.dart';
import 'block_skin_painter.dart';

/// High-performance GPU-optimized Grid Painter.
/// Features dynamic block-type-specific explosion animations (Fire, Frost, Lightning, Void, Gemstone, Jelly),
/// hover line completion highlights, and silky-smooth 120 FPS rendering.
class GridPainter extends CustomPainter {
  final List<List<GridCell>> grid;
  final PolyominoShape? draggingShape;
  final Point<int>? previewHoverPos;
  final bool isPreviewValid;
  final double animationProgress;
  final BoardSkin? activeSkin;
  final List<Point<int>>? recentPlacements;
  final double placementFlash;
  final BlockSkinStyle blockSkinStyle;
  final Color? overrideEmptyCellColor;
  final Color? overrideBorderColor;

  // Performance & Progression Parameters
  final List<ClearingCellAnim> clearingCells;
  final List<ClearingLineSlice> clearingLineSlices;
  final BoardEra currentEra;
  final bool hasAllClearCrest;
  final double allClearSurgeProgress;

  // Line Clear Preview (Lined-up highlights)
  final List<int> previewClearingRows;
  final List<int> previewClearingCols;

  GridPainter({
    required this.grid,
    this.draggingShape,
    this.previewHoverPos,
    this.isPreviewValid = true,
    this.animationProgress = 0.0,
    this.activeSkin,
    this.recentPlacements,
    this.placementFlash = 0.0,
    this.blockSkinStyle = BlockSkinStyle.minimalGlass,
    this.overrideEmptyCellColor,
    this.overrideBorderColor,
    this.clearingCells = const [],
    this.clearingLineSlices = const [],
    this.currentEra = BoardEra.bronze,
    this.hasAllClearCrest = false,
    this.allClearSurgeProgress = 0.0,
    this.previewClearingRows = const [],
    this.previewClearingCols = const [],
    this.activeSurgePalette,
    this.surgeProgress = 0.0,
    this.isMonochrome = false,
    this.uniformColor,
    this.previousUniformColor,
    this.nearCompleteRows = const [],
    this.nearCompleteCols = const [],
    super.repaint,
  });

  final List<Color>? activeSurgePalette;
  final double surgeProgress;
  final bool isMonochrome;
  final Color? uniformColor;
  final Color? previousUniformColor;
  final List<int> nearCompleteRows;
  final List<int> nearCompleteCols;

  static final Paint _groovePaint = Paint()
    ..color = const Color(0xFF1E293B).withValues(alpha: 0.9)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0;

  static final Paint _cellGlowPaint = Paint()..style = PaintingStyle.stroke;
  static final Paint _cellFillPaint = Paint()..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    final double cellSize = size.width / 8;
    final double padding = 2.5;
    final double pulse = sin(animationProgress * 2 * pi);

    // 1. Draw Grid Background Cells
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final rect = Rect.fromLTWH(
          c * cellSize + padding,
          r * cellSize + padding,
          cellSize - padding * 2,
          cellSize - padding * 2,
        );
        final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(2.5));
        final cell = grid[r][c];

        if (cell.isOccupied) {
          final isRecent = recentPlacements != null &&
              recentPlacements!.any((pt) => pt.x == r && pt.y == c);
          final bool isPreviewClearing = (previewClearingRows.contains(r) || previewClearingCols.contains(c)) &&
              draggingShape != null && previewHoverPos != null && isPreviewValid;
          final double flashBoost = isPreviewClearing ? (0.45 + pulse * 0.25).clamp(0.0, 1.0) : (isRecent ? placementFlash : 0.0);
          _drawOccupiedBlock(canvas, rrect, cell, pulse, flashBoost, r, c);
          if (cell.isFrozen) {
            _drawFrozenOverlay(canvas, rrect, pulse);
          }
        } else {
          _drawEmptyCell(canvas, rrect, r, c, pulse);
          if (cell.isFrozen) {
            _drawFrozenOverlay(canvas, rrect, pulse);
          }
        }
      }
    }

    // 2. Draw Block-Type-Specific Explosion VFX for Clearing Cells
    if (clearingCells.isNotEmpty) {
      _drawClearingCells(canvas, cellSize, padding);
    }

    // 3. Draw Elemental & Dynamic Laser Slice Blades
    if (clearingLineSlices.isNotEmpty) {
      _drawClearingLineSlices(canvas, size, cellSize);
    }

    // 4. Draw Line Cleared Anticipation Glow Halos
    _drawClearingLinePreviews(canvas, size, cellSize, padding, pulse);

    // 5. Draw Shape Placement Drag & Drop Preview Ghost
    if (draggingShape != null && previewHoverPos != null) {
      _drawPlacementPreview(canvas, cellSize, padding, pulse);
    }


    // 7. Draw Board Era Frame & Optional All-Clear Crest
    _drawBoardEraBorder(canvas, size);

    // 8. Draw All-Clear Golden Holy Flare Wave (if triggered)
    if (allClearSurgeProgress > 0.0 && allClearSurgeProgress < 1.0) {
      _drawAllClearSurge(canvas, size);
    }
  }

  static final Paint _emptyBgPaint = Paint()..style = PaintingStyle.fill;
  static final Paint _emptyGroovePaint = Paint()
    ..color = Colors.black.withValues(alpha: 0.22)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0;
  static final Paint _emptyRimPaint = Paint()
    ..color = const Color(0xFF334155).withValues(alpha: 0.18)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.8;

  void _drawEmptyCell(Canvas canvas, RRect rrect, int r, int c, double pulse) {
    final baseColor = overrideEmptyCellColor ?? const Color(0xFF0F172A);
    final rect = rrect.outerRect;

    // 1. Recessed Base Tray Socket Fill
    _emptyBgPaint.color = baseColor;
    canvas.drawRRect(rrect, _emptyBgPaint);

    // 2. Top & Left Inner Shadow (Recessed Socket Depth)
    final shadowColor = Colors.black.withValues(alpha: 0.42);
    _emptyGroovePaint.color = shadowColor;
    _emptyGroovePaint.strokeWidth = 1.3;
    // Top inner shadow
    canvas.drawLine(
      Offset(rect.left + 2.0, rect.top + 0.8),
      Offset(rect.right - 2.0, rect.top + 0.8),
      _emptyGroovePaint,
    );
    // Left inner shadow
    canvas.drawLine(
      Offset(rect.left + 0.8, rect.top + 2.0),
      Offset(rect.left + 0.8, rect.bottom - 2.0),
      _emptyGroovePaint,
    );

    // 3. Bottom & Right Subtle Groove Rim (Gives beveled socket floor)
    final rimColor = const Color(0xFF334155).withValues(alpha: 0.22);
    _emptyRimPaint.color = rimColor;
    _emptyRimPaint.strokeWidth = 1.0;
    // Bottom inner rim
    canvas.drawLine(
      Offset(rect.left + 2.0, rect.bottom - 0.8),
      Offset(rect.right - 2.0, rect.bottom - 0.8),
      _emptyRimPaint,
    );
    // Right inner rim
    canvas.drawLine(
      Offset(rect.right - 0.8, rect.top + 2.0),
      Offset(rect.right - 0.8, rect.bottom - 2.0),
      _emptyRimPaint,
    );
  }

  void _drawOccupiedBlock(Canvas canvas, RRect rrect, GridCell cell, double pulse, double flash, int r, int c) {
    Color finalColor = cell.blockColor ?? GameTheme.neonCyan;

    // Buttery-smooth diagonal wave color transition (no jitter, no flash spikes)
    final waveOffset = (r + c) / 14.0; // 0.0 (top-left) to 1.0 (bottom-right)
    final cellProgress = ((surgeProgress - waveOffset * 0.35) / 0.65).clamp(0.0, 1.0);
    final easedProgress = Curves.easeInOutCubic.transform(cellProgress);

    if (isMonochrome && uniformColor != null) {
      if (surgeProgress < 1.0) {
        final fromColor = cell.classicColor ?? cell.blockColor ?? uniformColor!;
        finalColor = Color.lerp(fromColor, uniformColor!, easedProgress)!;
      } else {
        finalColor = uniformColor!;
      }
    } else if (previousUniformColor != null && surgeProgress < 1.0) {
      final targetColor = cell.classicColor ?? cell.blockColor ?? GameTheme.neonCyan;
      finalColor = Color.lerp(previousUniformColor!, targetColor, easedProgress)!;
    } else {
      finalColor = cell.blockColor ?? GameTheme.neonCyan;
    }

    // Juicy Tactile Squash & Stretch Impact Physics (Block Blast Feel)
    Rect drawRect = rrect.outerRect;
    if (flash > 0.01) {
      final squashX = 1.0 + (sin(flash * pi) * 0.14 * flash);
      final squashY = 1.0 - (sin(flash * pi) * 0.09 * flash);
      final impactOffsetY = (sin(flash * pi) * 1.8 * flash);
      drawRect = Rect.fromCenter(
        center: Offset(rrect.outerRect.center.dx, rrect.outerRect.center.dy + impactOffsetY),
        width: rrect.outerRect.width * squashX,
        height: rrect.outerRect.height * squashY,
      );
    }

    BlockSkinPainter.drawBlock(
      canvas: canvas,
      rect: drawRect,
      color: finalColor,
      style: blockSkinStyle,
      pulse: pulse,
      flashAmount: flash * 0.40,
    );
  }

  void _drawFrozenOverlay(Canvas canvas, RRect rrect, double pulse) {
    final rect = rrect.outerRect;
    final frostAlpha = (0.28 + pulse * 0.08).clamp(0.2, 0.4);

    final fill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF67E8F9).withValues(alpha: frostAlpha),
          const Color(0xFF0284C7).withValues(alpha: frostAlpha * 0.55),
        ],
      ).createShader(rect);
    canvas.drawRRect(rrect, fill);

    final rim = Paint()
      ..color = const Color(0xFFE0F2FE).withValues(alpha: 0.55 + pulse * 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    canvas.drawRRect(rrect.deflate(0.6), rim);

    // Crystal shard accents
    final shard = Paint()
      ..color = Colors.white.withValues(alpha: 0.45)
      ..strokeWidth = 1.1
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(rect.left + rect.width * 0.25, rect.top + rect.height * 0.2),
      Offset(rect.left + rect.width * 0.55, rect.top + rect.height * 0.55),
      shard,
    );
    canvas.drawLine(
      Offset(rect.left + rect.width * 0.6, rect.top + rect.height * 0.25),
      Offset(rect.left + rect.width * 0.78, rect.top + rect.height * 0.48),
      shard,
    );
  }

  // ─── Block Clear Animations (Tiered Block Blast & Dragon Awakening VFX) ─────

  void _drawClearingCells(Canvas canvas, double cellSize, double padding) {
    for (final anim in clearingCells) {
      switch (anim.vfxStyle) {
        case ClearVfxStyle.candyPop:
          _drawCandyPopExplosion(canvas, anim, cellSize, padding);
          break;
        case ClearVfxStyle.laserVaporize:
          _drawLaserVaporizeExplosion(canvas, anim, cellSize, padding);
          break;
        case ClearVfxStyle.supernova:
          _drawSupernovaExplosion(canvas, anim, cellSize, padding);
          break;
        case ClearVfxStyle.dragonElemental:
          _drawDragonElementalExplosion(canvas, anim, cellSize, padding);
          break;
        case ClearVfxStyle.melt:
          _drawMeltExplosion(canvas, anim, cellSize, padding);
          break;
        case ClearVfxStyle.shatter:
          _drawShatterExplosion(canvas, anim, cellSize, padding);
          break;
      }
    }
  }

  // 🍬 1. Block Blast Signature Candy Pop (Juicy Chiclet Shards & Crisp Shockwave)
  void _drawCandyPopExplosion(Canvas canvas, ClearingCellAnim anim, double cellSize, double padding) {
    final double p = anim.localProgress;
    final double cx = anim.c * cellSize + cellSize / 2;
    final double cy = anim.r * cellSize + cellSize / 2;
    final double halfW = (cellSize - padding * 2) / 2;

    if (anim.progress <= anim.delayNormalized) {
      final blockRect = Rect.fromCenter(center: Offset(cx, cy), width: halfW * 2, height: halfW * 2);
      BlockSkinPainter.drawBlock(
        canvas: canvas,
        rect: blockRect,
        color: anim.color,
        style: anim.style,
      );
      return;
    }

    // 1. Pop Impulse: Block slightly swells up before bursting with bright white sheen
    if (p <= 0.18) {
      final double popP = p / 0.18;
      final double popScale = 1.0 + sin(popP * pi) * 0.15;
      final blockRect = Rect.fromCenter(
        center: Offset(cx, cy),
        width: halfW * 2 * popScale,
        height: halfW * 2 * popScale,
      );
      BlockSkinPainter.drawBlock(
        canvas: canvas,
        rect: blockRect,
        color: anim.color,
        style: anim.style,
        flashAmount: (1.0 - popP) * 0.70,
      );
    }

    // 2. Expanding Crisp Shockwave Ring
    if (p <= 0.55) {
      final double ringP = p / 0.55;
      final double ringRadius = halfW * (0.35 + ringP * 1.55);
      final double ringAlpha = (1.0 - ringP) * 0.75;
      canvas.drawCircle(
        Offset(cx, cy),
        ringRadius,
        Paint()
          ..color = Color.lerp(anim.color, Colors.white, 0.45)!.withValues(alpha: ringAlpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4 * (1.0 - ringP),
      );
    }

    // 3. Radiant Diamond Flare Sparkle
    if (p <= 0.32) {
      final double starP = p / 0.32;
      _drawDiamondStar(
        canvas: canvas,
        cx: cx,
        cy: cy,
        size: halfW * 1.25 * (1.0 - starP),
        color: anim.color,
        intensity: (1.0 - starP),
      );
    }

    // 4. Four Candy Chiclets Tumbling Outward
    final double chicletW = halfW * 0.84;
    final double spread = p * (halfW * 1.6);
    final double gravity = p * p * (cellSize * 2.2);
    final double shardAlpha = (1.0 - pow(p, 1.4)).clamp(0.0, 1.0);
    final double shardScale = (1.0 - p * 0.42).clamp(0.0, 1.0);

    if (shardAlpha > 0.01 && shardScale > 0.01) {
      final shardDirs = [
        Offset(-spread - anim.tumbleDx * 0.5, -spread * 0.85 + gravity),
        Offset(spread + anim.tumbleDx * 0.5, -spread * 0.85 + gravity),
        Offset(-spread * 0.8 - anim.tumbleDx * 0.3, spread * 0.65 + gravity),
        Offset(spread * 0.8 + anim.tumbleDx * 0.3, spread * 0.65 + gravity),
      ];
      final shardRotations = [
        -anim.tiltAngle * 2.2 * (1.0 + p),
        anim.tiltAngle * 2.2 * (1.0 + p),
        -anim.tiltAngle * 1.6 * (1.0 + p),
        anim.tiltAngle * 1.6 * (1.0 + p),
      ];

      for (int i = 0; i < 4; i++) {
        final pos = Offset(cx, cy) + shardDirs[i];
        canvas.save();
        canvas.translate(pos.dx, pos.dy);
        canvas.rotate(shardRotations[i]);
        canvas.scale(shardScale, shardScale);

        final shardRect = Rect.fromCenter(center: Offset.zero, width: chicletW, height: chicletW);
        BlockSkinPainter.drawBlock(
          canvas: canvas,
          rect: shardRect,
          color: anim.color,
          style: anim.style,
          opacity: shardAlpha,
          flashAmount: (1.0 - p * 3.0).clamp(0.0, 1.0),
        );
        canvas.restore();
      }
    }
  }

  // ⚡ 2. High-Voltage Laser Vaporize (2-3 Lines Clear)
  void _drawLaserVaporizeExplosion(Canvas canvas, ClearingCellAnim anim, double cellSize, double padding) {
    final double p = anim.localProgress;
    final double cx = anim.c * cellSize + cellSize / 2;
    final double cy = anim.r * cellSize + cellSize / 2;
    final double halfW = (cellSize - padding * 2) / 2;

    if (anim.progress <= anim.delayNormalized) {
      final blockRect = Rect.fromCenter(center: Offset(cx, cy), width: halfW * 2, height: halfW * 2);
      BlockSkinPainter.drawBlock(
        canvas: canvas,
        rect: blockRect,
        color: anim.color,
        style: anim.style,
      );
      return;
    }

    // 1. Cross-Axis High-Voltage Laser Cutting Beams
    if (p <= 0.35) {
      final double laserP = p / 0.35;
      final double beamAlpha = (1.0 - laserP) * 0.90;
      final double beamWidth = halfW * 1.8 * (1.0 - laserP * 0.3);
      final beamPaint = Paint()
        ..color = Color.lerp(anim.color, Colors.cyanAccent, 0.5)!.withValues(alpha: beamAlpha)
        ..strokeWidth = 3.2 * (1.0 - laserP)
        ..style = PaintingStyle.stroke;

      canvas.drawLine(Offset(cx - beamWidth, cy), Offset(cx + beamWidth, cy), beamPaint);
      canvas.drawLine(Offset(cx, cy - beamWidth), Offset(cx, cy + beamWidth), beamPaint);

      final corePaint = Paint()
        ..color = Colors.white.withValues(alpha: beamAlpha)
        ..strokeWidth = 1.2 * (1.0 - laserP)
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(cx - beamWidth * 0.8, cy), Offset(cx + beamWidth * 0.8, cy), corePaint);
      canvas.drawLine(Offset(cx, cy - beamWidth * 0.8), Offset(cx, cy + beamWidth * 0.8), corePaint);
    }

    // 2. Radiant Star Flare
    if (p <= 0.40) {
      final double starP = p / 0.40;
      _drawDiamondStar(
        canvas: canvas,
        cx: cx,
        cy: cy,
        size: halfW * 1.6 * (1.0 - starP),
        color: Colors.cyanAccent,
        intensity: (1.0 - starP),
      );
    }

    // 3. Upward Anti-Gravity Plasma Vapor Sparks
    if (p <= 0.85) {
      final double vaporAlpha = (1.0 - p / 0.85).clamp(0.0, 1.0);
      final sparkPaint = Paint()..style = PaintingStyle.fill;

      for (int i = 0; i < 6; i++) {
        final double angle = (i / 6.0) * pi * 2;
        final double sparkSpread = p * halfW * 0.85;
        final double rise = -p * cellSize * 2.2;
        final double sx = cx + cos(angle) * sparkSpread + sin(p * 12 + i) * (halfW * 0.3);
        final double sy = cy + sin(angle) * (sparkSpread * 0.35) + rise;
        final double sparkRadius = (2.2 * (1.0 - p * 0.7)).clamp(0.5, 2.5);

        sparkPaint.color = Color.lerp(anim.color, Colors.white, 0.45)!.withValues(alpha: vaporAlpha);
        canvas.drawCircle(Offset(sx, sy), sparkRadius, sparkPaint);
      }
    }

    // 4. Two Splitting Laser-Sliced Halves Dissolving
    final double splitP = p;
    final double splitDist = splitP * halfW * 0.9;
    final double splitAlpha = (1.0 - splitP * 1.5).clamp(0.0, 1.0);

    if (splitAlpha > 0.01) {
      canvas.save();
      canvas.translate(cx, cy - splitDist);
      canvas.scale(1.0 - splitP * 0.3, 1.0 - splitP * 0.3);
      BlockSkinPainter.drawBlock(
        canvas: canvas,
        rect: Rect.fromCenter(center: Offset.zero, width: halfW * 1.8, height: halfW * 0.85),
        color: anim.color,
        style: anim.style,
        opacity: splitAlpha,
        flashAmount: (1.0 - splitP * 2.5).clamp(0.0, 1.0),
      );
      canvas.restore();

      canvas.save();
      canvas.translate(cx, cy + splitDist);
      canvas.scale(1.0 - splitP * 0.3, 1.0 - splitP * 0.3);
      BlockSkinPainter.drawBlock(
        canvas: canvas,
        rect: Rect.fromCenter(center: Offset.zero, width: halfW * 1.8, height: halfW * 0.85),
        color: anim.color,
        style: anim.style,
        opacity: splitAlpha,
        flashAmount: (1.0 - splitP * 2.5).clamp(0.0, 1.0),
      );
      canvas.restore();
    }
  }

  // 🌌 3. Supernova Mega Clear (4+ Lines or 5+ Combo Streak)
  void _drawSupernovaExplosion(Canvas canvas, ClearingCellAnim anim, double cellSize, double padding) {
    final double p = anim.localProgress;
    final double cx = anim.c * cellSize + cellSize / 2;
    final double cy = anim.r * cellSize + cellSize / 2;
    final double halfW = (cellSize - padding * 2) / 2;

    if (anim.progress <= anim.delayNormalized) {
      final blockRect = Rect.fromCenter(center: Offset(cx, cy), width: halfW * 2, height: halfW * 2);
      BlockSkinPainter.drawBlock(
        canvas: canvas,
        rect: blockRect,
        color: anim.color,
        style: anim.style,
      );
      return;
    }

    // 1. Blinding Incandescent Core Flash (Zero-cost dual-ring glow, zero MaskFilter overhead)
    if (p <= 0.22) {
      final double flashP = p / 0.22;
      final double flashAlpha = (1.0 - flashP) * 0.95;
      final double r = halfW * (0.8 + flashP * 0.6);
      canvas.drawCircle(
        Offset(cx, cy),
        r * 1.35,
        Paint()..color = Colors.white.withValues(alpha: flashAlpha * 0.25),
      );
      canvas.drawCircle(
        Offset(cx, cy),
        r,
        Paint()..color = Colors.white.withValues(alpha: flashAlpha * 0.85),
      );
    }

    // 2. Dual Expanding Shockwave Rings (Outer Golden Corona + Inner High-Voltage Ring)
    if (p <= 0.65) {
      final double ringP = p / 0.65;
      final double outerR = halfW * (0.4 + ringP * 2.6);
      final double innerR = halfW * (0.2 + ringP * 1.8);
      final double outerAlpha = (1.0 - ringP) * 0.85;

      canvas.drawCircle(
        Offset(cx, cy),
        outerR,
        Paint()
          ..color = const Color(0xFFFFD700).withValues(alpha: outerAlpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0 * (1.0 - ringP),
      );

      canvas.drawCircle(
        Offset(cx, cy),
        innerR,
        Paint()
          ..color = Colors.white.withValues(alpha: outerAlpha * 0.9)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0 * (1.0 - ringP),
      );
    }

    // 3. Giant Radiant Golden 8-Point Starburst Lens Flare
    if (p <= 0.45) {
      final double starP = p / 0.45;
      _drawDiamondStar(
        canvas: canvas,
        cx: cx,
        cy: cy,
        size: halfW * 2.4 * (1.0 - starP),
        color: const Color(0xFFFFD700),
        intensity: (1.0 - starP),
      );
    }

    // 4. Radial Octagonal Fireworks Embers (8 radiant trails exploding outward)
    final double spread = p * (halfW * 2.6);
    final double emberAlpha = (1.0 - pow(p, 1.2)).clamp(0.0, 1.0);

    if (emberAlpha > 0.01) {
      final emberPaint = Paint()..style = PaintingStyle.fill;
      final trailPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      for (int i = 0; i < 8; i++) {
        final double angle = (i * pi / 4.0) + (p * 0.4);
        final double curX = cx + cos(angle) * spread;
        final double curY = cy + sin(angle) * spread;
        final double prevX = cx + cos(angle) * (spread * 0.65);
        final double prevY = cy + sin(angle) * (spread * 0.65);

        trailPaint
          ..color = const Color(0xFFFFE066).withValues(alpha: emberAlpha * 0.6)
          ..strokeWidth = 2.5 * (1.0 - p);
        canvas.drawLine(Offset(prevX, prevY), Offset(curX, curY), trailPaint);

        emberPaint.color = Colors.white.withValues(alpha: emberAlpha);
        canvas.drawCircle(Offset(curX, curY), 2.8 * (1.0 - p * 0.5), emberPaint);
        emberPaint.color = const Color(0xFFFFD700).withValues(alpha: emberAlpha * 0.8);
        canvas.drawCircle(Offset(curX, curY), 4.2 * (1.0 - p * 0.5), emberPaint);
      }
    }

  }

  // 🐉 4. Dragon Signature Elemental Blast (Fire, Ice, Storm, Earth)
  void _drawDragonElementalExplosion(Canvas canvas, ClearingCellAnim anim, double cellSize, double padding) {
    final double p = anim.localProgress;
    final double cx = anim.c * cellSize + cellSize / 2;
    final double cy = anim.r * cellSize + cellSize / 2;
    final double halfW = (cellSize - padding * 2) / 2;

    if (anim.progress <= anim.delayNormalized) {
      final blockRect = Rect.fromCenter(center: Offset(cx, cy), width: halfW * 2, height: halfW * 2);
      BlockSkinPainter.drawBlock(
        canvas: canvas,
        rect: blockRect,
        color: anim.color,
        style: anim.style,
      );
      return;
    }

    final eggType = anim.dragonType ?? DragonEggType.fire;
    final elemColor = anim.elementalColor ?? anim.color;

    switch (eggType) {
      case DragonEggType.fire:
        if (p <= 0.60) {
          final double ringP = p / 0.60;
          canvas.drawCircle(
            Offset(cx, cy),
            halfW * (0.3 + ringP * 1.8),
            Paint()
              ..color = const Color(0xFFFF5722).withValues(alpha: (1.0 - ringP) * 0.8)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3.5 * (1.0 - ringP),
          );
        }
        final double fireAlpha = (1.0 - p).clamp(0.0, 1.0);
        for (int i = 0; i < 6; i++) {
          final double angle = (i / 6.0) * pi * 2 + p * 4.0;
          final double dist = p * halfW * 1.6;
          final double fx = cx + cos(angle) * dist;
          final double fy = cy + sin(angle) * (dist * 0.5) - p * cellSize * 2.0;
          canvas.drawCircle(
            Offset(fx, fy),
            3.0 * (1.0 - p * 0.6),
            Paint()..color = (i.isEven ? const Color(0xFFFF9800) : const Color(0xFFFFEB3B)).withValues(alpha: fireAlpha),
          );
        }
        break;

      case DragonEggType.ice:
        if (p <= 0.55) {
          final double frostP = p / 0.55;
          final frostPaint = Paint()
            ..color = const Color(0xFF00E5FF).withValues(alpha: (1.0 - frostP) * 0.9)
            ..strokeWidth = 2.2 * (1.0 - frostP)
            ..style = PaintingStyle.stroke;
          for (int i = 0; i < 6; i++) {
            final double angle = i * pi / 3.0;
            final double r1 = halfW * 0.3;
            final double r2 = halfW * (0.4 + frostP * 1.8);
            canvas.drawLine(
              Offset(cx + cos(angle) * r1, cy + sin(angle) * r1),
              Offset(cx + cos(angle) * r2, cy + sin(angle) * r2),
              frostPaint,
            );
          }
        }
        canvas.drawCircle(
          Offset(cx, cy),
          halfW * (0.35 + p * 1.5),
          Paint()
            ..color = const Color(0xFFE0F7FA).withValues(alpha: (1.0 - p) * 0.6)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.0 * (1.0 - p),
        );
        break;

      case DragonEggType.storm:
        if (p <= 0.50) {
          final double stormP = p / 0.50;
          final boltPaint = Paint()
            ..color = const Color(0xFFE040FB).withValues(alpha: (1.0 - stormP) * 0.9)
            ..strokeWidth = 2.4 * (1.0 - stormP)
            ..style = PaintingStyle.stroke;

          for (int i = 0; i < 4; i++) {
            final double baseAngle = i * (pi / 2.0);
            final double dist = halfW * (0.3 + stormP * 1.8);
            final path = Path()
              ..moveTo(cx, cy)
              ..lineTo(cx + cos(baseAngle + 0.2) * (dist * 0.5), cy + sin(baseAngle + 0.2) * (dist * 0.5))
              ..lineTo(cx + cos(baseAngle - 0.2) * (dist * 0.8), cy + sin(baseAngle - 0.2) * (dist * 0.8))
              ..lineTo(cx + cos(baseAngle) * dist, cy + sin(baseAngle) * dist);
            canvas.drawPath(path, boltPaint);
          }
        }
        break;

      case DragonEggType.earth:
        if (p <= 0.60) {
          final double earthP = p / 0.60;
          canvas.drawCircle(
            Offset(cx, cy),
            halfW * (0.35 + earthP * 1.6),
            Paint()
              ..color = const Color(0xFF00E676).withValues(alpha: (1.0 - earthP) * 0.8)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3.2 * (1.0 - earthP),
          );
        }
        final double spread = p * (halfW * 1.4);
        final double gravity = p * p * (cellSize * 2.8);
        final double shardAlpha = (1.0 - p).clamp(0.0, 1.0);
        for (int i = 0; i < 4; i++) {
          final double angle = i * pi / 2.0 + pi / 4.0;
          final double sx = cx + cos(angle) * spread;
          final double sy = cy + sin(angle) * spread + gravity;
          canvas.drawRect(
            Rect.fromCenter(center: Offset(sx, sy), width: halfW * 0.5, height: halfW * 0.5),
            Paint()..color = (i.isEven ? const Color(0xFF00C853) : const Color(0xFFFFD700)).withValues(alpha: shardAlpha),
          );
        }
        break;
    }

    if (p <= 0.35) {
      final double starP = p / 0.35;
      _drawDiamondStar(
        canvas: canvas,
        cx: cx,
        cy: cy,
        size: halfW * 1.5 * (1.0 - starP),
        color: elemColor,
        intensity: (1.0 - starP),
      );
    }

  }

  // 💎 5. Authentic 4-Quadrant Physical Crystal Shatter & Burst FX
  void _drawShatterExplosion(Canvas canvas, ClearingCellAnim anim, double cellSize, double padding) {
    final double p = anim.localProgress;
    final double cx = anim.c * cellSize + cellSize / 2;
    final double cy = anim.r * cellSize + cellSize / 2;
    final double halfW = (cellSize - padding * 2) / 2;

    if (anim.progress <= anim.delayNormalized) {
      final blockRect = Rect.fromCenter(center: Offset(cx, cy), width: halfW * 2, height: halfW * 2);
      BlockSkinPainter.drawBlock(
        canvas: canvas,
        rect: blockRect,
        color: anim.color,
        style: anim.style,
      );
      return;
    }

    // 1. Expanding Shockwave Energy Ring
    if (p <= 0.55) {
      final double ringP = p / 0.55;
      final double ringRadius = halfW * (0.35 + ringP * 1.6);
      final double ringAlpha = (1.0 - ringP) * 0.70;
      canvas.drawCircle(
        Offset(cx, cy),
        ringRadius,
        Paint()
          ..color = Color.lerp(anim.color, Colors.white, 0.40)!.withValues(alpha: ringAlpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4 * (1.0 - ringP),
      );
    }

    // 2. Radiant Starburst Diamond Flash
    if (p <= 0.35) {
      final double starP = p / 0.35;
      final double starSize = halfW * (1.2 * (1.0 - starP));
      final double starAlpha = (1.0 - starP);
      _drawDiamondStar(
        canvas: canvas,
        cx: cx,
        cy: cy,
        size: starSize,
        color: anim.color,
        intensity: starAlpha,
      );
    }

    // 3. Four Separate Fractured Gemstone Shards Flying & Tumbling
    final double shardW = halfW * 0.86;
    final double spread = p * (halfW * 1.5);
    final double gravity = p * p * (cellSize * 2.0);
    final double shardAlpha = (1.0 - pow(p, 1.4)).clamp(0.0, 1.0);
    final double shardScale = (1.0 - p * 0.45).clamp(0.0, 1.0);

    if (shardAlpha > 0.01 && shardScale > 0.01) {
      final shardDirs = [
        Offset(-spread - anim.tumbleDx * 0.6, -spread * 0.8 + gravity),
        Offset(spread + anim.tumbleDx * 0.6, -spread * 0.8 + gravity),
        Offset(-spread * 0.8 - anim.tumbleDx * 0.4, spread * 0.6 + gravity),
        Offset(spread * 0.8 + anim.tumbleDx * 0.4, spread * 0.6 + gravity),
      ];
      final shardRotations = [
        -anim.tiltAngle * 2.5 * (1.0 + p),
        anim.tiltAngle * 2.5 * (1.0 + p),
        -anim.tiltAngle * 1.8 * (1.0 + p),
        anim.tiltAngle * 1.8 * (1.0 + p),
      ];

      for (int i = 0; i < 4; i++) {
        final pos = Offset(cx, cy) + shardDirs[i];
        canvas.save();
        canvas.translate(pos.dx, pos.dy);
        canvas.rotate(shardRotations[i]);
        canvas.scale(shardScale, shardScale);

        final shardRect = Rect.fromCenter(center: Offset.zero, width: shardW, height: shardW);
        BlockSkinPainter.drawBlock(
          canvas: canvas,
          rect: shardRect,
          color: anim.color,
          style: anim.style,
          opacity: shardAlpha,
          flashAmount: (1.0 - p * 3.0).clamp(0.0, 1.0),
        );
        canvas.restore();
      }
    }

  }

  // 🫠 6. Authentic Soft Jelly Melt & Droop Dissolution
  void _drawMeltExplosion(Canvas canvas, ClearingCellAnim anim, double cellSize, double padding) {
    final double p = anim.localProgress;
    final double cx = anim.c * cellSize + cellSize / 2;
    final double cy = anim.r * cellSize + cellSize / 2;
    final double halfW = (cellSize - padding * 2) / 2;

    if (anim.progress <= anim.delayNormalized) {
      final blockRect = Rect.fromCenter(center: Offset(cx, cy), width: halfW * 2, height: halfW * 2);
      BlockSkinPainter.drawBlock(
        canvas: canvas,
        rect: blockRect,
        color: anim.color,
        style: anim.style,
      );
      return;
    }

    final double meltAlpha = (1.0 - pow(p, 1.2)).clamp(0.0, 1.0);
    final double droopY = p * cellSize * 0.65;
    final double scaleX = (1.0 - p * 0.35).clamp(0.1, 1.0);
    final double scaleY = (1.0 + p * 0.40).clamp(1.0, 1.5);

    if (meltAlpha > 0.01) {
      canvas.save();
      canvas.translate(cx, cy + droopY);
      canvas.scale(scaleX, scaleY);
      final blockRect = Rect.fromCenter(center: Offset.zero, width: halfW * 2, height: halfW * 2);
      BlockSkinPainter.drawBlock(
        canvas: canvas,
        rect: blockRect,
        color: anim.color,
        style: anim.style,
        opacity: meltAlpha,
      );
      canvas.restore();

      final dropPaint = Paint()..color = anim.color.withValues(alpha: meltAlpha * 0.8);
      for (int i = 0; i < 3; i++) {
        final double dropP = (p * 1.4 - i * 0.15).clamp(0.0, 1.0);
        if (dropP > 0.0) {
          final double dx = (i - 1) * (halfW * 0.6);
          final double dy = cy + halfW + dropP * dropP * (cellSize * 1.5);
          canvas.drawCircle(Offset(cx + dx, dy), (halfW * 0.22 * (1.0 - dropP)).clamp(0.5, halfW), dropPaint);
        }
      }
    }

  }

  /// Vector 4-pointed Starburst Diamond Lens Flare with hot white core & tapered spikes
  void _drawDiamondStar({
    required Canvas canvas,
    required double cx,
    required double cy,
    required double size,
    required Color color,
    required double intensity,
  }) {
    if (size <= 0.5 || intensity <= 0.01) return;

    final double alpha = intensity.clamp(0.0, 1.0);
    final starPaint = Paint()
      ..color = Colors.white.withValues(alpha: (alpha * 0.95).clamp(0.0, 1.0))
      ..style = PaintingStyle.fill;

    // 1. Central hot white glow
    canvas.drawCircle(
      Offset(cx, cy),
      size * 0.16,
      Paint()..color = Colors.white.withValues(alpha: (alpha * 0.90).clamp(0.0, 1.0)),
    );
    canvas.drawCircle(
      Offset(cx, cy),
      size * 0.32,
      Paint()..color = color.withValues(alpha: (alpha * 0.45).clamp(0.0, 1.0)),
    );

    // 2. Primary Horizontal & Vertical Diamond Spikes
    final halfLen = size * 0.50;
    final halfThickness = size * 0.08;

    final crossPath = Path()
      ..moveTo(cx - halfLen, cy)
      ..lineTo(cx, cy - halfThickness)
      ..lineTo(cx + halfLen, cy)
      ..lineTo(cx, cy + halfThickness)
      ..close()
      ..moveTo(cx, cy - halfLen)
      ..lineTo(cx + halfThickness, cy)
      ..lineTo(cx, cy + halfLen)
      ..lineTo(cx - halfThickness, cy)
      ..close();

    canvas.drawPath(crossPath, starPaint);

    // 3. Diagonal 45-degree smaller secondary sparkles
    final diagLen = halfLen * 0.55;
    final diagThickness = halfThickness * 0.65;

    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(pi / 4);

    final diagPath = Path()
      ..moveTo(-diagLen, 0)
      ..lineTo(0, -diagThickness)
      ..lineTo(diagLen, 0)
      ..lineTo(0, diagThickness)
      ..close()
      ..moveTo(0, -diagLen)
      ..lineTo(diagThickness, 0)
      ..lineTo(0, diagLen)
      ..lineTo(-diagThickness, 0)
      ..close();

    final diagPaint = Paint()
      ..color = color.withValues(alpha: (alpha * 0.75).clamp(0.0, 1.0))
      ..style = PaintingStyle.fill;
    canvas.drawPath(diagPath, diagPaint);
    canvas.restore();
  }


  // ─── Innovative Hyper-Glossy Laser Blade Slices ────────────────────────────

  void _drawClearingLineSlices(Canvas canvas, Size size, double cellSize) {
    for (final slice in clearingLineSlices) {
      final double progress = slice.progress.clamp(0.0, 1.0);
      final double alpha = (1.0 - progress).clamp(0.0, 1.0);
      final double ease = sin(progress * pi / 2);

      // 1. Broad Ambient Laser Glow Aura
      final auraPaint = Paint()
        ..color = slice.color.withValues(alpha: (alpha * 0.45).clamp(0.0, 1.0))
        ..strokeWidth = 10.0 * (1.0 - progress * 0.5)
        ..strokeCap = StrokeCap.round;

      // 2. Saturated Neon Laser Core Blade
      final slicePaint = Paint()
        ..color = slice.color.withValues(alpha: (alpha * 0.92).clamp(0.0, 1.0))
        ..strokeWidth = 4.8 * (1.0 - progress * 0.35)
        ..strokeCap = StrokeCap.round;

      // 3. Hot White Laser Center Filament
      final filamentPaint = Paint()
        ..color = Colors.white.withValues(alpha: (alpha * 0.98).clamp(0.0, 1.0))
        ..strokeWidth = 2.0 * (1.0 - progress * 0.25)
        ..strokeCap = StrokeCap.round;

      if (slice.isRow) {
        final double y = slice.index * cellSize + cellSize / 2;
        final double expandX = (size.width / 2) * (0.05 + ease * 0.95);
        final p1 = Offset(size.width / 2 - expandX, y);
        final p2 = Offset(size.width / 2 + expandX, y);

        canvas.drawLine(p1, p2, auraPaint);
        canvas.drawLine(p1, p2, slicePaint);
        canvas.drawLine(p1, p2, filamentPaint);

        // Traveling Diamond Star Flares at Blade Tips
        final flareSize = cellSize * 0.85 * (1.0 - progress * 0.5);
        _drawDiamondStar(
          canvas: canvas,
          cx: p1.dx,
          cy: p1.dy,
          size: flareSize,
          color: slice.color,
          intensity: alpha,
        );
        _drawDiamondStar(
          canvas: canvas,
          cx: p2.dx,
          cy: p2.dy,
          size: flareSize,
          color: slice.color,
          intensity: alpha,
        );
      } else {
        final double x = slice.index * cellSize + cellSize / 2;
        final double expandY = (size.height / 2) * (0.05 + ease * 0.95);
        final p1 = Offset(x, size.height / 2 - expandY);
        final p2 = Offset(x, size.height / 2 + expandY);

        canvas.drawLine(p1, p2, auraPaint);
        canvas.drawLine(p1, p2, slicePaint);
        canvas.drawLine(p1, p2, filamentPaint);

        // Traveling Diamond Star Flares at Blade Tips
        final flareSize = cellSize * 0.85 * (1.0 - progress * 0.5);
        _drawDiamondStar(
          canvas: canvas,
          cx: p1.dx,
          cy: p1.dy,
          size: flareSize,
          color: slice.color,
          intensity: alpha,
        );
        _drawDiamondStar(
          canvas: canvas,
          cx: p2.dx,
          cy: p2.dy,
          size: flareSize,
          color: slice.color,
          intensity: alpha,
        );
      }
    }
  }

  void _drawClearingLinePreviews(Canvas canvas, Size size, double cellSize, double padding, double pulse) {
    if (previewClearingRows.isEmpty && previewClearingCols.isEmpty) return;
    if (draggingShape == null || previewHoverPos == null || !isPreviewValid) return;

    final double pulseAlpha = (0.65 + pulse * 0.25).clamp(0.0, 1.0);
    const goldAura = Color(0xFFFFD54F);
    const whiteAura = Colors.white;

    // Collect all cells that will be detonated by line clear
    final Set<int> clearingCellIndices = {};
    for (final r in previewClearingRows) {
      for (int c = 0; c < 8; c++) {
        clearingCellIndices.add(r * 8 + c);
      }
    }
    for (final c in previewClearingCols) {
      for (int r = 0; r < 8; r++) {
        clearingCellIndices.add(r * 8 + c);
      }
    }

    for (final idx in clearingCellIndices) {
      final r = idx ~/ 8;
      final c = idx % 8;
      final bool isIntersection = previewClearingRows.contains(r) && previewClearingCols.contains(c);

      final cellRect = Rect.fromLTWH(
        c * cellSize + padding,
        r * cellSize + padding,
        cellSize - padding * 2,
        cellSize - padding * 2,
      );
      const radius = Radius.circular(4.0);
      final rrect = RRect.fromRectAndRadius(cellRect, radius);
      final cell = grid[r][c];

      // 1. Radiant Anticipation Beam Fill (Whole line surges with golden-white light)
      final auraColor = isIntersection ? whiteAura : goldAura;
      _cellFillPaint.color = auraColor.withValues(
        alpha: (isIntersection ? 0.35 : 0.22) * pulseAlpha,
      );
      canvas.drawRRect(rrect, _cellFillPaint);

      // 2. High-Voltage Glowing Border
      _cellGlowPaint.color = auraColor.withValues(
        alpha: (isIntersection ? 0.95 : 0.70) * pulseAlpha,
      );
      _cellGlowPaint.strokeWidth = isIntersection ? (2.8 + pulse * 0.8) : (2.0 + pulse * 0.5);
      canvas.drawRRect(rrect, _cellGlowPaint);

      // 3. Existing Block White Flash Glow (Blocks in this line surge with energy)
      if (cell.isOccupied) {
        final hotFlashPaint = Paint()
          ..color = Colors.white.withValues(alpha: (0.35 * pulseAlpha).clamp(0.0, 1.0))
          ..style = PaintingStyle.fill;
        canvas.drawRRect(rrect, hotFlashPaint);
      }

      // 4. Center Radiant Diamond Star for Intersections
      if (isIntersection) {
        final center = cellRect.center;
        final flareSize = cellSize * 0.70 * (0.85 + pulse * 0.15);
        _drawDiamondStar(
          canvas: canvas,
          cx: center.dx,
          cy: center.dy,
          size: flareSize,
          color: goldAura,
          intensity: pulseAlpha,
        );
      }
    }
  }

  void _drawPlacementPreview(Canvas canvas, double cellSize, double padding, double pulse) {
    final shape = draggingShape!;
    final hover = previewHoverPos!;
    final double pulseMod = (pulse.abs() * 0.10);
    final double previewAlpha = (isPreviewValid ? (0.72 + pulseMod) : 0.40).clamp(0.0, 1.0);
    final Color displayColor = isPreviewValid ? shape.baseColor : const Color(0xFFFF3355);

    for (int r = 0; r < shape.rowCount; r++) {
      for (int c = 0; c < shape.colCount; c++) {
        if (shape.matrix[r][c] == 1) {
          final targetR = hover.x + r;
          final targetC = hover.y + c;

          if (targetR >= 0 && targetR < 8 && targetC >= 0 && targetC < 8) {
            final rect = Rect.fromLTWH(
              targetC * cellSize + padding,
              targetR * cellSize + padding,
              cellSize - padding * 2,
              cellSize - padding * 2,
            );
            const radius = Radius.circular(4.0);
            final rrect = RRect.fromRectAndRadius(rect, radius);

            if (isPreviewValid) {
              // 1. Soft magnetic contact shadow under preview block
              final shadowPaint = Paint()
                ..color = Colors.black.withValues(alpha: 0.28)
                ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);
              canvas.drawRRect(rrect.shift(const Offset(0, 2.0)), shadowPaint);

              // 2. Vibrant Solid Acrylic Chiclet (Block Blast Feel)
              BlockSkinPainter.drawBlock(
                canvas: canvas,
                rect: rect,
                color: displayColor,
                style: blockSkinStyle,
                opacity: previewAlpha,
              );

              // 3. Subtle outer energy rim
              final glowPaint = Paint()
                ..color = Colors.white.withValues(alpha: (0.35 + pulseMod).clamp(0.0, 1.0))
                ..style = PaintingStyle.stroke
                ..strokeWidth = 1.4;
              canvas.drawRRect(rrect, glowPaint);
            } else {
              // Soft warning ghost for invalid placement
              final warnPaint = Paint()
                ..color = const Color(0xFFFF5C7A).withValues(alpha: 0.28);
              canvas.drawRRect(rrect, warnPaint);

              final warnBorder = Paint()
                ..color = const Color(0xFFFF5C7A).withValues(alpha: 0.70)
                ..style = PaintingStyle.stroke
                ..strokeWidth = 1.6;
              canvas.drawRRect(rrect, warnBorder);
            }
          }
        }
      }
    }
  }

  void _drawBoardEraBorder(Canvas canvas, Size size) {
    final frameRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(16),
    );

    final frameColor = overrideBorderColor ?? currentEra.frameBorderColor;
    final highlightPaint = Paint()
      ..color = frameColor.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;
    canvas.drawRRect(frameRect, highlightPaint);

    canvas.drawRRect(frameRect.deflate(2.0), _groovePaint);

    if (hasAllClearCrest) {
      final crestPaint = Paint()
        ..color = const Color(0xFFFDE047).withValues(alpha: 0.90)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(size.width / 2, 2.0), 3.5, crestPaint);
    }
  }

  void _drawAllClearSurge(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width * 0.70;
    final radius = maxRadius * allClearSurgeProgress;
    final alpha = (1.0 - allClearSurgeProgress).clamp(0.0, 1.0);

    final flarePaint = Paint()
      ..color = const Color(0xFFFDE047).withValues(alpha: alpha * 0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5 * (1.0 - allClearSurgeProgress * 0.5);
    canvas.drawCircle(center, radius, flarePaint);
  }

  @override
  bool shouldRepaint(covariant GridPainter oldDelegate) {
    return oldDelegate.surgeProgress != surgeProgress ||
        oldDelegate.animationProgress != animationProgress ||
        oldDelegate.grid != grid ||
        oldDelegate.draggingShape != draggingShape ||
        oldDelegate.previewHoverPos != previewHoverPos ||
        oldDelegate.placementFlash != placementFlash ||
        oldDelegate.clearingCells.isNotEmpty ||
        clearingCells.isNotEmpty ||
        oldDelegate.clearingLineSlices.isNotEmpty ||
        clearingLineSlices.isNotEmpty ||
        oldDelegate.allClearSurgeProgress != allClearSurgeProgress ||
        oldDelegate.previewClearingRows != previewClearingRows ||
        oldDelegate.previewClearingCols != previewClearingCols ||
        oldDelegate.currentEra != currentEra ||
        oldDelegate.blockSkinStyle != blockSkinStyle ||
        oldDelegate.isMonochrome != isMonochrome ||
        oldDelegate.uniformColor != uniformColor ||
        oldDelegate.previousUniformColor != previousUniformColor ||
        oldDelegate.overrideEmptyCellColor != overrideEmptyCellColor ||
        oldDelegate.overrideBorderColor != overrideBorderColor;
  }
}
