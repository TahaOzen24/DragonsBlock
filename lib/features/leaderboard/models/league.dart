import 'package:flutter/material.dart';
import '../../../../core/theme/game_theme.dart';

enum LeagueTier {
  bronze,
  silver,
  gold,
  diamond,
  master;

  String get titleTr {
    switch (this) {
      case LeagueTier.bronze:
        return 'Bronz Ligi';
      case LeagueTier.silver:
        return 'Gümüş Ligi';
      case LeagueTier.gold:
        return 'Altın Ligi';
      case LeagueTier.diamond:
        return 'Elmas Ligi';
      case LeagueTier.master:
        return 'Efsanevi Usta (Archon)';
    }
  }

  String get titleEn {
    switch (this) {
      case LeagueTier.bronze:
        return 'Bronze League';
      case LeagueTier.silver:
        return 'Silver League';
      case LeagueTier.gold:
        return 'Gold League';
      case LeagueTier.diamond:
        return 'Diamond League';
      case LeagueTier.master:
        return 'Grand Archon';
    }
  }

  String get icon {
    switch (this) {
      case LeagueTier.bronze:
        return '🥉';
      case LeagueTier.silver:
        return '🥈';
      case LeagueTier.gold:
        return '🥇';
      case LeagueTier.diamond:
        return '💎';
      case LeagueTier.master:
        return '👑';
    }
  }

  Color get color {
    switch (this) {
      case LeagueTier.bronze:
        return const Color(0xFFCD7F32);
      case LeagueTier.silver:
        return const Color(0xFFC0C0C0);
      case LeagueTier.gold:
        return GameTheme.goldAccent;
      case LeagueTier.diamond:
        return GameTheme.neonCyan;
      case LeagueTier.master:
        return GameTheme.voidPurple;
    }
  }

  int get minScore {
    switch (this) {
      case LeagueTier.bronze:
        return 0;
      case LeagueTier.silver:
        return 2500;
      case LeagueTier.gold:
        return 6000;
      case LeagueTier.diamond:
        return 12000;
      case LeagueTier.master:
        return 25000;
    }
  }

  int get maxScore {
    switch (this) {
      case LeagueTier.bronze:
        return 2500;
      case LeagueTier.silver:
        return 6000;
      case LeagueTier.gold:
        return 12000;
      case LeagueTier.diamond:
        return 25000;
      case LeagueTier.master:
        return 50000;
    }
  }

  int get weeklyRewardShards {
    switch (this) {
      case LeagueTier.bronze:
        return 200;
      case LeagueTier.silver:
        return 400;
      case LeagueTier.gold:
        return 800;
      case LeagueTier.diamond:
        return 1500;
      case LeagueTier.master:
        return 3000;
    }
  }

  static LeagueTier fromScore(int score) {
    if (score >= 25000) return LeagueTier.master;
    if (score >= 12000) return LeagueTier.diamond;
    if (score >= 6000) return LeagueTier.gold;
    if (score >= 2500) return LeagueTier.silver;
    return LeagueTier.bronze;
  }
}

class LeaderboardEntry {
  final int rank;
  final String name;
  final String avatar;
  final int score;
  final LeagueTier tier;
  final bool isCurrentPlayer;

  const LeaderboardEntry({
    required this.rank,
    required this.name,
    required this.avatar,
    required this.score,
    required this.tier,
    this.isCurrentPlayer = false,
  });

  static List<LeaderboardEntry> generateWeeklyRoster(int playerScore) {
    final playerTier = LeagueTier.fromScore(playerScore);

    final List<LeaderboardEntry> mockRivals = [
      const LeaderboardEntry(rank: 1, name: 'Vortex_Archon', avatar: '👑', score: 38400, tier: LeagueTier.master),
      const LeaderboardEntry(rank: 2, name: 'CyberKnight_99', avatar: '⚡', score: 29850, tier: LeagueTier.master),
      const LeaderboardEntry(rank: 3, name: 'Frost_Valkyrie', avatar: '❄️', score: 24100, tier: LeagueTier.diamond),
      const LeaderboardEntry(rank: 4, name: 'InfernoMage', avatar: '🔥', score: 18950, tier: LeagueTier.diamond),
      const LeaderboardEntry(rank: 5, name: 'NeonSamurai', avatar: '🗡️', score: 14200, tier: LeagueTier.diamond),
      const LeaderboardEntry(rank: 6, name: 'VoidWalker', avatar: '🔮', score: 10450, tier: LeagueTier.gold),
      const LeaderboardEntry(rank: 7, name: 'RuneCrafter_TR', avatar: '🛡️', score: 8700, tier: LeagueTier.gold),
      const LeaderboardEntry(rank: 8, name: 'ZenMaster_Ozen', avatar: '🍃', score: 6200, tier: LeagueTier.gold),
      const LeaderboardEntry(rank: 9, name: 'ShadowStriker', avatar: '🐉', score: 4800, tier: LeagueTier.silver),
      const LeaderboardEntry(rank: 10, name: 'Sparky_Pro', avatar: '✨', score: 3200, tier: LeagueTier.silver),
    ];

    // Find where the player ranks
    int pRank = 11;
    for (int i = 0; i < mockRivals.length; i++) {
      if (playerScore >= mockRivals[i].score) {
        pRank = i + 1;
        break;
      }
    }

    final playerEntry = LeaderboardEntry(
      rank: pRank,
      name: 'YOU',
      avatar: '🌟',
      score: playerScore,
      tier: playerTier,
      isCurrentPlayer: true,
    );

    // If player is in top 10, insert
    if (pRank <= 10) {
      mockRivals.insert(pRank - 1, playerEntry);
      return mockRivals.take(10).map((e) {
        int idx = mockRivals.indexOf(e) + 1;
        return LeaderboardEntry(
          rank: idx,
          name: e.name,
          avatar: e.avatar,
          score: e.score,
          tier: e.tier,
          isCurrentPlayer: e.isCurrentPlayer,
        );
      }).toList();
    } else {
      // Append as 11th or pinned
      return [...mockRivals, playerEntry];
    }
  }
}
