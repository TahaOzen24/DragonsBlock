import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dragons_block/core/audio/procedural_audio.dart';
import 'package:dragons_block/core/localization/locale_manager.dart';
import 'package:dragons_block/core/settings/settings_manager.dart';
import 'package:dragons_block/core/storage/app_prefs.dart';
import 'package:dragons_block/features/adventure/models/adventure_level.dart';
import 'package:dragons_block/features/adventure/models/boss.dart';
import 'package:dragons_block/features/daily_challenge/services/daily_challenge_manager.dart';
import 'package:dragons_block/features/dragon/models/dragon.dart';
import 'package:dragons_block/features/dragon/services/dragon_manager.dart';
import 'package:dragons_block/features/game/logic/grid_engine.dart';
import 'package:dragons_block/features/game/logic/shape_spawner_engine.dart';
import 'package:dragons_block/features/game/models/polyomino_shape.dart';
import 'package:dragons_block/features/puzzle/models/puzzle_stage.dart';
import 'package:dragons_block/features/puzzle/services/puzzle_manager.dart';
import 'package:dragons_block/features/quests/services/quest_manager.dart';
import 'package:dragons_block/features/rewards/services/daily_reward_manager.dart';
import 'package:dragons_block/features/shop/models/board_skin.dart';
import 'package:dragons_block/features/shop/services/shop_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    const MethodChannel globalChannel = MethodChannel('xyz.luan/audioplayers.global');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      globalChannel,
      (MethodCall methodCall) async => 1,
    );
    const MethodChannel audioChannel = MethodChannel('xyz.luan/audioplayers');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      audioChannel,
      (MethodCall methodCall) async => 1,
    );
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    AppPrefs.instance.debugReset();
    await AppPrefs.instance.init();
  });

  group('🐉 1. SAF BLOCK PUZZLE ENGINE & SPAWNER TESTLERİ', () {
    test('8x8 grid boş başlatılır ve hücreler boştur', () {
      final engine = GridEngine();

      expect(engine.grid.length, 8);
      expect(engine.grid[0].length, 8);
      for (int r = 0; r < 8; r++) {
        for (int c = 0; c < 8; c++) {
          expect(engine.grid[r][c].isOccupied, false);
        }
      }
      expect(engine.currentScore, 0);
      expect(engine.comboStreak, 0);
    });

    test('1x1 Dot kuralı: Şekil üreticide asla 1x1 tek nokta bloğu üretilmez', () {
      final engine = GridEngine();
      final spawner = ShapeSpawnerEngine();
      for (int i = 0; i < 50; i++) {
        final shapes = spawner.generateBalancedHand(
          gridEngine: engine,
          currentScore: 0,
          movesCount: i,
        );
        expect(shapes.length, 3);
        for (final s in shapes) {
          expect(s.totalBlocks, greaterThanOrEqualTo(2),
              reason: 'Minimum shape size must be domino 1x2 or larger (No 1x1 dots)');
        }
      }
    });

    test('Satır ve sütun temizleme doğru puan ve kombo üretir', () {
      final engine = GridEngine();

      // Row 0'a 7 hücre doldur
      for (int c = 0; c < 7; c++) {
        engine.grid[0][c].occupy(color: Colors.blue);
      }
      expect(engine.nearCompleteRows.contains(0), true);

      // Son hücreyi domino 1x2 ile doldur (sadece (0,7) satır 0'da)
      final domino = PolyominoShape(
        id: 'test_domino',
        name: 'Domino',
        matrix: const [
          [1],
          [1],
        ],
        baseColor: Colors.red,
      );

      final result = engine.placeShape(domino, 0, 7, const []);
      expect(result.success, true);
      expect(result.linesCleared, 1);
      expect(engine.comboStreak, 1);
      expect(engine.totalLinesCleared, 1);
      expect(engine.currentScore, greaterThan(0));
    });

    test('canPlace ve sınır taşma koruması', () {
      final engine = GridEngine();

      final shape = PolyominoShape(
        id: 'test_duo',
        name: 'Duo',
        matrix: const [
          [1, 1],
        ],
        baseColor: Colors.amber,
      );

      expect(engine.canPlace(shape, 0, 0), true);
      expect(engine.canPlace(shape, 0, 7), false); // Sınır taşması
    });
  });

  group('🐉 2. EJDERHA EVRİMİ (DRAGON AWAKENING) TESTLERİ', () {
    test('Tüm 4 Element Ejderhası tanımlıdır ve doğru özelliklere sahiptir', () {
      expect(DragonDefinition.allDragons.length, 4);
      for (final dragon in DragonDefinition.allDragons) {
        expect(dragon.nameTr.isNotEmpty, true);
        expect(dragon.powerNameTr.isNotEmpty, true);
        expect(dragon.powerMaxEnergy, 100);
      }
    });

    test('Ejderha Seviye atlama ve 5 Evrim Kademesi hesaplaması', () {
      final manager = DragonManager.instance;
      manager.selectEgg(DragonEggType.fire);

      expect(manager.dragonLevel, 1);
      expect(manager.currentStage, DragonEvolutionStage.hatchling);

      // Level 10 -> Drake
      manager.addDragonExp(DragonEvolution.expForLevel(10));
      expect(manager.dragonLevel, greaterThanOrEqualTo(10));
      expect(manager.currentStage, DragonEvolutionStage.drake);

      // Level 25 -> BattleDragon
      manager.addDragonExp(DragonEvolution.expForLevel(25));
      expect(manager.dragonLevel, greaterThanOrEqualTo(25));
      expect(manager.currentStage, DragonEvolutionStage.battleDragon);

      // Level 50 -> AncientDragon
      manager.addDragonExp(DragonEvolution.expForLevel(50));
      expect(manager.dragonLevel, greaterThanOrEqualTo(50));
      expect(manager.currentStage, DragonEvolutionStage.ancientDragon);
    });

    test('Ejderha Yumurtası seçimi ve kaydı', () async {
      final manager = DragonManager.instance;
      await manager.unlockEgg(DragonEggType.ice, cost: 0);
      await manager.selectEgg(DragonEggType.ice);
      expect(manager.activeDragon.eggType, DragonEggType.ice);

      await manager.unlockEgg(DragonEggType.storm, cost: 0);
      await manager.selectEgg(DragonEggType.storm);
      expect(manager.activeDragon.eggType, DragonEggType.storm);
    });
  });

  group('🎨 3. BLOK STÜDYOSU VE MAĞAZA TESTLERİ', () {
    test('Varsayılan tema ve altın bakiyesi yönetimi', () async {
      final shop = ShopManager.instance;
      await shop.loadFromPrefs();

      expect(shop.activeSkin.id.isNotEmpty, true);
      expect(shop.goldShards, greaterThanOrEqualTo(0));

      final prevShards = shop.goldShards;
      await shop.addShards(500);
      expect(shop.goldShards, prevShards + 500);

      final spent = await shop.spendShards(200);
      expect(spent, true);
      expect(shop.goldShards, prevShards + 300);

      final overspend = await shop.spendShards(9999999);
      expect(overspend, false);
    });

    test('Tema satın alma ve kuşanma', () async {
      final shop = ShopManager.instance;
      await shop.addShards(5000);

      final skinToBuy = BoardSkin.defaultSkins.firstWhere((s) => s.priceShards > 0);
      final unlocked = await shop.purchaseSkin(skinToBuy);
      expect(unlocked, true);
      expect(shop.isSkinUnlocked(skinToBuy.id), true);

      await shop.selectSkin(skinToBuy.id);
      expect(shop.activeSkin.id, skinToBuy.id);
    });
  });

  group('🗺️ 4. MACERA HARİTASI VE GÖREV TESTLERİ', () {
    test('Macera Seviye ve Yıldız ilerlemesi', () async {
      final levels = AdventureLevel.getLevelsForWorld(1);
      expect(levels.length, 10);
      final l1 = AdventureLevel.getLevel(1);
      expect(l1.levelIndex, 1);
      expect(l1.maxMoves, greaterThan(0));

      await AdventureLevel.unlockNextLevel(1);
      final unlocked = await AdventureLevel.getUnlockedLevel();
      expect(unlocked, greaterThanOrEqualTo(2));

      await AdventureLevel.saveStarsForLevel(1, 3);
      final stars = await AdventureLevel.getStarsForLevel(1);
      expect(stars, 3);
    });

    test('Bölüm Sonu Canavarları (Bosses) doğru yapılandırılmıştır', () {
      expect(Boss.bosses.length, 6);
      final ignis = Boss.bosses.firstWhere((b) => b.id == 'ignis_dragon');
      expect(ignis.maxHp, greaterThan(0));
    });

    test('Günlük Görevler ve Ödül Talebi', () async {
      final qm = QuestManager.instance;
      await qm.loadQuests();

      expect(qm.quests.isNotEmpty, true);
      final quest = qm.quests.first;
      await qm.reportProgress(quest.id, quest.targetValue, isAbsolute: true);
      expect(quest.isCompleted, true);

      final claimed = await qm.claimReward(quest);
      expect(claimed, true);
      expect(quest.isClaimed, true);
    });

    test('Günlük Ödül ve Günlük Meydan Okuma', () async {
      final drm = DailyRewardManager.instance;
      await drm.checkDailyStatus();
      expect(drm.currentDay, greaterThanOrEqualTo(1));

      final dcm = DailyChallengeManager.instance;
      await dcm.loadClaimedMedals();
      expect(dcm.isMedalClaimed('bronze'), false);
    });

    test('Bulmaca (Puzzle) Aşamaları doğru ilerler', () async {
      final pm = PuzzleManager.instance;
      await pm.loadFromPrefs();
      expect(pm.isUnlocked(1), true);

      final p1 = PuzzleStage.getStage(1);
      expect(p1.stageNumber, 1);
      expect(p1.initialOccupiedCells, isNotNull);
    });
  });

  group('🌐 5. AYARLAR, DİL VE SES TESTLERİ', () {
    test('Türkçe ve İngilizce dil değişimi', () {
      final lm = LocaleManager.instance;
      lm.setLanguage(AppLanguage.tr);
      expect(lm.isTurkish, true);
      lm.setLanguage(AppLanguage.en);
      expect(lm.isTurkish, false);
      lm.setLanguage(AppLanguage.tr);
    });

    test('Ses ayarları güncellenebilir', () {
      final sm = SettingsManager.instance;
      final prev = sm.isSoundEnabled;
      sm.setSound(!prev);
      expect(sm.isSoundEnabled, !prev);
      sm.setSound(prev);
    });

    test('Prosedürel ses motoru çökmeden çalışır', () {
      final audio = ProceduralAudio.instance;
      expect(() => audio.playExplosion(), returnsNormally);
      expect(() => audio.playMultiLineClear(2), returnsNormally);
      expect(() => audio.playPowerUpUsed(), returnsNormally);
      expect(() => audio.playButtonClick(), returnsNormally);
      expect(() => audio.playDialogPop(), returnsNormally);
    });
  });
}
