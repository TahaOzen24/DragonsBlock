import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/audio/procedural_audio.dart';
import '../../../core/haptics/haptic_service.dart';
import '../../../core/settings/settings_dialog.dart';
import '../../../core/theme/game_theme.dart';
import '../models/adventure_level.dart';
import '../services/adventure_level_manager.dart';
import 'adventure_screen.dart';

class AdventureMapDialog extends StatefulWidget {
  const AdventureMapDialog({super.key});

  @override
  State<AdventureMapDialog> createState() => _AdventureMapDialogState();
}

class _AdventureMapDialogState extends State<AdventureMapDialog> {
  int _selectedWorldId = 1; // 1..6
  int _unlockedLevelIndex = 1;
  int _selectedFloorIndex = 1;
  Map<int, int> _levelStars = {};
  int _totalStars = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    await AdventureLevelManager.instance.loadProgress();
    final unlocked = AdventureLevelManager.instance.unlockedLevel;
    final stars = AdventureLevelManager.instance.starsByLevel;
    final total = AdventureLevelManager.instance.totalStars;

    if (mounted) {
      setState(() {
        _unlockedLevelIndex = unlocked;
        _levelStars = stars;
        _totalStars = total;
        _selectedWorldId = ((unlocked - 1) ~/ 10) + 1;
        if (_selectedWorldId > AdventureWorld.worlds.length) {
          _selectedWorldId = AdventureWorld.worlds.length;
        }
        _selectedFloorIndex = unlocked;
        _isLoading = false;
      });
    }
  }

  void _updateSelectedFloorForWorld() {
    final startFloor = (_selectedWorldId - 1) * 10 + 1;
    final endFloor = _selectedWorldId * 10;
    if (_unlockedLevelIndex >= startFloor && _unlockedLevelIndex <= endFloor) {
      _selectedFloorIndex = _unlockedLevelIndex;
    } else if (_unlockedLevelIndex > endFloor) {
      _selectedFloorIndex = startFloor;
    } else {
      _selectedFloorIndex = startFloor;
    }
  }

  String _getDepthRank(int floor) {
    if (floor >= 50) return 'Efsanevi Hükümdar 👑';
    if (floor >= 40) return 'Kadim Gezgin 🔮';
    if (floor >= 30) return 'Fırtına Ustası ⚡';
    if (floor >= 20) return 'Buzul Kaşifi ❄️';
    if (floor >= 10) return 'Alev Savaşçısı 🔥';
    return 'Acemi Kaşif 🛡️';
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final currentWorld = AdventureWorld.getWorldById(_selectedWorldId);
    final levelsInWorld = AdventureLevel.getLevelsForWorld(_selectedWorldId);
    final selectedLevel = AdventureLevel.getLevel(_selectedFloorIndex);

    // Calculate stars in this world
    int worldStarsEarned = 0;
    int worldUnlockedCount = 0;
    for (var l in levelsInWorld) {
      final s = _levelStars[l.levelIndex] ?? 0;
      worldStarsEarned += s;
      if (l.levelIndex <= _unlockedLevelIndex) worldUnlockedCount++;
    }

    final isWorldUnlocked = ((_selectedWorldId - 1) * 10 + 1) <= _unlockedLevelIndex;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      child: Container(
        constraints: BoxConstraints(maxHeight: screenHeight * 0.90),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: GameTheme.bgDark.withValues(alpha: 0.98),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: currentWorld.primaryColor.withValues(alpha: 0.75),
            width: 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: currentWorld.primaryColor.withValues(alpha: 0.35),
              blurRadius: 28,
              spreadRadius: 2,
            ),
          ],
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: GameTheme.neonCyan))
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ─── 1. TOP HEADER BAR ───
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Left: Map Icon & Title
                        Expanded(
                          child: Row(
                            children: [
                              const Text('🗺️', style: TextStyle(fontSize: 22)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'GÖREV HARİTASI',
                                      style: GameTheme.titleLarge.copyWith(
                                        fontSize: 15,
                                        color: currentWorld.primaryColor,
                                        letterSpacing: 0.8,
                                        fontWeight: FontWeight.w900,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      _getDepthRank(_unlockedLevelIndex),
                                      style: const TextStyle(
                                        color: GameTheme.textMuted,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
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

                        // Right: Stars Badge, Settings Gear & Close Button
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: GameTheme.bgDarkest,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: GameTheme.goldAccent.withValues(alpha: 0.6)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star_rounded, color: GameTheme.goldAccent, size: 14),
                                  const SizedBox(width: 3),
                                  Text(
                                    '$_totalStars ⭐',
                                    style: const TextStyle(
                                      color: GameTheme.goldAccent,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 5),
                            InkWell(
                              onTap: () {
                                AppHaptics.light();
                                ProceduralAudio.instance.playDialogPop();
                                showDialog(
                                  context: context,
                                  builder: (_) => const SettingsDialog(),
                                );
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: GameTheme.bgDarkest,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white24, width: 1.0),
                                ),
                                child: const Center(
                                  child: Icon(Icons.settings_rounded, color: Colors.white70, size: 16),
                                ),
                              ),
                            ),
                            const SizedBox(width: 5),
                            InkWell(
                              onTap: () {
                                AppHaptics.light();
                                Navigator.of(context).pop();
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: GameTheme.bgDarkest,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white24, width: 1.0),
                                ),
                                child: const Center(
                                  child: Icon(Icons.close_rounded, color: Colors.white, size: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // ─── 2. WORLD NAVIGATOR BANNER ───
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            currentWorld.primaryColor.withValues(alpha: 0.30),
                            GameTheme.bgSurface,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: currentWorld.primaryColor.withValues(alpha: 0.6),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: _selectedWorldId > 1
                                ? () {
                                    AppHaptics.selection();
                                    ProceduralAudio.instance.playButtonClick();
                                    setState(() {
                                      _selectedWorldId--;
                                      _updateSelectedFloorForWorld();
                                    });
                                  }
                                : null,
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: GameTheme.bgDarkest,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white24, width: 1.0),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.arrow_back_ios_rounded,
                                  size: 14,
                                  color: _selectedWorldId > 1 ? Colors.white70 : Colors.white24,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: currentWorld.primaryColor.withValues(alpha: 0.25),
                                    border: Border.all(color: currentWorld.primaryColor, width: 1.5),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    currentWorld.icon,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              currentWorld.name,
                                              style: TextStyle(
                                                color: currentWorld.primaryColor,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w900,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            '($_selectedWorldId/6)',
                                            style: const TextStyle(
                                              color: GameTheme.textMuted,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 1),
                                      Text(
                                        currentWorld.subtitle,
                                        style: const TextStyle(color: Colors.white70, fontSize: 10),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 3),
                                      Row(
                                        children: [
                                          Text(
                                            'İlerleme: $worldUnlockedCount/10',
                                            style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            '⭐ $worldStarsEarned/30',
                                            style: const TextStyle(color: GameTheme.goldAccent, fontSize: 9.5, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          InkWell(
                            onTap: _selectedWorldId < AdventureWorld.worlds.length
                                ? () {
                                    AppHaptics.selection();
                                    ProceduralAudio.instance.playButtonClick();
                                    setState(() {
                                      _selectedWorldId++;
                                      _updateSelectedFloorForWorld();
                                    });
                                  }
                                : null,
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: GameTheme.bgDarkest,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white24, width: 1.0),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 14,
                                  color: _selectedWorldId < AdventureWorld.worlds.length ? Colors.white70 : Colors.white24,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ─── 3. 10 LEVEL NODES GRID (5x2) ───
                    if (!isWorldUnlocked)
                      Container(
                        padding: const EdgeInsets.all(20),
                        margin: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: GameTheme.bgDarkest.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.lock_clock_rounded, color: Colors.white38, size: 36),
                            const SizedBox(height: 8),
                            const Text(
                              'BU DİYAR KİLİTLİ',
                              style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Açmak için önceki dünyanın bölümlerini tamamlayın.',
                              style: TextStyle(color: Colors.white38, fontSize: 11),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 0.82,
                        ),
                        itemCount: levelsInWorld.length,
                        itemBuilder: (context, idx) {
                          final level = levelsInWorld[idx];
                          final isUnlocked = level.levelIndex <= _unlockedLevelIndex;
                          final isCurrent = level.levelIndex == _unlockedLevelIndex;
                          final isSelected = level.levelIndex == _selectedFloorIndex;
                          final stars = _levelStars[level.levelIndex] ?? 0;
                          final isBoss = level.objectiveType == ObjectiveType.bossBattle;
                          final isTreasure = level.objectiveType == ObjectiveType.treasureChest;

                          String badgeEmoji;
                          if (isBoss) {
                            badgeEmoji = '👑';
                          } else if (isTreasure) {
                            badgeEmoji = '🎁';
                          } else if (level.objectiveType == ObjectiveType.shatterIce) {
                            badgeEmoji = '❄️';
                          } else if (level.objectiveType == ObjectiveType.clearLines) {
                            badgeEmoji = '⚡';
                          } else {
                            badgeEmoji = '🎯';
                          }

                          return InkWell(
                            onTap: isUnlocked
                                ? () {
                                    AppHaptics.selection();
                                    ProceduralAudio.instance.playButtonClick();
                                    setState(() {
                                      _selectedFloorIndex = level.levelIndex;
                                    });
                                  }
                                : null,
                            borderRadius: BorderRadius.circular(14),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: isUnlocked
                                    ? (isSelected
                                        ? currentWorld.primaryColor.withValues(alpha: 0.35)
                                        : (isCurrent
                                            ? currentWorld.primaryColor.withValues(alpha: 0.20)
                                            : GameTheme.bgSurface))
                                    : GameTheme.bgDarkest.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected
                                      ? currentWorld.primaryColor
                                      : (isCurrent
                                          ? currentWorld.primaryColor.withValues(alpha: 0.8)
                                          : (isUnlocked
                                              ? (isBoss || isTreasure
                                                  ? GameTheme.goldAccent
                                                  : GameTheme.gridBorder)
                                              : Colors.white10)),
                                  width: isSelected || isCurrent ? 2.0 : 1.0,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: currentWorld.primaryColor.withValues(alpha: 0.45),
                                          blurRadius: 10,
                                          spreadRadius: 1,
                                        ),
                                      ]
                                    : (isBoss && isUnlocked ? GameTheme.goldGlow(blur: 8) : null),
                              ),
                              child: Stack(
                                children: [
                                  // Top Glossy Pill Highlight
                                  if (isUnlocked)
                                    Positioned(
                                      top: 2,
                                      left: 6,
                                      right: 6,
                                      height: 3,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: isSelected ? 0.35 : 0.15),
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      ),
                                    ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (isUnlocked) ...[
                                        Text(badgeEmoji, style: const TextStyle(fontSize: 14)),
                                        const SizedBox(height: 1),
                                        Text(
                                          '${level.levelIndex}',
                                          style: TextStyle(
                                            color: isBoss || isTreasure ? GameTheme.goldAccent : Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: List.generate(3, (sIdx) {
                                            return Icon(
                                              Icons.star_rounded,
                                              size: 9,
                                              color: sIdx < stars ? GameTheme.goldAccent : Colors.white24,
                                            );
                                          }),
                                        ),
                                      ] else ...[
                                        const Icon(Icons.lock_rounded, size: 14, color: Colors.white24),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${level.levelIndex}',
                                          style: const TextStyle(color: Colors.white24, fontSize: 11),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 12),

                    // ─── 4. QUICK PLAY / SELECTED LEVEL CARD ───
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            GameTheme.bgSurface,
                            currentWorld.primaryColor.withValues(alpha: 0.20),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: currentWorld.primaryColor.withValues(alpha: 0.6),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      selectedLevel.title,
                                      style: TextStyle(
                                        color: currentWorld.primaryColor,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 13,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _getObjectiveDescription(selectedLevel),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerRight,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: GameTheme.bgDarkest,
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: GameTheme.gridBorder),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.touch_app_rounded, size: 12, color: Colors.white70),
                                            const SizedBox(width: 3),
                                            Text(
                                              '${selectedLevel.maxMoves} Hamle',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: GameTheme.bgDarkest,
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: GameTheme.goldAccent.withValues(alpha: 0.5)),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.monetization_on_rounded, size: 12, color: GameTheme.goldAccent),
                                            const SizedBox(width: 3),
                                            Text(
                                              '+${selectedLevel.rewardShards}',
                                              style: const TextStyle(
                                                color: GameTheme.goldAccent,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Start Level Button
                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: ElevatedButton(
                              onPressed: selectedLevel.levelIndex <= _unlockedLevelIndex
                                  ? () async {
                                      AppHaptics.heavy();
                                      ProceduralAudio.instance.playButtonClick();
                                      await Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => AdventureScreen(level: selectedLevel),
                                        ),
                                      );
                                      _loadProgress();
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: currentWorld.primaryColor,
                                foregroundColor: Colors.black,
                                elevation: 4,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.play_arrow_rounded, size: 20),
                                  const SizedBox(width: 6),
                                  Text(
                                    selectedLevel.levelIndex <= _unlockedLevelIndex ? 'BÖLÜME BAŞLA' : 'KİLİTLİ',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 13,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().scale(duration: 250.ms, curve: Curves.easeOut),
                  ],
                ),
              ),
      ),
    );
  }

  String _getObjectiveDescription(AdventureLevel level) {
    if (level.boss != null) {
      return '👑 ${level.boss!.nameTr} ile Savaş! (Can: ${level.boss!.maxHp})';
    }
    switch (level.objectiveType) {
      case ObjectiveType.shatterIce:
        return '❄️ ${level.targetIceCount} Donmuş Kristali Kır';
      case ObjectiveType.clearLines:
        return '⚡ ${level.targetLineCount} Hat Temizle';
      case ObjectiveType.treasureChest:
        return '🎁 5 Hat Temizle & Gizli Hazineden Altın Kap!';
      case ObjectiveType.scoreTarget:
        return '🎯 ${level.targetScore} Puan Yap';
      case ObjectiveType.bossBattle:
        return '👑 Bölüm Boss\'unu Yen!';
    }
  }
}
