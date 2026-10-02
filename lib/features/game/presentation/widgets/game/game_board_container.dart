import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../../core/particles/particle_system.dart';
import '../../../../../core/vfx/screen_shake.dart';
import '../../../../shop/models/board_skin.dart';
import '../../../models/block_skin_style.dart';
import '../../../models/board_era.dart';
import '../../../models/clearing_animation.dart';
import '../../../models/combo_realm_theme.dart';
import '../../../models/grid_cell.dart';
import '../../../models/polyomino_shape.dart';
import '../../painters/grid_painter.dart';
import '../../painters/particle_painter.dart';

class GameBoardContainer extends StatelessWidget {
  final double gridWidth;
  final ScreenShakeController shakeController;
  final ComboRealmTheme currentWorldTheme;
  final ComboRealmTheme previousWorldTheme;
  final BoardSkin activeSkin;
  final List<List<GridCell>> grid;
  final bool isHyperdriveActive;
  final List<int> nearCompleteRows;
  final List<int> nearCompleteCols;
  final PolyominoShape? draggingShape;
  final Point<int>? hoverGridPos;
  final bool isHoverValid;
  final BlockSkinStyle currentBlockSkinStyle;
  final List<Point<int>> recentlyPlacedCells;
  final double placementFlashProgress;
  final List<ClearingCellAnim> clearingCells;
  final List<ClearingLineSlice> clearingLineSlices;
  final BoardEra currentEra;
  final bool hasAllClearCrest;
  final double allClearSurgeProgress;
  final List<int> cachedPreviewRows;
  final List<int> cachedPreviewCols;
  final double boardRevealProgress;
  final AnimationController tickerController;
  final AnimationController worldMorphController;
  final AnimationController clearController;
  final ParticleSystem particleSystem;
  final Color screenFlashColor;
  final AnimationController? screenFlashController;
  final GlobalKey gridKey;

  const GameBoardContainer({
    super.key,
    required this.gridWidth,
    required this.shakeController,
    required this.currentWorldTheme,
    required this.previousWorldTheme,
    required this.activeSkin,
    required this.grid,
    required this.isHyperdriveActive,
    required this.nearCompleteRows,
    required this.nearCompleteCols,
    required this.draggingShape,
    required this.hoverGridPos,
    required this.isHoverValid,
    required this.currentBlockSkinStyle,
    required this.recentlyPlacedCells,
    required this.placementFlashProgress,
    required this.clearingCells,
    required this.clearingLineSlices,
    required this.currentEra,
    required this.hasAllClearCrest,
    required this.allClearSurgeProgress,
    required this.cachedPreviewRows,
    required this.cachedPreviewCols,
    required this.boardRevealProgress,
    required this.tickerController,
    required this.worldMorphController,
    required this.clearController,
    required this.particleSystem,
    required this.screenFlashColor,
    this.screenFlashController,
    required this.gridKey,
  });

  @override
  Widget build(BuildContext context) {
    return ScreenShakeWidget(
      controller: shakeController,
      child: Stack(
        children: [
          Center(
            child: SizedBox(
              width: gridWidth,
              height: gridWidth,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeInOut,
                width: gridWidth,
                height: gridWidth,
                decoration: BoxDecoration(
                  color: currentWorldTheme.emptyCellColor.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: currentWorldTheme.gridBorderColor.withValues(alpha: 0.95),
                    width: 2.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: currentWorldTheme.primaryGlow.withValues(alpha: 0.55),
                      blurRadius: 28,
                      spreadRadius: 3,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: AnimatedBuilder(
                  animation: Listenable.merge([tickerController, worldMorphController, clearController]),
                  builder: (context, _) {
                    return Stack(
                      key: gridKey,
                      children: [
                        RepaintBoundary(
                          child: Opacity(
                            opacity: boardRevealProgress,
                            child: CustomPaint(
                              size: Size(gridWidth, gridWidth),
                              painter: GridPainter(
                                grid: grid,
                                draggingShape: draggingShape,
                                previewHoverPos: hoverGridPos,
                                isPreviewValid: isHoverValid,
                                animationProgress: tickerController.value,
                                activeSkin: activeSkin,
                                recentPlacements: recentlyPlacedCells,
                                placementFlash: placementFlashProgress,
                                blockSkinStyle: currentBlockSkinStyle,
                                clearingCells: clearingCells,
                                clearingLineSlices: clearingLineSlices,
                                currentEra: currentEra,
                                hasAllClearCrest: hasAllClearCrest,
                                allClearSurgeProgress: allClearSurgeProgress,
                                previewClearingRows: cachedPreviewRows,
                                previewClearingCols: cachedPreviewCols,
                                overrideEmptyCellColor: isHyperdriveActive
                                    ? const Color(0xFF1B0B2E)
                                    : currentWorldTheme.emptyCellColor,
                                overrideBorderColor: isHyperdriveActive
                                    ? const Color(0xFFFF9100)
                                    : currentWorldTheme.gridBorderColor,
                                activeSurgePalette: currentWorldTheme.blockPalette,
                                isMonochrome: currentWorldTheme.isMonochrome,
                                uniformColor: currentWorldTheme.uniformColor,
                                previousUniformColor: previousWorldTheme.uniformColor,
                                surgeProgress: worldMorphController.value,
                                nearCompleteRows: nearCompleteRows,
                                nearCompleteCols: nearCompleteCols,
                              ),
                            ),
                          ),
                        ),
                        RepaintBoundary(
                          child: CustomPaint(
                            size: Size(gridWidth, gridWidth),
                            painter: ParticlePainter(
                              particleSystem: particleSystem,
                              repaint: tickerController,
                            ),
                          ),
                        ),
                        if (screenFlashController != null)
                          Positioned.fill(
                            child: IgnorePointer(
                              child: AnimatedBuilder(
                                animation: screenFlashController!,
                                builder: (context, child) {
                                  if (!screenFlashController!.isAnimating) {
                                    return const SizedBox.shrink();
                                  }
                                  final p = screenFlashController!.value;
                                  final opacity = (1.0 - p) * 0.6;
                                  if (opacity <= 0.01) return const SizedBox.shrink();
                                  return Container(
                                    color: screenFlashColor.withValues(alpha: opacity),
                                  );
                                },
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
