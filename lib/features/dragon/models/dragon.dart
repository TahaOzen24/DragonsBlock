import 'package:flutter/material.dart';
import '../../../core/localization/locale_manager.dart';
import '../../../core/theme/game_theme.dart';

/// Dragon Egg Types — determines playstyle, powers, and evolution path.
enum DragonEggType { fire, ice, storm, earth }

/// Evolution stages from hatchling to mythic leviathan.
enum DragonEvolutionStage {
  hatchling,   // Level 1
  drake,       // Level 10
  battleDragon, // Level 25
  ancientDragon, // Level 50
  mythicLeviathan, // Level 100
}

extension DragonEvolutionStageExt on DragonEvolutionStage {
  String get nameTr {
    switch (this) {
      case DragonEvolutionStage.hatchling: return 'Yavru Ejder';
      case DragonEvolutionStage.drake: return 'Genç Ejder';
      case DragonEvolutionStage.battleDragon: return 'Savaş Ejderi';
      case DragonEvolutionStage.ancientDragon: return 'Kadim Ejder';
      case DragonEvolutionStage.mythicLeviathan: return 'Efsanevi Leviathan';
    }
  }
  String get nameEn {
    switch (this) {
      case DragonEvolutionStage.hatchling: return 'Hatchling';
      case DragonEvolutionStage.drake: return 'Drake';
      case DragonEvolutionStage.battleDragon: return 'Battle Dragon';
      case DragonEvolutionStage.ancientDragon: return 'Ancient Dragon';
      case DragonEvolutionStage.mythicLeviathan: return 'Mythic Leviathan';
    }
  }
  String get displayName => LocaleManager.instance.isTurkish ? nameTr : nameEn;
}

class DragonDefinition {
  final DragonEggType eggType;
  final String nameTr;
  final String nameEn;
  final String eggEmoji;
  final String hatchlingEmoji;
  final String drakeEmoji;
  final String battleEmoji;
  final String ancientEmoji;
  final String mythicEmoji;
  final String imageAsset;
  final Color themeColor;
  final String passiveNameTr;
  final String passiveNameEn;
  final String passiveDescriptionTr;
  final String passiveDescriptionEn;
  final String powerNameTr;
  final String powerNameEn;
  final String powerDescriptionTr;
  final String powerDescriptionEn;
  final int powerMaxEnergy;
  final String personalityTr;
  final String personalityEn;

  String get name => LocaleManager.instance.isTurkish ? nameTr : nameEn;
  String get passiveName => LocaleManager.instance.isTurkish ? passiveNameTr : passiveNameEn;
  String get passiveDescription => LocaleManager.instance.isTurkish ? passiveDescriptionTr : passiveDescriptionEn;
  String get powerName => LocaleManager.instance.isTurkish ? powerNameTr : powerNameEn;
  String get powerDescription => LocaleManager.instance.isTurkish ? powerDescriptionTr : powerDescriptionEn;
  String get personality => LocaleManager.instance.isTurkish ? personalityTr : personalityEn;

  String getImageForStage(DragonEvolutionStage stage) {
    if (stage == DragonEvolutionStage.hatchling) {
      return 'assets/images/dragons/dragon_hatchling.jpg';
    }
    return imageAsset;
  }

  String getEmojiForStage(DragonEvolutionStage stage) {
    switch (stage) {
      case DragonEvolutionStage.hatchling:
        return hatchlingEmoji;
      case DragonEvolutionStage.drake:
        return drakeEmoji;
      case DragonEvolutionStage.battleDragon:
        return battleEmoji;
      case DragonEvolutionStage.ancientDragon:
        return ancientEmoji;
      case DragonEvolutionStage.mythicLeviathan:
        return mythicEmoji;
    }
  }

  const DragonDefinition({
    required this.eggType,
    required this.nameTr,
    required this.nameEn,
    required this.eggEmoji,
    required this.hatchlingEmoji,
    required this.drakeEmoji,
    required this.battleEmoji,
    required this.ancientEmoji,
    required this.mythicEmoji,
    required this.imageAsset,
    required this.themeColor,
    required this.passiveNameTr,
    required this.passiveNameEn,
    required this.passiveDescriptionTr,
    required this.passiveDescriptionEn,
    required this.powerNameTr,
    required this.powerNameEn,
    required this.powerDescriptionTr,
    required this.powerDescriptionEn,
    this.powerMaxEnergy = 100,
    required this.personalityTr,
    required this.personalityEn,
  });

