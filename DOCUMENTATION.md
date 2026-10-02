# 🧩 Block Survivor — Kapsamlı Oyun Dokümantasyonu

**Versiyon:** 1.0.0+1  
**Son Güncelleme:** Eylül 2026  
**Platform:** Android (Flutter)  
**Dil:** Dart/Flutter  

---

## 📋 İçindekiler

1. [Proje Özeti](#1-proje-özeti)
2. [Teknik Mimari](#2-teknik-mimari)
3. [Oyun Mekaniği](#3-oyun-mekaniği)
4. [Şekil Üretim Sistemi](#4-şekil-üretim-sistemi)
5. [Dinamik Zorluk Sistemi](#5-dinamik-zorluk-sistemi)
6. [Scoring Sistemi](#6-scoring-sistemi)
7. [Combo Sistemi](#7-combo-sistemi)
8. [Kurtarma Mekanikleri](#8-kurtarma-mekanikleri)
9. [Ses Sistemi](#9-ses-sistemi)
10. [Görsel Efektler](#10-görsel-efektler)
11. [UI/UX Tasarımı](#11-uiux-tasarımı)
12. [Veri Yönetimi](#12-veri-yönetimi)
13. [Ekonomi Sistemi](#13-ekonomi-sistemi)
14. [Yapılacaklar & Eksikler](#14-yapılacaklar--eksikler)

---

## 1. Proje Özeti

**Block Survivor**, 8x8 ızgarada blokları yerleştirip satır/sütun temizleyerek puan toplanan bir puzzle oyunudur. Block Blast'tan ilham alarak, ancak kendi özgün mekanikleriyle tasarlanmıştır.

### Temel Özellikler
- **8x8 Izgara** puzzle oyunu
- **7 basit şekil** (2-4 blok: çizgi, kare, L, T)
- **Combo sistemi** ile artan çarpanlar
- **Dinamik zorluk** (oyuncu performansına göre ayarlanan)
- **Minimal cam stili** zarif blok tasarımı
- **Pastel renk paleti** göz yormayan tonlar
- **Confetti kutlama** efektleri
- **Ses efektleri** (procedural synthesizer)

---

## 2. Teknik Mimari

### Dosya Yapısı
```
lib/
├── core/
│   ├── config/game_config.dart          # GameTuning, ShapeDroughtTracker, DynamicDifficulty
│   ├── audio/procedural_audio.dart       # Procedural ses üretimi (SoLoud + AudioPlayers)
│   ├── particles/particle_system.dart    # Parçacık sistemi (havuzlu, 300 max)
│   ├── vfx/screen_shake.dart            # Screen shake (trauma tabanlı)
│   ├── haptics/haptic_service.dart       # Titreşim servisi (3 profil)
│   ├── settings/settings_manager.dart    # Ayarlar yönetimi
│   ├── theme/game_theme.dart             # Tasarım sistemi (renk, font, spacing)
│   ├── storage/app_prefs.dart            # SharedPreferences wrapper
│   └── state/managers.dart              # Manager lifecycle
├── features/
│   ├── game/
│   │   ├── logic/
│   │   │   ├── grid_engine.dart          # Ana oyun motoru (8x8 grid, scoring, line clear)
│   │   │   ├── shape_spawner_engine.dart # Akıllı şekil üretimi (board-aware)
│   │   │   └── engine_helpers.dart       # Saf grid fonksiyonları
│   │   ├── models/
│   │   │   ├── polyomino_shape.dart      # Şekil tanımları ve palet
│   │   │   ├── grid_cell.dart            # Hücre modeli
│   │   │   ├── block_skin_style.dart     # 8 blok stili
│   │   │   ├── board_era.dart            # Skor bazlı görsel çağlar
│   │   │   └── combo_realm_theme.dart    # 8 dünya teması
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── game_screen.dart      # Ana oyun ekranı (oyun mantığı)
│   │       │   ├── main_menu_screen.dart # Ana menü (5 sekme)
│   │       │   └── splash_screen.dart    # Açılış ekranı (yeni logo)
│   │       ├── vfx/
│   │       │   ├── game_vfx_controller.dart # Clear/surge/stinger/flash/frenzy
│   │       │   ├── game_board_geometry.dart # Hücre/merkez koordinatları
│   │       │   └── game_dynamic_background.dart # Dinamik arka plan
│   │       ├── painters/
│   │       │   ├── grid_painter.dart     # Izgara boyacısı (GPU optimizeli, 6 seviyeli efekt)
│   │       │   ├── block_skin_painter.dart # 8 blok stili boyacısı
│   │       │   └── particle_painter.dart # Parçacık boyacısı
│   │       └── widgets/
│   │           ├── game_hud.dart         # Skor, combo, dragon butonu
│   │           ├── game_over_dialog.dart # Oyun bitiş ekranı
│   │           ├── block_spawner_bar.dart # 3 blok slotu
│   │           └── block_preview_widget.dart # Sürükleme önizlemesi
│   ├── shop/                             # Mağaza sistemi
│   ├── profile/                          # Oyuncu profili
│   ├── daily_challenge/                  # Günlük mücadele
│   ├── achievements/                     # Başarımlar
│   ├── dragon/                           # Ejderha sistemi
│   ├── talents/                          # Yetenek ağacı
│   └── adventure/                        # Macera modu
```

### Bağımlılıklar
```yaml
dependencies:
  flutter_animate: ^4.5.2          # Animasyonlar
  audioplayers: ^6.7.1             # Ses çalma
  flutter_soloud: ^3.5.4           # Düşük gecikmeli ses
  shared_preferences: ^2.5.5       # Veri saklama
  confetti: ^0.7.0                 # Confetti efekti
  google_mobile_ads: ^9.1.0        # Reklamlar
  in_app_purchase: ^3.2.0          # Satın alımlar
```

---

## 3. Oyun Mekaniği

### Temel Döngü
1. Oyuncuya 3 şekil verilir
2. Şekilleri sürükle ve ızgaraya bırak
3. Satır veya sütun dolarsa temizlenir → puan kazanılır
4. Combo streak artarsa çarpan artar
5. Board dolarsa ve yerleşecek yer yoksa → oyun biter

### Izgara Boyutu
- **8x8** sabit ızgara
- Toplam **64 hücre**
- Hücre başına **10 puan** (base)

### Şekil Yerleştirme
- `canPlace()` → hücre boş mu kontrol eder
- `frozenTurns > 0` olan hücrelere yerleştirilemez
- Yerleştirme sonrası `frozenTurns` azalır (her tur 1 azalır)
- Kalıcı buz (`frozenTurns = 999`) azalmaz

---

## 4. Şekil Üretim Sistemi

### Kullanılan 7 Basit Şekil

| Şekil | ID | Blok | Aile | Açıklama |
|-------|-----|------|------|----------|
| Çizgi 2 | `line_2` | 2 | line | Yatay/dikey çizgi |
| Çizgi 3 | `line_3` | 3 | line | Yatay/dikey çizgi |
| Çizgi 4 | `line_4` | 4 | line | Yatay/dikey çizgi |
| Köşe 3 | `corner_3` | 3 | lShape | L-köşe |
| L-Şekli 4 | `l_shape_4` | 4 | lShape | L-şekli |
| Kare 2x2 | `square_2x2` | 4 | block | Kare |
| T-Şekli | `t_shape` | 4 | branch | T-şekli |

### Ağırlıklı Seçim Sistemi
`GameTuning.shapeWeights` ile oyun fazına göre ağırlıklar:

```dart
'early': [25, 20, 15, 0, 10, 5, 0, 0, 10, 2, 0, 8, 5, 0, 0],
'mid':   [15, 15, 18, 5, 8, 10, 5, 3, 10, 3, 2, 10, 5, 2, 2],
'late':  [10, 12, 20, 10, 5, 12, 8, 5, 8, 5, 3, 10, 5, 3, 4],
'emergency': [30, 25, 10, 0, 10, 0, 0, 0, 15, 0, 0, 5, 5, 0, 0],
```

### Drought Tracker
`ShapeDroughtTracker` ile:
- `needsSolver`: 5+ hamlede line-clear yoksa → solver parçası zorunlu
- `needsSmallPiece`: 3+ hamlede küçük parça gelmediyse → küçük parçalar tercih edilir
- `isFamilyOverused()`: Aynı aileden 2+ parça geldiyse → engellenir

### Board-Aware Solver
`_findBestBoardSolvingCandidate()` → Mevcut tahtada en çok satır/sütun temizleyen parçayı bulur.

---

## 5. Dinamik Zorluk Sistemi

### Flow State Hesaplama
```dart
double calculateFlowState({
  required double occupancyRate,    // Doluluk oranı
  required int movesSinceLastClear, // Son temizlemeden beri geçen hamle
  required int comboStreak,         // Combo serisi
  required int totalLinesCleared,   // Toplam temizlenen çizgi
  required int movesCount,          // Toplam hamle
})
```

### Zorluk Profilleri
| Flow State | Profil | Davranış |
|-----------|--------|----------|
| > 0.7 | aggressive | Büyük parçalar, meydan okuma |
| 0.4-0.7 | balanced | Normal |
| 0.2-0.4 | defensive | Küçük parçalar, kolaylaştırma |
| < 0.2 | emergency | Acil kurtarma modu |

### Yeni Oyuncu Deneyimi (İlk 5 Oyun)
- `gamesPlayed < 5` ise `isNewPlayer = true`
- Daha fazla çizgi parçası (line4 tercihli)
- Daha küçük L-şekilleri
- Kolay yerleştirilebilir parçalar

---

## 6. Scoring Sistemi

### Temel Puanlama
```
baseScore = placedBlocks * 10
```

### Çizgi Temizleme Puanları
| Çizgi Sayısı | Puan |
|-------------|------|
| 1 | 75 |
| 2 | 200 |
| 3 | 500 |
| 4 | 1,200 |
| 5+ | 2,500 + (n-5) * 1,000 |

### Combo Çarpanı
| Combo | Çarpan |
|-------|--------|
| 1 | 1.0x |
| 2 | 1.3x |
| 3 | 1.8x |
| 4 | 2.5x |
| 5+ | 3.0 + (streak-5) * 0.5 |

### Ek Puanlar
- **Cross-clear bonus**: 500 * (satır * sütun) — Hem yatay hem dikey temizlenirse
- **Perfect clear**: 4,000 * streakMultiplier — Tahta tamamen temizlenirse
- **Almost-clear bonus**: 50 puan — 7/8 dolu satır/sütun

### Formül
```
totalPoints = ((baseScore + lineClearPoints + crossClearBonus) * globalMultiplier * feverMultiplier * surgeMultiplier)
```

---

## 7. Combo Sistemi

### Combo Streak
- Her çizgi temizlemede `comboStreak++`
- Temizleme olmadan yerleştirme → `comboStreak = 0`

### Hyperdrive Fever
- Enerji: `linesCleared * 25 + comboStreak * 15`
- Eşik: 90 enerji → 2x puan çarpanı (3 hamle)

### Frenzy Timer
- Combo tetiklendiğinde başlar
- Süre: 6000ms (base) × çarpanlar
- Süre dolduğunda combo sıfırlanır

### Confetti Kutlama
- 4+ satır VEYA 6+ combo → Confetti patlaması (30 parçacık)
- 3+ satır → Hafif confetti

---

## 8. Kurtarma Mekanikleri

### Kurtarma Zinciri (Sırayla)
1. **Acil Kurtarma** (relic/enchantment/pet)
2. **Aegis Bastion** — Alt 2 satırı eritir (1x/orun)
3. **Glacial Tortoise** — Alt 1 satırı eritir (1x/orun)
4. **Phoenix Constellation** — Alt 2 satırı eritir (1x/orun)
5. **Revive** — 200 altın VEYA reklam izle → Alt 3 satır temizle
6. **Game Over**

### Revive Kuralları
- Maksimum 1 revive/orun
- Minimum skor: 500
- Altın düşümü: `GameTuning.reviveCostGold = 200`
- Geri sayım: 5 saniye

---

## 9. Ses Sistemi

### Mimari: Hibrit Motor
1. **flutter_soloud** (birincil, <3ms gecikme) — 4 SFX + 10 combo
2. **audioplayers** (fallback) — Geri kalan tüm sesler

### Procedural Ses Üretimi
Tüm sesler matematiksel olarak üretilir (dış ses dosyası yok):
- **Place**: 5 katman (body + mid + click + noise + ring)
- **Explosion**: 6 katman (sub + body + mallet + click + noise + ring)
- **Combo**: 5 katman (fund + overtone + sparkle + sub + noise)
- **Game Over**: Aşağı yönlü frekans sweep

### Master Volume
- `ProceduralAudio.masterVolume` (0.0-1.0)
- Settings dialog'dan slider ile kontrol
- Varsayılan: 0.8

---

## 10. Görsel Efektler

### Parçacık Sistemi
- Havuzlu (max 300 aktif, max 96 havuzda)
- `spawnExplosion()`: Kristal parlamaları (daire + sparkle)
- `spawnComboSparks()`: Zarif combo parlamaları
- `spawnDragTrail()`: Sürükleme izi

### Screen Shake
- Trauma tabanlı (0.0-1.0)
- Intensity parametresi artık aktif
- Quadraik azalma (T^2)

### Screen Flash
- Büyük combo'larda ekran beyazlayıp sönüyor
- 120ms (massive) veya 60ms (big)

### Block Stilleri (8 adet)
1. **Minimal Glass** (varsayılan) — Zarif, cam benzeri
2. **Soft Jelly** — Yumuşak, şeker
3. **3D Mücevher** — Işıltılı, canlı
4. **Sıcak Yün** — Sıcak, dokulu
5. **İskandinav Ahşap** — Doğal, sade
6. **Mat Seramik** — Minimal, sakin
7. **Siber Neon** — Enerjik, parlak
8. **Kozmik Galaksi** — Derin, gizemli

### Blok Renkleri (Pastel Palet)
| Renk | Hex |
|------|-----|
| Soft Rose | #E57373 |
| Muted Blue | #64B5F6 |
| Sage Green | #81C784 |
| Warm Amber | #FFD54F |
| Muted Lavender | #BA68C8 |
| Teal | #4DB6AC |
| Soft Coral | #FF8A65 |

---

## 11. UI/UX Tasarımı

### Tasarım Sistemi (GameTheme)
- **Fontlar**: Outfit (birincil), SpaceGrotesk (ikincil)
- **Renkler**: 20+ token (bgDarkest, neonCyan, goldAccent, vb.)
- **Spacing**: 4pt ölçeği (4, 8, 12, 16, 20, 24, 32, 40)
- **Radius**: 6 seviye (8, 12, 16, 20, 28, 999)

### Ekranlar
1. **Splash Screen** — Özel logo (CustomPaint), 2sn animasyon
2. **Ana Menü** — 5 sekme (Mağaza, Koleksiyon, Ana Sayfa, Liderlik, Kulüp)
3. **Oyun Ekranı** — Izgara + HUD + blok slotları
4. **Game Over** — Skor, revive, 2X, tekrar oyna
5. **Ayarlar** — Ses, müzik, dil, titreme, pil tasarrufu
6. **Mağaza** — Temalar, VFX, paketler, ücretsiz
7. **Profil** — İsim, avatar, istatistikler

### Font Boyutları
- Minimum: 10px (erişilebilirlik)
- Başlık: 18-32px
- Gövde: 11-14px
- Etiket: 8-10.5px

---

## 12. Veri Yönetimi

### SharedPreferences Keys
| Key | Tür | Açıklama |
|-----|-----|----------|
| `high_score` | int | En yüksek skor |
| `games_played` | int | Oynanan oyun sayısı |
| `player_name` | String | Oyuncu adı |
| `player_avatar_id` | String | Seçili avatar |
| `player_frame_id` | String | Seçili çerçeve |
| `selected_block_skin_style` | int | Blok stili indeksi |
| `setting_sound` | bool | Ses efektleri |
| `setting_music` | bool | Müzik |
| `setting_haptics` | bool | Titreşim |
| `setting_screenshake` | bool | Ekran sarsıntısı |
| `setting_batterysaver` | bool | Pil tasarrufu |

### Pil Tasarrufu Etkisi
- Parçacık sayısı %50 azalır
- Confetti devre dışı
- Screen flash devre dışı

---

## 13. Ekonomi Sistemi

### Para Birimi: Gold Shards
- Başlangıç: 100 shard
- Günlük bonus: 50 shard
- Idle Vault: 50 shard/saat (max 8 saat = 400)

### Kazanma Yolları
- Çizgi temizleme (değişken)
- Günlük mücadele
- Reklam izleme (+100)
- Idle Vault toplama
- Boss öldürme

### Harcama Yerleri
- Revive: 200 shard
- Mağaza (tema/VFX)
- Boosters (Rocket: 150, Hammer: 100, Bomb: 200)

---

## 14. Yapılacaklar & Eksikler

### Yüksek Öncelik
- [x] Ice Surge ölü kod / çift puan — kaldırıldı
- [x] Frozen hücre görseli
- [x] Leaderboard yerel simülasyon etiketi
- [x] game_screen AppPrefs (high_score / games_played)
- [x] SharedPreferences AppPrefs bypass (kalan manager'lar) — tamamlandı
- [x] game_screen UI/VFX parçalama
- [x] Keystore / release signing (yerel; Play upload key yedeklenmeli)
- [x] IAP offline ücretsiz grant kapatıldı
- [ ] Privacy policy public URL + Play listing assets
- [ ] Keystore / Play yayın (AAB yükleme)


### Orta Öncelik
- [x] Undo/Reroll/Hammer UI
- [x] Volume slider (eklendi)
- [x] Near-complete satır göstergesi (kaldırıldı)
- [x] Battery saver aktifleştirme (eklendi)
- [x] Parça döndürme (swipe ile 90°)
- [x] Next queue (sıradaki parçalar)

### Düşük Öncelik
- [ ] Cloud save
- [ ] Leaderboard entegrasyonu
- [ ] Push notification
- [ ] Rate this app prompt
- [ ] News/changelog ekranı

---

## 📊 Test Durumu

```
flutter test → 46/46 test geçti ✅
dart analyze → 0 hata ✅
flutter build apk → Başarılı ✅
```

---

## 🎮 Değişiklik Geçmişi

### v1.0.0 (Eylül 2026)
- 7 basit şekil ile yeniden tasarım
- Pastel renk paleti
- Minimal cam blok stili
- Confetti kutlama efektleri
- Crystal patlama efekti (ateş yerine)
- Combo yazıları yeniden tasarlandı (zarif semboller)
- Sürükleme izi parçacıkları
- Ghost block önizlemesi
- Satır/sütun temizleme vurgusu
- Kademeli çizgi temizleme animasyonu
- Ekran flash (büyük combo'larda)
- Thud efekti (her yerleştirmede)
- Board reveal animasyonu
- Confetti (4+ satır)
- Volume slider
- Splash screen (özel logo)
- Profil güçlendirme (isim, 6 istatistik)
- Revive altın düşümü
- Screen shake intensity aktif
- Drought tracker entegrasyonu
- Battery saver (confetti/flash devre dışı)
- Tutorial hint kaldırıldı
- Near-complete vurgusu kaldırıldı
- Dragon güç butonu kaldırıldı
- Alt bar (mavi pedestal) kaldırıldı

### v1.0.1 — Sürükleme & Oynanış İyileştirmeleri
- **Drought Tracker düzeltildi**: `ShapeDroughtTracker()` her erişimde yeni instance oluşturuyordu; `_droughtTracker` instance field'a çevrildi. `needsSolver`, `needsSmallPiece` artık gerçekten çalışıyor.
- **Blok sürükleme pozisyonu**: Blok parmağın üstünde, `feedbackHeight + 60px` offset ile tam görünür.
- **Drag feedback sadeleştirildi**: 3 ağır BoxShadow kaldırıldı, `Transform.scale(1.12)` kaldırıldı, blok1:1 boyutta.
- **Ghost preview sadeleştirildi**: `saveLayer` + tam blok render kaldırıldı; basit yarı-saydam dolgu + ince kenarlık.
- **Pickup animasyonu hızlandırıldı**: 140ms → 100ms, squeeze 0.84 → 0.90.

### v1.0.2 — Yerleştirme Affediciliği & Akıcılık
- **Yerleştirme `.floor()` → `.round()`**: En yakın hücreye yuvarlanır, tam hizalama gerekmez.
- **Yakın geçerli pozisyon araması**: `_findNearbyValidPlacement()` — bırakılan pozisyon bloke ise çevredeki hücrelerde (radius 1-2) geçerli yer arar.
- **Sürükleme akıcılığı**: `spawnDragTrail` her harekette parçacık üretiyordu → kaldırıldı (lag kaynağı).
- **Haptik azaltıldı**: Hücre değişimindeki `AppHaptics.selection()` kaldırıldı; sadece satır tamamlanınca `medium()`.

### v1.0.3 — Hata Düzeltmeleri
- **`particle_painter.dart:227`**: Gradient `stops` sabit 3 elemanlı ama normal badge'de 2 renk vardı → `stops: isComboBanner ? [0,0.45,1] : [0,1]` yapıldı. Crash düzeltildi.

### v1.0.4 — Menü Sekmeleri Lokalizasyonu
- **30+ yeni AppStrings getter** eklendi (Collection, Leaderboard, Club, Bottom Nav).
- Main menu'deki hardcoded Türkçe stringler AppStrings'e çevrildi.
- Duplicate string tanımları `tab` prefix ile yeniden adlandırıldı.
- `const` widget'lardan AppStrings runtime değerleri kullanıldığında `const` kaldırıldı.
