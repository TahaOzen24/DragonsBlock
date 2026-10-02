import 'package:flutter/material.dart';
import '../../game/models/block_skin_style.dart';
import '../../../core/localization/locale_manager.dart';

/// Kilit açma gereksinimi türü
enum BlockThemeUnlockType {
  free,         // Başlangıçta açık
  level,        // Oyuncu seviyesiyle açılır
  dragonLevel,  // Ejderha seviyesiyle açılır
  quests,       // Görev tamamlama sayısıyla açılır
  shards,       // Altın parçacığı ile satın alınır
  vip,          // VIP / Özel başarım ödülü
}

class BlockThemeModel {
  final String id;
  final String nameTr;
  final String nameEn;
  final String descriptionTr;
  final String descriptionEn;
  final String icon;
  final BlockSkinStyle defaultStyle;
  final List<Color> palette;
  final BlockThemeUnlockType unlockType;
  final int unlockRequirement; // Seviye sayısı, görev sayısı veya altın ücreti
  final bool isPremium;

  String get name => LocaleManager.instance.isTurkish ? nameTr : nameEn;
  String get description => LocaleManager.instance.isTurkish ? descriptionTr : descriptionEn;

  const BlockThemeModel({
    required this.id,
    required this.nameTr,
    required this.nameEn,
    required this.descriptionTr,
    required this.descriptionEn,
    required this.icon,
    required this.defaultStyle,
    required this.palette,
    required this.unlockType,
    this.unlockRequirement = 0,
    this.isPremium = false,
  });

  String get unlockDescription {
    final isTr = LocaleManager.instance.isTurkish;
    switch (unlockType) {
      case BlockThemeUnlockType.free:
        return isTr ? 'Başlangıçta Açık' : 'Unlocked by Default';
      case BlockThemeUnlockType.level:
        return isTr ? 'Seviye $unlockRequirement Ulaş' : 'Reach Level $unlockRequirement';
      case BlockThemeUnlockType.dragonLevel:
        return isTr ? 'Ejderha Seviyesi $unlockRequirement' : 'Dragon Level $unlockRequirement';
      case BlockThemeUnlockType.quests:
        return isTr ? '$unlockRequirement Görev Tamamla' : 'Complete $unlockRequirement Quests';
      case BlockThemeUnlockType.shards:
        return '$unlockRequirement 🪙';
      case BlockThemeUnlockType.vip:
        return isTr ? '👑 VIP & Özel Ödül' : '👑 VIP Exclusive';
    }
  }

