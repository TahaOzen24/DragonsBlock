import 'package:flutter/services.dart';
import '../settings/settings_manager.dart';

/// 📳 Merkezi, Profile Duyarlı Haptik Titreşim Sistemi.
/// 3 Farklı Haptik Titreşim Modeli Destekler:
/// 1. Zen (🍃 İpeksi): Yumuşak, rahatlatıcı minik tıklamalar; kaba sarsıntı yok.
/// 2. Arcade (🎮 Tok): Dengeli, dolgun, tatmin edici klasik atari salonu hissi.
/// 3. Cyber (⚡ Keskin): Yüksek enerjili, net ve güçlü titreşim vuruşları.
/// Titreşim kapalı olduğunda (isHapticsEnabled == false) sıfır titreşim üretir.
class AppHaptics {
  const AppHaptics._();

  static bool get isEnabled => SettingsManager.instance.isHapticsEnabled;
  static HapticProfile get profile => SettingsManager.instance.hapticProfile;

  /// Hafif dokunma / seçim (UI butonları, liste tıklamaları, hafif geçişler)
  static void light() {
    if (!isEnabled) return;
    switch (profile) {
      case HapticProfile.zen:
        HapticFeedback.selectionClick();
        break;
      case HapticProfile.arcade:
        HapticFeedback.lightImpact();
        break;
      case HapticProfile.cyber:
        HapticFeedback.lightImpact();
        break;
    }
  }

  /// Seçim tık hissi (sekme geçişi, menü minik seçimleri)
  static void selection() {
    if (!isEnabled) return;
    switch (profile) {
      case HapticProfile.zen:
        HapticFeedback.selectionClick();
        break;
      case HapticProfile.arcade:
        HapticFeedback.selectionClick();
        break;
      case HapticProfile.cyber:
        HapticFeedback.lightImpact();
        break;
    }
  }

  /// Orta toklukta geri bildirim (blok yerleştirme, çekiç vuruşu, satın alma)
  static void medium() {
    if (!isEnabled) return;
    switch (profile) {
      case HapticProfile.zen:
        HapticFeedback.lightImpact();
        break;
      case HapticProfile.arcade:
        HapticFeedback.mediumImpact();
        break;
      case HapticProfile.cyber:
        HapticFeedback.mediumImpact();
        break;
    }
  }

  /// Güçlü tok vuruş (çizgi temizleme, kombo, nihai yetenek dolumu)
  static void heavy() {
    if (!isEnabled) return;
    switch (profile) {
      case HapticProfile.zen:
        HapticFeedback.mediumImpact();
        break;
      case HapticProfile.arcade:
        HapticFeedback.heavyImpact();
        break;
      case HapticProfile.cyber:
        HapticFeedback.heavyImpact();
        break;
    }
  }

  /// Ödül toplama / sandık açma / görev tamamlama
  static void reward() {
    if (!isEnabled) return;
    switch (profile) {
      case HapticProfile.zen:
        HapticFeedback.lightImpact();
        break;
      case HapticProfile.arcade:
        HapticFeedback.mediumImpact();
        break;
      case HapticProfile.cyber:
        HapticFeedback.heavyImpact();
        break;
    }
  }

  /// Blok kaldırma (tepsiden taşı alma anı)
  static void blockPickup() {
    if (!isEnabled) return;
    switch (profile) {
      case HapticProfile.zen:
        HapticFeedback.selectionClick();
        break;
      case HapticProfile.arcade:
        HapticFeedback.lightImpact();
        break;
      case HapticProfile.cyber:
        HapticFeedback.lightImpact();
        break;
    }
  }

  /// Blok yerleştirme (tahtaya başarıyla bırakma)
  static void blockPlace() {
    if (!isEnabled) return;
    switch (profile) {
      case HapticProfile.zen:
        HapticFeedback.lightImpact();
        break;
      case HapticProfile.arcade:
        HapticFeedback.lightImpact();
        break;
      case HapticProfile.cyber:
        HapticFeedback.mediumImpact();
        break;
    }
  }

  /// Çizgi temizleme / patlama titreşimi
  static void lineClear(int linesCount) {
    if (!isEnabled) return;
    switch (profile) {
      case HapticProfile.zen:
        if (linesCount >= 3) {
          HapticFeedback.mediumImpact();
        } else {
          HapticFeedback.lightImpact();
        }
        break;
      case HapticProfile.arcade:
        if (linesCount >= 3) {
          HapticFeedback.heavyImpact();
        } else {
          HapticFeedback.mediumImpact();
        }
        break;
      case HapticProfile.cyber:
        if (linesCount >= 3) {
          HapticFeedback.vibrate();
        } else {
          HapticFeedback.heavyImpact();
        }
        break;
    }
  }

  /// Kombo serisi titreşimi
  static void combo(int streak) {
    if (!isEnabled) return;
    switch (profile) {
      case HapticProfile.zen:
        if (streak >= 5) {
          HapticFeedback.mediumImpact();
        } else {
          HapticFeedback.lightImpact();
        }
        break;
      case HapticProfile.arcade:
        if (streak >= 5) {
          HapticFeedback.heavyImpact();
        } else if (streak >= 3) {
          HapticFeedback.mediumImpact();
        } else {
          HapticFeedback.lightImpact();
        }
        break;
      case HapticProfile.cyber:
        if (streak >= 6) {
          HapticFeedback.vibrate();
        } else if (streak >= 3) {
          HapticFeedback.heavyImpact();
        } else {
          HapticFeedback.mediumImpact();
        }
        break;
    }
  }

  /// Nihai yetenek ateşleme
  static void ultimate() {
    if (!isEnabled) return;
    switch (profile) {
      case HapticProfile.zen:
        HapticFeedback.mediumImpact();
        break;
      case HapticProfile.arcade:
        HapticFeedback.heavyImpact();
        break;
      case HapticProfile.cyber:
        HapticFeedback.vibrate();
        break;
    }
  }

  /// Oyun bittiğinde
  static void gameOver() {
    if (!isEnabled) return;
    switch (profile) {
      case HapticProfile.zen:
        HapticFeedback.mediumImpact();
        break;
      case HapticProfile.arcade:
        HapticFeedback.vibrate();
        break;
      case HapticProfile.cyber:
        HapticFeedback.vibrate();
        break;
    }
  }

  /// Profil değiştirildiğinde kullanıcıya anında hissettiren test titreşimi
  static void testPreview(HapticProfile targetProfile) {
    switch (targetProfile) {
      case HapticProfile.zen:
        HapticFeedback.selectionClick();
        break;
      case HapticProfile.arcade:
        HapticFeedback.mediumImpact();
        break;
      case HapticProfile.cyber:
        HapticFeedback.heavyImpact();
        break;
    }
  }
}
