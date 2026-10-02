import '../../../core/localization/locale_manager.dart';

class Quest {
  final String id;
  final String titleTr;
  final String titleEn;
  final String descriptionTr;
  final String descriptionEn;
  final String icon;
  final int targetValue;
  final int rewardShards;
  final int rewardXp;
  int currentValue;
  bool isClaimed;

  Quest({
    required this.id,
    required this.titleTr,
    required this.titleEn,
    required this.descriptionTr,
    required this.descriptionEn,
    required this.icon,
    required this.targetValue,
    required this.rewardShards,
    this.rewardXp = 50,
    this.currentValue = 0,
    this.isClaimed = false,
  });

  String get title => LocaleManager.instance.isTurkish ? titleTr : titleEn;
  String get description =>
      LocaleManager.instance.isTurkish ? descriptionTr : descriptionEn;

  bool get isCompleted => currentValue >= targetValue;

  double get progressRatio => (currentValue / targetValue).clamp(0.0, 1.0);
}
