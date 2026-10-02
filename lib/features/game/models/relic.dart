import 'package:flutter/material.dart';
import '../../../core/localization/locale_manager.dart';
import '../../../core/theme/game_theme.dart';

enum RelicRarity {
  common,
  rare,
  legendary;

  String get displayNameTr {
    switch (this) {
      case RelicRarity.common:
        return 'Yaygın Yadigâr';
      case RelicRarity.rare:
        return 'Nadir Yadigâr';
      case RelicRarity.legendary:
        return 'Efsanevi Yadigâr';
    }
  }

  String get displayNameEn {
    switch (this) {
      case RelicRarity.common:
        return 'Common Relic';
      case RelicRarity.rare:
        return 'Rare Relic';
      case RelicRarity.legendary:
        return 'Legendary Relic';
    }
  }

  String get displayName => LocaleManager.instance.isTurkish ? displayNameTr : displayNameEn;

  Color get color {
    switch (this) {
      case RelicRarity.common:
        return GameTheme.neonCyan;
      case RelicRarity.rare:
        return GameTheme.voidPurple;
      case RelicRarity.legendary:
        return GameTheme.goldAccent;
    }
  }
}

class Relic {
  final String id;
  final String nameTr;
  final String nameEn;
  final String descriptionTr;
  final String descriptionEn;
  final String icon;
  final RelicRarity rarity;
  final double scoreMultiplier;
  final bool hasEmergencySave;

  String get name => LocaleManager.instance.isTurkish ? nameTr : nameEn;
  String get description => LocaleManager.instance.isTurkish ? descriptionTr : descriptionEn;

  const Relic({
    required this.id,
    required this.nameTr,
    required this.nameEn,
    required this.descriptionTr,
    required this.descriptionEn,
    required this.icon,
    required this.rarity,
    this.scoreMultiplier = 1.0,
    this.hasEmergencySave = false,
  });

  static List<Relic> get allRelics => const [
        Relic(
          id: 'pyro_core',
          nameTr: "Ateş Büyücüsünün Çekirdeği",
          nameEn: "Pyromancer's Core",
          descriptionTr: "Hat patlamaları süper enerji dalgası yayar. Tüm puanlar +%20.",
          descriptionEn: "Line clears emit a supercharged energy blast. All points +20%.",
          icon: "🔥",
          rarity: RelicRarity.common,
          scoreMultiplier: 1.2,
        ),
        Relic(
          id: 'overcharge_coil',
          nameTr: "Aşırı Yük Bobini",
          nameEn: "Overcharge Coil",
          descriptionTr: "Her temizliğe bonus enerji yükler. Tüm puanlar +%35.",
          descriptionEn: "Charges every clear with bonus energy. All points +35%.",
          icon: "⚡",
          rarity: RelicRarity.rare,
          scoreMultiplier: 1.35,
        ),
        Relic(
          id: 'glacial_mirror',
          nameTr: "Buzul Aynası",
          nameEn: "Glacial Mirror",
          descriptionTr: "Kombo serisi puanlarını ikiye katlar. Tüm puanlar +%50.",
          descriptionEn: "Doubles combo streak points. All points +50%.",
          icon: "❄️",
          rarity: RelicRarity.rare,
          scoreMultiplier: 1.5,
        ),
        Relic(
          id: 'void_siphon',
          nameTr: "Hiçlik Emicisi",
          nameEn: "Void Siphon",
          descriptionTr: "Çoklu hat temizlikleri ekstra bonus puan kazandırır. Tüm puanlar +%60.",
          descriptionEn: "Multi-line clears grant massive bonus points. All points +60%.",
          icon: "🔮",
          rarity: RelicRarity.legendary,
          scoreMultiplier: 1.6,
        ),
        Relic(
          id: 'midas_touch',
          nameTr: "Midas Dokunuşu",
          nameEn: "Midas Touch",
          descriptionTr: "Hat temizliklerinde %25 şansla +200 bonus Altın Şarapnel kazanılır. Tüm puanlar +%10.",
          descriptionEn: "Line clears have a 25% chance to award +200 bonus Gold Shards. All points +10%.",
          icon: "🪙",
          rarity: RelicRarity.common,
          scoreMultiplier: 1.10,
        ),
        Relic(
          id: 'tetra_master',
          nameTr: "Tetra Ustası",
          nameEn: "Tetra Master",
          descriptionTr: "4+ bloklu herhangi bir şekil yerleştirmek anında +250 puan kazandırır. Tüm puanlar +%15.",
          descriptionEn: "Placing any shape with 4+ blocks immediately grants +250 points. All points +15%.",
          icon: "🧱",
          rarity: RelicRarity.common,
          scoreMultiplier: 1.15,
        ),
        Relic(
          id: 'emergency_sledge',
          nameTr: "Acil Durum Çekirdeği",
          nameEn: "Emergency Core",
          descriptionTr: "Tahta kilitlenmek üzereyken 6 bloğu otomatik yok eder (koşu başına 1 kez).",
          descriptionEn: "Auto-destroys 6 blocks when the board is about to lock (1x per run).",
          icon: "🛡️",
          rarity: RelicRarity.legendary,
          hasEmergencySave: true,
        ),
        Relic(
          id: 'architect_compass',
          nameTr: "Mimarın Matrisi",
          nameEn: "Architect's Matrix",
          descriptionTr: "Izgarayı lehinize yeniden şekillendirir. Tüm puanlar +%40.",
          descriptionEn: "Reshapes the grid in your favor. All points +40%.",
          icon: "📐",
          rarity: RelicRarity.rare,
          scoreMultiplier: 1.4,
        ),
        Relic(
          id: 'phoenix_feather',
          nameTr: "Anka Tüyü",
          nameEn: "Phoenix Feather",
          descriptionTr: "Tahta kilitlendiğinde merkezdeki 4x4 alanı küle çevirir (koşu başına 1 kez). Tüm puanlar +%25.",
          descriptionEn: "Incinerates the central 4x4 sector when the board locks (1x per run). All points +25%.",
          icon: "🪶",
          rarity: RelicRarity.legendary,
          hasEmergencySave: true,
          scoreMultiplier: 1.25,
        ),
        Relic(
          id: 'chain_reactor',
          nameTr: "Zincir Reaktörü",
          nameEn: "Chain Reactor",
          descriptionTr: "Ardı ardına temizlikler zincirleme reaksiyon tetikler. Tüm puanlar +%45.",
          descriptionEn: "Consecutive clears trigger chain reaction multipliers. All points +45%.",
          icon: "⛓️",
          rarity: RelicRarity.rare,
          scoreMultiplier: 1.45,
        ),
        Relic(
          id: 'alchemist_stone',
          nameTr: "Felsefe Taşı",
          nameEn: "Philosopher's Stone",
          descriptionTr: "Çoklu hat temizlikleri +300 bonus şarapnel kazandırır. Tüm puanlar +%50.",
          descriptionEn: "Multi-line clears grant +300 bonus shards. All points +50%.",
          icon: "💎",
          rarity: RelicRarity.legendary,
          scoreMultiplier: 1.5,
        ),
      ];
}

