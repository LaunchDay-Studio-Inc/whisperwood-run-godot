# Phase 2 — Grove Meta + Progression

## Design Notes

### Goal
Build the grove meta-game scene with grid-based building placement, upgrades that affect runner rewards, and a quest system providing short-term and long-term goals.

### Grove Architecture
```
GroveScene (Node2D)
├── Background (Polygon2D — grass/dark surround)
├── Grid cells (Polygon2D × 108)
├── Building nodes (placed dynamically)
├── Camera2D
└── UI Layer (CanvasLayer)
    ├── Top bar (seeds, gems)
    ├── Bottom bar (Run, Build, Quests, Menu)
    ├── Build overlay (scrollable building list)
    └── Quest overlay (quest progress/claim)
```

### Buildings (10 types)
| ID | Name | Size | Max Level | Base Cost | Effect |
|----|------|------|-----------|-----------|--------|
| seed_house | Seed House | 2×2 | 5 | 50 🌱 | +15% seeds/level |
| lantern | Enchanted Lantern | 1×1 | 3 | 100 🌱 | Unlock biomes |
| workshop | Workshop | 2×2 | 4 | 75 🌱 | Craft boosts |
| flower_bed | Flower Bed | 1×1 | 1 | 15 🌱 | Decoration |
| mushroom_ring | Mushroom Ring | 1×1 | 1 | 20 🌱 | Decoration |
| pond | Moonlit Pond | 2×1 | 1 | 30 🌱 | Decoration |
| stone_path | Stone Path | 1×1 | 1 | 10 🌱 | Decoration |
| fairy_tree | Fairy Tree | 2×3 | 2 | 60 🌱 | Decoration |
| bench | Grove Bench | 1×1 | 1 | 12 🌱 | Decoration |
| crystal | Crystal Formation | 1×1 | 1 | 25 🌱 | Decoration |

### Upgrade Effects on Runner
- **Seed House** → `seed_multiplier = 1.0 + level * 0.15`
- **Lantern** → unlocks biomes (Lv1: Crystal Caverns, Lv2: Starlit Meadow)
- **Workshop** → Lv1: start shield, Lv2+: +1s magnet per level

### Quest System
#### Beginner Quests (persistent)
1. **First Steps** — Run 100m total → 20 seeds
2. **Seed Gatherer** — Collect 50 seeds total → 30 seeds
3. **Getting Warmed Up** — Complete 5 runs → 5 gems

#### Daily Quests (reset each day)
1. **Daily Dash** — Run 200m in one run → 15 seeds
2. **Daily Harvest** — Collect 20 seeds today → 10 seeds
3. **Moonlit Explorer** — Take a moonlit shortcut → 2 gems

### Economy Balance v1
- Average seeds per run: ~15
- First building affordable in 1-2 runs
- Seed House Lv1 at ~3-4 runs
- Workshop Lv1 at ~5 runs
- First biome unlock at ~7 runs
- Gems are scarce → incentivizes ad engagement on mobile

---

## Acceptance Criteria

- [ ] Grove scene loads with grid visible
- [ ] Build menu shows all 10 buildings with costs
- [ ] Can purchase building when enough seeds
- [ ] Cannot purchase when insufficient seeds
- [ ] Purchased functional buildings (Seed House, Lantern, Workshop) update GameManager
- [ ] Seed multiplier increases actual seed gain in runner
- [ ] Lantern unlock adds new biomes to runner biome pool
- [ ] Workshop Lv1 gives start shield in runner
- [ ] Buildings visually appear on grid after purchase
- [ ] Upgrades persist across sessions
- [ ] Quest panel shows 3 beginner + 3 daily quests
- [ ] Quest progress updates after runs
- [ ] Completed quests can be claimed for rewards
- [ ] Daily quests reset each new day
- [ ] Runner payout with Seed House upgrade feels noticeably better

---

## Test Checklist

### Grove Tests
- [ ] Open grove → grid and background render correctly
- [ ] Tap "Build" → build menu opens
- [ ] Purchase Flower Bed (10 seeds) → seed count decreases, building appears
- [ ] Purchase Seed House Lv1 → seed_house_level = 1 in GameManager
- [ ] Run → seeds collected multiplied by 1.15
- [ ] Purchase Lantern Lv1 → Crystal Caverns biome available
- [ ] Purchase Workshop Lv1 → player starts with shield
- [ ] Close and reopen app → grove data persists
- [ ] All buildings visible after reload

### Quest Tests
- [ ] Quest panel shows all quests
- [ ] Run 100m → "First Steps" progress updates
- [ ] Collect 50 seeds → "Seed Gatherer" completable
- [ ] Complete 5 runs → "Getting Warmed Up" completable
- [ ] Claim quest reward → seeds/gems added
- [ ] Next day → daily quests reset

### Economy Tests
- [ ] New player can buy stone_path in 1 run
- [ ] Seed House Lv1 takes 3-4 runs
- [ ] Multiplier stacking feels impactful by Lv3

---

## Known Issues (Phase 2)

1. **Grid placement is auto-find** — No drag-and-drop placement yet; buildings auto-place to first free spot.
2. **No building removal** — Once placed, buildings cannot be moved or removed.
3. **Quest UI is basic** — Functional but lacks polish animations.
4. **No daily login reward** — Planned but not implemented.
5. **Decoration buildings are visual-only** — They don't affect gameplay.

---

## Suggested Git Commits

```
feat: implement GroveScene with grid-based layout and camera
feat: add 10 building definitions with cost/upgrade formulas
feat: build/upgrade menu with seed cost deduction
feat: connect Seed House, Lantern, Workshop upgrades to runner
feat: add Quest system with 3 beginner + 3 daily quests
feat: implement quest progress tracking via EventBus
feat: add economy balance data file
docs: add Phase 2 design notes and acceptance criteria
```
