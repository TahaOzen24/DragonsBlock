import 'package:flutter/material.dart';
import 'block_skin_style.dart';

class ComboRealmTheme {
  final String id;
  final String title;
  final String realmBadge;
  final BlockSkinStyle blockSkinStyle;
  final Color primaryGlow;
  final Color gridBorderColor;
  final Color emptyCellColor;
  final List<Color> blockPalette;
  final Color stingerColor;
  final bool isMonochrome;
  final Color? uniformColor;

  const ComboRealmTheme({
    required this.id,
    required this.title,
    required this.realmBadge,
    required this.blockSkinStyle,
    required this.primaryGlow,
    required this.gridBorderColor,
    required this.emptyCellColor,
    required this.blockPalette,
    required this.stingerColor,
    this.isMonochrome = false,
    this.uniformColor,
  });

  // ─── 💎 1. Classic Vibrant Candy-Jewel Spectrum (Vivid, Juicy, Precious Gemstones) ──
  static const ComboRealmTheme classicJewel = ComboRealmTheme(
    id: 'classic_jewel',
    title: '💎 KRİSTAL MÜCEVHER DİYARI',
    realmBadge: '💎',
    blockSkinStyle: BlockSkinStyle.minimalGlass,
    primaryGlow: Color(0xFF00E5FF),
    gridBorderColor: Color(0xFF1E293B),
    emptyCellColor: Color(0xFF0F172A),
    blockPalette: [
      Color(0xFF2563EB), // Royal Cobalt Blue (from reference image)
      Color(0xFF22C55E), // Vibrant Emerald Green (from reference image)
      Color(0xFFF97316), // Radiant Orange
      Color(0xFFEF4444), // Crimson Ruby
      Color(0xFFA855F7), // Royal Violet
      Color(0xFF06B6D4), // Cyan Diamond
      Color(0xFFEAB308), // Amber Topaz
    ],
    stingerColor: Color(0xFF00E5FF),
    isMonochrome: false,
  );

  // ─── 🌸 2. Juicy Soft Candy & Jelly (Sweet Pastel Bliss) ────────────────────
  static const ComboRealmTheme sugarJelly = ComboRealmTheme(
    id: 'sugar_jelly',
    title: '🌸 PASTEL ŞEKER BAHÇESİ',
    realmBadge: '🌸',
    blockSkinStyle: BlockSkinStyle.minimalGlass,
    primaryGlow: Color(0xFFF472B6),
    gridBorderColor: Color(0xFF2D1B2D),
    emptyCellColor: Color(0xFF150B16),
    blockPalette: [
      Color(0xFFF43F5E), // Strawberry Velvet
      Color(0xFFFB923C), // Apricot Tangerine
      Color(0xFF34D399), // Mint Green
      Color(0xFF38BDF8), // Blue Raspberry
      Color(0xFFA855F7), // Soft Lavender
      Color(0xFFFBBF24), // Lemon Chiffon
    ],
    stingerColor: Color(0xFFF472B6),
    isMonochrome: false,
  );

  // ─── ⚡ 3. Cyber Neon Matrix (Smooth Cyan & Purple Cyber Glow) ───────────────
  static const ComboRealmTheme cyberNeon = ComboRealmTheme(
    id: 'cyber_neon',
    title: '⚡ SİBER ENERJİ MATRİSİ',
    realmBadge: '⚡',
    blockSkinStyle: BlockSkinStyle.minimalGlass,
    primaryGlow: Color(0xFF06B6D4),
    gridBorderColor: Color(0xFF0C2438),
    emptyCellColor: Color(0xFF06111C),
    blockPalette: [
      Color(0xFF06B6D4), // Cyan Laser
      Color(0xFFF43F5E), // Neon Rose
      Color(0xFF8B5CF6), // Deep Cyber Purple
      Color(0xFF10B981), // Emerald Matrix
      Color(0xFFF59E0B), // Solar Flare
    ],
    stingerColor: Color(0xFF06B6D4),
    isMonochrome: false,
  );

  // ─── 🌌 4. Cosmic Stardust Singularity (Deep Space Nebula) ──────────────────
  static const ComboRealmTheme cosmicStardust = ComboRealmTheme(
    id: 'cosmic_stardust',
    title: '🌌 KOZMİK NEBULA DİYARI',
    realmBadge: '🌌',
    blockSkinStyle: BlockSkinStyle.minimalGlass,
    primaryGlow: Color(0xFFA855F7),
    gridBorderColor: Color(0xFF1F1133),
    emptyCellColor: Color(0xFF0D0618),
    blockPalette: [
      Color(0xFFA855F7), // Nebula Violet
      Color(0xFF38BDF8), // Astral Cyan
      Color(0xFFF472B6), // Starlight Pink
      Color(0xFFFBBF24), // Solar Amber
      Color(0xFF34D399), // Auroral Emerald
    ],
    stingerColor: Color(0xFFA855F7),
    isMonochrome: false,
  );

