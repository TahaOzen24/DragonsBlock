import 'dart:math';
import 'package:flutter/material.dart';
import '../../features/game/models/block_skin_style.dart';
import '../localization/locale_manager.dart';
import '../settings/settings_manager.dart';
import '../theme/game_theme.dart';

// ─── Particle Types ───────────────────────────────────────────────────────────
enum ParticleShape {
  circle,
  square,
  star,
  sparkle,
  shatterShard,
  glassTriangle,
  fluidOrb,
  lightRay,
  softPetal,
}

class Particle {
  double x, y, vx, vy;
  double size;
  Color color;
  Color? secondaryColor;
  double life; // 1.0 → 0.0
  double decay;
  double gravity;
  double damping;
  double wobbleAmp;
  double wobbleFreq;
  double wobblePhase;
  double rotation;
  double rotationSpeed;
  ParticleShape shape;
  double maxLife;
  List<Offset>? polyPoints;

  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.color,
    this.secondaryColor,
    this.life = 1.0,
    this.maxLife = 1.0,
    this.decay = 0.02,
    this.gravity = 0.0,
    this.damping = 0.94,
    this.wobbleAmp = 0.0,
    this.wobbleFreq = 0.0,
    this.wobblePhase = 0.0,
    this.rotation = 0.0,
    this.rotationSpeed = 0.0,
    this.shape = ParticleShape.circle,
    this.polyPoints,
  });

  bool update() {
    x += vx;
    y += vy;
    vx *= damping;
    vy = (vy * damping) + gravity;
    if (wobbleFreq > 0) {
      x += sin((1.0 - life) * wobbleFreq + wobblePhase) * wobbleAmp;
    }
    rotation += rotationSpeed;
    rotationSpeed *= 0.985;
    life -= decay;
    return life > 0;
  }
}

// ─── Shockwave ────────────────────────────────────────────────────────────────
class Shockwave {
  double x, y, radius, maxRadius;
  Color color;
  double life;
  double strokeWidth;
  bool isSoft;

  Shockwave({
    required this.x,
    required this.y,
    this.radius = 5.0,
    this.maxRadius = 120.0,
    required this.color,
    this.life = 1.0,
    this.strokeWidth = 3.0,
    this.isSoft = true,
  });

  bool update() {
    radius += (maxRadius - radius) * 0.16;
    life -= 0.042;
    return life > 0;
  }
}

// ─── Flash Overlay ────────────────────────────────────────────────────────────
class FlashOverlay {
  Color color;
  double life;

  FlashOverlay({required this.color, this.life = 1.0});

  bool update() {
    life -= 0.08;
    return life > 0;
  }
}

// ─── Floating Text ────────────────────────────────────────────────────────────
class FloatingText {
  String text;
  double x, y, vy;
  double startX, startY;
  double? targetX, targetY;
  Color color;
  double life, scale, fontSize;
  double progress = 0.0;
  int holdTicks = 0;
  VoidCallback? onArrived;

  FloatingText({
    required this.text,
    required this.x,
    required this.y,
    this.targetX,
    this.targetY,
    this.vy = -0.8,
    required this.color,
    this.life = 1.0,
    this.scale = 0.8,
    this.fontSize = 14.0,
    this.onArrived,
  })  : startX = x,
        startY = y;

  bool update() {
    if (targetX != null && targetY != null) {
      if (holdTicks < 18) {
        // Phase 1: Elastic pop-in (0.5 -> 1.25 -> 1.0)
        holdTicks++;
        final double t = holdTicks / 18.0;
        scale = 0.5 + sin(t * pi) * 0.55 + t * 0.50;
        y += vy;
        vy *= 0.88;
        return true;
      }

      // Phase 2: Graceful, smooth glide to target HUD counter
      progress = (progress + 0.026).clamp(0.0, 1.0);
      final double controlX = (startX + targetX!) / 2 + 10;
      final double controlY = min(startY, targetY!) - 40;
      final double t = progress;
      final double u = 1.0 - t;
      x = u * u * startX + 2 * u * t * controlX + t * t * targetX!;
      y = u * u * startY + 2 * u * t * controlY + t * t * targetY!;
      scale = 1.0 - progress * 0.25;
      life = 1.0 - (progress * 0.6);
      if (progress >= 1.0) {
        onArrived?.call();
        return false;
      }
      return true;
    } else {
      holdTicks++;
      if (holdTicks <= 14) {
        // Juicy elastic overshoot for combo badges (0.4 -> 1.30 -> 1.0)
        final double t = holdTicks / 14.0;
        scale = 0.4 + sin(t * pi) * 0.70 + t * 0.60;
      } else {
        scale += (1.0 - scale) * 0.08;
      }
      y += vy;
      vy *= 0.94;
      life -= 0.016;
      return life > 0;
    }
  }
}

// ─── Particle System ──────────────────────────────────────────────────────────
class ParticleSystem {
  final List<Particle> particles = [];
  final List<Shockwave> shockwaves = [];
  final List<FloatingText> floatingTexts = [];
  final List<FlashOverlay> flashes = [];
  final Random _rng = Random();

  final List<Particle> _particlePool = [];

  bool get hasActiveFx =>
      particles.isNotEmpty ||
      shockwaves.isNotEmpty ||
      floatingTexts.isNotEmpty ||
      flashes.isNotEmpty;

