import 'package:flutter/material.dart';
import '../../../core/audio/procedural_audio.dart';
import '../../../core/haptics/haptic_service.dart';
import '../../../core/localization/locale_manager.dart';
import '../../../core/theme/game_theme.dart';
import '../../../core/ui/game_toast.dart';
import '../../game/models/block_skin_style.dart';
import '../../game/presentation/painters/block_skin_painter.dart';
import '../../shop/services/shop_manager.dart';
import '../models/block_theme_model.dart';
import '../services/block_theme_manager.dart';

/// 🎨 Block Studio & Palette Mixer Dialog
/// Provides full customization of block themes, 7-slot Mix & Match palette,
/// material styles (Gemstone, Jelly, Neon, etc.), and interactive live preview.
class BlockStudioDialog extends StatefulWidget {
  const BlockStudioDialog({super.key});

  @override
  State<BlockStudioDialog> createState() => _BlockStudioDialogState();
}

class _BlockStudioDialogState extends State<BlockStudioDialog> with SingleTickerProviderStateMixin {
  final BlockThemeManager _manager = BlockThemeManager.instance;
  final ShopManager _shop = ShopManager.instance;

  int _selectedTab = 0; // 0: Presets, 1: Palette Mixer, 2: Material Style
  int _selectedMixSlot = 0; // 0 to 6
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _manager.addListener(_onUpdated);
    _shop.addListener(_onUpdated);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _manager.removeListener(_onUpdated);
    _shop.removeListener(_onUpdated);
    super.dispose();
  }

  void _onUpdated() {
    if (mounted) setState(() {});
  }

  void _equipTheme(BlockThemeModel theme) async {
    AppHaptics.selection();
    ProceduralAudio.instance.playDialogPop();
    await _manager.equipTheme(theme.id);
    if (!mounted) return;
    GameToast.showSuccess(context, '${theme.name} Kuşanıldı!', title: 'TEMA AKTİF 🎨');
  }

  void _purchaseTheme(BlockThemeModel theme) async {
    if (_shop.goldShards < theme.unlockRequirement) {
      AppHaptics.light();
      ProceduralAudio.instance.playGameOver();
      GameToast.showError(
        context,
        'Yeterli altın parçacığı yok! (Gereken: ${theme.unlockRequirement}🪙)',
        title: 'BAKİYE YETERSİZ',
      );
      return;
    }

    AppHaptics.heavy();
    ProceduralAudio.instance.playPurchase();
    final success = await _manager.purchaseTheme(theme.id);
    if (!mounted) return;

    if (success) {
      GameToast.showGold(context, '${theme.name} kilidi açıldı ve kuşanıldı!', title: 'YENİ TEMA KAZANILDI 🎉');
    }
  }

  void _selectColorForSlot(Color color) async {
    AppHaptics.selection();
    ProceduralAudio.instance.playButtonClick();
    await _manager.setCustomSlotColor(_selectedMixSlot, color);
    if (!mounted) return;
    GameToast.showSuccess(context, 'Slot ${_selectedMixSlot + 1} güncellendi!', title: 'PALET MİKSLENDİ 🎛️');
  }

  void _selectStyle(BlockSkinStyle style) async {
    AppHaptics.selection();
    ProceduralAudio.instance.playButtonClick();
    await _manager.setBlockStyle(style);
    if (!mounted) return;
    GameToast.showSuccess(context, '${style.displayName} kuşanıldı!', title: 'MATERYAL GÜNCELLENDİ ✨');
  }

  @override
  Widget build(BuildContext context) {
    final isTr = LocaleManager.instance.isTurkish;
    final screenHeight = MediaQuery.of(context).size.height;
    final activePalette = _manager.activePalette;
    final activeStyle = _manager.activeStyle;
    final activeTheme = _manager.activeTheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: screenHeight * 0.90,
          maxWidth: 420,
        ),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0A0F24),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFF38BDF8), width: 2.0),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF38BDF8).withValues(alpha: 0.35),
              blurRadius: 28,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('🎨', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.blockStudio,
                          style: const TextStyle(
                            color: Color(0xFF38BDF8),
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            letterSpacing: 0.8,
                          ),
                        ),
                        Text(
                          _manager.isCustomMixEnabled ? (isTr ? 'Özel Miks Palet' : 'Custom Mix') : activeTheme.name,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBBF24).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFFBBF24)),
                      ),
                      child: Row(
                        children: [
                          const Text('🪙', style: TextStyle(fontSize: 11)),
                          const SizedBox(width: 4),
                          Text(
                            '${_shop.goldShards}',
                            style: const TextStyle(
                              color: Color(0xFFFBBF24),
                              fontWeight: FontWeight.w900,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: GameTheme.bgDarkest,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24, width: 1.0),
                        ),
                        child: const Center(
                          child: Icon(Icons.close_rounded, color: Colors.white70, size: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 2. Interactive Live 4x4 Mini Board Showcase
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF1E293B).withValues(alpha: 0.7),
                    const Color(0xFF0F172A),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.4), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                    blurRadius: 14,
                  ),
                ],
              ),
              child: Row(
                children: [
                  // 4x4 Mini Grid Canvas
                  Container(
                    width: 96,
                    height: 96,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF060B18),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: _MiniBoardPainter(
                            palette: activePalette,
                            style: activeStyle,
                            pulse: _pulseController.value,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              activeStyle.displayName,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          activeStyle.description,
                          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 9.5),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        // 7 Palette Dots Preview
                        Row(
                          children: List.generate(activePalette.length.clamp(0, 7), (i) {
                            return Container(
                              width: 13,
                              height: 13,
                              margin: const EdgeInsets.only(right: 4),
                              decoration: BoxDecoration(
                                color: activePalette[i],
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white60, width: 1),
                                boxShadow: [
                                  BoxShadow(
                                    color: activePalette[i].withValues(alpha: 0.6),
                                    blurRadius: 4,
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
            const SizedBox(height: 12),

            // 3. Segmented Tab Switcher (Presets, Palette Mixer, Material Style)
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: GameTheme.bgDarkest,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  _buildTabButton(0, '💎', AppStrings.blockPresets),
                  _buildTabButton(1, '🎛️', AppStrings.paletteMixer),
                  _buildTabButton(2, '✨', AppStrings.blockMaterial),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // 4. Tab Content Area
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _buildCurrentTabContent(isTr),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(int index, String icon, String label) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          AppHaptics.selection();
          ProceduralAudio.instance.playButtonClick();
          setState(() => _selectedTab = index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF38BDF8).withValues(alpha: 0.25) : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: isSelected ? const Color(0xFF38BDF8) : Colors.transparent,
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(icon, style: const TextStyle(fontSize: 11)),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white60,
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                    fontSize: 9.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentTabContent(bool isTr) {
    switch (_selectedTab) {
      case 0:
        return _buildPresetsTab(isTr);
      case 1:
        return _buildMixerTab(isTr);
      case 2:
        return _buildMaterialStyleTab(isTr);
      default:
        return const SizedBox.shrink();
    }
  }

  // ─── TAB 0: PRESET THEMES ──────────────────────────────────────────────────
  Widget _buildPresetsTab(bool isTr) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: BlockThemeModel.allThemes.length,
      itemBuilder: (context, index) {
        final theme = BlockThemeModel.allThemes[index];
        final isUnlocked = _manager.isThemeUnlocked(theme.id);
        final isEquipped = !_manager.isCustomMixEnabled && _manager.activeThemeId == theme.id;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isEquipped
                ? const Color(0xFF38BDF8).withValues(alpha: 0.15)
                : (isUnlocked ? const Color(0xFF0F172A) : Colors.black38),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isEquipped
                  ? const Color(0xFF38BDF8)
                  : (isUnlocked ? Colors.white24 : Colors.white10),
              width: isEquipped ? 1.8 : 1.0,
            ),
          ),
          child: Row(
            children: [
              // Theme Icon Box
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (theme.palette.isNotEmpty ? theme.palette.first : Colors.blue).withValues(alpha: 0.2),
                  border: Border.all(
                    color: theme.palette.isNotEmpty ? theme.palette.first : Colors.blue,
                    width: 1.2,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(theme.icon, style: const TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 10),

              // Theme Info & Palette Dots
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          theme.name,
                          style: TextStyle(
                            color: isUnlocked ? Colors.white : Colors.white54,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                          ),
                        ),
                        if (theme.isPremium) ...[
                          const SizedBox(width: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFBBF24).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0xFFFBBF24), width: 0.8),
                            ),
                            child: const Text(
                              'VIP',
                              style: TextStyle(color: Color(0xFFFBBF24), fontSize: 7.5, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      theme.description,
                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 9),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    // Palette Preview
                    Row(
                      children: List.generate(theme.palette.length.clamp(0, 7), (i) {
                        return Container(
                          width: 9,
                          height: 9,
                          margin: const EdgeInsets.only(right: 3),
                          decoration: BoxDecoration(
                            color: isUnlocked ? theme.palette[i] : Colors.white24,
                            shape: BoxShape.circle,
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Action Button
              if (isEquipped)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF38BDF8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'AKTİF',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 10),
                  ),
                )
              else if (isUnlocked)
                ElevatedButton(
                  onPressed: () => _equipTheme(theme),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E293B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: Color(0xFF38BDF8), width: 1),
                    ),
                  ),
                  child: const Text('KUŞAN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
                )
              else if (theme.unlockType == BlockThemeUnlockType.shards)
                ElevatedButton(
                  onPressed: () => _purchaseTheme(theme),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD97706),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    theme.unlockDescription,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Text(
                    theme.unlockDescription,
                    style: const TextStyle(color: Colors.white54, fontSize: 8.5, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // ─── TAB 1: PALETTE MIXER (MIX & MATCH) ───────────────────────────────────
  Widget _buildMixerTab(bool isTr) {
    final customPalette = _manager.customPalette;

    // Available color swatch bank pulled from all themes
    final allAvailableColors = <Color>{};
    for (final theme in BlockThemeModel.allThemes) {
      allAvailableColors.addAll(theme.palette);
    }
    final colorList = allAvailableColors.toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Hint
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isTr ? '7 RENK SLOTUNU MİKSLE' : 'MIX 7 COLOR SLOTS',
                style: const TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.w900, fontSize: 11),
              ),
              if (_manager.isCustomMixEnabled)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF10B981)),
                  ),
                  child: const Text(
                    'ÖZEL PALET AKTİF ✓',
                    style: TextStyle(color: Color(0xFF10B981), fontSize: 8.5, fontWeight: FontWeight.w900),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // 7 Interactive Slot Selectors
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (slotIdx) {
              final isSlotSelected = _selectedMixSlot == slotIdx;
              final slotColor = slotIdx < customPalette.length ? customPalette[slotIdx] : Colors.blue;

              return GestureDetector(
                onTap: () {
                  AppHaptics.selection();
                  ProceduralAudio.instance.playButtonClick();
                  setState(() => _selectedMixSlot = slotIdx);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 42,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isSlotSelected ? slotColor.withValues(alpha: 0.3) : const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSlotSelected ? Colors.white : slotColor.withValues(alpha: 0.6),
                      width: isSlotSelected ? 2.2 : 1.2,
                    ),
                    boxShadow: isSlotSelected
                        ? [
                            BoxShadow(
                              color: slotColor.withValues(alpha: 0.5),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: slotColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white70, width: 1.2),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '#${slotIdx + 1}',
                        style: TextStyle(
                          color: isSlotSelected ? Colors.white : Colors.white54,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 14),

          // Color Swatch Bank
          Text(
            isTr ? 'Slot ${_selectedMixSlot + 1} İçin Renk Seç:' : 'Select Color for Slot ${_selectedMixSlot + 1}:',
            style: const TextStyle(color: Colors.white70, fontSize: 10.5, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: colorList.map((color) {
              final isCurrent = _selectedMixSlot < customPalette.length && customPalette[_selectedMixSlot] == color;

              return GestureDetector(
                onTap: () => _selectColorForSlot(color),
                child: Container(
                  width: 32,
                  height: 32,
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
                      ? const Center(child: Icon(Icons.check_rounded, color: Colors.white, size: 16))
                      : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          // Quick Preset Cloner
          Text(
            isTr ? 'Hazır Temayı Miksere Kopyala:' : 'Clone Preset to Mixer:',
            style: const TextStyle(color: Colors.white70, fontSize: 10.5, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: BlockThemeModel.allThemes.map((theme) {
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ActionChip(
                    backgroundColor: const Color(0xFF1E293B),
                    side: const BorderSide(color: Colors.white24),
                    label: Text('${theme.icon} ${theme.name}', style: const TextStyle(color: Colors.white, fontSize: 9.5)),
                    onPressed: () async {
                      AppHaptics.medium();
                      ProceduralAudio.instance.playRewardClaim();
                      await _manager.copyThemeToCustomPalette(theme);
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

  // ─── TAB 2: MATERIAL STYLE ─────────────────────────────────────────────────
  Widget _buildMaterialStyleTab(bool isTr) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: BlockSkinStyle.values.length,
      itemBuilder: (context, index) {
        final style = BlockSkinStyle.values[index];
        final isEquipped = _manager.activeStyle == style;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isEquipped
                ? const Color(0xFF38BDF8).withValues(alpha: 0.15)
                : const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isEquipped ? const Color(0xFF38BDF8) : Colors.white12,
              width: isEquipped ? 1.8 : 1.0,
            ),
          ),
          child: Row(
            children: [
              // Single Live Block Canvas
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFF060B18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomPaint(
                  painter: _SingleBlockPainter(
                    color: const Color(0xFF2563EB),
                    style: style,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      style.displayName,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      style.description,
                      style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 9.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (isEquipped)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF38BDF8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'AKTİF',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 10),
                  ),
                )
              else
                ElevatedButton(
                  onPressed: () => _selectStyle(style),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E293B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: Color(0xFF38BDF8), width: 1),
                    ),
                  ),
                  child: const Text('KUŞAN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// 🎨 Interactive 4x4 Mini Board Painter
class _MiniBoardPainter extends CustomPainter {
  final List<Color> palette;
  final BlockSkinStyle style;
  final double pulse;

  _MiniBoardPainter({
    required this.palette,
    required this.style,
    required this.pulse,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const int gridSize = 4;
    final double cellSize = size.width / gridSize;
    const double padding = 1.5;

    final colors = palette.isNotEmpty ? palette : [Colors.blue, Colors.green, Colors.orange, Colors.purple];

    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        final color = colors[(r * gridSize + c) % colors.length];
        final rect = Rect.fromLTWH(
          c * cellSize + padding,
          r * cellSize + padding,
          cellSize - padding * 2,
          cellSize - padding * 2,
        );

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
  bool shouldRepaint(covariant _MiniBoardPainter oldDelegate) {
    return oldDelegate.palette != palette || oldDelegate.style != style || oldDelegate.pulse != pulse;
  }
}

/// 💎 Single Live Block Painter
class _SingleBlockPainter extends CustomPainter {
  final Color color;
  final BlockSkinStyle style;

  _SingleBlockPainter({required this.color, required this.style});

  @override
  void paint(Canvas canvas, Size size) {
    const double padding = 3.0;
    final rect = Rect.fromLTWH(padding, padding, size.width - padding * 2, size.height - padding * 2);
    BlockSkinPainter.drawBlock(
      canvas: canvas,
      rect: rect,
      color: color,
      style: style,
    );
  }

  @override
  bool shouldRepaint(covariant _SingleBlockPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.style != style;
  }
}
