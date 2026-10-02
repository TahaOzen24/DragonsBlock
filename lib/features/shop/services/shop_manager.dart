import 'package:flutter/foundation.dart';
import '../../../core/storage/app_prefs.dart';
import '../models/board_skin.dart';
import '../models/clear_fx_style.dart';

class ShopManager extends ChangeNotifier {
  static final ShopManager instance = ShopManager._();
  ShopManager._();

  int _goldShards = 0;
  Set<String> _unlockedSkinIds = {'obsidian_cyber'};
  String _activeSkinId = 'obsidian_cyber';
  Set<String> _unlockedFxIds = {'neon_pulse'};
  String _activeFxId = 'neon_pulse';
  bool _isVipAdFree = false;

  int get goldShards => _goldShards;
  String get activeSkinId => _activeSkinId;
  String get activeFxId => _activeFxId;
  bool get isVipAdFree => _isVipAdFree;

  BoardSkin get activeSkin {
    return BoardSkin.defaultSkins.firstWhere(
      (s) => s.id == _activeSkinId,
      orElse: () => BoardSkin.defaultSkins.first,
    );
  }

  ClearFxStyle get activeFx {
    return ClearFxStyle.allStyles.firstWhere(
      (fx) => fx.id == _activeFxId,
      orElse: () => ClearFxStyle.allStyles.first,
    );
  }

  bool isSkinUnlocked(String skinId) => _unlockedSkinIds.contains(skinId);
  bool isFxUnlocked(String fxId) => _unlockedFxIds.contains(fxId);

  AppPrefs get _p => AppPrefs.instance;

  Future<void> loadFromPrefs() async {
    await _p.init();
    _goldShards = _p.getInt(AppPrefs.kGoldShards) ?? 100;
    final storedUnlocked = _p.getStringList(AppPrefs.kUnlockedSkins);
    if (storedUnlocked != null) {
      _unlockedSkinIds = storedUnlocked.toSet();
    }
    _activeSkinId = _p.getString(AppPrefs.kActiveSkin) ?? 'obsidian_cyber';

    final storedFx = _p.getStringList(AppPrefs.kUnlockedFx);
    if (storedFx != null) {
      _unlockedFxIds = storedFx.toSet();
    }
    _activeFxId = _p.getString(AppPrefs.kActiveFx) ?? 'neon_pulse';
    _isVipAdFree = _p.getBool(AppPrefs.kIsVip) ?? false;
    notifyListeners();
  }

  Future<void> addShards(int amount) async {
    await _p.init();
    _goldShards += amount;
    await _p.setInt(AppPrefs.kGoldShards, _goldShards);
    notifyListeners();
  }

  Future<bool> spendShards(int amount) async {
    await _p.init();
    if (_goldShards >= amount) {
      _goldShards -= amount;
      await _p.setInt(AppPrefs.kGoldShards, _goldShards);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> spendGold(int amount) => spendShards(amount);

  Future<bool> purchaseSkin(BoardSkin skin) async {
    if (_goldShards >= skin.priceShards && !isSkinUnlocked(skin.id)) {
      _goldShards -= skin.priceShards;
      _unlockedSkinIds.add(skin.id);
      _activeSkinId = skin.id;
      await _p.setInt(AppPrefs.kGoldShards, _goldShards);
      await _p.setStringList(AppPrefs.kUnlockedSkins, _unlockedSkinIds.toList());
      await _p.setString(AppPrefs.kActiveSkin, _activeSkinId);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> selectSkin(String skinId) async {
    if (isSkinUnlocked(skinId)) {
      _activeSkinId = skinId;
      await _p.setString(AppPrefs.kActiveSkin, _activeSkinId);
      notifyListeners();
    }
  }

  Future<bool> purchaseFx(ClearFxStyle fx) async {
    if (_goldShards >= fx.cost && !isFxUnlocked(fx.id)) {
      _goldShards -= fx.cost;
      _unlockedFxIds.add(fx.id);
      _activeFxId = fx.id;
      await _p.setInt(AppPrefs.kGoldShards, _goldShards);
      await _p.setStringList(AppPrefs.kUnlockedFx, _unlockedFxIds.toList());
      await _p.setString(AppPrefs.kActiveFx, _activeFxId);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> selectFx(String fxId) async {
    if (isFxUnlocked(fxId)) {
      _activeFxId = fxId;
      await _p.setString(AppPrefs.kActiveFx, _activeFxId);
      notifyListeners();
    }
  }

  Future<void> setVipStatus(bool value) async {
    _isVipAdFree = value;
    await _p.setBool(AppPrefs.kIsVip, _isVipAdFree);
    notifyListeners();
  }

  /// Sync VIP from IAP no-ads entitlement (and keep flags aligned).
  Future<void> syncVipFromIap(bool hasNoAds) async {
    if (hasNoAds == _isVipAdFree) return;
    await setVipStatus(hasNoAds);
  }

  String get _todayKey {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  bool get canClaimDailyAdReward {
    return (_p.getString(AppPrefs.kShopDailyAdClaimDate) ?? '') != _todayKey;
  }

  bool get canClaimWizardGrace {
    return (_p.getString(AppPrefs.kShopWizardGraceClaimDate) ?? '') != _todayKey;
  }

  bool get hasAnyShopFreeClaimAvailable => canClaimDailyAdReward || canClaimWizardGrace;

  Future<bool> claimDailyAdReward({int amount = 100}) async {
    await _p.init();
    if (!canClaimDailyAdReward) return false;
    await addShards(amount);
    await _p.setString(AppPrefs.kShopDailyAdClaimDate, _todayKey);
    notifyListeners();
    return true;
  }

  Future<bool> claimWizardGrace({int amount = 50}) async {
    await _p.init();
    if (!canClaimWizardGrace) return false;
    await addShards(amount);
    await _p.setString(AppPrefs.kShopWizardGraceClaimDate, _todayKey);
    notifyListeners();
    return true;
  }

  /// Flash deal end timestamp (ms). Creates a 24h window if missing/expired.
  Future<DateTime> ensureFlashDealDeadline() async {
    await _p.init();
    final now = DateTime.now();
    final stored = _p.getInt(AppPrefs.kShopFlashDealEndsAtMs);
    if (stored != null) {
      final end = DateTime.fromMillisecondsSinceEpoch(stored);
      if (end.isAfter(now)) return end;
    }
    final end = now.add(const Duration(hours: 24));
    await _p.setInt(AppPrefs.kShopFlashDealEndsAtMs, end.millisecondsSinceEpoch);
    return end;
  }
}
