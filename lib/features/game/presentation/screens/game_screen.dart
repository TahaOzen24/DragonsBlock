import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/audio/procedural_audio.dart';
import '../../../../core/ads/ad_service.dart';
import '../../../../core/analytics/analytics_service.dart';
import '../../../../core/config/game_config.dart';
import '../../../../core/localization/locale_manager.dart';
import '../../../../core/particles/particle_system.dart';
import '../../../../core/settings/settings_manager.dart';
import '../../../../core/theme/game_theme.dart';
import '../../../../core/ui/game_toast.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/vfx/screen_shake.dart';
import '../../../achievements/services/achievement_manager.dart';
import '../../../daily_challenge/models/challenge_modifier.dart';
import '../../../daily_challenge/services/daily_challenge_manager.dart';
import '../../../block_themes/services/block_theme_manager.dart';
import '../../../shop/services/shop_manager.dart';
import '../../logic/grid_engine.dart';
import '../../logic/shape_spawner_engine.dart';
import '../../models/block_skin_style.dart';
import '../../models/board_era.dart';
import '../../models/board_realm.dart';
import '../../models/combo_realm_theme.dart';
import '../../models/game_mode.dart';
import '../../models/polyomino_shape.dart';
import '../../models/relic.dart';
import '../../services/game_session_store.dart';
import '../vfx/game_board_geometry.dart';
import '../vfx/game_vfx_controller.dart';
import '../widgets/block_spawner_bar.dart';
import '../widgets/game_hud.dart';
import '../widgets/mode_indicator_bar.dart';
import '../widgets/game/game_board_container.dart';
import '../widgets/game/game_dialog_helper.dart';
import '../widgets/game/game_fx_overlay.dart';
import '../../../../core/haptics/haptic_service.dart';
import '../../../dragon/models/dragon.dart';
import '../../../dragon/services/dragon_manager.dart';
class GameScreen extends StatefulWidget {
  final ChallengeModifier? dailyModifier;
  final GameMode gameMode;

