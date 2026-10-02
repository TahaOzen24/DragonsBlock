import 'dart:math';
import '../../../core/storage/app_prefs.dart';
import '../../shop/services/shop_manager.dart';

class IdleVaultManager {
  static final IdleVaultManager instance = IdleVaultManager._();
  IdleVaultManager._();

  static const int shardsPerHour = 50;
  static const int maxHours = 8;
  static const int maxShards = shardsPerHour * maxHours;

  DateTime? _lastClaimedTime;

  DateTime get lastClaimedTime => _lastClaimedTime ?? DateTime.now();

  AppPrefs get _p => AppPrefs.instance;

  Future<void> init() async {
    await _p.init();
    final timestamp = _p.getInt(AppPrefs.kIdleVaultLastClaim);
    if (timestamp != null) {
      _lastClaimedTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    } else {
      _lastClaimedTime = DateTime.now().subtract(const Duration(hours: 3));
      await _p.setInt(AppPrefs.kIdleVaultLastClaim, _lastClaimedTime!.millisecondsSinceEpoch);
    }
  }

  int get pendingShards {
    final now = DateTime.now();
    final diffMinutes = now.difference(lastClaimedTime).inMinutes;
    if (diffMinutes < 5) return 0;
    final hours = diffMinutes / 60.0;
    final cappedHours = min(maxHours.toDouble(), hours);
    return (cappedHours * shardsPerHour).round();
  }

  double get vaultFillPercentage => (pendingShards / maxShards).clamp(0.0, 1.0);

  String get accumulatedTimeFormatted {
    final now = DateTime.now();
    final diffMinutes = min(maxHours * 60, now.difference(lastClaimedTime).inMinutes);
    final h = diffMinutes ~/ 60;
    final m = diffMinutes % 60;
    if (h > 0) return '$h sa $m dk';
    return '$m dk';
  }

  Future<int> claimVault() async {
    final amount = pendingShards;
    if (amount <= 0) return 0;
    _lastClaimedTime = DateTime.now();
    await _p.setInt(AppPrefs.kIdleVaultLastClaim, _lastClaimedTime!.millisecondsSinceEpoch);
    await ShopManager.instance.addShards(amount);
    return amount;
  }

  Future<int> claimAndDoubleVault() async {
    final amount = pendingShards * 2;
    if (amount <= 0) return 0;
    _lastClaimedTime = DateTime.now();
    await _p.setInt(AppPrefs.kIdleVaultLastClaim, _lastClaimedTime!.millisecondsSinceEpoch);
    await ShopManager.instance.addShards(amount);
    return amount;
  }
}
