# Phase 3 — Monetization + Platform Shipping

## Design Notes

### Goal
Integrate AdMob rewarded/interstitial ads on Android, implement Remove Ads IAP, set up export pipelines for Android (AAB) and Web (HTML5), and ensure graceful fallbacks when ads are unavailable.

### Monetization Architecture

```
AdManager (Autoload)
├── AdMob Plugin (Android only)
│   ├── Rewarded Ad → revive, double reward, daily bonus
│   ├── Interstitial Ad → after run ends (frequency capped)
│   └── Fallback: signals ad_failed, UI hides ad buttons
└── Web Fallback
    ├── Free revive 1/day
    ├── Gem-spend alternatives
    └── No ad buttons shown

IAPManager (Autoload)
├── Google Play Billing Plugin (Android only)
│   ├── "Remove Ads" product
│   └── Acknowledge + grant on purchase
└── Web: IAP disabled
```

### Ad Placements
| Placement | Type | Trigger | Frequency Cap |
|-----------|------|---------|---------------|
| Revive | Rewarded | After crash (before game over) | 1 per run |
| Double Reward | Rewarded | Game over screen | 1 per run |
| Daily Bonus | Rewarded | Daily reward reroll | 1 per day |
| Post-Run | Interstitial | After game over | Max 1 per 3 runs |

### Ad Safety Rules
1. **Never block gameplay** if ad fails to load
2. Rewarded ads are always **optional** — player can decline
3. Interstitial only appears if:
   - `ads_removed == false`
   - `runs_since_interstitial >= 3`
   - Not on web
4. If AdMob plugin is missing, all ad features silently degrade
5. Remove Ads purchase:
   - Disables interstitials permanently
   - Rewarded ads remain available but optional
   - Persisted in save file

### Web Monetization
- No AdMob SDK in web build
- "Watch Ad" buttons are hidden
- Revive: 1 free per day, then costs 5 gems
- Double reward: costs 3 gems
- Revenue via itch.io page (tip jar / pay-what-you-want)

### Export Configuration

#### Android AAB
- Min SDK: 21 (Android 5.0)
- Target SDK: 34
- Architectures: ARMv7 + ARM64
- Gradle build: enabled
- Package: `com.launchdaystudio.whisperwoodrun`
- Signed AAB format for Play Store

#### Web HTML5
- GL Compatibility renderer
- Canvas resize policy: adaptive
- PWA enabled with offline support
- Touch input emulation enabled

---

## Acceptance Criteria

- [ ] AdMob rewarded ad loads on Android (or gracefully fails)
- [ ] Rewarded ad on revive: player continues if watched
- [ ] Rewarded ad on double reward: seeds doubled if watched
- [ ] Interstitial shows only after 3+ runs (not before)
- [ ] Interstitial never blocks if load fails
- [ ] "Remove Ads" IAP flows through Google Play Billing
- [ ] After purchase: interstitials stop, rewarded remains optional
- [ ] Remove Ads persists across sessions
- [ ] Web build: no ad buttons visible
- [ ] Web revive: free once/day, then gem cost shown
- [ ] Android export produces valid AAB
- [ ] Web export produces playable HTML5
- [ ] Privacy policy covers all data practices
- [ ] Data safety declaration matches actual behavior

---

## Test Checklist

### Android Ad Tests
- [ ] Fresh install → rewarded ad loads within 30s
- [ ] Crash → revive prompt shows "Watch Ad" → ad plays → revive works
- [ ] Crash → decline revive → game over → no ad interruption
- [ ] Game over → "Double Rewards" → ad plays → seeds doubled
- [ ] Play 3 runs → interstitial appears after 3rd
- [ ] Play 2 runs → no interstitial
- [ ] Disable internet → rewarded fails → revive button says "Unavailable"
- [ ] Disable internet → interstitial skipped silently

### IAP Tests
- [ ] Tap "Remove Ads" → Google Play purchase flow
- [ ] Complete purchase → interstitials stop
- [ ] Restart app → ads still removed
- [ ] Rewarded ads still work after Remove Ads

### Web Tests
- [ ] No "Watch Ad" button visible anywhere
- [ ] Revive uses free daily → works once
- [ ] Second revive → shows gem cost
- [ ] No errors in browser console related to AdMob
- [ ] Offline mode → game plays normally

### Export Tests
- [ ] `godot --headless --export-release "Android"` produces AAB
- [ ] `godot --headless --export-release "Web"` produces HTML5 files
- [ ] AAB passes `bundletool validate`
- [ ] Web build serves from local HTTP server
- [ ] Web build loads and runs in Chrome/Firefox

---

## Known Issues (Phase 3)

1. **AdMob plugin not bundled** — Requires manual AdMob Godot plugin installation. Project runs without it (ads silently disabled).
2. **IAP not testable without Play Console** — Google Play Billing requires a signed APK on a test device. Use license testing accounts.
3. **No ad mediation** — Single AdMob network only. Could add mediation later.
4. **Interstitial frequency is session-based** — Resets on app restart. Could be daily-based instead.

---

## Suggested Git Commits

```
feat: implement AdManager with AdMob rewarded + interstitial
feat: add web fallback for ad moments (free revive, gem costs)
feat: add IAPManager with Remove Ads product
feat: create export_presets.cfg for Android AAB and Web HTML5
feat: add interstitial frequency cap (max 1 per 3 runs)
feat: connect revive flow to AdManager rewarded ads
feat: connect double reward to AdManager
docs: add privacy policy and data safety declaration
docs: add Phase 3 design notes and test checklist
```
