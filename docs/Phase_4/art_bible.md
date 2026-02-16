# Whisperwood Run — Art Bible

## Overview
Visual identity: **Storybook Fantasy** — lush, painterly environments with warm light, clean stylized characters, and a cozy-premium feel. Think illustrated children's book meets modern mobile polish.

---

## Color Palette

### Primary Palette
| Name | Hex | Use |
|------|-----|-----|
| Deep Forest | #1E2D1F | Background foundation, shadows |
| Enchanted Green | #4DD982 | Player character, positive UI |
| Golden Seed | #FFD933 | Seeds, score, highlights |
| Moonlight Amber | #F2E6B0 | Light rays, warm accents |
| Twilight Purple | #2A1F3D | Sky, deep backgrounds |
| Crystal Blue | #4D9FCC | Shield, water, ice elements |
| Berry Rose | #CC4D6E | Danger, risky portals |
| Mystic Violet | #9966CC | Mystery, magic, premium |

### Biome Sub-Palettes
- **Enchanted Forest**: Greens (#1E2D1F → #4DD982), Ambers (#F2E6B0)
- **Crystal Caverns**: Blues (#1A1833 → #4D9FCC), Purples (#2A1F3D → #7733AA)
- **Starlit Meadow**: Deep Night (#0D0820), Gold-Green (#E6FF80), Silver (#C0C0D0)

### UI Colors
| Element | Color |
|---------|-------|
| Panel background | rgba(30, 26, 46, 0.95) |
| Button normal | #403556 |
| Button hover | #594778 |
| Button pressed | #332A4D |
| Text primary | #F2E6B0 |
| Text secondary | #999080 |
| Text accent | #FFD933 |
| Border | rgba(128, 115, 153, 0.5) |

---

## Lighting Rules

1. **Key light**: Warm amber from upper-right (45° angle), simulating moonlight through canopy
2. **Fill light**: Cool blue-purple ambient from left
3. **Rim light**: Subtle gold outline on foreground objects
4. **Atmospheric haze**: Lighter values on distant layers for depth
5. **Light overlays**: Semi-transparent warm tint across gameplay, pulsing gently
6. **Particle glow**: Seeds and powerups emit a soft radial glow (additive blend)

---

## Brush Texture & Style

- **Backgrounds**: Painterly with visible brush strokes, soft edges
- **Characters**: Clean vector-style with subtle texture overlay
- **Obstacles**: Semi-realistic forms with painterly shading
- **UI panels**: Frosted glass effect with soft borders
- **Icons**: Flat with one shadow layer, 2px rounded corners

### Line Weight
- Characters: 2-3px outline, warm dark brown (#2A1F14)
- Obstacles: 1-2px outline or no outline (shadow only)
- UI icons: 2px stroke
- No outlines on backgrounds

---

## Silhouette Rules

1. Every object must read clearly as a silhouette at 50% scale
2. Characters: Round head, compact body, short legs — reads as "cute creature"
3. Obstacles: Irregular organic shapes — never perfect rectangles
4. Powerups: Distinct geometric shapes (star, diamond, circle)
5. Buildings: Clear roofline silhouette for each type

---

## Character Proportions

- **Height**: 2.5 heads tall
- **Head**: Large, round, ~35% of total height
- **Body**: Compact oval, ~40% of total height
- **Legs**: Short stubs, ~25% of total height
- **Arms**: Optional — small stubs or tucked
- **Eyes**: Large, round, high on face (60% up)
- **Mouth**: Small, simple curve or dot

### Character Sprites Needed
| Sprite | Frames | Size (px) |
|--------|--------|-----------|
| Idle | 4 | 128×128 |
| Run | 8 | 128×128 |
| Jump (up) | 2 | 128×128 |
| Jump (down) | 2 | 128×128 |
| Slide | 2 | 160×80 |
| Crash | 4 | 128×128 |
| Celebrate | 4 | 128×128 |

---

## UI Style Tokens

### Typography
- **Headings**: Rounded serif or slab serif, warm gold color
- **Body**: Clean sans-serif, cream/off-white
- **Numbers (score)**: Monospace or tabular lining, larger size
- **Size scale**: 10, 12, 14, 16, 18, 22, 26, 32, 48px

### Panels
- Background: Dark purple-brown with 95% opacity
- Corner radius: 16px
- Border: 2px, pale purple-gray at 50% opacity
- Padding: 16-24px
- Drop shadow: 4px offset, 8px blur, rgba(0,0,0,0.3)

### Buttons
- Corner radius: 10-12px
- Min height: 48px (touch target)
- Min width: 120px
- Text centered, 18-22px
- Hover: lighten 10%
- Pressed: darken 5%
- Disabled: 50% opacity

---

## Asset Prompts for Image Generation

### Background Layers (3 per biome, parallax)

#### Enchanted Forest — Far Layer
```
A distant view of a mystical forest mountain range at twilight, 
deep purple sky with warm amber moon glow, 
silhouetted layered mountains with soft painterly edges,
storybook illustration style, warm fantasy lighting,
seamless horizontal tile, 1280x400px, no text
```

#### Enchanted Forest — Mid Layer
```
Dense enchanted forest trees at mid-distance, 
tall stylized trees with full canopies in deep greens and teals,
dappled golden light filtering through leaves,
painterly brush texture, soft edges, storybook fantasy style,
seamless horizontal tile, 1280x400px, no text
```

#### Enchanted Forest — Near Layer
```
Close-up forest floor with ferns, mushrooms and bushes,
rich dark greens and mossy browns,
glowing fireflies and dewdrops catching light,
painterly storybook style with visible brush strokes,
seamless horizontal tile, 1280x300px, no text
```

#### Crystal Caverns — Far Layer
```
Deep underground cavern with distant crystal formations,
deep purple and midnight blue colors,
faint blue and violet crystal glow from stalagmites,
atmospheric cave mist, fantasy illustration style,
seamless horizontal tile, 1280x400px, no text
```

#### Crystal Caverns — Mid Layer
```
Crystal cave pillars and stalactites at middle distance,
luminescent purple and ice blue crystals embedded in dark rock,
soft magical glow emanating from crystal clusters,
painterly fantasy cave style,
seamless horizontal tile, 1280x400px, no text
```

#### Crystal Caverns — Near Layer
```
Close cave floor with small crystals, cave mushrooms, and rocky formations,
dark stone with blue-purple crystal fragments,
soft phosphorescent glow from fungi,
fantasy illustration style with texture,
seamless horizontal tile, 1280x300px, no text
```

#### Starlit Meadow — Far Layer
```
Vast night sky over rolling meadow hills,
deep dark blue-black sky filled with bright stars and distant galaxies,
silhouetted gentle hills with occasional tall trees,
dreamy storybook night scene, soft painterly style,
seamless horizontal tile, 1280x400px, no text
```

#### Starlit Meadow — Mid Layer
```
Meadow with scattered silver birch trees under starlight,
pale silver bark trees with delicate golden-green leaves,
soft moonlight illuminating the scene from above,
fireflies and star motes floating in the air,
painterly fantasy illustration style,
seamless horizontal tile, 1280x400px, no text
```

#### Starlit Meadow — Near Layer
```
Close meadow floor with tall grasses, wildflowers and fireflies,
golden-green grass swaying gently,
small glowing flowers in lavender and gold,
enchanted night meadow, storybook style,
seamless horizontal tile, 1280x300px, no text
```

### UI Panels/Buttons

```
Fantasy game UI panel, dark purple-brown background,
rounded rectangle with subtle golden border,
frosted glass effect with soft inner glow,
elegant but readable, storybook fantasy style,
transparent PNG, 400x300px
```

```
Fantasy game button set: normal, hover, pressed states,
rounded rectangle, warm forest green color,
golden text, subtle shine highlight on top,
clean flat design with one shadow layer,
transparent PNG, 300x60px each
```

### Character Sprites

```
Cute forest spirit character sprite sheet,
small round creature with big eyes, leaf-like ears,
forest green body with lighter belly,
2.5 heads tall proportions, chibi style,
run cycle 8 frames, transparent background,
storybook fantasy illustration style, clean outlines,
sprite sheet layout, 1024x128px
```

### Obstacles

```
Set of 6 forest obstacle sprites for endless runner,
mossy boulder, fallen log, thorn bush, mushroom cluster,
twisted root, enchanted barrier,
each ~64x64px, painterly storybook style,
organic irregular shapes, dark earth tones,
transparent background PNG
```

### Collectibles

```
Golden magical seed collectible sprite,
diamond/teardrop shape with inner glow,
warm golden-yellow color (#FFD933),
4 frames of subtle glow animation,
storybook fantasy style, transparent background,
64x64px sprite sheet
```

```
Power-up collectible sprite set: shield (blue star), 
magnet (pink star), score multiplier (purple star),
each with soft glow halo, clean geometric shape,
fantasy style, transparent background, 64x64px each
```

### Grove Buildings

```
Small seed house building for top-down grove view,
cozy cottage style with thatched roof,
warm brown wood and golden accents,
tiny chimney with curling smoke,
storybook fantasy illustration, top-down perspective,
128x128px, transparent background
```

```
Enchanted lantern tower for top-down grove view,
tall thin tower with glowing amber lantern at top,
stone base with golden light rays,
fantasy storybook style, top-down perspective,
64x64px, transparent background
```

```
Fantasy workshop building for top-down grove view,
small forge/craftsman style building,
purple-gray stone with wooden details,
glowing runes or symbols on walls,
storybook style, top-down perspective,
128x128px, transparent background
```

---

## Post-Processing Plan

### Target Resolutions
| Asset Type | Base Resolution | @2x | @3x |
|------------|----------------|-----|-----|
| Character sprites | 64x64 | 128x128 | 192x192 |
| Obstacles | 64x64 | 128x128 | - |
| Collectibles | 32x32 | 64x64 | - |
| BG layers | 1280x400 | 2560x800 | - |
| UI panels | 400x300 | 800x600 | - |
| UI icons | 32x32 | 64x64 | - |
| Building sprites | 64x64 | 128x128 | - |

### Trimming & Padding
- All sprites: trim transparent pixels, add 2px padding on each side
- Character sprites: maintain consistent canvas size per animation
- UI panels: preserve full canvas for 9-slice

### 9-Slice Rules for UI
- Panel background: 16px margins on all sides
- Button backgrounds: 12px margins on all sides
- Tooltip backgrounds: 8px margins

### Texture Atlasing
- Use Godot's built-in TextureAtlas for sprite sheets
- Group by category: characters, obstacles, collectibles, UI
- Max atlas size: 2048x2048

### Compression Settings (Godot Import)
| Asset Type | Format | Filter | Mipmaps |
|------------|--------|--------|---------|
| Sprites | Lossless (PNG) | Nearest | Off |
| Backgrounds | Lossy (WebP, q80) | Linear | Off |
| UI panels | Lossless (PNG) | Linear | Off |
| Icons | Lossless (PNG) | Nearest | Off |

### Memory Budget
- Total texture memory target: <50MB on low-end (2GB RAM)
- Character atlas: ~2MB
- Obstacle atlas: ~1MB
- 3 biome BGs: ~6MB (3 × 3 layers × ~700KB)
- UI atlas: ~2MB
- Collectibles: ~0.5MB
- Grove buildings: ~1.5MB
- **Total: ~13MB** (well within budget)

---

## Audio Direction (Placeholder Plan)

### SFX Needed
| Sound | Style | Duration |
|-------|-------|----------|
| Seed collect | Bright chime, ascending | 0.1s |
| Powerup collect | Magical sparkle, wider | 0.2s |
| Jump | Soft whoosh, upward pitch | 0.15s |
| Slide | Quick swoosh, downward | 0.12s |
| Crash | Soft thud + glass break | 0.3s |
| Shield hit | Crystal ring + deflect | 0.25s |
| Shield activate | Chiming barrier sound | 0.3s |
| Lane switch | Soft air swoosh | 0.08s |
| Portal enter | Magical whorl, reverb | 0.4s |
| UI button tap | Soft click with warmth | 0.05s |
| Score tick | Subtle tap | 0.03s |
| Quest complete | Triumphant short jingle | 0.5s |
| Building place | Stone + wood settle | 0.3s |
| Building upgrade | Ascending chime chain | 0.5s |

### Music Tracks Needed
| Track | Style | Loop Length | Tempo |
|-------|-------|-------------|-------|
| Main Menu | Calm, mystical, ambient | 60s | 80 BPM |
| Enchanted Forest Run | Upbeat, whimsical orchestral | 90s | 140 BPM |
| Crystal Caverns Run | Energetic, ethereal synth | 90s | 145 BPM |
| Starlit Meadow Run | Dreamy, flowing, uplifting | 90s | 135 BPM |
| Grove Theme | Gentle, peaceful, pastoral | 60s | 90 BPM |
| Game Over | Brief sad/contemplative | 5s | - |
| Victory Jingle | Short triumphant | 3s | - |

### CC0 / Royalty-Free Sources
- [Freesound.org](https://freesound.org) — CC0 sound effects
- [OpenGameArt.org](https://opengameart.org) — CC0/CC-BY game assets
- [Incompetech](https://incompetech.com) — Royalty-free music (attribution)
- [Musopen](https://musopen.org) — Public domain classical
- Custom generation via tools like [sfxr](https://sfxr.me/) / [ChipTone](https://sfbgames.itch.io/chiptone)
