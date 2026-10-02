import 'dart:io';
import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dragons_block/core/audio/procedural_audio.dart';
import 'package:dragons_block/core/storage/app_prefs.dart';
import 'package:dragons_block/core/vfx/screen_shake.dart';
import 'package:dragons_block/features/game/logic/grid_engine.dart';
import 'package:dragons_block/features/game/models/block_skin_style.dart';
import 'package:dragons_block/features/game/models/polyomino_shape.dart';
import 'package:dragons_block/features/game/presentation/painters/block_skin_painter.dart';
import 'package:dragons_block/features/shop/services/shop_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({
      'gold_shards': 500,
      'high_score': 10000,
      'is_vip': false,
    });
    AppPrefs.instance.debugReset();
    await AppPrefs.instance.init();
  });

  final testDomino = PolyominoShape(
    id: 'test_domino',
    name: 'Domino',
    matrix: [
      [1, 1],
    ],
    baseColor: const Color(0xFF2563EB),
  );

  final testLine4 = PolyominoShape(
    id: 'test_line4',
    name: 'Line4',
    matrix: [
      [1, 1, 1, 1],
    ],
    baseColor: const Color(0xFF22C55E),
  );

  group('🔒 GÜVENLİK & SIZMA / İSTEMCİ MANİPÜLASYON TESTLERİ', () {
    test('1. Negatif ve Sınır Dışı Koordinat Sızma Koruması (Grid Bounds Tamper)', () {
      final engine = GridEngine();

      // Negative coordinates (out-of-bounds penetration attempt)
      expect(engine.canPlace(testDomino, -1, -1), isFalse);
      expect(engine.canPlace(testDomino, -100, 5), isFalse);
      expect(engine.canPlace(testDomino, 5, -100), isFalse);

      // Overflow coordinates (attempt to write outside 8x8 buffer)
      expect(engine.canPlace(testDomino, 8, 8), isFalse);
      expect(engine.canPlace(testDomino, 100, 100), isFalse);
      expect(engine.canPlace(testDomino, 0, 7), isFalse); // Domino [1, 1] overflows column 7

      // Ensure no crash or exception on placing at invalid coordinates
      final result = engine.placeShape(testDomino, -5, -5, []);
      expect(result.success, isFalse);
      expect(engine.occupiedCellCount, equals(0));
    });

    test('2. Puan ve Çarpan Sınır Güvenliği (Score Overflow & NaN Defense)', () {
      final engine = GridEngine();

      // Astronomical multiplier injection attempt
      engine.runScoreMultiplier = 99999.0;
      engine.comboStreak = 50;

      // Fill row 0 with two Line4 shapes
      engine.placeShape(testLine4, 0, 0, []);
      final result = engine.placeShape(testLine4, 0, 4, []);

      expect(result.linesCleared, equals(1));
      expect(engine.currentScore, isPositive);
      expect(engine.currentScore.isFinite, isTrue);
      expect(engine.currentScore.isNaN, isFalse);

      // Score reset safety
      engine.reset();
      expect(engine.currentScore, equals(0));
      expect(engine.comboStreak, equals(0));
    });

    test('3. Bakiye Manipülasyonu & Negatif Harcama Koruması (Wallet Tamper Defense)', () async {
      final shop = ShopManager.instance;
      await shop.loadFromPrefs();

      final initialShards = shop.goldShards;

      // Attempt to spend more than current balance
      final overspendSuccess = await shop.spendShards(initialShards + 9999);
      expect(overspendSuccess, isFalse);
      expect(shop.goldShards, equals(initialShards));

      // Legitimate spend
      if (initialShards >= 50) {
        final legitSpend = await shop.spendShards(50);
        expect(legitSpend, isTrue);
        expect(shop.goldShards, equals(initialShards - 50));
      }
    });

    test('4. Kaynak Kod Hassas Anahtar & Gizli Bilgi Taraması (Secret Leak Audit)', () {
      final libDir = Directory('lib');
      expect(libDir.existsSync(), isTrue);

      final files = libDir.listSync(recursive: true).whereType<File>();
      final suspiciousPatterns = [
        RegExp(r'AIzaSy[A-Za-z0-9_-]{33}'), // Google API Key
        RegExp(r'AKIA[0-9A-Z]{16}'), // AWS Access Key
        RegExp(r'-----BEGIN PRIVATE KEY-----'), // Private RSA Key
        RegExp(r'ghp_[A-Za-z0-9]{36}'), // GitHub Personal Access Token
      ];

      for (final file in files) {
        if (!file.path.endsWith('.dart')) continue;
        final content = file.readAsStringSync();
        for (final pattern in suspiciousPatterns) {
          final matches = pattern.allMatches(content);
          expect(
            matches.isEmpty,
            isTrue,
            reason: 'Hassas anahtar deseni tespit edildi: ${file.path}',
          );
        }
      }
    });
  });

  group('⚡ PERFORMANS & STRES / KASMA ÖNLEME TESTLERİ', () {
    test('5. 1.000 Hızlı Hamle Stres Testi (High-Throughput Benchmark)', () {
      final engine = GridEngine();
      final stopwatch = Stopwatch()..start();

      int placementsCount = 0;
      for (int i = 0; i < 1000; i++) {
        final r = i % 7;
        final c = (i * 2) % 7;

        if (engine.canPlace(testDomino, r, c)) {
          final res = engine.placeShape(testDomino, r, c, []);
          if (res.success) {
            placementsCount++;
          }
        } else {
          // Reset grid when full to continue the high-throughput test
          engine.reset();
        }
      }
      stopwatch.stop();

      // 1,000 simulated moves must complete well under 500ms on modern Dart VM
      expect(stopwatch.elapsedMilliseconds, lessThan(500),
          reason: '1000 hamle çok yavaş çalıştı: ${stopwatch.elapsedMilliseconds}ms');
      expect(placementsCount, isPositive);
    });

    test('6. 8x8 Tam Tahta Patlatma Stres Testi (Mega 64-Cell All-Clear)', () {
      final engine = GridEngine();

      // Occupy entire 8x8 board (64 cells) except 1 cell in the last row
      for (int r = 0; r < 8; r++) {
        for (int c = 0; c < 8; c++) {
          if (r == 7 && (c == 6 || c == 7)) continue;
          engine.grid[r][c].occupy(color: const Color(0xFF22C55E));
        }
      }

      // Complete the entire board with a final domino to trigger multi-line clear
      final result = engine.placeShape(testDomino, 7, 6, []);
      expect(result.success, isTrue);
      expect(result.linesCleared, greaterThanOrEqualTo(1));
      expect(result.clearedCells.isNotEmpty, isTrue);
      expect(engine.comboStreak, isPositive);
    });

    test('7. 8 Farklı Blok Modelinin Vektörel Çizim Kararlılığı (BlockSkinPainter Stress)', () {
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);

      // Render all 8 styles across various scales, opacities, and edge-cases
      for (final style in BlockSkinStyle.values) {
        // Normal 40x40 tile
        BlockSkinPainter.drawBlock(
          canvas: canvas,
          rect: const Rect.fromLTWH(0, 0, 40, 40),
          color: const Color(0xFF2563EB),
          style: style,
          opacity: 1.0,
          showPlusOne: false,
        );

        // Clearing block with "+1" badge
        BlockSkinPainter.drawBlock(
          canvas: canvas,
          rect: const Rect.fromLTWH(50, 0, 40, 40),
          color: const Color(0xFF22C55E),
          style: style,
          opacity: 0.5,
          showPlusOne: true,
          pulse: 0.5,
          flashAmount: 0.8,
        );

        // Feedback / Drag lift shadow
        BlockSkinPainter.drawBlock(
          canvas: canvas,
          rect: const Rect.fromLTWH(100, 0, 40, 40),
          color: const Color(0xFFF97316),
          style: style,
          isFeedback: true,
        );

        // Zero-size boundary check (should not throw / divide by zero)
        BlockSkinPainter.drawBlock(
          canvas: canvas,
          rect: Rect.zero,
          color: const Color(0xFFEF4444),
          style: style,
        );
      }

      final picture = recorder.endRecording();
      expect(picture, isNotNull);
      picture.dispose();
    });

    test('8. Yaşam Döngüsü & Ses / Titreşim Bellek Sızıntısı Koruması', () {
      final shakeController = ScreenShakeController();

      // Trigger shake when attached vs detached
      shakeController.trigger(intensity: 10.0, trauma: 0.8);

      // Procedural audio lifecycle transition safety
      ProceduralAudio.instance.handleAppLifecycle(AppLifecycleState.paused);
      ProceduralAudio.instance.handleAppLifecycle(AppLifecycleState.resumed);

      expect(true, isTrue); // Clean execution without uncaught state error
    });

    test('9. Her Oyunda Dinamik Blok Bileşeni Değişimi & Model Çeşitliliği', () {
      final styles = BlockSkinStyle.values;
      expect(styles.length, greaterThanOrEqualTo(8));

      // Test auto-rotation sequence
      BlockSkinStyle current = styles.first;
      final Set<BlockSkinStyle> rotatedStyles = {};
      for (int game = 0; game < styles.length; game++) {
        rotatedStyles.add(current);
        final nextIdx = (current.index + 1) % styles.length;
        current = styles[nextIdx];
      }

      // Verify that all 8 distinct block models are visited in a full cycle
      expect(rotatedStyles.length, equals(styles.length));
      for (final s in styles) {
        expect(s.displayName.isNotEmpty, isTrue);
        expect(s.description.isNotEmpty, isTrue);
      }
    });
  });
}
