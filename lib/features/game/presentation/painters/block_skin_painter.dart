import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/block_skin_style.dart';

/// Crisp Tactile Square Tile Block Rendering System (TAM KARE).
/// Provides 8 distinct, authentic block models:
/// 1. Düz Modern Kare (Minimalist Flat Square Chiclet - clean, flat, tactile square)
/// 2. 3D Kristal Pah (Classic 4-bevel chiclet matching reference photo)
/// 3. Yumuşak Mat Jel (Soft velvety matte square with top pill reflection)
/// 4. Siber Neon Kare (Glowing cyber frame with energetic core)
/// 5. Sırlı Seramik (Glazed porcelain square with diagonal gloss)
/// 6. Ahşap Zanaat (Tactile carved wood block with subtle grain)
/// 7. Kozmik Galaksi (Deep galaxy gradient with sparkling stardust)
/// 8. Sıcak Dokuma (Warm felt square with stitched thread border)
class BlockSkinPainter {
  BlockSkinPainter._();

  static final Paint _sharedFillPaint = Paint()..style = PaintingStyle.fill;
  static final Paint _sharedStrokePaint = Paint()..style = PaintingStyle.stroke;
  static final Paint _sharedLiftShadowPaint = Paint()
    ..style = PaintingStyle.fill
    ..color = const Color(0x75000000)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);
  static final Paint _sharedLiftGlowPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.4;
  static final Paint _sharedContactShadowPaint = Paint()
    ..style = PaintingStyle.fill
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.4);

  static void drawBlock({
    required Canvas canvas,
    required Rect rect,
    required Color color,
    required BlockSkinStyle style,
    double pulse = 0.0,
    double flashAmount = 0.0,
    bool isFeedback = false,
    double opacity = 1.0,
    bool showPlusOne = false,
  }) {
    switch (style) {
      case BlockSkinStyle.minimalGlass:
        _drawFlatModernSquare(
          canvas: canvas,
          rect: rect,
          baseColor: color,
          pulse: pulse,
          flashAmount: flashAmount,
          isFeedback: isFeedback,
          opacity: opacity,
          showPlusOne: showPlusOne,
        );
        break;

      case BlockSkinStyle.gemstone3D:
        _draw4FacetGemstone(
          canvas: canvas,
          rect: rect,
          baseColor: color,
          pulse: pulse,
          flashAmount: flashAmount,
          isFeedback: isFeedback,
          opacity: opacity,
          showPlusOne: showPlusOne,
        );
        break;

      case BlockSkinStyle.softJelly:
        _drawSoftMatteSquare(
          canvas: canvas,
          rect: rect,
          baseColor: color,
          pulse: pulse,
          flashAmount: flashAmount,
          isFeedback: isFeedback,
          opacity: opacity,
          showPlusOne: showPlusOne,
        );
        break;

      case BlockSkinStyle.neonEnergy:
        _drawCyberNeonSquare(
          canvas: canvas,
          rect: rect,
          baseColor: color,
          pulse: pulse,
          flashAmount: flashAmount,
          isFeedback: isFeedback,
          opacity: opacity,
          showPlusOne: showPlusOne,
        );
        break;

      case BlockSkinStyle.zenCeramic:
        _drawGlazedCeramicSquare(
          canvas: canvas,
          rect: rect,
          baseColor: color,
          pulse: pulse,
          flashAmount: flashAmount,
          isFeedback: isFeedback,
          opacity: opacity,
          showPlusOne: showPlusOne,
        );
        break;

      case BlockSkinStyle.nordicWood:
        _drawNordicWoodSquare(
          canvas: canvas,
          rect: rect,
          baseColor: color,
          pulse: pulse,
          flashAmount: flashAmount,
          isFeedback: isFeedback,
          opacity: opacity,
          showPlusOne: showPlusOne,
        );
        break;

      case BlockSkinStyle.cosmicStardust:
        _drawCosmicSquare(
          canvas: canvas,
          rect: rect,
          baseColor: color,
          pulse: pulse,
          flashAmount: flashAmount,
          isFeedback: isFeedback,
          opacity: opacity,
          showPlusOne: showPlusOne,
        );
        break;

      case BlockSkinStyle.cozyWool:
        _drawCozyWoolSquare(
          canvas: canvas,
          rect: rect,
          baseColor: color,
          pulse: pulse,
          flashAmount: flashAmount,
          isFeedback: isFeedback,
          opacity: opacity,
          showPlusOne: showPlusOne,
        );
        break;
    }
  }

  // ---------------------------------------------------------------------------
  // MODEL 1: 🍬 TOK AKRİLİK ŞEKER KARE (Juicy Candy Chiclet - Block Blast Iconic)
  // 100% solid, opaque, rich, vibrant toy-like acrylic square.
  // Crisp top-left light bevel, deep bottom-right shadow bevel, zero milky glass.
  // ---------------------------------------------------------------------------
  static void _drawFlatModernSquare({
    required Canvas canvas,
    required Rect rect,
    required Color baseColor,
    required double pulse,
    required double flashAmount,
    required bool isFeedback,
    required double opacity,
    required bool showPlusOne,
  }) {
    const radius = Radius.circular(4.0);
    final blockRRect = RRect.fromRectAndRadius(rect, radius);

    _drawContactShadow(canvas, blockRRect, baseColor, isFeedback, opacity);

    canvas.save();
    canvas.clipRRect(blockRRect);

    // 1. Solid Vibrant Body with subtle vertical depth (100% opaque, no washed-out white)
    final topBodyColor = Color.lerp(Colors.white, baseColor, 0.12)!.withValues(alpha: opacity);
    final midBodyColor = baseColor.withValues(alpha: opacity);
    final bottomBodyColor = Color.lerp(baseColor, Colors.black, 0.16)!.withValues(alpha: opacity);

    _sharedFillPaint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [topBodyColor, midBodyColor, bottomBodyColor],
      stops: const [0.0, 0.50, 1.0],
    ).createShader(rect);
    canvas.drawRRect(blockRRect, _sharedFillPaint);
    _sharedFillPaint.shader = null;

    // 2. Crisp Light Bevel (Top & Left Edges - gives physical chiclet pop)
    final bevelHighlight = Color.lerp(Colors.white, baseColor, 0.28)!.withValues(alpha: opacity);
    _sharedStrokePaint.color = bevelHighlight;
    _sharedStrokePaint.strokeWidth = 1.8;
    // Top highlight line
    canvas.drawLine(
      Offset(rect.left + 3.0, rect.top + 1.0),
      Offset(rect.right - 3.0, rect.top + 1.0),
      _sharedStrokePaint,
    );
    // Left highlight line
    canvas.drawLine(
      Offset(rect.left + 1.0, rect.top + 3.0),
      Offset(rect.left + 1.0, rect.bottom - 3.0),
      _sharedStrokePaint,
    );

    // 3. Deep Shadow Bevel (Bottom & Right Edges - gives tactile grounding)
    final bevelShadow = Color.lerp(baseColor, Colors.black, 0.40)!.withValues(alpha: opacity);
    _sharedStrokePaint.color = bevelShadow;
    _sharedStrokePaint.strokeWidth = 2.0;
    // Bottom shadow line
    canvas.drawLine(
      Offset(rect.left + 2.5, rect.bottom - 1.0),
      Offset(rect.right - 2.5, rect.bottom - 1.0),
      _sharedStrokePaint,
    );
    // Right shadow line
    _sharedStrokePaint.strokeWidth = 1.6;
    canvas.drawLine(
      Offset(rect.right - 1.0, rect.top + 3.0),
      Offset(rect.right - 1.0, rect.bottom - 2.5),
      _sharedStrokePaint,
    );

    // 4. Subtle Inner Face Glint (top-left corner sparkle for glossy toy shine)
    final glintPaint = Paint()
      ..color = Colors.white.withValues(alpha: (0.75 * opacity).clamp(0.0, 1.0))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(rect.left + 5.0, rect.top + 5.0), 1.2, glintPaint);

    _drawFlashAndBadge(canvas, rect, blockRRect, flashAmount, showPlusOne, opacity);
    canvas.restore();
  }

  // ---------------------------------------------------------------------------
  // MODEL 2: 💎 3D KRİSTAL PAH (Classic 4-Facet Beveled Chiclet)
  // Matching the reference photo: 4 chamfer slopes meeting a clean flat center.
  // ---------------------------------------------------------------------------
  static void _draw4FacetGemstone({
    required Canvas canvas,
    required Rect rect,
    required Color baseColor,
    required double pulse,
    required double flashAmount,
    required bool isFeedback,
    required double opacity,
    required bool showPlusOne,
  }) {
    const radius = Radius.circular(2.5);
    final blockRRect = RRect.fromRectAndRadius(rect, radius);

    _drawContactShadow(canvas, blockRRect, baseColor, isFeedback, opacity);

    canvas.save();
    canvas.clipRRect(blockRRect);

    final topFacetColor = Color.lerp(Colors.white, baseColor, 0.45)!.withValues(alpha: opacity);
    final leftFacetColor = Color.lerp(Colors.white, baseColor, 0.22)!.withValues(alpha: opacity);
    final rightFacetColor = Color.lerp(baseColor, Colors.black, 0.25)!.withValues(alpha: opacity);
    final bottomFacetColor = Color.lerp(baseColor, Colors.black, 0.42)!.withValues(alpha: opacity);
    final centerColor = baseColor.withValues(alpha: opacity);

    // Outer solid base fills corners cleanly
    _sharedFillPaint.shader = null;
    _sharedFillPaint.color = bottomFacetColor;
    canvas.drawRRect(blockRRect, _sharedFillPaint);

    // 4 Chamfer Trapezoids (15% bevel slope)
    final double inset = rect.width * 0.16;
    final innerRect = rect.deflate(inset);

    // Top Chamfer
    final topPath = Path()
      ..moveTo(rect.left, rect.top)
      ..lineTo(rect.right, rect.top)
      ..lineTo(innerRect.right, innerRect.top)
      ..lineTo(innerRect.left, innerRect.top)
      ..close();
    _sharedFillPaint.color = topFacetColor;
    canvas.drawPath(topPath, _sharedFillPaint);

    // Left Chamfer
    final leftPath = Path()
      ..moveTo(rect.left, rect.top)
      ..lineTo(innerRect.left, innerRect.top)
      ..lineTo(innerRect.left, innerRect.bottom)
      ..lineTo(rect.left, rect.bottom)
      ..close();
    _sharedFillPaint.color = leftFacetColor;
    canvas.drawPath(leftPath, _sharedFillPaint);

    // Right Chamfer
    final rightPath = Path()
      ..moveTo(rect.right, rect.top)
      ..lineTo(rect.right, rect.bottom)
      ..lineTo(innerRect.right, innerRect.bottom)
      ..lineTo(innerRect.right, innerRect.top)
      ..close();
    _sharedFillPaint.color = rightFacetColor;
    canvas.drawPath(rightPath, _sharedFillPaint);

    // Bottom Chamfer
    final bottomPath = Path()
      ..moveTo(rect.left, rect.bottom)
      ..lineTo(innerRect.left, innerRect.bottom)
      ..lineTo(innerRect.right, innerRect.bottom)
      ..lineTo(rect.right, rect.bottom)
      ..close();
    _sharedFillPaint.color = bottomFacetColor;
    canvas.drawPath(bottomPath, _sharedFillPaint);

    // Center Flat Square Plateau
    const innerRadius = Radius.circular(1.5);
    final innerRRect = RRect.fromRectAndRadius(innerRect, innerRadius);
    _sharedFillPaint.color = centerColor;
    canvas.drawRRect(innerRRect, _sharedFillPaint);

    // Plateau highlight seam
    _sharedStrokePaint.color = Colors.white.withValues(alpha: 0.45 * opacity);
    _sharedStrokePaint.strokeWidth = 1.0;
    canvas.drawLine(
      Offset(innerRect.left + 1, innerRect.top + 0.5),
      Offset(innerRect.right - 1, innerRect.top + 0.5),
      _sharedStrokePaint,
    );

    // Diagonal Plateau Facet Sheen
    _sharedStrokePaint.color = Colors.white.withValues(alpha: 0.22 * opacity);
    _sharedStrokePaint.strokeWidth = 0.8;
    canvas.drawLine(
      Offset(innerRect.left + 2, innerRect.bottom - 2),
      Offset(innerRect.right - 2, innerRect.top + 2),
      _sharedStrokePaint,
    );

    // Specular glint
    final glintOffset = Offset(innerRect.left + innerRect.width * 0.22, innerRect.top + innerRect.height * 0.22);
    _sharedFillPaint.color = Colors.white.withValues(alpha: (0.85 + pulse * 0.15).clamp(0.0, 1.0));
    canvas.drawCircle(glintOffset, 1.4, _sharedFillPaint);

    _drawFlashAndBadge(canvas, rect, blockRRect, flashAmount, showPlusOne, opacity);
    canvas.restore();
  }

  // ---------------------------------------------------------------------------
  // MODEL 3: 🌸 YUMUŞAK MAT JEL (Soft Matte Velvet Square)
  // Velvety soft-touch finish with horizontal upper pill reflection.
  // ---------------------------------------------------------------------------
  static void _drawSoftMatteSquare({
    required Canvas canvas,
    required Rect rect,
    required Color baseColor,
    required double pulse,
    required double flashAmount,
    required bool isFeedback,
    required double opacity,
    required bool showPlusOne,
  }) {
    const radius = Radius.circular(2.8);
    final blockRRect = RRect.fromRectAndRadius(rect, radius);

    _drawContactShadow(canvas, blockRRect, baseColor, isFeedback, opacity);

    canvas.save();
    canvas.clipRRect(blockRRect);

    // 1. Soft Vertical Velvet Body
    final softGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color.lerp(Colors.white, baseColor, 0.22)!.withValues(alpha: opacity),
        baseColor.withValues(alpha: opacity),
        Color.lerp(baseColor, Colors.black, 0.20)!.withValues(alpha: opacity),
      ],
      stops: const [0.0, 0.60, 1.0],
    );
    canvas.drawRRect(blockRRect, Paint()..shader = softGradient.createShader(rect));

    // 2. Soft Horizontal Pill Highlight
    final pillRect = Rect.fromCenter(
      center: Offset(rect.center.dx, rect.top + rect.height * 0.25),
      width: rect.width * 0.70,
      height: rect.height * 0.18,
    );
    final pillRRect = RRect.fromRectAndRadius(pillRect, const Radius.circular(3.0));
    canvas.drawRRect(
      pillRRect,
      Paint()..color = Colors.white.withValues(alpha: 0.28 * opacity),
    );

    // 3. Subtle Bottom Bevel Line
    canvas.drawLine(
      Offset(rect.left + 2, rect.bottom - 1.0),
      Offset(rect.right - 2, rect.bottom - 1.0),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.25 * opacity)
        ..strokeWidth = 1.2,
    );

    _drawFlashAndBadge(canvas, rect, blockRRect, flashAmount, showPlusOne, opacity);
    canvas.restore();
  }

  // ---------------------------------------------------------------------------
  // MODEL 4: ⚡ SİBER NEON KARE (Cyber Neon Frame Square)
  // Deep tinted cyber core with vibrant glowing edges and corner ticks.
  // ---------------------------------------------------------------------------
  static void _drawCyberNeonSquare({
    required Canvas canvas,
    required Rect rect,
    required Color baseColor,
    required double pulse,
    required double flashAmount,
    required bool isFeedback,
    required double opacity,
    required bool showPlusOne,
  }) {
    const radius = Radius.circular(2.0);
    final blockRRect = RRect.fromRectAndRadius(rect, radius);

    _drawContactShadow(canvas, blockRRect, baseColor, isFeedback, opacity);

    canvas.save();
    canvas.clipRRect(blockRRect);

    // 1. Dark Neon Core
    final darkCore = Color.lerp(baseColor, const Color(0xFF0A0F1D), 0.55)!.withValues(alpha: opacity);
    canvas.drawRRect(blockRRect, Paint()..color = darkCore);

    // 2. Inner Neon Ambient Glow
    final innerRect = rect.deflate(3.0);
    canvas.drawRRect(
      RRect.fromRectAndRadius(innerRect, const Radius.circular(1.5)),
      Paint()..color = baseColor.withValues(alpha: 0.35 * opacity),
    );

    // 3. High-Voltage Frame Border
    final framePaint = Paint()
      ..color = baseColor.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    canvas.drawRRect(blockRRect.deflate(0.9), framePaint);

    // 4. White High-Frequency Corner Accents
    final cornerPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85 * opacity)
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.square;
    const double tick = 4.0;
    // Top-left
    canvas.drawLine(Offset(rect.left + 1.5, rect.top + 1.5), Offset(rect.left + 1.5 + tick, rect.top + 1.5), cornerPaint);
    canvas.drawLine(Offset(rect.left + 1.5, rect.top + 1.5), Offset(rect.left + 1.5, rect.top + 1.5 + tick), cornerPaint);
    // Bottom-right
    canvas.drawLine(Offset(rect.right - 1.5, rect.bottom - 1.5), Offset(rect.right - 1.5 - tick, rect.bottom - 1.5), cornerPaint);
    canvas.drawLine(Offset(rect.right - 1.5, rect.bottom - 1.5), Offset(rect.right - 1.5, rect.bottom - 1.5 - tick), cornerPaint);

    _drawFlashAndBadge(canvas, rect, blockRRect, flashAmount, showPlusOne, opacity);
    canvas.restore();
  }

  // ---------------------------------------------------------------------------
  // MODEL 5: 🏺 SIRLI SERAMİK KARE (Glazed Ceramic Porcelain Tile)
  // Clean flat porcelain square with diagonal gloss shine.
  // ---------------------------------------------------------------------------
  static void _drawGlazedCeramicSquare({
    required Canvas canvas,
    required Rect rect,
    required Color baseColor,
    required double pulse,
    required double flashAmount,
    required bool isFeedback,
    required double opacity,
    required bool showPlusOne,
  }) {
    const radius = Radius.circular(2.2);
    final blockRRect = RRect.fromRectAndRadius(rect, radius);

    _drawContactShadow(canvas, blockRRect, baseColor, isFeedback, opacity);

    canvas.save();
    canvas.clipRRect(blockRRect);

    // 1. Ceramic Body
    canvas.drawRRect(blockRRect, Paint()..color = baseColor.withValues(alpha: opacity));

    // 2. Diagonal Specular Gloss Sheen
    final glossGradient = LinearGradient(
      begin: const Alignment(-0.8, -0.8),
      end: const Alignment(0.8, 0.8),
      colors: [
        Colors.white.withValues(alpha: 0.35 * opacity),
        Colors.white.withValues(alpha: 0.10 * opacity),
        Colors.transparent,
        Colors.black.withValues(alpha: 0.20 * opacity),
      ],
      stops: const [0.0, 0.35, 0.55, 1.0],
    );
    canvas.drawRRect(blockRRect, Paint()..shader = glossGradient.createShader(rect));

    // 3. Crisp Tile Rim
    canvas.drawRRect(
      blockRRect.deflate(0.6),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.25 * opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );

    _drawFlashAndBadge(canvas, rect, blockRRect, flashAmount, showPlusOne, opacity);
    canvas.restore();
  }

  // ---------------------------------------------------------------------------
  // MODEL 6: 🪵 AHŞAP ZANAAT BLOĞU (Craft Nordic Wood Tile)
  // Warm wood tones, subtle fiber grain striations and carved border.
  // ---------------------------------------------------------------------------
  static void _drawNordicWoodSquare({
    required Canvas canvas,
    required Rect rect,
    required Color baseColor,
    required double pulse,
    required double flashAmount,
    required bool isFeedback,
    required double opacity,
    required bool showPlusOne,
  }) {
    const radius = Radius.circular(2.0);
    final blockRRect = RRect.fromRectAndRadius(rect, radius);

    _drawContactShadow(canvas, blockRRect, baseColor, isFeedback, opacity);

    canvas.save();
    canvas.clipRRect(blockRRect);

    // 1. Warm Wood Base
    final warmWood = Color.lerp(const Color(0xFFB45309), baseColor, 0.60)!.withValues(alpha: opacity);
    canvas.drawRRect(blockRRect, Paint()..color = warmWood);

    // 2. Horizontal Wood Grain Striations
    final grainPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.10 * opacity)
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(rect.left + 2, rect.top + rect.height * 0.35), Offset(rect.right - 2, rect.top + rect.height * 0.35), grainPaint);
    canvas.drawLine(Offset(rect.left + 2, rect.top + rect.height * 0.68), Offset(rect.right - 2, rect.top + rect.height * 0.68), grainPaint);

    // 3. Carved Bevel Edge (dark bottom, light top)
    canvas.drawLine(
      Offset(rect.left + 1, rect.top + 0.6),
      Offset(rect.right - 1, rect.top + 0.6),
      Paint()..color = const Color(0xFFFDE68A).withValues(alpha: 0.40 * opacity)..strokeWidth = 1.2,
    );
    canvas.drawLine(
      Offset(rect.left + 1, rect.bottom - 0.7),
      Offset(rect.right - 1, rect.bottom - 0.7),
      Paint()..color = const Color(0xFF451A03).withValues(alpha: 0.45 * opacity)..strokeWidth = 1.4,
    );

    _drawFlashAndBadge(canvas, rect, blockRRect, flashAmount, showPlusOne, opacity);
    canvas.restore();
  }

  // ---------------------------------------------------------------------------
  // MODEL 7: 🌌 KOZMİK GALAKSİ KARE (Cosmic Galactic Square)
  // Deep celestial gradient with stardust glint.
  // ---------------------------------------------------------------------------
  static void _drawCosmicSquare({
    required Canvas canvas,
    required Rect rect,
    required Color baseColor,
    required double pulse,
    required double flashAmount,
    required bool isFeedback,
    required double opacity,
    required bool showPlusOne,
  }) {
    const radius = Radius.circular(2.4);
    final blockRRect = RRect.fromRectAndRadius(rect, radius);

    _drawContactShadow(canvas, blockRRect, baseColor, isFeedback, opacity);

    canvas.save();
    canvas.clipRRect(blockRRect);

    // 1. Cosmic Gradient
    final cosmicGradient = RadialGradient(
      center: const Alignment(-0.4, -0.4),
      radius: 0.9,
      colors: [
        Color.lerp(Colors.white, baseColor, 0.25)!.withValues(alpha: opacity),
        baseColor.withValues(alpha: opacity),
        Color.lerp(baseColor, const Color(0xFF0F051D), 0.65)!.withValues(alpha: opacity),
      ],
      stops: const [0.0, 0.55, 1.0],
    );
    canvas.drawRRect(blockRRect, Paint()..shader = cosmicGradient.createShader(rect));

    // 2. Corner Starlight Glint
    final starCenter = Offset(rect.left + rect.width * 0.24, rect.top + rect.height * 0.24);
    final starAlpha = (0.75 + sin(pulse * pi * 2) * 0.25).clamp(0.4, 1.0) * opacity;
    final starPaint = Paint()..color = Colors.white.withValues(alpha: starAlpha);
    canvas.drawCircle(starCenter, 1.3, starPaint);

    // 3. Starlight Micro Cross Rays
    const double rayLen = 3.5;
    final rayPaint = Paint()
      ..color = Colors.white.withValues(alpha: starAlpha * 0.70)
      ..strokeWidth = 0.8;
    canvas.drawLine(Offset(starCenter.dx - rayLen, starCenter.dy), Offset(starCenter.dx + rayLen, starCenter.dy), rayPaint);
    canvas.drawLine(Offset(starCenter.dx, starCenter.dy - rayLen), Offset(starCenter.dx, starCenter.dy + rayLen), rayPaint);

    // 4. Luminous Rim
    canvas.drawRRect(
      blockRRect.deflate(0.6),
      Paint()
        ..color = Color.lerp(Colors.white, baseColor, 0.4)!.withValues(alpha: 0.35 * opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );

    _drawFlashAndBadge(canvas, rect, blockRRect, flashAmount, showPlusOne, opacity);
    canvas.restore();
  }

  // ---------------------------------------------------------------------------
  // MODEL 8: 🧶 SICAK DOKUMA KEÇE (Tactile Woven Felt Tile)
  // Warm textured matte tile with stitched thread border.
  // ---------------------------------------------------------------------------
  static void _drawCozyWoolSquare({
    required Canvas canvas,
    required Rect rect,
    required Color baseColor,
    required double pulse,
    required double flashAmount,
    required bool isFeedback,
    required double opacity,
    required bool showPlusOne,
  }) {
    const radius = Radius.circular(2.8);
    final blockRRect = RRect.fromRectAndRadius(rect, radius);

    _drawContactShadow(canvas, blockRRect, baseColor, isFeedback, opacity);

    canvas.save();
    canvas.clipRRect(blockRRect);

    // 1. Felt Matte Body
    canvas.drawRRect(blockRRect, Paint()..color = baseColor.withValues(alpha: opacity));

    // 2. Inset Stitched Thread Border
    final stitchRect = rect.deflate(2.2);
    final stitchPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35 * opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRRect(
      RRect.fromRectAndRadius(stitchRect, const Radius.circular(1.8)),
      stitchPaint,
    );

    // 3. Subtle Texture Grain
    final grainPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.08 * opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;
    for (double y = rect.top + 3; y < rect.bottom - 2; y += 3.5) {
      canvas.drawLine(Offset(rect.left + 3, y), Offset(rect.right - 3, y), grainPaint);
    }

    _drawFlashAndBadge(canvas, rect, blockRRect, flashAmount, showPlusOne, opacity);
    canvas.restore();
  }

  // ---------------------------------------------------------------------------
  // COMMON HELPER: Contact Drop Shadow Under Tile
  // ---------------------------------------------------------------------------
  static void _drawContactShadow(
    Canvas canvas,
    RRect blockRRect,
    Color baseColor,
    bool isFeedback,
    double opacity,
  ) {
    if (opacity < 0.95) return; // Airborne or fading shards don't cast ground contact shadow
    if (isFeedback) {
      canvas.drawRRect(blockRRect.shift(const Offset(0, 6.0)), _sharedLiftShadowPaint);
      _sharedLiftGlowPaint.color = baseColor.withValues(alpha: 0.45 * opacity);
      canvas.drawRRect(blockRRect, _sharedLiftGlowPaint);
    } else {
      _sharedContactShadowPaint.color = Colors.black.withValues(alpha: 0.38 * opacity);
      canvas.drawRRect(blockRRect.shift(const Offset(0, 2.2)), _sharedContactShadowPaint);
    }
  }

  // ---------------------------------------------------------------------------
  // COMMON HELPER: Flash Animation & "+1" Clearing Badge
  // ---------------------------------------------------------------------------
  static void _drawFlashAndBadge(
    Canvas canvas,
    Rect rect,
    RRect blockRRect,
    double flashAmount,
    bool showPlusOne,
    double opacity,
  ) {
    // Placement / Line clear white flash
    if (flashAmount > 0.05) {
      final flashPaint = Paint()
        ..color = Colors.white.withValues(alpha: (flashAmount * 0.70).clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;
      canvas.drawRRect(blockRRect, flashPaint);
    }

    // "+1" Score Badge on Clearing Blocks (as seen in reference visual)
    if (showPlusOne) {
      final tp = TextPainter(
        text: TextSpan(
          text: '+1',
          style: TextStyle(
            color: Colors.white.withValues(alpha: (opacity * 0.98).clamp(0.0, 1.0)),
            fontSize: rect.width * 0.32,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.85),
                offset: const Offset(0, 1.2),
                blurRadius: 2.2,
              ),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(rect.center.dx - tp.width / 2, rect.center.dy - tp.height / 2),
      );
    }
  }
}
