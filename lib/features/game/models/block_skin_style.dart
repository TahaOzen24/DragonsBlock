import 'package:flutter/material.dart';

enum BlockSkinStyle {
  softJelly,
  gemstone3D,
  cozyWool,
  nordicWood,
  zenCeramic,
  neonEnergy,
  cosmicStardust,
  minimalGlass,
}

extension BlockSkinStyleExt on BlockSkinStyle {
  String get displayName {
    switch (this) {
      case BlockSkinStyle.minimalGlass:
        return '✨ Düz Modern Kare';
      case BlockSkinStyle.gemstone3D:
        return '💎 3D Kristal Pah';
      case BlockSkinStyle.softJelly:
        return '🌸 Yumuşak Mat';
      case BlockSkinStyle.neonEnergy:
        return '⚡ Siber Neon';
      case BlockSkinStyle.zenCeramic:
        return '🏺 Sırlı Seramik';
      case BlockSkinStyle.nordicWood:
        return '🪵 Ahşap Zanaat';
      case BlockSkinStyle.cosmicStardust:
        return '🌌 Kozmik Galaksi';
      case BlockSkinStyle.cozyWool:
        return '🧶 Sıcak Dokuma';
    }
  }

  String get emoji {
    switch (this) {
      case BlockSkinStyle.minimalGlass:
        return '✨';
      case BlockSkinStyle.gemstone3D:
        return '💎';
      case BlockSkinStyle.softJelly:
        return '🌸';
      case BlockSkinStyle.neonEnergy:
        return '⚡';
      case BlockSkinStyle.zenCeramic:
        return '🏺';
      case BlockSkinStyle.nordicWood:
        return '🪵';
      case BlockSkinStyle.cosmicStardust:
        return '🌌';
      case BlockSkinStyle.cozyWool:
        return '🧶';
    }
  }

  String get description {
    switch (this) {
      case BlockSkinStyle.minimalGlass:
        return 'Sade, düz ve son derece keskin modern kare';
      case BlockSkinStyle.gemstone3D:
        return 'Klasik 4-pahlı derin açılı kristal blok';
      case BlockSkinStyle.softJelly:
        return 'İpeksi kadife mat yüzey ve tepe parıltısı';
      case BlockSkinStyle.neonEnergy:
        return 'Işıltılı siber çerçeve ve enerjik çekirdek';
      case BlockSkinStyle.zenCeramic:
        return 'Pürüzsüz sır kaplamalı diyagonal parlaklık';
      case BlockSkinStyle.nordicWood:
        return 'Doğal ahşap lifleri ve oyma kenarlar';
      case BlockSkinStyle.cosmicStardust:
        return 'Derin uzay gradyanı ve parıldayan yıldız tozu';
      case BlockSkinStyle.cozyWool:
        return 'Dokunsal dikiş detaylı sıcak keçe kare';
    }
  }

  double get cornerRadius {
    switch (this) {
      case BlockSkinStyle.softJelly:
        return 12.0;
      case BlockSkinStyle.gemstone3D:
        return 7.0;
      case BlockSkinStyle.cozyWool:
        return 11.0;
      case BlockSkinStyle.nordicWood:
        return 6.0;
      case BlockSkinStyle.zenCeramic:
        return 9.0;
      case BlockSkinStyle.neonEnergy:
        return 6.0;
      case BlockSkinStyle.cosmicStardust:
        return 9.0;
      case BlockSkinStyle.minimalGlass:
        return 10.0;
    }
  }

  Color getStingerColor(Color baseColor) {
    switch (this) {
      case BlockSkinStyle.softJelly:
        return const Color(0xFFFF80AB);
      case BlockSkinStyle.gemstone3D:
        return const Color(0xFFFFD700);
      case BlockSkinStyle.cozyWool:
        return const Color(0xFFFFB74D);
      case BlockSkinStyle.nordicWood:
        return const Color(0xFFFFCC80);
      case BlockSkinStyle.zenCeramic:
        return const Color(0xFFE0E0E0);
      case BlockSkinStyle.neonEnergy:
        return const Color(0xFF00E6FF);
      case BlockSkinStyle.cosmicStardust:
        return const Color(0xFFB388FF);
      case BlockSkinStyle.minimalGlass:
        return const Color(0xFFE8F5E9);
    }
  }
}
