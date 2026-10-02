import 'package:flutter/material.dart';
import '../../../../../core/ui/vector_assets/vector_assets.dart';
import '../../../../../core/audio/procedural_audio.dart';
import '../../../../../core/haptics/haptic_service.dart';
import '../../../../../core/localization/app_strings.dart';
import '../../../../../core/ui/game_toast.dart';
import '../../../../achievements/presentation/achievements_dialog.dart';
import '../../../../leaderboard/models/league.dart';
import '../../../../leaderboard/presentation/leaderboard_dialog.dart';
import '../../../../leaderboard/services/league_reward_service.dart';
import 'modern_menu_grid_card.dart';

class MenuLeaderboardTab extends StatefulWidget {
  final int highScore;
  final String avatarEmoji;
  final VoidCallback? onRefresh;

  const MenuLeaderboardTab({
    super.key,
    required this.highScore,
    required this.avatarEmoji,
    this.onRefresh,
  });

  @override
  State<MenuLeaderboardTab> createState() => _MenuLeaderboardTabState();
}

class _MenuLeaderboardTabState extends State<MenuLeaderboardTab> {
  Future<void> _claimWeekly() async {
    final amount = await LeagueRewardService.instance.claimWeeklyReward(widget.highScore);
    if (!mounted) return;
    if (amount == null) {
      GameToast.showInfo(context, AppStrings.weeklyChestClaimed, title: AppStrings.navLeaderboard);
      return;
    }
    AppHaptics.reward();
    ProceduralAudio.instance.playPurchase();
    GameToast.showGold(context, '+$amount 🪙', title: AppStrings.claimWeeklyChest);
    setState(() {});
    widget.onRefresh?.call();
  }

  @override
  Widget build(BuildContext context) {
    final highScore = widget.highScore;
    final playerTier = LeagueTier.fromScore(highScore);
    final currentScoreInTier =
        (highScore - playerTier.minScore).clamp(0, playerTier.maxScore - playerTier.minScore);
    final tierRange = playerTier.maxScore - playerTier.minScore;
    final progressToNext = tierRange > 0 ? (currentScoreInTier / tierRange).clamp(0.0, 1.0) : 1.0;
    final roster = LeaderboardEntry.generateWeeklyRoster(highScore);
    final canClaim = LeagueRewardService.instance.canClaimThisWeek;
    final daysLeft = LeagueRewardService.daysUntilWeekEnd();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              ProceduralAudio.instance.playDialogPop();
              showDialog(context: context, builder: (_) => const LeaderboardDialog());
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    playerTier.color.withValues(alpha: 0.25),
                    const Color(0xFF0F172A),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: playerTier.color, width: 1.8),
                boxShadow: [
                  BoxShadow(
                    color: playerTier.color.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      VectorLeagueCrest(tier: playerTier, size: 52),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              playerTier.titleTr.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 14.5,
                                letterSpacing: 0.6,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${AppStrings.tabYourScore}: $highScore • ${AppStrings.tabTarget}: ${playerTier.maxScore}',
                              style: TextStyle(
                                color: playerTier.color.withValues(alpha: 0.9),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              AppStrings.localLeagueSubtitle,
                              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progressToNext,
                      backgroundColor: Colors.white12,
                      valueColor: AlwaysStoppedAnimation<Color>(playerTier.color),
                      minHeight: 7,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: canClaim ? _claimWeekly : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: playerTier.color,
                        disabledBackgroundColor: Colors.white12,
                        foregroundColor: Colors.black,
                        disabledForegroundColor: Colors.white38,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        canClaim
                            ? '${AppStrings.claimWeeklyChest} (+${playerTier.weeklyRewardShards}🪙)'
                            : AppStrings.weeklyChestClaimed,
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppStrings.seasonEndsIn(daysLeft),
                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  AppStrings.localPracticeRanking,
                  style: const TextStyle(
                    color: Color(0xFF38BDF8),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              InkWell(
                onTap: () => showDialog(context: context, builder: (_) => const LeaderboardDialog()),
                child: Text(
                  AppStrings.viewAll,
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A).withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF334155), width: 1.2),
            ),
            child: Column(
              children: roster.take(8).map((entry) {
                final isMe = entry.isCurrentPlayer;
                Widget rankBadge;
                if (entry.rank == 1) {
                  rankBadge = Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFFBBF24), Color(0xFFD97706)]),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      '🥇 1',
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 10),
                    ),
                  );
                } else if (entry.rank == 2) {
                  rankBadge = Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF94A3B8), Color(0xFF64748B)]),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      '🥈 2',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10),
                    ),
                  );
                } else if (entry.rank == 3) {
                  rankBadge = Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFB45309), Color(0xFF78350F)]),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      '🥉 3',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10),
                    ),
                  );
                } else {
                  rankBadge = Text(
                    '#${entry.rank}',
                    style: TextStyle(
                      color: isMe ? playerTier.color : const Color(0xFF94A3B8),
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      SizedBox(width: 42, child: Center(child: rankBadge)),
                      const SizedBox(width: 8),
                      Text(entry.avatar, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isMe ? AppStrings.tabYou : entry.name,
                          style: TextStyle(
                            color: isMe ? Colors.white : const Color(0xFFE2E8F0),
                            fontWeight: isMe ? FontWeight.w900 : FontWeight.w600,
                            fontSize: 12.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isMe)
                        Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: playerTier.color.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            AppStrings.tabYou,
                            style: TextStyle(
                              color: playerTier.color,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      Text(
                        '${entry.score}',
                        style: TextStyle(
                          color: isMe ? playerTier.color : const Color(0xFFFBBF24),
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              AppStrings.achievementsBadges,
              style: const TextStyle(
                color: Color(0xFF60A5FA),
                fontSize: 13,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.15,
            children: [
              ModernMenuGridCard(
                icon: '🎖️',
                title: AppStrings.tabAchievements,
                subtitle: AppStrings.achievementsBadgesSub,
                actionLabel: AppStrings.tabBadges,
                themeColor: const Color(0xFFC084FC),
                onTap: () {
                  showDialog(context: context, builder: (_) => const AchievementsDialog())
                      .then((_) => widget.onRefresh?.call());
                },
              ),
              ModernMenuGridCard(
                icon: '🏆',
                title: AppStrings.weeklyLeague,
                subtitle: AppStrings.localLeagueSubtitle,
                actionLabel: AppStrings.viewAll,
                themeColor: const Color(0xFFF59E0B),
                onTap: () {
                  showDialog(context: context, builder: (_) => const LeaderboardDialog())
                      .then((_) => widget.onRefresh?.call());
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
