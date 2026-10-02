import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/localization/locale_manager.dart';
import '../../../../core/storage/app_prefs.dart';
import '../../../../core/theme/game_theme.dart';
import 'boss.dart';

enum ObjectiveType {
  scoreTarget,
  shatterIce,
  clearLines,
  treasureChest,
  bossBattle,
}

class AdventureWorld {
  final int id;
  final String nameTr;
  final String nameEn;
  final String title;
  final String subtitleTr;
  final String subtitleEn;
  final String icon;
  final Color primaryColor;
  final Color glowColor;

  const AdventureWorld({
    required this.id,
    required this.nameTr,
    required this.nameEn,
    required this.title,
    required this.subtitleTr,
    required this.subtitleEn,
    required this.icon,
    required this.primaryColor,
    required this.glowColor,
  });

  String get name => LocaleManager.instance.isTurkish ? nameTr : nameEn;
  String get subtitle => LocaleManager.instance.isTurkish ? subtitleTr : subtitleEn;

  static const List<AdventureWorld> worlds = [
    AdventureWorld(
      id: 1,
      nameTr: 'Alev Krallığı',
      nameEn: 'Fire Kingdom',
      title: 'Pyro Highlands',
      subtitleTr: 'Ateşli kalıntıların ve volkanik dağların diyarı',
      subtitleEn: 'Realm of volcanic relics and highlands',
      icon: '🔥',
      primaryColor: GameTheme.fireOrange,
      glowColor: GameTheme.fireYellow,
    ),
    AdventureWorld(
      id: 2,
      nameTr: 'Buzul Zirvesi',
      nameEn: 'Glacier Summit',
      title: 'Glacial Peak',
      subtitleTr: 'Donmuş buz kristalleri ve kutup rüzgarları',
      subtitleEn: 'Frozen ice crystals and polar storms',
      icon: '❄️',
      primaryColor: GameTheme.frostCyan,
      glowColor: GameTheme.neonCyan,
    ),
    AdventureWorld(
      id: 3,
      nameTr: 'Fırtına Kanyonu',
      nameEn: 'Storm Canyon',
      title: 'Thunder Chasm',
      subtitleTr: 'Yüksek voltajlı yıldırımlar ve aşırı yükler',
      subtitleEn: 'High-voltage lightning and power surges',
      icon: '⚡',
      primaryColor: GameTheme.lightningYellow,
      glowColor: GameTheme.goldAccent,
    ),
    AdventureWorld(
      id: 4,
      nameTr: 'Hiçlik Boyutu',
      nameEn: 'Void Dimension',
      title: 'Void Abyss',
      subtitleTr: 'Karanlık tekillik ve boyut yırtıkları',
      subtitleEn: 'Dark singularities and dimensional tears',
      icon: '🔮',
      primaryColor: GameTheme.voidPurple,
      glowColor: GameTheme.neonCyan,
    ),
    AdventureWorld(
      id: 5,
      nameTr: 'Zümrüt Tapınağı',
      nameEn: 'Emerald Temple',
      title: 'Emerald Sanctum',
      subtitleTr: 'Kadim doğa enerjisi ve asırlık zümrütler',
      subtitleEn: 'Ancient nature energy and centuries-old emeralds',
      icon: '🍃',
      primaryColor: GameTheme.emeraldGreen,
      glowColor: Color(0xFF69F0AE),
    ),
    AdventureWorld(
      id: 6,
      nameTr: 'Kutsal Bastion',
      nameEn: 'Holy Bastion',
      title: 'Celestial Bastion',
      subtitleTr: '24K Altın parıltısı ve kutsal güneş rünleri',
      subtitleEn: '24K gold shimmer and celestial sun runes',
      icon: '👑',
      primaryColor: GameTheme.goldAccent,
      glowColor: Colors.amberAccent,
    ),
  ];

  static AdventureWorld getWorldForFloor(int floorNumber) {
    // 10 floors per world chapter (1..10 = World 1, 11..20 = World 2, etc.)
    final index = ((floorNumber - 1) ~/ 10) % worlds.length;
    return worlds[index];
  }

  static AdventureWorld getWorldById(int worldId) {
    return worlds.firstWhere((w) => w.id == worldId, orElse: () => worlds.first);
  }
}

class AdventureLevel {
  final int levelIndex; // 1-based floor number (1..infinity)
  final int worldId;
  final String titleTr;
  final String titleEn;
  final ObjectiveType objectiveType;
  final int maxMoves;
  final int targetScore;
  final int targetIceCount;
  final int targetLineCount;
  final Boss? boss;
  final List<Point<int>> initialIceCells;
  final int rewardShards;

