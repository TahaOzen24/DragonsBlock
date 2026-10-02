# 🎮 Block Survivor Project Rules & Context Memory

## 🐉 FUTURE VISION: DRAGON AWAKENING (Planlanan Yeni Mimari)
> "Block puzzle oynarken kendi efsanevi ejderhanı büyüt."
- **Şampiyon Koleksiyonu Kaldırılacak:** Oyuncu oyun başında tek bir ana Ejderha Yumurtası seçecek (Ateş, Buz, Fırtına, Toprak) ve bu ejderhayla duygusal bağ kurup onu büyütecek.
- **Evrim Basamakları:** Yavru (Seviye 1) -> Genç (Seviye 10) -> Savaş (Seviye 25) -> Kadim (Seviye 50) -> Efsanevi (Seviye 100).
- **Canlı Ejderha Etkileşimi:**
  - Ana Menüde nefes alan, kanat çırpan, uyuyan canlı ejderha.
  - Oyun içi HUD'da kombolara sevinen, hatalarda homurdanan, Ultimate kullanıldığında nefes/saldırı animasyonu oynatan ejderha.
- **Ejderha Güçleri:**
  - 🔥 Ateş: *Alev Nefesi* (Alanı yakıp temizler).
  - ❄️ Buz: *Donmuş Koruma* (Şekli sonraki turlar için saklama).
  - ⚡ Fırtına: *Yıldırım Zinciri* (Satır/sütunu anında tamamlama).
  - 🌍 Toprak: *Taş Kalkan* (Koruyucu bloklar).
- **Sefer Sistemi (Expeditions):** 15 dk (Kısa), 2 saat (Orta), 8 saat (Uzun), 24 saat (Kadim).
- **Kozmetikler (P2W Değil):** Obsidyen, Kristal, Gökkuşağı, Altın, Kemik kaplamaları.

---

## ⚡ Aktif Tasarım & Kodlama Kuralları:
1. **Block Blast-Grade Juicy Candy-Gem Aesthetic:**
   - No faux-3D polygons or raster PNG gemstone overlays.
   - Use GPU-accelerated vector drawing with drop shadows, vertical body gradient, top-inner pill highlight, and inner bottom ambient occlusion.
   - Preserves authentic multi-jewel spectrum colors (Ruby Red, Sapphire Blue, Emerald Green, Amber Topaz, Royal Amethyst, Diamond Cyan).

2. **Clean & Minimalist Zen UI (Zero Notification Clutter):**
   - No intrusive full-screen stinger banners during regular moves (eras, elixirs, 3-line clears, streaks).
   - Only clean, tasteful flying score numbers (+100, +300, etc.) and gentle audio feedback.
   - Zero per-frame atmospheric particle spam on the game board.

3. **No 1x1 Blocks Allowed:**
   - Single dot shapes (`singleDot1x1`) must NEVER spawn. Minimum shape size is domino 1x2 or larger.

4. **Lifecycle & Audio Safety:**
   - `BlockSurvivorApp` uses `WidgetsBindingObserver` to pause procedural audio when app goes to background or screen locks.

5. **Animation Controllers:**
   - `_GameScreenState` uses `TickerProviderStateMixin` to support multiple simultaneous animation controllers safely.
