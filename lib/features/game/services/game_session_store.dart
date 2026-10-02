import '../../../../core/storage/app_prefs.dart';

/// Persisted classic-run stats used by [GameScreen].
class GameSessionStore {
  GameSessionStore._();

  static Future<({int highScore, int gamesPlayed, int gemstoneTier})> load() async {
    await AppPrefs.instance.init();
    return (
      highScore: AppPrefs.instance.getInt(AppPrefs.kHighScore) ?? 0,
      gamesPlayed: AppPrefs.instance.getInt(AppPrefs.kGamesPlayed) ?? 0,
      gemstoneTier: AppPrefs.instance.getInt(AppPrefs.kGemstoneEvolutionTier) ?? 1,
    );
  }

  static Future<void> saveHighScore(int score) async {
    await AppPrefs.instance.setInt(AppPrefs.kHighScore, score);
  }

  static Future<void> saveGamesPlayed(int count) async {
    await AppPrefs.instance.setInt(AppPrefs.kGamesPlayed, count);
  }

  static Future<void> saveGemstoneTier(int tier) async {
    await AppPrefs.instance.setInt(AppPrefs.kGemstoneEvolutionTier, tier);
  }
}