  void clear() {
    particles.clear();
    shockwaves.clear();
    floatingTexts.clear();
    flashes.clear();
  }

  int _scaledCount(int count) =>
      SettingsManager.instance.isBatterySaver ? (count / 2).ceil() : count;

  Particle _createOrRecycleParticle({
    required double x,
    required double y,
    required double vx,
    required double vy,
    required double size,
    required Color color,
    Color? secondaryColor,
    double life = 1.0,
    double maxLife = 1.0,
    double decay = 0.02,
    double gravity = 0.0,
    double damping = 0.94,
    double wobbleAmp = 0.0,
    double wobbleFreq = 0.0,
    double wobblePhase = 0.0,
    double rotation = 0.0,
    double rotationSpeed = 0.0,
    ParticleShape shape = ParticleShape.circle,
    List<Offset>? polyPoints,
  }) {
    if (_particlePool.isNotEmpty) {
      final p = _particlePool.removeLast();
      p.x = x; p.y = y; p.vx = vx; p.vy = vy;
      p.size = size; p.color = color; p.secondaryColor = secondaryColor;
      p.life = life; p.maxLife = maxLife; p.decay = decay;
      p.gravity = gravity; p.damping = damping;
      p.wobbleAmp = wobbleAmp; p.wobbleFreq = wobbleFreq; p.wobblePhase = wobblePhase;
      p.rotation = rotation; p.rotationSpeed = rotationSpeed;
      p.shape = shape; p.polyPoints = polyPoints;
      return p;
    }
    return Particle(
      x: x, y: y, vx: vx, vy: vy, size: size, color: color,
      secondaryColor: secondaryColor, life: life, maxLife: maxLife,
      decay: decay, gravity: gravity, damping: damping,
      wobbleAmp: wobbleAmp, wobbleFreq: wobbleFreq, wobblePhase: wobblePhase,
      rotation: rotation, rotationSpeed: rotationSpeed, shape: shape,
      polyPoints: polyPoints,
    );
  }

  void update() {
    for (int i = particles.length - 1; i >= 0; i--) {
      if (!particles[i].update()) {
        final p = particles.removeAt(i);
        if (_particlePool.length < 300) {
          _particlePool.add(p);
        }
      }
    }
    shockwaves.removeWhere((s) => !s.update());
    floatingTexts.removeWhere((t) => !t.update());
    flashes.removeWhere((f) => !f.update());

    while (particles.length > 96) {
      final p = particles.removeAt(0);
      if (_particlePool.length < 300) _particlePool.add(p);
    }
  }

  // ── Block Placed Poof & Impact (Soft & Tactile) ──────────────────────────
  void spawnPlacePoof(double x, double y, Color color) {
    for (int i = 0; i < _scaledCount(8); i++) {
      final angle = _rng.nextDouble() * 2 * pi;
      final speed = 1.2 + _rng.nextDouble() * 2.8;
      particles.add(_createOrRecycleParticle(
        x: x, y: y,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed - 0.4,
        size: 3.0 + _rng.nextDouble() * 3.5,
        color: i.isEven ? color : Colors.white,
        secondaryColor: Colors.white,
        decay: 0.035 + _rng.nextDouble() * 0.03,
        damping: 0.91,
        gravity: 0.03,
        rotationSpeed: (_rng.nextDouble() - 0.5) * 0.3,
        shape: _rng.nextBool() ? ParticleShape.sparkle : ParticleShape.fluidOrb,
      ));
    }

    // Soft fluid placement ripple
    shockwaves.add(Shockwave(
      x: x, y: y,
      radius: 4.0,
      maxRadius: 38.0,
      color: color,
      strokeWidth: 2.4,
      isSoft: true,
      life: 0.85,
    ));
  }

  // ── Multi-cell Placement Impact ──────────────────────────────────────────
  void spawnPlacementImpact(List<Offset> cellCenters, Color color) {
    for (final center in cellCenters) {
      spawnPlacePoof(center.dx, center.dy, color);
    }
  }

