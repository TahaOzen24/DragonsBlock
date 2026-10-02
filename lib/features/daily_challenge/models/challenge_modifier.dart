import 'package:flutter/material.dart';
import '../../../core/localization/locale_manager.dart';
import '../../../core/theme/game_theme.dart';

class ChallengeModifier {
  final String id;
  final String titleTr;
  final String titleEn;
  final String subtitleTr;
  final String subtitleEn;
  final String icon;
  final Color themeColor;
  final double scoreMultiplier;
  final double energyMultiplier;
  final int bonusShardPerLine;

  const ChallengeModifier({
    required this.id,
    required this.titleTr,
    required this.titleEn,
    required this.subtitleTr,
    required this.subtitleEn,
    required this.icon,
    required this.themeColor,
    this.scoreMultiplier = 1.0,
    this.energyMultiplier = 1.0,
    this.bonusShardPerLine = 0,
  });

  String get title => LocaleManager.instance.isTurkish ? titleTr : titleEn;
  String get subtitle =>
      LocaleManager.instance.isTurkish ? subtitleTr : subtitleEn;

  static const List<ChallengeModifier> pool = [
    ChallengeModifier(
      id: 'magma_rush',
      titleTr: 'Magma Hücumu',
      titleEn: 'Magma Rush',
      subtitleTr: 'Ateşli kombolar skoru +%100 artırır!',
      subtitleEn: 'Blazing combos scale score by +100%!',
      icon: '🔥',
      themeColor: GameTheme.fireOrange,
      scoreMultiplier: 2.0,
    ),
    ChallengeModifier(
      id: 'hyper_charge',
      titleTr: 'Hiperşarj Protokolü',
      titleEn: 'Hypercharge Protocol',
      subtitleTr: 'Enerji üretimi iki katına çıkar! Durmaksızın Balyoz ve Yenileme kullan.',
      subtitleEn: 'Energy generation doubled! Unleash non-stop Hammers & Rerolls.',
      icon: '⚡',
      themeColor: GameTheme.lightningYellow,
      energyMultiplier: 2.0,
      scoreMultiplier: 1.3,
    ),
    ChallengeModifier(
      id: 'midas_fever',
      titleTr: 'Midas Ateşi',
      titleEn: 'Midas Fever',
      subtitleTr: 'Her hat temizliği +150 bonus kristal kazandırır!',
      subtitleEn: 'Every line clear drops +150 bonus crystals!',
      icon: '🪙',
      themeColor: GameTheme.goldAccent,
      bonusShardPerLine: 150,
      scoreMultiplier: 1.5,
    ),
    ChallengeModifier(
      id: 'glacial_surge',
      titleTr: 'Buzul Dalgası',
      titleEn: 'Glacial Surge',
      subtitleTr: 'Buz gibi sakin hamlelerle +%60 ekstra skor bonusu!',
      subtitleEn: 'Glacial focus awards +60% score multiplier!',
      icon: '❄️',
      themeColor: GameTheme.neonCyan,
      scoreMultiplier: 1.6,
    ),
    ChallengeModifier(
      id: 'void_anomaly',
      titleTr: 'Hiçlik Anomalisi',
      titleEn: 'Void Anomaly',
      subtitleTr: 'Derin odaklanma ve yüksek risk! +%80 kombo skoru.',
      subtitleEn: 'Deep focus with high risk! +80% combo score bonus.',
      icon: '🔮',
      themeColor: GameTheme.voidPurple,
      scoreMultiplier: 1.8,
    ),
  ];

  static ChallengeModifier getTodayModifier() {
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    return pool[dayOfYear % pool.length];
  }
}