  const GameScreen({
    super.key, 
    this.dailyModifier,
    this.gameMode = GameMode.classic,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin, WidgetsBindingObserver {
  late final GridEngine _gridEngine;
  late final ParticleSystem _particleSystem;
  final ScreenShakeController _shakeController = ScreenShakeController();
  late final GameBoardGeometry _geometry;
  late final GameVfxController _vfx;

  List<PolyominoShape?> _availableShapes = [null, null, null];
  final List<Relic> _activeRelics = [];
  bool _isGameOver = false;
  bool _canRevive = true;
  bool _hasUsedAegisRescue = false;
  double _dragonEnergy = 0.0;
  DragonDefinition get _activeDragon => DragonManager.instance.activeDragon;
  bool get _isDragonPowerReady => _dragonEnergy >= 100.0;
  int _dailyBonusShards = 0;
  bool _isGameOverModalActive = false;

  PolyominoShape? _draggingShape;
  Point<int>? _hoverGridPos;
  bool _isHoverValid = false;
  Offset _lastDragTrailPos = Offset.zero;
  final GlobalKey _gridKey = GlobalKey();
  int _movesCount = 0;

  BlockSkinStyle _currentBlockSkinStyle = BlockSkinStyle.minimalGlass;
  int _sessionClearedLines = 0;
  int _gamesPlayed = 0;
  int _gemstoneEvolutionTier = 1;
  List<int> _cachedPreviewRows = const [];
  List<int> _cachedPreviewCols = const [];
  ComboRealmTheme _currentWorldTheme = ComboRealmTheme.classicJewel;
  ComboRealmTheme _previousWorldTheme = ComboRealmTheme.classicJewel;
  int _feverComboStreak = 0;

  void _onTrayCompleted() {
    _spawnNewShapes();
  }

  BoardEra _currentEra = BoardEra.bronze;

  double get _frenzyDurationMultiplier =>
      _activeDragon.eggType == DragonEggType.ice ? 1.30 : 1.0;

  void _triggerClearingAnimation({
    required List<ClearedCellInfo> cellDetails,
    required List<int> clearedRows,
    required List<int> clearedCols,
    required Color fallbackColor,
    int linesCleared = 1,
    int comboStreak = 0,
    bool isDragonPower = false,
  }) {
    _vfx.triggerClearingAnimation(
      cellDetails: cellDetails,
      clearedRows: clearedRows,
      clearedCols: clearedCols,
      fallbackColor: fallbackColor,
      blockSkinStyle: _currentBlockSkinStyle,
      dragonType: _activeDragon.eggType,
      dragonThemeColor: _activeDragon.themeColor,
      linesCleared: linesCleared,
      comboStreak: comboStreak,
      isDragonPower: isDragonPower,
    );
  }

  String _cachedBackground = 'assets/images/backgrounds/bg_main_menu.jpg';

  String _getInGameBackground() {
    if (widget.gameMode == GameMode.adventure) {
      return 'assets/images/backgrounds/bg_guild.jpg'; // 🔥 Volkanik Macera Kalesi
    }
    final score = _gridEngine.currentScore;
    if (score >= 15000) {
      return 'assets/images/backgrounds/bg_leaderboard.jpg'; // 👑 Kadim Şampiyonlar Arenası
    } else if (score >= 8500) {
      return 'assets/images/backgrounds/bg_shop.jpg'; // 🔮 Mistik Rün Mahzeni
    } else if (score >= 4000) {
      return 'assets/images/backgrounds/bg_guild.jpg'; // 🔥 Volkanik Lav Kalesi
    } else if (score >= 1500) {
      return 'assets/images/backgrounds/bg_collection.jpg'; // 💎 Zümrüt Uçan Ejderha Adaları
    }
    return 'assets/images/backgrounds/bg_main_menu.jpg'; // 🌌 Mistik Safir Kristal Tapınağı
  }

  String _getBackgroundRealmName(String bgPath) {
    if (bgPath.contains('bg_collection')) return 'ZÜMRÜT EJDERHA ADALARI';
    if (bgPath.contains('bg_guild')) return 'VOLKANİK LAV KALESİ';
    if (bgPath.contains('bg_shop')) return 'MİSTİK RÜN MAHZENİ';
    if (bgPath.contains('bg_leaderboard')) return 'KADİM ZAFER ARENASI';
    return 'MİSTİK TAPINAK';
  }

  void _checkEraProgression(int score) {
    final nextEra = BoardEra.fromScore(score);
    if (nextEra != _currentEra) {
      setState(() {
        _currentEra = nextEra;
      });
      ProceduralAudio.instance.playPowerUpUsed();
    }

    // Dynamic In-Game Realm Background Morph
    final nextBg = _getInGameBackground();
    if (nextBg != _cachedBackground) {
      _cachedBackground = nextBg;
      ProceduralAudio.instance.playPowerUpUsed();
      final realmTitle = _getBackgroundRealmName(nextBg);
      final gridCenter = _geometry.gridCenter();
      _particleSystem.spawnFloatingText(
        "✨ $realmTitle ✨",
        gridCenter.dx,
        gridCenter.dy - 65,
        GameTheme.neonCyan,
        fontSize: 14,
      );
    }
  }

  void _resetFrenzyTimer({bool resetProgress = true}) {
    _vfx.resetFrenzyTimer(
      resetProgress: resetProgress,
      durationMultiplier: _frenzyDurationMultiplier,
    );
  }

  void _resumeFrenzyTimer() {
    _vfx.resumeFrenzyTimer(durationMultiplier: _frenzyDurationMultiplier);
  }

  void _triggerStinger(String text, Color color, {bool isCrucialMilestone = false}) {
    _vfx.triggerStinger(text, color, isCrucialMilestone: isCrucialMilestone);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _currentBlockSkinStyle = BlockThemeManager.instance.activeStyle;
    BlockThemeManager.instance.addListener(_onBlockThemeUpdated);
    _gridEngine = GridEngine();
    _particleSystem = ParticleSystem();
    _geometry = GameBoardGeometry(_gridKey);
    _vfx = GameVfxController(
      vsync: this,
      onChanged: () {
        if (mounted) setState(() {});
      },
      geometry: _geometry,
      particles: _particleSystem,
      shake: _shakeController,
      onFrenzyExpired: () {
        _gridEngine.comboStreak = 0;
      },
    );

    if (widget.dailyModifier != null) {
      _gridEngine.runScoreMultiplier = widget.dailyModifier!.scoreMultiplier;
      _gridEngine.runEnergyMultiplier = widget.dailyModifier!.energyMultiplier;
      DailyChallengeManager.instance.loadClaimedMedals();
    }

    _loadStoredData();

    if (_gridEngine.isBoardCompletelyEmpty()) {
      _gridEngine.placeStartingBlocks(count: 6);
    }

    _spawnNewShapes();
    _vfx.start();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      _vfx.pauseLoops();
      ProceduralAudio.instance.handleAppLifecycle(state);
    } else if (state == AppLifecycleState.resumed) {
      ProceduralAudio.instance.handleAppLifecycle(state);
      if (!_isGameOver && !_isGameOverModalActive) {
        _vfx.tickerController.repeat();
        _resumeFrenzyTimer();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    BlockThemeManager.instance.removeListener(_onBlockThemeUpdated);
    _vfx.dispose();
    super.dispose();
  }

  void _onBlockThemeUpdated() {
    if (mounted) {
      setState(() {
        _currentBlockSkinStyle = BlockThemeManager.instance.activeStyle;
      });
    }
  }

  void _triggerBoardRealmEvolution(BoardRealm newRealm) {
    if (_gridEngine.activeRealm == newRealm) return;
    _gridEngine.activeRealm = newRealm;
  }

  Future<void> _loadStoredData() async {
    await DragonManager.instance.loadFromPrefs();
    final stored = await GameSessionStore.load();
    final initialSkin = BlockThemeManager.instance.activeStyle;

    setState(() {
      _gridEngine.highScore = stored.highScore;
      _gamesPlayed = stored.gamesPlayed;
      _gemstoneEvolutionTier = stored.gemstoneTier;
      _currentBlockSkinStyle = initialSkin;
      _sessionClearedLines = 0;
    });
  }

  void _activateDragonPower() {
    if (!_isDragonPowerReady || _isGameOver) return;
    AppHaptics.heavy();
    ProceduralAudio.instance.playPowerUpUsed();

    setState(() {
      _dragonEnergy = 0.0;
    });

    final gridCenter = _geometry.gridCenter();

    switch (_activeDragon.eggType) {
      case DragonEggType.fire:
        // Pyro Meteor Rain: Clears most crowded 3x3 area
        int bestR = 0, bestC = 0, maxCount = -1;
        for (int r = 0; r <= 5; r++) {
          for (int c = 0; c <= 5; c++) {
            int cnt = 0;
            for (int dr = 0; dr < 3; dr++) {
              for (int dc = 0; dc < 3; dc++) {
                if (_gridEngine.grid[r + dr][c + dc].isOccupied) cnt++;
              }
            }
            if (cnt > maxCount) {
              maxCount = cnt;
              bestR = r;
              bestC = c;
            }
          }
        }
        for (int dr = 0; dr < 3; dr++) {
          for (int dc = 0; dc < 3; dc++) {
            _gridEngine.grid[bestR + dr][bestC + dc].reset();
          }
        }
        _shakeController.trigger(intensity: 8.0, trauma: 1.0);
        _particleSystem.spawnExplosion(gridCenter.dx, gridCenter.dy, _activeDragon.themeColor, count: 28);
        _triggerStinger("🔥 ALEV NEFESİ! (3x3 ALAN YAKILDI)", _activeDragon.themeColor, isCrucialMilestone: true);
        break;

      case DragonEggType.ice:
        // Glacius Frost Wave: Clears bottom 2 rows
        for (int r = 6; r < 8; r++) {
          for (int c = 0; c < 8; c++) {
            _gridEngine.grid[r][c].reset();
          }
        }
        _shakeController.trigger(intensity: 6.0, trauma: 0.8);
        _particleSystem.spawnExplosion(gridCenter.dx, gridCenter.dy, _activeDragon.themeColor, count: 24);
        _triggerStinger("❄️ DONMUŞ FIRTINA! (2 SATIR TEMİZLENDİ)", _activeDragon.themeColor, isCrucialMilestone: true);
        break;

      case DragonEggType.storm:
        // Storm Lightning Cross: Clears row 3 and 4 + col 3 and 4
        for (int i = 0; i < 8; i++) {
          _gridEngine.grid[3][i].reset();
          _gridEngine.grid[4][i].reset();
          _gridEngine.grid[i][3].reset();
          _gridEngine.grid[i][4].reset();
        }
        _shakeController.trigger(intensity: 7.5, trauma: 0.9);
        _particleSystem.spawnExplosion(gridCenter.dx, gridCenter.dy, _activeDragon.themeColor, count: 26);
        _triggerStinger("⚡ YILDIRIM ÇAPRAZI!", _activeDragon.themeColor, isCrucialMilestone: true);
        break;

      case DragonEggType.earth:
        // Terra Stone Burst: Clears corners and random occupied blocks
        for (int r = 0; r < 8; r++) {
          for (int c = 0; c < 8; c++) {
            if (_gridEngine.grid[r][c].isOccupied && Random().nextDouble() < 0.35) {
              _gridEngine.grid[r][c].reset();
            }
          }
        }
        _shakeController.trigger(intensity: 7.0, trauma: 0.85);
        _particleSystem.spawnExplosion(gridCenter.dx, gridCenter.dy, _activeDragon.themeColor, count: 24);
        _triggerStinger("🌍 TAŞ DEPREMİ!", _activeDragon.themeColor, isCrucialMilestone: true);
        break;
    }

    _gridEngine.currentScore += 300;
    ProceduralAudio.instance.playPerfectSweep();
    _saveStoredData();
    setState(() {});
  }



  void _checkGemstoneEvolution({
    required bool isPerfectClear,
    required int linesClearedThisMove,
  }) async {
    _sessionClearedLines += linesClearedThisMove;

    final targetLines = 25 + (_gemstoneEvolutionTier - 1) * 10;
    final targetMegaCombo = _gemstoneEvolutionTier > 1 ? 5 : 4;

    bool triggered = false;

    if (isPerfectClear) {
      triggered = true;
    } else if (linesClearedThisMove >= targetMegaCombo) {
      triggered = true;
    } else if (_sessionClearedLines >= targetLines) {
      triggered = true;
    }

    if (triggered) {
      // Reward bonus shards without altering the clean soft block skin style
      ShopManager.instance.addShards(50);
      _gemstoneEvolutionTier++;
      await GameSessionStore.saveGemstoneTier(_gemstoneEvolutionTier);
      ProceduralAudio.instance.playRewardClaim();
    }
  }

  Future<void> _saveStoredData() async {
    await GameSessionStore.saveHighScore(_gridEngine.highScore);
  }

  final ShapeSpawnerEngine _spawnerEngine = ShapeSpawnerEngine();

  List<Color> get _activePalette =>
      _currentWorldTheme.isMonochrome && _currentWorldTheme.uniformColor != null
          ? [_currentWorldTheme.uniformColor!]
          : BlockThemeManager.instance.activePalette;

  List<PolyominoShape> _generateHand() {
    return _spawnerEngine.generateBalancedHand(
      gridEngine: _gridEngine,
      currentScore: _gridEngine.currentScore,
      movesCount: _movesCount,
      forcedPalette: _activePalette,
      gamesPlayed: _gamesPlayed,
    );
  }

  void _spawnNewShapes() {
    var hand = _generateHand();

    // Hard anti-softlock pass
    if (!hand.any(_gridEngine.canPlaceShapeAnywhere) &&
        _spawnerEngine.boardHasAnyLegalCatalogMove(_gridEngine)) {
      hand = _generateHand();
    }

    setState(() {
      _availableShapes = List<PolyominoShape?>.from(hand);
    });

    final slots = List<PolyominoShape?>.from(_availableShapes);
    if (_spawnerEngine.rescueUnplaceableSlots(
      gridEngine: _gridEngine,
      slots: slots,
      forcedPalette: _activePalette,
    )) {
      setState(() => _availableShapes = slots);
    }
  }

  void _rotateSlot(int slotIndex) {
    if (_isGameOver || slotIndex < 0 || slotIndex >= _availableShapes.length) return;
    final shape = _availableShapes[slotIndex];
    if (shape == null) return;
    AppHaptics.light();
    ProceduralAudio.instance.playPlace();
    setState(() {
      final rotated = shape.rotated90();
      _availableShapes[slotIndex] = rotated;
      if (_draggingShape != null && _draggingShape!.id == shape.id) {
        _draggingShape = rotated;
      }
    });
  }

  void _onBlockPlaced(PolyominoShape shape, int slotIndex, int row, int col) async {
    _movesCount++;
    ProceduralAudio.instance.playPlace();

    final result = _gridEngine.placeShape(shape, row, col, _activeRelics);

    if (result.success) {
      // Track piece in drought tracker for dynamic difficulty
      _spawnerEngine.droughtTracker.recordPiece(
        shape.name,
        result.linesCleared > 0,
        shape.totalBlocks,
      );

      // Track newly placed cell positions for impact flash
      final List<Point<int>> placedPoints = [];
      final List<Offset> cellCenters = [];
      for (int r = 0; r < shape.rowCount; r++) {
        for (int c = 0; c < shape.colCount; c++) {
          if (shape.matrix[r][c] == 1) {
            placedPoints.add(Point(row + r, col + c));
            cellCenters.add(_geometry.cellCenter(row + r, col + c));
          }
        }
      }

      setState(() {
        _vfx.markPlacementFlash(placedPoints);
        _availableShapes[slotIndex] = null;
      });

      // Thud effect: subtle screen shake + haptic on placement
      _shakeController.trigger(intensity: 1.5, trauma: 0.15);
      if (result.linesCleared == 0) {
        AppHaptics.blockPlace();
      }

      // Gold Shards earned from placing tiles
      if (result.goldShardsEarned > 0) {
        final earned = result.goldShardsEarned;
        ShopManager.instance.addShards(earned);
        AppLog.reward('Hat Temizleme', earned);
      }

      // Fire Passive: Flame Resonance (Multi-line clears award +25% bonus score)
      if (_activeDragon.eggType == DragonEggType.fire && result.linesCleared >= 2) {
        final bonus = (result.pointsEarned * 0.25).round();
        _gridEngine.currentScore += bonus;
      }

      if (_gridEngine.currentScore > _gridEngine.highScore) {
        _gridEngine.highScore = _gridEngine.currentScore;
      }

      // Dragon Power Energy Charging
      double chargeGain = 4.0;
      if (result.linesCleared > 0) {
        chargeGain += result.linesCleared * 16.0;
      }
      if (result.comboStreak > 1) {
        chargeGain += result.comboStreak * 6.0;
      }
      // Storm Passive: High Voltage (+20% faster dragon power charge rate)
      if (_activeDragon.eggType == DragonEggType.storm) {
        chargeGain *= 1.20;
      }
      final prevReady = _isDragonPowerReady;
      _dragonEnergy = (_dragonEnergy + chargeGain).clamp(0.0, 100.0);
      if (!prevReady && _isDragonPowerReady) {
        ProceduralAudio.instance.playLevelUp();
        final center = _geometry.gridCenter();
        _particleSystem.spawnFloatingText("⚡ NİHAİ YETENEK HAZIR! ⚡", center.dx, center.dy - 50, _activeDragon.themeColor, fontSize: 14);
      }

      AppLog.game('Taş Yerleştirildi: ${shape.name}', {
        'konum': '($row, $col)',
        'puan': result.pointsEarned,
        'satır': result.linesCleared,
        'kombo': result.comboStreak,
      });

      // Daily challenge bonus shards per cleared line
      final modifier = widget.dailyModifier;
      if (modifier != null && modifier.bonusShardPerLine > 0 && result.linesCleared > 0) {
        final bonus = result.linesCleared * modifier.bonusShardPerLine;
        _dailyBonusShards += bonus;
        ShopManager.instance.addShards(bonus);
      }

      // Multi-cell placement impact shockwaves & sparkling poofs
      _particleSystem.spawnPlacementImpact(cellCenters, shape.baseColor);

      // Spawn VFX and audio for lines cleared
      if (result.linesCleared > 0) {
        _resetFrenzyTimer();

        ProceduralAudio.instance.playComboTone(result.comboStreak);
        ProceduralAudio.instance.playExplosion();
        if (result.linesCleared >= 2) {
          ProceduralAudio.instance.playMultiLineClear(result.linesCleared);
        }

        // 1. Immediately trigger the vsync staggered cascade clearing animation
        _triggerClearingAnimation(
          cellDetails: result.clearedCellDetails,
          clearedRows: result.clearedRows,
          clearedCols: result.clearedCols,
          fallbackColor: shape.baseColor,
          linesCleared: result.linesCleared,
          comboStreak: result.comboStreak,
        );

        // 2. Punchy screen shake trauma, tiered haptics & flash feedback
        AppHaptics.lineClear(result.linesCleared);
        if (result.comboStreak >= 2) {
          AppHaptics.combo(result.comboStreak);
        }
        final comboCenter = _geometry.gridCenter();
        if (result.linesCleared >= 4 || result.comboStreak >= 6) {
          _shakeController.trigger(intensity: 8.0, trauma: 1.0);
          _particleSystem.spawnExplosion(comboCenter.dx, comboCenter.dy, Colors.white, count: 28);
          _particleSystem.spawnExplosion(comboCenter.dx, comboCenter.dy, shape.baseColor, count: 24);
          if (!SettingsManager.instance.isBatterySaver) {
            _vfx.showScreenFlash(Colors.white, duration: 120);
            _vfx.playConfetti();
          }
        } else if (result.linesCleared >= 2 || result.comboStreak >= 3) {
          _shakeController.trigger(intensity: 5.0, trauma: 0.70);
          _particleSystem.spawnExplosion(comboCenter.dx, comboCenter.dy, shape.baseColor, count: 18);
          _particleSystem.spawnExplosion(comboCenter.dx, comboCenter.dy, Colors.white, count: 10);
          if (!SettingsManager.instance.isBatterySaver) {
            _vfx.showScreenFlash(Colors.white, duration: 60);
          }
          if (result.linesCleared >= 3) _vfx.playConfetti();
        } else if (result.linesCleared == 1) {
          _shakeController.trigger(intensity: 2.8, trauma: 0.35);
          _particleSystem.spawnExplosion(comboCenter.dx, comboCenter.dy, shape.baseColor, count: 12);
        }

        // 3. Milestone Era Check (Earned score progression: Bronze -> Silver -> Gold -> Astral)
        _checkEraProgression(_gridEngine.currentScore);
        _checkGemstoneEvolution(
          isPerfectClear: result.isPerfectClear,
          linesClearedThisMove: result.linesCleared,
        );

        // 4. All-Clear Milestone Check (The ultimate board wipe)
        if (result.isPerfectClear) {
          _vfx.triggerAllClearSurge();
          ProceduralAudio.instance.playPerfectSweep();
          _triggerBoardRealmEvolution(BoardRealm.astralGold);
        } else if (result.linesCleared >= 4) {
          _triggerBoardRealmEvolution(BoardRealm.astralGold);
        } else if (result.linesCleared == 3) {
          _triggerBoardRealmEvolution(BoardRealm.cyberLightning);
        } else if (result.comboStreak >= 6) {
          _triggerBoardRealmEvolution(BoardRealm.amethystVoid);
        }

        // 5. Block Blast Style Juicy Score Badge (Punches up at clear center & glides to HUD)
        Offset scorePos = _geometry.gridCenter();
        if (result.clearedCellDetails.isNotEmpty) {
          double sumX = 0, sumY = 0;
          for (final cell in result.clearedCellDetails) {
            final pt = _geometry.cellCenter(cell.pos.x, cell.pos.y);
            sumX += pt.dx;
            sumY += pt.dy;
          }
          scorePos = Offset(sumX / result.clearedCellDetails.length, sumY / result.clearedCellDetails.length);
        }

        final gridCenter = _geometry.gridCenter();
        _particleSystem.spawnFlyingScore(
          text: "+${result.pointsEarned}",
          startX: scorePos.dx,
          startY: scorePos.dy,
          targetX: gridCenter.dx,
          targetY: -35.0,
          color: _currentWorldTheme.primaryGlow,
          fontSize: result.comboStreak > 2 ? 26.0 : 22.0,
          onArrived: () {
            if (mounted) setState(() {});
          },
        );

        // 6. 🔥 Juicy Iconic Block Blast Arcade Combo Praise, scaling burst & Shimmer Sparks
        if (result.comboStreak >= 2) {
          _particleSystem.spawnComboPraise(gridCenter.dx, gridCenter.dy - 50, result.comboStreak);
          _particleSystem.spawnComboBurst(scorePos.dx, scorePos.dy, shape.baseColor, result.comboStreak);
        }

        // Perfect Board Clear Celebration (Gentle & Ethereal)
        if (result.isPerfectClear) {
          ProceduralAudio.instance.playPerfectSweep();
          _shakeController.trigger(intensity: 3.5);
          final gridCenter = _geometry.gridCenter();
          _particleSystem.spawnExplosion(gridCenter.dx, gridCenter.dy, GameTheme.goldAccent, count: 20);
        }
      } else {
        // Placement points: subtle, gentle in-place float (no clutter)
        final center = cellCenters.isNotEmpty ? cellCenters.first : _geometry.gridCenter();
        _particleSystem.spawnFloatingText(
          "+${result.pointsEarned}",
          center.dx,
          center.dy - 10,
          GameTheme.neonCyan.withValues(alpha: 0.85),
          fontSize: 12,
        );
      }

      _saveStoredData();

      // Track Achievements
      AchievementManager.instance.updateProgress('score_5000', _gridEngine.currentScore, isMax: true);
      AchievementManager.instance.updateProgress('score_10000', _gridEngine.currentScore, isMax: true);
      if (!_hasUsedAegisRescue && _canRevive) {
        AchievementManager.instance.updateProgress('zen_5000', _gridEngine.currentScore, isMax: true);
      }
      if (widget.dailyModifier != null) {
        AchievementManager.instance.updateProgress('blitz_3000', _gridEngine.currentScore, isMax: true);
      }
      if (result.comboStreak >= 3) {
        AchievementManager.instance.updateProgress('first_combo_3', result.comboStreak, isMax: true);
      }
      if (result.linesCleared >= 3) {
        AchievementManager.instance.updateProgress('mega_blast_3_lines', result.linesCleared, isMax: true);
      }
      if (result.goldShardsEarned > 0) {
        AchievementManager.instance.updateProgress('total_shards_2500', result.goldShardsEarned);
      }

      // Combo & Dragon Progression
      if (result.linesCleared > 0) {
        if (result.comboStreak > _feverComboStreak) {
          _feverComboStreak = result.comboStreak;
        }

        final expGained = (result.linesCleared * 8) + (result.comboStreak * 12);
        DragonManager.instance.addDragonExp(expGained);
      }

      // Check Hyperdrive Trigger
      if (result.hyperdriveTriggered) {
        AchievementManager.instance.updateProgress('hyperdrive_frenzy', 1);
        _shakeController.trigger(intensity: 16.0);
        ProceduralAudio.instance.playRewardClaim();
        final gridCenter = _geometry.gridCenter();
        _particleSystem.spawnFloatingText(
          "⚡ HYPERDRIVE FEVER! 2X PUAN! ⚡",
          gridCenter.dx,
          gridCenter.dy - 60,
          GameTheme.goldAccent,
          fontSize: 14,
        );
      }

      // If all 3 slots empty, advance tray cleanly without visual collision
      if (_availableShapes.every((s) => s == null)) {
        if (result.linesCleared > 0) {
          Future.delayed(const Duration(milliseconds: 320), () {
            if (mounted) _onTrayCompleted();
          });
        } else {
          Future.delayed(const Duration(milliseconds: 80), () {
            if (mounted) _onTrayCompleted();
          });
        }
      } else {
        _rescueMidTrayThenCheckGameOver();
      }
    }
  }

  /// After placing one piece, swap any leftover bricks that no longer fit
  /// (as long as the board still accepts catalog pieces) — then check game over.
  void _rescueMidTrayThenCheckGameOver() {
    final slots = List<PolyominoShape?>.from(_availableShapes);
    final rescued = _spawnerEngine.rescueUnplaceableSlots(
      gridEngine: _gridEngine,
      slots: slots,
      forcedPalette: _activePalette,
    );
    if (rescued) {
      setState(() => _availableShapes = slots);
    }
    _checkGameOver();
  }

  void _executeRevive({String? sourceText}) {
    setState(() {
      _canRevive = false;
      _isGameOver = false;
      _isGameOverModalActive = false;
      final cleared = _gridEngine.meltBottomRows(3);
      for (var pt in cleared) {
        final c = _geometry.cellCenter(pt.x, pt.y);
        _particleSystem.spawnExplosion(c.dx, c.dy, const Color(0xFF10B981), count: 18);
      }
      ProceduralAudio.instance.playRewardClaim();
      final center = _geometry.gridCenter();
      _particleSystem.spawnFloatingText(
        sourceText ?? "❤️ İKİNCİ ŞANS! Alt Satırlar Temizlendi!",
        center.dx,
        center.dy - 30,
        const Color(0xFF10B981),
        fontSize: 13,
      );
      _ensureAtLeastOneShapeCanBePlaced();
    });
  }

  void _ensureAtLeastOneShapeCanBePlaced() {
    final remaining = _availableShapes.whereType<PolyominoShape>().toList();
    if (_gridEngine.hasAnyValidMoves(remaining)) return;

    final slots = List<PolyominoShape?>.from(_availableShapes);
    if (_spawnerEngine.rescueUnplaceableSlots(
      gridEngine: _gridEngine,
      slots: slots,
      forcedPalette: _activePalette,
    )) {
      setState(() => _availableShapes = slots);
      return;
    }

    // Legacy domino rescue (isolated 2-cell gaps)
    for (int i = 0; i < _availableShapes.length; i++) {
      if (_availableShapes[i] != null) {
        final horizontalDomino = PolyominoShape(
          id: 'rescue_rune_h_$i',
          name: 'Rescue Rune',
          matrix: const [
            [1, 1],
          ],
          baseColor: GameTheme.emeraldGreen,
        );
        final verticalDomino = PolyominoShape(
          id: 'rescue_rune_v_$i',
          name: 'Rescue Rune',
          matrix: const [
            [1],
            [1],
          ],
          baseColor: GameTheme.emeraldGreen,
        );

        final chosen = _gridEngine.canPlaceShapeAnywhere(horizontalDomino)
            ? horizontalDomino
            : (_gridEngine.canPlaceShapeAnywhere(verticalDomino) ? verticalDomino : null);

        if (chosen != null) {
          setState(() {
            _availableShapes[i] = chosen;
          });
          break;
        }
      }
    }
  }

  void _checkGameOver() {
    if (_isGameOver || _isGameOverModalActive) return;
    final remainingShapes = _availableShapes.whereType<PolyominoShape>().toList();
    if (remainingShapes.isEmpty) return;

    if (!_gridEngine.hasAnyValidMoves(remainingShapes)) {
      // Emergency save (relic/ enchantment/ pet)
      if (_gridEngine.tryEmergencySave(_activeRelics)) {
        _showRescueEffect("🛡️ Acil Kurtarma!", GameTheme.goldAccent);
        _ensureAtLeastOneShapeCanBePlaced();
        return;
      }

      if (_activeDragon.eggType == DragonEggType.earth && !_hasUsedAegisRescue) {
        _hasUsedAegisRescue = true;
        final rescued = _gridEngine.meltBottomRows(2);
        for (var pt in rescued) {
          final center = _geometry.cellCenter(pt.x, pt.y);
          _particleSystem.spawnExplosion(center.dx, center.dy, _activeDragon.themeColor, count: 20);
        }
        _showRescueEffect("🛡️ TAŞ KALKAN KURTARIŞI!", _activeDragon.themeColor);
        _ensureAtLeastOneShapeCanBePlaced();
        return;
      }

      // Layer 3: Revive (final resort)
      if (_canRevive && _gridEngine.currentScore >= GameTuning.minScoreForRevive) {
        _isGameOverModalActive = true;
        GameDialogHelper.showReviveDialog(
          context: context,
          totalSeconds: GameTuning.reviveCountdownSeconds,
          currentScore: _gridEngine.currentScore,
          comboStreak: _gridEngine.comboStreak,
          onWatchAd: () async {
            final watched = await AdService.instance.showRewardedAd();
            if (!mounted) return;
            if (watched) {
              _executeRevive(sourceText: "❤️ İKİNCİ ŞANS! Alt Satırlar Temizlendi!");
            } else {
              _canRevive = false;
              _isGameOverModalActive = false;
              _triggerGameOver();
            }
          },
          onPayGold: () async {
            if (!mounted) return;
            final spent = await ShopManager.instance.spendShards(GameTuning.reviveCostGold);
            if (!spent || !mounted) return;
            _executeRevive(sourceText: "🪙 ${GameTuning.reviveCostGold} ALTINLA CANLANILDI!");
          },
          onTimeoutOrSkip: () {
            _canRevive = false;
            _isGameOverModalActive = false;
            _triggerGameOver();
          },
        );
      } else {
        _triggerGameOver();
      }
    }
  }

  void _showRescueEffect(String text, Color color) {
    ProceduralAudio.instance.playPowerUpUsed();
    final gridCenter = _geometry.gridCenter();
    _particleSystem.spawnFloatingText(text, gridCenter.dx, gridCenter.dy - 30, color, fontSize: 13);
  }

  void _triggerGameOver() async {
    if (_isGameOver) return;
    _particleSystem.clear();
    setState(() {
      _isGameOver = true;
      _isGameOverModalActive = true;
    });
    ProceduralAudio.instance.playGameOver();
    AppHaptics.gameOver();
    final earnedThisRun = _gridEngine.totalGoldShardsEarnedInRun + _dailyBonusShards;
    
    // Increment games played for new player experience
    _gamesPlayed++;
    GameSessionStore.saveGamesPlayed(_gamesPlayed);
    
    _saveStoredData();
    _settleDailyChallenge();

    final isNewRecord = _gridEngine.currentScore == _gridEngine.highScore && _gridEngine.currentScore > 0;

    // Show Interstitial Ad before summary
    await AdService.instance.showInterstitialAd();
    if (!mounted) return;

    if (isNewRecord) {
      GameDialogHelper.showVictoryChestDialog(
        context: context,
        baseReward: 750,
      ).then((_) {
        if (mounted) {
          _showGameOverModal(earnedThisRun, isNewRecord);
        }
      });
    } else {
      _showGameOverModal(earnedThisRun, isNewRecord);
    }
  }

  void _showGameOverModal(int earnedThisRun, bool isNewRecord) async {
    // Award Dragon EXP based on game performance
    DragonManager.instance.awardGameExp(
      linesCleared: _gridEngine.totalLinesCleared,
      score: _gridEngine.currentScore,
      comboStreak: _gridEngine.comboStreak,
    );

    AnalyticsService.instance.logEvent('game_over', {
      'mode': widget.gameMode.name,
      'score': _gridEngine.currentScore,
      'is_new_record': isNewRecord,
    });

    GameDialogHelper.showGameOverDialog(
      context: context,
      finalScore: _gridEngine.currentScore,
      highScore: _gridEngine.highScore,
      linesCleared: _gridEngine.totalLinesCleared,
      shardsEarned: earnedThisRun,
      isNewHighScore: isNewRecord,
      onShareScore: () => _showShareScoreDialog(earnedThisRun),
      onDoubleShards: () async {
        if (earnedThisRun <= 0) return;
        final watched = await AdService.instance.showRewardedAd();
        if (!mounted) return;
        final isTr = LocaleManager.instance.isTurkish;
        if (watched) {
          await ShopManager.instance.addShards(earnedThisRun);
          ProceduralAudio.instance.playRewardClaim();
          if (!mounted) return;
          GameToast.showGold(
            context,
            isTr ? '${earnedThisRun * 2} 🪙 2X Ödül Alındı!' : '${earnedThisRun * 2} 🪙 Reward Doubled!',
            title: '2X ÖDÜL',
          );
        } else {
          GameToast.showError(
            context,
            isTr ? 'Reklam yüklenemedi, tekrar dene.' : 'Ad unavailable, try again.',
          );
        }
      },
      onRestart: () {
        Navigator.of(context).pop();
        _restartGame();
      },
      onMainMenu: () {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      },
    );
  }

  void _showShareScoreDialog(int shards) {
    GameDialogHelper.showShareScoreDialog(
      context: context,
      score: _gridEngine.currentScore,
      highScore: _gridEngine.highScore,
      linesCleared: _gridEngine.totalLinesCleared,
      comboStreak: _gridEngine.comboStreak,
      shards: shards,
    );
  }

  Future<void> _settleDailyChallenge() async {
    if (widget.dailyModifier == null) return;
    final reward = await DailyChallengeManager.instance
        .claimMedalsForScore(_gridEngine.currentScore);
    if (reward > 0 && mounted) {
      final isTr = LocaleManager.instance.isTurkish;
      GameToast.showGold(
        context,
        isTr ? '🏆 Günlük Madalya Ödülü: +$reward 🪙' : '🏆 Daily Medal Reward: +$reward 🪙',
        title: 'MEYDAN OKUMA',
      );
    }
  }

  void _showPauseMenu() {
    GameDialogHelper.showPauseMenu(
      context: context,
      onRestart: _restartGame,
      onQuit: () => Navigator.of(context).pop(),
    );
  }

  void _restartGame() {
    setState(() {
      _currentBlockSkinStyle = BlockThemeManager.instance.activeStyle;
      _gridEngine.reset();
      _activeRelics.clear();
      _isGameOver = false;
      _isGameOverModalActive = false;
      _canRevive = true;
      _hasUsedAegisRescue = false;
      _draggingShape = null;
      _hoverGridPos = null;
      _isHoverValid = false;
      _vfx.recentlyPlacedCells.clear();
      _vfx.placementFlashProgress = 0.0;
      _vfx.resetAllClearCrest();
      _vfx.worldMorphController.value = 1.0;
      _particleSystem.clear();
      _dailyBonusShards = 0;
      _movesCount = 0;
      _currentEra = BoardEra.bronze;
      _currentWorldTheme = ComboRealmTheme.classicJewel;
      _previousWorldTheme = ComboRealmTheme.classicJewel;
      _feverComboStreak = 0;
      _sessionClearedLines = 0;
      _dragonEnergy = 0.0;
      _cachedBackground = _getInGameBackground();
    });
    _spawnNewShapes();
    if (!_vfx.tickerController.isAnimating) {
      _vfx.tickerController.repeat();
    }
  }

  Color get _dominantBoardColor {
    final Map<int, int> colorCounts = {};
    int maxCount = 0;
    Color? dominant;

    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final cell = _gridEngine.grid[r][c];
        if (cell.isOccupied && cell.blockColor != null) {
          final colorVal = cell.blockColor!.toARGB32();
          final count = (colorCounts[colorVal] ?? 0) + 1;
          colorCounts[colorVal] = count;
          if (count > maxCount) {
            maxCount = count;
            dominant = cell.blockColor;
          }
        }
      }
    }

    if (dominant != null) {
      return dominant;
    }

    if (_availableShapes.isNotEmpty && _availableShapes.first != null) {
      return _availableShapes.first!.baseColor;
    }

    return const Color(0xFF2563EB);
  }

  void _onDragHoverMove(DragTargetDetails<PolyominoShape> details) {
    if (_isGameOver) return;
    final RenderBox? renderBox = _gridKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final localPos = renderBox.globalToLocal(details.offset);
    final gridW = renderBox.size.width;
    final cellSize = gridW / 8;
    final shape = details.data;

    // Spawn subtle sparkling drag trail throttled by distance (prevents frame drops during pointer move)
    if ((localPos - _lastDragTrailPos).distance > 24.0) {
      _lastDragTrailPos = localPos;
      _particleSystem.spawnDragTrail(localPos.dx, localPos.dy, shape.baseColor);
    }

    // Generous boundary check
    final bool isInsideGridBounds =
        localPos.dx >= -cellSize && localPos.dx <= gridW + cellSize &&
        localPos.dy >= -cellSize && localPos.dy <= gridW + cellSize;

    if (!isInsideGridBounds) {
      if (_hoverGridPos != null || _isHoverValid) {
        setState(() {
          _hoverGridPos = null;
          _isHoverValid = false;
          _cachedPreviewRows = const [];
          _cachedPreviewCols = const [];
        });
      }
      return;
    }

    // Affedici snap — en yakın hücreye yuvarla (Block Blast hissi)
    final int col = (localPos.dx / cellSize).round().clamp(0, 7);
    final int row = (localPos.dy / cellSize).round().clamp(0, 7);

    final bool isValid = _gridEngine.canPlace(shape, row, col);

    // Değişim yoksa rebuild yapma (120 FPS koruması)
    if (_hoverGridPos?.x == row && _hoverGridPos?.y == col &&
        _isHoverValid == isValid && _draggingShape == shape) {
      return;
    }

    List<int> willClearRows = const [];
    List<int> willClearCols = const [];

    if (isValid) {
      // Subtle tactile snap tick when transitioning to a valid cell
      if (_hoverGridPos?.x != row || _hoverGridPos?.y != col) {
        AppHaptics.selection();
      }
      willClearRows = _gridEngine.getRowsClearedIfPlaced(shape, row, col);
      willClearCols = _gridEngine.getColsClearedIfPlaced(shape, row, col);
      if ((willClearRows.isNotEmpty || willClearCols.isNotEmpty) &&
          (_cachedPreviewRows.isEmpty && _cachedPreviewCols.isEmpty)) {
        AppHaptics.medium();
      }
    }

    setState(() {
      _draggingShape = shape;
      _hoverGridPos = Point(row, col);
      _isHoverValid = isValid;
      _cachedPreviewRows = willClearRows;
      _cachedPreviewCols = willClearCols;
    });
  }

  // Forgiving placement: search nearby cells for a valid spot when the direct
  // drop position is blocked. Expands outward up to radius 2.
  Point<int>? _findNearbyValidPlacement(PolyominoShape shape, int row, int col) {
    for (int radius = 1; radius <= 2; radius++) {
      for (int dr = -radius; dr <= radius; dr++) {
        for (int dc = -radius; dc <= radius; dc++) {
          if (dr == 0 && dc == 0) continue;
          final nr = row + dr;
          final nc = col + dc;
          if (nr >= 0 && nr < 8 && nc >= 0 && nc < 8 &&
              _gridEngine.canPlace(shape, nr, nc)) {
            return Point(nr, nc);
          }
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final screenWidth = media.size.width;
    final screenHeight = media.size.height - media.padding.top - media.padding.bottom;

    // Dynamically calculate gridWidth to guarantee zero vertical or horizontal overflow on all screen sizes
    final nonGridHeight = 330.0;
    final maxGridByHeight = screenHeight - nonGridHeight;
    final maxGridByWidth = screenWidth - 24.0;
    final gridWidth = min(maxGridByWidth, maxGridByHeight).clamp(160.0, 390.0);
    final cellSize = gridWidth / 8;
    final activeSkin = ShopManager.instance.activeSkin;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          _vfx.stopOnPop();
          _saveStoredData();
          ProceduralAudio.instance.pauseBackgroundMusic();
        }
      },
      child: Scaffold(
        backgroundColor: activeSkin.bgDarkColor,
        body: Stack(
          children: [
            // 1. Dynamic In-Game Realm Background (Smoothly morphs with score progression)
            Positioned.fill(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 900),
                switchInCurve: Curves.easeInOutCubic,
                switchOutCurve: Curves.easeInOutCubic,
                child: Image.asset(
                  _getInGameBackground(),
                  key: ValueKey<String>(_getInGameBackground()),
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),

            // 2. Protective Vignette Gradient: Preserves Candy-Gem block contrast & board clarity
            Positioned.fill(
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xF0070C18), // 94% dark at top HUD
                      Color(0xCA060A14), // 79% dark behind grid
                      Color(0xFA04060C), // 98% dark at bottom spawner
                    ],
                    stops: [0.0, 0.44, 1.0],
                  ),
                ),
              ),
            ),

            // 3. Dynamic Board Dominant Color Ambient Lighting Aura
            Positioned.fill(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeInOutCubic,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0.0, -0.05),
                    radius: 0.95,
                    colors: [
                      _dominantBoardColor.withValues(alpha: _gridEngine.isHyperdriveActive ? 0.32 : 0.16),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 1.0],
                  ),
                ),
              ),
            ),

            // 4. Interactive Game Elements & Grid
            SafeArea(
              child: DragTarget<PolyominoShape>(
            onWillAcceptWithDetails: (details) => true,
            onMove: _onDragHoverMove,
            onLeave: (data) {
              setState(() {
                _hoverGridPos = null;
                _isHoverValid = false;
                _cachedPreviewRows = const [];
                _cachedPreviewCols = const [];
              });
            },
            onAcceptWithDetails: (details) {
              final RenderBox? renderBox = _gridKey.currentContext?.findRenderObject() as RenderBox?;
              if (renderBox != null) {
                final localPos = renderBox.globalToLocal(details.offset);
                final gridW = renderBox.size.width;
                final cSize = gridW / 8;

                // Generous forgiving boundary check: Easy placement even on edge cells
                final bool isDroppedOnGrid = localPos.dx >= -cSize * 0.75 && localPos.dx <= gridW + cSize * 0.75 &&
                                             localPos.dy >= -cSize * 0.75 && localPos.dy <= gridW + cSize * 0.75;

                if (isDroppedOnGrid) {
                  // Affedici snap — en yakın hücreye yuvarla
                  final col = (localPos.dx / cSize).round();
                  final row = (localPos.dy / cSize).round();

                  int targetRow = row;
                  int targetCol = col;

                  // Priority 1: Direct calculated grid position
                  if (!_gridEngine.canPlace(details.data, targetRow, targetCol)) {
                    // Priority 2: Currently active hover position
                    if (_hoverGridPos != null && _isHoverValid && _gridEngine.canPlace(details.data, _hoverGridPos!.x, _hoverGridPos!.y)) {
                      targetRow = _hoverGridPos!.x;
                      targetCol = _hoverGridPos!.y;
                    } else {
                      // Priority 3: Search nearby positions (forgiving placement)
                      final found = _findNearbyValidPlacement(details.data, row, col);
                      if (found != null) {
                        targetRow = found.x;
                        targetCol = found.y;
                      }
                    }
                  }

                  bool placed = false;
                  if (targetRow >= 0 && targetRow < 8 && targetCol >= 0 && targetCol < 8 && _gridEngine.canPlace(details.data, targetRow, targetCol)) {
                    int slotIdx = _availableShapes.indexOf(details.data);
                    if (slotIdx == -1) {
                      slotIdx = _availableShapes.indexWhere((s) => s != null && s.id == details.data.id);
                    }
                    if (slotIdx != -1) {
                      placed = true;
                      _onBlockPlaced(details.data, slotIdx, targetRow, targetCol);
                    }
                  }

                  if (!placed) {
                    _particleSystem.spawnInvalidDrop(localPos.dx, localPos.dy);
                    _shakeController.trigger(intensity: 1.2, trauma: 0.12);
                    AppHaptics.light();
                  }
                }
              }
              setState(() {
                _draggingShape = null;
                _hoverGridPos = null;
                _isHoverValid = false;
                _cachedPreviewRows = const [];
                _cachedPreviewCols = const [];
              });
            },
            builder: (context, candidateData, rejectedData) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Mode Indicator Bar (Blitz timer / Zen banner / Boss Rush HP)
                      ModeIndicatorBar(
                        gameMode: widget.gameMode,
                      ),

                      // Top Clean Game HUD
                      RepaintBoundary(
                        child: GameHUD(
                          score: _gridEngine.currentScore,
                          highScore: _gridEngine.highScore,
                          combo: _gridEngine.comboStreak,
                          goldShards: ShopManager.instance.goldShards,
                          onPauseTap: _showPauseMenu,
                          activeDragon: _activeDragon,
                          dragonChargeProgress: (_dragonEnergy / 100.0).clamp(0.0, 1.0),
                          isDragonPowerReady: _isDragonPowerReady,
                          onDragonPowerTap: _activateDragonPower,
                        ),
                      ),

                      // Central 8x8 Grid Canvas
                      GameBoardContainer(
                        gridWidth: gridWidth,
                        shakeController: _shakeController,
                        currentWorldTheme: _currentWorldTheme,
                        previousWorldTheme: _previousWorldTheme,
                        activeSkin: activeSkin,
                        grid: _gridEngine.grid,
                        isHyperdriveActive: _gridEngine.isHyperdriveActive,
                        nearCompleteRows: _gridEngine.nearCompleteRows,
                        nearCompleteCols: _gridEngine.nearCompleteCols,
                        draggingShape: _draggingShape,
                        hoverGridPos: _hoverGridPos,
                        isHoverValid: _isHoverValid,
                        currentBlockSkinStyle: _currentBlockSkinStyle,
                        recentlyPlacedCells: _vfx.recentlyPlacedCells,
                        placementFlashProgress: _vfx.placementFlashProgress,
                        clearingCells: _vfx.clearingCells,
                        clearingLineSlices: _vfx.clearingLineSlices,
                        currentEra: _currentEra,
                        hasAllClearCrest: _vfx.hasAllClearCrest,
                        allClearSurgeProgress: _vfx.allClearSurgeProgress,
                        cachedPreviewRows: _cachedPreviewRows,
                        cachedPreviewCols: _cachedPreviewCols,
                        boardRevealProgress: _vfx.boardRevealProgress,
                        tickerController: _vfx.tickerController,
                        worldMorphController: _vfx.worldMorphController,
                        clearController: _vfx.clearController,
                        particleSystem: _particleSystem,
                        screenFlashColor: _vfx.screenFlashColor,
                        screenFlashController: _vfx.screenFlashController,
                        gridKey: _gridKey,
                      ),

                      // Bottom 3-Block Invisible Full-Height Touch Columns
                      Expanded(
                        child: RepaintBoundary(
                          child: BlockSpawnerBar(
                            shapes: _availableShapes,
                            screenWidth: screenWidth,
                            gridWidth: gridWidth,
                            cellSize: cellSize,
                            gridBorderColor: activeSkin.gridBorderColor,
                            primaryGlow: activeSkin.primaryGlow,
                            blockSkinStyle: _currentBlockSkinStyle,
                            onDragStarted: (shape) {
                              AppHaptics.blockPickup();
                              setState(() => _draggingShape = shape);
                            },
                            onDragEnd: () {
                              setState(() {
                                _draggingShape = null;
                                _hoverGridPos = null;
                                _isHoverValid = false;
                                _cachedPreviewRows = const [];
                                _cachedPreviewCols = const [];
                              });
                            },
                            onRotateSlot: _rotateSlot,
                          ),
                        ),
                      ),
                    ],
                  ),

                  Positioned.fill(
                    child: GameFxOverlay(
                      stingerText: _vfx.stingerText,
                      stingerColor: _vfx.stingerColor,
                      stingerTop: screenHeight * 0.40,
                      confettiController: _vfx.confettiController,
                    ),
                  ),
                ],
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