  // ── 💎 High-Performance Physics Block Shatter & Fracture FX ────────────────
  void spawnBlockShatter(
    double x,
    double y,
    Color baseColor, {
    required BlockSkinStyle style,
    double cellSize = 36.0,
  }) {
    switch (style) {
      case BlockSkinStyle.gemstone3D:
        // 💎 A. Prismatic Diamond Crystal Shockwave Ring
        shockwaves.add(Shockwave(
          x: x,
          y: y,
          radius: 4.0,
          maxRadius: cellSize * 1.50,
          color: Color.lerp(baseColor, Colors.white, 0.65)!,
          strokeWidth: 3.0,
          isSoft: false,
          life: 0.95,
        ));

        // Faceted Crystal Shards, Sparkling Diamonds & Stardust
        final int chipCount = _scaledCount(10);
        for (int i = 0; i < chipCount; i++) {
          final double angle = (i * (2 * pi / chipCount)) + (_rng.nextDouble() * 0.35 - 0.175);
          final double speed = 3.5 + _rng.nextDouble() * 4.2;
          final ParticleShape shape = (i % 3 == 0)
              ? ParticleShape.sparkle
              : (i % 3 == 1)
                  ? ParticleShape.shatterShard
                  : ParticleShape.glassTriangle;

          particles.add(Particle(
            x: x + cos(angle) * 3,
            y: y + sin(angle) * 3,
            vx: cos(angle) * speed,
            vy: sin(angle) * speed - 1.8,
            size: shape == ParticleShape.sparkle
                ? (4.5 + _rng.nextDouble() * 3.5)
                : (5.0 + _rng.nextDouble() * 4.0),
            color: i.isEven ? Color.lerp(baseColor, Colors.white, 0.40)! : baseColor,
            secondaryColor: Colors.white,
            life: 1.0,
            maxLife: 1.0,
            decay: 0.022 + _rng.nextDouble() * 0.015,
            gravity: 0.30,
            damping: 0.93,
            rotation: _rng.nextDouble() * 2 * pi,
            rotationSpeed: (_rng.nextBool() ? 1 : -1) * (0.22 + _rng.nextDouble() * 0.30),
            shape: shape,
          ));
        }

        // Micro Stardust Glitter specks that float up gracefully
        final int stardustCount = _scaledCount(4);
        for (int i = 0; i < stardustCount; i++) {
          particles.add(Particle(
            x: x + (_rng.nextDouble() * 16 - 8),
            y: y + (_rng.nextDouble() * 16 - 8),
            vx: (_rng.nextDouble() * 1.6 - 0.8),
            vy: -1.0 - _rng.nextDouble() * 1.5,
            size: 2.5 + _rng.nextDouble() * 2.0,
            color: Colors.white,
            secondaryColor: Color.lerp(baseColor, Colors.white, 0.7)!,
            life: 1.0,
            maxLife: 1.0,
            decay: 0.018 + _rng.nextDouble() * 0.012,
            gravity: 0.04,
            damping: 0.96,
            rotation: _rng.nextDouble() * 2 * pi,
            rotationSpeed: 0.15,
            shape: ParticleShape.sparkle,
          ));
        }
        break;

      case BlockSkinStyle.softJelly:
        // 🍬 A. Soft Fluid Gelatinous Expanding Ripple
        shockwaves.add(Shockwave(
          x: x,
          y: y,
          radius: 3.0,
          maxRadius: cellSize * 1.30,
          color: baseColor,
          strokeWidth: 2.6,
          isSoft: true,
          life: 0.88,
        ));

        // Translucent Liquid Gummy Droplets Splashing with Gravity Arcs
        final int dropletCount = _scaledCount(8);
        for (int i = 0; i < dropletCount; i++) {
          final double angle = (i * (2 * pi / dropletCount)) + (_rng.nextDouble() * 0.3 - 0.15);
          final double speed = 2.0 + _rng.nextDouble() * 2.8;
          particles.add(Particle(
            x: x,
            y: y,
            vx: cos(angle) * speed,
            vy: sin(angle) * speed - 1.0,
            size: 5.0 + _rng.nextDouble() * 3.5,
            color: baseColor,
            secondaryColor: Colors.white,
            life: 1.0,
            decay: 0.030 + _rng.nextDouble() * 0.015,
            gravity: 0.22,
            damping: 0.92,
            shape: ParticleShape.fluidOrb,
          ));
        }
        break;

      case BlockSkinStyle.nordicWood:
        // 🪵 A. Warm Wood Shockwave
        shockwaves.add(Shockwave(
          x: x,
          y: y,
          radius: 3.0,
          maxRadius: cellSize * 1.20,
          color: const Color(0xFFD97706),
          strokeWidth: 2.2,
          isSoft: true,
          life: 0.80,
        ));

        // Wooden Splinter Chips & Sawdust
        final int chipCount = _scaledCount(7);
        for (int i = 0; i < chipCount; i++) {
          final double angle = _rng.nextDouble() * 2 * pi;
          final double speed = 2.2 + _rng.nextDouble() * 3.0;
          particles.add(Particle(
            x: x,
            y: y,
            vx: cos(angle) * speed,
            vy: sin(angle) * speed - 1.4,
            size: 4.0 + _rng.nextDouble() * 4.0,
            color: i.isEven ? const Color(0xFFB45309) : const Color(0xFFDEB887),
            secondaryColor: const Color(0xFFFFD54F),
            life: 1.0,
            decay: 0.032 + _rng.nextDouble() * 0.016,
            gravity: 0.32,
            damping: 0.92,
            rotation: _rng.nextDouble() * 2 * pi,
            rotationSpeed: (_rng.nextBool() ? 1 : -1) * 0.25,
            shape: ParticleShape.shatterShard,
          ));
        }
        break;

      case BlockSkinStyle.cozyWool:
        // 🧶 Fluffy Felt Petals & Yarn Fiber Specks
        shockwaves.add(Shockwave(
          x: x,
          y: y,
          radius: 3.0,
          maxRadius: cellSize * 1.25,
          color: baseColor.withValues(alpha: 0.8),
          strokeWidth: 2.0,
          isSoft: true,
          life: 0.85,
        ));

        final int fluffCount = _scaledCount(7);
        for (int i = 0; i < fluffCount; i++) {
          final double angle = (i * (2 * pi / fluffCount)) + (_rng.nextDouble() * 0.4 - 0.2);
          final double speed = 1.4 + _rng.nextDouble() * 2.0;
          particles.add(Particle(
            x: x,
            y: y,
            vx: cos(angle) * speed,
            vy: sin(angle) * speed - 0.8,
            size: 6.0 + _rng.nextDouble() * 4.0,
            color: baseColor,
            secondaryColor: Colors.white,
            life: 1.0,
            decay: 0.024 + _rng.nextDouble() * 0.012,
            gravity: 0.08,
            damping: 0.95,
            rotation: _rng.nextDouble() * 2 * pi,
            rotationSpeed: (_rng.nextBool() ? 1 : -1) * 0.12,
            shape: ParticleShape.softPetal,
          ));
        }
        break;

      case BlockSkinStyle.zenCeramic:
        // 🏺 Ceramic Shards + Shimmering 24K Gold Kintsugi Dust
        shockwaves.add(Shockwave(
          x: x,
          y: y,
          radius: 3.0,
          maxRadius: cellSize * 1.30,
          color: const Color(0xFFFFD700),
          strokeWidth: 2.4,
          isSoft: false,
          life: 0.90,
        ));

        // Gold dust specks
        final int goldCount = _scaledCount(8);
        for (int i = 0; i < goldCount; i++) {
          final double angle = _rng.nextDouble() * 2 * pi;
          final double speed = 1.6 + _rng.nextDouble() * 2.8;
          particles.add(Particle(
            x: x,
            y: y,
            vx: cos(angle) * speed,
            vy: sin(angle) * speed - 1.0,
            size: 4.0 + _rng.nextDouble() * 3.0,
            color: const Color(0xFFFFD700),
            secondaryColor: Colors.white,
            life: 1.0,
            decay: 0.028 + _rng.nextDouble() * 0.015,
            gravity: 0.16,
            damping: 0.93,
            shape: ParticleShape.sparkle,
          ));
        }
        break;

      case BlockSkinStyle.neonEnergy:
        // ⚡ High-Voltage Electric Discharge & Laser Arcs
        shockwaves.add(Shockwave(
          x: x,
          y: y,
          radius: 4.0,
          maxRadius: cellSize * 1.45,
          color: baseColor,
          strokeWidth: 2.8,
          isSoft: false,
          life: 0.92,
        ));

        final int laserCount = _scaledCount(8);
        for (int i = 0; i < laserCount; i++) {
          final double angle = _rng.nextDouble() * 2 * pi;
          final double speed = 3.2 + _rng.nextDouble() * 4.2;
          particles.add(Particle(
            x: x,
            y: y,
            vx: cos(angle) * speed,
            vy: sin(angle) * speed,
            size: 6.0 + _rng.nextDouble() * 4.0,
            color: baseColor,
            secondaryColor: Colors.white,
            life: 1.0,
            decay: 0.038 + _rng.nextDouble() * 0.020,
            gravity: 0.04,
            damping: 0.88,
            rotation: angle,
            shape: ParticleShape.lightRay,
          ));
        }
        break;

      case BlockSkinStyle.cosmicStardust:
        // 🌌 Cosmic Singularity Implosion Pop & Twinkling Stars
        shockwaves.add(Shockwave(
          x: x,
          y: y,
          radius: 2.0,
          maxRadius: cellSize * 1.40,
          color: const Color(0xFFC084FC),
          strokeWidth: 2.6,
          isSoft: true,
          life: 0.90,
        ));

        final int starCount = _scaledCount(7);
        for (int i = 0; i < starCount; i++) {
          final double angle = (i * (2 * pi / starCount)) + (_rng.nextDouble() * 0.3);
          final double speed = 1.8 + _rng.nextDouble() * 2.8;
          particles.add(Particle(
            x: x,
            y: y,
            vx: cos(angle) * speed,
            vy: sin(angle) * speed - 0.8,
            size: 5.5 + _rng.nextDouble() * 4.0,
            color: i.isEven ? const Color(0xFFC084FC) : Colors.white,
            secondaryColor: baseColor,
            life: 1.0,
            decay: 0.028 + _rng.nextDouble() * 0.014,
            gravity: 0.10,
            damping: 0.94,
            rotation: _rng.nextDouble() * 2 * pi,
            rotationSpeed: 0.20,
            shape: ParticleShape.star,
          ));
        }
        break;

      case BlockSkinStyle.minimalGlass:
        // 🍬 Juicy Candy Cube Burst (Block Blast Iconic)
        shockwaves.add(Shockwave(
          x: x,
          y: y,
          radius: 4.0,
          maxRadius: cellSize * 1.45,
          color: Color.lerp(baseColor, Colors.white, 0.65)!,
          strokeWidth: 2.8,
          isSoft: false,
          life: 0.90,
        ));

        // 1. Tumbling 3D Candy Cube Fragments
        final int cubeCount = _scaledCount(9);
        for (int i = 0; i < cubeCount; i++) {
          final double angle = (i * (2 * pi / cubeCount)) + (_rng.nextDouble() * 0.4 - 0.2);
          final double speed = 3.2 + _rng.nextDouble() * 4.0;
          particles.add(Particle(
            x: x + cos(angle) * 3,
            y: y + sin(angle) * 3,
            vx: cos(angle) * speed,
            vy: sin(angle) * speed - 2.0,
            size: 4.5 + _rng.nextDouble() * 3.5,
            color: i.isEven ? Color.lerp(baseColor, Colors.white, 0.25)! : baseColor,
            secondaryColor: Color.lerp(baseColor, Colors.black, 0.30)!,
            life: 1.0,
            maxLife: 1.0,
            decay: 0.022 + _rng.nextDouble() * 0.014,
            gravity: 0.32,
            damping: 0.94,
            rotation: _rng.nextDouble() * 2 * pi,
            rotationSpeed: (_rng.nextBool() ? 1 : -1) * (0.20 + _rng.nextDouble() * 0.35),
            shape: ParticleShape.square,
          ));
        }

        // 2. Sparkling Candy Sugar Flakes
        final int sparkleCount = _scaledCount(5);
        for (int i = 0; i < sparkleCount; i++) {
          final double angle = (i * (2 * pi / sparkleCount)) + (_rng.nextDouble() * 0.3);
          final double speed = 2.0 + _rng.nextDouble() * 2.5;
          particles.add(Particle(
            x: x,
            y: y,
            vx: cos(angle) * speed,
            vy: sin(angle) * speed - 0.8,
            size: 3.5 + _rng.nextDouble() * 2.5,
            color: Colors.white,
            secondaryColor: baseColor,
            life: 1.0,
            decay: 0.028 + _rng.nextDouble() * 0.015,
            gravity: 0.12,
            damping: 0.95,
            shape: ParticleShape.sparkle,
          ));
        }
        break;
    }
  }

