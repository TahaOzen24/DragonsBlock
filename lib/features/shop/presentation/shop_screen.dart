import 'package:flutter/material.dart';
import '../../../core/audio/procedural_audio.dart';
import '../../../core/ads/ad_service.dart';
import '../../../core/haptics/haptic_service.dart';
import '../../../core/localization/locale_manager.dart';
import '../../../core/theme/game_theme.dart';
import '../../../core/ui/game_toast.dart';
import '../../../core/ui/vector_assets/vector_assets.dart';
import '../../../core/iap/iap_service.dart';
import '../../block_themes/models/block_theme_model.dart';
import '../../block_themes/presentation/block_studio_dialog.dart';
import '../../block_themes/services/block_theme_manager.dart';
import '../models/board_skin.dart';
import '../models/clear_fx_style.dart';
import '../services/shop_manager.dart';
import '../../rewards/presentation/daily_reward_dialog.dart';
import '../../rewards/presentation/idle_vault_dialog.dart';
import '../../rewards/presentation/lucky_wheel_dialog.dart';
import 'widgets/shop_godray_painter.dart';
import 'widgets/shop_live_board_preview.dart';
import 'widgets/shop_live_vfx_preview.dart';
import 'widgets/shop_hero_deal_banner.dart';

/// 🛒 AAA Büyü Mağazası (Shop Screen)
/// Supercell / Brawl Stars / Royal Match kalitesinde canlı, nefes alan,
/// ışık hüzmeli (godrays), animasyonlu ve interaktif mobil market mimarisi.
class ShopScreen extends StatefulWidget {
  final bool isTab;
  const ShopScreen({super.key, this.isTab = false});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final ShopManager _shop = ShopManager.instance;
  final BlockThemeManager _blockThemeManager = BlockThemeManager.instance;
  int _selectedCategory = 0; // 0: Blok & Temalar, 1: Patlatma VFX, 2: Altın & VIP, 3: Ücretsiz

  @override
  void initState() {
    super.initState();
    _shop.addListener(_onShopUpdated);
    _blockThemeManager.addListener(_onShopUpdated);
    IapService.instance.addListener(_onShopUpdated);
    LocaleManager.instance.addListener(_onShopUpdated);
  }

  @override
  void dispose() {
    _shop.removeListener(_onShopUpdated);
    _blockThemeManager.removeListener(_onShopUpdated);
    IapService.instance.removeListener(_onShopUpdated);
    LocaleManager.instance.removeListener(_onShopUpdated);
    super.dispose();
  }

