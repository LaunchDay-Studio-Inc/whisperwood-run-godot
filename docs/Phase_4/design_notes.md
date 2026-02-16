# Phase 4 — Polish + Content + Launch Pack

## Design Notes

### Goal
Bring the game to shipping quality with visual polish, particle effects, 2 additional biomes, onboarding tutorial, build packaging, and a complete marketing kit.

### Visual Polish Additions
1. **Particle effects** — collect burst, crash shockwave, shield break, floating text, trail particles
2. **Light overlays** — warm pulsing light tint per biome
3. **Screen juice** — flash on crash, tween-based micro-animations on all UI
4. **Parallax depth** — 5-layer parallax backgrounds with biome-specific coloring
5. **Floating particles** — firefly-like ambient particles on main menu and grove
6. **Button hover effects** — color transitions, gentle scale pulse

### Three Biomes

| Biome | Unlock | Color Theme | Unique Obstacles |
|-------|--------|-------------|-----------------|
| Enchanted Forest | Default | Greens, warm amber | Mossy rocks, fallen logs, thorn bushes |
| Crystal Caverns | Lantern Lv1 | Deep purples, icy blues | Crystal spikes, stalagmites, cave mushrooms |
| Starlit Meadow | Lantern Lv2 | Deep night, gold/green | Gnarled roots, fairy rings, sleeping stones |

### Tutorial System
- 5-step overlay shown on first run only
- ~30 seconds to complete
- Each step: instruction text + animated arrow
- Tap to advance through steps
- Persisted via save ("tutorial_completed")
- Steps: lanes → jump → slide → seeds → powerups

### Effects Manager
Static utility methods for spawning visual effects:
- `spawn_collect_burst()` — particle burst on seed/powerup collect
- `spawn_crash_effect()` — shockwave ring + screen flash on crash
- `spawn_shield_break()` — shard explosion when shield consumed
- `spawn_floating_text()` — "+10", "SHIELD!", etc.
- `spawn_trail_particle()` — cosmetic trail behind player
- `create_light_overlay()` — warm atmosphere tint
- `create_vignette()` — edge darkening

---

## Acceptance Criteria

- [ ] All 3 biomes playable with distinct visuals
- [ ] Crystal Caverns unlocks at Lantern Lv1
- [ ] Starlit Meadow unlocks at Lantern Lv2
- [ ] Particle effects fire on: collect, crash, shield break
- [ ] Floating text appears for score popups
- [ ] Light overlay pulses subtly during runs
- [ ] Tutorial plays on first-ever run
- [ ] Tutorial skippable by tapping through
- [ ] Tutorial doesn't replay after completion
- [ ] Cold start to first run in <15 seconds
- [ ] No major memory spikes during 5-minute play session
- [ ] Stable FPS (target 60, minimum 30 on low-end)
- [ ] All UI works on 16:9, 18:9, 20:9, and wider aspect ratios
- [ ] Android AAB exports successfully
- [ ] Web HTML5 exports and runs in browser
- [ ] Marketing kit complete (description, screenshots, trailer storyboard)

---

## Test Checklist

### Biome Tests
- [ ] Default biome = Enchanted Forest (green/amber palette)
- [ ] Purchase Lantern Lv1 → Crystal Caverns appears in biome rotation
- [ ] Crystal Caverns run → purple/blue palette, different obstacle colors
- [ ] Purchase Lantern Lv2 → Starlit Meadow available
- [ ] Starlit Meadow → dark night palette with gold seeds

### Effects Tests
- [ ] Collect seed → golden burst particles
- [ ] Collect powerup → colored burst
- [ ] Crash without shield → red shockwave + screen flash
- [ ] Crash with shield → blue shard explosion, no death
- [ ] Score popup text floats up and fades
- [ ] Trail particles appear behind player during run

### Tutorial Tests
- [ ] First launch → tutorial overlay appears
- [ ] Step 1: "Swipe LEFT or RIGHT" with horizontal arrow
- [ ] Step 2: "Swipe UP to JUMP" with up arrow
- [ ] Step 3: "Swipe DOWN to SLIDE" with down arrow
- [ ] Step 4: "Collect golden seeds" (no arrow)
- [ ] Step 5: "Watch for power-ups" (no arrow)
- [ ] Tap through all steps → tutorial completes
- [ ] Restart app → tutorial doesn't replay
- [ ] Second run → no tutorial

### Performance Tests
- [ ] Cold start: main menu appears in <5s (desktop), <15s (low-end Android)
- [ ] 5-minute continuous run → no memory spikes >50MB
- [ ] FPS counter stays ≥30 on low-end, ≥55 on mid-tier
- [ ] Object pool: active objects never exceed ~40 on screen

### Aspect Ratio Tests
- [ ] 16:9 (standard phone) — no clipping
- [ ] 18:9 (modern phone) — content scales properly
- [ ] 20:9 (tall phone) — HUD elements visible
- [ ] 4:3 (web browser wide) — playable, no stretching

---

## Known Issues (Phase 4)

1. **Placeholder art** — All visuals remain procedural vector shapes. The Art Bible provides specs for replacement.
2. **No real music** — Music system ready but needs CC0 tracks.
3. **Web PWA not fully tested** — Service worker and offline mode need verification.
4. **Single player skin** — Skin system architecture exists but only "default" skin implemented.
5. **No leaderboard** — Offline-first design means no online leaderboards.

---

## Suggested Git Commits

```
feat: add EffectsManager with particle burst, crash, shield effects
feat: implement BiomeConfig for 3 biomes (forest, caverns, meadow)
feat: add TutorialOverlay with 5-step onboarding
feat: integrate effects into runner (collect, crash, powerup)
feat: add warm light overlay and vignette effects
polish: add micro-animations to all UI buttons
polish: improve parallax background with biome colors
feat: add player trail particles during run
docs: create marketing kit (store description, screenshots, trailer)
docs: add Phase 4 design notes and launch checklist
chore: finalize export presets for AAB and Web
```
