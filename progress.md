# Progress — 2026-09-29

## Session: P0 store blockers
- Keystore generated locally (gitignored); gradle refuses unsigned release.
- IAP free fallback removed; shop shows error / payment-opening toasts.
- Privacy policy docs + PLAY_RELEASE checklist + LegalUrls.
- `flutter analyze` (touched paths): clean · related tests: 26 passed.
- signingReport: release → `android/upload-keystore.jks`.

## Still needs user / manual
1. Backup `.jks` + passwords offline
2. Host `docs/privacy-policy.html` → set `PRIVACY_POLICY_URL`
3. Play listing assets + Data safety
4. Then: Dragon power UI, puzzle prune, Firebase