  static const List<DragonDefinition> allDragons = [
    DragonDefinition(
      eggType: DragonEggType.fire,
      nameTr: 'Pyraxis',
      nameEn: 'Pyraxis',
      eggEmoji: '🔥',
      hatchlingEmoji: '🐣',
      drakeEmoji: '🦎',
      battleEmoji: '🐉',
      ancientEmoji: '🐲',
      mythicEmoji: '🌌',
      imageAsset: 'assets/images/dragons/dragon_pyro.jpg',
      themeColor: GameTheme.fireOrange,
      passiveNameTr: 'Alev Rezonansı',
      passiveNameEn: 'Flame Resonance',
      passiveDescriptionTr: 'Çoklu hat temizliklerinde +%25 daha fazla puan kazandırır.',
      passiveDescriptionEn: 'Multi-line clears award +25% bonus points.',
      powerNameTr: '🔥 Alev Nefesi',
      powerNameEn: '🔥 Fire Breath',
      powerDescriptionTr: 'Tahtadaki seçili veya en kalabalık 3x3 alanı yakarak anında temizler.',
      powerDescriptionEn: 'Burns and instantly clears the most crowded 3x3 area on the board.',
      personalityTr: 'Agresif ve patlayıcı',
      personalityEn: 'Aggressive & explosive',
    ),
    DragonDefinition(
      eggType: DragonEggType.ice,
      nameTr: 'Glacius',
      nameEn: 'Glacius',
      eggEmoji: '❄️',
      hatchlingEmoji: '🐣',
      drakeEmoji: '🦎',
      battleEmoji: '🐉',
      ancientEmoji: '🐲',
      mythicEmoji: '🌌',
      imageAsset: 'assets/images/dragons/dragon_frost.jpg',
      themeColor: GameTheme.frostCyan,
      passiveNameTr: 'Donmuş Koruma',
      passiveNameEn: 'Frozen Protection',
      passiveDescriptionTr: 'Kombo süresi %30 daha yavaş tükenir.',
      passiveDescriptionEn: 'Combo timer depletes 30% slower.',
      powerNameTr: '❄️ Donmuş Kafes',
      powerNameEn: '❄️ Frozen Cage',
      powerDescriptionTr: 'Bir şekli sonraki turlar için buz kafesine alıp saklar.',
      powerDescriptionEn: 'Captures a shape in an ice cage, holding it for future turns.',
      personalityTr: 'Kontrollü ve soğukkanlı',
      personalityEn: 'Controlled & calculating',
    ),
    DragonDefinition(
      eggType: DragonEggType.storm,
      nameTr: 'Voltaris',
      nameEn: 'Voltaris',
      eggEmoji: '⚡',
      hatchlingEmoji: '🐣',
      drakeEmoji: '🦎',
      battleEmoji: '🐉',
      ancientEmoji: '🐲',
      mythicEmoji: '🌌',
      imageAsset: 'assets/images/dragons/dragon_storm.jpg',
      themeColor: GameTheme.lightningYellow,
      passiveNameTr: 'Yüksek Voltaj',
      passiveNameEn: 'High Voltage',
      passiveDescriptionTr: 'Nihai yetenek her hat temizliğinde %20 daha hızlı şarj olur.',
      passiveDescriptionEn: 'Dragon power charges 20% faster on each line clear.',
      powerNameTr: '⚡ Yıldırım Zinciri',
      powerNameEn: '⚡ Lightning Chain',
      powerDescriptionTr: 'Eksik kalan bir satır veya sütunu yıldırımla anında tamamlar.',
      powerDescriptionEn: 'Instantly completes a nearly-full row or column with lightning.',
      personalityTr: 'Hızlı ve enerjik',
      personalityEn: 'Fast & energetic',
    ),
    DragonDefinition(
      eggType: DragonEggType.earth,
      nameTr: 'Terranon',
      nameEn: 'Terranon',
      eggEmoji: '🌍',
      hatchlingEmoji: '🐣',
      drakeEmoji: '🦎',
      battleEmoji: '🐉',
      ancientEmoji: '🐲',
      mythicEmoji: '🌌',
      imageAsset: 'assets/images/dragons/dragon_terra.jpg',
      themeColor: GameTheme.earthGreen,
      passiveNameTr: 'Taş Kalkan',
      passiveNameEn: 'Stone Shield',
      passiveDescriptionTr: 'Kritik hücreleri koruyarak taş kalkan oluşturur.',
      passiveDescriptionEn: 'Creates stone shields to protect critical cells.',
      powerNameTr: '🌍 Taş Kalkan',
      powerNameEn: '🌍 Stone Shield',
      powerDescriptionTr: 'Kritik çıkmazlarda kurtarıcı koruma blokları oluşturur.',
      powerDescriptionEn: 'Creates rescue shield blocks in critical dead-end situations.',
      personalityTr: 'Güçlü ve koruyucu',
      personalityEn: 'Strong & protective',
    ),
  ];
}

/// Evolution stage thresholds
class DragonEvolution {
  static DragonEvolutionStage getStageForLevel(int level) {
    if (level >= 100) return DragonEvolutionStage.mythicLeviathan;
    if (level >= 50) return DragonEvolutionStage.ancientDragon;
    if (level >= 25) return DragonEvolutionStage.battleDragon;
    if (level >= 10) return DragonEvolutionStage.drake;
    return DragonEvolutionStage.hatchling;
  }

  static int expForLevel(int level) {
    if (level <= 1) return 0;
    return (level * level * 50) + (level * 100);
  }

  static int expForNextLevel(int currentLevel) {
    return expForLevel(currentLevel + 1);
  }

  static String getStageName(DragonEvolutionStage stage) {
    switch (stage) {
      case DragonEvolutionStage.hatchling:
        return LocaleManager.instance.isTurkish ? 'Yavru' : 'Hatchling';
      case DragonEvolutionStage.drake:
        return LocaleManager.instance.isTurkish ? 'Genç Ejderha' : 'Drake';
      case DragonEvolutionStage.battleDragon:
        return LocaleManager.instance.isTurkish ? 'Savaş Ejderhası' : 'Battle Dragon';
      case DragonEvolutionStage.ancientDragon:
        return LocaleManager.instance.isTurkish ? 'Kadim Ejderha' : 'Ancient Dragon';
      case DragonEvolutionStage.mythicLeviathan:
        return LocaleManager.instance.isTurkish ? 'Efsanevi Leviathan' : 'Mythic Leviathan';
    }
  }

  static double expProgress(int currentExp, int level) {
    final currentLevelExp = expForLevel(level);
    final nextLevelExp = expForNextLevel(level);
    final needed = nextLevelExp - currentLevelExp;
    if (needed <= 0) return 1.0;
    return ((currentExp - currentLevelExp) / needed).clamp(0.0, 1.0);
  }
}
