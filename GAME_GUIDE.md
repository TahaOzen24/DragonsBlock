# 🎮 BLOCK SURVIVOR — KAPSAMLI OYUN KILAVUZU VE SİSTEM MİMARİSİ

Bu belge; **Block Survivor** projesinin kod tabanında **birebir uygulanmış ve çalışan** tüm oynanış mekaniklerini, görsel sanat sistemini, şampiyonlarını, oyun modlarını ve mağaza/IAP mimarisini detaylandıran resmi kılavuzdur.

---

## 📌 İÇİNDEKİLER
1. [Oyunun Özeti ve Tasarım Felsefesi](#1-oyunun-özeti-ve-tasarım-felsefesi)
2. [Temel Oynanış Mekanikleri (Core Gameplay Loop)](#2-temel-oynanış-mekanikleri-core-gameplay-loop)
3. [Görsel Sanat Mimarisi ve Taş Tasarımı (Candy-Gem Aesthetic)](#3-görsel-sanat-mimarisi-ve-taş-tasarımı-candy-gem-aesthetic)
4. [Aktif Oyun Modları ve Etkinlikler](#4-aktif-oyun-modları-ve-etkinlikler)
5. [Şampiyonlar ve Nihai Yetenek Sistemi (Champions)](#5-şampiyonlar-ve-nihai-yetenek-sistemi-champions)
6. [Kadim Parşömenler ve Kehanet Rünleri (Meta-Progression)](#6-kadim-parşömenler-ve-kehanet-rünleri-meta-progression)
7. [Ekonomi ve Mağaza Mimarisi (Real IAP & Altın)](#7-ekonomi-ve-mağaza-mimarisi-real-iap--altın)
8. [Ses, Haptik ve Yaşam Döngüsü Güvenliği](#8-ses-haptik-ve-yaşam-döngüsü-güvenliği)
9. [Teknik Özellikler ve Google Play Uyumluluğu](#9-teknik-özellikler-ve-google-play-uyumluluğu)

---

## 1. Oyunun Özeti ve Tasarım Felsefesi

**Block Survivor**, 8x8 ızgara üzerinde klasik blok yerleştirme bulmacasını şampiyon yetenekleri, kadim parşömenler ve RPG ilerleme mekanikleriyle birleştiren hibrit bir oyundur.

### Temel Sistem Kuralları:
* **1x1 Blok Kesinlikle Yasaktır:** Rastgele tek noktalı (1x1) kurtarıcı taşlar asla tahtada spawn edilmez. Minimum şekil 1x2 (domino) veya daha büyüktür.
* **Zen UI (Sıfır Bildirim Kirliliği):** Oyun esnasında dikkati dağıtan devasa stinger afişler yer almaz; yalnızca uçuşan zarif skor sayıları (+100, +300), kristalize ışıltılar ve akıcı mikro-haptik titreşimler bulunur.
* **Şampiyon Sinerjisi:** Temizlenen her satır/sütun, seçili şampiyonun Ultimate enerji barını şarj eder.

---

## 2. Temel Oynanış Mekanikleri (Core Gameplay Loop)

```
┌─────────────────────────────────────────────────────────────┐
│                    TEMEL OYNANIŞ DÖNGÜSÜ                    │
├─────────────────────────────────────────────────────────────┤
│ 1. 8x8 Izgara Tahtası: 3'lü şekil grubundan blok yerleştir  │
│ 2. Hat Temizleme: Satır veya sütunları tamamen doldur       │
│ 3. Kombo & Seri (Streak): Zincirleme hamlelerle çarpan kazan │
│ 4. Şampiyon Enerjisi: Barı doldur ve Nihai Yeteneği patlat! │
│ 5. Acil Kurtarma: Tıkanınca Parşömen/Ödüllü Reklamla dön    │
└─────────────────────────────────────────────────────────────┘
```

### 2.1. Tahta ve Şekil Dağılımı (8x8 Grid)
* Tahta 8x8 hücreden oluşur.
* Alt dock alanında oyuncuya her turda **3 adet şekil** sunulur.
* 3 şekil tahtaya yerleştirilmeden yeni şekil grubu gelmez.
* Satır veya sütun tamamen dolduğunda hat patlar, hücreler temizlenir ve puan kazandırır.

### 2.2. Kombo ve Seri (Streak) Çarpanı
* **Çoklu Hat (Multi-Line):** Aynı hamlede birden fazla hat (2x, 3x, 4x) temizlemek ekstra çarpan ve enerji kazandırır.
* **Seri (Streak):** Peş peşe gelen her temizleme hamlesi seriyi 1 artırır; seri bozulmadıkça her temizlik katlanarak daha yüksek puan verir.

### 2.3. Acil Durum Kurtarma (Emergency Rescue)
* Eğer alt dock'taki hiçbir şekil tahtaya yerleşemiyorsa oyun doğrudan bitmez.
* Oyuncu **Ödüllü Reklam İzleme** veya **Yeniden Canlanma Parşömeni** kullanarak şekilleri tazeleyebilir ve oyuna devam edebilir.

---

## 3. Görsel Sanat Mimarisi ve Taş Tasarımı (Candy-Gem Aesthetic)

Taşlar raster PNG görseller yerine **GPU hızlandırmalı vektörel CustomPainter Canvas** mimarisiyle çizilir.

```
┌──────────────────────────────┐
│  ╭────────────────────────╮  │  ◄── 1. Üst-İç Elips Hap Vurgusu (Pill Highlight)
│  │                        │  │
│  │   DİKEY GÖVDE GRADIENT │  │  ◄── 2. Canlı Mücevher Renk Gradyanı (Üst açık, alt koyu)
│  │   (Ruby / Sapphire /   │  │
│  │    Emerald / Amber)    │  │
│  │                        │  │
│  ╰────────────────────────╯  │  ◄── 3. Alt İç Ortam Karartması (Ambient Occlusion)
└──────────────────────────────┘
  ▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼
     4. Yumuşak Düşen Gölge (Drop Shadow)
```

### 3.1. Dört Katmanlı Taş Çizimi (`BlockPainter`):
1. **Düşen Gölge (Drop Shadow):** Taşların tahta üzerinde havada asılı 3D hissi vermesini sağlayan gölge.
2. **Dikey Gövde Gradyanı (Vertical Gradient):** Mücevhere derinlik katan iki tonlu dikey geçiş.
3. **Üst-İç Hap Parlaması (Pill Highlight):** Taşın üst kısmında cam/şeker parlaklığı oluşturan beyaz saydam elips.
4. **Alt Ortam Karartması (Ambient Occlusion):** Taşın alt sınırına oturan yumuşak koyulaştırma.

### 3.2. Mücevher Renk Yelpazesi:
* 🔴 **Yakut Kırmızısı (Ruby Red)**
* 🔵 **Safir Mavisi (Sapphire Blue)**
* 🟢 **Zümrüt Yeşili (Emerald Green)**
* 🟡 **Kehribar / Topaz (Amber Topaz)**
* 🟣 **Kraliyet Ametisti (Royal Amethyst)**
* 🩵 **Elmas Camgöbeği (Diamond Cyan)**

---

## 4. Aktif Oyun Modları ve Etkinlikler

### 4.1. Ana Oyun Modları (`GameMode`):
1. 👑 **Sonsuz Mod (Classic Mode):**
   - Süre ve hamle sınırı yoktur.
   - Amaç en yüksek skoru yaparak global lider tablosunda zirveye tırmanmaktır.
2. 🗺️ **Görev & Harita Modu (Adventure Mode):**
   - Bölüm haritasında aşama aşama ilerlenir.
   - Tahtadaki özel görevler (ör. buzları kırma, belirli renkli mücevherleri toplama, hedef skora ulaşma) tamamlanarak **3 Yıldız** kazanılır.

### 4.2. Entegre Yan Etkinlikler & Menü Modülleri:
* 🏰 **Lonca Fetihleri (Guild Conquest):** Lonca üyeleriyle puan biriktirme ve fetih görevleri.
* 🗼 **Kadim Kule (Spire of Ascension):** Kat kat yükselen zorlayıcı kule meydan okumaları.
* ⚔️ **Turnuva Arenası (Tournament Arena):** Fırtına Şampiyonası ve lig bazlı yarışmalar.
* 🏮 **Sezonluk Festival (Festival Events):** Süreli görevler ve özel etkinlik biletleri.

---

## 5. Şampiyonlar ve Nihai Yetenek Sistemi (Champions)

Oyunda **4 adet tamamen kodlanmış ve benzersiz şampiyon** yer alır:

```
┌──────────────┬──────────────────┬────────────────────────────────────────────────────────┐
│ Şampiyon     │ Pasif Yetenek    │ Nihai Yetenek (Ultimate)                               │
├──────────────┼──────────────────┼────────────────────────────────────────────────────────┤
│ 🔥 Ignis     │ Alev Rezonansı   │ 🌋 Meteor Yağmuru                                      │
│ (Ateş)       │ Çoklu hatta +%25 │ Tahtadaki en kalabalık 3x3 alanı anında küle çevirir.   │
│              │ bonus puan.      │                                                        │
├──────────────┼──────────────────┼────────────────────────────────────────────────────────┤
│ ❄️ Glacia    │ Donmuş Zaman     │ ❄️ Mutlak Sıfır                                        │
│ (Buz)        │ Kombo süresi     │ Kombo süresini dondurur, sonraki 3 hamleyi 2X yapar.   │
│              │ %30 yavaş biter. │                                                        │
├──────────────┼──────────────────┼────────────────────────────────────────────────────────┤
│ ⚡ Voltur    │ Yüksek Voltaj    │ ⚡ Aşırı Yük Yıldırımı                                 │
│ (Yıldırım)   │ Ultimate %20     │ Tahtadaki yatay ve dikey çapraz hatları temizler.      │
│              │ daha hızlı dolar.│                                                        │
├──────────────┼──────────────────┼────────────────────────────────────────────────────────┤
│ 🔮 Umbra     │ Karanlık Çekim   │ 🔮 Boyut Tekilliği                                     │
│ (Hiçlik)     │ Kazanılan altın  │ Tahtadaki 6 izole tekli hücreyi kara delikle yok eder. │
│              │ +%25 artar.      │                                                        │
└──────────────┴──────────────────┴────────────────────────────────────────────────────────┘
```

* **Şampiyon Edinme:** Ignis başlangıçta açıktır. Glacia (500 Altın), Voltur (800 Altın) ve Umbra (1.200 Altın) oyun içinde toplanan altınlarla açılır.

---

## 6. Kadim Parşömenler ve Kehanet Rünleri (Meta-Progression)

* **Kadim Parşömen Kuşanma (`Scrolls`):** Oyuncu oyun başlamadan önce envanterindeki parşömenleri kuşanır; oyun başladığında otomatik olarak ekstra can, puan bonusu veya başlangıç avantajı sağlar.
* **Kehanet Rünleri (`Oracle / Rune Cards`):** Rün kartları açılarak şampiyonların enerji dolum hızları ve kombo süreleri kalıcı olarak güçlendirilir.
* **Şampiyon Seferleri (`Expeditions`):** Şampiyonlar boş zamanlarında çevrimdışı seferlere gönderilerek altın ve rün tozu kazanır.

---

## 7. Ekonomi ve Mağaza Mimarisi (Real IAP & Altın)

### 7.1. Gerçek Satın Alımlar Kataloğu (`IapService`):
Resmi `in_app_purchase` motoru üzerinden Google Play Faturalandırmasına bağlıdır:

| Ürün Kodu (Product ID) | Paket Adı | Tür | Açıklama & Avantaj |
| :--- | :--- | :--- | :--- |
| `shards_tier1_500` | 💰 **Çırak Kesesi** | Tüketilebilir (Consumable) | 500 Altın hesaba eklenir. |
| `shards_tier2_1500` | 💎 **Maceracı Sandığı** | Tüketilebilir (Consumable) | 1.500 Altın hesaba eklenir. |
| `shards_tier3_5000` | 👑 **Kadim Hazine** | Tüketilebilir (Consumable) | 5.000 Altın hesaba eklenir. |
| `no_ads_lifetime` | 🛡️ **Reklamsız Hayat VIP** | Kalıcı (Non-Consumable) | **Tüm geçiş reklamlarını ömür boyu engeller.** |
| `battle_pass_premium` | 📜 **Premium Savaş Bileti** | Sezonluk (Non-Consumable) | Savaş Biletinin Premium ödül hattını açar. |

### 7.2. Tüketici Koruması ve Otomasyon:
* **Satın Alımları Geri Yükle (Restore Purchases):** Mağazada ve Ayarlar menüsünde yer alan tek tıkla geri yükleme butonu sayesinde telefon değiştiğinde VIP ve bilet hakları geri gelir.
* **Otomatik Reklam Engelleme:** `IapService.instance.hasNoAds` aktif olduğunda `AdService` geçiş reklamlarını otomatik olarak atlar.

---

## 8. Ses, Haptik ve Yaşam Döngüsü Güvenliği

* **Prosedürel Polifonik Sesler:** Taş koyma, hat silme ve nihai yetenek sesleri birbirini ezmeden çalınır.
* **Yaşam Döngüsü Koruması (`WidgetsBindingObserver`):** Telefon kilitlendiğinde veya uygulama arka plana alındığında sesler ve animasyonlar pil tasarrufu için duraklatılır.
* **Anlık Dil Değişimi (`LocaleManager`):** Ayarlardan Türkçe veya İngilizce seçildiğinde arayüz anında güncellenir.

---

## 9. Teknik Özellikler ve Google Play Uyumluluğu

* **Paket Kimliği (Application ID):** `com.runegrid.block_survivor`
* **SDK Seviyesi:** Android 14 / 15 (Target SDK 34/35) & 64-bit ARM desteği.
* **Kod Kalitesi:** `flutter analyze` 0 Hata, 0 Uyarı (Temiz kod mimarisi).
* **Gizlilik Politikası:** Ayarlar menüsünde yer alan KVKK & GDPR uyumlu metin.

---

*Bu belge, Block Survivor projesinin mevcut kod tabanıyla %100 örtüşen resmi sistem ve oyun kılavuzudur.*
