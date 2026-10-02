import 'package:flutter/material.dart';
import '../../../core/localization/locale_manager.dart';
import '../../../core/storage/app_prefs.dart';
import '../../../core/theme/game_theme.dart';

class Boss {
  final String id;
  final String nameTr;
  final String nameEn;
  final String titleTr;
  final String titleEn;
  final String avatar;
  final String imageAsset;
  final int maxHp;
  final String bossType;
  final int attackInterval; // Attack every N player block placements
  final String attackNameTr;
  final String attackNameEn;
  final String attackDescriptionTr;
  final String attackDescriptionEn;
  final int enragedAttackInterval;
  final String enragedAttackNameTr;
  final String enragedAttackNameEn;
  final String enragedAttackDescriptionTr;
  final String enragedAttackDescriptionEn;
  final Color themeColor;
  final int rewardShards;

  const Boss({
    required this.id,
    required this.nameTr,
    required this.nameEn,
    required this.titleTr,
    required this.titleEn,
    required this.avatar,
    required this.imageAsset,
    required this.maxHp,
    required this.bossType,
    required this.attackInterval,
    required this.attackNameTr,
    required this.attackNameEn,
    required this.attackDescriptionTr,
    required this.attackDescriptionEn,
    required this.enragedAttackInterval,
    required this.enragedAttackNameTr,
    required this.enragedAttackNameEn,
    required this.enragedAttackDescriptionTr,
    required this.enragedAttackDescriptionEn,
    required this.themeColor,
    required this.rewardShards,
  });

  String get name => LocaleManager.instance.isTurkish ? nameTr : nameEn;
  String get title => LocaleManager.instance.isTurkish ? titleTr : titleEn;
  String get attackName => LocaleManager.instance.isTurkish ? attackNameTr : attackNameEn;
  String get attackDescription => LocaleManager.instance.isTurkish ? attackDescriptionTr : attackDescriptionEn;
  String get enragedAttackName => LocaleManager.instance.isTurkish ? enragedAttackNameTr : enragedAttackNameEn;
  String get enragedAttackDescription => LocaleManager.instance.isTurkish ? enragedAttackDescriptionTr : enragedAttackDescriptionEn;

  static Future<Set<String>> getDefeatedBossIds() async {
    await AppPrefs.instance.init();
    final list = AppPrefs.instance.getStringList(AppPrefs.kDefeatedBosses) ?? [];
    return list.toSet();
  }

  static Future<void> markBossDefeated(String bossId) async {
    await AppPrefs.instance.init();
    final list = (AppPrefs.instance.getStringList(AppPrefs.kDefeatedBosses) ?? []).toSet();
    list.add(bossId);
    await AppPrefs.instance.setStringList(AppPrefs.kDefeatedBosses, list.toList());
  }

  static bool isBossUnlocked(Boss boss, Set<String> defeatedIds) {
    final index = bosses.indexWhere((b) => b.id == boss.id);
    if (index <= 0) return true; // First boss always unlocked
    final prevBoss = bosses[index - 1];
    return defeatedIds.contains(prevBoss.id);
  }

