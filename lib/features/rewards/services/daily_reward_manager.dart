import 'package:flutter/foundation.dart';
import '../../../core/storage/app_prefs.dart';
import '../../shop/services/shop_manager.dart';

class DailyReward {
  final int day;
  final int shards;
  final String icon;
  final String title;

  const DailyReward({
    required this.day,
    required this.shards,
    required this.icon,
    required this.title,
  });
}

class DailyRewardManager extends ChangeNotifier {
  static final DailyRewardManager instance = DailyRewardManager._();
  DailyRewardManager._();

  static const List<DailyReward> schedule = [
    DailyReward(day: 1, shards: 100, icon: '🪙', title: 'Day 1 Starter'),
    DailyReward(day: 2, shards: 150, icon: '⚡', title: 'Day 2 Surge'),
    DailyReward(day: 3, shards: 200, icon: '🔮', title: 'Day 3 Mystic'),
    DailyReward(day: 4, shards: 250, icon: '❄️', title: 'Day 4 Frost Vault'),
    DailyReward(day: 5, shards: 350, icon: '🔥', title: 'Day 5 Inferno'),
    DailyReward(day: 6, shards: 500, icon: '💎', title: 'Day 6 Royal Cache'),
    DailyReward(day: 7, shards: 1000, icon: '👑', title: 'Day 7 Grand Ascendancy'),
  ];

  int _currentDay = 1;
  bool _canClaimToday = false;

  int get currentDay => _currentDay;
  bool get canClaimToday => _canClaimToday;

  AppPrefs get _p => AppPrefs.instance;

  Future<void> checkDailyStatus() async {
    await _p.init();
    final lastClaimTimestamp = _p.getInt(AppPrefs.kLastDailyClaimTs) ?? 0;
    _currentDay = _p.getInt(AppPrefs.kDailyStreakDay) ?? 1;

    final now = DateTime.now();
    final lastClaimDate = DateTime.fromMillisecondsSinceEpoch(lastClaimTimestamp);

    final isSameDay = lastClaimTimestamp > 0 &&
        now.year == lastClaimDate.year &&
        now.month == lastClaimDate.month &&
        now.day == lastClaimDate.day;

    if (isSameDay) {
      _canClaimToday = false;
    } else {
      final diffHours = now.difference(lastClaimDate).inHours;
      if (lastClaimTimestamp > 0 && diffHours > 48) {
        _currentDay = 1;
      }
      _canClaimToday = true;
    }
    notifyListeners();
  }

  Future<bool> claimToday() async {
    if (!_canClaimToday) return false;

    final reward = schedule.firstWhere((r) => r.day == _currentDay, orElse: () => schedule.first);
    await ShopManager.instance.addShards(reward.shards);

    await _p.setInt(AppPrefs.kLastDailyClaimTs, DateTime.now().millisecondsSinceEpoch);

    if (_currentDay >= 7) {
      _currentDay = 1;
    } else {
      _currentDay++;
    }

    await _p.setInt(AppPrefs.kDailyStreakDay, _currentDay);
    _canClaimToday = false;
    notifyListeners();
    return true;
  }
}
