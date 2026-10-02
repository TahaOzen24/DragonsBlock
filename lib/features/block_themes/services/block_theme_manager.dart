import 'package:flutter/material.dart';
import '../../../core/storage/app_prefs.dart';
import '../../../core/utils/app_logger.dart';
import '../../dragon/services/dragon_manager.dart';
import '../../game/models/block_skin_style.dart';
import '../../quests/services/quest_manager.dart';
import '../../shop/services/shop_manager.dart';
import '../models/block_theme_model.dart';

/// Block & Theme Manager — palette, material style, unlocks.
class BlockThemeManager extends ChangeNotifier {
  static final BlockThemeManager instance = BlockThemeManager._();
  BlockThemeManager._();

  String _activeThemeId = 'classic_jewel';
  BlockSkinStyle _activeStyle = BlockSkinStyle.minimalGlass;
  bool _isCustomMixEnabled = false;
  late List<Color> _customPalette;
  Set<String> _unlockedThemeIds = {'classic_jewel'};

  String get activeThemeId => _activeThemeId;
  BlockSkinStyle get activeStyle => _activeStyle;
  bool get isCustomMixEnabled => _isCustomMixEnabled;
  List<Color> get customPalette => List.unmodifiable(_customPalette);
  Set<String> get unlockedThemeIds => Set.unmodifiable(_unlockedThemeIds);

  BlockThemeModel get activeTheme {
    return BlockThemeModel.allThemes.firstWhere(
      (t) => t.id == _activeThemeId,
      orElse: () => BlockThemeModel.allThemes.first,
    );
  }

  List<Color> get activePalette {
    if (_isCustomMixEnabled && _customPalette.isNotEmpty) {
      return _customPalette;
    }
    return activeTheme.palette;
  }

  bool isThemeUnlocked(String themeId) => _unlockedThemeIds.contains(themeId);

  AppPrefs get _p => AppPrefs.instance;

  Future<void> init() async {
    final defaultPalette = List<Color>.from(BlockThemeModel.allThemes.first.palette);
    _customPalette = defaultPalette;

    try {
      await _p.init();
      _activeThemeId = _p.getString(AppPrefs.kBlockThemeActiveId) ?? 'classic_jewel';

      final styleIdx = _p.getInt(AppPrefs.kBlockThemeStyleIdx);
      if (styleIdx != null && styleIdx >= 0 && styleIdx < BlockSkinStyle.values.length) {
        _activeStyle = BlockSkinStyle.values[styleIdx];
      } else {
        _activeStyle = activeTheme.defaultStyle;
      }

      _isCustomMixEnabled = _p.getBool(AppPrefs.kBlockThemeCustomMix) ?? false;

      final storedUnlocked = _p.getStringList(AppPrefs.kBlockThemeUnlocked);
      if (storedUnlocked != null && storedUnlocked.isNotEmpty) {
        _unlockedThemeIds = storedUnlocked.toSet();
      }
      _unlockedThemeIds.add('classic_jewel');

      final storedCustomHex = _p.getStringList(AppPrefs.kBlockThemeCustomColors);
      if (storedCustomHex != null && storedCustomHex.length == 7) {
        _customPalette = storedCustomHex.map((hex) => Color(int.parse(hex))).toList();
      }

      checkAutoProgressionUnlocks();
    } catch (e, st) {
      AppLog.error('BlockThemeManager.init', e, st);
    }
    notifyListeners();
  }

  void checkAutoProgressionUnlocks() {
    final dragonLvl = DragonManager.instance.dragonLevel;
    final completedQuests = QuestManager.instance.completedQuestCount;
    final isVip = ShopManager.instance.isVipAdFree;

    bool newlyUnlocked = false;

    for (final theme in BlockThemeModel.allThemes) {
      if (_unlockedThemeIds.contains(theme.id)) continue;

      switch (theme.unlockType) {
        case BlockThemeUnlockType.free:
          _unlockedThemeIds.add(theme.id);
          newlyUnlocked = true;
          break;
        case BlockThemeUnlockType.dragonLevel:
          if (dragonLvl >= theme.unlockRequirement) {
            _unlockedThemeIds.add(theme.id);
            newlyUnlocked = true;
          }
          break;
        case BlockThemeUnlockType.quests:
          if (completedQuests >= theme.unlockRequirement) {
            _unlockedThemeIds.add(theme.id);
            newlyUnlocked = true;
          }
          break;
        case BlockThemeUnlockType.vip:
          if (isVip) {
            _unlockedThemeIds.add(theme.id);
            newlyUnlocked = true;
          }
          break;
        case BlockThemeUnlockType.level:
          if (dragonLvl >= theme.unlockRequirement) {
            _unlockedThemeIds.add(theme.id);
            newlyUnlocked = true;
          }
          break;
        case BlockThemeUnlockType.shards:
          break;
      }
    }

    if (newlyUnlocked) {
      _saveToPrefs();
      notifyListeners();
    }
  }

  Future<void> equipTheme(String themeId) async {
    if (!isThemeUnlocked(themeId)) return;
    _activeThemeId = themeId;
    _isCustomMixEnabled = false;
    _activeStyle = activeTheme.defaultStyle;
    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> setBlockStyle(BlockSkinStyle style) async {
    _activeStyle = style;
    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> toggleCustomMix(bool enabled) async {
    _isCustomMixEnabled = enabled;
    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> setCustomSlotColor(int slotIndex, Color color) async {
    if (slotIndex < 0 || slotIndex >= _customPalette.length) return;
    final updated = List<Color>.from(_customPalette);
    updated[slotIndex] = color;
    _customPalette = updated;
    _isCustomMixEnabled = true;
    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> copyThemeToCustomPalette(BlockThemeModel theme) async {
    _customPalette = List<Color>.from(theme.palette);
    _isCustomMixEnabled = true;
    await _saveToPrefs();
    notifyListeners();
  }

  Future<bool> purchaseTheme(String themeId) async {
    final theme = BlockThemeModel.allThemes.firstWhere((t) => t.id == themeId);
    if (isThemeUnlocked(themeId)) return true;

    final spent = await ShopManager.instance.spendShards(theme.unlockRequirement);
    if (spent) {
      _unlockedThemeIds.add(themeId);
      _activeThemeId = themeId;
      _isCustomMixEnabled = false;
      _activeStyle = theme.defaultStyle;
      await _saveToPrefs();
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> _saveToPrefs() async {
    try {
      await _p.setString(AppPrefs.kBlockThemeActiveId, _activeThemeId);
      await _p.setInt(AppPrefs.kBlockThemeStyleIdx, _activeStyle.index);
      await _p.setBool(AppPrefs.kBlockThemeCustomMix, _isCustomMixEnabled);
      await _p.setStringList(AppPrefs.kBlockThemeUnlocked, _unlockedThemeIds.toList());
      final colorHexList = _customPalette.map((c) => c.toARGB32().toString()).toList();
      await _p.setStringList(AppPrefs.kBlockThemeCustomColors, colorHexList);
    } catch (e, st) {
      AppLog.error('BlockThemeManager._saveToPrefs', e, st);
    }
  }
}