  static List<Boss> get bosses => const [
        Boss(
          id: 'ignis_dragon',
          nameTr: 'Ignis',
          nameEn: 'Ignis',
          titleTr: 'Kavrulmuş Ejderha',
          titleEn: 'The Scorched Dragon',
          avatar: '🐉',
          imageAsset: 'assets/images/boss_pyro_dragon.jpg',
          maxHp: 2800,
          bossType: 'fire',
          attackInterval: 5,
          attackNameTr: 'Magma Tükürüğü',
          attackNameEn: 'Magma Spit',
          attackDescriptionTr: 'Rastgele 2 hücreyi erimiş magmayla yakar!',
          attackDescriptionEn: 'Burns 2 random cells with molten magma!',
          enragedAttackInterval: 4,
          enragedAttackNameTr: 'Piroklastik Cehennem Ateşi',
          enragedAttackNameEn: 'Pyroclastic Hellfire',
          enragedAttackDescriptionTr: '3 hücreyi tutuşturur ve tahta kenarlarını lavaya çevirir!',
          enragedAttackDescriptionEn: 'Ignites 3 cells and turns board borders into lava!',
          themeColor: GameTheme.fireOrange,
          rewardShards: 400,
        ),
        Boss(
          id: 'glacior_giant',
          nameTr: 'Glacius',
          nameEn: 'Glacius',
          titleTr: 'Buzul Titanı',
          titleEn: 'The Frost Titan',
          avatar: '🗿',
          imageAsset: 'assets/images/boss_frost_golem.jpg',
          maxHp: 3800,
          bossType: 'frost',
          attackInterval: 5,
          attackNameTr: 'Buz Nefesi',
          attackNameEn: 'Frost Breath',
          attackDescriptionTr: 'Hücreleri sıfırın altı buz bloklarına dondurur!',
          attackDescriptionEn: 'Freezes cells into subzero ice blocks!',
          enragedAttackInterval: 4,
          enragedAttackNameTr: 'Kar Fırtınası Çığ',
          enragedAttackNameEn: 'Blizzard Avalanche',
          enragedAttackDescriptionTr: 'Rastgele 3 hücreyi kalıcı donmuş toprakla kilitler!',
          enragedAttackDescriptionEn: 'Locks 3 random cells under permanent permafrost!',
          themeColor: GameTheme.frostCyan,
          rewardShards: 600,
        ),
        Boss(
          id: 'voltur_lord',
          nameTr: 'Voltur',
          nameEn: 'Voltur',
          titleTr: 'Yıldırım Yılanı',
          titleEn: 'The Lightning Serpent',
          avatar: '⚡',
          imageAsset: 'assets/images/boss_storm_serpent.jpg',
          maxHp: 4800,
          bossType: 'lightning',
          attackInterval: 5,
          attackNameTr: 'Gök Gürültüsü Fırtınası',
          attackNameEn: 'Thunderstorm',
          attackDescriptionTr: 'Rastgele güçlendirme enerjisini şoklar ve devre dışı bırakır!',
          attackDescriptionEn: 'Shocks and disables random power-up energy!',
          enragedAttackInterval: 4,
          enragedAttackNameTr: 'Mega-Volt Süper Şarj',
          enragedAttackNameEn: 'Mega-Volt Supercharge',
          enragedAttackDescriptionTr: 'Satır ve sütunlardan oluşan bir şok çizgisi çeker!',
          enragedAttackDescriptionEn: 'Strikes shock waves across rows and columns!',
          themeColor: GameTheme.lightningYellow,
          rewardShards: 800,
        ),
        Boss(
          id: 'void_queen',
          nameTr: 'Umbra',
          nameEn: 'Umbra',
          titleTr: 'Hiçlik Hükümdarı',
          titleEn: 'The Void Archon',
          avatar: '🔮',
          imageAsset: 'assets/images/boss_void_reaper.jpg',
          maxHp: 5800,
          bossType: 'void',
          attackInterval: 5,
          attackNameTr: 'Boyutsal Yarık',
          attackNameEn: 'Dimensional Rift',
          attackDescriptionTr: 'Izgaranın bir bölümünü yutar!',
          attackDescriptionEn: 'Devours a section of your grid!',
          enragedAttackInterval: 4,
          enragedAttackNameTr: 'Olay Ufku Çöküşü',
          enragedAttackNameEn: 'Event Horizon Collapse',
          enragedAttackDescriptionTr: '2x2 ızgara çekirdeğini karanlık tekilliğe yutar!',
          enragedAttackDescriptionEn: 'Swallows a 2x2 grid core into dark singularity!',
          themeColor: GameTheme.voidPurple,
          rewardShards: 1100,
        ),
        Boss(
          id: 'sylva_golem',
          nameTr: 'Sylva',
          nameEn: 'Sylva',
          titleTr: 'Kadim Zümrüt Titanı',
          titleEn: 'The Ancient Emerald Titan',
          avatar: '🍃',
          imageAsset: 'assets/images/boss_frost_golem.jpg',
          maxHp: 6800,
          bossType: 'emerald',
          attackInterval: 5,
          attackNameTr: 'Sarmaşık Tuzağı',
          attackNameEn: 'Vine Entangle',
          attackDescriptionTr: 'Rastgele 2 hücreyi kadim sarmaşıklarla bağlar!',
          attackDescriptionEn: 'Seals 2 random cells with ancient vines!',
          enragedAttackInterval: 4,
          enragedAttackNameTr: 'Orman Gazabı',
          enragedAttackNameEn: 'Wrath of the Forest',
          enragedAttackDescriptionTr: '3 hücreyi zehirli rünik taşlarla donatır!',
          enragedAttackDescriptionEn: 'Enroots 3 cells with thorny runic stones!',
          themeColor: Color(0xFF69F0AE),
          rewardShards: 1400,
        ),
        Boss(
          id: 'solaria_queen',
          nameTr: 'Aureus',
          nameEn: 'Aureus',
          titleTr: 'Güneş Hükümdarı',
          titleEn: 'The Celestial Sovereign',
          avatar: '👑',
          imageAsset: 'assets/images/victory_crest.jpg',
          maxHp: 7800,
          bossType: 'gold',
          attackInterval: 5,
          attackNameTr: 'Güneş Işınımı',
          attackNameEn: 'Solar Radiance',
          attackDescriptionTr: 'Hücreleri 24K kutsal ışıkla mühürler!',
          attackDescriptionEn: 'Seals cells with 24K celestial light!',
          enragedAttackInterval: 4,
          enragedAttackNameTr: 'Kutsal Süpernova',
          enragedAttackNameEn: 'Holy Supernova',
          enragedAttackDescriptionTr: 'Güneş aleviyle 3 hücreyi parlatır!',
          enragedAttackDescriptionEn: 'Ignites 3 cells with celestial solar fire!',
          themeColor: GameTheme.goldAccent,
          rewardShards: 1800,
        ),
      ];

