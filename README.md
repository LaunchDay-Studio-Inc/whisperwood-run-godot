# Whisperwood Run

**An enchanting endless runner with grove-building meta-game — built in Godot 4.x**

Race through magical biomes, collect golden seeds, build your grove sanctuary, and push deeper into the Whisperwood.

---

## Game Overview

| Feature | Details |
|---------|---------|
| **Genre** | Endless Runner + Base Builder |
| **Engine** | Godot 4.x (GL Compatibility) |
| **Platforms** | Android (AAB) · Web (HTML5/WebAssembly) |
| **Orientation** | Portrait (720×1280) |
| **Monetization** | AdMob Rewarded + IAP "Remove Ads" (Android) |
| **Offline** | Fully playable offline — no server required |
| **Save** | Local encrypted save with checksum |

### Core Loop
1. **Run** through procedurally-generated lanes, dodging obstacles
2. **Collect** seeds and powerups
3. **Choose** portals (safe / risky / mystery) every 500m
4. Crash → spend seeds in the **Grove** to build & upgrade
5. Upgrades give run bonuses → run farther → repeat

### Biomes
- **Enchanted Forest** — Unlocked from start
- **Crystal Caverns** — Unlocked at Lantern Lv2
- **Starlit Meadow** — Unlocked at Lantern Lv3

---

## Project Structure

```
godot/
├── project.godot              # Engine config, autoloads, inputs
├── export_presets.cfg         # Android + Web export presets
├── scripts/
│   ├── autoload/              # Global singletons
│   │   ├── event_bus.gd       # Signal hub
│   │   ├── game_manager.gd    # State, economy, session
│   │   ├── save_manager.gd    # Encrypted local saves
│   │   ├── audio_manager.gd   # SFX pool + music
│   │   ├── ad_manager.gd      # AdMob + web fallback
│   │   ├── analytics_manager.gd
│   │   ├── transition_manager.gd
│   │   └── iap_manager.gd     # Google Play Billing
│   ├── runner/                # Core gameplay
│   │   ├── player_runner.gd   # Player FSM (6 states)
│   │   ├── swipe_detector.gd  # Touch input
│   │   ├── obstacle_spawner.gd# Procedural generation
│   │   ├── parallax_bg.gd     # 5-layer scrolling BG
│   │   ├── runner_scene.gd    # Scene controller
│   │   ├── runner_hud.gd      # In-game UI
│   │   ├── effects_manager.gd # Particles & juice
│   │   └── biome_config.gd    # Biome palette data
│   ├── grove/                 # Meta-game
│   │   ├── grove_scene.gd     # Grid placement, buildings
│   │   └── quest_manager.gd   # Daily + persistent quests
│   ├── ui/
│   │   └── main_menu.gd       # Title screen
│   └── tutorial/
│       └── tutorial_overlay.gd # First-run onboarding
├── scenes/
│   ├── main_menu.tscn
│   ├── runner/runner.tscn
│   └── grove/grove.tscn
├── data/
│   └── economy_balance.json   # Design reference data
├── ui/theme/
│   └── whisperwood_theme.tres
└── assets/
    ├── art/                   # Sprites, backgrounds
    ├── audio/                 # SFX + music
    └── fonts/                 # TTF fonts
```

---

## Prerequisites

