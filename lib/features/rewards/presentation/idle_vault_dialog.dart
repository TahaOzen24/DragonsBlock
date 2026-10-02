import 'package:flutter/material.dart';
import '../../../core/haptics/haptic_service.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/ads/ad_service.dart';
import '../../../core/audio/procedural_audio.dart';
import '../../../core/localization/locale_manager.dart';
import '../../../core/theme/game_theme.dart';
import '../services/idle_vault_manager.dart';

class IdleVaultDialog extends StatefulWidget {
  const IdleVaultDialog({super.key});

  @override
  State<IdleVaultDialog> createState() => _IdleVaultDialogState();
}

class _IdleVaultDialogState extends State<IdleVaultDialog> {
  final IdleVaultManager _vault = IdleVaultManager.instance;
  bool _isClaimed = false;

  void _claim() async {
    if (_isClaimed) return;
    AppHaptics.heavy();
    ProceduralAudio.instance.playRewardClaim();
    final claimed = await _vault.claimVault();

    if (mounted) {
      setState(() {
        _isClaimed = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: GameTheme.goldAccent,
          content: Text(
            AppStrings.claimedFromVault(claimed),
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  void _claimDouble() async {
    if (_isClaimed) return;
    final watched = await AdService.instance.showRewardedAd();
    if (!watched || !mounted) return;

    AppHaptics.heavy();
    ProceduralAudio.instance.playRewardClaim();
    final claimed = await _vault.claimAndDoubleVault();

    if (mounted) {
      setState(() {
        _isClaimed = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: GameTheme.goldAccent,
          content: Text(
            AppStrings.claimedDoubleFromVault(claimed),
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pending = _vault.pendingShards;
    final fill = _vault.vaultFillPercentage;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: GameTheme.bgDark.withValues(alpha: 0.98),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: GameTheme.goldAccent, width: 2.2),
          boxShadow: [
            BoxShadow(
              color: GameTheme.goldAccent.withValues(alpha: 0.35),
              blurRadius: 28,
              spreadRadius: 3,
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
                        const Text('🏦', style: TextStyle(fontSize: 22)),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            AppStrings.runicTreasureVault,
                            style: const TextStyle(
                              color: GameTheme.goldAccent,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.1,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
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
            const SizedBox(height: 6),
            Text(
              AppStrings.vaultSubtitle,
              textAlign: TextAlign.center,
              style: GameTheme.bodyMedium.copyWith(fontSize: 11, color: GameTheme.textMuted),
            ),
            const SizedBox(height: 18),

            // Vault Graphic & Accumulated Shards
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: GameTheme.goldAccent.withValues(alpha: 0.15),
                border: Border.all(color: GameTheme.goldAccent, width: 2.5),
                boxShadow: GameTheme.goldGlow(blur: 20, spread: 2),
              ),
              alignment: Alignment.center,
              child: const Text('🪙', style: TextStyle(fontSize: 48)),
            ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),

            const SizedBox(height: 12),

            Text(
              '+$pending 🪙',
              style: const TextStyle(
                color: GameTheme.goldAccent,
                fontSize: 30,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              '${_vault.accumulatedTimeFormatted} / 8 sa birikti',
              style: const TextStyle(color: GameTheme.neonCyan, fontSize: 11, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 14),

            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: fill,
                minHeight: 8,
                backgroundColor: GameTheme.bgSurface,
                valueColor: const AlwaysStoppedAnimation<Color>(GameTheme.goldAccent),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('0 🪙', style: TextStyle(color: GameTheme.textMuted, fontSize: 9.5)),
                Text('${IdleVaultManager.maxShards} 🪙 (Kapasite)',
                    style: TextStyle(color: GameTheme.textMuted, fontSize: 9.5)),
              ],
            ),

            const SizedBox(height: 18),

            // 2X Claim Button
            ElevatedButton.icon(
              onPressed: pending > 0 ? _claimDouble : null,
              icon: const Text('🎬', style: TextStyle(fontSize: 16)),
              label: Text(
                AppStrings.claim2x(pending * 2),
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: GameTheme.emeraldGreen,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),

            const SizedBox(height: 8),

            // Normal Claim Button
            OutlinedButton(
              onPressed: pending > 0 ? _claim : null,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: GameTheme.gridBorder),
                minimumSize: const Size(double.infinity, 40),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                AppStrings.regularClaim(pending),
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    ),
  );
  }
}
