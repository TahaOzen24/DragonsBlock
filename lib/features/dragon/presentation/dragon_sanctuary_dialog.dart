import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/audio/procedural_audio.dart';
import '../../../../core/haptics/haptic_service.dart';
import '../../../../core/localization/locale_manager.dart';
import '../../../../core/theme/game_theme.dart';
import '../../../../core/ui/game_toast.dart';
import '../../../../core/ui/vector_assets/vector_assets.dart';
import '../../shop/services/shop_manager.dart';
import '../models/dragon.dart';
import '../services/dragon_manager.dart';
import 'dragon_egg_selection_screen.dart';

/// 🐉 Dragon Sanctuary & Evolution Tree Dialog
/// Shows the player's primary dragon, level progression, 5 evolution stages,
/// feeding mechanics, and elemental ultimate abilities.
class DragonSanctuaryDialog extends StatefulWidget {
  final bool isTab;
  const DragonSanctuaryDialog({super.key, this.isTab = false});

  @override
  State<DragonSanctuaryDialog> createState() => _DragonSanctuaryDialogState();
}

class _DragonSanctuaryDialogState extends State<DragonSanctuaryDialog> {
  final DragonManager _dragonManager = DragonManager.instance;
  final ShopManager _shop = ShopManager.instance;

  @override
  void initState() {
    super.initState();
    _dragonManager.addListener(_onUpdated);
    _shop.addListener(_onUpdated);
  }

  @override
  void dispose() {
    _dragonManager.removeListener(_onUpdated);
    _shop.removeListener(_onUpdated);
    super.dispose();
  }

  void _onUpdated() {
    if (mounted) setState(() {});
  }

  Future<void> _feedDragon() async {
    if (_dragonManager.dragonLevel >= 100) {
      AppHaptics.light();
      GameToast.showInfo(context, AppStrings.dragonMaxLevel, title: 'MAX');
      return;
    }

    const cost = 150;
    if (_shop.goldShards < cost) {
      AppHaptics.light();
      ProceduralAudio.instance.playGameOver();
      GameToast.showError(context, 'Yeterli altın yok! (Gereken: $cost🪙)', title: 'BAKİYE YETERSİZ');
      return;
    }

    AppHaptics.heavy();
    ProceduralAudio.instance.playPurchase();
    final spent = await _shop.spendShards(cost);
    if (!spent) return;
    await _dragonManager.addDragonExp(120);

    if (!mounted) return;
    GameToast.showGold(context, '+120 Ejderha DP Kazandın!', title: 'EJDERHA BESLENDİ 🥩');
  }