  // ── 🫠 Dissolving & Liquid Melting FX ──────────────────────────────────────
  void spawnBlockMelt(
    double x,
    double y,
    Color baseColor, {
    double cellSize = 36.0,
  }) {
    // 1. Fluid Melting Ripple (warm expanding ring)
    shockwaves.add(Shockwave(
      x: x,
      y: y,
      radius: 3.0,
      maxRadius: cellSize * 1.30,
      color: baseColor,
      strokeWidth: 2.2,
      isSoft: true,
      life: 0.85,
    ));

    // 2. Dripping Liquefaction Droplets (Falling with gravity)
    final int dropCount = _scaledCount(9);
    for (int i = 0; i < dropCount; i++) {
      final double xOffset = (_rng.nextDouble() * 2 - 1) * (cellSize * 0.4);
      final double speedY = 1.0 + _rng.nextDouble() * 3.2; // flows downward
      final double speedX = (_rng.nextDouble() * 2 - 1) * 0.8;

      particles.add(Particle(
        x: x + xOffset,
        y: y + (_rng.nextDouble() * 6),
        vx: speedX,
        vy: speedY,
        size: 4.5 + _rng.nextDouble() * 3.5,
        color: baseColor,
        secondaryColor: Colors.white,
        life: 1.0,
        decay: 0.026 + _rng.nextDouble() * 0.014,
        gravity: 0.24, // gravity accelerates melting drips downward
        damping: 0.95,
        shape: ParticleShape.fluidOrb,
      ));
    }

    // 3. Dissolving Steam / Rising Vapor Bubbles (Floating upward)
    final int steamCount = _scaledCount(6);
    for (int i = 0; i < steamCount; i++) {
      final double xOffset = (_rng.nextDouble() * 2 - 1) * (cellSize * 0.35);
      final double floatSpeedY = -(1.2 + _rng.nextDouble() * 2.0); // floats up
      final double floatSpeedX = (_rng.nextDouble() * 2 - 1) * 0.6;

      particles.add(Particle(
        x: x + xOffset,
        y: y - (_rng.nextDouble() * 4),
        vx: floatSpeedX,
        vy: floatSpeedY,
        size: 3.0 + _rng.nextDouble() * 2.5,
        color: Color.lerp(baseColor, Colors.white, 0.6)!.withValues(alpha: 0.75),
        secondaryColor: Colors.white,
        life: 1.0,
        decay: 0.038 + _rng.nextDouble() * 0.020,
        gravity: -0.05, // buoyant rise
        damping: 0.92,
        wobbleAmp: 0.8,
        wobbleFreq: 8.0,
        wobblePhase: _rng.nextDouble() * pi,
        shape: ParticleShape.fluidOrb,
      ));
    }
  }

