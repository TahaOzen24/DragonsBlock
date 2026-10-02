# DragonsBlock — Play Release Checklist

Paket: `com.dragonsblock.app` · Versiyon: `1.0.0+1`

## 1. Signing (keystore)

- [x] Yerel `android/upload-keystore.jks` + `android/key.properties` oluşturuldu (gitignored)
- [x] Release build debug imzaya düşmez — keystore yoksa Gradle fail
- [ ] **Yedek al:** `.jks` + şifreleri güvenli yere kopyala (Play güncellemesi için zorunlu)
- [ ] Play Console → App signing → upload key kaydı (ilk AAB yüklemede)

Yeniden üretmek gerekirse:
```powershell
powershell -ExecutionPolicy Bypass -File tool/create_upload_keystore.ps1
```

## 2. AdMob (prod)

Kayıtlı ID’ler: [ADMOB_SETUP.md](ADMOB_SETUP.md)

| Dosya | Durum |
|-------|--------|
| `android/admob.properties` | App ID (gitignored; örnek: `admob.properties.example`) |
| `dart_defines.admob.json` | Rewarded + Interstitial unit ID’ler |

Release build:
```bat
flutter build appbundle --release --dart-define-from-file=dart_defines.admob.json
```

- [ ] AdMob Console’da test cihazı GAID kayıtlı
- [ ] Release APK/AAB’de gerçek birimler (test ID değil) doğrulandı
- [ ] Policy / app-ads.txt (gerekirse)

## 3. Privacy policy (Play zorunlu)

- [x] Metin: [docs/privacy-policy.md](docs/privacy-policy.md) + hostlanabilir HTML: [docs/privacy-policy.html](docs/privacy-policy.html)
- [ ] **Herkese açık URL** yayınla (GitHub Pages / kendi domain)
  - Önerilen: `https://<senin-domain>/privacy` veya Pages
- [ ] Play Console → App content → Privacy policy → URL yapıştır
- [ ] Data safety formu: AdMob (Advertising ID), IAP (Play Billing)

Uygulama içi: Ayarlar → Gizlilik Politikası (tam metin dialog). Harici URL sabiti: `lib/core/config/legal_urls.dart`.

## 4. Play listing assets

- [ ] App icon 512×512 (`assets/images/app_icon.png` kaynak)
- [ ] Feature graphic 1024×500
- [ ] Phone screenshots (en az 2)
- [ ] Kısa açıklama / uzun açıklama (TR + EN)
- [ ] İçerik derecelendirmesi anketi

## 5. IAP (Play Console)

Ürün ID’leri kodla aynı olmalı (`IapService.catalog`):

| Product ID | Tip |
|------------|-----|
| `shards_tier1_500` | Consumable |
| `shards_tier2_1500` | Consumable |
| `shards_tier3_5000` | Consumable |
| `no_ads_lifetime` | Non-consumable |
| `battle_pass_premium` | Non-consumable |

- [ ] Ürünler Play Console’da Active
- [ ] Lisans test hesabı eklendi
- [x] Uygulama offline/fallback ile ücretsiz ürün vermiyor

## 6. Smoke test (yayın öncesi)

```bat
flutter analyze
flutter test
flutter build appbundle --release --dart-define-from-file=dart_defines.admob.json
```

- [ ] Cold start, bir oyun, shop açılışı, reklam (test device), IAP test purchase
