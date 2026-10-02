import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/localization/locale_manager.dart';
import '../../../core/storage/app_prefs.dart';
import '../../../core/theme/game_theme.dart';
import '../../adventure/models/boss.dart';
import '../../dragon/presentation/dragon_sanctuary_dialog.dart';
import '../../dragon/services/dragon_manager.dart';
import '../../shop/services/shop_manager.dart';
import '../models/player_avatar.dart';

class PlayerProfileDialog extends StatefulWidget {
  const PlayerProfileDialog({super.key});

  @override
  State<PlayerProfileDialog> createState() => _PlayerProfileDialogState();
}

class _PlayerProfileDialogState extends State<PlayerProfileDialog> {
  int _highScore = 0;
  int _bossesDefeatedCount = 0;
  int _totalGamesPlayed = 0;
  int _totalLinesCleared = 0;
  String _selectedAvatarId = 'knight';
  String _selectedFrameId = 'gold';
  String _playerName = '';
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadStats() async {
    await AppPrefs.instance.init();
    final defeated = await Boss.getDefeatedBossIds();
    setState(() {
      _highScore = AppPrefs.instance.getInt(AppPrefs.kHighScore) ?? 0;
      _bossesDefeatedCount = defeated.length;
      _totalGamesPlayed = AppPrefs.instance.getInt(AppPrefs.kGamesPlayed) ?? 0;
      _totalLinesCleared = AppPrefs.instance.getInt(AppPrefs.kTotalLinesCleared) ?? 0;
      _selectedAvatarId = AppPrefs.instance.getString(AppPrefs.kPlayerAvatarId) ?? 'knight';
      _selectedFrameId = AppPrefs.instance.getString(AppPrefs.kPlayerFrameId) ?? 'gold';
      _playerName = AppPrefs.instance.getString(AppPrefs.kPlayerName) ?? '';
      _nameController.text = _playerName;
    });
  }

  Future<void> _saveName(String name) async {
    await AppPrefs.instance.setString(AppPrefs.kPlayerName, name);
    setState(() {
      _playerName = name;
    });
  }

  int get _playerLevel => 1 + (_highScore ~/ 1500);

  Future<void> _setAvatar(String id) async {
    await AppPrefs.instance.setString(AppPrefs.kPlayerAvatarId, id);
    setState(() {
      _selectedAvatarId = id;
    });
  }

  Future<void> _setFrame(String id) async {
    await AppPrefs.instance.setString(AppPrefs.kPlayerFrameId, id);
    setState(() {
      _selectedFrameId = id;
    });
  }