  // ── Line Clear Burst ─────────────────────────────────────────────────────
  void spawnLineClearParticles(double x, double y, Color color, {int count = 20, String? fxStyleId}) {
    final fx = fxStyleId ?? 'neon_pulse';

    for (int i = 0; i < _scaledCount(count); i++) {
      final angle = _rng.nextDouble() * 2 * pi;
      final speed = 2.5 + _rng.nextDouble() * 7.0;
      final isSparkle = _rng.nextDouble() < 0.35;

      Color pColor = color;
      ParticleShape shape = isSparkle ? ParticleShape.sparkle : ParticleShape.square;

      if (fx == 'solar_flare') {
        pColor = i.isEven ? GameTheme.fireOrange : GameTheme.fireYellow;
        shape = isSparkle ? ParticleShape.sparkle : ParticleShape.circle;
      } else if (fx == 'blizzard_shards') {
        pColor = i.isEven ? GameTheme.frostCyan : Colors.white;
        shape = ParticleShape.sparkle;
      } else if (fx == 'sovereign_gold') {
        pColor = i.isEven ? GameTheme.goldAccent : Colors.amberAccent;
        shape = isSparkle ? ParticleShape.star : ParticleShape.circle;
      } else {
        pColor = isSparkle ? Colors.white : color;
      }

      particles.add(Particle(
        x: x, y: y,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed - (fx == 'solar_flare' ? 2.0 : 1.0),
        size: isSparkle ? 2.5 + _rng.nextDouble() * 3.5 : 4.0 + _rng.nextDouble() * 6.0,
        color: pColor,
        decay: 0.016 + _rng.nextDouble() * 0.024,
        gravity: fx == 'blizzard_shards' ? 0.06 : (isSparkle ? 0.05 : 0.18),
        rotationSpeed: (_rng.nextDouble() - 0.5) * 0.4,
        shape: shape,
      ));
    }

    shockwaves.add(Shockwave(
      x: x, y: y,
      maxRadius: fx == 'sovereign_gold' ? 120.0 : 100.0,
      color: fx == 'sovereign_gold'
          ? GameTheme.goldAccent
          : (fx == 'solar_flare' ? GameTheme.fireOrange : color),
      life: 0.9,
    ));
  }