  void _onShopUpdated() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isTab ? Colors.transparent : const Color(0xFF060918),
      appBar: widget.isTab
          ? null
          : AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: Navigator.canPop(context)
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                      onPressed: () {
                        ProceduralAudio.instance.playButtonClick();
                        Navigator.of(context).pop();
                      },
                    )
                  : null,
              title: Text(
                AppStrings.ancientMagicShop,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
              actions: [
                _buildShardBalanceBadge(),
              ],
            ),
      body: SafeArea(
        child: Column(
          children: [
            _buildRewardsQuickRow(),
            _buildCategoryTabs(),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _buildActiveCategoryContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardsQuickRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 2),
      child: Row(
        children: [
          Expanded(
            child: _RewardQuickTile(
              asset: 'assets/images/ui/icon_gift.png',
              label: 'Günlük',
              accent: const Color(0xFFFBBF24),
              onTap: () async {
                AppHaptics.light();
                ProceduralAudio.instance.playDialogPop();
                await showDialog(
                  context: context,
                  builder: (_) => const DailyRewardDialog(),
                );
                if (mounted) setState(() {});
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _RewardQuickTile(
              asset: 'assets/images/ui/icon_spin.png',
              label: 'Çark',
              accent: const Color(0xFF38BDF8),
              onTap: () async {
                AppHaptics.light();
                ProceduralAudio.instance.playDialogPop();
                await showDialog(
                  context: context,
                  builder: (_) => const LuckyWheelDialog(),
                );
                if (mounted) setState(() {});
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _RewardQuickTile(
              asset: 'assets/images/ui/icon_honey_pot.png',
              label: 'Sandık',
              accent: const Color(0xFFF59E0B),
              onTap: () async {
                AppHaptics.light();
                ProceduralAudio.instance.playDialogPop();
                await showDialog(
                  context: context,
                  builder: (_) => const IdleVaultDialog(),
                );
                if (mounted) setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShardBalanceBadge() {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1836),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2563EB), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.25),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🪙', style: TextStyle(fontSize: 13)),
          const SizedBox(width: 4),
          Text(
            '${_shop.goldShards}',
            style: const TextStyle(
              color: Color(0xFF38BDF8),
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    final categories = [
      {'icon': '🎨', 'label': AppStrings.shopTabThemes},
      {'icon': '✨', 'label': AppStrings.shopTabVfx},
      {'icon': '🪙', 'label': AppStrings.shopTabBundles},
      {'icon': '🎁', 'label': AppStrings.shopTabFree},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E293B), width: 1.2),
      ),
      child: Row(
        children: List.generate(categories.length, (idx) {
          final isSel = _selectedCategory == idx;
          final cat = categories[idx];
          return Expanded(
            child: InkWell(
              onTap: () {
                AppHaptics.selection();
                ProceduralAudio.instance.playTabSwitch();
                setState(() => _selectedCategory = idx);
              },
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  gradient: isSel
                      ? const LinearGradient(
                          colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                        )
                      : null,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSel
                      ? [
                          BoxShadow(
                            color: const Color(0xFF2563EB).withValues(alpha: 0.45),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(cat['icon']!, style: const TextStyle(fontSize: 13)),
                    const SizedBox(width: 4),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          cat['label']!,
                          style: TextStyle(
                            color: isSel ? Colors.white : GameTheme.textMuted,
                            fontWeight: isSel ? FontWeight.w900 : FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildActiveCategoryContent() {
    switch (_selectedCategory) {
      case 0:
        return _buildThemesAndSkinsContent();
      case 1:
        return _buildVfxContent();
      case 2:
        return _buildBundlesContent();
      case 3:
      default:
        return _buildFreeRewardsContent();
    }
  }

  // ─── 1. Blok & Tahta Temaları (Block & Board Cosmetics) ──────────────────────
  Widget _buildThemesAndSkinsContent() {
    return ListView(
      key: const ValueKey(0),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      children: [
        // 🌟 1. Daily Hero Deal Banner
        ShopHeroDealBanner(
          onPurchased: () => setState(() {}),
        ),
        const SizedBox(height: 12),

        // 🎨 2. Blok Renk & Palet Temaları Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text('🌈', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Text(
                  AppStrings.shopBlockColorThemes,
                  style: const TextStyle(
                    color: Color(0xFF38BDF8),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
            InkWell(
              onTap: () {
                ProceduralAudio.instance.playDialogPop();
                showDialog(
                  context: context,
                  builder: (_) => const BlockStudioDialog(),
                ).then((_) {
                  if (mounted) setState(() {});
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: const Color(0xFF38BDF8).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF38BDF8)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🎛️', style: TextStyle(fontSize: 9.5)),
                    const SizedBox(width: 4),
                    Text(
                      AppStrings.shopPaletteMixerCta,
                      style: const TextStyle(
                        color: Color(0xFF38BDF8),
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // 8 Blok Teması Grid Listesi
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: BlockThemeModel.allThemes.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.86,
          ),
          itemBuilder: (context, index) {
            final theme = BlockThemeModel.allThemes[index];
            final isUnlocked = _blockThemeManager.isThemeUnlocked(theme.id);
            final isEquipped = !_blockThemeManager.isCustomMixEnabled && _blockThemeManager.activeThemeId == theme.id;
            final primaryColor = theme.palette.isNotEmpty ? theme.palette.first : const Color(0xFF38BDF8);

            return Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isEquipped ? const Color(0xFF1E1B4B) : const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isEquipped
                      ? const Color(0xFF38BDF8)
                      : (isUnlocked ? primaryColor.withValues(alpha: 0.5) : Colors.white12),
                  width: isEquipped ? 2.0 : 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isEquipped
                        ? const Color(0xFF38BDF8).withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.3),
                    blurRadius: isEquipped ? 14 : 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Icon + Palette Dots
                  Column(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: primaryColor.withValues(alpha: 0.2),
                          border: Border.all(color: primaryColor, width: 1.2),
                        ),
                        alignment: Alignment.center,
                        child: Text(theme.icon, style: const TextStyle(fontSize: 20)),
                      ),
                      const SizedBox(height: 6),
                      // 7 Color Dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(theme.palette.length.clamp(0, 7), (i) {
                          return Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 1.5),
                            decoration: BoxDecoration(
                              color: isUnlocked ? theme.palette[i] : Colors.white24,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white60, width: 0.6),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),

                  // Title & Description
                  Column(
                    children: [
                      Text(
                        theme.name,
                        style: TextStyle(
                          color: isEquipped ? const Color(0xFF38BDF8) : Colors.white,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w900,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        theme.description,
                        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 9),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),

                  // Action Button
                  if (isEquipped)
                    Container(
                      width: double.infinity,
                      height: 26,
                      decoration: BoxDecoration(
                        color: const Color(0xFF38BDF8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        AppStrings.shopEquippedCheck,
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 10),
                      ),
                    )
                  else if (isUnlocked)
                    SizedBox(
                      width: double.infinity,
                      height: 26,
                      child: ElevatedButton(
                        onPressed: () async {
                          AppHaptics.selection();
                          ProceduralAudio.instance.playDialogPop();
                          await _blockThemeManager.equipTheme(theme.id);
                          if (!context.mounted) return;
                          GameToast.showSuccess(context, AppStrings.themeEquippedMsg(theme.name), title: AppStrings.shopThemeActiveTitle);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E293B),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.zero,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(color: Color(0xFF38BDF8), width: 1),
                          ),
                        ),
                        child: Text(AppStrings.equipSigil, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
                      ),
                    )
                  else if (theme.unlockType == BlockThemeUnlockType.shards)
                    SizedBox(
                      width: double.infinity,
                      height: 26,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_shop.goldShards < theme.unlockRequirement) {
                            AppHaptics.light();
                            ProceduralAudio.instance.playGameOver();
                            GameToast.showError(context, AppStrings.shopNotEnoughGold, title: AppStrings.shopBalanceLowTitle);
                            return;
                          }
                          AppHaptics.heavy();
                          ProceduralAudio.instance.playPurchase();
                          final success = await _blockThemeManager.purchaseTheme(theme.id);
                          if (!context.mounted) return;
                          if (success) {
                            GameToast.showGold(context, AppStrings.themeUnlockedMsg(theme.name), title: AppStrings.shopThemeUnlockedTitle);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD97706),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.zero,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('🪙', style: TextStyle(fontSize: 10)),
                            const SizedBox(width: 3),
                            Text(
                              '${theme.unlockRequirement}',
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10.5),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Container(
                      width: double.infinity,
                      height: 26,
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        theme.unlockDescription,
                        style: const TextStyle(color: Colors.white54, fontSize: 8.5, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 16),

        // 🎨 3. Kadim Tahta Temaları Header
        Row(
          children: [
            const Text('🏛️', style: TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(
              AppStrings.shopAncientBoards,
              style: const TextStyle(
                color: Color(0xFF38BDF8),
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: BoardSkin.defaultSkins.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.84,
          ),
          itemBuilder: (context, index) {
            final skin = BoardSkin.defaultSkins[index];
            final isUnlocked = _shop.isSkinUnlocked(skin.id);
            final isSelected = _shop.activeSkinId == skin.id;

            return InkWell(
              onTap: () {
                ProceduralAudio.instance.playDialogPop();
                _showSkinPreview(context, skin);
              },
              borderRadius: BorderRadius.circular(18),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF1E1B4B) : const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isSelected
                        ? skin.primaryGlow
                        : (isUnlocked ? const Color(0xFF3B82F6).withValues(alpha: 0.5) : Colors.white12),
                    width: isSelected ? 2.0 : 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected
                          ? skin.primaryGlow.withValues(alpha: 0.35)
                          : Colors.black.withValues(alpha: 0.3),
                      blurRadius: isSelected ? 14 : 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Live 3D Candy-Gem Mini Board Preview
                    ShopLiveBoardPreview(
                      skin: skin,
                      height: 68,
                    ),
                    const SizedBox(height: 3),

                    // Title & Description
                    Column(
                      children: [
                        Text(
                          '${skin.previewEmoji} ${skin.name}',
                          style: TextStyle(
                            color: isSelected ? skin.primaryGlow : Colors.white,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w900,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          skin.description,
                          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 9),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),

                    // Action Button
                    if (isUnlocked)
                      SizedBox(
                        width: double.infinity,
                        height: 26,
                        child: ElevatedButton(
                          onPressed: isSelected
                              ? null
                              : () {
                                  AppHaptics.selection();
                                  ProceduralAudio.instance.playButtonClick();
                                  _shop.selectSkin(skin.id);
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isSelected ? const Color(0xFF0284C7) : const Color(0xFF1E293B),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.zero,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text(
                            isSelected ? AppStrings.shopEquippedCheck : AppStrings.equipSigil,
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900),
                          ),
                        ),
                      )
                    else
                      SizedBox(
                        width: double.infinity,
                        height: 26,
                        child: ElevatedButton(
                          onPressed: () async {
                            bool success = await _shop.purchaseSkin(skin);
                            if (!context.mounted) return;
                            if (success) {
                              AppHaptics.heavy();
                              ProceduralAudio.instance.playPurchase();
                              GameToast.showSuccess(context, AppStrings.themeUnlockedMsg(skin.name), title: AppStrings.shopThemeUnlockedTitle);
                            } else {
                              AppHaptics.light();
                              ProceduralAudio.instance.playGameOver();
                              GameToast.showError(context, AppStrings.shopNotEnoughGold, title: AppStrings.shopBalanceLowTitle);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: skin.primaryGlow,
                            foregroundColor: Colors.black,
                            padding: EdgeInsets.zero,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('🪙', style: TextStyle(fontSize: 10)),
                              const SizedBox(width: 3),
                              Text(
                                '${skin.priceShards}',
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10.5),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  // ─── 2. Efektler (Clear FX Styles) ──────────────────────────────────────────
  Widget _buildVfxContent() {
    return ListView(
      key: const ValueKey(1),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      children: [
        // Section Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Row(
            children: [
              const Text('✨', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text(
                AppStrings.shopLiveVfxHeader,
                style: const TextStyle(
                  color: Color(0xFFA855F7),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: ClearFxStyle.allStyles.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.82,
          ),
          itemBuilder: (context, index) {
            final fx = ClearFxStyle.allStyles[index];
            final isUnlocked = _shop.isFxUnlocked(fx.id);
            final isSelected = _shop.activeFxId == fx.id;

            return InkWell(
              onTap: () {
                AppHaptics.selection();
                ProceduralAudio.instance.playButtonClick();
                if (isUnlocked) {
                  _shop.selectFx(fx.id);
                }
              },
              borderRadius: BorderRadius.circular(18),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF1E1B4B) : const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isSelected ? fx.primaryColor : (isUnlocked ? const Color(0xFF334155) : Colors.white12),
                    width: isSelected ? 2.0 : 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected
                          ? fx.primaryColor.withValues(alpha: 0.35)
                          : Colors.black.withValues(alpha: 0.3),
                      blurRadius: isSelected ? 14 : 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 💥 Real-Time Animated Blast VFX Preview
                    ShopLiveVfxPreview(
                      fxStyle: fx,
                      size: 66,
                    ),
                    const SizedBox(height: 3),

                    // Title & Description
                    Column(
                      children: [
                        Text(
                          '${fx.icon} ${fx.name}',
                          style: TextStyle(
                            color: isSelected ? fx.primaryColor : Colors.white,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w900,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          fx.description,
                          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 9),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),

                    if (isUnlocked)
                      SizedBox(
                        width: double.infinity,
                        height: 26,
                        child: ElevatedButton(
                          onPressed: isSelected
                              ? null
                              : () {
                                  AppHaptics.selection();
                                  ProceduralAudio.instance.playButtonClick();
                                  _shop.selectFx(fx.id);
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isSelected ? const Color(0xFF0284C7) : const Color(0xFF1E293B),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.zero,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text(
                            isSelected ? AppStrings.shopEquippedCheck : AppStrings.equipSigil,
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900),
                          ),
                        ),
                      )
                    else
                      SizedBox(
                        width: double.infinity,
                        height: 26,
                        child: ElevatedButton(
                          onPressed: () async {
                            bool success = await _shop.purchaseFx(fx);
                            if (!context.mounted) return;
                            if (success) {
                              AppHaptics.heavy();
                              ProceduralAudio.instance.playPurchase();
                              GameToast.showSuccess(context, AppStrings.fxUnlockedMsg(fx.name), title: AppStrings.shopVfxUnlockedTitle);
                            } else {
                              AppHaptics.light();
                              ProceduralAudio.instance.playGameOver();
                              GameToast.showError(context, AppStrings.shopNotEnoughGold, title: AppStrings.shopBalanceLowTitle);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: fx.primaryColor,
                            foregroundColor: Colors.black,
                            padding: EdgeInsets.zero,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('🪙', style: TextStyle(fontSize: 10)),
                              const SizedBox(width: 3),
                              Text(
                                '${fx.cost}',
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10.5),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  // ─── 3. Altın & VIP Paketleri (Real In-App Purchase) ─────────────────────
  Widget _buildBundlesContent() {
    final iap = IapService.instance;

    return ListView(
      key: const ValueKey(2),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      children: [
        // Section Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Row(
            children: [
              const Text('🪙', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text(
                AppStrings.shopGoldVipHeader,
                style: const TextStyle(
                  color: Color(0xFFFBBF24),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        ...IapService.catalog.where((item) => item.id != 'battle_pass_premium').map((item) {
          final isNoAds = item.id == 'no_ads_lifetime';
          final isOwned = isNoAds && iap.hasNoAds;
          final localizedPrice = iap.getLocalizedPrice(item.id);

          final Color accentColor = switch (item.id) {
            'shards_tier1_500' => const Color(0xFF38BDF8),
            'shards_tier2_1500' => const Color(0xFFFBBF24),
            'shards_tier3_5000' => const Color(0xFFA855F7),
            'no_ads_lifetime' => const Color(0xFFEF4444),
            _ => const Color(0xFF38BDF8),
          };

          final String? valueTag = switch (item.id) {
            'shards_tier2_1500' => AppStrings.shopTagPopular,
            'shards_tier3_5000' => AppStrings.shopTagValue,
            'no_ads_lifetime' => AppStrings.shopTagLifetime,
            _ => null,
          };

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  accentColor.withValues(alpha: 0.22),
                  const Color(0xFF0F172A),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isOwned ? const Color(0xFF10B981) : accentColor.withValues(alpha: 0.7),
                width: isOwned ? 2.0 : 1.4,
              ),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.25),
                  blurRadius: 14,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  // Content Row
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        // Animated Chest with Rotating Godrays
                        ShopGodrayBackground(
                          rayColor: accentColor,
                          size: 56,
                          speed: 8.0,
                          child: item.id.contains('tier1')
                              ? const VectorTreasureChest(tier: ChestTier.bronze, size: 42)
                              : item.id.contains('tier2')
                                  ? const VectorTreasureChest(tier: ChestTier.silver, size: 42)
                                      : item.id.contains('tier3')
                                          ? const VectorTreasureChest(tier: ChestTier.gold, size: 42)
                                          : Container(
                                              width: 42,
                                              height: 42,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: accentColor.withValues(alpha: 0.25),
                                                border: Border.all(color: accentColor, width: 1.5),
                                              ),
                                              alignment: Alignment.center,
                                              child: Text(item.icon, style: const TextStyle(fontSize: 22)),
                                            ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      item.title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w900,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (valueTag != null) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                      decoration: BoxDecoration(
                                        color: accentColor.withValues(alpha: 0.3),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: accentColor, width: 0.8),
                                      ),
                                      child: Text(
                                        valueTag,
                                        style: TextStyle(
                                          color: accentColor,
                                          fontSize: 8,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                  if (isOwned) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF10B981).withValues(alpha: 0.3),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        AppStrings.shopOwned,
                                        style: const TextStyle(color: Color(0xFF10B981), fontSize: 8, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.description,
                                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: isOwned
                              ? null
                              : () async {
                                  AppHaptics.heavy();
                                  ProceduralAudio.instance.playButtonClick();
                                  final success = await iap.buyProduct(item.id);
                                  if (!mounted) return;
                                  if (success) {
                                    GameToast.showGold(
                                      context,
                                      AppStrings.shopPaymentOpened,
                                      title: AppStrings.shopPaymentTitle,
                                    );
                                  } else {
                                    GameToast.showError(
                                      context,
                                      iap.lastError ?? AppStrings.shopPurchaseFailed,
                                      title: AppStrings.shop,
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isOwned ? Colors.white12 : accentColor,
                            foregroundColor: isOwned ? Colors.white38 : Colors.black,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            minimumSize: const Size(72, 34),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text(
                            isOwned ? AppStrings.activeLabel : localizedPrice,
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),

        const SizedBox(height: 6),

        // Restore Purchases Button
        Center(
          child: TextButton.icon(
            onPressed: () async {
              AppHaptics.light();
              ProceduralAudio.instance.playButtonClick();
              await iap.restorePurchases();
              if (!mounted) return;
              GameToast.showSuccess(context, AppStrings.shopRestoreDone, title: AppStrings.shopRestoreTitle);
            },
            icon: const Icon(Icons.restore_rounded, size: 16, color: Colors.white54),
            label: Text(
              AppStrings.shopRestorePurchases,
              style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  // ─── 4. Ücretsiz & Ödüller (Free & Rewarded Ads) ────────────────────────────
  Widget _buildFreeRewardsContent() {
    return ListView(
      key: const ValueKey(3),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      children: [
        // Rewarded Ad Box
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFB45309), Color(0xFF78350F), Color(0xFF0F172A)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFBBF24), width: 1.6),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const ShopGodrayBackground(
                    rayColor: Color(0xFFFBBF24),
                    size: 56,
                    speed: 8.0,
                    child: VectorTreasureChest(tier: ChestTier.gold, size: 42),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.shopFreeDailyGold,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 13.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          AppStrings.shopFreeDailyGoldDesc,
                          style: const TextStyle(color: Color(0xFFFDE68A), fontSize: 10.5),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: !_shop.canClaimDailyAdReward
                        ? null
                        : () async {
                            final watched = await AdService.instance.showRewardedAd();
                            if (!mounted) return;
                            if (watched) {
                              final claimed = await _shop.claimDailyAdReward(amount: 100);
                              if (!mounted) return;
                              if (claimed) {
                                AppHaptics.reward();
                                ProceduralAudio.instance.playPurchase();
                                GameToast.showGold(context, AppStrings.shopGainedGold(100), title: AppStrings.shopDailyRewardTitle);
                              }
                            } else {
                              AppHaptics.light();
                              GameToast.showError(context, AppStrings.shopAdNotReady);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFBBF24),
                      disabledBackgroundColor: Colors.white12,
                      foregroundColor: Colors.black,
                      disabledForegroundColor: Colors.white38,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      _shop.canClaimDailyAdReward ? AppStrings.shopWatchAd : AppStrings.claimedToday,
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Daily Bonus Chest (Wizard's Grace)
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF065F46), Color(0xFF064E3B), Color(0xFF0F172A)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF34D399), width: 1.6),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981).withValues(alpha: 0.3),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const ShopGodrayBackground(
                    rayColor: Color(0xFF34D399),
                    size: 56,
                    speed: 8.0,
                    child: VectorPotionBottle(liquidColor: Color(0xFF10B981), size: 40),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.shopWizardGrace,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 13.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          AppStrings.shopWizardGraceDesc,
                          style: const TextStyle(color: Color(0xFFA7F3D0), fontSize: 10.5),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: !_shop.canClaimWizardGrace
                        ? null
                        : () async {
                            final claimed = await _shop.claimWizardGrace(amount: 50);
                            if (!mounted) return;
                            if (claimed) {
                              AppHaptics.reward();
                              ProceduralAudio.instance.playPurchase();
                              GameToast.showGold(context, AppStrings.shopWizardGraceClaimed(50), title: AppStrings.shopWizardGrace);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF34D399),
                      disabledBackgroundColor: Colors.white12,
                      foregroundColor: Colors.black,
                      disabledForegroundColor: Colors.white38,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      _shop.canClaimWizardGrace ? AppStrings.shopCollect : AppStrings.claimedToday,
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  // ─── Interactive Skin Preview Modal ─────────────────────────────────────────
  void _showSkinPreview(BuildContext context, BoardSkin skin) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: skin.bgDarkColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: skin.primaryGlow, width: 2),
            boxShadow: [
              BoxShadow(
                color: skin.primaryGlow.withValues(alpha: 0.35),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${skin.previewEmoji} ${skin.name}',
                      style: TextStyle(
                        color: skin.primaryGlow,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => Navigator.of(ctx).pop(),
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
                        child: Icon(Icons.close_rounded, color: Colors.white70, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                skin.description,
                textAlign: TextAlign.center,
                style: const TextStyle(color: GameTheme.textMuted, fontSize: 11),
              ),
              const SizedBox(height: 14),
              ShopLiveBoardPreview(
                skin: skin,
                width: 240,
                height: 180,
              ),
              const SizedBox(height: 16),
              StatefulBuilder(
                builder: (ctx, setModalState) {
                  final isUnlocked = _shop.isSkinUnlocked(skin.id);
                  final isSelected = _shop.activeSkinId == skin.id;

                  if (isUnlocked) {
                    return SizedBox(
                      width: double.infinity,
                      height: 38,
                      child: ElevatedButton(
                        onPressed: isSelected
                            ? null
                            : () {
                                AppHaptics.selection();
                                ProceduralAudio.instance.playButtonClick();
                                _shop.selectSkin(skin.id);
                                setModalState(() {});
                                setState(() {});
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSelected ? const Color(0xFF0284C7) : skin.primaryGlow,
                          foregroundColor: isSelected ? Colors.white : Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          isSelected ? AppStrings.shopEquippedCheck : AppStrings.equipSigil,
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                        ),
                      ),
                    );
                  } else {
                    return SizedBox(
                      width: double.infinity,
                      height: 38,
                      child: ElevatedButton(
                        onPressed: () async {
                          bool success = await _shop.purchaseSkin(skin);
                          if (!context.mounted) return;
                          if (success) {
                            AppHaptics.heavy();
                            ProceduralAudio.instance.playPurchase();
                            GameToast.showSuccess(context, AppStrings.themeUnlockedAndEquipped(skin.name), title: AppStrings.shopThemeUnlockedTitle);
                            setModalState(() {});
                            setState(() {});
                          } else {
                            AppHaptics.light();
                            ProceduralAudio.instance.playGameOver();
                            GameToast.showError(context, AppStrings.shopNotEnoughGold, title: AppStrings.shopBalanceLowTitle);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: skin.primaryGlow,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          AppStrings.buyForShards(skin.priceShards),
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RewardQuickTile extends StatelessWidget {
  final String asset;
  final String label;
  final Color accent;
  final VoidCallback onTap;

  const _RewardQuickTile({
    required this.asset,
    required this.label,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A).withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: accent.withValues(alpha: 0.45), width: 1.2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              asset,
              width: 22,
              height: 22,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: accent,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
