import 'package:flutter/material.dart';

/// Grid RenderBox üzerinden hücre / merkez koordinatları.
class GameBoardGeometry {
  GameBoardGeometry(this.gridKey);

  final GlobalKey gridKey;

  Offset cellCenter(int r, int c) {
    final renderBox = gridKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final size = renderBox.size;
      final cellSize = size.width / 8;
      return Offset(
        c * cellSize + cellSize / 2,
        r * cellSize + cellSize / 2,
      );
    }
    return const Offset(150, 150);
  }

  Offset gridCenter() {
    final renderBox = gridKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      return Offset(renderBox.size.width / 2, renderBox.size.height / 2);
    }
    return const Offset(160, 160);
  }
}
