import 'package:flutter/foundation.dart';
import '../../../core/storage/app_prefs.dart';
import '../../shop/services/shop_manager.dart';
import '../models/dragon.dart';

class DragonManager extends ChangeNotifier {
  static final DragonManager instance = DragonManager._();
  DragonManager._();

  DragonEggType _activeEggType = DragonEggType.fire;
  int _dragonLevel = 1;
  int _dragonExp = 0;
  int _totalExp = 0;
  bool _hasChosenEgg = false;
  final Set<DragonEggType> _unlockedEggs = {DragonEggType.fire};
  String? _activeCosmeticId;

  DragonEggType get activeEggType => _activeEggType;
  int get dragonLevel => _dragonLevel;
  int get dragonExp => _dragonExp;
  int get totalExp => _totalExp;
  bool get hasChosenEgg => _hasChosenEgg;
  Set<DragonEggType> get unlockedEggs => Set.unmodifiable(_unlockedEggs);
  String? get activeCosmeticId => _activeCosmeticId;

  DragonDefinition get activeDragon {
    return DragonDefinition.allDragons.firstWhere(
      (d) => d.eggType == _activeEggType,
      orElse: () => DragonDefinition.allDragons.first,
    );
  }

  DragonEvolutionStage get currentStage => DragonEvolution.getStageForLevel(_dragonLevel);
  double get expProgress => DragonEvolution.expProgress(_dragonExp, _dragonLevel);
  int get expToNextLevel => DragonEvolution.expForNextLevel(_dragonLevel) - _dragonExp;
  String get currentEmoji => activeDragon.getEmojiForStage(currentStage);
  String get stageName => DragonEvolution.getStageName(currentStage);
  bool isEggUnlocked(DragonEggType eggType) => _unlockedEggs.contains(eggType);

  AppPrefs get _p => AppPrefs.instance;

  Future<void> loadFromPrefs() async {
    await _p.init();
    _hasChosenEgg = _p.getBool(AppPrefs.kDragonHasChosenEgg) ?? false;

    final eggIndex = _p.getInt(AppPrefs.kDragonActiveEgg) ?? 0;
    _activeEggType = DragonEggType.values[eggIndex.clamp(0, DragonEggType.values.length - 1)];

    _dragonLevel = _p.getInt(AppPrefs.kDragonLevel) ?? 1;
    _dragonExp = _p.getInt(AppPrefs.kDragonExp) ?? 0;
    _totalExp = _p.getInt(AppPrefs.kDragonTotalExp) ?? 0;
    _activeCosmeticId = _p.getString(AppPrefs.kDragonCosmeticId);

    final unlockedList = _p.getStringList(AppPrefs.kDragonUnlockedEggs);
    if (unlockedList != null && unlockedList.isNotEmpty) {
      _unlockedEggs.clear();
      for (var name in unlockedList) {
        final idx = int.tryParse(name);
        if (idx != null && idx < DragonEggType.values.length) {
          _unlockedEggs.add(DragonEggType.values[idx]);
        }
      }
    }

    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    await _p.init();
    await _p.setBool(AppPrefs.kDragonHasChosenEgg, _hasChosenEgg);
    await _p.setInt(AppPrefs.kDragonActiveEgg, _activeEggType.index);
    await _p.setInt(AppPrefs.kDragonLevel, _dragonLevel);
    await _p.setInt(AppPrefs.kDragonExp, _dragonExp);
    await _p.setInt(AppPrefs.kDragonTotalExp, _totalExp);
    if (_activeCosmeticId != null) {
      await _p.setString(AppPrefs.kDragonCosmeticId, _activeCosmeticId!);
    } else {
      await _p.remove(AppPrefs.kDragonCosmeticId);
    }
    await _p.setStringList(
      AppPrefs.kDragonUnlockedEggs,
      _unlockedEggs.map((e) => e.index.toString()).toList(),
    );
  }

  Future<void> awardGameExp({
    required int linesCleared,
    required int score,
    required int comboStreak,
  }) async {
    int expGain = 0;
    expGain += linesCleared * 15;
    expGain += (score / 200).toInt();
    expGain += comboStreak * 8;
    expGain = expGain.clamp(5, 200);
    await addDragonExp(expGain);
  }

  Future<void> addDragonExp(int expGain) async {
    _dragonExp += expGain;
    _totalExp += expGain;

    while (_dragonLevel < 100 && _dragonExp >= DragonEvolution.expForNextLevel(_dragonLevel)) {
      _dragonLevel++;
    }

    if (_dragonLevel >= 100) {
      _dragonExp = DragonEvolution.expForLevel(100);
    }

    await _saveToPrefs();
    notifyListeners();
  }

  Future<bool> chooseEgg(DragonEggType eggType) async {
    if (_hasChosenEgg) return false;
    _activeEggType = eggType;
    _hasChosenEgg = true;
    _unlockedEggs.add(eggType);
    await _saveToPrefs();
    notifyListeners();
    return true;
  }

  Future<void> selectEgg(DragonEggType eggType) async {
    if (!_unlockedEggs.contains(eggType)) return;
    _activeEggType = eggType;
    await _saveToPrefs();
    notifyListeners();
  }

  Future<bool> unlockEgg(DragonEggType eggType, {int cost = 500}) async {
    if (_unlockedEggs.contains(eggType)) return true;
    if (cost > 0) {
      final canSpend = await ShopManager.instance.spendShards(cost);
      if (!canSpend) return false;
    }
    _unlockedEggs.add(eggType);
    await _saveToPrefs();
    notifyListeners();
    return true;
  }

  Future<void> setCosmetic(String? cosmeticId) async {
    _activeCosmeticId = cosmeticId;
    await _saveToPrefs();
    notifyListeners();
  }

  double get passiveScoreMultiplier {
    switch (currentStage) {
      case DragonEvolutionStage.hatchling:
        return 1.0;
      case DragonEvolutionStage.drake:
        return 1.05;
      case DragonEvolutionStage.battleDragon:
        return 1.12;
      case DragonEvolutionStage.ancientDragon:
        return 1.20;
      case DragonEvolutionStage.mythicLeviathan:
        return 1.35;
    }
  }

  double get passiveComboSlowdown {
    double base = 1.0;
    if (_activeEggType == DragonEggType.ice) base += 0.15;
    switch (currentStage) {
      case DragonEvolutionStage.hatchling:
        return base;
      case DragonEvolutionStage.drake:
        return base + 0.05;
      case DragonEvolutionStage.battleDragon:
        return base + 0.10;
      case DragonEvolutionStage.ancientDragon:
        return base + 0.15;
      case DragonEvolutionStage.mythicLeviathan:
        return base + 0.25;
    }
  }

  double get passiveGoldMultiplier {
    switch (currentStage) {
      case DragonEvolutionStage.hatchling:
        return 1.0;
      case DragonEvolutionStage.drake:
        return 1.05;
      case DragonEvolutionStage.battleDragon:
        return 1.10;
      case DragonEvolutionStage.ancientDragon:
        return 1.15;
      case DragonEvolutionStage.mythicLeviathan:
        return 1.25;
    }
  }

  double get ultimateChargeMultiplier {
    double base = 1.0;
    if (_activeEggType == DragonEggType.storm) base += 0.20;
    switch (currentStage) {
      case DragonEvolutionStage.hatchling:
        return base;
      case DragonEvolutionStage.drake:
        return base + 0.05;
      case DragonEvolutionStage.battleDragon:
        return base + 0.10;
      case DragonEvolutionStage.ancientDragon:
        return base + 0.15;
      case DragonEvolutionStage.mythicLeviathan:
        return base + 0.25;
    }
  }
}
