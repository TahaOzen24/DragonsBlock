import 'package:flutter/material.dart';
import '../audio/procedural_audio.dart';
import '../config/legal_urls.dart';
import '../localization/locale_manager.dart';
import '../storage/app_prefs.dart';
import '../theme/game_theme.dart';
import '../../features/tutorial/presentation/tutorial_dialog.dart';
import '../../features/jukebox/presentation/jukebox_dialog.dart';
import '../haptics/haptic_service.dart';
import '../ui/game_toast.dart';
import '../iap/iap_service.dart';
import 'settings_manager.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  final SettingsManager _settings = SettingsManager.instance;
  final LocaleManager _localeManager = LocaleManager.instance;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: GameTheme.bgDark.withValues(alpha: 0.98),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: GameTheme.neonCyan.withValues(alpha: 0.5), width: 1.5),
          boxShadow: [
            BoxShadow(
                color: GameTheme.neonCyan.withValues(alpha: 0.3),
                blurRadius: 24,
                spreadRadius: 2),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.settings_rounded, color: GameTheme.neonCyan, size: 24),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            AppStrings.settings,
                            style: GameTheme.titleLarge.copyWith(fontSize: 18),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(color: GameTheme.gridBorder, height: 16),

              // Language Selector Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Text('🌐', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(AppStrings.language,
                                  style: GameTheme.labelBold.copyWith(fontSize: 13)),
                              Text(AppStrings.languageSubtitle,
                                  style: GameTheme.bodyMedium
                                      .copyWith(fontSize: 10, color: GameTheme.textMuted)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () {
                      _localeManager.toggleLanguage();
                      setState(() {});
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: GameTheme.bgSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: GameTheme.goldAccent.withValues(alpha: 0.6)),
                      ),
                      child: Text(
                        _localeManager.currentLanguage.displayName,
                        style: const TextStyle(
                          color: GameTheme.goldAccent,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Music Toggle
              _buildSettingRow(
                icon: '🎵',
                title: AppStrings.music,
                subtitle: AppStrings.musicSubtitle,
                value: _settings.isMusicEnabled,
                onChanged: (val) {
                  _settings.setMusic(val);
                  setState(() {});
                },
              ),

              if (_settings.isMusicEnabled) ...[
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: AudioSoundscape.values.map((soundscape) {
                              final isSelected =
                                  ProceduralAudio.instance.currentSoundscape == soundscape;
                              return Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: InkWell(
                                  onTap: () {
                                    ProceduralAudio.instance.setSoundscape(soundscape);
                                    setState(() {});
                                  },
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? GameTheme.neonCyan.withValues(alpha: 0.25)
                                          : GameTheme.bgSurface,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: isSelected
                                            ? GameTheme.neonCyan
                                            : GameTheme.gridBorder,
                                        width: isSelected ? 1.5 : 1.0,
                                      ),
                                    ),
                                    child: Text(
                                      soundscape.displayName,
                                      style: TextStyle(
                                        color: isSelected
                                            ? GameTheme.neonCyan
                                            : GameTheme.textMuted,
                                        fontSize: 11,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      InkWell(
                        onTap: () {
                          AppHaptics.light();
                          ProceduralAudio.instance.playDialogPop();
                          showDialog(
                            context: context,
                            builder: (_) => const JukeboxDialog(),
                          );
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                          decoration: BoxDecoration(
                            color: GameTheme.neonCyan.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: GameTheme.neonCyan.withValues(alpha: 0.6)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('🎧', style: TextStyle(fontSize: 12)),
                              SizedBox(width: 3),
                              Text(
                                'Stüdyo',
                                style: TextStyle(
                                  color: GameTheme.neonCyan,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 12),

              // Sound FX Toggle
              _buildSettingRow(
                icon: '🔊',
                title: AppStrings.soundFx,
                subtitle: AppStrings.soundFxSubtitle,
                value: _settings.isSoundEnabled,
                onChanged: (val) {
                  _settings.setSound(val);
                  setState(() {});
                },
              ),

              // Volume Slider (when sound is enabled)
              if (_settings.isSoundEnabled)
                Padding(
                  padding: const EdgeInsets.only(left: 20, top: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.volume_down_rounded, color: GameTheme.textMuted, size: 18),
                      Expanded(
                        child: SliderTheme(
                          data: SliderThemeData(
                            activeTrackColor: GameTheme.neonCyan,
                            inactiveTrackColor: GameTheme.bgSurface,
                            thumbColor: GameTheme.neonCyan,
                            overlayColor: GameTheme.neonCyan.withValues(alpha: 0.2),
                            trackHeight: 3,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                          ),
                          child: Slider(
                            value: ProceduralAudio.instance.masterVolume,
                            min: 0.0,
                            max: 1.0,
                            onChanged: (val) {
                              ProceduralAudio.instance.setMasterVolume(val);
                              setState(() {});
                            },
                          ),
                        ),
                      ),
                      const Icon(Icons.volume_up_rounded, color: GameTheme.textMuted, size: 18),
                    ],
                  ),
                ),

              const SizedBox(height: 12),

              // Haptics Toggle
              _buildSettingRow(
                icon: '📳',
                title: AppStrings.haptics,
                subtitle: AppStrings.hapticsSubtitle,
                value: _settings.isHapticsEnabled,
                onChanged: (val) {
                  _settings.setHaptics(val);
                  if (val) {
                    AppHaptics.testPreview(_settings.hapticProfile);
                  }
                  setState(() {});
                },
              ),

              if (_settings.isHapticsEnabled) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: HapticProfile.values.map((profile) {
                            final isSelected = _settings.hapticProfile == profile;
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: InkWell(
                                onTap: () {
                                  _settings.setHapticProfile(profile);
                                  AppHaptics.testPreview(profile);
                                  setState(() {});
                                },
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? GameTheme.neonCyan.withValues(alpha: 0.25)
                                        : GameTheme.bgSurface,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isSelected
                                          ? GameTheme.neonCyan
                                          : GameTheme.gridBorder,
                                      width: isSelected ? 1.5 : 1.0,
                                    ),
                                  ),
                                  child: Text(
                                    profile.displayName,
                                    style: TextStyle(
                                      color: isSelected
                                          ? GameTheme.neonCyan
                                          : GameTheme.textMuted,
                                      fontSize: 11,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _settings.hapticProfile.subtitle,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 12),

              // Screen Shake Toggle
              _buildSettingRow(
                icon: '💥',
                title: AppStrings.screenShake,
                subtitle: AppStrings.screenShakeSubtitle,
                value: _settings.isScreenShakeEnabled,
                onChanged: (val) {
                  _settings.setScreenShake(val);
                  setState(() {});
                },
              ),

              const SizedBox(height: 12),

              // Battery Saver Toggle
              _buildSettingRow(
                icon: '🔋',
                title: AppStrings.batterySaver,
                subtitle: AppStrings.batterySaverSubtitle,
                value: _settings.isBatterySaver,
                onChanged: (val) {
                  _settings.setBatterySaver(val);
                  setState(() {});
                },
              ),

              const SizedBox(height: 14),
              const Divider(color: GameTheme.gridBorder, height: 12),

              // How to Play Tutorial Guide
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => const TutorialDialog(),
                    );
                  },
                  icon: const Text('❓', style: TextStyle(fontSize: 14)),
                  label: Text(
                    _localeManager.isTurkish ? 'Nasıl Oynanır? (Rün Rehberi)' : 'How to Play (Runic Guide)',
                    style: const TextStyle(color: GameTheme.neonCyan, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              // Restore Purchases
              Center(
                child: TextButton.icon(
                  onPressed: () async {
                    AppHaptics.light();
                    ProceduralAudio.instance.playButtonClick();
                    await IapService.instance.restorePurchases();
                    if (!context.mounted) return;
                    GameToast.showSuccess(
                      context,
                      _localeManager.isTurkish
                          ? 'Satın alımlar geri yüklendi.'
                          : 'Purchases restored successfully.',
                      title: _localeManager.isTurkish ? 'GERİ YÜKLEME' : 'RESTORE',
                    );
                  },
                  icon: const Icon(Icons.restore_rounded, color: GameTheme.goldAccent, size: 16),
                  label: Text(
                    _localeManager.isTurkish ? 'Satın Alımları Geri Yükle' : 'Restore Purchases',
                    style: const TextStyle(color: GameTheme.goldAccent, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              // Privacy Policy
              Center(
                child: TextButton.icon(
                  onPressed: () => _showPrivacyPolicy(context),
                  icon: const Icon(Icons.privacy_tip_outlined, color: Colors.white60, size: 15),
                  label: Text(
                    _localeManager.isTurkish ? 'Gizlilik Politikası (Privacy Policy)' : 'Privacy Policy',
                    style: const TextStyle(color: Colors.white60, fontSize: 11),
                  ),
                ),
              ),

              const SizedBox(height: 4),

              // Reset Data Option
              Center(
                child: TextButton.icon(
                  onPressed: () => _confirmReset(context),
                  icon: const Icon(Icons.delete_forever_rounded,
                      color: GameTheme.fireOrange, size: 16),
                  label: Text(
                    _localeManager.isTurkish
                        ? 'Tüm Oyun Verilerini Sıfırla'
                        : 'Reset All Game Data',
                    style: const TextStyle(color: GameTheme.fireOrange, fontSize: 11),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingRow({
    required String icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: GameTheme.labelBold.copyWith(fontSize: 13)),
                    Text(subtitle,
                        style: GameTheme.bodyMedium
                            .copyWith(fontSize: 10, color: GameTheme.textMuted)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Switch(
          value: value,
          activeThumbColor: GameTheme.neonCyan,
          activeTrackColor: GameTheme.neonCyan.withValues(alpha: 0.3),
          onChanged: onChanged,
        ),
      ],
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: GameTheme.bgDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          _localeManager.isTurkish ? 'Tüm Veriler Sıfırlansın mı?' : 'Reset All Progress?',
          style: const TextStyle(color: GameTheme.fireOrange),
        ),
        content: Text(
          _localeManager.isTurkish
              ? 'Bu işlem rekorunuzu, açık temalarınızı ve yeteneklerinizi sıfırlar. Geri alınamaz.'
              : 'This will clear your high score, unlocked skins, talents, and crystals. This action cannot be undone.',
          style: const TextStyle(color: GameTheme.textMuted, fontSize: 12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              _localeManager.isTurkish ? 'İPTAL' : 'CANCEL',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await AppPrefs.instance.clearAll();
              if (ctx.mounted) {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: GameTheme.fireOrange),
            child: Text(
              _localeManager.isTurkish ? 'SIFIRLA' : 'RESET',
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: GameTheme.bgDarkest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: GameTheme.neonCyan, width: 1.2),
        ),
        title: Row(
          children: [
            const Icon(Icons.privacy_tip_rounded, color: GameTheme.neonCyan, size: 20),
            const SizedBox(width: 8),
            Text(
              _localeManager.isTurkish ? 'Gizlilik Politikası' : 'Privacy Policy',
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Text(
              _localeManager.isTurkish
                  ? 'DragonsBlock ("biz", "uygulama"), kullanıcı gizliliğine saygı duyar. '
                    'Oyun deneyiminizi geliştirmek ve reklam hizmetleri (Google AdMob) sunmak için '
                    'cihaz kimliği (Advertising ID) ve anonimleştirilmiş analiz verileri toplanabilir. '
                    'Kişisel kimlik bilgileriniz (isim, e-posta, kredi kartı vb.) tarafımızca saklanmaz veya satılmaz. '
                    'Uygulama içi satın alımlar doğrudan Google Play Store güvenli altyapısı üzerinden işlenir.\n\n'
                    '${LegalUrls.hasPrivacyPolicyUrl ? 'Tam metin: ${LegalUrls.privacyPolicyUrl}\n\n' : ''}'
                    'İletişim & Destek: ${LegalUrls.supportEmail}'
                  : 'DragonsBlock ("we", "the app") respects user privacy. '
                    'To improve gameplay experience and advertising services (Google AdMob), '
                    'anonymized telemetry and device advertising identifiers may be collected. '
                    'No personal identifying information (name, email, payment card data) is stored or sold by us. '
                    'In-app purchases are securely processed through Google Play Store billing.\n\n'
                    '${LegalUrls.hasPrivacyPolicyUrl ? 'Full policy: ${LegalUrls.privacyPolicyUrl}\n\n' : ''}'
                    'Contact & Support: ${LegalUrls.supportEmail}',
              style: const TextStyle(color: GameTheme.textMuted, fontSize: 12, height: 1.4),
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: GameTheme.neonCyan,
              foregroundColor: Colors.black,
            ),
            child: Text(
              _localeManager.isTurkish ? 'KAPAT' : 'CLOSE',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
