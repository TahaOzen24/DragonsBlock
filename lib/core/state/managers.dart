import 'package:flutter/foundation.dart';

import '../localization/locale_manager.dart';
import '../settings/settings_manager.dart';
import '../storage/app_prefs.dart';
import '../utils/app_logger.dart';
import '../../features/shop/services/shop_manager.dart';
import '../../features/quests/services/quest_manager.dart';
import '../../features/rewards/services/daily_reward_manager.dart';
import '../../features/rewards/services/idle_vault_manager.dart';
import '../../features/dragon/services/dragon_manager.dart';
import '../../features/puzzle/services/puzzle_manager.dart';
import '../../features/rewards/services/lives_manager.dart';
import '../../features/daily_challenge/services/daily_challenge_manager.dart';
import '../../features/block_themes/services/block_theme_manager.dart';
import '../iap/iap_service.dart';

/// Central registry of core feature managers.
///
/// Core pillars:
/// 1. Saf Block Puzzle
/// 2. Ejderha Evrimi (Dragon Evolution)
/// 3. Blok Stüdyosu & Temalar
/// 4. Macera Haritası (Adventure Map & Quests)
class Managers {
  Managers._();

  static final List<ChangeNotifier> _notifiers = [];
  static final List<Future<void> Function()> _loaders = [];
  static bool _registered = false;
  static Future<void>? _loadFuture;

  /// Idempotent registration. Call once at startup (e.g. in `main()`).
  static void ensureRegistered() {
    if (_registered) return;
    _registered = true;

    _register(LocaleManager.instance, LocaleManager.instance.loadLanguage);
    _register(SettingsManager.instance, SettingsManager.instance.loadSettings);
    _register(ShopManager.instance, ShopManager.instance.loadFromPrefs);
    _register(QuestManager.instance, QuestManager.instance.loadQuests);
    _register(DailyRewardManager.instance, DailyRewardManager.instance.checkDailyStatus);
    _register(null, IdleVaultManager.instance.init);
    _register(DragonManager.instance, DragonManager.instance.loadFromPrefs);
    _register(PuzzleManager.instance, PuzzleManager.instance.loadFromPrefs);
    _register(LivesManager.instance, LivesManager.instance.loadFromPrefs);
    _register(DailyChallengeManager.instance, DailyChallengeManager.instance.loadClaimedMedals);
    _register(BlockThemeManager.instance, BlockThemeManager.instance.init);
    _register(IapService.instance, IapService.instance.initialize);
  }

  static void _register(ChangeNotifier? notifier, Future<void> Function() load) {
    if (notifier != null) _notifiers.add(notifier);
    _loaders.add(load);
  }

  /// ChangeNotifiers to listen to for reactive UI updates.
  static List<ChangeNotifier> get notifiers => List.unmodifiable(_notifiers);

  /// Runs every manager's load closure in registration order.
  static Future<void> loadAll() {
    return _loadFuture ??= _loadAll();
  }

  static Future<void> _loadAll() async {
    for (final load in _loaders) {
      await load();
    }
  }

  /// Called when the application transitions to background/sleep.
  static Future<void> onAppPaused() async {
    try {
      await AppPrefs.instance.setInt(
        AppPrefs.kAppLastBackground,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e, st) {
      AppLog.error('Managers.onAppPaused', e, st);
    }
  }

  /// Called when the application returns to foreground.
  static Future<void> onAppResumed() async {
    try {
      await IdleVaultManager.instance.init();
      await LivesManager.instance.loadFromPrefs();
      await QuestManager.instance.loadQuests();
      await DailyChallengeManager.instance.loadClaimedMedals();
    } catch (e, st) {
      AppLog.error('Managers.onAppResumed', e, st);
    }
  }
}
