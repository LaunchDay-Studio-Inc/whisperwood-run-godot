# Asset Pipeline — Whisperwood Run

## Directory Structure

```
godot/assets/
├── art/
│   ├── characters/       # Player sprites, NPC sprites
│   ├── obstacles/        # Rock, log, thorn, etc.
│   ├── collectibles/     # Seeds, powerups
│   ├── backgrounds/      # Parallax layers per biome
│   │   ├── enchanted_forest/
│   │   ├── crystal_caverns/
│   │   └── starlit_meadow/
│   ├── grove/            # Top-down building sprites
│   ├── ui/               # Panels, buttons, icons
│   ├── effects/          # Particle textures
│   └── icon.png          # App icon (512x512)
├── audio/
│   ├── sfx/              # Short sound effects (.wav or .ogg)
│   └── music/            # Background music loops (.ogg)
└── fonts/
    └── *.ttf             # UI fonts
```

## Import Workflow

### Step 1: Generate or Source Assets
1. Use prompts from `docs/Phase_4/art_bible.md` to generate art via image generation tools
2. Download CC0 SFX from Freesound.org or generate via sfxr.me
3. Source CC0/royalty-free music or commission original

### Step 2: Process Raw Assets
1. **Trim** transparent borders (ImageMagick):
   ```bash
   convert input.png -trim +repage -bordercolor transparent -border 2 output.png
   ```
2. **Resize** to target resolution:
   ```bash
   convert input.png -resize 128x128 output.png
   ```
3. **Pack sprite sheets** (optional — Godot handles AtlasTexture natively):
   ```bash
   montage frame_*.png -tile 8x1 -geometry +0+0 -background transparent spritesheet.png
   ```

### Step 3: Import into Godot
1. Place files in the appropriate `godot/assets/` subdirectory
2. Open the Godot editor — it auto-imports
3. Select each asset in the FileSystem dock and configure import settings:

| Asset Type | Preset | Filter | Mipmaps | Compress |
|------------|--------|--------|---------|----------|
| Sprites | 2D Pixel | Nearest | Off | Lossless |
| Backgrounds | 2D | Linear | Off | Lossy (WebP) |
| UI panels | 2D | Linear | Off | Lossless |
| SFX (.wav) | — | — | — | Vorbis → .ogg |
| Music (.ogg) | — | — | — | Already OGG |

4. Click **Reimport** after changing settings

### Step 4: Wire into Scenes
1. Character sprites → `player_runner.gd` (replace vector placeholder with `Sprite2D`)
2. Obstacle sprites → `obstacle_spawner.gd` factory methods
3. Backgrounds → `parallax_bg.gd` (replace procedural rects with TextureRect)
4. UI → `whisperwood_theme.tres` (add StyleBoxTexture resources)
5. Grove buildings → `grove_scene.gd` building definitions

## Naming Conventions

```
<category>_<name>_<variant>_<frame>.png

Examples:
  char_player_run_01.png
  char_player_run_02.png
  obs_rock_mossy_01.png
  bg_forest_far_01.png
  ui_panel_dark.png
  ui_btn_normal.png
  ui_btn_hover.png
  grove_seedhouse_lv1.png
  fx_sparkle_01.png
  collect_seed_01.png
  collect_shield.png
```

## Automation Scripts

### Batch Resize (tools/asset_pipeline/resize_assets.sh)
```bash
#!/bin/bash
# Resize all PNGs in a folder to target size
# Usage: ./resize_assets.sh input_dir output_dir 128x128

INPUT_DIR="$1"
OUTPUT_DIR="$2"
SIZE="$3"

mkdir -p "$OUTPUT_DIR"
for f in "$INPUT_DIR"/*.png; do
    filename=$(basename "$f")
    convert "$f" -resize "$SIZE" "$OUTPUT_DIR/$filename"
    echo "Resized: $filename → $SIZE"
done
```

### Generate Placeholder Assets (tools/asset_pipeline/gen_placeholders.sh)
```bash
#!/bin/bash
# Generate colored rectangle placeholder PNGs
# Requires ImageMagick

ASSET_DIR="../../godot/assets/art"

# Player placeholder (green rounded rect)
convert -size 64x64 xc:transparent \
    -fill '#4DD982' -draw 'roundrectangle 4,4 60,60 8,8' \
    "$ASSET_DIR/characters/char_player_idle_01.png"

# Seed placeholder (golden diamond)
convert -size 32x32 xc:transparent \
    -fill '#FFD933' -draw 'polygon 16,2 30,16 16,30 2,16' \
    "$ASSET_DIR/collectibles/collect_seed_01.png"

# Obstacle placeholder (brown rock)
convert -size 64x64 xc:transparent \
    -fill '#6B4423' -draw 'ellipse 32,36 28,24 0,360' \
    "$ASSET_DIR/obstacles/obs_rock_01.png"

echo "Placeholders generated."
```

## Quality Checklist

- [ ] All sprites have consistent canvas sizes per category
- [ ] No sprites exceed 512x512 (except BG layers)
- [ ] All PNGs have transparency (no white background)
- [ ] Sprite sheets use consistent frame sizes
- [ ] Audio files are .ogg for music, .wav or .ogg for SFX
- [ ] SFX files are normalized to -3dB peak
- [ ] Music loops seamlessly (check crossfade point)
- [ ] Total asset size < 50MB uncompressed
- [ ] All assets are original or CC0/public domain
- [ ] Attribution file updated if using CC-BY assets
