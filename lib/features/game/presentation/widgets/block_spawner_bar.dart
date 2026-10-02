import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/block_skin_style.dart';
import '../../models/polyomino_shape.dart';
import 'block_preview_widget.dart';

/// Clean, invisible 3-zone bottom touch area.
/// Divides the entire bottom space into 3 full-height vertical columns (Left, Center, Right).
/// Touching or dragging anywhere within a column instantly grabs that column's block.
/// Double-tap or horizontal swipe rotates the piece 90°.
class BlockSpawnerBar extends StatelessWidget {
  final List<PolyominoShape?> shapes;
  final double screenWidth;
  final double gridWidth;
  final double cellSize;
  final Color gridBorderColor;
  final Color primaryGlow;
  final BlockSkinStyle blockSkinStyle;
  final void Function(PolyominoShape shape) onDragStarted;
  final VoidCallback onDragEnd;
  final void Function(int slotIndex)? onRotateSlot;

  const BlockSpawnerBar({
    super.key,
    required this.shapes,
    required this.screenWidth,
    required this.gridWidth,
    required this.cellSize,
    required this.gridBorderColor,
    required this.primaryGlow,
    this.blockSkinStyle = BlockSkinStyle.minimalGlass,
    required this.onDragStarted,
    required this.onDragEnd,
    this.onRotateSlot,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            const Color(0xFF0F172A).withValues(alpha: 0.35),
            const Color(0xFF0F172A).withValues(alpha: 0.70),
          ],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: List.generate(3, (index) {
              return Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final shape = shapes[index];
                    if (shape == null) return const SizedBox.expand();

                    final maxAvailableWidth = constraints.maxWidth * 0.88;
                    final maxAvailableHeight = (constraints.maxHeight - 20.0) * 0.85;
                    final maxColSize = maxAvailableWidth / max(shape.colCount, 1);
                    final maxRowSize = maxAvailableHeight / max(shape.rowCount, 1);
                    final fittedBlockSize =
                        min(cellSize * 0.76, min(maxColSize, maxRowSize)).clamp(22.0, 36.0);

                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          bottom: 12,
                          child: Container(
                            width: min(72.0, constraints.maxWidth * 0.7),
                            height: 12,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: shape.baseColor.withValues(alpha: 0.40),
                                  blurRadius: 22,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ),
                        TweenAnimationBuilder<double>(
                          key: ValueKey(shape.id),
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: Duration(milliseconds: 420 + index * 45),
                          builder: (context, animVal, child) {
                            // Stagger the tray without delaying layout: each piece
                            // settles in with a quiet lift instead of a hard pop.
                            final start = index * 0.12;
                            final localProgress = Interval(
                              start,
                              0.72 + index * 0.08,
                              curve: Curves.easeOutCubic,
                            ).transform(animVal);
                            return Transform.scale(
                              scale: (0.88 + 0.12 * localProgress).clamp(0.0, 1.0),
                              alignment: Alignment.bottomCenter,
                              child: Transform.translate(
                                offset: Offset(0, 10.0 * (1.0 - localProgress)),
                                child: Opacity(
                                  opacity: localProgress.clamp(0.0, 1.0),
                                  child: child,
                                ),
                              ),
                            );
                          },
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onDoubleTap: onRotateSlot == null
                                ? null
                                : () => onRotateSlot!(index),
                            onHorizontalDragEnd: onRotateSlot == null
                                ? null
                                : (details) {
                                    final v = details.primaryVelocity ?? 0;
                                    if (v.abs() > 180) {
                                      onRotateSlot!(index);
                                    }
                                  },
                            child: BlockPreviewWidget(
                              shape: shape,
                              blockSkinStyle: blockSkinStyle,
                              previewBlockSize: fittedBlockSize,
                              dragBlockSize: cellSize,
                              onDragStarted: () => onDragStarted(shape),
                              onDragEnd: onDragEnd,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
