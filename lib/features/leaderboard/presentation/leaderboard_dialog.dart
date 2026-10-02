import 'package:flutter/material.dart';
import '../../../../core/localization/locale_manager.dart';
import '../../../../core/storage/app_prefs.dart';
import '../../../../core/theme/game_theme.dart';
import '../../../../core/ui/vector_assets/vector_assets.dart';
import '../models/league.dart';
import '../services/league_reward_service.dart';

class LeaderboardDialog extends StatefulWidget {
  const LeaderboardDialog({super.key});

  @override
  State<LeaderboardDialog> createState() => _LeaderboardDialogState();
}

class _LeaderboardDialogState extends State<LeaderboardDialog> {
  int _highScore = 0;
  List<LeaderboardEntry> _roster = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await AppPrefs.instance.init();
    final hs = AppPrefs.instance.getInt(AppPrefs.kHighScore) ?? 0;
    if (!mounted) return;
    setState(() {
      _highScore = hs;
      _roster = LeaderboardEntry.generateWeeklyRoster(hs);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isTr = LocaleManager.instance.isTurkish;
    final playerTier = LeagueTier.fromScore(_highScore);

    final currentScoreInTier = (_highScore - playerTier.minScore).clamp(0, playerTier.maxScore - playerTier.minScore);
    final tierRange = playerTier.maxScore - playerTier.minScore;
    final progressToNext = tierRange > 0 ? (currentScoreInTier / tierRange).clamp(0.0, 1.0) : 1.0;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
          maxWidth: 390,
        ),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: GameTheme.bgDark.withValues(alpha: 0.98),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: playerTier.color, width: 2.0),
          boxShadow: [
            BoxShadow(
              color: playerTier.color.withValues(alpha: 0.35),
              blurRadius: 28,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      VectorLeagueCrest(tier: playerTier, size: 36),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.weeklyLeague,
                              style: GameTheme.titleLarge.copyWith(fontSize: 15, letterSpacing: 0.8),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              AppStrings.localLeagueSubtitle,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withValues(alpha: 0.55),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              isTr ? playerTier.titleTr : playerTier.titleEn,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: playerTier.color,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: GameTheme.bgSurface,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24, width: 1.0),
                    ),
                    child: const Center(
                      child: Icon(Icons.close_rounded, color: Colors.white70, size: 18),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Tier Progress & Season Reset Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: GameTheme.bgSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: GameTheme.gridBorder),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppStrings.seasonEndsIn(LeagueRewardService.daysUntilWeekEnd()),
                        style: const TextStyle(color: GameTheme.textMuted, fontSize: 11),
                      ),
                      Text(
                        AppStrings.weeklyPrize(playerTier.weeklyRewardShards),
                        style: const TextStyle(color: GameTheme.goldAccent, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progressToNext,
                      backgroundColor: GameTheme.bgDarkest,
                      valueColor: AlwaysStoppedAnimation<Color>(playerTier.color),
                      minHeight: 5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Leaderboard Roster
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _roster.length,
                separatorBuilder: (context, index) => const SizedBox(height: 6),
                itemBuilder: (context, index) {
                  final entry = _roster[index];
                  final isTop3 = entry.rank <= 3;

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: entry.isCurrentPlayer
                          ? playerTier.color.withValues(alpha: 0.15)
                          : (isTop3 ? GameTheme.bgSurface : GameTheme.bgDarkest),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: entry.isCurrentPlayer
                            ? playerTier.color
                            : (isTop3 ? GameTheme.goldAccent.withValues(alpha: 0.4) : GameTheme.gridBorder),
                        width: entry.isCurrentPlayer ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Rank Badge
                        SizedBox(
                          width: 28,
                          child: entry.rank == 1
                              ? Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(colors: [Color(0xFFFBBF24), Color(0xFFD97706)]),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text('1.', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.black)),
                                )
                              : entry.rank == 2
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(colors: [Color(0xFFE2E8F0), Color(0xFF94A3B8)]),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text('2.', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.black)),
                                    )
                                  : entry.rank == 3
                                      ? Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(colors: [Color(0xFFF97316), Color(0xFFC2410C)]),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: const Text('3.', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white)),
                                        )
                                      : Text(
                                          '#${entry.rank}',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: GameTheme.textMuted,
                                          ),
                                        ),
                        ),

                        // Avatar
                        Text(entry.avatar, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),

                        // Player Name & League Icon
                        Expanded(
                          child: Text(
                            entry.name,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: entry.isCurrentPlayer ? FontWeight.w900 : FontWeight.w600,
                              color: entry.isCurrentPlayer ? playerTier.color : Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        // Score
                        Text(
                          '${entry.score}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: entry.isCurrentPlayer ? Colors.white : GameTheme.neonCyan,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
