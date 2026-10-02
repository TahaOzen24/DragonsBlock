import 'package:flutter/material.dart';
import '../../../core/localization/locale_manager.dart';
import '../../../core/theme/game_theme.dart';

class BoardSkin {
  final String id;
  final String nameTr;
  final String nameEn;
  final String descriptionTr;
  final String descriptionEn;
  final int priceShards;
  final Color primaryGlow;
  final Color emptyCellColor;
  final Color gridBorderColor;
  final Color bgDarkColor;
  final String previewEmoji;

  const BoardSkin({
    required this.id,
    required this.nameTr,
    required this.nameEn,
    required this.descriptionTr,
    required this.descriptionEn,
    required this.priceShards,
    required this.primaryGlow,
    required this.emptyCellColor,
    required this.gridBorderColor,
    required this.bgDarkColor,
    required this.previewEmoji,
  });

  String get name => LocaleManager.instance.isTurkish ? nameTr : nameEn;
  String get description => LocaleManager.instance.isTurkish ? descriptionTr : descriptionEn;

  static List<BoardSkin> get defaultSkins => const [
        BoardSkin(
          id: 'obsidian_cyber',
          nameTr: 'Obsidyen Siber',
          nameEn: 'Obsidian Cyber',
          descriptionTr: 'Camgöbeği lazer vurgulu yüksek teknoloji obsidyen matris.',
          descriptionEn: 'High-tech dark obsidian matrix with cyan laser accents.',
          priceShards: 0,
          primaryGlow: GameTheme.neonCyan,
          emptyCellColor: GameTheme.gridEmptyCell,
          gridBorderColor: GameTheme.gridBorder,
          bgDarkColor: GameTheme.bgDarkest,
          previewEmoji: '💎',
        ),
        BoardSkin(
          id: 'magma_volcano',
          nameTr: 'Magma Kaldera',
          nameEn: 'Magma Caldera',
          descriptionTr: 'Yanardağ kayası ve kor çekirdekli eriyik lav.',
          descriptionEn: 'Molten volcanic rock with burning ember core.',
          priceShards: 500,
          primaryGlow: GameTheme.fireOrange,
          emptyCellColor: Color(0xFF1E0E0B),
          gridBorderColor: Color(0xFF4A1A12),
          bgDarkColor: Color(0xFF0F0604),
          previewEmoji: '🌋',
        ),
        BoardSkin(
          id: 'glacial_crystal',
          nameTr: 'Buzul Aurora',
          nameEn: 'Glacial Aurora',
          descriptionTr: 'Donmuş kristal plakalar ve aurora ışıltısı.',
          descriptionEn: 'Sub-zero crystalline ice sheets with frosted aurora glow.',
          priceShards: 750,
          primaryGlow: GameTheme.frostCyan,
          emptyCellColor: Color(0xFF0C1926),
          gridBorderColor: Color(0xFF1B3854),
          bgDarkColor: Color(0xFF060D14),
          previewEmoji: '❄️',
        ),
        BoardSkin(
          id: 'void_nebula',
          nameTr: 'Hiçlik Nebulası',
          nameEn: 'Void Nebula',
          descriptionTr: 'Mor arkane enerjiyle nabız atan kozmik boşluk.',
          descriptionEn: 'Deep cosmic void pulsing with purple arcane energy.',
          priceShards: 1000,
          primaryGlow: GameTheme.voidPurple,
          emptyCellColor: Color(0xFF170C26),
          gridBorderColor: Color(0xFF38195E),
          bgDarkColor: Color(0xFF0A0412),
          previewEmoji: '🔮',
        ),
        BoardSkin(
          id: 'golden_sovereign',
          nameTr: 'Altın Hükümdar',
          nameEn: 'Golden Sovereign',
          descriptionTr: 'Gerçek yüksek skorcular için 24 ayar electrum çerçeve.',
          descriptionEn: 'Pure 24K electrum gold frame for the true high scorer.',
          priceShards: 1500,
          primaryGlow: GameTheme.goldAccent,
          emptyCellColor: Color(0xFF241C0A),
          gridBorderColor: Color(0xFF5E4919),
          bgDarkColor: Color(0xFF0F0B03),
          previewEmoji: '👑',
        ),
      ];
}
