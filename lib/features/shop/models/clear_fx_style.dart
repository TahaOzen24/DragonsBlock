import 'package:flutter/material.dart';
import '../../../core/localization/locale_manager.dart';
import '../../../core/theme/game_theme.dart';

class ClearFxStyle {
  final String id;
  final String nameTr;
  final String nameEn;
  final String descriptionTr;
  final String descriptionEn;
  final String icon;
  final int cost;
  final Color primaryColor;
  final Color secondaryColor;

  String get name => LocaleManager.instance.isTurkish ? nameTr : nameEn;
  String get description => LocaleManager.instance.isTurkish ? descriptionTr : descriptionEn;

  const ClearFxStyle({
    required this.id,
    required this.nameTr,
    required this.nameEn,
    required this.descriptionTr,
    required this.descriptionEn,
    required this.icon,
    required this.cost,
    required this.primaryColor,
    required this.secondaryColor,
  });

  static const List<ClearFxStyle> allStyles = [
    ClearFxStyle(
      id: 'neon_pulse',
      nameTr: 'Neon Nabız',
      nameEn: 'Neon Pulse',
      descriptionTr: 'Camgöbeği elektrik halkaları ve dijital kıvılcımlar saçar.',
      descriptionEn: 'Scatters cyan electric rings and digital sparks.',
      icon: '⚡',
      cost: 0, // Free / Default
      primaryColor: GameTheme.neonCyan,
      secondaryColor: Colors.blueAccent,
    ),
    ClearFxStyle(
      id: 'solar_flare',
      nameTr: 'Güneş Süpernovası',
      nameEn: 'Solar Supernova',
      descriptionTr: 'Ateş ve plazma şok dalgalarıyla tahtayı kavurur.',
      descriptionEn: 'Scorches the board with fire and plasma shockwaves.',
      icon: '🔥',
      cost: 400,
      primaryColor: GameTheme.fireOrange,
      secondaryColor: Colors.deepOrangeAccent,
    ),
    ClearFxStyle(
      id: 'blizzard_shards',
      nameTr: 'Buzul Fırtınası',
      nameEn: 'Blizzard Storm',
      descriptionTr: 'Donan kristal parçacıkları ve kar girdabı patlatır.',
      descriptionEn: 'Bursts frozen crystal shards and a snow vortex.',
      icon: '❄️',
      cost: 600,
      primaryColor: GameTheme.frostCyan,
      secondaryColor: Colors.tealAccent,
    ),
    ClearFxStyle(
      id: 'sovereign_gold',
      nameTr: '24K Hükümdar Tozu',
      nameEn: '24K Sovereign Dust',
      descriptionTr: 'Altın şarapneller ve asil kraliyet konfetisi saçar.',
      descriptionEn: 'Scatters gold shards and royal confetti.',
      icon: '👑',
      cost: 900,
      primaryColor: GameTheme.goldAccent,
      secondaryColor: Colors.amber,
    ),
  ];
}
