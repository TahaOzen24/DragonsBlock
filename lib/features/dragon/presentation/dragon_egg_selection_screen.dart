import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/haptics/haptic_service.dart';
import '../../../core/audio/procedural_audio.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/theme/game_theme.dart';
import '../../../core/ui/vector_assets/vector_assets.dart';
import '../models/dragon.dart';
import '../services/dragon_manager.dart';

class DragonEggSelectionScreen extends StatefulWidget {
  final bool isChoosingFirst;

  const DragonEggSelectionScreen({super.key, this.isChoosingFirst = false});

  @override
  State<DragonEggSelectionScreen> createState() => _DragonEggSelectionScreenState();
}

class _DragonEggSelectionScreenState extends State<DragonEggSelectionScreen> {
  final DragonManager _manager = DragonManager.instance;
  DragonEggType? _selectedType;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _manager.addListener(_onUpdated);
    _selectedType = _manager.activeEggType;
  }

  @override
  void dispose() {
    _manager.removeListener(_onUpdated);
    super.dispose();
  }

  void _onUpdated() {
    if (mounted) setState(() {});
  }

  void _selectEgg(DragonDefinition dragon) {
    AppHaptics.medium();
    ProceduralAudio.instance.playButtonClick();
    setState(() => _selectedType = dragon.eggType);
  }

  void _confirmSelection() async {
    if (_selectedType == null) return;

    final unlocked = _manager.isEggUnlocked(_selectedType!);

    // Locked egg → purchase flow
    if (!unlocked) {
      AppHaptics.heavy();
      final ok = await _manager.unlockEgg(_selectedType!);
      if (!mounted) return;
      if (!ok) {
        AppHaptics.light();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red.shade800,
            content: Text(
              AppStrings.notEnoughGold,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        );
        return;
      }
      await _manager.selectEgg(_selectedType!);
      if (!mounted) return;
      final dragon = DragonDefinition.allDragons.firstWhere((d) => d.eggType == _selectedType);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: dragon.themeColor,
          content: Text(
            AppStrings.dragonSelected(dragon.name),
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
          duration: const Duration(milliseconds: 1400),
        ),
      );
      Navigator.of(context).pop();
      return;
    }

    AppHaptics.heavy();
    ProceduralAudio.instance.playPurchase();

    if (widget.isChoosingFirst && !_manager.hasChosenEgg) {
      await _manager.chooseEgg(_selectedType!);
    } else {
      await _manager.selectEgg(_selectedType!);
    }

    if (mounted) {
      final dragon = DragonDefinition.allDragons.firstWhere((d) => d.eggType == _selectedType);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: dragon.themeColor,
          content: Text(
            widget.isChoosingFirst
                ? AppStrings.dragonChosen(dragon.name)
                : AppStrings.dragonSelected(dragon.name),
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
          duration: const Duration(milliseconds: 1400),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedDragon = _selectedType != null
        ? DragonDefinition.allDragons.firstWhere((d) => d.eggType == _selectedType)
        : null;

    return PopScope(
      canPop: !widget.isChoosingFirst,
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0E1A),
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Title
              Text(
                widget.isChoosingFirst
                    ? (_manager.hasChosenEgg ? AppStrings.chooseYourDragon : AppStrings.chooseFirstDragon)
                    : AppStrings.changeDragon,
                style: TextStyle(
                  color: selectedDragon?.themeColor ?? Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                AppStrings.dragonSelectionSubtitle,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11),
              ),
              const SizedBox(height: 16),

              // Egg Cards - Compact PageView
              Expanded(
                child: PageView.builder(
                  controller: PageController(viewportFraction: 0.78),
                  itemCount: DragonDefinition.allDragons.length,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemBuilder: (context, index) {
                    final dragon = DragonDefinition.allDragons[index];
                    final isActive = _manager.activeEggType == dragon.eggType;
                    final isSelected = _selectedType == dragon.eggType;
                    final isUnlocked = _manager.isEggUnlocked(dragon.eggType);

                    return GestureDetector(
                      onTap: () => _selectEgg(dragon),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? dragon.themeColor.withValues(alpha: 0.15)
                              : GameTheme.bgDark.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: isSelected ? dragon.themeColor : Colors.white12,
                            width: isSelected ? 2.5 : 1.0,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: dragon.themeColor.withValues(alpha: 0.35),
                                    blurRadius: 24,
                                    spreadRadius: 2,
                                  ),
                                ]
                              : null,
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // 🐉 Pure GPU-Accelerated 3D Vector Elemental Dragon Egg with Dragon Avatar Preview
                              Stack(
                                clipBehavior: Clip.none,
                                alignment: Alignment.center,
                                children: [
                                  VectorDragonEgg(
                                    eggType: dragon.eggType,
                                    size: isSelected ? 80 : 66,
                                    isSelected: isSelected,
                                    shimmerPhase: isSelected ? 0.6 : 0.0,
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: -4,
                                    child: Container(
                                      width: isSelected ? 40 : 32,
                                      height: isSelected ? 40 : 32,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: dragon.themeColor, width: 2),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.6),
                                            blurRadius: 8,
                                          ),
                                        ],
                                      ),
                                      child: ClipOval(
                                        child: Image.asset(
                                          dragon.imageAsset,
                                          fit: BoxFit.cover,
                                          filterQuality: FilterQuality.high,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                                  .animate(target: isSelected ? 1.0 : 0.0)
                                  .scale(
                                    begin: const Offset(1, 1),
                                    end: const Offset(1.08, 1.08),
                                    duration: 500.ms,
                                    curve: Curves.easeOutBack,
                                  ),

                              const SizedBox(height: 12),

                              // Dragon Name
                              Text(
                                dragon.name,
                                style: TextStyle(
                                  color: isSelected ? dragon.themeColor : Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 3),

                              // Personality tag
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: dragon.themeColor.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  dragon.personality,
                                  style: TextStyle(
                                    color: dragon.themeColor,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 10),

                              // Passive
                              _buildInfoRow(
                                icon: '✨',
                                label: dragon.passiveName,
                                value: dragon.passiveDescription,
                                color: Colors.white70,
                              ),
                              const SizedBox(height: 6),

                              // Dragon Power
                              _buildInfoRow(
                                icon: '⚡',
                                label: dragon.powerName,
                                value: dragon.powerDescription,
                                color: dragon.themeColor,
                              ),

                              const SizedBox(height: 10),

                              // Status badge
                              if (isActive)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: dragon.themeColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    AppStrings.selectedCheck,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                )
                              else if (!isUnlocked)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.white12,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.white24),
                                  ),
                                  child: Text(
                                    AppStrings.unlockEggCost(500),
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Dot indicators
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    DragonDefinition.allDragons.length,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: _currentPage == i ? 18 : 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: _currentPage == i
                            ? DragonDefinition.allDragons[i].themeColor
                            : Colors.white24,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom Buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Row(
                  children: [
                    if (!widget.isChoosingFirst || _manager.hasChosenEgg)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white24),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            AppStrings.cancel,
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ),
                      ),
                    if (!widget.isChoosingFirst || _manager.hasChosenEgg)
                      const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _selectedType != null ? _confirmSelection : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedDragon?.themeColor ?? GameTheme.frostCyan,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 6,
                        ),
                        child: Text(
                          () {
                            if (_selectedType == null) return AppStrings.selectArrow;
                            final locked = !_manager.isEggUnlocked(_selectedType!);
                            if (locked) return AppStrings.unlockEggAction;
                            if (widget.isChoosingFirst && !_manager.hasChosenEgg) {
                              return AppStrings.confirmEgg;
                            }
                            return AppStrings.selectDragonAction;
                          }(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required String icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(icon, style: const TextStyle(fontSize: 11)),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 9.5),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                value,
                style: const TextStyle(color: GameTheme.textMuted, fontSize: 9),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
