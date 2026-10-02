import 'package:flutter/material.dart';

/// The 4 Grand Milestones / Eras of Game Progression.
/// Replaces random, noisy realm flipping with earned, prestigious visual evolutions.
enum BoardEra {
  bronze, // 0 - 4,999
  silver, // 5,000 - 14,999
  gold,   // 15,000 - 29,999
  astral; // 30,000+

  static BoardEra fromScore(int score) {
    if (score >= 30000) return BoardEra.astral;
    if (score >= 15000) return BoardEra.gold;
    if (score >= 5000) return BoardEra.silver;
    return BoardEra.bronze;
  }

  String get title {
    switch (this) {
      case BoardEra.bronze:
        return 'TUNÇ ÇAĞI';
      case BoardEra.silver:
        return 'GÜMÜŞ OBSİDYEN ÇAĞI';
      case BoardEra.gold:
        return 'KADİM ALTIN ÇAĞI';
      case BoardEra.astral:
        return 'KOZMİK ASTRAL ÇAĞ';
    }
  }

  String get badgeGlyph {
    switch (this) {
      case BoardEra.bronze:
        return '🥉';
      case BoardEra.silver:
        return '🥈';
      case BoardEra.gold:
        return '👑';
      case BoardEra.astral:
        return '🌌';
    }
  }

  /// Board Metallic Frame Border Color
  Color get frameBorderColor {
    switch (this) {
      case BoardEra.bronze:
        return const Color(0xFF926337); // Ancient Bronze
      case BoardEra.silver:
        return const Color(0xFFCBD5E1); // Polished Sterling Silver
      case BoardEra.gold:
        return const Color(0xFFE2B857); // Ancient Royal Gold
      case BoardEra.astral:
        return const Color(0xFFA855F7); // Celestial Void Purple
    }
  }

  /// Subtle Ambient Grid Glow
  Color get ambientGlow {
    switch (this) {
      case BoardEra.bronze:
        return const Color(0xFFD97706).withValues(alpha: 0.18);
      case BoardEra.silver:
        return const Color(0xFF38BDF8).withValues(alpha: 0.22);
      case BoardEra.gold:
        return const Color(0xFFF59E0B).withValues(alpha: 0.28);
      case BoardEra.astral:
        return const Color(0xFFA855F7).withValues(alpha: 0.32);
    }
  }

  /// Empty Grid Cell Base Background
  Color get emptyCellColor {
    switch (this) {
      case BoardEra.bronze:
        return const Color(0xFF0F172A);
      case BoardEra.silver:
        return const Color(0xFF0C1628);
      case BoardEra.gold:
        return const Color(0xFF14120E);
      case BoardEra.astral:
        return const Color(0xFF120C22);
    }
  }
}
