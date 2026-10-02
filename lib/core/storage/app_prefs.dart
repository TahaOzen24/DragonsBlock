import 'package:shared_preferences/shared_preferences.dart';

/// Centralized SharedPreferences wrapper.
///
/// Call [init] once at startup. Prefer this over `SharedPreferences.getInstance()`.
class AppPrefs {
  AppPrefs._();
  static final AppPrefs instance = AppPrefs._();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // ignore: avoid_setters_without_getters
  set debugPrefs(SharedPreferences prefs) => _prefs = prefs;

  /// Test-only: drop cache so [init] reloads after setMockInitialValues.
  void debugReset() => _prefs = null;

  SharedPreferences get _sp {
    final p = _prefs;
    if (p == null) throw StateError('AppPrefs.init() not called');
    return p;
  }

  int? getInt(String key) => _sp.getInt(key);
  String? getString(String key) => _sp.getString(key);
  bool? getBool(String key) => _sp.getBool(key);
  double? getDouble(String key) => _sp.getDouble(key);
  List<String>? getStringList(String key) => _sp.getStringList(key);

  Future<bool> setInt(String key, int v) => _sp.setInt(key, v);
  Future<bool> setString(String key, String v) => _sp.setString(key, v);
  Future<bool> setBool(String key, bool v) => _sp.setBool(key, v);
  Future<bool> setDouble(String key, double v) => _sp.setDouble(key, v);
  Future<bool> setStringList(String key, List<String> v) => _sp.setStringList(key, v);
  Future<bool> remove(String key) => _sp.remove(key);

  /// Wipes all keys (settings reset). Re-init not required — same instance.
  Future<bool> clearAll() async {
    final ok = await _sp.clear();
    return ok;
  }

  // ── Game ─────────────────────────────────────────────────────────
  static const String kHighScore = 'high_score';
  static const String kGamesPlayed = 'games_played';
  static const String kGemstoneEvolutionTier = 'gemstone_evolution_tier';
  static const String kPlayerAvatarId = 'player_avatar_id';
  static const String kAppLastBackground = 'app_last_background_timestamp';

  // ── Shop ─────────────────────────────────────────────────────────
  static const String kGoldShards = 'gold_shards';
  static const String kUnlockedSkins = 'unlocked_skins';
  static const String kActiveSkin = 'active_skin';
  static const String kUnlockedFx = 'unlocked_fx';
  static const String kActiveFx = 'active_fx';
  static const String kIsVip = 'is_vip';
  static const String kShopDailyAdClaimDate = 'shop_daily_ad_claim_date';
  static const String kShopWizardGraceClaimDate = 'shop_wizard_grace_claim_date';
  static const String kShopFlashDealEndsAtMs = 'shop_flash_deal_ends_at_ms';
  static const String kLeagueRewardWeekKey = 'league_reward_week_key';

  // ── Dragon ───────────────────────────────────────────────────────
  static const String kDragonHasChosenEgg = 'dragon_has_chosen_egg';
  static const String kDragonActiveEgg = 'dragon_active_egg';
  static const String kDragonLevel = 'dragon_level';
  static const String kDragonExp = 'dragon_exp';
  static const String kDragonTotalExp = 'dragon_total_exp';
  static const String kDragonCosmeticId = 'dragon_cosmetic_id';
  static const String kDragonUnlockedEggs = 'dragon_unlocked_eggs';

  // ── Settings (legacy key strings — do not rename) ────────────────
  static const String kSettingSound = 'setting_sound';
  static const String kSettingMusic = 'setting_music';
  static const String kSettingHaptics = 'setting_haptics';
  static const String kSettingHapticProfile = 'setting_haptic_profile';
  static const String kSettingSoundscape = 'setting_soundscape';
  static const String kSettingScreenShake = 'setting_screenshake';
  static const String kSettingBatterySaver = 'setting_batterysaver';

  // ── Locale ───────────────────────────────────────────────────────
  static const String kLocale = 'app_language';

  // ── Block themes ─────────────────────────────────────────────────
  static const String kBlockThemeActiveId = 'block_theme_active_id';
  static const String kBlockThemeStyleIdx = 'block_theme_style_idx';
  static const String kBlockThemeCustomMix = 'block_theme_custom_mix';
  static const String kBlockThemeUnlocked = 'block_theme_unlocked';
  static const String kBlockThemeCustomColors = 'block_theme_custom_colors';

  // ── Lives / rewards ───────────────────────────────────────────────
  static const String kPlayerLives = 'player_lives';
  static const String kLastLivesRegen = 'last_lives_regen_time';
  static const String kIdleVaultLastClaim = 'idle_vault_last_claim';
  static const String kLastDailyClaimTs = 'last_daily_claim_ts';
  static const String kDailyStreakDay = 'daily_streak_day';
  static const String kLastLuckyWheelTs = 'last_lucky_wheel_ts';

  // ── Boosters / puzzle ────────────────────────────────────────────
  static const String kBoosterRocket = 'booster_rocket';
  static const String kBoosterHammer = 'booster_hammer';
  static const String kBoosterBomb = 'booster_bomb';
  static const String kPuzzleUnlockedStage = 'puzzle_unlocked_stage';

  // ── Adventure / profile / IAP ────────────────────────────────────
  static const String kAdventureUnlockedLevel = 'adventure_unlocked_level';
  static const String kAdventureHighestFloor = 'adventure_highest_floor';
  static const String kDefeatedBosses = 'defeated_bosses';
  static const String kPlayerName = 'player_name';
  static const String kPlayerFrameId = 'player_frame_id';
  static const String kTotalLinesCleared = 'total_lines_cleared';
  static const String kIapNoAds = 'iap_no_ads_purchased';
  static const String kIapBattlePass = 'iap_battle_pass_premium';
  static const String kQuestResetDate = 'quest_reset_date';

  // ── Versioning ───────────────────────────────────────────────────
  static const String kPrefsVersion = 'prefs_version';
  static const int currentPrefsVersion = 2;

  Future<void> runMigrations() async {
    final v = getInt(kPrefsVersion) ?? 0;
    if (v < currentPrefsVersion) {
      await setInt(kPrefsVersion, currentPrefsVersion);
    }
  }
}