  @override
  Widget build(BuildContext context) {
    final dragon = _dragonManager.activeDragon;
    final stage = _dragonManager.currentStage;
    final level = _dragonManager.dragonLevel;
    final xp = _dragonManager.dragonExp;
    final progress = _dragonManager.expProgress;

    final isTurkish = LocaleManager.instance.isTurkish;

    final stages = [
      {'stage': DragonEvolutionStage.hatchling, 'name': 'Yavru Ejder', 'nameEn': 'Hatchling', 'level': 1, 'icon': dragon.hatchlingEmoji},
      {'stage': DragonEvolutionStage.drake, 'name': 'Genç Ejder', 'nameEn': 'Drake', 'level': 10, 'icon': dragon.drakeEmoji},
      {'stage': DragonEvolutionStage.battleDragon, 'name': 'Savaş Ejderi', 'nameEn': 'Battle Dragon', 'level': 25, 'icon': dragon.battleEmoji},
      {'stage': DragonEvolutionStage.ancientDragon, 'name': 'Kadim Ejder', 'nameEn': 'Ancient Dragon', 'level': 50, 'icon': dragon.ancientEmoji},
      {'stage': DragonEvolutionStage.mythicLeviathan, 'name': 'Efsanevi Leviathan', 'nameEn': 'Mythic Leviathan', 'level': 100, 'icon': dragon.mythicEmoji},
    ];

    final contentWidget = Container(
      constraints: widget.isTab
          ? null
          : BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.90,
              maxWidth: 400,
            ),
      padding: EdgeInsets.all(widget.isTab ? 12 : 18),
      decoration: BoxDecoration(
        color: widget.isTab ? Colors.transparent : const Color(0xFF0A0F24),
        borderRadius: BorderRadius.circular(28),
        border: widget.isTab ? null : Border.all(color: dragon.themeColor, width: 2.0),
        boxShadow: widget.isTab
            ? null
            : [
                BoxShadow(
                  color: dragon.themeColor.withValues(alpha: 0.35),
                  blurRadius: 28,
                  spreadRadius: 2,
                ),
              ],
      ),
      child: Column(
        mainAxisSize: widget.isTab ? MainAxisSize.max : MainAxisSize.min,
        children: [
          // 1. Header Row (only shown in dialog mode, or customized for tab)
          if (!widget.isTab)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    VectorDragonEgg(eggType: dragon.eggType, size: 28),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'EJDERHA MABEDİ',
                          style: TextStyle(
                            color: dragon.themeColor,
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                            letterSpacing: 0.8,
                          ),
                        ),
                        Text(
                          '${dragon.name} • Lv.$level',
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
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 32,
                    height: 32,
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
          if (!widget.isTab) const SizedBox(height: 14),

          // Scrollable Content
          Expanded(
            flex: widget.isTab ? 1 : 0,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                    // 2. Active Dragon Hero Presentation Box
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            dragon.themeColor.withValues(alpha: 0.25),
                            const Color(0xFF0F172A),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: dragon.themeColor.withValues(alpha: 0.6), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: dragon.themeColor.withValues(alpha: 0.2),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Animated 3D Dragon Stage Avatar
                          Center(
                            child: Container(
                              width: 88,
                              height: 88,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: dragon.themeColor, width: 2.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: dragon.themeColor.withValues(alpha: 0.45),
                                    blurRadius: 18,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  dragon.getImageForStage(stage),
                                  fit: BoxFit.cover,
                                  filterQuality: FilterQuality.high,
                                ),
                              ),
                            )
                                .animate(onPlay: (c) => c.repeat(reverse: true))
                                .scale(
                                  begin: const Offset(1, 1),
                                  end: const Offset(1.06, 1.06),
                                  duration: 1800.ms,
                                  curve: Curves.easeInOut,
                                ),
                          ),
                          const SizedBox(height: 8),

                          // Personality Tag
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: dragon.themeColor.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              dragon.personality,
                              style: TextStyle(
                                color: dragon.themeColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 10.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // EXP Bar
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Seviye $level',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11.5),
                              ),
                              Text(
                                '$xp / ${DragonEvolution.expForNextLevel(level)} DP',
                                style: TextStyle(color: dragon.themeColor, fontWeight: FontWeight.bold, fontSize: 11),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.white12,
                              valueColor: AlwaysStoppedAnimation<Color>(dragon.themeColor),
                              minHeight: 8,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Feed Dragon Button
                          SizedBox(
                            width: double.infinity,
                            height: 36,
                            child: ElevatedButton(
                              onPressed: level >= 100 ? null : _feedDragon,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFBBF24),
                                disabledBackgroundColor: Colors.white12,
                                foregroundColor: Colors.black,
                                disabledForegroundColor: Colors.white38,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(level >= 100 ? '👑' : '🥩', style: const TextStyle(fontSize: 14)),
                                  const SizedBox(width: 6),
                                  Text(
                                    level >= 100
                                        ? AppStrings.dragonMaxLevel
                                        : 'Ejderhayı Besle (150🪙)',
                                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 3. Dragon Powers & Passives Card
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(dragon.powerName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12.5)),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: dragon.themeColor.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text('ULTIMATE', style: TextStyle(color: dragon.themeColor, fontSize: 8.5, fontWeight: FontWeight.w900)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(dragon.powerDescription, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10.5)),
                          const Divider(color: Colors.white12, height: 16),
                          Row(
                            children: [
                              const Text('✨', style: TextStyle(fontSize: 12)),
                              const SizedBox(width: 6),
                              Text(dragon.passiveName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11.5)),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(dragon.passiveDescription, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 4. Evolution Tree Roadmap
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'EVRİM AĞACI',
                        style: TextStyle(
                          color: Color(0xFF38BDF8),
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    ...stages.map((stg) {
                      final reqLevel = stg['level'] as int;
                      final isUnlocked = level >= reqLevel;
                      final isCurrent = stage == stg['stage'];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? dragon.themeColor.withValues(alpha: 0.2)
                              : (isUnlocked ? Colors.white.withValues(alpha: 0.05) : Colors.black26),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isCurrent ? dragon.themeColor : (isUnlocked ? Colors.white24 : Colors.white10),
                            width: isCurrent ? 1.6 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(stg['icon'] as String, style: const TextStyle(fontSize: 22)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isTurkish ? (stg['name'] as String) : (stg['nameEn'] as String),
                                    style: TextStyle(
                                      color: isUnlocked ? Colors.white : Colors.white38,
                                      fontWeight: isCurrent ? FontWeight.w900 : FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    'Gereken: Seviye $reqLevel',
                                    style: TextStyle(
                                      color: isCurrent ? dragon.themeColor : Colors.white38,
                                      fontSize: 9.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isCurrent)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: dragon.themeColor,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'AKTİF',
                                  style: TextStyle(color: Colors.black, fontSize: 8.5, fontWeight: FontWeight.w900),
                                ),
                              )
                            else if (isUnlocked)
                              const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18)
                            else
                              const Icon(Icons.lock_rounded, color: Colors.white24, size: 16),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 12),

                    // Switch Dragon / Egg Selection Action Button
                    OutlinedButton.icon(
                      onPressed: () {
                        ProceduralAudio.instance.playDialogPop();
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const DragonEggSelectionScreen()),
                        );
                      },
                      icon: const Icon(Icons.swap_horiz_rounded, size: 18, color: Colors.white70),
                      label: const Text(
                        'Ejderha Yumurtasını Değiştir',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11.5),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

    if (widget.isTab) {
      return contentWidget;
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      child: contentWidget,
    );
  }
}
