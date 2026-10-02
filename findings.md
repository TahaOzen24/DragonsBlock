# DragonsBlock — Findings (2026-09-29)

## Meta polish (2026-09-29)
- Shop: daily ad + wizard grace claim lock; VIP sync from IAP; BP hidden; flash deal 24h prefs.
- Dragon: egg unlock wired; max-level feed lock.
- Leaderboard: local practice copy; weekly chest claim; real week countdown.
- Collection: mixer “use theme” reset; dock i18n labels + smarter badges.

## Domain
| Domain | Status |
|--------|--------|
| game, shop, adventure, block_themes, rewards, quests, daily_challenge, profile, jukebox | Complete / usable |
| dragon | Partial — power UI removed; static art |
| achievements | Partial — not in Managers registry |
| leaderboard | Simulated roster |
| tutorial | Mentions missing domains |
| puzzle | Stub — manager only, no UI |

## Critical gaps
1. Release keystore missing
2. IAP offline/fallback grants products free (`iap_service.dart`)
3. `battle_pass_premium` no real deliver/UI
4. Analytics console-only; no Firebase
5. Privacy policy URL / Play listing assets missing
6. Dragon Awakening blueprint vs code mismatch (powers, expeditions, live dragon)
7. Dead LiveOps strings: guild, tournament, alchemy, BP

## Validation
- Commands: `flutter test`, `flutter analyze` — 2026-09-29 session.
