import 'package:flutter/material.dart';
import '../../../../core/theme/game_theme.dart';
import 'block_skin_style.dart';
import 'polyomino_shape.dart';

enum BoardRealm {
  jewelSpectrum,
  astralGold,
  cyberLightning,
  amethystVoid;

  String get displayName {
    switch (this) {
      case BoardRealm.jewelSpectrum:
        return '💎 Zümrüt & Safir Diyarı';
      case BoardRealm.astralGold:
        return '🌟 Kutsal Astral Altın Diyarı';
      case BoardRealm.cyberLightning:
        return '⚡ Siber Şimşek Plazma Diyarı';
      case BoardRealm.amethystVoid:
        return '💥 Amortis Kozmik Nebula Diyarı';
    }
  }

  Color get themeColor {
    switch (this) {
      case BoardRealm.jewelSpectrum:
        return GameTheme.neonCyan;
      case BoardRealm.astralGold:
        return const Color(0xFFFDE047);
      case BoardRealm.cyberLightning:
        return const Color(0xFF38BDF8);
      case BoardRealm.amethystVoid:
        return const Color(0xFFC084FC);
    }
  }

  BlockSkinStyle get skinStyle => BlockSkinStyle.minimalGlass;

  List<Color> get palette {
    switch (this) {
      case BoardRealm.jewelSpectrum:
        return PolyominoShape.palette;
      case BoardRealm.astralGold:
        return const [
          Color(0xFFF59E0B), // Amber Gold
          Color(0xFFFDE047), // Bright Gold
          Color(0xFFFEF08A), // Champagne Gold
          Color(0xFFD97706), // Deep Gold
        ];
      case BoardRealm.cyberLightning:
        return const [
          Color(0xFF06B6D4), // Cyan Laser
          Color(0xFF38BDF8), // Sky Blue Plasma
          Color(0xFF60A5FA), // Neon Blue
          Color(0xFF67E8F9), // Electric Cyan
        ];
      case BoardRealm.amethystVoid:
        return const [
          Color(0xFFA855F7), // Deep Amethyst
          Color(0xFFC084FC), // Bright Lavender
          Color(0xFFE879F9), // Magenta Nebula
          Color(0xFF7E22CE), // Royal Purple
        ];
    }
  }
}