  /// Procedurally generates a scaled Boss battle for any dungeon floor.
  static Boss generateForFloor(int floorNumber) {
    final worldIndex = (floorNumber - 1) ~/ 10;
    final cycle = worldIndex % bosses.length;
    final baseBoss = bosses[cycle.clamp(0, bosses.length - 1)];
    final depthMultiplier = (floorNumber / 20.0).clamp(1.0, 8.0);

    final scaledHp = (baseBoss.maxHp * (0.85 + depthMultiplier * 0.15)).toInt();
    final scaledReward = (baseBoss.rewardShards * (1.0 + depthMultiplier * 0.25)).toInt();

    final titlesTr = [
      'Kat $floorNumber Muhafızı',
      'Derinlik $floorNumber Lordu',
      'Uçurum $floorNumber Hükümdarı',
      'Kadim $floorNumber Hakimi',
    ];
    final titlesEn = [
      'Guardian of Floor $floorNumber',
      'Lord of Depth $floorNumber',
      'Ruler of the Abyss $floorNumber',
      'Ancient Judge of Floor $floorNumber',
    ];
    final titleIndex = (floorNumber ~/ 10) % titlesTr.length;
    final chosenTitleTr = titlesTr[titleIndex];
    final chosenTitleEn = titlesEn[titleIndex];

    return Boss(
      id: 'procedural_boss_floor_$floorNumber',
      nameTr: '${baseBoss.nameTr} [Bölüm $floorNumber]',
      nameEn: '${baseBoss.nameEn} [Floor $floorNumber]',
      titleTr: chosenTitleTr,
      titleEn: chosenTitleEn,
      avatar: baseBoss.avatar,
      imageAsset: baseBoss.imageAsset,
      maxHp: scaledHp,
      bossType: baseBoss.bossType,
      attackInterval: baseBoss.attackInterval,
      attackNameTr: baseBoss.attackNameTr,
      attackNameEn: baseBoss.attackNameEn,
      attackDescriptionTr: baseBoss.attackDescriptionTr,
      attackDescriptionEn: baseBoss.attackDescriptionEn,
      enragedAttackInterval: baseBoss.enragedAttackInterval,
      enragedAttackNameTr: baseBoss.enragedAttackNameTr,
      enragedAttackNameEn: baseBoss.enragedAttackNameEn,
      enragedAttackDescriptionTr: baseBoss.enragedAttackDescriptionTr,
      enragedAttackDescriptionEn: baseBoss.enragedAttackDescriptionEn,
      themeColor: baseBoss.themeColor,
      rewardShards: scaledReward,
    );
  }
}