  static const List<BlockThemeModel> allThemes = [
    // 1. 💎 Klasik Safir & Yakut (Default)
    BlockThemeModel(
      id: 'classic_jewel',
      nameTr: 'Klasik Mücevher',
      nameEn: 'Classic Jewel',
      descriptionTr: 'Safir mavisi, yakut kırmızısı ve zümrüt yeşilinden oluşan Block Blast efsanesi.',
      descriptionEn: 'The iconic Block Blast spectrum of sapphire, ruby, and emerald gems.',
      icon: '💎',
      defaultStyle: BlockSkinStyle.minimalGlass,
      palette: [
        Color(0xFF2563EB), // Royal Cobalt Blue
        Color(0xFF22C55E), // Vibrant Emerald Green
        Color(0xFFF97316), // Radiant Orange
        Color(0xFFEF4444), // Crimson Ruby
        Color(0xFFA855F7), // Royal Violet
        Color(0xFF06B6D4), // Cyan Diamond
        Color(0xFFEAB308), // Amber Topaz
      ],
      unlockType: BlockThemeUnlockType.free,
    ),

    // 2. 🌸 Pastel Jelly Bahçesi
    BlockThemeModel(
      id: 'sugar_jelly',
      nameTr: 'Pastel Jel Bahçesi',
      nameEn: 'Pastel Jelly Garden',
      descriptionTr: 'Yumuşak pamuk şeker, çilek kreması ve nane ferahlığı veren tatlı palet.',
      descriptionEn: 'Soft pastel cotton candy, strawberry cream, and sweet mint tones.',
      icon: '🌸',
      defaultStyle: BlockSkinStyle.softJelly,
      palette: [
        Color(0xFFF43F5E), // Strawberry Velvet
        Color(0xFFFB923C), // Apricot Tangerine
        Color(0xFF34D399), // Mint Green
        Color(0xFF38BDF8), // Blue Raspberry
        Color(0xFFA855F7), // Soft Lavender
        Color(0xFFFBBF24), // Lemon Chiffon
        Color(0xFFEC4899), // Bubblegum Pink
      ],
      unlockType: BlockThemeUnlockType.quests,
      unlockRequirement: 5,
    ),

    // 3. ⚡ Siber Neon Matris
    BlockThemeModel(
      id: 'cyber_neon',
      nameTr: 'Siber Neon Matris',
      nameEn: 'Cyber Neon Matrix',
      descriptionTr: 'Yüksek voltajlı elektrik camgöbeği, lazer moru ve fütüristik neon parıltısı.',
      descriptionEn: 'High voltage electric cyan, laser purple, and futuristic cyber glow.',
      icon: '⚡',
      defaultStyle: BlockSkinStyle.neonEnergy,
      palette: [
        Color(0xFF06B6D4), // Cyan Laser
        Color(0xFFF43F5E), // Neon Rose
        Color(0xFF8B5CF6), // Deep Cyber Purple
        Color(0xFF10B981), // Emerald Matrix
        Color(0xFFF59E0B), // Solar Flare
        Color(0xFF3B82F6), // Pulse Blue
        Color(0xFFD946EF), // Plasma Magenta
      ],
      unlockType: BlockThemeUnlockType.shards,
      unlockRequirement: 350,
    ),

    // 4. 🌋 Magma Ejderha Pulu
    BlockThemeModel(
      id: 'dragon_magma',
      nameTr: 'Magma Ejderha Pulu',
      nameEn: 'Magma Dragon Scales',
      descriptionTr: 'Pyraxis\'in alev nefesi, volkanik magma ve altın közlerden doğan kor bloklar.',
      descriptionEn: 'Forged from Pyraxis\'s fire breath, volcanic magma, and golden ember flames.',
      icon: '🌋',
      defaultStyle: BlockSkinStyle.gemstone3D,
      palette: [
        Color(0xFFDC2626), // Magma Crimson
        Color(0xFFEA580C), // Fiery Blaze
        Color(0xFFF59E0B), // Molten Gold
        Color(0xFFB91C1C), // Deep Lava
        Color(0xFFD97706), // Topaz Flare
        Color(0xFF7C2D12), // Obsidian Ember
        Color(0xFFFF7A00), // Plasma Spark
      ],
      unlockType: BlockThemeUnlockType.dragonLevel,
      unlockRequirement: 5,
    ),

    // 5. ❄️ Glacius Kristal Buzulu
    BlockThemeModel(
      id: 'glacius_crystal',
      nameTr: 'Glacius Kristal Buzulu',
      nameEn: 'Glacius Frost Crystal',
      descriptionTr: 'Kutup yıldızları, elmas prizmalar ve safir dondurucu buz yansımaları.',
      descriptionEn: 'Polar starlight, crystalline diamond prisms, and sapphire frozen ice.',
      icon: '❄️',
      defaultStyle: BlockSkinStyle.gemstone3D,
      palette: [
        Color(0xFF0284C7), // Glacial Cobalt
        Color(0xFF38BDF8), // Polar Cyan
        Color(0xFF06B6D4), // Diamond Ice
        Color(0xFF67E8F9), // Crystalline Aqua
        Color(0xFF93C5FD), // Frost Blue
        Color(0xFF818CF8), // Aurora Indigo
        Color(0xFFE0F2FE), // Pure Ice Shimmer
      ],
      unlockType: BlockThemeUnlockType.level,
      unlockRequirement: 8,
    ),

    // 6. 🌌 Kozmik Nebula Stardust
    BlockThemeModel(
      id: 'cosmic_nebula',
      nameTr: 'Kozmik Nebula',
      nameEn: 'Cosmic Nebula',
      descriptionTr: 'Sonsuz galaktik uzay boşluğu, parıldayan süpernova ve yıldız tozu aurası.',
      descriptionEn: 'Deep space galactic vacuum, shimmering supernova, and stardust aura.',
      icon: '🌌',
      defaultStyle: BlockSkinStyle.cosmicStardust,
      palette: [
        Color(0xFF7E22CE), // Nebula Purple
        Color(0xFF9333EA), // Cosmic Violet
        Color(0xFFC026D3), // Stardust Magenta
        Color(0xFF4338CA), // Deep Abyss
        Color(0xFF0284C7), // Pulsar Cyan
        Color(0xFFE11D48), // Solar Flare
        Color(0xFFFBBF24), // Supernova Gold
      ],
      unlockType: BlockThemeUnlockType.vip,
      isPremium: true,
    ),

    // 7. 👑 Kraliyet Obsidyen & Altın
    BlockThemeModel(
      id: 'royal_obsidian',
      nameTr: 'Kraliyet Obsidyen & Altın',
      nameEn: 'Royal Obsidian & Gold',
      descriptionTr: 'Karanlık obsidyen gövde, parlak 24 ayar altın kaplama ve kraliyet mücevherleri.',
      descriptionEn: 'Deep obsidian body with 24k polished gold trims and royal gemstones.',
      icon: '👑',
      defaultStyle: BlockSkinStyle.zenCeramic,
      palette: [
        Color(0xFFD97706), // Royal Gold
        Color(0xFFF59E0B), // Radiant Amber
        Color(0xFF1E293B), // Obsidian Slate
        Color(0xFF047857), // Imperial Emerald
        Color(0xFF4338CA), // Velvet Sapphire
        Color(0xFFBE123C), // Sovereign Ruby
        Color(0xFFFDE68A), // Champagne Topaz
      ],
      unlockType: BlockThemeUnlockType.shards,
      unlockRequirement: 600,
      isPremium: true,
    ),

    // 8. 🍬 Gökkuşağı Şeker Şöleni
    BlockThemeModel(
      id: 'rainbow_carnival',
      nameTr: 'Gökkuşağı Karnavalı',
      nameEn: 'Rainbow Carnival',
      descriptionTr: 'Göz kamaştırıcı canlı gökkuşağı tayfı, karnaval şekeri ve neşeli parlaklık.',
      descriptionEn: 'Dazzling vivid rainbow spectrum, carnival candies, and joyful luster.',
      icon: '🍬',
      defaultStyle: BlockSkinStyle.minimalGlass,
      palette: [
        Color(0xFFFF0055), // Neon Red
        Color(0xFFFF7700), // Bright Tangerine
        Color(0xFFFFEE00), // Sunshine Yellow
        Color(0xFF00E575), // Lime Green
        Color(0xFF00C8FF), // Vivid Sky
        Color(0xFF9D00FF), // Electric Violet
        Color(0xFFFF00B7), // Hot Pink
      ],
      unlockType: BlockThemeUnlockType.quests,
      unlockRequirement: 12,
    ),
  ];
}
