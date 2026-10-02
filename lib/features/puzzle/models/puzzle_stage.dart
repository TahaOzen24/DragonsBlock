import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/localization/locale_manager.dart';
import '../../../core/theme/game_theme.dart';
import '../../game/models/polyomino_shape.dart';

class PuzzleStage {
  final int stageNumber;
  final String titleTr;
  final String titleEn;
  final String descriptionTr;
  final String descriptionEn;
  final int maxMoves;
  final List<Point<int>> initialOccupiedCells;
  final List<PolyominoShape> givenShapes;
  final int rewardShards;
  final int rewardXp;

  const PuzzleStage({
    required this.stageNumber,
    required this.titleTr,
    required this.titleEn,
    required this.descriptionTr,
    required this.descriptionEn,
    required this.maxMoves,
    required this.initialOccupiedCells,
    required this.givenShapes,
    required this.rewardShards,
    required this.rewardXp,
  });

  String get title => LocaleManager.instance.isTurkish ? titleTr : titleEn;
  String get description =>
      LocaleManager.instance.isTurkish ? descriptionTr : descriptionEn;

  static PuzzleStage getStage(int stageNumber) {
    final num = stageNumber.clamp(1, 30);

    final List<Point<int>> cells = [];
    final List<PolyominoShape> shapes = [];
    int maxMoves = 1;
    String titleTr = 'Bulmaca #$num';
    String titleEn = 'Puzzle #$num';
    String descTr = 'Verilen şekilleri yerleştirerek tüm hedef hatları temizle!';
    String descEn = 'Place the given shapes to clear all target lines!';
    int shards = 150 + (num * 25);
    int xp = 50 + (num * 10);

    // Reusable polyomino helpers (No 1x1 blocks allowed per GEMINI.md Rule #3)
    PolyominoShape dominoH(String id, Color color) => PolyominoShape(
          id: id,
          name: 'Domino Yatay',
          matrix: const [
            [1, 1]
          ],
          baseColor: color,
        );

    PolyominoShape dominoV(String id, Color color) => PolyominoShape(
          id: id,
          name: 'Domino Dikey',
          matrix: const [
            [1],
            [1]
          ],
          baseColor: color,
        );

    PolyominoShape cornerSmall(String id, Color color) => PolyominoShape(
          id: id,
          name: 'Köşe Rün',
          matrix: const [
            [1, 1],
            [1, 0],
          ],
          baseColor: color,
        );

    PolyominoShape cornerSmallRot(String id, Color color) => PolyominoShape(
          id: id,
          name: 'Ters Köşe',
          matrix: const [
            [1, 1],
            [0, 1],
          ],
          baseColor: color,
        );

    PolyominoShape line3H(String id, Color color) => PolyominoShape(
          id: id,
          name: '3-Hat Yatay',
          matrix: const [
            [1, 1, 1]
          ],
          baseColor: color,
        );

    PolyominoShape line3V(String id, Color color) => PolyominoShape(
          id: id,
          name: '3-Hat Dikey',
          matrix: const [
            [1],
            [1],
            [1]
          ],
          baseColor: color,
        );

    PolyominoShape square2x2(String id, Color color) => PolyominoShape(
          id: id,
          name: '2x2 Küp',
          matrix: const [
            [1, 1],
            [1, 1],
          ],
          baseColor: color,
        );

    PolyominoShape shapeT(String id, Color color) => PolyominoShape(
          id: id,
          name: 'T-Blok',
          matrix: const [
            [1, 1, 1],
            [0, 1, 0],
          ],
          baseColor: color,
        );

    PolyominoShape shapeL(String id, Color color) => PolyominoShape(
          id: id,
          name: 'L-Blok',
          matrix: const [
            [1, 0],
            [1, 0],
            [1, 1],
          ],
          baseColor: color,
        );

    if (num <= 10) {
      // ─────────────────────────────────────────────────────────────────────────
      // CHAPTER 1: ÇIRAK DERSLERİ (STAGES 1 - 10)
      // ─────────────────────────────────────────────────────────────────────────
      titleTr = 'Çırak Dersi #$num';
      titleEn = 'Apprentice Lesson #$num';

      if (num == 1) {
        // Row 7: 6 cells filled, cols 3-4 gap (domino 1x2)
        maxMoves = 1;
        descTr = 'Domino rünü yerleştirerek alt satırı tamamla!';
        descEn = 'Place the domino rune to complete the bottom line!';
        for (int c = 0; c < 8; c++) {
          if (c != 3 && c != 4) cells.add(Point(7, c));
        }
        shapes.add(dominoH('p_1_1', GameTheme.neonCyan));
      } else if (num == 2) {
        // Col 7: 6 cells filled, rows 3-4 gap (domino 2x1)
        maxMoves = 1;
        descTr = 'Dikey domino ile sağ sütunu arındır!';
        descEn = 'Purge the right column with a vertical domino!';
        for (int r = 0; r < 8; r++) {
          if (r != 3 && r != 4) cells.add(Point(r, 7));
        }
        shapes.add(dominoV('p_2_1', GameTheme.emeraldGreen));
      } else if (num == 3) {
        // Row 0: gap at cols 1, 2
        maxMoves = 1;
        descTr = 'Tavan satırını domino yerleşimiyle süpür!';
        descEn = 'Sweep the ceiling line with a domino placement!';
        for (int c = 0; c < 8; c++) {
          if (c != 1 && c != 2) cells.add(Point(0, c));
        }
        shapes.add(dominoH('p_3_1', GameTheme.goldAccent));
      } else if (num == 4) {
        // Corner clear! Row 6 gap at (6,7). Row 7 gap at (7,6), (7,7).
        maxMoves = 1;
        descTr = 'Köşe rünü ile 2 satırı aynı anda yok et!';
        descEn = 'Destroy 2 lines simultaneously with the corner rune!';
        for (int c = 0; c < 7; c++) {
          cells.add(Point(6, c));
        }
        for (int c = 0; c < 6; c++) {
          cells.add(Point(7, c));
        }
        shapes.add(cornerSmallRot('p_4_1', GameTheme.fireOrange));
      } else if (num == 5) {
        // Col 0: gap at rows 4, 5
        maxMoves = 1;
        descTr = 'Sol sütundaki boşluğu dikey domino ile mühürle!';
        descEn = 'Seal the left column gap with a vertical domino!';
        for (int r = 0; r < 8; r++) {
          if (r != 4 && r != 5) cells.add(Point(r, 0));
        }
        shapes.add(dominoV('p_5_1', GameTheme.voidPurple));
      } else if (num == 6) {
        // 2 moves: Row 6 gap at cols 1,2. Row 7 gap at cols 5,6.
        maxMoves = 2;
        descTr = '2 hamlede iki alt satırı sırayla temizle!';
        descEn = 'Clear both bottom lines in 2 sequential moves!';
        for (int c = 0; c < 8; c++) {
          if (c != 1 && c != 2) cells.add(Point(6, c));
          if (c != 5 && c != 6) cells.add(Point(7, c));
        }
        shapes.add(dominoH('p_6_1', GameTheme.neonCyan));
        shapes.add(dominoH('p_6_2', GameTheme.emeraldGreen));
      } else if (num == 7) {
        // 2 moves: Row 7 gap at cols 2,3 (H). Col 0 gap at rows 3,4 (V).
        maxMoves = 2;
        descTr = 'Yatay ve dikey iki dominoyu doğru hatlara yerleştir!';
        descEn = 'Place horizontal and vertical dominoes into correct lines!';
        for (int c = 0; c < 8; c++) {
          if (c != 2 && c != 3) cells.add(Point(7, c));
        }
        for (int r = 0; r < 8; r++) {
          if (r != 3 && r != 4) cells.add(Point(r, 0));
        }
        shapes.add(dominoH('p_7_1', GameTheme.goldAccent));
        shapes.add(dominoV('p_7_2', GameTheme.voidPurple));
      } else if (num == 8) {
        // 2 moves: Col 7 gap at rows 1,2. Col 6 gap at rows 5,6.
        maxMoves = 2;
        descTr = 'İki dikey sütunu domino darbeleriyle kır!';
        descEn = 'Break two vertical columns with domino strikes!';
        for (int r = 0; r < 8; r++) {
          if (r != 1 && r != 2) cells.add(Point(r, 7));
          if (r != 5 && r != 6) cells.add(Point(r, 6));
        }
        shapes.add(dominoV('p_8_1', GameTheme.fireOrange));
        shapes.add(dominoV('p_8_2', GameTheme.neonCyan));
      } else if (num == 9) {
        // 2 moves: Row 7 gap at cols 4,5 (2-cell). Row 6 gap at cols 2,3,4 (3-cell).
        maxMoves = 2;
        descTr = 'Domino ve 3-Hat kombinasyonuyla tabanı arındır!';
        descEn = 'Purge the base with a domino and 3-line combo!';
        for (int c = 0; c < 8; c++) {
          if (c != 4 && c != 5) cells.add(Point(7, c));
          if (c < 2 || c > 4) cells.add(Point(6, c));
        }
        shapes.add(dominoH('p_9_1', GameTheme.emeraldGreen));
        shapes.add(line3H('p_9_2', GameTheme.goldAccent));
      } else {
        // Stage 10: Symmetrical dual corner triominoes
        maxMoves = 2;
        descTr = 'İki köşe parçasını simetrik yuvalara yerleştir!';
        descEn = 'Slot two corner pieces into symmetrical sockets!';
        for (int c = 0; c < 8; c++) {
          if (c != 0 && c != 1 && c != 6 && c != 7) {
            cells.add(Point(7, c));
            cells.add(Point(6, c));
          }
        }
        cells.add(const Point(6, 1));
        cells.add(const Point(6, 6));
        shapes.add(cornerSmall('p_10_1', GameTheme.neonCyan));
        shapes.add(cornerSmallRot('p_10_2', GameTheme.voidPurple));
      }
    } else if (num <= 20) {
      // ─────────────────────────────────────────────────────────────────────────
      // CHAPTER 2: USTA TAKTİKLERİ (STAGES 11 - 20)
      // ─────────────────────────────────────────────────────────────────────────
      titleTr = 'Usta Taktikleri #$num';
      titleEn = 'Master Tactics #$num';

      if (num == 11) {
        // Quad Clear: Rows 3,4 and Cols 3,4 filled EXCEPT the 2x2 center at (3,3)-(4,4)
        maxMoves = 1;
        descTr = 'Merkeze 2x2 Küp koyarak aynı anda 4 hattı birden patlat!';
        descEn = 'Drop a 2x2 cube into center to trigger a 4-line Quad Clear!';
        for (int c = 0; c < 8; c++) {
          if (c != 3 && c != 4) {
            cells.add(Point(3, c));
            cells.add(Point(4, c));
          }
        }
        for (int r = 0; r < 8; r++) {
          if (r != 3 && r != 4) {
            cells.add(Point(r, 3));
            cells.add(Point(r, 4));
          }
        }
        shapes.add(square2x2('p_11_1', GameTheme.goldAccent));
      } else if (num == 12) {
        // 2 moves: Row 5 gap at cols 3..5 (3-line), Col 2 gap at rows 1..2 (2-domino)
        maxMoves = 2;
        descTr = 'Yatay 3-hat ve dikey domino ile kesişimi temizle!';
        descEn = 'Clear the intersection with horizontal 3-line and vertical domino!';
        for (int c = 0; c < 8; c++) {
          if (c < 3 || c > 5) cells.add(Point(5, c));
        }
        for (int r = 0; r < 8; r++) {
          if (r != 1 && r != 2) cells.add(Point(r, 2));
        }
        shapes.add(line3H('p_12_1', GameTheme.neonCyan));
        shapes.add(dominoV('p_12_2', GameTheme.fireOrange));
      } else if (num == 13) {
        // 2 moves: 2x2 center cube gap + Row 0 gap (domino 1x2)
        maxMoves = 2;
        descTr = 'Küp ve domino yerleşimiyle tahtayı iki hamlede arındır!';
        descEn = 'Purge the board in two moves with cube and domino!';
        for (int c = 0; c < 8; c++) {
          if (c != 3 && c != 4) {
            cells.add(Point(3, c));
            cells.add(Point(4, c));
          }
          if (c != 2 && c != 3) cells.add(Point(0, c));
        }
        shapes.add(square2x2('p_13_1', GameTheme.emeraldGreen));
        shapes.add(dominoH('p_13_2', GameTheme.goldAccent));
      } else if (num == 14) {
        // T-Block slot in center rows + Domino
        maxMoves = 2;
        descTr = 'T-Blok ile ana gövdeyi tamamla, ardından alt hattı bitir!';
        descEn = 'Complete the core with T-block, then finish the bottom line!';
        for (int c = 0; c < 8; c++) {
          if (c < 2 || c > 4) cells.add(Point(3, c));
          if (c != 3) cells.add(Point(4, c));
          if (c != 5 && c != 6) cells.add(Point(7, c));
        }
        shapes.add(shapeT('p_14_1', GameTheme.voidPurple));
        shapes.add(dominoH('p_14_2', GameTheme.neonCyan));
      } else if (num == 15) {
        // Dual 3-lines: Row 2 cols 2..4, Col 5 rows 2..4
        maxMoves = 2;
        descTr = 'Dikey ve yatay 3-Hat bloklarıyla çifte süpürme yap!';
        descEn = 'Execute a double sweep with vertical and horizontal 3-lines!';
        for (int c = 0; c < 8; c++) {
          if (c < 2 || c > 4) cells.add(Point(2, c));
        }
        for (int r = 0; r < 8; r++) {
          if (r < 2 || r > 4) cells.add(Point(r, 5));
        }
        shapes.add(line3H('p_15_1', GameTheme.goldAccent));
        shapes.add(line3V('p_15_2', GameTheme.emeraldGreen));
      } else if (num == 16) {
        // L-tetromino clearing 3 rows simultaneously + domino
        maxMoves = 2;
        descTr = 'L-Blok ile 3 satırı birden delip geç!';
        descEn = 'Pierce through 3 rows simultaneously with the L-block!';
        for (int r = 3; r <= 5; r++) {
          for (int c = 0; c < 8; c++) {
            if (c != 2 && (r != 5 || c != 3)) cells.add(Point(r, c));
          }
        }
        for (int c = 0; c < 8; c++) {
          if (c != 5 && c != 6) cells.add(Point(0, c));
        }
        shapes.add(shapeL('p_16_1', GameTheme.fireOrange));
        shapes.add(dominoH('p_16_2', GameTheme.neonCyan));
      } else if (num == 17) {
        // Two 2x2 Cubes clearing four quadrants
        maxMoves = 2;
        descTr = 'İki 2x2 Küp ile çapraz hatları tamamen temizle!';
        descEn = 'Completely clear diagonal lines with two 2x2 Cubes!';
        for (int i = 0; i < 8; i++) {
          if (i != 1 && i != 2) {
            cells.add(Point(1, i));
            cells.add(Point(2, i));
          }
          if (i != 5 && i != 6) {
            cells.add(Point(5, i));
            cells.add(Point(6, i));
          }
        }
        shapes.add(square2x2('p_17_1', GameTheme.neonCyan));
        shapes.add(square2x2('p_17_2', GameTheme.voidPurple));
      } else if (num == 18) {
        // Frame purge: 2x2 center cube + 2x1 domino
        maxMoves = 2;
        descTr = 'Merkez küp ve kenar dominoyla çerçeveyi serbest bırak!';
        descEn = 'Release the frame with center cube and edge domino!';
        for (int c = 1; c <= 6; c++) {
          if (c != 3 && c != 4) {
            cells.add(Point(3, c));
            cells.add(Point(4, c));
          }
        }
        for (int r = 0; r < 8; r++) {
          if (r != 5 && r != 6) cells.add(Point(r, 7));
        }
        shapes.add(square2x2('p_18_1', GameTheme.goldAccent));
        shapes.add(dominoV('p_18_2', GameTheme.emeraldGreen));
      } else if (num == 19) {
        // T-Block and 3-Line combo
        maxMoves = 2;
        descTr = 'T-Blok ve 3-Hat birleşimiyle tahtayı temizle!';
        descEn = 'Clear the board with T-block and 3-line combination!';
        for (int c = 0; c < 8; c++) {
          if (c < 3 || c > 5) cells.add(Point(2, c));
          if (c != 4) cells.add(Point(3, c));
          if (c < 2 || c > 4) cells.add(Point(6, c));
        }
        shapes.add(shapeT('p_19_1', GameTheme.neonCyan));
        shapes.add(line3H('p_19_2', GameTheme.fireOrange));
      } else {
        // Stage 20: Master exam - 3-line vertical and 3-line horizontal
        maxMoves = 2;
        descTr = 'İki 3-Hat ile yatay ve dikey hatları aynı anda süpür!';
        descEn = 'Sweep horizontal and vertical lines at once with two 3-lines!';
        for (int c = 0; c < 8; c++) {
          if (c < 2 || c > 4) cells.add(Point(4, c));
        }
        for (int r = 0; r < 8; r++) {
          if (r < 2 || r > 4) cells.add(Point(r, 4));
        }
        shapes.add(line3H('p_20_1', GameTheme.goldAccent));
        shapes.add(line3V('p_20_2', GameTheme.voidPurple));
      }
    } else {
      // ─────────────────────────────────────────────────────────────────────────
      // CHAPTER 3: BÜYÜK MİMAR (STAGES 21 - 30)
      // ─────────────────────────────────────────────────────────────────────────
      maxMoves = 3;
      titleTr = 'Büyük Mimar #$num';
      titleEn = 'Grand Architect #$num';
      descTr = '3 stratejik yerleşimle tahtayı tamamen arındır!';
      descEn = 'Clear the board completely with 3 strategic placements!';

      if (num == 21) {
        // 3 moves: 1x3 line, 1x2 domino, 2x1 domino
        for (int c = 0; c < 8; c++) {
          if (c < 2 || c > 4) cells.add(Point(5, c));
          if (c != 6 && c != 7) cells.add(Point(6, c));
        }
        for (int r = 0; r < 8; r++) {
          if (r != 2 && r != 3) cells.add(Point(r, 1));
        }
        shapes.add(line3H('p_21_1', GameTheme.neonCyan));
        shapes.add(dominoH('p_21_2', GameTheme.emeraldGreen));
        shapes.add(dominoV('p_21_3', GameTheme.goldAccent));
      } else if (num == 22) {
        // L-tetromino + two dominoes
        for (int r = 2; r <= 4; r++) {
          for (int c = 0; c < 8; c++) {
            if (c != 3 && (r != 4 || c != 4)) cells.add(Point(r, c));
          }
        }
        for (int c = 0; c < 8; c++) {
          if (c != 1 && c != 2) cells.add(Point(6, c));
          if (c != 5 && c != 6) cells.add(Point(7, c));
        }
        shapes.add(shapeL('p_22_1', GameTheme.voidPurple));
        shapes.add(dominoH('p_22_2', GameTheme.fireOrange));
        shapes.add(dominoH('p_22_3', GameTheme.neonCyan));
      } else if (num == 23) {
        // T-Block + 2x2 Square + Domino
        for (int c = 0; c < 8; c++) {
          if (c < 3 || c > 5) cells.add(Point(1, c));
          if (c != 4) cells.add(Point(2, c));
          if (c != 2 && c != 3) {
            cells.add(Point(4, c));
            cells.add(Point(5, c));
          }
          if (c != 6 && c != 7) cells.add(Point(7, c));
        }
        shapes.add(shapeT('p_23_1', GameTheme.goldAccent));
        shapes.add(square2x2('p_23_2', GameTheme.emeraldGreen));
        shapes.add(dominoH('p_23_3', GameTheme.neonCyan));
      } else if (num == 24) {
        // Triple corner purges
        for (int c = 0; c < 8; c++) {
          if (c != 0 && c != 1) cells.add(Point(1, c));
          if (c != 6 && c != 7) cells.add(Point(4, c));
          if (c != 3 && c != 4) cells.add(Point(7, c));
        }
        shapes.add(cornerSmall('p_24_1', GameTheme.fireOrange));
        shapes.add(cornerSmallRot('p_24_2', GameTheme.voidPurple));
        shapes.add(dominoH('p_24_3', GameTheme.neonCyan));
      } else if (num == 25) {
        // 2x2 Square + 3-Line H + 3-Line V
        for (int c = 0; c < 8; c++) {
          if (c != 3 && c != 4) {
            cells.add(Point(2, c));
            cells.add(Point(3, c));
          }
          if (c < 2 || c > 4) cells.add(Point(6, c));
        }
        for (int r = 0; r < 8; r++) {
          if (r < 4 || r > 6) cells.add(Point(r, 6));
        }
        shapes.add(square2x2('p_25_1', GameTheme.goldAccent));
        shapes.add(line3H('p_25_2', GameTheme.emeraldGreen));
        shapes.add(line3V('p_25_3', GameTheme.neonCyan));
      } else if (num == 26) {
        // Two 2x2 Squares + 1x2 Domino
        for (int c = 0; c < 8; c++) {
          if (c != 1 && c != 2) {
            cells.add(Point(1, c));
            cells.add(Point(2, c));
          }
          if (c != 5 && c != 6) {
            cells.add(Point(4, c));
            cells.add(Point(5, c));
          }
          if (c != 3 && c != 4) cells.add(Point(7, c));
        }
        shapes.add(square2x2('p_26_1', GameTheme.neonCyan));
        shapes.add(square2x2('p_26_2', GameTheme.voidPurple));
        shapes.add(dominoH('p_26_3', GameTheme.goldAccent));
      } else if (num == 27) {
        // T-Block + L-Block + Domino
        for (int c = 0; c < 8; c++) {
          if (c < 2 || c > 4) cells.add(Point(2, c));
          if (c != 3) cells.add(Point(3, c));
          if (c != 5 && c != 6) cells.add(Point(7, c));
        }
        for (int r = 4; r <= 6; r++) {
          for (int c = 0; c < 8; c++) {
            if (c != 5 && (r != 6 || c != 6)) cells.add(Point(r, c));
          }
        }
        shapes.add(shapeT('p_27_1', GameTheme.fireOrange));
        shapes.add(shapeL('p_27_2', GameTheme.emeraldGreen));
        shapes.add(dominoH('p_27_3', GameTheme.neonCyan));
      } else if (num == 28) {
        // Triple Lines (H, V, H)
        for (int c = 0; c < 8; c++) {
          if (c < 1 || c > 3) cells.add(Point(1, c));
          if (c < 4 || c > 6) cells.add(Point(6, c));
        }
        for (int r = 0; r < 8; r++) {
          if (r < 2 || r > 4) cells.add(Point(r, 4));
        }
        shapes.add(line3H('p_28_1', GameTheme.neonCyan));
        shapes.add(line3V('p_28_2', GameTheme.goldAccent));
        shapes.add(line3H('p_28_3', GameTheme.voidPurple));
      } else if (num == 29) {
        // Symmetrical Twin T-Blocks + Domino
        for (int c = 0; c < 8; c++) {
          if (c < 1 || c > 3) cells.add(Point(2, c));
          if (c != 2) cells.add(Point(3, c));
          if (c < 4 || c > 6) cells.add(Point(5, c));
          if (c != 5) cells.add(Point(6, c));
          if (c != 3 && c != 4) cells.add(Point(0, c));
        }
        shapes.add(shapeT('p_29_1', GameTheme.emeraldGreen));
        shapes.add(shapeT('p_29_2', GameTheme.fireOrange));
        shapes.add(dominoH('p_29_3', GameTheme.neonCyan));
      } else {
        // Stage 30: Grand Masterpiece - 2x2 Square, L-Block, and 1x3 Line
        for (int c = 0; c < 8; c++) {
          if (c != 2 && c != 3) {
            cells.add(Point(2, c));
            cells.add(Point(3, c));
          }
          if (c < 4 || c > 6) cells.add(Point(6, c));
        }
        for (int r = 4; r <= 6; r++) {
          for (int c = 0; c < 8; c++) {
            if (c != 1 && (r != 6 || c != 2)) cells.add(Point(r, c));
          }
        }
        shapes.add(square2x2('p_30_1', GameTheme.goldAccent));
        shapes.add(shapeL('p_30_2', GameTheme.neonCyan));
        shapes.add(line3H('p_30_3', GameTheme.voidPurple));
      }
    }

    return PuzzleStage(
      stageNumber: num,
      titleTr: titleTr,
      titleEn: titleEn,
      descriptionTr: descTr,
      descriptionEn: descEn,
      maxMoves: maxMoves,
      initialOccupiedCells: cells,
      givenShapes: shapes,
      rewardShards: shards,
      rewardXp: xp,
    );
  }
}