  // ── Elemental Explosion ──────────────────────────────────────────────────
  void spawnExplosion(double x, double y, Color color, {int count = 45}) {
    // Crystal burst - clean, elegant particles
    for (int i = 0; i < _scaledCount(count); i++) {
      final angle = _rng.nextDouble() * 2 * pi;
      final speed = 2.5 + _rng.nextDouble() * 8.0;
      final isSparkle = _rng.nextDouble() < 0.35;
      final lightColor = Color.lerp(color, Colors.white, 0.4)!;
      particles.add(Particle(
        x: x, y: y,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed - 1.0,
        size: isSparkle ? 2.0 + _rng.nextDouble() * 3.0 : 3.0 + _rng.nextDouble() * 4.0,
        color: i.isEven ? color : lightColor,
        decay: 0.018 + _rng.nextDouble() * 0.02,
        gravity: 0.10,
        rotationSpeed: (_rng.nextDouble() - 0.5) * 0.3,
        shape: isSparkle ? ParticleShape.sparkle : ParticleShape.circle,
      ));
    }

    // Single soft shockwave ring
    shockwaves.add(Shockwave(x: x, y: y, maxRadius: 120.0, color: color, life: 0.8, isSoft: true));

    // Screen flash
    flashes.add(FlashOverlay(color: color.withValues(alpha: 0.10)));
  }

  // ── Combo Sparkle - Elegant, clean ──────────────────────────────────────────
  void spawnComboSparks(double x, double y, int combo) {
    final int count = _scaledCount(10 + combo * 3);
    for (int i = 0; i < count; i++) {
      final angle = _rng.nextDouble() * 2 * pi;
      final speed = 3.0 + _rng.nextDouble() * 6.0;
      final lightColor = Color.lerp(combo >= 4 ? const Color(0xFFB388FF) : const Color(0xFF80D8FF), Colors.white, 0.3)!;
      particles.add(Particle(
        x: x, y: y,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed - 1.5,
        size: 1.5 + _rng.nextDouble() * 3.0,
        color: i.isEven ? (combo >= 4 ? const Color(0xFFB388FF) : const Color(0xFF80D8FF)) : lightColor,
        decay: 0.025 + _rng.nextDouble() * 0.03,
        gravity: 0.1,
        shape: ParticleShape.sparkle,
      ));
    }
    shockwaves.add(Shockwave(
      x: x, y: y,
      maxRadius: 80.0 + combo * 15.0,
      color: GameTheme.lightningYellow,
      life: 0.8,
    ));
  }

  // ── High-Octane Scaling Combo Burst ──────────────────────────────────────
  void spawnComboBurst(double x, double y, Color color, int comboStreak) {
    final int count = _scaledCount(12 + comboStreak * 6);
    final double power = (1.0 + (comboStreak * 0.15)).clamp(1.0, 2.5);

    for (int i = 0; i < count; i++) {
      final double angle = _rng.nextDouble() * 2 * pi;
      final double speed = (3.5 + _rng.nextDouble() * 6.5) * power;
      final bool isStar = i % 3 == 0;
      final Color pColor = i.isEven
          ? color
          : Color.lerp(color, Colors.white, 0.65)!;

      particles.add(_createOrRecycleParticle(
        x: x,
        y: y,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed - (1.5 * power),
        size: (isStar ? 3.5 : 4.5) * (1.0 + comboStreak * 0.12),
        color: pColor,
        secondaryColor: Colors.white,
        decay: 0.020 + _rng.nextDouble() * 0.025,
        gravity: 0.12,
        damping: 0.93,
        rotationSpeed: (_rng.nextDouble() - 0.5) * 0.35,
        shape: isStar ? ParticleShape.star : ParticleShape.sparkle,
      ));
    }

    shockwaves.add(Shockwave(
      x: x,
      y: y,
      radius: 6.0,
      maxRadius: 75.0 + comboStreak * 18.0,
      color: color,
      strokeWidth: 3.0 + comboStreak * 0.5,
      isSoft: false,
      life: 0.95,
    ));

    if (comboStreak >= 3) {
      flashes.add(FlashOverlay(color: color.withValues(alpha: 0.14)));
    }
  }

