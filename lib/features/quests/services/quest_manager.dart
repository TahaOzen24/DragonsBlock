import 'package:flutter/foundation.dart';
import '../../../core/storage/app_prefs.dart';
import '../../dragon/services/dragon_manager.dart';
import '../../shop/services/shop_manager.dart';
import '../models/quest.dart';

class QuestManager extends ChangeNotifier {
  static final QuestManager instance = QuestManager._();
  QuestManager._();

  List<Quest> quests = [
    Quest(
      id: 'multi_clear_master',
      titleTr: 'Çoklu Hat Ustası',
      titleEn: 'Multi-Line Master',
      descriptionTr: 'Koşuların boyunca 5 adet çoklu hat temizliği yap.',
      descriptionEn: 'Perform 5 multi-line clears across your runs.',
      icon: '💥',
      targetValue: 5,
      rewardShards: 150,
      rewardXp: 60,
    ),
    Quest(
      id: 'block_placer',
      titleTr: 'Usta İnşaatçı',
      titleEn: 'Master Builder',
      descriptionTr: 'Toplam 30 adet blok yerleştir.',
      descriptionEn: 'Place 30 total blocks.',
      icon: '🧱',
      targetValue: 30,
      rewardShards: 200,
      rewardXp: 50,
    ),
    Quest(
      id: 'combo_virtuoso',
      titleTr: 'Kombo Virtüözü',
      titleEn: 'Combo Virtuoso',
      descriptionTr: 'Herhangi bir koşuda 3x kombo serisi yakala.',
      descriptionEn: 'Reach a 3x Combo streak in any run.',
      icon: '✨',
      targetValue: 3,
      rewardShards: 250,
      rewardXp: 75,
    ),
    Quest(
      id: 'line_crusher',
      titleTr: 'Matris Temizleyici',
      titleEn: 'Matrix Cleaner',
      descriptionTr: 'Toplam 20 hat temizle.',
      descriptionEn: 'Clear 20 total lines.',
      icon: '🧱',
      targetValue: 20,
      rewardShards: 300,
      rewardXp: 80,
    ),
    Quest(
      id: 'high_score_hunter',
      titleTr: 'Üstün Skorer',
      titleEn: 'Ascended Scorer',
      descriptionTr: 'Tek bir koşuda 5,000 puan kazan.',
      descriptionEn: 'Score 5,000 points in a single run.',
      icon: '👑',
      targetValue: 5000,
      rewardShards: 400,
      rewardXp: 100,
    ),
    Quest(
      id: 'dragon_awakener',
      titleTr: 'Ejderha Efendisi',
      titleEn: 'Dragon Lord',
      descriptionTr: 'Ejderhanı besle veya bir Ultimate gücünü aktifleştir.',
      descriptionEn: 'Feed your dragon or unleash a Dragon Ultimate power.',
      icon: '🐉',
      targetValue: 1,
      rewardShards: 350,
      rewardXp: 90,
    ),
    Quest(
      id: 'dungeon_crawler',
      titleTr: 'Zindan Fatihi',
      titleEn: 'Dungeon Conqueror',
      descriptionTr: 'Sonsuz Zindanda 2 kat başarıyla tamamla.',
      descriptionEn: 'Conquer 2 floors in the Infinite Dungeon.',
      icon: '🗝️',
      targetValue: 2,
      rewardShards: 300,
      rewardXp: 85,
    ),
    Quest(
      id: 'clan_crusher',
      titleTr: 'Baskın Savaşçısı',
      titleEn: 'Raid Warrior',
      descriptionTr: 'Dünya Bossu Ignarok\'a karşı en az 10.000 hasar ver.',
      descriptionEn: 'Deal at least 10,000 damage to World Boss Ignarok.',
      icon: '🌋',
      targetValue: 10000,
      rewardShards: 450,
      rewardXp: 120,
    ),
    Quest(
      id: 'speed_demon',
      titleTr: 'Süpernova Patlaması',
      titleEn: 'Supernova Blast',
      descriptionTr: 'Tek bir hamlede 3 veya daha fazla hat temizle.',
      descriptionEn: 'Clear 3 or more lines in a single move.',
      icon: '⚡',
      targetValue: 1,
      rewardShards: 250,
      rewardXp: 70,
    ),
    Quest(
      id: 'daily_challenger',
      titleTr: 'Günün Kahramanı',
      titleEn: 'Daily Champion',
      descriptionTr: 'Günlük Mutatörlü Meydan Okumada madalya kazan.',
      descriptionEn: 'Earn a medal in the Daily Mutator Challenge.',
      icon: '🏅',
      targetValue: 1,
      rewardShards: 300,
      rewardXp: 80,
    ),
  ];

  Future<void> loadQuests() async {
    await AppPrefs.instance.init();
    final now = DateTime.now();
    final todayKey = '${now.year}-${now.month}-${now.day}';
    final lastReset = AppPrefs.instance.getString(AppPrefs.kQuestResetDate) ?? '';
    final shouldReset = lastReset != todayKey;

    for (var quest in quests) {
      quest.currentValue = shouldReset ? 0 : (AppPrefs.instance.getInt('quest_${quest.id}_val') ?? 0);
      quest.isClaimed = shouldReset ? false : (AppPrefs.instance.getBool('quest_${quest.id}_claimed') ?? false);
    }

    if (shouldReset) {
      await AppPrefs.instance.setString(AppPrefs.kQuestResetDate, todayKey);
      for (var quest in quests) {
        await AppPrefs.instance.setInt('quest_${quest.id}_val', 0);
        await AppPrefs.instance.setBool('quest_${quest.id}_claimed', false);
      }
    }
    notifyListeners();
  }

  Future<void> reportProgress(String questId, int amount, {bool isAbsolute = false}) async {
    final quest = quests.firstWhere((q) => q.id == questId, orElse: () => quests.first);
    if (!quest.isClaimed) {
      if (isAbsolute) {
        if (amount > quest.currentValue) {
          quest.currentValue = amount;
        }
      } else {
        quest.currentValue += amount;
      }
      await AppPrefs.instance.setInt('quest_${quest.id}_val', quest.currentValue);
      notifyListeners();
    }
  }

  Future<bool> claimReward(Quest quest) async {
    if (quest.isCompleted && !quest.isClaimed) {
      quest.isClaimed = true;
      await ShopManager.instance.addShards(quest.rewardShards);
      DragonManager.instance.addDragonExp(quest.rewardXp);

      await AppPrefs.instance.setBool('quest_${quest.id}_claimed', true);
      notifyListeners();
      return true;
    }
    return false;
  }

  int get claimableCount => quests.where((q) => q.isCompleted && !q.isClaimed).length;
  int get completedQuestCount => quests.where((q) => q.isClaimed || q.isCompleted).length;
}
