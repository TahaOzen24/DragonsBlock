import 'package:flutter/foundation.dart';
import '../../../core/storage/app_prefs.dart';
import '../../shop/services/shop_manager.dart';

class DailyMedal {
  final String id;
  final int targetScore;
  final int rewardShards;

  const DailyMedal({
    required this.id,
    required this.targetScore,
    required this.rewardShards,
  });
}

class DailyChallengeManager extends ChangeNotifier {
  static final DailyChallengeManager instance = DailyChallengeManager._();
  DailyChallengeManager._();

  static const List<DailyMedal> medals = [
    DailyMedal(id: 'bronze', targetScore: 3000, rewardShards: 100),
    DailyMedal(id: 'silver', targetScore: 8000, rewardShards: 250),
    DailyMedal(id: 'gold', targetScore: 15000, rewardShards: 500),
    DailyMedal(id: 'diamond', targetScore: 25000, rewardShards: 1000),
  ];

  Set<String> _claimedToday = {};
  String _activeDateKey = '';

  String get _todayKey {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  AppPrefs get _p => AppPrefs.instance;

  Future<void> loadClaimedMedals() async {
    await _p.init();
    final key = _todayKey;
    if (_activeDateKey != key) {
      _activeDateKey = key;
      _claimedToday = (_p.getStringList('daily_medals_$key') ?? []).toSet();
    }
    notifyListeners();
  }

  bool isMedalClaimed(String medalId) => _claimedToday.contains(medalId);

  Future<int> claimMedalsForScore(int score) async {
    if (_activeDateKey != _todayKey) {
      await loadClaimedMedals();
    }
    int total = 0;
    bool changed = false;
    for (final medal in medals) {
      if (score >= medal.targetScore && !_claimedToday.contains(medal.id)) {
        _claimedToday.add(medal.id);
        total += medal.rewardShards;
        changed = true;
      }
    }
    if (changed) {
      await _p.setStringList('daily_medals_$_activeDateKey', _claimedToday.toList());
      if (total > 0) {
        await ShopManager.instance.addShards(total);
      }
      notifyListeners();
    }
    return total;
  }
}
