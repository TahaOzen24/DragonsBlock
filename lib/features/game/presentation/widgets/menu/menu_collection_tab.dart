import 'package:flutter/material.dart';

import '../../../../../core/audio/procedural_audio.dart';
import '../../../../../core/haptics/haptic_service.dart';
import '../../../../../core/localization/locale_manager.dart';
import '../../../../../core/ui/game_toast.dart';
import '../../../../block_themes/models/block_theme_model.dart';
import '../../../../block_themes/services/block_theme_manager.dart';
import '../../../../shop/services/shop_manager.dart';
import '../../../models/block_skin_style.dart';
import '../../painters/block_skin_painter.dart';

/// 🎨 Modern & Minimalist Block Collection Screen (Blok Görünümü & Stüdyosu)
/// Dedicated purely to block aesthetics: Themes, 8 Vector Material Styles, and Color Mixer.
class MenuCollectionTab extends StatefulWidget {
  final bool isTab;
  final VoidCallback? onClose;

  const MenuCollectionTab({
    super.key,
    this.isTab = true,
    this.onClose,
  });

  @override
  State<MenuCollectionTab> createState() => _MenuCollectionTabState();
}

class _MenuCollectionTabState extends State<MenuCollectionTab> with SingleTickerProviderStateMixin {
  final BlockThemeManager _themeManager = BlockThemeManager.instance;
  final ShopManager _shopManager = ShopManager.instance;

  int _selectedSubTab = 0; // 0: Temalar, 1: Stiller, 2: Renk Mikseri
  int _activeMixSlot = 0; // 0..6
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _themeManager.addListener(_onStateChanged);
    _shopManager.addListener(_onStateChanged);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _themeManager.removeListener(_onStateChanged);
    _shopManager.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  void _equipTheme(BlockThemeModel theme) async {
    AppHaptics.selection();
    ProceduralAudio.instance.playDialogPop();
    await _themeManager.equipTheme(theme.id);
    if (!mounted) return;
    GameToast.showSuccess(context, '${theme.name} kuşanıldı!', title: 'TEMA AKTİF 🎨');
  }

  void _purchaseTheme(BlockThemeModel theme) async {
    if (_shopManager.goldShards < theme.unlockRequirement) {
      AppHaptics.light();
      ProceduralAudio.instance.playGameOver();
      GameToast.showError(
        context,
        'Yetersiz altın parçacığı! (Gereken: ${theme.unlockRequirement} 🪙)',
        title: 'BAKİYE YETERSİZ',
      );
      return;
    }

    AppHaptics.heavy();
    ProceduralAudio.instance.playPurchase();
    final success = await _themeManager.purchaseTheme(theme.id);
    if (!mounted) return;

    if (success) {
      GameToast.showGold(
        context,
        '${theme.name} kilidi açıldı ve kuşanıldı!',
        title: 'YENİ BLOK TEMASI 🎉',
      );
    }
  }

  void _equipStyle(BlockSkinStyle style) async {
    AppHaptics.selection();
    ProceduralAudio.instance.playButtonClick();
    await _themeManager.setBlockStyle(style);
    if (!mounted) return;
    GameToast.showSuccess(context, '${style.displayName} kuşanıldı!', title: 'BLOK STİLİ AKTİF ✨');
  }

  void _changeMixSlotColor(Color color) async {
    AppHaptics.selection();
    ProceduralAudio.instance.playButtonClick();
    await _themeManager.setCustomSlotColor(_activeMixSlot, color);
    if (!mounted) return;
    GameToast.showSuccess(context, 'Slot ${_activeMixSlot + 1} güncellendi!', title: 'RENK MİKSLENDİ 🎛️');
  }