  const AdventureLevel({
    required this.levelIndex,
    required this.worldId,
    required this.titleTr,
    required this.titleEn,
    required this.objectiveType,
    required this.maxMoves,
    this.targetScore = 0,
    this.targetIceCount = 0,
    this.targetLineCount = 0,
    this.boss,
    this.initialIceCells = const [],
    this.rewardShards = 150,
  });

  String get title => LocaleManager.instance.isTurkish ? titleTr : titleEn;

  // ─── Persistence Helpers ───────────────────────────────────────────────────

  static const String _levelStarsPrefix = 'adventure_stars_lvl_';

  static Future<int> getUnlockedLevel() async {
    await AppPrefs.instance.init();
    final val1 = AppPrefs.instance.getInt(AppPrefs.kAdventureUnlockedLevel);
    final val2 = AppPrefs.instance.getInt(AppPrefs.kAdventureHighestFloor);
    return max(val1 ?? 1, val2 ?? 1);
  }

  static Future<void> unlockNextLevel(int completedLevel) async {
    await AppPrefs.instance.init();
    final currentUnlocked = await getUnlockedLevel();
    if (completedLevel >= currentUnlocked) {
      await AppPrefs.instance.setInt(AppPrefs.kAdventureUnlockedLevel, completedLevel + 1);
      await AppPrefs.instance.setInt(AppPrefs.kAdventureHighestFloor, completedLevel + 1);
    }
  }

  static Future<int> getStarsForLevel(int levelIndex) async {
    await AppPrefs.instance.init();
    return AppPrefs.instance.getInt('$_levelStarsPrefix$levelIndex') ?? 0;
  }

  static Future<void> saveStarsForLevel(int levelIndex, int stars) async {
    await AppPrefs.instance.init();
    final current = AppPrefs.instance.getInt('$_levelStarsPrefix$levelIndex') ?? 0;
    if (stars > current) {
      await AppPrefs.instance.setInt('$_levelStarsPrefix$levelIndex', stars);
    }
  }

  static Future<Map<int, int>> getAllStars() async {
    await AppPrefs.instance.init();
    final unlocked = await getUnlockedLevel();
    final maxToCheck = max(unlocked + 20, 60);
    final Map<int, int> starsMap = {};
    for (int i = 1; i <= maxToCheck; i++) {
      starsMap[i] = AppPrefs.instance.getInt('$_levelStarsPrefix$i') ?? 0;
    }
    return starsMap;
  }

  static Future<int> getTotalStars() async {
    final map = await getAllStars();
    return map.values.fold<int>(0, (sum, val) => sum + val);
  }

  // ─── Balanced & Relaxed Level Generator ─────────────────────────────────────

