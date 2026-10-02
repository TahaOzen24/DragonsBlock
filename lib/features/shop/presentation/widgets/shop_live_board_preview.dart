import 'package:flutter/material.dart';
import '../../models/board_skin.dart';

/// 💎 Live 3D Candy-Gem Mini Board Preview
/// Renders an authentic miniature grid representing the active or inspected Board Skin,
/// displaying juicy Block Blast-grade candy gems with top-pill highlights and ambient occlusion.
class ShopLiveBoardPreview extends StatefulWidget {
  final BoardSkin skin;
  final double width;
  final double height;
  final bool isInteractive;

  const ShopLiveBoardPreview({
    super.key,
    required this.skin,
    this.width = double.infinity,
    this.height = 80.0,
    this.isInteractive = false,
  });

  @override
  State<ShopLiveBoardPreview> createState() => _ShopLiveBoardPreviewState();
}

class _ShopLiveBoardPreviewState extends State<ShopLiveBoardPreview>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  // Mini 4x4 or 5x3 pattern of gems
  static const List<int> _gemPattern = [
    1, 0, 2, 0,
    0, 3, 4, 0,
    5, 0, 0, 6,
  ];

  static const List<Color> _gemColors = [
    Color(0xFFEF4444), // Ruby Red
    Color(0xFF3B82F6), // Sapphire Blue
    Color(0xFF10B981), // Emerald Green
    Color(0xFFF59E0B), // Amber Topaz
    Color(0xFF8B5CF6), // Royal Amethyst
    Color(0xFF06B6D4), // Diamond Cyan
    Color(0xFFEC4899), // Rose Pink
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final skin = widget.skin;

    return Container(
      width: widget.width,
      height: widget.height,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: skin.emptyCellColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: skin.gridBorderColor, width: 1.4),
        boxShadow: [
          BoxShadow(
            color: skin.primaryGlow.withValues(alpha: 0.15),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const cols = 4;
          const rows = 3;
          final cellW = (constraints.maxWidth - (cols - 1) * 3) / cols;
          final cellH = (constraints.maxHeight - (rows - 1) * 3) / rows;

          return AnimatedBuilder(
            animation: _pulseController,
            builder: (context, _) {
              return GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  mainAxisSpacing: 3,
                  crossAxisSpacing: 3,
                  childAspectRatio: cellW / cellH,
                ),
                itemCount: cols * rows,
                itemBuilder: (context, index) {
                  final gemId = _gemPattern[index];
                  final isFilled = gemId > 0;

                  if (!isFilled) {
                    return Container(
                      decoration: BoxDecoration(
                        color: skin.emptyCellColor,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: skin.gridBorderColor.withValues(alpha: 0.5),
                          width: 0.8,
                        ),
                      ),
                    );
                  }

                  final gemColor = _gemColors[(gemId - 1) % _gemColors.length];
                  return _buildCandyGemCell(gemColor);
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCandyGemCell(Color baseColor) {
    final pulse = _pulseController.value;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(baseColor, Colors.white, 0.28)!,
            baseColor,
            Color.lerp(baseColor, Colors.black, 0.40)!,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: baseColor.withValues(alpha: 0.35 + 0.2 * pulse),
            blurRadius: 4 + 2 * pulse,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.5),
          width: 0.8,
        ),
      ),
      child: Stack(
        children: [
          // Top pill gloss highlight
          Positioned(
            top: 2,
            left: 3,
            right: 3,
            height: 4,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
