import 'package:flutter/material.dart';
import '../../../core/localization/locale_manager.dart';
import '../../../core/theme/game_theme.dart';

class PlayerAvatar {
  final String id;
  final String nameTr;
  final String nameEn;
  final String emoji;
  final Color themeColor;

  String get name => LocaleManager.instance.isTurkish ? nameTr : nameEn;

  const PlayerAvatar({
    required this.id,
    required this.nameTr,
    required this.nameEn,
    required this.emoji,
    required this.themeColor,
  });

  static const List<PlayerAvatar> defaultAvatars = [
    PlayerAvatar(id: 'knight', nameTr: 'Ateş Şövalyesi', nameEn: 'Fire Knight', emoji: '⚔️', themeColor: GameTheme.fireOrange),
    PlayerAvatar(id: 'weaver', nameTr: 'Buzul Büyücüsü', nameEn: 'Frost Weaver', emoji: '❄️', themeColor: GameTheme.frostCyan),
    PlayerAvatar(id: 'shaman', nameTr: 'Yıldırım Şamanı', nameEn: 'Lightning Shaman', emoji: '⚡', themeColor: GameTheme.lightningYellow),
    PlayerAvatar(id: 'sovereign', nameTr: 'Hiçlik Hükümdarı', nameEn: 'Void Sovereign', emoji: '🔮', themeColor: GameTheme.voidPurple),
    PlayerAvatar(id: 'archon', nameTr: 'Altın Usta', nameEn: 'Gold Master', emoji: '👑', themeColor: GameTheme.goldAccent),
    PlayerAvatar(id: 'wanderer', nameTr: 'Zen Gezgini', nameEn: 'Zen Wanderer', emoji: '🍃', themeColor: GameTheme.emeraldGreen),
  ];
}

class PlayerFrame {
  final String id;
  final String nameTr;
  final String nameEn;
  final Color frameColor;
  final double borderWidth;
  final bool hasGlow;

  String get name => LocaleManager.instance.isTurkish ? nameTr : nameEn;

  const PlayerFrame({
    required this.id,
    required this.nameTr,
    required this.nameEn,
    required this.frameColor,
    this.borderWidth = 2.0,
    this.hasGlow = false,
  });

  static const List<PlayerFrame> defaultFrames = [
    PlayerFrame(id: 'classic', nameTr: 'Klasik Rün', nameEn: 'Classic Rune', frameColor: GameTheme.gridBorder, borderWidth: 1.5),
    PlayerFrame(id: 'neon', nameTr: 'Neon Nabız', nameEn: 'Neon Pulse', frameColor: GameTheme.neonCyan, borderWidth: 2.2, hasGlow: true),
    PlayerFrame(id: 'magma', nameTr: 'Magma Kor', nameEn: 'Magma Ember', frameColor: GameTheme.fireOrange, borderWidth: 2.5, hasGlow: true),
    PlayerFrame(id: 'gold', nameTr: '24K Altın Hale', nameEn: '24K Golden Halo', frameColor: GameTheme.goldAccent, borderWidth: 3.0, hasGlow: true),
  ];
}
