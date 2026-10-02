import 'package:flutter/material.dart';

class GridCell {
  bool isOccupied;
  Color? blockColor;
  Color? classicColor;
  double glowFactor;
  bool isClearing;
  int frozenTurns; // If > 0, cell is protected/frozen

  bool get isFrozen => frozenTurns > 0;

  GridCell({
    this.isOccupied = false,
    this.blockColor,
    this.classicColor,
    this.glowFactor = 0.0,
    this.isClearing = false,
    this.frozenTurns = 0,
  });

  void reset() {
    isOccupied = false;
    blockColor = null;
    classicColor = null;
    glowFactor = 0.0;
    isClearing = false;
    frozenTurns = 0;
  }

  void occupy({
    required Color color,
    Color? assignedClassicColor,
  }) {
    isOccupied = true;
    blockColor = color;
    classicColor = assignedClassicColor ?? color;
    glowFactor = 0.3;
    isClearing = false;
  }

  GridCell clone() {
    return GridCell(
      isOccupied: isOccupied,
      blockColor: blockColor,
      classicColor: classicColor,
      glowFactor: glowFactor,
      isClearing: isClearing,
      frozenTurns: frozenTurns,
    );
  }
}
