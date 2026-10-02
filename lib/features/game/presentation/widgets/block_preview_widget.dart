import 'package:flutter/material.dart';
import '../../../../core/haptics/haptic_service.dart';
import '../../models/block_skin_style.dart';
import '../../models/polyomino_shape.dart';
import '../painters/block_skin_painter.dart';

/// Clean, fast draggable block — no extra shadows, no heavy effects.
/// Block follows finger directly with a small offset above.
class BlockPreviewWidget extends StatefulWidget {
  final PolyominoShape shape;
  final double previewBlockSize;
  final double dragBlockSize;
  final bool isDraggable;
  final BlockSkinStyle blockSkinStyle;
  final VoidCallback? onDragStarted;
  final VoidCallback? onDragEnd;

  const BlockPreviewWidget({
    super.key,
    required this.shape,
    this.previewBlockSize = 25.0,
    this.dragBlockSize = 42.0,
    this.isDraggable = true,
    this.blockSkinStyle = BlockSkinStyle.minimalGlass,
    this.onDragStarted,
    this.onDragEnd,
  });

  @override
  State<BlockPreviewWidget> createState() => _BlockPreviewWidgetState();
}

class _BlockPreviewWidgetState extends State<BlockPreviewWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pickupCtrl;
  late final Animation<double> _pickupScale;

  @override
  void initState() {
    super.initState();
    _pickupCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 60),
    );
    _pickupScale = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _pickupCtrl, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _pickupCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double width = widget.shape.colCount * widget.previewBlockSize;
    final double height = widget.shape.rowCount * widget.previewBlockSize;
    final double feedbackWidth = widget.shape.colCount * widget.dragBlockSize;
    final double feedbackHeight = widget.shape.rowCount * widget.dragBlockSize;

    Widget shapeContent = SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _MiniShapePainter(
          shape: widget.shape,
          blockSize: widget.previewBlockSize,
          blockSkinStyle: widget.blockSkinStyle,
        ),
      ),
    );

    if (!widget.isDraggable) {
      return shapeContent;
    }

    Widget hitArea = Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.transparent,
      alignment: Alignment.center,
      child: AnimatedBuilder(
        animation: _pickupScale,
        builder: (context, child) => Transform.scale(
          scale: _pickupScale.value,
          child: child,
        ),
        child: shapeContent,
      ),
    );

    return Draggable<PolyominoShape>(
      data: widget.shape,
      hitTestBehavior: HitTestBehavior.opaque,
      onDragStarted: () {
        AppHaptics.light();
        widget.onDragStarted?.call();
      },
      onDragEnd: (_) => widget.onDragEnd?.call(),
      onDraggableCanceled: (_, _) => widget.onDragEnd?.call(),
      // Snappy, instant 1:1 finger tracking with generous vertical lift
      // Floating distance prevents the player's thumb/finger from occluding the block or grid cells
      dragAnchorStrategy: (draggable, context, position) {
        return Offset(feedbackWidth / 2, feedbackHeight + 98.0);
      },
      feedback: Material(
        color: Colors.transparent,
        child: CustomPaint(
          size: Size(feedbackWidth, feedbackHeight),
          painter: _MiniShapePainter(
            shape: widget.shape,
            blockSize: widget.dragBlockSize,
            blockSkinStyle: widget.blockSkinStyle,
            isFeedback: true,
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.08,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.transparent,
          alignment: Alignment.center,
          child: shapeContent,
        ),
      ),
      child: hitArea,
    );
  }
}

class _MiniShapePainter extends CustomPainter {
  final PolyominoShape shape;
  final double blockSize;
  final BlockSkinStyle blockSkinStyle;
  final bool isFeedback;

  _MiniShapePainter({
    required this.shape,
    required this.blockSize,
    required this.blockSkinStyle,
    this.isFeedback = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double padding = isFeedback ? 1.8 : 1.2;

    for (int r = 0; r < shape.rowCount; r++) {
      for (int c = 0; c < shape.colCount; c++) {
        if (shape.matrix[r][c] == 1) {
          final rect = Rect.fromLTWH(
            c * blockSize + padding,
            r * blockSize + padding,
            blockSize - padding * 2,
            blockSize - padding * 2,
          );

          BlockSkinPainter.drawBlock(
            canvas: canvas,
            rect: rect,
            color: shape.baseColor,
            style: blockSkinStyle,
            isFeedback: isFeedback,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MiniShapePainter oldDelegate) =>
      oldDelegate.shape.id != shape.id ||
      oldDelegate.shape.baseColor != shape.baseColor ||
      oldDelegate.blockSize != blockSize ||
      oldDelegate.blockSkinStyle != blockSkinStyle ||
      oldDelegate.isFeedback != isFeedback;
}