  String get _playerTitle {
    if (_bossesDefeatedCount >= 4 && _highScore >= 30000) {
      return AppStrings.titleGrandArchon;
    } else if (_bossesDefeatedCount >= 2 || _highScore >= 15000) {
      return AppStrings.titleDragonSlayer;
    } else if (_highScore >= 5000) {
      return AppStrings.titleElementalAdept;
    } else {
      return AppStrings.titleRuneApprentice;
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeSkin = ShopManager.instance.activeSkin;
    final isTr = LocaleManager.instance.isTurkish;

    final currentAvatar = PlayerAvatar.defaultAvatars.firstWhere(
      (a) => a.id == _selectedAvatarId,
      orElse: () => PlayerAvatar.defaultAvatars.first,
    );
    final currentFrame = PlayerFrame.defaultFrames.firstWhere(
      (f) => f.id == _selectedFrameId,
      orElse: () => PlayerFrame.defaultFrames.first,
    );

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: GameTheme.bgDark.withValues(alpha: 0.98),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: activeSkin.primaryGlow.withValues(alpha: 0.6), width: 2),
          boxShadow: [
            BoxShadow(
              color: activeSkin.primaryGlow.withValues(alpha: 0.35),
              blurRadius: 28,
              spreadRadius: 2,
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Text('🛡️', style: TextStyle(fontSize: 22)),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            AppStrings.playerProfile,
                            style: GameTheme.titleLarge.copyWith(fontSize: 18),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
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
                        child: Icon(Icons.close_rounded, color: Colors.white70, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Illustrated Avatar Badge with Custom Frame
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: GameTheme.bgDarkest,
                  border: Border.all(
                    color: currentFrame.frameColor,
                    width: currentFrame.borderWidth,
                  ),
                  boxShadow: currentFrame.hasGlow
                      ? [
                          BoxShadow(
                            color: currentFrame.frameColor.withValues(alpha: 0.6),
                            blurRadius: 18,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  currentAvatar.emoji,
                  style: const TextStyle(fontSize: 36),
                ),
              ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),

              const SizedBox(height: 8),

              // Player Name Input
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: GameTheme.bgSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: GameTheme.neonCyan.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person_rounded, color: GameTheme.neonCyan, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _nameController,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: isTr ? 'Oyuncu adı...' : 'Player name...',
                          hintStyle: TextStyle(color: GameTheme.textMuted, fontSize: 12),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        onSubmitted: _saveName,
                        maxLength: 20,
                      ),
                    ),
                    if (_nameController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.check_rounded, color: GameTheme.emeraldGreen, size: 18),
                        onPressed: () => _saveName(_nameController.text),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Title & Level
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: GameTheme.goldAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Lv.$_playerLevel',
                      style: const TextStyle(color: GameTheme.goldAccent, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _playerTitle,
                    style: const TextStyle(color: GameTheme.goldAccent, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Avatar Picker Row
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemCount: PlayerAvatar.defaultAvatars.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, idx) {
                    final a = PlayerAvatar.defaultAvatars[idx];
                    final isSel = a.id == _selectedAvatarId;
                    return InkWell(
                      onTap: () => _setAvatar(a.id),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSel ? a.themeColor.withValues(alpha: 0.25) : GameTheme.bgSurface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSel ? a.themeColor : GameTheme.gridBorder,
                            width: isSel ? 1.8 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(a.emoji, style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 4),
                            Text(
                              a.name.split(' ').first,
                              style: TextStyle(
                                color: isSel ? a.themeColor : Colors.white70,
                                fontSize: 10,
                                fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 8),

              // Frame Picker Row
              SizedBox(
                height: 32,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemCount: PlayerFrame.defaultFrames.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 6),
                  itemBuilder: (context, idx) {
                    final f = PlayerFrame.defaultFrames[idx];
                    final isSel = f.id == _selectedFrameId;
                    return InkWell(
                      onTap: () => _setFrame(f.id),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isSel ? f.frameColor.withValues(alpha: 0.2) : GameTheme.bgSurface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSel ? f.frameColor : GameTheme.gridBorder,
                            width: isSel ? 1.6 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: f.frameColor,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              f.name,
                              style: TextStyle(
                                color: isSel ? f.frameColor : Colors.white60,
                                fontSize: 9.5,
                                fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // Stats Grid 3x2
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
                childAspectRatio: 1.8,
                children: [
                  _buildStatTile('🏆', AppStrings.profileBestScore, '$_highScore', GameTheme.goldAccent),
                  _buildStatTile('⚔️', AppStrings.profileBossesDefeated, '$_bossesDefeatedCount/4', GameTheme.fireOrange),
                  _buildStatTile('🪙', AppStrings.profileTotalGold, '${ShopManager.instance.goldShards}', GameTheme.neonCyan),
                  _buildStatTile('🎮', isTr ? 'Oyun' : 'Games', '$_totalGamesPlayed', GameTheme.emeraldGreen),
                  _buildStatTile('📐', isTr ? 'Çizgi' : 'Lines', '$_totalLinesCleared', GameTheme.lightningYellow),
                  _buildStatTile('🐉', isTr ? 'Ejderha' : 'Dragon', 'Lv.${DragonManager.instance.dragonLevel}', GameTheme.voidPurple),
                ],
              ),

              const SizedBox(height: 12),

              // Active Theme Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: GameTheme.bgSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: activeSkin.gridBorderColor),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Text('🎨', style: TextStyle(fontSize: 15)),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              AppStrings.activeBoardSkin,
                              style: GameTheme.bodyMedium.copyWith(fontSize: 11),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      activeSkin.name,
                      style: TextStyle(
                          color: activeSkin.primaryGlow,
                          fontWeight: FontWeight.bold,
                          fontSize: 11),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Dragon Sanctuary Button
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  showDialog(
                    context: context,
                    builder: (_) => const DragonSanctuaryDialog(),
                  );
                },
                icon: const Text('🐉', style: TextStyle(fontSize: 16)),
                label: Text(
                  isTr ? 'EJDERHA MABEDİ' : 'DRAGON SANCTUARY',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DragonManager.instance.activeDragon.themeColor,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 40),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatTile(String icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      decoration: BoxDecoration(
        color: GameTheme.bgSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 10)),
              const SizedBox(width: 3),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(label,
                      style: const TextStyle(
                          color: GameTheme.textMuted, fontSize: 8, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
