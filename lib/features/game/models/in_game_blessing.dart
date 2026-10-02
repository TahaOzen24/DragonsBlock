import 'package:flutter/material.dart';
import '../../../core/localization/locale_manager.dart';
import '../../../core/theme/game_theme.dart';

enum BlessingRarity {
  common,
  rare,
  legendary;

  String get displayNameTr {
    switch (this) {
      case BlessingRarity.common:
        return 'Yaygın';
      case BlessingRarity.rare:
        return 'Nadir';
      case BlessingRarity.legendary:
        return 'Efsanevi';
    }
  }

  String get displayNameEn {
    switch (this) {
      case BlessingRarity.common:
        return 'Common';
      case BlessingRarity.rare:
        return 'Rare';
      case BlessingRarity.legendary:
        return 'Legendary';
    }
  }

  String get displayName => LocaleManager.instance.isTurkish ? displayNameTr : displayNameEn;

  Color get color {
    switch (this) {
      case BlessingRarity.common:
        return Colors.tealAccent;
      case BlessingRarity.rare:
        return GameTheme.fireOrange;
      case BlessingRarity.legendary:
        return GameTheme.goldAccent;
    }
  }
}

class InGameBlessing {
  final String id;
  final String titleTr;
  final String titleEn;
  final String descriptionTr;
  final String descriptionEn;
  final String icon;
  final BlessingRarity rarity;
  final Color themeColor;

  String get title => LocaleManager.instance.isTurkish ? titleTr : titleEn;
  String get description => LocaleManager.instance.isTurkish ? descriptionTr : descriptionEn;

  const InGameBlessing({
    required this.id,
    required this.titleTr,
    required this.titleEn,
    required this.descriptionTr,
    required this.descriptionEn,
    required this.icon,
    required this.rarity,
    required this.themeColor,
  });

  static const List<InGameBlessing> allBlessings = [
    InGameBlessing(
      id: 'gold_rush',
      titleTr: 'Altın Yağmuru',
      titleEn: 'Gold Rush',
      descriptionTr: 'Anında +150 Altın kazandırır.',
      descriptionEn: 'Instantly grants +150 Gold Shards.',
      icon: '🪙',
      rarity: BlessingRarity.common,
      themeColor: GameTheme.goldAccent,
    ),
    InGameBlessing(
      id: 'overload_arc',
      titleTr: 'Yıldırım Darbesi',
      titleEn: 'Lightning Strike',
      descriptionTr: 'Kombolarda rastgele 1 sütunu tamamen temizler.',
      descriptionEn: 'On combos, completely clears a random column.',
      icon: '⚡',
      rarity: BlessingRarity.rare,
      themeColor: GameTheme.lightningYellow,
    ),
    InGameBlessing(
      id: 'chrono_shield',
      titleTr: 'Kurtarma Kalkanı',
      titleEn: 'Rescue Shield',
      descriptionTr: 'Tahta sıkıştığında en alt satırı eriterek oyunu kurtarır.',
      descriptionEn: 'Melts the bottom row when blocked, saving your run.',
      icon: '🛡️',
      rarity: BlessingRarity.legendary,
      themeColor: Colors.tealAccent,
    ),
    InGameBlessing(
      id: 'frost_nova',
      titleTr: 'Buzul Süpürge',
      titleEn: 'Glacial Sweep',
      descriptionTr: 'Çoklu satır temizlendiğinde +%25 ekstra puan verir.',
      descriptionEn: 'Grants +25% bonus score on multi-line clears.',
      icon: '❄️',
      rarity: BlessingRarity.common,
      themeColor: GameTheme.frostCyan,
    ),
    InGameBlessing(
      id: 'void_singularity',
      titleTr: 'Hiçlik Patlaması',
      titleEn: 'Void Burst',
      descriptionTr: 'Satır temizliklerinde 2 rastgele dolu kareyi anında yok eder.',
      descriptionEn: 'On line clears, destroys 2 random filled blocks.',
      icon: '🔮',
      rarity: BlessingRarity.legendary,
      themeColor: GameTheme.voidPurple,
    ),
    InGameBlessing(
      id: 'frenzy_boost',
      titleTr: 'Ateş Enerjisi',
      titleEn: 'Fire Surge',
      descriptionTr: 'Fever süresini uzatır ve 2 kat puan kazandırır.',
      descriptionEn: 'Extends fever time and awards 2X score.',
      icon: '🔥',
      rarity: BlessingRarity.rare,
      themeColor: GameTheme.fireOrange,
    ),
  ];

  static List<InGameBlessing> getRandomBlessings(List<InGameBlessing> existing, {int count = 2}) {
    final available = allBlessings.where((b) => !existing.any((e) => e.id == b.id)).toList();
    if (available.isEmpty) return [];
    available.shuffle();
    return available.take(count).toList();
  }
}
