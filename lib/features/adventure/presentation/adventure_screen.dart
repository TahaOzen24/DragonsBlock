import 'dart:math';
import '../../../core/haptics/haptic_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/audio/procedural_audio.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/localization/locale_manager.dart';
import '../../../core/particles/particle_system.dart';
import '../../../core/theme/game_theme.dart';
import '../../../core/vfx/screen_shake.dart';
import '../../game/logic/grid_engine.dart';
import '../../game/logic/shape_spawner_engine.dart';
import '../../game/models/polyomino_shape.dart';
import '../../game/models/relic.dart';
import '../../game/presentation/painters/grid_painter.dart';
import '../../game/presentation/painters/particle_painter.dart';
import '../../game/presentation/widgets/block_preview_widget.dart';
import '../models/adventure_level.dart';
import '../models/boss.dart';
import '../services/adventure_level_manager.dart';
import '../../rewards/presentation/victory_chest_dialog.dart';
import '../../block_themes/services/block_theme_manager.dart';
import '../../shop/services/shop_manager.dart';
import '../../game/presentation/painters/stat_bar_vector_icons.dart';
import '../../game/presentation/widgets/pause_menu_dialog.dart';

class AdventureScreen extends StatefulWidget {
  final AdventureLevel level;

  const AdventureScreen({super.key, required this.level});

  @override
  State<AdventureScreen> createState() => _AdventureScreenState();
}