  @override
  Widget build(BuildContext context) {
    final activePalette = _themeManager.activePalette;
    final activeStyle = _themeManager.activeStyle;
    final activeTheme = _themeManager.activeTheme;
    final isCustomMix = _themeManager.isCustomMixEnabled;

    return Container(
      color: Colors.transparent,
      child: Column(
        children: [
          // 1. Top Clean Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('🎨', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Text(
                          AppStrings.navCollection.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      LocaleManager.instance.isTurkish
                          ? 'Blok görünümü, temalar ve materyal stüdyosu'
                          : 'Block appearance, themes and material studio',
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                // Gold Shards Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFFBBF24).withValues(alpha: 0.6), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFBBF24).withValues(alpha: 0.2),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🪙', style: TextStyle(fontSize: 13)),
                      const SizedBox(width: 5),
                      Text(
                        '${_shopManager.goldShards}',
                        style: const TextStyle(
                          color: Color(0xFFFBBF24),
                          fontWeight: FontWeight.w900,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. Hero Interactive Live Block Showcase
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF162038),
                    Color(0xFF0C1322),
                  ],
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: const Color(0xFF38BDF8).withValues(alpha: 0.5),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF38BDF8).withValues(alpha: 0.20),
                    blurRadius: 18,
                    spreadRadius: 1,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Animated 3x3 Block Showcase Cluster
                  Container(
                    width: 98,
                    height: 98,
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF070B16),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.3)),
                    ),
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, _) {
                        return CustomPaint(
                          painter: _CollectionLiveHeroPainter(
                            palette: activePalette,
                            style: activeStyle,
                            pulse: _pulseController.value,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Showcase Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF38BDF8).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFF38BDF8), width: 0.8),
                              ),
                              child: Text(
                                isCustomMix ? 'ÖZEL PALET' : 'AKTİF TEMA',
                                style: const TextStyle(
                                  color: Color(0xFF38BDF8),
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              activeStyle.displayName,
                              style: const TextStyle(
                                color: Color(0xFFFDE047),
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isCustomMix ? 'Özel Miks Palet' : activeTheme.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          activeStyle.description,
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 10,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),

                        // Active 7 Color Dots Row
                        Row(
                          children: List.generate(activePalette.length.clamp(0, 7), (idx) {
                            final c = activePalette[idx];
                            return Container(
                              width: 15,
                              height: 15,
                              margin: const EdgeInsets.only(right: 5),
                              decoration: BoxDecoration(
                                color: c,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white70, width: 1.2),
                                boxShadow: [
                                  BoxShadow(
                                    color: c.withValues(alpha: 0.6),
                                    blurRadius: 5,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Three Clean Segmented Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  _buildSegmentButton(0, '💎', 'TEMALAR'),
                  _buildSegmentButton(1, '✨', 'STİLLER'),
                  _buildSegmentButton(2, '🎛️', 'MİKSER'),
                ],
              ),
            ),
          ),

          // 4. Tab Body Area
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: _buildSubTabContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentButton(int index, String icon, String title) {
    final isSelected = _selectedSubTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          AppHaptics.selection();
          ProceduralAudio.instance.playButtonClick();
          setState(() => _selectedSubTab = index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF38BDF8).withValues(alpha: 0.25) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFF38BDF8) : Colors.transparent,
              width: 1.2,
            ),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(icon, style: const TextStyle(fontSize: 12)),
              const SizedBox(width: 5),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white60,
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubTabContent() {
    switch (_selectedSubTab) {
      case 0:
        return _buildThemesList();
      case 1:
        return _buildStylesGrid();
      case 2:
        return _buildMixerSection();
      default:
        return const SizedBox.shrink();
    }
  }

  // ─── 1. TEMALAR (THEMES) ───────────────────────────────────────────────────
  Widget _buildThemesList() {
    final themes = BlockThemeModel.allThemes;

    return ListView.builder(
      key: const ValueKey('themes_list'),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
      physics: const BouncingScrollPhysics(),
      itemCount: themes.length,
      itemBuilder: (context, index) {
        final theme = themes[index];
        final isUnlocked = _themeManager.isThemeUnlocked(theme.id);
        final isEquipped = !_themeManager.isCustomMixEnabled && _themeManager.activeThemeId == theme.id;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isEquipped
                ? const Color(0xFF0284C7).withValues(alpha: 0.20)
                : (isUnlocked ? const Color(0xFF131D33) : const Color(0xFF0A0F1D)),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isEquipped
                  ? const Color(0xFF38BDF8)
                  : (isUnlocked ? Colors.white12 : Colors.white10),
              width: isEquipped ? 1.8 : 1.0,
            ),
            boxShadow: isEquipped
                ? [
                    BoxShadow(
                      color: const Color(0xFF38BDF8).withValues(alpha: 0.25),
                      blurRadius: 12,
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              // Icon Circle
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (theme.palette.isNotEmpty ? theme.palette.first : Colors.blue).withValues(alpha: 0.25),
                  border: Border.all(
                    color: theme.palette.isNotEmpty ? theme.palette.first : Colors.blue,
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(theme.icon, style: const TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 12),

              // Info & Spectrum
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          theme.name,
                          style: TextStyle(
                            color: isUnlocked ? Colors.white : Colors.white60,
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                        ),
                        if (theme.isPremium) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFBBF24).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: const Color(0xFFFBBF24), width: 0.8),
                            ),
                            child: const Text(
                              'VIP',
                              style: TextStyle(color: Color(0xFFFBBF24), fontSize: 8, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      theme.description,
                      style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    // Color Spectrum Dots
                    Row(
                      children: List.generate(theme.palette.length.clamp(0, 7), (i) {
                        return Container(
                          width: 11,
                          height: 11,
                          margin: const EdgeInsets.only(right: 4),
                          decoration: BoxDecoration(
                            color: isUnlocked ? theme.palette[i] : Colors.white24,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white30, width: 0.8),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Button / Status
              if (isEquipped)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF38BDF8),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF38BDF8).withValues(alpha: 0.4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Text(
                    'AKTİF ✓',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 11),
                  ),
                )
              else if (isUnlocked)
                ElevatedButton(
                  onPressed: () => _equipTheme(theme),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E293B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Color(0xFF38BDF8), width: 1.2),
                    ),
                  ),
                  child: const Text('KUŞAN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
                )
              else if (theme.unlockType == BlockThemeUnlockType.shards)
                ElevatedButton(
                  onPressed: () => _purchaseTheme(theme),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD97706),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    theme.unlockDescription,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Text(
                    theme.unlockDescription,
                    style: const TextStyle(color: Colors.white54, fontSize: 9.5, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // ─── 2. STİLLER (8 VECTOR MATERIAL MODELS) ─────────────────────────────────
  Widget _buildStylesGrid() {
    final styles = BlockSkinStyle.values;
    final activeStyle = _themeManager.activeStyle;
    final primaryColor = _themeManager.activePalette.isNotEmpty
        ? _themeManager.activePalette.first
        : const Color(0xFF2563EB);

    return ListView.builder(
      key: const ValueKey('styles_list'),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
      physics: const BouncingScrollPhysics(),
      itemCount: styles.length,
      itemBuilder: (context, index) {
        final style = styles[index];
        final isEquipped = activeStyle == style;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isEquipped
                ? const Color(0xFF0284C7).withValues(alpha: 0.20)
                : const Color(0xFF131D33),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isEquipped ? const Color(0xFF38BDF8) : Colors.white12,
              width: isEquipped ? 1.8 : 1.0,
            ),
            boxShadow: isEquipped
                ? [
                    BoxShadow(
                      color: const Color(0xFF38BDF8).withValues(alpha: 0.25),
                      blurRadius: 12,
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              // Live Single Block Vector Rendering
              Container(
                width: 44,
                height: 44,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: const Color(0xFF070B16),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: CustomPaint(
                  painter: _SingleBlockVectorPainter(
                    color: primaryColor,
                    style: style,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Title & Description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      style.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      style.description,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Equip / Active Button
              if (isEquipped)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF38BDF8),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF38BDF8).withValues(alpha: 0.4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Text(
                    'AKTİF ✓',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 11),
                  ),
                )
              else
                ElevatedButton(
                  onPressed: () => _equipStyle(style),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E293B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Color(0xFF38BDF8), width: 1.2),
                    ),
                  ),
                  child: const Text('KUŞAN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
                ),
            ],
          ),
        );
      },
    );
  }

  // ─── 3. MİKSER (7-SLOT CUSTOM MIXER) ───────────────────────────────────────
  Widget _buildMixerSection() {
    final customPalette = _themeManager.customPalette;

    // Build curated color bank from all themes
    final allColors = <Color>{};
    for (final theme in BlockThemeModel.allThemes) {
      allColors.addAll(theme.palette);
    }
    final colorList = allColors.toList();

    return SingleChildScrollView(
      key: const ValueKey('mixer_section'),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hint Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '7 RENK SLOTUNU KENDİN BELİRLE:',
                style: TextStyle(
                  color: Color(0xFF38BDF8),
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                  letterSpacing: 0.5,
                ),
              ),
              if (_themeManager.isCustomMixEnabled)
                TextButton(
                  onPressed: () async {
                    AppHaptics.selection();
                    ProceduralAudio.instance.playButtonClick();
                    await _themeManager.toggleCustomMix(false);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF38BDF8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  ),
                  child: Text(
                    AppStrings.useThemePalette,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900),
                  ),
                )
              else
                const SizedBox.shrink(),
            ],
          ),
          const SizedBox(height: 10),

          // 7 Interactive Slot Cards
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (slotIdx) {
              final isSelected = _activeMixSlot == slotIdx;
              final color = slotIdx < customPalette.length ? customPalette[slotIdx] : Colors.blue;

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    AppHaptics.selection();
                    ProceduralAudio.instance.playButtonClick();
                    setState(() => _activeMixSlot = slotIdx);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.symmetric(horizontal: 2.5),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? color.withValues(alpha: 0.35) : const Color(0xFF131D33),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? Colors.white : color.withValues(alpha: 0.6),
                        width: isSelected ? 2.0 : 1.0,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: color.withValues(alpha: 0.6),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.2),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '#${slotIdx + 1}',
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white60,
                            fontWeight: FontWeight.w900,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),

          // Color Palette Swatches Bank
          Text(
            'Slot ${_activeMixSlot + 1} için renk seçin:',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: colorList.map((color) {
              final isCurrent = _activeMixSlot < customPalette.length && customPalette[_activeMixSlot] == color;

              return GestureDetector(
                onTap: () => _changeMixSlotColor(color),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCurrent ? Colors.white : Colors.white24,
                      width: isCurrent ? 2.5 : 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.4),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: isCurrent
                      ? const Center(child: Icon(Icons.check_rounded, color: Colors.white, size: 18))
                      : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),

          // Preset Cloner
          const Text(
            'Hazır temadan kopyala:',
            style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: BlockThemeModel.allThemes.map((theme) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    backgroundColor: const Color(0xFF1E293B),
                    side: const BorderSide(color: Colors.white24),
                    label: Text('${theme.icon} ${theme.name}', style: const TextStyle(color: Colors.white, fontSize: 10)),
                    onPressed: () async {
                      AppHaptics.medium();
                      ProceduralAudio.instance.playRewardClaim();
                      await _themeManager.copyThemeToCustomPalette(theme);
                      if (!mounted) return;
                      GameToast.showSuccess(context, '${theme.name} miksere kopyalandı!', title: 'PALET YÜKLENDİ 📋');
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Hero 3x3 Live Block Preview Canvas
class _CollectionLiveHeroPainter extends CustomPainter {
  final List<Color> palette;
  final BlockSkinStyle style;
  final double pulse;

  _CollectionLiveHeroPainter({
    required this.palette,
    required this.style,
    required this.pulse,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (palette.isEmpty) return;
    const int cols = 3;
    const int rows = 3;
    final double pad = 4.0;
    final double cellSize = (size.width - (cols + 1) * pad) / cols;

    // Distinct attractive 3x3 shape pattern (plus-like tetromino combo)
    final pattern = [
      [1, 1, 0],
      [0, 1, 1],
      [1, 0, 1],
    ];

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (pattern[r][c] == 0) continue;
        final rect = Rect.fromLTWH(
          pad + c * (cellSize + pad),
          pad + r * (cellSize + pad),
          cellSize,
          cellSize,
        );
        final colorIndex = (r * cols + c) % palette.length;
        final color = palette[colorIndex];

        BlockSkinPainter.drawBlock(
          canvas: canvas,
          rect: rect,
          color: color,
          style: style,
          pulse: pulse,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CollectionLiveHeroPainter oldDelegate) {
    return oldDelegate.palette != palette ||
        oldDelegate.style != style ||
        oldDelegate.pulse != pulse;
  }
}

/// Single Vector Block Painter for style cards
class _SingleBlockVectorPainter extends CustomPainter {
  final Color color;
  final BlockSkinStyle style;

  _SingleBlockVectorPainter({required this.color, required this.style});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(1, 1, size.width - 2, size.height - 2);
    BlockSkinPainter.drawBlock(
      canvas: canvas,
      rect: rect,
      color: color,
      style: style,
    );
  }

  @override
  bool shouldRepaint(covariant _SingleBlockVectorPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.style != style;
  }
}
