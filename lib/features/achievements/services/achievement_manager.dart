import 'package:flutter/foundation.dart';
import '../../../../core/storage/app_prefs.dart';
import '../../../../core/theme/game_theme.dart';
import '../../shop/services/shop_manager.dart';
import '../models/achievement.dart';

class AchievementManager extends ChangeNotifier {
  static final AchievementManager instance = AchievementManager._();
  AchievementManager._();

  final List<Achievement> achievements = [
    Achievement(
      id: 'first_combo_3',
      titleTr: 'İlk Kıvılcım',
      titleEn: 'First Spark',
      descTr: '3x veya daha yüksek Kombo serisi yap',
      descEn: 'Achieve a 3x or higher combo streak',
      icon: '⚡',
      targetValue: 3,
      rewardShards: 150,
      themeColor: GameTheme.lightningYellow,
    ),
    Achievement(
      id: 'mega_blast_3_lines',
      titleTr: 'Cehennem Patlaması',
      titleEn: 'Infernal Cleave',
      descTr: 'Tek hamlede 3 veya daha fazla satır temizle',
      descEn: 'Clear 3 or more lines in a single move',
      icon: '🔥',
      targetValue: 3,
      rewardShards: 200,
      themeColor: GameTheme.fireOrange,
    ),
    Achievement(
      id: 'score_5000',
      titleTr: 'Rün Çırağı',
      titleEn: 'Runic Apprentice',
      descTr: 'Herhangi bir oyunda 5.000 skoru aş',
      descEn: 'Reach 5,000 score in any game run',
      icon: '💎',
      targetValue: 5000,
      rewardShards: 250,
      themeColor: GameTheme.neonCyan,
    ),
    Achievement(
      id: 'score_10000',
      titleTr: 'Rün Efendisi',
      titleEn: 'Grand Runelord',
      descTr: 'Tek bir oyunda 10.000 skoru aş',
      descEn: 'Reach 10,000 score in a single run',
      icon: '👑',
      targetValue: 10000,
      rewardShards: 500,
      themeColor: GameTheme.goldAccent,
    ),
    Achievement(
      id: 'boss_slayer',
      titleTr: 'Ejderha Avcısı',
      titleEn: 'Dragon Slayer',
      descTr: 'Boss Seferinde en az 1 Boss mağlup et',
      descEn: 'Defeat at least 1 Boss in the Campaign',
      icon: '🐉',
      targetValue: 1,
      rewardShards: 350,
      themeColor: GameTheme.fireOrange,
    ),
    Achievement(
      id: 'zen_5000',
      titleTr: 'Zen Ustalığı',
      titleEn: 'Zen Master',
      descTr: 'Hiç can kaybetmeden 5.000 skora ulaş',
      descEn: 'Reach 5,000 score without losing any lives',
      icon: '🍃',
      targetValue: 5000,
      rewardShards: 200,
      themeColor: GameTheme.emeraldGreen,
    ),
    Achievement(
      id: 'blitz_3000',
      titleTr: 'Günün Savaşçısı',
      titleEn: 'Daily Dragon',
      descTr: 'Günün Mücadelesinde 3.000 skora ulaş',
      descEn: 'Reach 3,000 score in Daily Challenge',
      icon: '⏱️',
      targetValue: 3000,
      rewardShards: 250,
      themeColor: GameTheme.fireOrange,
    ),
    Achievement(
      id: 'total_shards_2500',
      titleTr: 'Midas Hazinesi',
      titleEn: 'Midas Hoard',
      descTr: 'Toplam 2.500 Altın Şarapnel topla',
      descEn: 'Collect a total of 2,500 Gold Shards',
      icon: '🪙',
      targetValue: 2500,
      rewardShards: 300,
      themeColor: GameTheme.lightningYellow,
    ),
    Achievement(
      id: 'hyperdrive_frenzy',
      titleTr: 'Hiper Sürücü Çılgınlığı',
      titleEn: 'Hyperdrive Overload',
      descTr: 'Hyperdrive Fever modunu 3 kez tetikle',
      descEn: 'Trigger Hyperdrive Fever mode 3 times',
      icon: '⚡',
      targetValue: 3,
      rewardShards: 300,
      themeColor: GameTheme.goldAccent,
    ),
  ];

  int get claimableCount => achievements.where((a) => a.isCompleted && !a.isClaimed).length;

  Future<void> loadAchievements() async {
    await AppPrefs.instance.init();
    for (var a in achievements) {
      a.currentValue = AppPrefs.instance.getInt('ach_${a.id}_val') ?? 0;
      a.isClaimed = AppPrefs.instance.getBool('ach_${a.id}_claimed') ?? false;
    }
    notifyListeners();
  }

  Future<void> updateProgress(String achievementId, int value, {bool isMax = false}) async {
    final ach = achievements.firstWhere((a) => a.id == achievementId, orElse: () => achievements.first);
    if (ach.id != achievementId) return;

    if (isMax) {
      if (value > ach.currentValue) {
        ach.currentValue = value;
      }
    } else {
      ach.currentValue += value;
    }

    await AppPrefs.instance.setInt('ach_${ach.id}_val', ach.currentValue);
    notifyListeners();
  }

  Future<bool> claimReward(String achievementId) async {
    final ach = achievements.firstWhere((a) => a.id == achievementId, orElse: () => achievements.first);
    if (ach.id != achievementId || !ach.isCompleted || ach.isClaimed) return false;

    ach.isClaimed = true;
    await AppPrefs.instance.setBool('ach_${ach.id}_claimed', true);

    await ShopManager.instance.addShards(ach.rewardShards);
    notifyListeners();
    return true;
  }
}