  // ── Invalid Drop Rejection Feedback ──────────────────────────────────────
  void spawnInvalidDrop(double x, double y) {
    const rejectColor = Color(0xFFFF3355);

    for (int i = 0; i < _scaledCount(6); i++) {
      final double angle = _rng.nextDouble() * 2 * pi;
      final speed = 1.5 + _rng.nextDouble() * 2.5;
      particles.add(_createOrRecycleParticle(
        x: x + (_rng.nextDouble() - 0.5) * 16,
        y: y + (_rng.nextDouble() - 0.5) * 16,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed,
        size: 3.0 + _rng.nextDouble() * 2.5,
        color: rejectColor,
        decay: 0.055 + _rng.nextDouble() * 0.03,
        gravity: 0.08,
        damping: 0.88,
        shape: ParticleShape.circle,
      ));
    }

    shockwaves.add(Shockwave(
      x: x,
      y: y,
      radius: 4.0,
      maxRadius: 36.0,
      color: rejectColor.withValues(alpha: 0.7),
      strokeWidth: 2.0,
      isSoft: true,
      life: 0.75,
    ));

    flashes.add(FlashOverlay(color: rejectColor.withValues(alpha: 0.12)));
  }

  // ── Floating Text ────────────────────────────────────────────────────────
  void spawnFloatingText(String text, double x, double y, Color color, {double fontSize = 13.0}) {
    floatingTexts.add(FloatingText(text: text, x: x, y: y, color: color, fontSize: fontSize));
  }

  // ── Drag Trail Particles (Recycled & Lightweight) ────────────────────────
  void spawnDragTrail(double x, double y, Color color) {
    for (int i = 0; i < _scaledCount(2); i++) {
      final angle = _rng.nextDouble() * 2 * pi;
      final speed = 0.5 + _rng.nextDouble() * 2.0;
      particles.add(_createOrRecycleParticle(
        x: x + (_rng.nextDouble() - 0.5) * 12,
        y: y + (_rng.nextDouble() - 0.5) * 12,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed + 0.5,
        size: 2.0 + _rng.nextDouble() * 3.0,
        color: color.withValues(alpha: 0.8),
        decay: 0.05 + _rng.nextDouble() * 0.04,
        gravity: -0.04,
        shape: _rng.nextBool() ? ParticleShape.sparkle : ParticleShape.circle,
      ));
    }
  }

  // ── Custom Particle Lab Trail Particles ──────────────────────────────────
  void spawnCustomTrail(double x, double y, String trailId) {
    Color pColor = GameTheme.neonCyan;
    Color sColor = const Color(0xFFBA68C8);
    ParticleShape shape = ParticleShape.sparkle;

    switch (trailId) {
      case 'magma_sparks':
        pColor = GameTheme.fireOrange;
        sColor = const Color(0xFFFFD54F);
        shape = ParticleShape.circle;
        break;
      case 'frost_shards':
        pColor = GameTheme.frostCyan;
        sColor = Colors.white;
        shape = ParticleShape.square;
        break;
      case 'storm_sparks':
        pColor = GameTheme.lightningYellow;
        sColor = const Color(0xFF00E5FF);
        shape = ParticleShape.star;
        break;
      case 'sakura_breeze':
        pColor = const Color(0xFFFF80AB);
        sColor = const Color(0xFFF8BBD0);
        shape = ParticleShape.circle;
        break;
      case 'rainbow_aurora':
        final rainbowColors = [
          const Color(0xFFFF1744),
          const Color(0xFFFF9100),
          const Color(0xFFFFEA00),
          const Color(0xFF00E676),
          const Color(0xFF00E5FF),
          const Color(0xFFD500F9),
        ];
        pColor = rainbowColors[_rng.nextInt(rainbowColors.length)];
        sColor = rainbowColors[_rng.nextInt(rainbowColors.length)];
        shape = ParticleShape.sparkle;
        break;
      default:
        pColor = GameTheme.neonCyan;
        sColor = const Color(0xFFBA68C8);
        shape = ParticleShape.sparkle;
        break;
    }

    for (int i = 0; i < _scaledCount(3); i++) {
      final angle = _rng.nextDouble() * 2 * pi;
      final speed = 0.8 + _rng.nextDouble() * 2.5;
      final usePrimary = _rng.nextBool();
      particles.add(Particle(
        x: x + (_rng.nextDouble() - 0.5) * 14,
        y: y + (_rng.nextDouble() - 0.5) * 14,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed - 0.5,
        size: 2.5 + _rng.nextDouble() * 3.5,
        color: (usePrimary ? pColor : sColor).withValues(alpha: 0.9),
        decay: 0.04 + _rng.nextDouble() * 0.04,
        gravity: trailId == 'magma_sparks' ? -0.06 : 0.02,
        shape: shape,
      ));
    }
  }

  // ── Custom Particle Lab Fireworks ─────────────────────────────────────────
  void spawnCustomFireworks(double x, double y, String fireworksId) {
    Color mainColor = GameTheme.neonCyan;
    int count = 28;

    switch (fireworksId) {
      case 'dragonfire_burst':
        mainColor = GameTheme.fireOrange;
        count = 36;
        break;
      case 'shattered_diamonds':
        mainColor = const Color(0xFF80DEEA);
        count = 32;
        break;
      case 'void_implosion':
        mainColor = GameTheme.voidPurple;
        count = 40;
        break;
      default:
        mainColor = GameTheme.neonCyan;
        count = 28;
        break;
    }

    spawnExplosion(x, y, mainColor, count: count);
    shockwaves.add(Shockwave(
      x: x,
      y: y,
      maxRadius: 140.0,
      color: mainColor,
      life: 1.0,
    ));
  }

