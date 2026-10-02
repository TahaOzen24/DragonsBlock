import 'package:flutter/material.dart';
import '../../../core/localization/locale_manager.dart';

enum GameMode {
  classic,
  adventure;

  String get titleTr {
    switch (this) {
      case GameMode.classic:
        return 'Sonsuz Mod';
      case GameMode.adventure:
        return 'Görev & Harita';
    }
  }

  String get titleEn {
    switch (this) {
      case GameMode.classic:
        return 'Endless Mode';
      case GameMode.adventure:
        return 'Mission & Map';
    }
  }

  String get title => LocaleManager.instance.isTurkish ? titleTr : titleEn;

  /// Epik AAA Başlık
  String get epicTitle {
    switch (this) {
      case GameMode.classic:
        return 'SONSUZ HAYATTA KALMA';
      case GameMode.adventure:
        return 'KADİM GÖREV SEFERİ';
    }
  }

  /// Rozet Etiketi
  String get badgeTag {
    switch (this) {
      case GameMode.classic:
        return 'REKOR MÜCADELESİ';
      case GameMode.adventure:
        return 'HARİTA İLERLEMESİ';
    }
  }

  String get subtitleTr {
    switch (this) {
      case GameMode.classic:
        return 'Süre ve hamle sınırı yok. Blokları yerleştir, yüksek kombolar yap ve en yüksek skoru kır!';
      case GameMode.adventure:
        return 'Haritada aşama aşama ilerle. Tahtadaki özel görevleri (buz kırma, mücevher toplama) tamamla ve yıldızları kazan!';
    }
  }

  String get subtitleEn {
    switch (this) {
      case GameMode.classic:
        return 'No timer or move limits. Place blocks, chain juicy combos, and chase the ultimate high score!';
      case GameMode.adventure:
        return 'Progress through the world map. Complete board objectives (shatter ice, gather gems) and earn 3 stars!';
    }
  }

  String get subtitle => LocaleManager.instance.isTurkish ? subtitleTr : subtitleEn;

  /// Mod mekanik etiketleri (Kural Çipleri)
  List<String> get mechanicChips {
    switch (this) {
      case GameMode.classic:
        return ['♾️ Süresiz Oyun', '⚡ Yüksek Skor', '🏆 Global Sıralama'];
      case GameMode.adventure:
        return ['🗺️ Bölüm Haritası', '🧊 Özel Görevler', '⭐ 3 Yıldız Sistemi'];
    }
  }

  String get icon {
    switch (this) {
      case GameMode.classic:
        return '👑';
      case GameMode.adventure:
        return '🗺️';
    }
  }

  String get runeGlyph {
    switch (this) {
      case GameMode.classic:
        return '✦';
      case GameMode.adventure:
        return 'ᛟ';
    }
  }

  Color get themeColor {
    switch (this) {
      case GameMode.classic:
        return const Color(0xFF38BDF8); // Cyan Sky
      case GameMode.adventure:
        return const Color(0xFFF59E0B); // Amber Gold
    }
  }

  Color get darkCardBaseColor {
    switch (this) {
      case GameMode.classic:
        return const Color(0xFF0C192C);
      case GameMode.adventure:
        return const Color(0xFF221607);
    }
  }

  String get highScoreKey {
    switch (this) {
      case GameMode.classic:
        return 'high_score';
      case GameMode.adventure:
        return 'adventure_unlocked_level';
    }
  }
}
