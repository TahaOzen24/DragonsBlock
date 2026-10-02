import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/analytics/analytics_service.dart';
import '../../../../core/audio/procedural_audio.dart';
import '../../../../core/haptics/haptic_service.dart';
import '../../../../core/settings/settings_dialog.dart';
import '../../../../core/state/managers.dart';
import '../../../../core/storage/app_prefs.dart';
import '../../../adventure/presentation/adventure_map_dialog.dart';
import '../../../dragon/presentation/dragon_egg_selection_screen.dart';
import '../../../dragon/services/dragon_manager.dart';
import '../../../profile/models/player_avatar.dart';
import '../../../rewards/presentation/lives_refill_dialog.dart';
import '../../../rewards/services/lives_manager.dart';
import '../../../shop/presentation/shop_screen.dart';
import '../../../shop/services/shop_manager.dart';
import '../../models/game_mode.dart';
import '../widgets/menu/menu_bottom_nav_dock.dart';
import '../widgets/menu/menu_collection_tab.dart';
import '../widgets/menu/menu_home_playable_tab.dart';
import '../widgets/menu/menu_leaderboard_tab.dart';
import '../widgets/menu/menu_top_status_bar.dart';
import '../../../dragon/presentation/dragon_sanctuary_dialog.dart';
import 'game_screen.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> with WidgetsBindingObserver {
  // Tabs: 0 Shop, 1 Collection, 2 Home/Play, 3 Dragon, 4 Leaderboard
  int _currentTab = 2;
  GameMode _selectedGameMode = GameMode.classic;
  int _highScore = 0;
  int _adventureLevel = 1;
  String _avatarEmoji = '⚔️';

  final ShopManager _shop = ShopManager.instance;
  final LivesManager _lives = LivesManager.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    for (final manager in Managers.notifiers) {
      manager.addListener(_onChanged);
    }
    _initApp();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    ProceduralAudio.instance.handleAppLifecycle(state);
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      Managers.onAppPaused();
    } else if (state == AppLifecycleState.resumed) {
      Managers.onAppResumed();
      _initApp();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    for (final manager in Managers.notifiers) {
      manager.removeListener(_onChanged);
    }
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _initApp() async {
    await Managers.loadAll();

    await AppPrefs.instance.init();
    final avatarId = AppPrefs.instance.getString(AppPrefs.kPlayerAvatarId) ?? 'knight';
    final avatarObj = PlayerAvatar.defaultAvatars.firstWhere(
      (a) => a.id == avatarId,
      orElse: () => PlayerAvatar.defaultAvatars.first,
    );

    if (mounted) {
      setState(() {
        _highScore = AppPrefs.instance.getInt(AppPrefs.kHighScore) ?? 2940;
        _adventureLevel = AppPrefs.instance.getInt(AppPrefs.kAdventureUnlockedLevel) ?? 1;
        _avatarEmoji = avatarObj.emoji;
      });

      // First-time dragon egg selection
      if (!DragonManager.instance.hasChosenEgg) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.of(context).push(
              MaterialPageRoute(
                fullscreenDialog: true,
                builder: (_) => const DragonEggSelectionScreen(isChoosingFirst: true),
              ),
            );
          }
        });
      }
    }
  }

  void _openSettingsOrQuickMenu() {
    ProceduralAudio.instance.playDialogPop();
    showDialog(
      context: context,
      builder: (_) => const SettingsDialog(),
    );
  }

  void _openLivesRefill() {
    ProceduralAudio.instance.playDialogPop();
    showDialog(
      context: context,
      builder: (_) => const LivesRefillDialog(),
    );
  }

  Future<bool?> _showExitConfirmationDialog() {
    ProceduralAudio.instance.playDialogPop();
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.6), width: 1.8),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF38BDF8).withValues(alpha: 0.25),
                  blurRadius: 24,
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.7),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                    border: Border.all(color: const Color(0xFF38BDF8), width: 1.5),
                  ),
                  alignment: Alignment.center,
                  child: const Text('🛡️', style: TextStyle(fontSize: 28)),
                ),
                const SizedBox(height: 14),
                const Text(
                  'OYUNDAN ÇIKIŞ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'İlerlemen, boşta maden birikimin ve rünlerin güvenle kaydedildi.\n\nOyundan çıkmak istiyor musun?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          AppHaptics.light();
                          ProceduralAudio.instance.playButtonClick();
                          Navigator.of(ctx).pop(false);
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFF475569), width: 1.2),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'İPTAL',
                            style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          AppHaptics.heavy();
                          ProceduralAudio.instance.playButtonClick();
                          Navigator.of(ctx).pop(true);
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFEF4444), Color(0xFFB91C1C)],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFFCA5A5), width: 1.2),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFEF4444).withValues(alpha: 0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'ÇIKIŞ',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _startGame() async {
    AppHaptics.heavy();
    ProceduralAudio.instance.playButtonClick();
    AnalyticsService.instance.logEvent('game_start', {'mode': _selectedGameMode.name});

    if (_selectedGameMode == GameMode.adventure) {
      await showDialog(
        context: context,
        builder: (_) => const AdventureMapDialog(),
      );
      _initApp();
      return;
    }

    // Classic / Endless Mode
    if (!_lives.hasLives) {
      _openLivesRefill();
      return;
    }

    await _lives.consumeLife();
    if (!mounted) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GameScreen(gameMode: _selectedGameMode),
      ),
    );
    _initApp();
  }

  String _getBackgroundForTab(int tab) {
    switch (tab) {
      case 0:
        return 'assets/images/backgrounds/bg_shop.jpg';
      case 1:
        return 'assets/images/backgrounds/bg_collection.jpg';
      case 2:
        return _selectedGameMode == GameMode.adventure
            ? 'assets/images/backgrounds/bg_guild.jpg' // 🔥 Volkanik Lav Kalesi (Macera)
            : 'assets/images/backgrounds/bg_main_menu.jpg'; // 💎 Mistik Safir Kristal Tapınağı (Klasik)
      case 3:
        return 'assets/images/backgrounds/bg_collection.jpg';
      case 4:
        return 'assets/images/backgrounds/bg_leaderboard.jpg';
      default:
        return 'assets/images/backgrounds/bg_main_menu.jpg';
    }
  }

  Color _getTabAccentColor(int tab) {
    switch (tab) {
      case 0:
        return const Color(0xFF6366F1); // Royal Arcane Purple / Indigo
      case 1:
        return const Color(0xFF06B6D4); // Cyan Diamond (Block themes)
      case 2:
        return _selectedGameMode.themeColor; // Dynamic Mode Tint
      case 3:
        return DragonManager.instance.activeDragon.themeColor; // Dragon Element
      case 4:
        return const Color(0xFFF59E0B); // Champion Gold / Victory
      default:
        return const Color(0xFF38BDF8);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (_currentTab != 2) {
          setState(() => _currentTab = 2);
          return;
        }
        final shouldExit = await _showExitConfirmationDialog();
        if (shouldExit == true) {
          ProceduralAudio.instance.stopBackgroundMusic();
          ProceduralAudio.instance.stopAllSfx();
          await Managers.onAppPaused();
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0C1427),
        body: Stack(
          children: [
            // 1. Dynamic Tab & Game Mode Background Wallpaper with Smooth Animated Cross-Fade
            Positioned.fill(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: Image.asset(
                  _getBackgroundForTab(_currentTab),
                  key: ValueKey<String>('${_getBackgroundForTab(_currentTab)}_${_currentTab == 2 ? _selectedGameMode.name : ''}'),
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
            // 2. Top and Bottom Anti-Banding Smoothing Gradient (Eliminates JPEG artifacts in corners)
            Positioned.fill(
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xCC070C18),
                      Colors.transparent,
                      Color(0xE604060C),
                    ],
                    stops: [0.0, 0.30, 1.0],
                  ),
                ),
              ),
            ),
            // 3. Dynamic Atmospheric Ambient Lighting Tint (Morphs on Tab & Game Mode Switch)
            Positioned.fill(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 450),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0.0, 0.4),
                    radius: 1.1,
                    colors: [
                      _getTabAccentColor(_currentTab).withValues(alpha: 0.18),
                      const Color(0xFF070B16).withValues(alpha: 0.55),
                      const Color(0xFF04060C).withValues(alpha: 0.85),
                    ],
                    stops: const [0.0, 0.6, 1.0],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Column(
                    children: [
                      // 1. Top Bar (Lives, High Score, Gold, Settings)
                      MenuTopStatusBar(
                        highScore: _highScore,
                        goldCoins: _shop.goldShards,
                        onGoldCoinsTap: () => setState(() => _currentTab = 0),
                        onSettingsTap: _openSettingsOrQuickMenu,
                        onAfterQuest: _initApp,
                      ),

                      // 2. Active Tab Screen Body (5 Clean Tabs)
                      Expanded(
                        child: IndexedStack(
                          index: _currentTab,
                          children: [
                            const ShopScreen(isTab: true),
                            const MenuCollectionTab(isTab: true),
                            MenuHomePlayableTab(
                              selectedGameMode: _selectedGameMode,
                              onModeChanged: (GameMode mode) => setState(() => _selectedGameMode = mode),
                              highScore: _highScore,
                              adventureLevel: _adventureLevel,
                              onStartGame: _startGame,
                            ),
                            const DragonSanctuaryDialog(isTab: true),
                            MenuLeaderboardTab(
                              highScore: _highScore,
                              avatarEmoji: _avatarEmoji,
                              onRefresh: _initApp,
                            ),
                          ],
                        ),
                      ),

                      // 3. 5-Tab Navigation Dock
                      MenuBottomNavDock(
                        currentTab: _currentTab,
                        onTabSelected: (tab) => setState(() => _currentTab = tab),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