  /// Deterministically creates a balanced, comfortable level for any floor 1..infinity.
  /// Each World contains 10 structured floors with generous moves (28-36) and diverse objectives.
  static AdventureLevel getLevel(int floorNumber) {
    final world = AdventureWorld.getWorldForFloor(floorNumber);
    final stepInWorld = ((floorNumber - 1) % 10) + 1; // 1..10
    final worldIndex = (floorNumber - 1) ~/ 10;
    final baseReward = 150 + (floorNumber * 15);

    // 10. Bölüm: Diyar Boss Savaşı (World Boss Finale)
    if (stepInWorld == 10) {
      final boss = Boss.generateForFloor(floorNumber);
      return AdventureLevel(
        levelIndex: floorNumber,
        worldId: world.id,
        titleTr: '👑 Bölüm $floorNumber: ${boss.nameTr}',
        titleEn: '👑 Floor $floorNumber: ${boss.nameEn}',
        objectiveType: ObjectiveType.bossBattle,
        maxMoves: (34 + (worldIndex % 3)).clamp(34, 40),
        boss: boss,
        rewardShards: boss.rewardShards,
      );
    }

    // 5. Bölüm: Gizli Hazine Odası (Milestone Treasure Vault)
    if (stepInWorld == 5) {
      return AdventureLevel(
        levelIndex: floorNumber,
        worldId: world.id,
        titleTr: '🎁 Bölüm $floorNumber: Gizli Hazine Sandığı',
        titleEn: '🎁 Floor $floorNumber: Secret Treasure Vault',
        objectiveType: ObjectiveType.treasureChest,
        maxMoves: 32,
        targetLineCount: 5,
        rewardShards: baseReward + 300, // Extra shards for milestone!
      );
    }

    final rng = Random(floorNumber * 7919);

    // 3. ve 6. Bölüm: Donmuş Kristal Kırma (Shatter Ice - ferah yerleşim)
    if (stepInWorld == 3 || stepInWorld == 6) {
      final iceCount = stepInWorld == 3
          ? (4 + (worldIndex % 3)).clamp(4, 7)
          : (5 + (worldIndex % 4)).clamp(5, 9);

      // Aesthetic non-blocking placements (outer perimeter & quadrants)
      final candidateSlots = [
        const Point(1, 1), const Point(1, 6),
        const Point(6, 1), const Point(6, 6),
        const Point(2, 2), const Point(2, 5),
        const Point(5, 2), const Point(5, 5),
        const Point(1, 3), const Point(1, 4),
        const Point(6, 3), const Point(6, 4),
      ]..shuffle(rng);

      final iceCells = candidateSlots.take(iceCount).toList();

      return AdventureLevel(
        levelIndex: floorNumber,
        worldId: world.id,
        titleTr: stepInWorld == 3
            ? '❄️ Bölüm $floorNumber: Donmuş Rünler'
            : '❄️ Bölüm $floorNumber: Kristal Çözücü',
        titleEn: stepInWorld == 3
            ? '❄️ Floor $floorNumber: Frozen Runes'
            : '❄️ Floor $floorNumber: Crystal Breaker',
        objectiveType: ObjectiveType.shatterIce,
        maxMoves: (30 + (worldIndex % 3)).clamp(30, 35),
        targetIceCount: iceCount,
        initialIceCells: iceCells,
        rewardShards: baseReward + 50,
      );
    }

    // 2., 7. ve 9. Bölüm: Hat Temizliği (Clear Lines - rahat ve ferah)
    if (stepInWorld == 2 || stepInWorld == 7 || stepInWorld == 9) {
      final targetLines = stepInWorld == 2
          ? (4 + (worldIndex % 2)).clamp(4, 6)
          : (stepInWorld == 7
              ? (5 + (worldIndex % 3)).clamp(5, 7)
              : (6 + (worldIndex % 2)).clamp(6, 8));

      return AdventureLevel(
        levelIndex: floorNumber,
        worldId: world.id,
        titleTr: stepInWorld == 2
            ? '⚡ Bölüm $floorNumber: Hat Temizliği'
            : (stepInWorld == 7
                ? '⚡ Bölüm $floorNumber: Yıldırım Hatları'
                : '⚡ Bölüm $floorNumber: Kadim Rün Kapısı'),
        titleEn: stepInWorld == 2
            ? '⚡ Floor $floorNumber: Clear Lines'
            : (stepInWorld == 7
                ? '⚡ Floor $floorNumber: Lightning Lines'
                : '⚡ Floor $floorNumber: Ancient Rune Gate'),
        objectiveType: ObjectiveType.clearLines,
        maxMoves: (30 + (worldIndex % 3)).clamp(28, 34),
        targetLineCount: targetLines,
        rewardShards: baseReward,
      );
    }

    // 1., 4. ve 8. Bölüm: Puan Hedefi (Score Target - ulaşılabilir hedefler)
    final targetScore = stepInWorld == 1
        ? (900 + worldIndex * 300)
        : (stepInWorld == 4
            ? (1600 + worldIndex * 400)
            : (2400 + worldIndex * 500));

    return AdventureLevel(
      levelIndex: floorNumber,
      worldId: world.id,
      titleTr: stepInWorld == 1
          ? '🎯 Bölüm $floorNumber: Isınma Rünü'
          : (stepInWorld == 4
              ? '🎯 Bölüm $floorNumber: Rünik Akış'
              : '🎯 Bölüm $floorNumber: Yüksek Güç'),
      titleEn: stepInWorld == 1
          ? '🎯 Floor $floorNumber: Warmup Rune'
          : (stepInWorld == 4
              ? '🎯 Floor $floorNumber: Runic Flow'
              : '🎯 Floor $floorNumber: High Power'),
      objectiveType: ObjectiveType.scoreTarget,
      maxMoves: (30 + (worldIndex % 3)).clamp(28, 35),
      targetScore: targetScore,
      rewardShards: baseReward,
    );
  }

  /// Returns a list of 10 structured levels for the given 1-based world/chapter index (1 = World 1, 2 = World 2, etc.).
  static List<AdventureLevel> getLevelsForWorld(int worldId) {
    final start = (worldId - 1) * 10 + 1;
    return List.generate(10, (i) => getLevel(start + i));
  }

  /// Backwards compatibility helper.
  static List<AdventureLevel> getLevelsForPage(int page) {
    return getLevelsForWorld(page);
  }
}