  // ── Combo Praise Emitter (Clean, Non-Overlapping Punchy Badges) ───────────
  void spawnComboPraise(double x, double y, int combo) {
    if (combo < 2) return;

    // 1. Immediately remove any previous combo text so they NEVER overlap or clutter!
    floatingTexts.removeWhere((ft) => ft.targetX == null);

    final bool isTr = LocaleManager.instance.isTurkish;
    String text;
    Color color;
    double fontSize;

    if (combo == 2) {
      text = isTr ? "KOMBO x2" : "COMBO x2";
      color = const Color(0xFF38BDF8);
      fontSize = 20;
    } else if (combo == 3) {
      text = isTr ? "KOMBO x3 🔥" : "COMBO x3 🔥";
      color = const Color(0xFF4ADE80);
      fontSize = 22;
    } else if (combo == 4) {
      text = isTr ? "KOMBO x4 ⚡" : "COMBO x4 ⚡";
      color = const Color(0xFFFBBF24);
      fontSize = 24;
    } else if (combo == 5) {
      text = isTr ? "KOMBO x5 🌟" : "COMBO x5 🌟";
      color = const Color(0xFFF97316);
      fontSize = 26;
    } else {
      text = isTr ? "KOMBO x$combo 👑" : "COMBO x$combo 👑";
      color = const Color(0xFFA855F7);
      fontSize = 28;
    }

    floatingTexts.add(FloatingText(
      text: text,
      x: x,
      y: y,
      color: color,
      fontSize: fontSize,
      scale: 0.4,
      vy: -1.0,
    ));

    spawnComboSparks(x, y, combo);
  }

  void spawnFlyingScore({
    required String text,
    required double startX,
    required double startY,
    required double targetX,
    required double targetY,
    Color color = GameTheme.goldAccent,
    double fontSize = 14.0,
    VoidCallback? onArrived,
  }) {
    floatingTexts.add(FloatingText(
      text: text,
      x: startX,
      y: startY,
      targetX: targetX,
      targetY: targetY,
      color: color,
      fontSize: fontSize,
      scale: 0.95,
      onArrived: () {
        spawnExplosion(targetX, targetY, color, count: 5);
        onArrived?.call();
      },
    ));
  }

  // ── Thematic Atmospheric Particles ───────────────────────────────────────
  void spawnThematicAtmosphere(String skinId, double width, double height) {
    if (particles.length > 40) return; // Keep performance optimal

    final x = _rng.nextDouble() * width;
    final y = skinId == 'magma_volcano' ? height : _rng.nextDouble() * height;

    if (skinId == 'magma_volcano') {
      // Rising ember sparks
      particles.add(Particle(
        x: x, y: y,
        vx: (_rng.nextDouble() - 0.5) * 0.8,
        vy: -0.8 - _rng.nextDouble() * 1.5,
        size: 2.0 + _rng.nextDouble() * 3.0,
        color: _rng.nextBool() ? GameTheme.fireOrange : GameTheme.fireYellow,
        decay: 0.008 + _rng.nextDouble() * 0.01,
        gravity: -0.02,
        shape: ParticleShape.sparkle,
      ));
    } else if (skinId == 'glacial_crystal') {
      // Drifting gentle frost snowflakes
      particles.add(Particle(
        x: x, y: 0,
        vx: sin(_rng.nextDouble() * pi) * 0.6,
        vy: 0.6 + _rng.nextDouble() * 1.2,
        size: 2.5 + _rng.nextDouble() * 3.0,
        color: _rng.nextBool() ? Colors.white : GameTheme.frostCyan,
        decay: 0.006 + _rng.nextDouble() * 0.008,
        gravity: 0.01,
        shape: ParticleShape.sparkle,
      ));
    } else if (skinId == 'void_nebula') {
      // Cosmic pulsing purple motes
      particles.add(Particle(
        x: x, y: y,
        vx: (_rng.nextDouble() - 0.5) * 0.4,
        vy: (_rng.nextDouble() - 0.5) * 0.4,
        size: 3.0 + _rng.nextDouble() * 4.0,
        color: _rng.nextBool() ? GameTheme.voidPurple : Colors.purpleAccent,
        decay: 0.010 + _rng.nextDouble() * 0.012,
        gravity: 0.0,
        shape: ParticleShape.circle,
      ));
    } else if (skinId == 'golden_sovereign') {
      // Drifting golden glimmers
      particles.add(Particle(
        x: x, y: y,
        vx: (_rng.nextDouble() - 0.5) * 0.6,
        vy: 0.4 + _rng.nextDouble() * 0.8,
        size: 2.0 + _rng.nextDouble() * 3.5,
        color: _rng.nextBool() ? GameTheme.goldAccent : GameTheme.lightningYellow,
        decay: 0.008 + _rng.nextDouble() * 0.01,
        gravity: 0.02,
        shape: ParticleShape.star,
      ));
    }
  }
}