| Tool | Version | Purpose |
|------|---------|---------|
| [Godot Engine](https://godotengine.org/download) | 4.2+ | Editor & export |
| [Android SDK](https://developer.android.com/studio) | API 34 | Android builds |
| [OpenJDK](https://adoptium.net) | 17 | Android Gradle |
| A web browser | Modern | HTML5 testing |

### Godot Export Templates
Download via **Editor → Manage Export Templates → Download for Current Version**

---

## Setup

### 1. Clone & Open
```bash
git clone <repo-url> whisperwood-run
cd whisperwood-run
```
Open Godot → **Import** → select `godot/project.godot` → **Import & Edit**

### 2. Verify Autoloads
**Project → Project Settings → Autoload** should show:
| Name | Path |
|------|------|
| EventBus | res://scripts/autoload/event_bus.gd |
| GameManager | res://scripts/autoload/game_manager.gd |
| SaveManager | res://scripts/autoload/save_manager.gd |
| AudioManager | res://scripts/autoload/audio_manager.gd |
| AdManager | res://scripts/autoload/ad_manager.gd |
| AnalyticsManager | res://scripts/autoload/analytics_manager.gd |
| TransitionManager | res://scripts/autoload/transition_manager.gd |
| IAPManager | res://scripts/autoload/iap_manager.gd |

### 3. Test in Editor
Press **F5** or click ▶ — the main menu should appear.  
Click **Play** to enter the runner.

---

## Building for Android (AAB)

### One-Time Setup

1. **Android SDK**: Install via Android Studio or command line
   ```bash
   sdkmanager "platforms;android-34" "build-tools;34.0.0" "ndk;25.2.9519653"
   ```

2. **Configure Godot**: **Editor → Editor Settings → Export → Android**
   - Android SDK Path: `/path/to/android/sdk`
   - Java SDK Path: `/path/to/jdk-17`

3. **Create Keystore** (for signed release):
   ```bash
   keytool -genkeypair -v \
     -keystore whisperwood.keystore \
     -keyalg RSA -keysize 2048 -validity 10000 \
     -alias whisperwood \
     -storepass <password> -keypass <password>
   ```

4. **AdMob Plugin** (optional):
   - Download [Godot AdMob Plugin](https://github.com/poing-studios/godot-admob-plugin)
   - Extract to `godot/addons/`
   - Enable in **Project → Project Settings → Plugins**
   - Replace test ad unit IDs in `ad_manager.gd` with production IDs

### Build

1. **Project → Export → Android**
2. Verify settings:
   - Package: `com.launchdaystudio.whisperwoodrun`
   - Min SDK: 21
   - Target SDK: 34
   - Architectures: arm64-v8a, armeabi-v7a
   - Gradle Build: ✅
   - Export Format: AAB
3. **Keystore**: Point to your `.keystore` file, enter alias/password
4. Click **Export Project** → save as `whisperwood-run.aab`

### Upload to Google Play

1. Go to [Google Play Console](https://play.google.com/console)
2. Create app → fill store listing (see `marketing/store_listing/store_description.md`)
3. Upload `.aab` to Internal Testing track first
4. Set Content Rating → complete questionnaire
5. Review → Promote to Production when ready

---

## Building for Web (HTML5)

### Build

1. **Project → Export → Web (HTML5)**
2. Verify settings:
   - Export Type: Regular
   - Progressive Web App: ✅
   - Canvas Resize Policy: Adaptive
3. Click **Export Project** → save as `index.html` in a folder
4. Godot exports multiple files: `index.html`, `index.js`, `index.wasm`, `index.pck`, etc.

### Local Testing

Web exports require a local HTTP server (CORS restrictions):
```bash
cd /path/to/export/folder
python3 -m http.server 8000
# Open http://localhost:8000 in browser
```

### Deploy to itch.io

1. **Zip** all exported files:
   ```bash
   cd /path/to/export/folder
   zip -r whisperwood-run-web.zip *
   ```
2. Go to [itch.io Dashboard](https://itch.io/dashboard) → **Create new project**
3. Kind of project: **HTML**
4. Upload `whisperwood-run-web.zip`
5. Check **"This file will be played in the browser"**
6. Set viewport: **720 × 1280**
7. Enable **SharedArrayBuffer support** if prompted
8. Fill description (see `marketing/store_listing/store_description.md`)
9. **Save & view page**

---

## Development Workflow

### Phase Progression
| Phase | Focus | Key Files |
|-------|-------|-----------|
| 1 | Core runner, input, saves | `player_runner.gd`, `obstacle_spawner.gd`, `save_manager.gd` |
| 2 | Grove, quests, economy | `grove_scene.gd`, `quest_manager.gd`, `economy_balance.json` |
| 3 | Monetization, export | `ad_manager.gd`, `iap_manager.gd`, `export_presets.cfg` |
| 4 | Polish, biomes, marketing | `effects_manager.gd`, `biome_config.gd`, `tutorial_overlay.gd` |

See `docs/Phase_*/design_notes.md` for detailed acceptance criteria and test checklists per phase.

### Adding New Obstacles
1. Add a factory method in `obstacle_spawner.gd`
2. Register in the `DIFFICULTY_TABLE` spawn weights
3. Add sprite to `assets/art/obstacles/`
4. Add biome color variant in `biome_config.gd`

### Adding New Buildings
1. Add entry to `BUILDINGS` dict in `grove_scene.gd`
2. Define cost progression and max level
3. If functional, add upgrade effects in `game_manager.gd`
4. Add sprite to `assets/art/grove/`

### Adding New Quests
1. Add quest definition in `quest_manager.gd` `_init_quests()`
2. Connect relevant EventBus signal
3. Quest automatically appears in grove quest panel

---

## Architecture Notes

### Signal Bus Pattern
All game systems communicate through `EventBus` — no direct cross-references between singletons. This ensures clean decoupling and testability.

### Save System Security
- XOR cipher with configurable key (not cryptographically secure — deters casual tampering)
- MD5 checksum validates data integrity
- Tampered saves produce a warning but still load (player-friendly)

### Ad Fallback Strategy
- **Android with AdMob plugin**: Real ads served
- **Android without plugin**: Ads silently disabled, fallback rewards given
- **Web**: No ad SDK — revive is free once/day, other rewards cost gems

### Difficulty Scaling
7 tiers based on distance run, controlling:
- Obstacle spawn interval
- Obstacle speed multiplier
- Moving obstacle probability
- Powerup spawn rate
- Seed cluster frequency

---

## Art Assets

All placeholder art is generated procedurally via code (colored shapes). To replace with production art, see:
- **Art Bible**: `docs/Phase_4/art_bible.md` — palette, style guide, image generation prompts
- **Asset Pipeline**: `tools/asset_pipeline/README.md` — import workflow, naming, automation

---

## License

- **Code**: See `LICENSE_CODE`
- **Assets**: See `LICENSE_ASSETS`
- **Third-party**: All dependencies listed in `addons/` with their own licenses

---

## Credits

Whisperwood Run — Design & Development by Launch Day Studio