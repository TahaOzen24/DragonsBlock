# DragonsBlock

> 8×8 tactile block puzzle — dragon powers, elemental runes & roguelike blessings.

**Paket ID (AdMob / Play):** `com.dragonsblock.app`  
**AdMob kurulum:** [ADMOB_SETUP.md](ADMOB_SETUP.md)

![Flutter](https://img.shields.io/badge/Flutter-3.10-blue) ![Dart](https://img.shields.io/badge/Dart-3.10-blue)

## Özellikler
- **Core Loop:** 8×8 grid, polyomino placement, satır/sütun temizleme, perfect sweep bonus (`lib/features/game/logic/grid_engine.dart:172`)
- **Dragon Powers:** Fire 3×3, Ice rows, Storm cross, Earth burst
- **Hyperdrive Fever:** Combo ile şarj, 2× skor
- **Meta:** Shop, Adventure, Quests, Daily Challenge, Block Themes
- **Ads:** `AdService` (rewarded + interstitial, `dart-define` ile prod ID)

## Kurulum

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

Prod AdMob ile build (detay: `ADMOB_SETUP.md`):
```bash
copy android\admob.properties.example android\admob.properties
# ADMOB_APP_ID'yi gerçek App ID ile doldur

flutter build apk --release ^
  --dart-define=ADMOB_REWARDED_ANDROID=ca-app-pub-xxx/yyy ^
  --dart-define=ADMOB_INTERSTITIAL_ANDROID=ca-app-pub-xxx/zzz
```

## Proje Yapısı
```
lib/
  main.dart                 # runZonedGuarded + FlutterError handling
  core/
    ads/ ad_service.dart
    analytics/ analytics_service.dart
    config/ game_config.dart # tuning tek nokta
    storage/ app_prefs.dart  # SharedPreferences wrapper
    theme/ game_theme.dart
  features/
    game/ (logic/grid_engine, models, presentation)
    shop/, battle_pass/, guild/, tournament/ ... (31 domain)
assets/
  images/ app_icon.png + boss art
  audio/  pop/place/combo SFX + procedural fallback
  fonts/  Outfit, SpaceGrotesk
```

## Mimari Kararlar
- **State:** Singleton `ChangeNotifier` + `Managers` registry. Gelecekte Riverpod/Provider'a tek dosyada geçiş.
- **Persistence:** `AppPrefs` wrapper üzerinden `SharedPreferences` (migration versiyonlu).
- **Config:** `GameConfig` remote-config seam — Firebase Remote Config bağlamaya hazır.

## Analiz Sonuçları (son run)
- `flutter analyze`: **No issues found**
- `flutter test`: **40 passed**

## Store Checklist (P0)
- [x] INTERNET + AD_ID permission (`android/app/src/main/AndroidManifest.xml`)
- [x] Release signing: `android/key.properties` + `upload-keystore.jks` (gitignored; script: `tool/create_upload_keystore.ps1`)
- [x] Test AdMob ID dart-define ile override edilebilir (`dart_defines.admob.json`)
- [x] IAP offline ücretsiz grant kapatıldı
- [x] Privacy policy metni: `docs/privacy-policy.html` (host URL Play’e eklenecek)
- [ ] Privacy policy **public HTTPS URL** → `PRIVACY_POLICY_URL` + Play Console
- [ ] Play listing: feature graphic, screenshots, Data safety
- [ ] Firebase Analytics/Crashlytics: `AnalyticsService.setBackend`

Detay: [PLAY_RELEASE.md](PLAY_RELEASE.md) · AdMob: [ADMOB_SETUP.md](ADMOB_SETUP.md)

## Solo-Dev Notu
Master Prompt hedefi: asset-minimal, low content cost. Mevcut 31 domain fazla — LiveOps sürdürülebilir değil. Öneri: core 10 domaine indir, kalanları sezonluk modül olarak aç.

## Lisans
Private — `publish_to: none`
