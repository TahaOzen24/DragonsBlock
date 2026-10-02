import 'package:flutter/material.dart';
import '../../../core/localization/locale_manager.dart';
import '../../../../core/theme/game_theme.dart';

class Achievement {
  final String id;
  final String titleTr;
  final String titleEn;
  final String descTr;
  final String descEn;
  final String icon;
  final int targetValue;
  final int rewardShards;
  final Color themeColor;

  int currentValue;
  bool isClaimed;

  Achievement({
    required this.id,
    required this.titleTr,
    required this.titleEn,
    required this.descTr,
    required this.descEn,
    required this.icon,
    required this.targetValue,
    required this.rewardShards,
    this.themeColor = GameTheme.neonCyan,
    this.currentValue = 0,
    this.isClaimed = false,
  });

  bool get isCompleted => currentValue >= targetValue;
  double get progressRatio => (currentValue / targetValue).clamp(0.0, 1.0);

  String getTitle(bool _) => LocaleManager.instance.isTurkish ? titleTr : titleEn;
  String getDesc(bool _) => LocaleManager.instance.isTurkish ? descTr : descEn;
}
