# Phase 1 — Core Runner Prototype

## Design Notes

### Goal
Deliver a playable 3-lane endless runner loop with procedural spawning, collision, scoring, seed collection, basic menus, and persistent save.

### Architecture

#### Scene Graph
```
RunnerScene (Node2D)
├── Background (Node2D) — parallax_bg.gd
├── Camera2D
├── Player (Node2D) — player_runner.gd
│   ├── Polygon2D (placeholder sprite)
│   ├── Area2D (collision)
│   └── SwipeDetector (swipe_detector.gd)
├── ObstacleSpawner (Node2D) — obstacle_spawner.gd
└── HUD (CanvasLayer) — runner_hud.gd
```

#### Autoloads
| Singleton | Purpose |
|-----------|---------|
| GameManager | Game state, session data, economy |
| SaveManager | Encrypted local save with checksum |
| AudioManager | SFX pool + music player |
| EventBus | Global signal hub |
| AdManager | Ad abstraction (stub in Phase 1) |
| AnalyticsManager | Event logging |
| TransitionManager | Scene fade transitions |

#### Player State Machine
```
RUNNING ──→ JUMPING ──→ RUNNING
RUNNING ──→ SLIDING ──→ RUNNING
RUNNING ──→ CRASHING ──→ DEAD
Any ──(shield)──→ INVULNERABLE ──→ RUNNING
DEAD ──(revive)──→ INVULNERABLE
```

#### Difficulty Curve
| Distance (m) | Speed | Spawn Interval | Moving Obstacles | Double Obstacles |
|---------------|-------|---------------|------------------|-----------------|
| 0 | 400 | 0.80s | 0% | 0% |
| 200 | 460 | 0.70s | 10% | 10% |
| 500 | 520 | 0.60s | 20% | 20% |
| 1000 | 580 | 0.50s | 30% | 30% |
| 2000 | 640 | 0.45s | 35% | 35% |
| 3500 | 700 | 0.40s | 40% | 40% |
| 5000 | 740 | 0.38s | 45% | 45% |

### Input
- **Mobile**: Swipe left/right for lane change, swipe up = jump, swipe down = slide
- **Keyboard**: A/D or Left/Right = lanes, W/Up/Space = jump, S/Down = slide
- **Pause**: Escape key

### Collectibles
- **Seeds** (golden diamonds) — currency, +10 score each
- **Shield** (blue star) — absorbs one hit
- **Magnet** (pink star) — attracts seeds for 5s
- **Multiplier** (purple star) — 2x score for 8s

### Save Format
XOR-obfuscated JSON with MD5 checksum. Stored at `user://whisperwood_save.dat`.

---

## Acceptance Criteria

- [ ] 3-lane runner with smooth lane switching
- [ ] Swipe input works on touch devices
- [ ] Keyboard input works on desktop/web
- [ ] Obstacles spawn procedurally
- [ ] Difficulty increases with distance
- [ ] At least 1 lane always open (no impossible sections)
- [ ] Seeds and powerups spawn
- [ ] Score increases over time + from seeds
- [ ] Collision with obstacles triggers crash
- [ ] Shield absorbs crash
- [ ] Main menu with Play, Grove (stub), Settings
- [ ] Pause menu during run
- [ ] Game over screen with score, distance, seeds
- [ ] High score persists across sessions
- [ ] Total seeds persist across sessions
- [ ] Can play 10 consecutive runs without crash/error
- [ ] Difficulty increase is smooth and fair

---

## Test Checklist

### Functional Tests
- [ ] Launch game → main menu appears
- [ ] Press "Begin Run" → runner starts
- [ ] Swipe/keyboard left → player moves to left lane
- [ ] Swipe/keyboard right → player moves to right lane
- [ ] Swipe/keyboard up → player jumps
- [ ] Swipe/keyboard down → player slides
- [ ] Player collides with obstacle → crash animation + game over
- [ ] Player with shield hits obstacle → shield consumed, player survives
- [ ] Seeds collected → seed count increases
- [ ] Score increases over time
- [ ] Powerups collected → effect activates
- [ ] Magnet → nearby seeds attracted to player
- [ ] Multiplier → score accumulates faster
- [ ] Portals spawn periodically → entering one adds shortcut bonus
- [ ] Pause → game freezes, pause menu shown
- [ ] Resume → game continues
- [ ] Game over → final stats shown
- [ ] "Run Again" → new run starts
- [ ] "Main Menu" → returns to title
- [ ] High score saved and displayed
- [ ] Seeds accumulated across runs

### Performance Tests
- [ ] 10 consecutive runs with no crash
- [ ] No visible stutter at difficulty transitions
- [ ] Obstacle pool doesn't grow unbounded (objects cleaned up past screen)

### Save Tests
- [ ] Close and reopen → data persists
- [ ] Tamper with save file → warning logged but game still loads
- [ ] Delete save file → starts fresh

---

## Known Issues (Phase 1)

1. **Placeholder art only** — All visuals are vector shapes. Will be replaced in Phase 4.
2. **No sound effects in-game** — Procedural blips generated but no music.
3. **Grove button leads to stub** — Grove scene not yet implemented (Phase 2).
4. **No revive ads** — Ad system is stubbed. Revive prompt appears but doesn't connect to real ads yet.
5. **Web build not tested** — Export pipeline not set up until Phase 3.
6. **Settings don't persist** — Volume settings reset on restart (save integration pending).

---

## Suggested Git Commits

```
feat: add project.godot with Godot 4.x configuration
feat: add autoload singletons (GameManager, SaveManager, EventBus, AudioManager)
feat: add TransitionManager and AnalyticsManager autoloads
feat: implement PlayerRunner with FSM and 3-lane movement
feat: add SwipeDetector for mobile touch input
feat: implement ObstacleSpawner with procedural difficulty curve
feat: create parallax background system
feat: build RunnerHUD with score, pause, game over panels
feat: create MainMenu scene with entrance animations
feat: add encrypted save system with checksum validation
feat: stub AdManager for future monetization
docs: add Phase 1 design notes and acceptance criteria
```