class _AdventureScreenState extends State<AdventureScreen> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final GridEngine _gridEngine;
  late final ParticleSystem _particleSystem;
  late final AnimationController _tickerController;
  final ScreenShakeController _shakeController = ScreenShakeController();
  final ShapeSpawnerEngine _spawnerEngine = ShapeSpawnerEngine();

  List<PolyominoShape?> _availableShapes = [null, null, null];
  final List<Relic> _activeRelics = [];
  
  late int _movesLeft;
  late int _currentScore;
  late int _iceRemaining;
  int _linesCleared = 0;

  // Boss Battle state
  late int _bossHp;
  late int _turnsUntilBossAttack;
  bool _isBossEnraged = false;
  bool _isFinished = false;
  bool _hasUsedReroll = false;
  bool _hasUsedSoftlockRescue = false;

  PolyominoShape? _draggingShape;
  Point<int>? _hoverGridPos;
  bool _isHoverValid = false;
  List<Point<int>> _recentlyPlacedCells = [];
  double _placementFlashProgress = 0.0;
  final GlobalKey _gridKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _gridEngine = GridEngine();
    _particleSystem = ParticleSystem();

    _movesLeft = widget.level.maxMoves;
    _currentScore = 0;
    _iceRemaining = widget.level.initialIceCells.length;
    _linesCleared = 0;

    if (widget.level.boss != null) {
      _bossHp = widget.level.boss!.maxHp;
      _turnsUntilBossAttack = widget.level.boss!.attackInterval;
    }

    _setupInitialGrid();
    _spawnNewShapes();

    _tickerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(() {
        _particleSystem.update();
        if (_placementFlashProgress > 0) {
          _placementFlashProgress = (_placementFlashProgress - 0.05).clamp(0.0, 1.0);
        }
        setState(() {});
      });
    _tickerController.repeat();
  }

  void _setupInitialGrid() {
    if (widget.level.initialIceCells.isNotEmpty) {
      for (final pt in widget.level.initialIceCells) {
        if (pt.x >= 0 && pt.x < 8 && pt.y >= 0 && pt.y < 8) {
          _gridEngine.grid[pt.x][pt.y].occupy(
            color: GameTheme.frostCyan,
          );
          _gridEngine.grid[pt.x][pt.y].frozenTurns = 999;
        }
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      _tickerController.stop();
      ProceduralAudio.instance.handleAppLifecycle(state);
    } else if (state == AppLifecycleState.resumed) {
      ProceduralAudio.instance.handleAppLifecycle(state);
      if (!_isFinished) {
        _tickerController.repeat();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tickerController.dispose();
    super.dispose();
  }

  int _countIceCellsOnBoard() {
    int n = 0;
    for (int r = 0; r < GridEngine.gridSize; r++) {
      for (int c = 0; c < GridEngine.gridSize; c++) {
        if (_gridEngine.grid[r][c].frozenTurns >= 999) n++;
      }
    }
    return n;
  }

  void _spawnNewShapes() {
    final newHand = _spawnerEngine.generateBalancedHand(
      gridEngine: _gridEngine,
      currentScore: _currentScore,
      movesCount: widget.level.maxMoves - _movesLeft,
      forcedPalette: BlockThemeManager.instance.activePalette,
    );

    setState(() {
      _availableShapes = List<PolyominoShape?>.from(newHand);
    });

    final slots = List<PolyominoShape?>.from(_availableShapes);
    if (_spawnerEngine.rescueUnplaceableSlots(
      gridEngine: _gridEngine,
      slots: slots,
      forcedPalette: BlockThemeManager.instance.activePalette,
    )) {
      setState(() => _availableShapes = slots);
    }

    _checkBattleStatus();
  }

  void _rerollHand() {
    if (_hasUsedReroll || _isFinished) return;
    AppHaptics.medium();
    ProceduralAudio.instance.playPowerUpUsed();

    final newHand = _spawnerEngine.generateBalancedHand(
      gridEngine: _gridEngine,
      currentScore: _currentScore,
      movesCount: widget.level.maxMoves - _movesLeft,
      forcedPalette: BlockThemeManager.instance.activePalette,
    );

    setState(() {
      _availableShapes = List<PolyominoShape?>.from(newHand);
      _hasUsedReroll = true;
    });

    final gridCenter = _getGridCenter();
    _particleSystem.spawnFloatingText("🎲 EL YENİLENDİ!", gridCenter.dx, gridCenter.dy, GameTheme.neonCyan, fontSize: 24);
  }

  void _onBlockPlaced(PolyominoShape shape, int slotIndex, int row, int col) {
    ProceduralAudio.instance.playPlace();
    AppHaptics.medium();

    final result = _gridEngine.placeShape(shape, row, col, _activeRelics);

    if (result.success) {
      final List<Point<int>> placedPoints = [];
      final List<Offset> cellCenters = [];
      for (int r = 0; r < shape.rowCount; r++) {
        for (int c = 0; c < shape.colCount; c++) {
          if (shape.matrix[r][c] == 1) {
            placedPoints.add(Point(row + r, col + c));
            cellCenters.add(_getCellGlobalCenter(row + r, col + c));
          }
        }
      }

      setState(() {
        _availableShapes[slotIndex] = null;
        _movesLeft--;
        _currentScore += result.pointsEarned;
        _recentlyPlacedCells = placedPoints;
        _placementFlashProgress = 1.0;
        if (widget.level.boss != null) {
          _turnsUntilBossAttack--;
          if (_turnsUntilBossAttack <= 0) {
            _triggerBossAttack(widget.level.boss!);
          }
        }
      });

      if (result.goldShardsEarned > 0) {
        ShopManager.instance.addShards(result.goldShardsEarned);
      }

      _particleSystem.spawnPlacementImpact(cellCenters, shape.baseColor);

      // Ice progress: recount permanent frost cells still on board
      if (widget.level.objectiveType == ObjectiveType.shatterIce) {
        setState(() {
          _iceRemaining = _countIceCellsOnBoard();
        });
      }

      // Check lines cleared
      if ((widget.level.objectiveType == ObjectiveType.clearLines ||
              widget.level.objectiveType == ObjectiveType.treasureChest) &&
          result.linesCleared > 0) {
        setState(() {
          _linesCleared += result.linesCleared;
        });
      }

      // Bonus Move reward on Multi-Line Clear (2+) or Combo Streak (2+)
      if (result.linesCleared >= 2 || result.comboStreak >= 2) {
        setState(() {
          _movesLeft++;
        });
        final gridCenter = _getGridCenter();
        _particleSystem.spawnFloatingText(
          "⚡ +1 HAMLE!",
          gridCenter.dx,
          gridCenter.dy - 65,
          GameTheme.goldAccent,
          fontSize: 26,
        );
      }

      // Handle Line Clears & Damage / Score
      if (result.linesCleared > 0) {
        ProceduralAudio.instance.playComboTone(result.comboStreak);
        AppHaptics.heavy();

        if (widget.level.boss != null) {
          final boss = widget.level.boss!;
          int damage = (result.linesCleared * 650) +
              (result.comboStreak * 350) +
              (result.elementalBlastCells.length * 200);

          if (result.isPerfectClear) {
            damage += 2500;
            ProceduralAudio.instance.playPerfectSweep();
            _shakeController.trigger(intensity: 14.0);
          } else if (result.linesCleared >= 2 || result.comboStreak >= 2) {
            _shakeController.trigger(intensity: 7.0);
          }

          setState(() {
            _bossHp = max(0, _bossHp - damage);
          });

          // Check Enraged Phase trigger (< 50% HP)
          if (!_isBossEnraged && _bossHp > 0 && _bossHp <= (boss.maxHp * 0.50)) {
            _isBossEnraged = true;
            _shakeController.trigger(intensity: 16.0);
            ProceduralAudio.instance.playExplosion();
            final gridCenter = _getGridCenter();
            _particleSystem.spawnFloatingText(
              "⚠️ ${boss.name} ENRAGED! ⚠️",
              gridCenter.dx,
              gridCenter.dy - 60,
              GameTheme.fireOrange,
              fontSize: 28,
            );
          }

          // Damage floating text
          final gridCenter = _getGridCenter();
          if (result.comboStreak > 1) {
            _particleSystem.spawnComboPraise(gridCenter.dx, gridCenter.dy - 50, result.comboStreak);
            _particleSystem.spawnFloatingText(
              "💥 -$damage CRIT!",
              gridCenter.dx,
              gridCenter.dy,
              GameTheme.fireOrange,
              fontSize: 26,
            );
          } else {
            _particleSystem.spawnFloatingText(
              "💥 -$damage DMG",
              gridCenter.dx,
              gridCenter.dy - 40,
              GameTheme.neonCyan,
              fontSize: 24,
            );
          }
        }

        for (var cell in result.clearedCells) {
          final center = _getCellGlobalCenter(cell.x, cell.y);
          _particleSystem.spawnBlockShatter(
            center.dx,
            center.dy,
            widget.level.boss?.themeColor ?? shape.baseColor,
            style: BlockThemeManager.instance.activeStyle,
          );
        }
      }

      if (_availableShapes.every((s) => s == null)) {
        _spawnNewShapes();
      } else {
        _checkBattleStatus();
      }
    }
  }

  void _triggerBossAttack(Boss boss) {
    _shakeController.trigger(intensity: _isBossEnraged ? 15.0 : 10.0);
    final rng = Random();

    setState(() {
      _turnsUntilBossAttack = _isBossEnraged ? boss.enragedAttackInterval : boss.attackInterval;

      switch (boss.bossType) {
        case 'fire':
          final count = _isBossEnraged ? 3 : 2;
          List<Point<int>> emptyCells = [];
          for (int r = 0; r < 8; r++) {
            for (int c = 0; c < 8; c++) {
              if (!_gridEngine.grid[r][c].isOccupied) emptyCells.add(Point(r, c));
            }
          }
          emptyCells.shuffle(rng);
          for (int i = 0; i < min(count, emptyCells.length); i++) {
            final pt = emptyCells[i];
            _gridEngine.grid[pt.x][pt.y].occupy(
              color: GameTheme.fireOrange,
            );
            final center = _getCellGlobalCenter(pt.x, pt.y);
            _particleSystem.spawnExplosion(center.dx, center.dy, GameTheme.fireOrange, count: 20);
          }
          ProceduralAudio.instance.playExplosion();
          break;

        case 'frost':
          final count = _isBossEnraged ? 4 : 2;
          List<Point<int>> occupiedCells = [];
          for (int r = 0; r < 8; r++) {
            for (int c = 0; c < 8; c++) {
              if (_gridEngine.grid[r][c].isOccupied) occupiedCells.add(Point(r, c));
            }
          }
          if (occupiedCells.isNotEmpty) {
            occupiedCells.shuffle(rng);
            for (int i = 0; i < min(count, occupiedCells.length); i++) {
              final pt = occupiedCells[i];
              _gridEngine.grid[pt.x][pt.y].frozenTurns = _isBossEnraged ? 3 : 2;
              final center = _getCellGlobalCenter(pt.x, pt.y);
              _particleSystem.spawnLineClearParticles(center.dx, center.dy, GameTheme.frostCyan, count: 12);
            }
          }
          ProceduralAudio.instance.playFrost();
          break;

        case 'lightning':
          final targetRow = rng.nextInt(8);
          for (int c = 0; c < 8; c++) {
            _gridEngine.grid[targetRow][c].occupy(
              color: GameTheme.lightningYellow,
            );
            final center = _getCellGlobalCenter(targetRow, c);
            _particleSystem.spawnComboSparks(center.dx, center.dy, 2);
          }
          if (_isBossEnraged) {
            final targetCol = rng.nextInt(8);
            for (int r = 0; r < 8; r++) {
              _gridEngine.grid[r][targetCol].occupy(
                color: GameTheme.lightningYellow,
              );
            }
          }
          ProceduralAudio.instance.playLightning();
          break;

        case 'void':
          int startR = rng.nextInt(7);
          int startC = rng.nextInt(7);
          for (int dr = 0; dr < 2; dr++) {
            for (int dc = 0; dc < 2; dc++) {
              final r = startR + dr;
              final c = startC + dc;
              _gridEngine.grid[r][c].occupy(
                color: GameTheme.voidPurple,
              );
              final center = _getCellGlobalCenter(r, c);
              _particleSystem.spawnExplosion(center.dx, center.dy, GameTheme.voidPurple, count: 16);
            }
          }
          ProceduralAudio.instance.playVoid();
          break;
      }
    });
  }

  void _checkBattleStatus() {
    if (_isFinished) return;

    final remainingShapes = _availableShapes.whereType<PolyominoShape>().toList();
    var handBlocked =
        remainingShapes.isNotEmpty && !_gridEngine.hasAnyValidMoves(remainingShapes);

    // Softlock rescue once per run before declaring defeat
    if (handBlocked &&
        !_hasUsedSoftlockRescue &&
        _spawnerEngine.boardHasAnyLegalCatalogMove(_gridEngine)) {
      _hasUsedSoftlockRescue = true;
      final slots = List<PolyominoShape?>.from(_availableShapes);
      final rescued = _spawnerEngine.rescueUnplaceableSlots(
        gridEngine: _gridEngine,
        slots: slots,
        forcedPalette: BlockThemeManager.instance.activePalette,
      );
      if (rescued) {
        setState(() => _availableShapes = slots);
        handBlocked = false;
        final gridCenter = _getGridCenter();
        _particleSystem.spawnFloatingText(
          '🛡️ KURTARMA BLOĞU!',
          gridCenter.dx,
          gridCenter.dy - 40,
          GameTheme.emeraldGreen,
          fontSize: 22,
        );
      }
    }

    final run = AdventureRunState(
      score: _currentScore,
      movesLeft: _movesLeft,
      maxMoves: widget.level.maxMoves,
      iceRemaining: _iceRemaining,
      linesCleared: _linesCleared,
      bossHp: widget.level.boss != null ? _bossHp : 1,
      handBlocked: handBlocked,
      outOfMoves: _movesLeft <= 0,
    );

    final outcome = AdventureLevelManager.instance.evaluate(widget.level, run);

    if (outcome.kind == AdventureOutcomeKind.victory) {
      _isFinished = true;
      ProceduralAudio.instance.playPerfectSweep();
      _finalizeVictory();
      return;
    }

    if (outcome.kind == AdventureOutcomeKind.defeat) {
      _isFinished = true;
      ProceduralAudio.instance.playGameOver();
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => _buildDefeatDialog(
          outcome.defeatReasonKey == 'moves' ? AppStrings.movesRanOut : AppStrings.boardFull,
        ),
      );
    }
  }

  Future<void> _finalizeVictory() async {
    final committed = await AdventureLevelManager.instance.commitVictory(
      level: widget.level,
      movesLeft: _movesLeft,
    );
    if (!mounted) return;

    final stars = committed.stars;
    final totalReward = committed.rewardShards;

    if (widget.level.boss != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => VictoryChestDialog(
          title: AppStrings.bossDefeated(widget.level.boss!.name),
          subtitle: AppStrings.bossVictorySubtitle,
          baseReward: 1000,
        ),
      ).then((_) {
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => _buildVictoryDialog(stars, totalReward),
          );
        }
      });
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _buildVictoryDialog(stars, totalReward),
    );
  }

  void _showPauseMenu() {
    AppHaptics.light();
    ProceduralAudio.instance.playDialogPop();
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => PauseMenuDialog(
        onRestart: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => AdventureScreen(level: widget.level),
            ),
          );
        },
        onQuit: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Offset _getCellGlobalCenter(int r, int c) {
    final RenderBox? renderBox = _gridKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final size = renderBox.size;
      final cellSize = size.width / 8;
      return Offset(c * cellSize + cellSize / 2, r * cellSize + cellSize / 2);
    }
    return const Offset(150, 150);
  }

  Offset _getGridCenter() {
    final RenderBox? renderBox = _gridKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      return Offset(renderBox.size.width / 2, renderBox.size.height / 2);
    }
    return const Offset(160, 160);
  }

  void _onDragHoverMove(DragTargetDetails<PolyominoShape> details) {
    if (_isFinished) return;
    final RenderBox? renderBox = _gridKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final localPos = renderBox.globalToLocal(details.offset);
    final gridW = renderBox.size.width;
    final cellSize = gridW / 8;
    final shape = details.data;

    final bool isInsideGridBounds = localPos.dx >= -cellSize * 0.4 && localPos.dx <= gridW + cellSize * 0.4 &&
                                    localPos.dy >= -cellSize * 0.4 && localPos.dy <= gridW + cellSize * 0.4;

    if (!isInsideGridBounds) {
      if (_hoverGridPos != null || _isHoverValid) {
        setState(() {
          _hoverGridPos = null;
          _isHoverValid = false;
        });
      }
      return;
    }

    final col = (localPos.dx / cellSize).round();
    final row = (localPos.dy / cellSize).round();

    final bool isValid = row >= 0 && row < 8 && col >= 0 && col < 8 && _gridEngine.canPlace(shape, row, col);

    if (_hoverGridPos?.x == row && _hoverGridPos?.y == col && _isHoverValid == isValid && _draggingShape == shape) {
      return;
    }

    if ((_hoverGridPos == null || _hoverGridPos!.x != row || _hoverGridPos!.y != col) && isValid) {
      AppHaptics.selection();
    }

    final pieceCenterX = localPos.dx + (shape.colCount * cellSize) / 2;
    final pieceCenterY = localPos.dy + (shape.rowCount * cellSize) / 2;
    _particleSystem.spawnDragTrail(pieceCenterX, pieceCenterY, shape.baseColor);

    setState(() {
      _draggingShape = shape;
      _hoverGridPos = Point(row, col);
      _isHoverValid = isValid;
    });
  }

  Widget _buildVictoryDialog(int stars, int reward) {
    final nextLevelIndex = widget.level.levelIndex + 1;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
        decoration: BoxDecoration(
          color: const Color(0xFF070E20).withValues(alpha: 0.98),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: const Color(0xFFFBBF24).withValues(alpha: 0.85),
            width: 1.8,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
              blurRadius: 30,
              spreadRadius: 2,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.65),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Glowing Trophy Emblem
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF59E0B), Color(0xFFB45309)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  border: Border.all(color: const Color(0xFFFDE047), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
                      blurRadius: 18,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.emoji_events_rounded, color: Colors.white, size: 36),
                ),
              ).animate().scale(curve: Curves.elasticOut, duration: 600.ms),

              const SizedBox(height: 14),

              // Title
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Colors.white, Color(0xFFFDE047), Color(0xFFF59E0B)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ).createShader(bounds),
                child: const Text(
                  'BÖLÜM GEÇİLDİ!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                  ),
                ),
              ),

              const SizedBox(height: 4),
              Text(
                AppStrings.levelCompleted(widget.level.title),
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // 3 Stars Animated
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) {
                  final filled = i < stars;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Icon(
                      filled ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: filled ? const Color(0xFFFBBF24) : Colors.white24,
                      size: 42,
                    ).animate(delay: (i * 150).ms).scale(
                          begin: const Offset(0.2, 0.2),
                          end: const Offset(1.0, 1.0),
                          curve: Curves.elasticOut,
                          duration: 500.ms,
                        ),
                  );
                }),
              ),

              const SizedBox(height: 18),

              // Rewards Box with Pure Vector Coin
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F1A34),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const VectorCoinIcon(size: 24),
                    const SizedBox(width: 8),
                    Text(
                      '+$reward Altın Kazanıldı',
                      style: const TextStyle(
                        color: Color(0xFFFDE047),
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // Primary Button: Sonraki Bölüm
              Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                  ),
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.45),
                      blurRadius: 14,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(26),
                    onTap: () {
                      AppHaptics.medium();
                      ProceduralAudio.instance.playButtonClick();
                      Navigator.of(context).pop();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => AdventureScreen(
                            level: AdventureLevel.getLevel(nextLevelIndex),
                          ),
                        ),
                      );
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 22),
                        SizedBox(width: 8),
                        Text(
                          'SONRAKİ BÖLÜM',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Secondary Button: Haritaya Dön
              Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF0B1429),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFF1E3A8A).withValues(alpha: 0.85),
                    width: 1.3,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () {
                      AppHaptics.light();
                      ProceduralAudio.instance.playButtonClick();
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    child: const Center(
                      child: Text(
                        'HARİTAYA DÖN',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefeatDialog(String reason) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
        decoration: BoxDecoration(
          color: const Color(0xFF12070A).withValues(alpha: 0.98),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: const Color(0xFFEF4444).withValues(alpha: 0.8),
            width: 1.8,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFEF4444).withValues(alpha: 0.35),
              blurRadius: 28,
              spreadRadius: 2,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.65),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Skull Emblem
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEF4444), Color(0xFF991B1B)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  border: Border.all(color: const Color(0xFFFCA5A5), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.5),
                      blurRadius: 18,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.heart_broken_rounded, color: Colors.white, size: 34),
                ),
              ).animate().shake(duration: 500.ms),

              const SizedBox(height: 14),

              const Text(
                'BÖLÜM BAŞARISIZ',
                style: TextStyle(
                  color: Color(0xFFEF4444),
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                ),
              ),

              const SizedBox(height: 6),
              Text(
                reason,
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 22),

              // Retry Button
              Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                  ),
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.45),
                      blurRadius: 14,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(26),
                    onTap: () {
                      AppHaptics.medium();
                      ProceduralAudio.instance.playButtonClick();
                      Navigator.of(context).pop();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => AdventureScreen(level: widget.level),
                        ),
                      );
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.replay_rounded, color: Colors.white, size: 22),
                        SizedBox(width: 8),
                        Text(
                          'TEKRAR DENE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Return to Map
              Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF180A0E),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFF7F1D1D).withValues(alpha: 0.85),
                    width: 1.3,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () {
                      AppHaptics.light();
                      ProceduralAudio.instance.playButtonClick();
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    child: const Center(
                      child: Text(
                        'HARİTAYA DÖN',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final screenWidth = media.size.width;
    final screenHeight = media.size.height - media.padding.top - media.padding.bottom;

    final bool hasBoss = widget.level.boss != null;
    final headerEstimate = hasBoss ? 142.0 : 96.0;
    final nonGridHeight = headerEstimate + 172.0;

    final maxGridByHeight = screenHeight - nonGridHeight;
    final maxGridByWidth = screenWidth - 24.0;
    final gridWidth = min(maxGridByWidth, maxGridByHeight).clamp(160.0, 380.0);
    final cellSize = gridWidth / 8;

    final boss = widget.level.boss;
    final Color levelColor = boss?.themeColor ?? GameTheme.neonCyan;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          _tickerController.stop();
          ProceduralAudio.instance.pauseBackgroundMusic();
        }
      },
      child: Scaffold(
      backgroundColor: GameTheme.bgDarkest,
      body: SafeArea(
        child: DragTarget<PolyominoShape>(
          onWillAcceptWithDetails: (details) => true,
          onMove: _onDragHoverMove,
          onLeave: (data) {
            setState(() {
              _hoverGridPos = null;
              _isHoverValid = false;
            });
          },
          onAcceptWithDetails: (details) {
            final RenderBox? renderBox = _gridKey.currentContext?.findRenderObject() as RenderBox?;
            if (renderBox != null) {
              final localPos = renderBox.globalToLocal(details.offset);
              final gridW = renderBox.size.width;
              final cSize = gridW / 8;

              final bool isDroppedOnGrid = localPos.dx >= -cSize * 0.75 && localPos.dx <= gridW + cSize * 0.75 &&
                                           localPos.dy >= -cSize * 0.75 && localPos.dy <= gridW + cSize * 0.75;

              if (isDroppedOnGrid) {
                final col = (localPos.dx / cSize).round();
                final row = (localPos.dy / cSize).round();
                int targetRow = row;
                int targetCol = col;
                if (!_gridEngine.canPlace(details.data, targetRow, targetCol) &&
                    _hoverGridPos != null &&
                    _isHoverValid &&
                    _gridEngine.canPlace(details.data, _hoverGridPos!.x, _hoverGridPos!.y)) {
                  targetRow = _hoverGridPos!.x;
                  targetCol = _hoverGridPos!.y;
                }
                if (targetRow >= 0 && targetRow < 8 && targetCol >= 0 && targetCol < 8 && _gridEngine.canPlace(details.data, targetRow, targetCol)) {
                  int slotIdx = _availableShapes.indexOf(details.data);
                  if (slotIdx == -1) slotIdx = _availableShapes.indexWhere((s) => s != null && s.id == details.data.id);
                  if (slotIdx != -1) _onBlockPlaced(details.data, slotIdx, targetRow, targetCol);
                }
              }
            }
            setState(() {
              _draggingShape = null;
              _hoverGridPos = null;
              _isHoverValid = false;
            });
          },
          builder: (context, candidateData, rejectedData) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: GameTheme.bgSurface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _isBossEnraged ? GameTheme.fireOrange : levelColor.withValues(alpha: 0.5),
                        width: _isBossEnraged ? 2.0 : 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _isBossEnraged ? GameTheme.fireOrange.withValues(alpha: 0.4) : levelColor.withValues(alpha: 0.2),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Text(boss != null ? boss.avatar : '🎯', style: const TextStyle(fontSize: 22)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.level.title,
                                          style: GameTheme.titleLarge.copyWith(fontSize: 15, color: levelColor),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          AppStrings.levelLabel(widget.level.levelIndex),
                                          style: GameTheme.bodyMedium.copyWith(fontSize: 11),
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
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _movesLeft <= 3 ? GameTheme.fireOrange.withValues(alpha: 0.3) : GameTheme.bgDarkest,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: _movesLeft <= 3 ? GameTheme.fireOrange : GameTheme.gridBorder),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.touch_app_rounded, size: 14, color: Colors.white70),
                                      const SizedBox(width: 4),
                                      Text(
                                        '$_movesLeft Hamle',
                                        style: TextStyle(
                                          color: _movesLeft <= 3 ? GameTheme.fireOrange : Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),
                                InkWell(
                                  onTap: _showPauseMenu,
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: GameTheme.bgDarkest,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: levelColor.withValues(alpha: 0.6),
                                        width: 1.2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: levelColor.withValues(alpha: 0.25),
                                          blurRadius: 6,
                                        ),
                                      ],
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.settings_rounded,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (boss != null) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text('Boss HP', style: GameTheme.bodyMedium.copyWith(fontSize: 11)),
                                  if (_isBossEnraged) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                      decoration: BoxDecoration(color: GameTheme.fireOrange, borderRadius: BorderRadius.circular(6)),
                                      child: const Text('ENRAGED 🔥', style: TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ],
                              ),
                              Text('$_bossHp / ${boss.maxHp}', style: TextStyle(color: _isBossEnraged ? GameTheme.fireOrange : boss.themeColor, fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: (_bossHp / boss.maxHp).clamp(0.0, 1.0),
                              backgroundColor: GameTheme.gridBorder,
                              valueColor: AlwaysStoppedAnimation<Color>(_isBossEnraged ? GameTheme.fireOrange : boss.themeColor),
                              minHeight: 8,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(AppStrings.counterAttack, style: GameTheme.bodyMedium.copyWith(fontSize: 11)),
                              Text(AppStrings.placementsUntilAttack(_turnsUntilBossAttack), style: TextStyle(color: _turnsUntilBossAttack == 1 ? GameTheme.fireOrange : boss.themeColor, fontWeight: FontWeight.bold, fontSize: 11)),
                            ],
                          ),
                        ] else ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: GameTheme.bgDarkest,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: levelColor.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  widget.level.objectiveType == ObjectiveType.shatterIce
                                      ? AppStrings.frozenBlocksLeft
                                      : (widget.level.objectiveType == ObjectiveType.treasureChest
                                          ? 'Hazine Sandığı Hatları'
                                          : (widget.level.objectiveType == ObjectiveType.clearLines
                                              ? 'Temizlenen Hatlar'
                                              : AppStrings.targetScore)),
                                  style: GameTheme.bodyMedium.copyWith(fontSize: 12),
                                ),
                                Text(
                                  widget.level.objectiveType == ObjectiveType.shatterIce
                                      ? '$_iceRemaining Adet'
                                      : (widget.level.objectiveType == ObjectiveType.treasureChest || widget.level.objectiveType == ObjectiveType.clearLines
                                          ? '$_linesCleared / ${widget.level.targetLineCount}'
                                          : '$_currentScore / ${widget.level.targetScore}'),
                                  style: TextStyle(color: levelColor, fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                ScreenShakeWidget(
                  controller: _shakeController,
                  child: Center(
                    child: Container(
                      width: gridWidth,
                      height: gridWidth,
                      decoration: BoxDecoration(
                        color: GameTheme.gridEmptyCell,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _isBossEnraged ? GameTheme.fireOrange : levelColor.withValues(alpha: 0.6), width: 2),
                        boxShadow: [BoxShadow(color: levelColor.withValues(alpha: 0.2), blurRadius: 20, spreadRadius: 2)],
                      ),
                      child: Stack(
                        key: _gridKey,
                        children: [
                          CustomPaint(
                            size: Size(gridWidth, gridWidth),
                            painter: GridPainter(
                              grid: _gridEngine.grid,
                              draggingShape: _draggingShape,
                              previewHoverPos: _hoverGridPos,
                              isPreviewValid: _isHoverValid,
                              animationProgress: _tickerController.value,
                              recentPlacements: _recentlyPlacedCells,
                              placementFlash: _placementFlashProgress,
                            ),
                          ),
                          CustomPaint(size: Size(gridWidth, gridWidth), painter: ParticlePainter(particleSystem: _particleSystem)),
                        ],
                      ),
                    ),
                  ),
                ),
                // Free Reroll helper pill
                Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 2),
                  child: InkWell(
                    onTap: !_hasUsedReroll && !_isFinished ? _rerollHand : null,
                    borderRadius: BorderRadius.circular(16),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                      decoration: BoxDecoration(
                        color: !_hasUsedReroll ? GameTheme.goldAccent.withValues(alpha: 0.16) : Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: !_hasUsedReroll ? GameTheme.goldAccent.withValues(alpha: 0.8) : Colors.white24,
                          width: 1.2,
                        ),
                        boxShadow: !_hasUsedReroll
                            ? [BoxShadow(color: GameTheme.goldAccent.withValues(alpha: 0.25), blurRadius: 8)]
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.casino_rounded, size: 15, color: !_hasUsedReroll ? GameTheme.goldAccent : Colors.white38),
                          const SizedBox(width: 5),
                          Text(
                            !_hasUsedReroll ? 'ELİ YENİLE (1/1)' : 'YENİLENDİ (0/1)',
                            style: TextStyle(
                              color: !_hasUsedReroll ? GameTheme.goldAccent : Colors.white38,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: GameTheme.bgSurface.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: levelColor.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(3, (index) {
                      final shape = _availableShapes[index];
                      return SizedBox(
                        width: (gridWidth - 64) / 3,
                        height: 85,
                        child: Center(
                          child: shape != null
                              ? BlockPreviewWidget(
                                  shape: shape,
                                  previewBlockSize: 18.0,
                                  dragBlockSize: cellSize,
                                  onDragStarted: () {
                                    AppHaptics.light();
                                    setState(() {
                                      _draggingShape = shape;
                                    });
                                  },
                                  onDragEnd: () {
                                    setState(() {
                                      _draggingShape = null;
                                      _hoverGridPos = null;
                                      _isHoverValid = false;
                                    });
                                  },
                                )
                              : const SizedBox.shrink(),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 6),
              ],
            );
          },
        ),
      ),
    ),
  );
}
}
