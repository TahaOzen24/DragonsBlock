import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dragons_block/core/storage/app_prefs.dart';
import 'package:dragons_block/features/block_themes/models/block_theme_model.dart';
import 'package:dragons_block/features/block_themes/services/block_theme_manager.dart';
import 'package:dragons_block/features/game/models/block_skin_style.dart';
import 'package:dragons_block/features/shop/services/shop_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    AppPrefs.instance.debugReset();
    await AppPrefs.instance.init();
    await BlockThemeManager.instance.init();
    await ShopManager.instance.loadFromPrefs();
  });

  group('BlockThemeManager Tests', () {
    test('Default initial theme is classic_jewel and palette has 7 colors', () {
      final manager = BlockThemeManager.instance;
      expect(manager.activeThemeId, 'classic_jewel');
      expect(manager.isCustomMixEnabled, false);
      expect(manager.activePalette.length, 7);
      expect(manager.isThemeUnlocked('classic_jewel'), true);
    });

    test('Equipping unlocked theme updates activeThemeId and activePalette', () async {
      final manager = BlockThemeManager.instance;
      // sugar_jelly theme
      await manager.equipTheme('classic_jewel');
      expect(manager.activeThemeId, 'classic_jewel');
      expect(manager.activeStyle, BlockSkinStyle.minimalGlass);
    });

    test('Mix & match custom palette updates slot color and enables custom mix', () async {
      final manager = BlockThemeManager.instance;
      const testColor = Color(0xFFFF0055);
      
      await manager.setCustomSlotColor(0, testColor);
      expect(manager.isCustomMixEnabled, true);
      expect(manager.activePalette[0], testColor);
      expect(manager.customPalette[0], testColor);
    });

    test('Setting block style persists activeStyle', () async {
      final manager = BlockThemeManager.instance;
      await manager.setBlockStyle(BlockSkinStyle.gemstone3D);
      expect(manager.activeStyle, BlockSkinStyle.gemstone3D);
    });

    test('Purchasing shard-based theme checks gold shards and unlocks theme', () async {
      final manager = BlockThemeManager.instance;
      await ShopManager.instance.addShards(500);

      final success = await manager.purchaseTheme('cyber_neon');
      expect(success, true);
      expect(manager.isThemeUnlocked('cyber_neon'), true);
      expect(manager.activeThemeId, 'cyber_neon');
    });

    test('Cloning preset theme to custom palette copies colors', () async {
      final manager = BlockThemeManager.instance;
      final magmaTheme = BlockThemeModel.allThemes.firstWhere((t) => t.id == 'dragon_magma');

      await manager.copyThemeToCustomPalette(magmaTheme);
      expect(manager.isCustomMixEnabled, true);
      expect(manager.activePalette, magmaTheme.palette);
    });
  });
}
