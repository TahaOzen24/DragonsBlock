import 'package:flutter/foundation.dart';
import '../../../core/storage/app_prefs.dart';
import '../../dragon/services/dragon_manager.dart';
import '../../shop/services/shop_manager.dart';
import '../models/puzzle_stage.dart';

class PuzzleManager extends ChangeNotifier {
  static final PuzzleManager instance = PuzzleManager._();
  PuzzleManager._();

  int _highestUnlockedStage = 1;
  final Map<int, int> _starsByStage = {};

  int get highestUnlockedStage => _highestUnlockedStage;
  int get totalStars => _starsByStage.values.fold(0, (sum, s) => sum + s);

  int getStars(int stageNumber) => _starsByStage[stageNumber] ?? 0;
  bool isUnlocked(int stageNumber) => stageNumber <= _highestUnlockedStage;

  AppPrefs get _p => AppPrefs.instance;

  Future<void> loadFromPrefs() async {
    await _p.init();
    _highestUnlockedStage = _p.getInt(AppPrefs.kPuzzleUnlockedStage) ?? 1;

    for (int i = 1; i <= 30; i++) {
      final stars = _p.getInt('puzzle_stars_$i');
      if (stars != null && stars > 0) {
        _starsByStage[i] = stars;
      }
    }

    notifyListeners();
  }

  Future<void> completeStage(int stageNumber, int stars) async {
    final prevStars = getStars(stageNumber);
    if (stars > prevStars) {
      _starsByStage[stageNumber] = stars;
    }

    final stage = PuzzleStage.getStage(stageNumber);
    await ShopManager.instance.addShards(stage.rewardShards);
    DragonManager.instance.addDragonExp(stage.rewardXp);

    if (stageNumber >= _highestUnlockedStage && _highestUnlockedStage < 30) {
      _highestUnlockedStage = stageNumber + 1;
    }

    await _p.setInt(AppPrefs.kPuzzleUnlockedStage, _highestUnlockedStage);
    if (stars > prevStars) {
      await _p.setInt('puzzle_stars_$stageNumber', stars);
    }

    notifyListeners();
  }
}
