import 'dart:math';

import '../../../core/theme/game_theme.dart';
import '../models/grid_cell.dart';

/// Pure grid-manipulation logic extracted from [GridEngine].
///
/// Keeping these as free functions makes the rules independently testable
/// and shrinks GridEngine's responsibility. Every function takes the `grid`
/// explicitly so it has no hidden state beyond the passed-in objects.

List<Point<int>> applyGravityOp(
  List<List<GridCell>> grid,
  int gridSize,
) {
  bool movedAny = false;
  for (int c = 0; c < gridSize; c++) {
    int writeRow = gridSize - 1;
    for (int r = gridSize - 1; r >= 0; r--) {
      if (grid[r][c].isOccupied) {
        if (writeRow != r) {
          grid[writeRow][c].occupy(
            color: grid[r][c].blockColor ?? GameTheme.neonCyan,
            assignedClassicColor: grid[r][c].classicColor,
          );
          grid[r][c].reset();
          movedAny = true;
        }
        writeRow--;
      }
    }
  }
  return movedAny ? <Point<int>>[] : const [];
}

List<Point<int>> applyVoidSingularityOp(
  List<List<GridCell>> grid,
  int gridSize,
) {
  final cleared = <Point<int>>[];
  for (int r = 3; r <= 4; r++) {
    for (int c = 3; c <= 4; c++) {
      if (grid[r][c].isOccupied) {
        grid[r][c].reset();
        cleared.add(Point(r, c));
      }
    }
  }
  return cleared;
}

List<Point<int>> meltBottomRowsOp(
  List<List<GridCell>> grid,
  int gridSize,
  int count,
) {
  final cleared = <Point<int>>[];
  for (int r = gridSize - 1; r >= gridSize - count && r >= 0; r--) {
    for (int c = 0; c < gridSize; c++) {
      if (grid[r][c].isOccupied) {
        grid[r][c].reset();
        cleared.add(Point(r, c));
      }
    }
  }
  applyGravityOp(grid, gridSize);
  return cleared;
}

bool applyChronoShieldOp(
  List<List<GridCell>> grid,
  int gridSize,
) {
  int maxOccupiedRow = -1;
  int maxCount = 0;
  for (int r = 0; r < gridSize; r++) {
    int count = 0;
    for (int c = 0; c < gridSize; c++) {
      if (grid[r][c].isOccupied) count++;
    }
    if (count > maxCount) {
      maxCount = count;
      maxOccupiedRow = r;
    }
  }
  if (maxOccupiedRow != -1 && maxCount > 0) {
    for (int c = 0; c < gridSize; c++) {
      grid[maxOccupiedRow][c].reset();
    }
    return true;
  }
  return false;
}

List<Point<int>> reviveClearOp(
  List<List<GridCell>> grid,
  int gridSize,
) {
  final cleared = <Point<int>>[];
  for (int r = 2; r <= 5; r++) {
    for (int c = 2; c <= 5; c++) {
      if (grid[r][c].isOccupied) {
        grid[r][c].reset();
        cleared.add(Point(r, c));
      }
    }
  }
  return cleared;
}

List<Point<int>> meltRandomOccupiedCellsOp(
  List<List<GridCell>> grid,
  int gridSize,
  int count,
) {
  final occupied = <Point<int>>[];
  for (int r = 0; r < gridSize; r++) {
    for (int c = 0; c < gridSize; c++) {
      if (grid[r][c].isOccupied) {
        occupied.add(Point(r, c));
      }
    }
  }
  occupied.shuffle();
  final toMelt = occupied.take(count).toList();
  for (final pt in toMelt) {
    grid[pt.x][pt.y].reset();
  }
  return toMelt;
}

bool isBoardCompletelyEmptyOp(
  List<List<GridCell>> grid,
  int gridSize,
) {
  for (int r = 0; r < gridSize; r++) {
    for (int c = 0; c < gridSize; c++) {
      if (grid[r][c].isOccupied) return false;
    }
  }
  return true;
}

/// Finds the 3x3 quadrant with the most occupied blocks and clears them (Ignis Meteor Rain).
List<Point<int>> findDensest3x3SectorOp(
  List<List<GridCell>> grid,
  int gridSize,
) {
  int maxOccupied = -1;
  int bestR = 2;
  int bestC = 2;

  for (int r = 0; r <= gridSize - 3; r++) {
    for (int c = 0; c <= gridSize - 3; c++) {
      int count = 0;
      for (int dr = 0; dr < 3; dr++) {
        for (int dc = 0; dc < 3; dc++) {
          if (grid[r + dr][c + dc].isOccupied) count++;
        }
      }
      if (count > maxOccupied) {
        maxOccupied = count;
        bestR = r;
        bestC = c;
      }
    }
  }

  final cleared = <Point<int>>[];
  for (int dr = 0; dr < 3; dr++) {
    for (int dc = 0; dc < 3; dc++) {
      final pr = bestR + dr;
      final pc = bestC + dc;
      if (grid[pr][pc].isOccupied) {
        grid[pr][pc].reset();
        cleared.add(Point(pr, pc));
      }
    }
  }
  return cleared;
}

/// Clears cross horizontal row and vertical column axes (Voltur Overload Lightning).
List<Point<int>> clearCrossAxesOp(
  List<List<GridCell>> grid,
  int gridSize, {
  int targetRow = 3,
  int targetCol = 3,
}) {
  final cleared = <Point<int>>[];
  final safeRow = targetRow.clamp(0, gridSize - 1);
  final safeCol = targetCol.clamp(0, gridSize - 1);

  for (int c = 0; c < gridSize; c++) {
    if (grid[safeRow][c].isOccupied) {
      grid[safeRow][c].reset();
      cleared.add(Point(safeRow, c));
    }
  }
  for (int r = 0; r < gridSize; r++) {
    if (r != safeRow && grid[r][safeCol].isOccupied) {
      grid[r][safeCol].reset();
      cleared.add(Point(r, safeCol));
    }
  }
  return cleared;
}

/// Finds and absorbs up to [maxCount] isolated obstacle cells into a cosmic singularity (Umbra Singularity).
List<Point<int>> absorbIsolatedCellsOp(
  List<List<GridCell>> grid,
  int gridSize, {
  int maxCount = 6,
}) {
  final List<MapEntry<Point<int>, int>> cellDensities = [];

  for (int r = 0; r < gridSize; r++) {
    for (int c = 0; c < gridSize; c++) {
      if (grid[r][c].isOccupied) {
        int neighbors = 0;
        for (int dr = -1; dr <= 1; dr++) {
          for (int dc = -1; dc <= 1; dc++) {
            if (dr == 0 && dc == 0) continue;
            int nr = r + dr;
            int nc = c + dc;
            if (nr >= 0 && nr < gridSize && nc >= 0 && nc < gridSize) {
              if (grid[nr][nc].isOccupied) neighbors++;
            }
          }
        }
        cellDensities.add(MapEntry(Point(r, c), neighbors));
      }
    }
  }

  // Sort by lowest neighbor density first (isolated stragglers)
  cellDensities.sort((a, b) => a.value.compareTo(b.value));

  final cleared = <Point<int>>[];
  for (int i = 0; i < min(maxCount, cellDensities.length); i++) {
    final pt = cellDensities[i].key;
    grid[pt.x][pt.y].reset();
    cleared.add(pt);
  }
  return cleared;
}
