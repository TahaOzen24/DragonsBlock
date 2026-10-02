# DragonsBlock — AdMob

## Kayıtlı ID'ler

| Tür | ID |
|-----|-----|
| **App ID** | `ca-app-pub-8081463517220236~3039947448` ✅ |
| **Rewarded** | `ca-app-pub-8081463517220236/8690980946` ✅ |
| **Interstitial** | `ca-app-pub-8081463517220236/9309842323` ✅ |

## Dosyalar

| Dosya | Amaç |
|-------|------|
| `android/admob.properties` | Manifest App ID (gitignored; örnek: `.example`) |
| `dart_defines.admob.json` | Unit ID + isteğe bağlı `PRIVACY_POLICY_URL` |

## Debug vs Prod

| Mod | Ne olur |
|-----|---------|
| `flutter run` (debug) | **Google test reklamları** — ekranda çıkar |
| Release + dart-define | Senin gerçek birimlerin |
| İnceleme / mağaza yok | Prod birimler çoğu zaman **No fill** |

## Test device (AdMob Console)

Use the advertising ID shown in the AdMob test-device setup flow for the
specific development device. Do not commit device identifiers to this
repository.

(İsteğe bağlı telefonda) **Reklamlarda hata ayıklama günlüğünü etkinleştir** → aç

## Komutlar

```bash
# Test reklam
flutter run

# Gerçek birimler (test device + release)
flutter run --dart-define-from-file=dart_defines.admob.json --dart-define=ADMOB_FORCE_PROD=true

# Play AAB
flutter build appbundle --release --dart-define-from-file=dart_defines.admob.json
```

Tam yayın checklist: [PLAY_RELEASE.md](PLAY_RELEASE.md)
