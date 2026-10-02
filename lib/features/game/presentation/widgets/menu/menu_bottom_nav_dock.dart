import 'package:flutter/material.dart';
import '../../../../../core/audio/procedural_audio.dart';
import '../../../../../core/haptics/haptic_service.dart';
import '../../../../../core/localization/app_strings.dart';
import '../../../../dragon/services/dragon_manager.dart';
import '../../../../leaderboard/services/league_reward_service.dart';
import '../../../../shop/services/shop_manager.dart';

class MenuBottomNavDock extends StatelessWidget {
  final int currentTab;
  final ValueChanged<int> onTabSelected;

  const MenuBottomNavDock({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
  });

  bool _hasBadgeForTab(int tab) {
    switch (tab) {
      case 0:
        return ShopManager.instance.hasAnyShopFreeClaimAvailable;
      case 1:
        return false;
      case 3:
        final dragon = DragonManager.instance;
        final canAffordFeed =
            dragon.dragonLevel < 100 && ShopManager.instance.goldShards >= 150;
        return canAffordFeed || dragon.expProgress >= 0.85;
      case 4:
        return LeagueRewardService.instance.canClaimThisWeek;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final navItems = [
      {'image': 'assets/images/ui/icon_shop.png', 'label': AppStrings.navShop, 'tab': 0},
      {'image': 'assets/images/ui/icon_collection.png', 'label': AppStrings.navCollection, 'tab': 1},
      {'image': 'assets/images/ui/icon_castle.png', 'label': AppStrings.navHome, 'tab': 2},
      {'image': 'assets/images/dragons/dragon_hatchling.jpg', 'label': AppStrings.navDragon, 'tab': 3, 'isDragon': true},
      {'image': 'assets/images/ui/icon_rank.png', 'label': AppStrings.navLeaderboard, 'tab': 4},
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 8),
      height: 70,
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1E293B),
            Color(0xFF162548),
            Color(0xFF0F172A),
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: const Color(0xFF38BDF8).withValues(alpha: 0.55),
          width: 1.8,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1D4ED8).withValues(alpha: 0.40),
            blurRadius: 20,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.65),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: navItems.map((item) {
          final tabIndex = item['tab'] as int;
          final isSelected = currentTab == tabIndex;
          final isHome = tabIndex == 2;
          final isDragon = item['isDragon'] == true;
          final hasBadge = _hasBadgeForTab(tabIndex);

          if (isHome) {
            return Expanded(
              child: InkWell(
                onTap: () {
                  AppHaptics.selection();
                  ProceduralAudio.instance.playTabSwitch();
                  onTabSelected(tabIndex);
                },
                borderRadius: BorderRadius.circular(26),
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 64,
                    height: 58,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: isSelected
                            ? [const Color(0xFF1E3A8A), const Color(0xFF0F172A)]
                            : [const Color(0xFF1E293B), const Color(0xFF0F172A)],
                      ),
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(
                        color: isSelected ? const Color(0xFFFBBF24) : const Color(0xFF475569),
                        width: 2.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected
                              ? const Color(0xFFFBBF24).withValues(alpha: 0.60)
                              : Colors.black.withValues(alpha: 0.3),
                          blurRadius: isSelected ? 18 : 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/ui/icon_castle.png',
                          width: 28,
                          height: 28,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                        ),
                        const SizedBox(height: 2),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            AppStrings.navPlay,
                            style: const TextStyle(
                              color: Color(0xFFFDE047),
                              fontSize: 10.0,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          return Expanded(
            child: InkWell(
              onTap: () {
                AppHaptics.selection();
                ProceduralAudio.instance.playTabSwitch();
                onTabSelected(tabIndex);
              },
              borderRadius: BorderRadius.circular(18),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        isDragon
                            ? Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected ? const Color(0xFFFBBF24) : Colors.white24,
                                    width: 1.5,
                                  ),
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    item['image'] as String,
                                    fit: BoxFit.cover,
                                    filterQuality: FilterQuality.high,
                                  ),
                                ),
                              )
                            : Image.asset(
                                item['image'] as String,
                                width: 26,
                                height: 26,
                                fit: BoxFit.contain,
                                filterQuality: FilterQuality.high,
                                color: isSelected ? null : Colors.white.withValues(alpha: 0.55),
                                colorBlendMode: isSelected ? null : BlendMode.modulate,
                              ),
                        const SizedBox(height: 2),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            item['label'] as String,
                            maxLines: 1,
                            style: TextStyle(
                              color: isSelected ? const Color(0xFF38BDF8) : const Color(0xFF94A3B8),
                              fontSize: 10.0,
                              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (hasBadge)
                      Positioned(
                        top: 2,
                        right: 12,
                        child: Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withValues(alpha: 0.8),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
