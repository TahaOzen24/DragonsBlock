import '../../../core/storage/app_prefs.dart';
import '../../shop/services/shop_manager.dart';
import '../models/league.dart';

/// Local weekly league chest (no online backend).
class LeagueRewardService {
  LeagueRewardService._();
  static final LeagueRewardService instance = LeagueRewardService._();

  static String weekKey([DateTime? now]) {
    final d = now ?? DateTime.now();
    // ISO-ish week: year + week-of-year (Mon-based)
    final thursday = d.add(Duration(days: 4 - (d.weekday)));
    final firstDay = DateTime(thursday.year);
    final week = ((thursday.difference(firstDay).inDays) / 7).floor() + 1;
    return '${thursday.year}-W${week.toString().padLeft(2, '0')}';
  }

  static int daysUntilWeekEnd([DateTime? now]) {
    final d = now ?? DateTime.now();
    final daysToSunday = 7 - d.weekday; // weekday: Mon=1 … Sun=7
    return daysToSunday == 0 ? 0 : daysToSunday;
  }

  bool get canClaimThisWeek {
    final claimed = AppPrefs.instance.getString(AppPrefs.kLeagueRewardWeekKey) ?? '';
    return claimed != weekKey();
  }

  Future<int?> claimWeeklyReward(int playerHighScore) async {
    await AppPrefs.instance.init();
    if (!canClaimThisWeek) return null;
    final tier = LeagueTier.fromScore(playerHighScore);
    final amount = tier.weeklyRewardShards;
    await ShopManager.instance.addShards(amount);
    await AppPrefs.instance.setString(AppPrefs.kLeagueRewardWeekKey, weekKey());
    return amount;
  }
}
