## BiomeConfig — Defines palette/obstacle sets for each biome
extends RefCounted
class_name BiomeConfig

static var BIOMES := {
	"enchanted_forest": {
		"name": "Enchanted Forest",
		"bg_colors": [
			Color(0.15, 0.12, 0.25),  # sky
			Color(0.2, 0.18, 0.3),     # far mountains
			Color(0.15, 0.3, 0.2),     # mid trees
			Color(0.1, 0.25, 0.15),    # near bushes
			Color(0.2, 0.15, 0.1),     # ground
		],
		"obstacle_colors": [Color(0.45, 0.35, 0.3), Color(0.5, 0.35, 0.2)],
		"seed_color": Color(1.0, 0.85, 0.2),
		"trail_color": Color(0.3, 0.85, 0.5, 0.5),
		"light_tint": Color(1.0, 0.9, 0.6, 0.04),
		"ambient": Color(0.12, 0.1, 0.15),
		"portals": {
			"safe": Color(0.2, 0.7, 0.4, 0.8),
			"risky": Color(0.8, 0.3, 0.2, 0.8),
			"mystery": Color(0.6, 0.4, 0.9, 0.8),
		},
		"unique_obstacles": ["mossy_rock", "fallen_log", "thorn_bush"],
	},
	"crystal_caverns": {
		"name": "Crystal Caverns",
		"bg_colors": [
			Color(0.08, 0.06, 0.18),   # deep cave sky
			Color(0.12, 0.1, 0.28),    # stalactites
			Color(0.18, 0.12, 0.35),   # crystal formations
			Color(0.12, 0.08, 0.3),    # near crystals
			Color(0.1, 0.08, 0.2),     # cave floor
		],
		"obstacle_colors": [Color(0.3, 0.25, 0.5), Color(0.4, 0.2, 0.45)],
		"seed_color": Color(0.5, 0.8, 1.0),
		"trail_color": Color(0.4, 0.5, 1.0, 0.5),
		"light_tint": Color(0.5, 0.6, 1.0, 0.05),
		"ambient": Color(0.08, 0.06, 0.15),
		"portals": {
			"safe": Color(0.3, 0.5, 0.8, 0.8),
			"risky": Color(0.9, 0.2, 0.5, 0.8),
			"mystery": Color(0.8, 0.3, 0.9, 0.8),
		},
		"unique_obstacles": ["crystal_spike", "stalagmite", "cave_mushroom"],
	},
	"starlit_meadow": {
		"name": "Starlit Meadow",
		"bg_colors": [
			Color(0.05, 0.03, 0.12),   # deep night sky
			Color(0.08, 0.06, 0.18),   # distant hills
			Color(0.12, 0.2, 0.12),    # meadow trees
			Color(0.08, 0.18, 0.08),   # tall grass
			Color(0.12, 0.1, 0.06),    # earthy path
		],
		"obstacle_colors": [Color(0.35, 0.4, 0.3), Color(0.3, 0.35, 0.25)],
		"seed_color": Color(0.9, 1.0, 0.5),
		"trail_color": Color(0.7, 0.9, 0.3, 0.5),
		"light_tint": Color(0.7, 0.8, 1.0, 0.03),
		"ambient": Color(0.05, 0.04, 0.1),
		"portals": {
			"safe": Color(0.4, 0.8, 0.3, 0.8),
			"risky": Color(0.9, 0.5, 0.2, 0.8),
			"mystery": Color(0.5, 0.6, 1.0, 0.8),
		},
		"unique_obstacles": ["gnarled_root", "fairy_ring", "sleeping_stone"],
	},
}

static func get_biome(biome_id: String) -> Dictionary:
	return BIOMES.get(biome_id, BIOMES["enchanted_forest"])

static func get_all_biome_ids() -> Array[String]:
	var ids: Array[String] = []
	for key in BIOMES:
		ids.append(key)
	return ids