  // ─── 🟡 5. Warm Amber & Pure Gold (Soothing Golden Glow) ────────────────────
  static const ComboRealmTheme pureGold = ComboRealmTheme(
    id: 'pure_gold',
    title: '🟡 BAL & SAF ALTIN DİYARI',
    realmBadge: '🟡',
    blockSkinStyle: BlockSkinStyle.minimalGlass,
    primaryGlow: Color(0xFFF59E0B),
    gridBorderColor: Color(0xFF33230A),
    emptyCellColor: Color(0xFF1A1103),
    blockPalette: [Color(0xFFF59E0B)],
    stingerColor: Color(0xFFF59E0B),
    isMonochrome: true,
    uniformColor: Color(0xFFF59E0B),
  );

  // ─── 🪵 6. Nordic Polished Wood & Brass Studs ──────────────────────────────
  static const ComboRealmTheme nordicWood = ComboRealmTheme(
    id: 'nordic_wood',
    title: '🪵 İSKANDİNAV AHŞAP',
    realmBadge: '🪵',
    blockSkinStyle: BlockSkinStyle.minimalGlass,
    primaryGlow: Color(0xFFD97706),
    gridBorderColor: Color(0xFF2C1908),
    emptyCellColor: Color(0xFF140B03),
    blockPalette: [
      Color(0xFFD97706), // Amber Teak
      Color(0xFFB45309), // Warm Walnut
      Color(0xFF92400E), // Deep Mahogany
      Color(0xFFCD853F), // Peru Birch
      Color(0xFFDEB887), // Natural Maple
      Color(0xFFB8860B), // Golden Oak
    ],
    stingerColor: Color(0xFFD97706),
    isMonochrome: false,
  );

  // ─── 🏺 7. Zen Matte Ceramic & Kintsugi Gold ───────────────────────────────
  static const ComboRealmTheme zenCeramic = ComboRealmTheme(
    id: 'zen_ceramic',
    title: '🏺 ZEN MAT SERAMİK & KİNTSUGİ',
    realmBadge: '🏺',
    blockSkinStyle: BlockSkinStyle.minimalGlass,
    primaryGlow: Color(0xFF94A3B8),
    gridBorderColor: Color(0xFF1E293B),
    emptyCellColor: Color(0xFF0F172A),
    blockPalette: [
      Color(0xFF80CBC4), // Celadon Jade
      Color(0xFFFFAB91), // Terracotta Glaze
      Color(0xFFC5E1A5), // Matcha Silk
      Color(0xFF90CAF9), // Indigo Mist
      Color(0xFFBCAAA4), // Clay Earth
      Color(0xFFFFF59D), // Primrose Glaze
    ],
    stingerColor: Color(0xFF94A3B8),
    isMonochrome: false,
  );

  // ─── 🔴 8. Warm Velvet Crimson Ruby ─────────────────────────────────────────
  static const ComboRealmTheme pureRuby = ComboRealmTheme(
    id: 'pure_ruby',
    title: '🔴 KADİFE YAKUT ALEVİ',
    realmBadge: '🔴',
    blockSkinStyle: BlockSkinStyle.minimalGlass,
    primaryGlow: Color(0xFFEF4444),
    gridBorderColor: Color(0xFF330E14),
    emptyCellColor: Color(0xFF1A0509),
    blockPalette: [Color(0xFFEF4444)],
    stingerColor: Color(0xFFEF4444),
    isMonochrome: true,
    uniformColor: Color(0xFFEF4444),
  );

  // Theme Aliases & Collections
  static const ComboRealmTheme cozyWool = classicJewel;
  static const ComboRealmTheme defaultSanctuary = classicJewel;
  static const ComboRealmTheme goldenZenith = pureGold;
  static const ComboRealmTheme rubyFlame = pureRuby;
  static const ComboRealmTheme sakuraPink = sugarJelly;
  static const ComboRealmTheme warmWood = nordicWood;
  static const ComboRealmTheme goldSurge = pureGold;
  static const ComboRealmTheme rubySurge = pureRuby;
  static const ComboRealmTheme sakuraSurge = sugarJelly;
  static const ComboRealmTheme woodSurge = nordicWood;

  static const List<ComboRealmTheme> worldThemes = [
    classicJewel,
    sugarJelly,
    cyberNeon,
    pureGold,
    cosmicStardust,
    nordicWood,
    zenCeramic,
    pureRuby,
  ];

  static const List<ComboRealmTheme> comboThemes = worldThemes;
  static const List<ComboRealmTheme> surgeThemes = worldThemes;

  /// Dynamic gameplay & score milestone theme mapper
  static ComboRealmTheme getThemeForScore(int score) {
    if (score < 4000) return classicJewel;
    if (score < 10000) return sugarJelly;
    if (score < 18000) return cyberNeon;
    if (score < 28000) return pureGold;
    if (score < 42000) return cosmicStardust;
    if (score < 60000) return nordicWood;
    return zenCeramic;
  }
}
