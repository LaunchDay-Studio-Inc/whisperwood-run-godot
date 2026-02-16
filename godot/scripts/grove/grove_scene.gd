## GroveScene — Top-down diorama grove with grid-based building placement
extends Node2D

const GRID_SIZE := 64
const GRID_COLS := 9
const GRID_ROWS := 12
const GRID_OFFSET := Vector2(-GRID_SIZE * GRID_COLS / 2.0, -GRID_SIZE * GRID_ROWS / 2.0 + 100)

var _grid: Array = []  # 2D array of building_ids (empty string = vacant)
var _building_nodes: Dictionary = {}  # grid_key -> Node2D
var _selected_building_id: String = ""
var _placement_mode: bool = false
var _camera: Camera2D = null
var _ui_layer: CanvasLayer = null

# Building definitions
const BUILDINGS := {
	"seed_house": {
		"name": "Seed House",
		"description": "Increases seeds gained per run",
		"size": Vector2i(2, 2),
		"max_level": 5,
		"base_cost": 50,
		"cost_mult": 1.8,
		"color": Color(0.6, 0.45, 0.2),
		"effect": "seed_multiplier",
	},
	"lantern": {
		"name": "Enchanted Lantern",
		"description": "Unlocks new biomes and palettes",
		"size": Vector2i(1, 1),
		"max_level": 3,
		"base_cost": 100,
		"cost_mult": 2.5,
		"color": Color(0.9, 0.7, 0.2),
		"effect": "biome_unlock",
	},
	"workshop": {
		"name": "Workshop",
		"description": "Craft boosts like start shield and magnet duration",
		"size": Vector2i(2, 2),
		"max_level": 4,
		"base_cost": 75,
		"cost_mult": 2.0,
		"color": Color(0.5, 0.4, 0.5),
		"effect": "craft_boosts",
	},
	"flower_bed": {
		"name": "Flower Bed",
		"description": "A decorative patch of wildflowers",
		"size": Vector2i(1, 1),
		"max_level": 1,
		"base_cost": 15,
		"cost_mult": 1.0,
		"color": Color(0.8, 0.3, 0.5),
		"effect": "decoration",
	},
	"mushroom_ring": {
		"name": "Mushroom Ring",
		"description": "A mystical circle of glowing mushrooms",
		"size": Vector2i(1, 1),
		"max_level": 1,
		"base_cost": 20,
		"cost_mult": 1.0,
		"color": Color(0.7, 0.5, 0.8),
		"effect": "decoration",
	},
	"pond": {
		"name": "Moonlit Pond",
		"description": "A serene reflecting pool",
		"size": Vector2i(2, 1),
		"max_level": 1,
		"base_cost": 30,
		"cost_mult": 1.0,
		"color": Color(0.3, 0.5, 0.7),
		"effect": "decoration",
	},
	"stone_path": {
		"name": "Stone Path",
		"description": "A winding cobblestone path",
		"size": Vector2i(1, 1),
		"max_level": 1,
		"base_cost": 10,
		"cost_mult": 1.0,
		"color": Color(0.55, 0.5, 0.45),
		"effect": "decoration",
	},
	"fairy_tree": {
		"name": "Fairy Tree",
		"description": "A great tree with tiny lanterns",
		"size": Vector2i(2, 3),
		"max_level": 2,
		"base_cost": 60,
		"cost_mult": 2.0,
		"color": Color(0.3, 0.55, 0.25),
		"effect": "decoration",
	},
	"bench": {
		"name": "Grove Bench",
		"description": "A quiet resting spot",
		"size": Vector2i(1, 1),
		"max_level": 1,
		"base_cost": 12,
		"cost_mult": 1.0,
		"color": Color(0.5, 0.35, 0.2),
		"effect": "decoration",
	},
	"crystal": {
		"name": "Crystal Formation",
		"description": "A cluster of luminescent crystals",
		"size": Vector2i(1, 1),
		"max_level": 1,
		"base_cost": 25,
		"cost_mult": 1.0,
		"color": Color(0.4, 0.7, 0.9),
		"effect": "decoration",
	},
}

func _ready() -> void:
	GameManager.change_state(GameManager.GameState.GROVE)
	_init_grid()
	_draw_grove_background()
	_draw_grid()
	_load_grove_data()
	_setup_camera()
	_build_grove_ui()

func _init_grid() -> void:
	_grid = []
	for row in GRID_ROWS:
		var row_data: Array = []
		for col in GRID_COLS:
			row_data.append("")
		_grid.append(row_data)

func _draw_grove_background() -> void:
	# Grass background
	var bg := Polygon2D.new()
	var margin := 40
	bg.polygon = PackedVector2Array([
		Vector2(GRID_OFFSET.x - margin, GRID_OFFSET.y - margin),
		Vector2(GRID_OFFSET.x + GRID_COLS * GRID_SIZE + margin, GRID_OFFSET.y - margin),
		Vector2(GRID_OFFSET.x + GRID_COLS * GRID_SIZE + margin, GRID_OFFSET.y + GRID_ROWS * GRID_SIZE + margin),
		Vector2(GRID_OFFSET.x - margin, GRID_OFFSET.y + GRID_ROWS * GRID_SIZE + margin),
	])
	bg.color = Color(0.15, 0.28, 0.12)
	bg.z_index = -5
	add_child(bg)

	# Outer darkness
	var outer := Polygon2D.new()
	outer.polygon = PackedVector2Array([
		Vector2(-600, -800), Vector2(600, -800),
		Vector2(600, 1000), Vector2(-600, 1000),
	])
	outer.color = Color(0.08, 0.06, 0.1)
	outer.z_index = -6
	add_child(outer)

func _draw_grid() -> void:
	for row in GRID_ROWS:
		for col in GRID_COLS:
			var cell := Polygon2D.new()
			var pos := _grid_to_world(Vector2i(col, row))
			cell.polygon = PackedVector2Array([
				Vector2(1, 1), Vector2(GRID_SIZE - 1, 1),
				Vector2(GRID_SIZE - 1, GRID_SIZE - 1), Vector2(1, GRID_SIZE - 1),
			])
			cell.color = Color(0.18, 0.32, 0.15, 0.3)
			cell.position = pos
			cell.z_index = -4
			add_child(cell)

func _grid_to_world(grid_pos: Vector2i) -> Vector2:
	return Vector2(grid_pos.x * GRID_SIZE, grid_pos.y * GRID_SIZE) + GRID_OFFSET

func _world_to_grid(world_pos: Vector2) -> Vector2i:
	var local := world_pos - GRID_OFFSET
	return Vector2i(int(local.x / GRID_SIZE), int(local.y / GRID_SIZE))

func _setup_camera() -> void:
	_camera = Camera2D.new()
	_camera.position = Vector2(0, 200)
	_camera.zoom = Vector2(0.85, 0.85)
	add_child(_camera)

func _build_grove_ui() -> void:
	_ui_layer = CanvasLayer.new()
	_ui_layer.layer = 10
	add_child(_ui_layer)

	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ui_layer.add_child(root)

	# Top bar with currency
	var top_bar := HBoxContainer.new()
	top_bar.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top_bar.offset_top = 20
	top_bar.offset_left = 20
	top_bar.offset_right = -20
	top_bar.offset_bottom = 70
	root.add_child(top_bar)

	var seeds_label := Label.new()
	seeds_label.name = "SeedsLabel"
	seeds_label.text = "🌱 %d" % GameManager.seeds
	seeds_label.add_theme_font_size_override("font_size", 22)
	seeds_label.add_theme_color_override("font_color", Color(1, 0.85, 0.2))
	top_bar.add_child(seeds_label)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_bar.add_child(spacer)

	var gems_label := Label.new()
	gems_label.name = "GemsLabel"
	gems_label.text = "💎 %d" % GameManager.gems
	gems_label.add_theme_font_size_override("font_size", 22)
	gems_label.add_theme_color_override("font_color", Color(0.5, 0.8, 1.0))
	top_bar.add_child(gems_label)

	# Bottom action bar
	var bottom_bar := HBoxContainer.new()
	bottom_bar.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bottom_bar.offset_top = -80
	bottom_bar.offset_left = 10
	bottom_bar.offset_right = -10
	bottom_bar.add_theme_constant_override("separation", 8)
	root.add_child(bottom_bar)

	var run_btn := _create_grove_button("Run!", Color(0.2, 0.5, 0.3))
	run_btn.pressed.connect(func(): GameManager.go_to_scene("res://scenes/runner/runner.tscn"))
	bottom_bar.add_child(run_btn)

	var build_btn := _create_grove_button("Build", Color(0.4, 0.35, 0.2))
	build_btn.pressed.connect(_open_build_menu)
	bottom_bar.add_child(build_btn)

	var quest_btn := _create_grove_button("Quests", Color(0.35, 0.3, 0.5))
	quest_btn.pressed.connect(_open_quest_panel)
	bottom_bar.add_child(quest_btn)

	var menu_btn := _create_grove_button("Menu", Color(0.3, 0.25, 0.35))
	menu_btn.pressed.connect(func(): GameManager.go_to_scene("res://scenes/main_menu.tscn"))
	bottom_bar.add_child(menu_btn)

	# Connect currency updates
	EventBus.seeds_updated.connect(func(v): seeds_label.text = "🌱 %d" % v)
	EventBus.gems_updated.connect(func(v): gems_label.text = "💎 %d" % v)

func _create_grove_button(text: String, color: Color) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.custom_minimum_size.y = 56
	btn.add_theme_font_size_override("font_size", 18)

	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	btn.add_theme_stylebox_override("normal", style)

	var hover := style.duplicate()
	hover.bg_color = Color(color.r + 0.1, color.g + 0.1, color.b + 0.1)
	btn.add_theme_stylebox_override("hover", hover)

	return btn

func _open_build_menu() -> void:
	var overlay := ColorRect.new()
	overlay.name = "BuildOverlay"
	overlay.color = Color(0, 0, 0, 0.6)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_ui_layer.add_child(overlay)

	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.offset_top = 60
	scroll.offset_bottom = -90
	scroll.offset_left = 20
	scroll.offset_right = -20
	overlay.add_child(scroll)

	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 8)
	scroll.add_child(vbox)

	var title := Label.new()
	title.text = "BUILD & UPGRADE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color(1, 0.95, 0.7))
	vbox.add_child(title)

	for building_id in BUILDINGS:
		var data: Dictionary = BUILDINGS[building_id]
		var current_level := _get_building_level(building_id)
		var cost := _get_upgrade_cost(building_id)
		var is_maxed := current_level >= data["max_level"]

		var item := HBoxContainer.new()
		item.custom_minimum_size.y = 70

		# Color swatch
		var swatch := ColorRect.new()
		swatch.color = data["color"]
		swatch.custom_minimum_size = Vector2(50, 50)
		item.add_child(swatch)

		# Info
		var info_vbox := VBoxContainer.new()
		info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var name_label := Label.new()
		name_label.text = "%s (Lv %d/%d)" % [data["name"], current_level, data["max_level"]]
		name_label.add_theme_font_size_override("font_size", 16)
		name_label.add_theme_color_override("font_color", Color(0.9, 0.85, 0.7))
		info_vbox.add_child(name_label)

		var desc_label := Label.new()
		desc_label.text = data["description"]
		desc_label.add_theme_font_size_override("font_size", 12)
		desc_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.55))
		info_vbox.add_child(desc_label)

		item.add_child(info_vbox)

		# Build/Upgrade button
		if not is_maxed:
			var build_btn := Button.new()
			if current_level == 0:
				build_btn.text = "Build (%d 🌱)" % cost
			else:
				build_btn.text = "Upgrade (%d 🌱)" % cost
			build_btn.custom_minimum_size = Vector2(130, 44)
			build_btn.disabled = GameManager.seeds < cost
			build_btn.add_theme_font_size_override("font_size", 13)

			var bid := building_id  # Capture for lambda
			build_btn.pressed.connect(func():
				_build_or_upgrade(bid)
				overlay.queue_free()
				_open_build_menu()  # Refresh
			)
			item.add_child(build_btn)
		else:
			var maxed_label := Label.new()
			maxed_label.text = "MAX"
			maxed_label.add_theme_font_size_override("font_size", 14)
			maxed_label.add_theme_color_override("font_color", Color(0.5, 0.8, 0.4))
			item.add_child(maxed_label)

		vbox.add_child(item)

	# Close button
	var close_btn := Button.new()
	close_btn.text = "Close"
	close_btn.custom_minimum_size = Vector2(200, 44)
	close_btn.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	close_btn.pressed.connect(func(): overlay.queue_free())
	var close_container := CenterContainer.new()
	close_container.custom_minimum_size.y = 50
	close_container.add_child(close_btn)
	vbox.add_child(close_container)

func _open_quest_panel() -> void:
	var quest_mgr_script = load("res://scripts/grove/quest_manager.gd")
	var overlay := ColorRect.new()
	overlay.name = "QuestOverlay"
	overlay.color = Color(0, 0, 0, 0.6)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_ui_layer.add_child(overlay)

	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(420, 500)
	panel.offset_left = -210
	panel.offset_right = 210
	panel.offset_top = -250
	panel.offset_bottom = 250

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.1, 0.18, 0.98)
	style.corner_radius_top_left = 16
	style.corner_radius_top_right = 16
	style.corner_radius_bottom_left = 16
	style.corner_radius_bottom_right = 16
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 16
	style.content_margin_bottom = 16
	panel.add_theme_stylebox_override("panel", style)
	overlay.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)

	var title := Label.new()
	title.text = "QUESTS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 26)
	title.add_theme_color_override("font_color", Color(1, 0.95, 0.7))
	vbox.add_child(title)

	var quest_data: Dictionary = SaveManager.get_value("quest_data", {})
	var quests := _get_all_quests()

	for quest in quests:
		var qid: String = quest["id"]
		var progress: int = quest_data.get(qid + "_progress", 0)
		var completed: bool = quest_data.get(qid + "_completed", false)

		var quest_item := VBoxContainer.new()
		var quest_name := Label.new()
		quest_name.text = quest["name"]
		quest_name.add_theme_font_size_override("font_size", 16)
		quest_name.add_theme_color_override("font_color", Color(0.9, 0.85, 0.7) if not completed else Color(0.5, 0.7, 0.4))
		quest_item.add_child(quest_name)

		var progress_label := Label.new()
		if completed:
			progress_label.text = "✓ Completed — Reward: %s" % quest["reward_text"]
		else:
			progress_label.text = "%d / %d — Reward: %s" % [min(progress, quest["target"]), quest["target"], quest["reward_text"]]
		progress_label.add_theme_font_size_override("font_size", 12)
		progress_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.55))
		quest_item.add_child(progress_label)

		# Claim button
		if progress >= quest["target"] and not completed:
			var claim_btn := Button.new()
			claim_btn.text = "Claim!"
			claim_btn.custom_minimum_size = Vector2(80, 32)
			claim_btn.add_theme_font_size_override("font_size", 13)
			var quest_ref := quest
			claim_btn.pressed.connect(func():
				_claim_quest_reward(quest_ref)
				overlay.queue_free()
				_open_quest_panel()
			)
			quest_item.add_child(claim_btn)

		var sep := HSeparator.new()
		quest_item.add_child(sep)
		vbox.add_child(quest_item)

	var close_btn := Button.new()
	close_btn.text = "Close"
	close_btn.custom_minimum_size = Vector2(200, 44)
	close_btn.pressed.connect(func(): overlay.queue_free())
	var close_container := CenterContainer.new()
	close_container.add_child(close_btn)
	vbox.add_child(close_container)

	panel.add_child(vbox)

func _get_all_quests() -> Array:
	return [
		# Beginner quests
		{"id": "beg_run_100", "name": "First Steps", "description": "Run 100 meters total", "target": 100, "type": "distance", "reward_seeds": 20, "reward_text": "20 Seeds"},
		{"id": "beg_seeds_50", "name": "Seed Gatherer", "description": "Collect 50 seeds total", "target": 50, "type": "seeds", "reward_seeds": 30, "reward_text": "30 Seeds"},
		{"id": "beg_runs_5", "name": "Getting Warmed Up", "description": "Complete 5 runs", "target": 5, "type": "runs", "reward_gems": 5, "reward_text": "5 Gems"},
		# Daily quests
		{"id": "daily_run_200", "name": "Daily Dash", "description": "Run 200m in a single run", "target": 200, "type": "single_distance", "reward_seeds": 15, "reward_text": "15 Seeds", "daily": true},
		{"id": "daily_seeds_20", "name": "Daily Harvest", "description": "Collect 20 seeds today", "target": 20, "type": "daily_seeds", "reward_seeds": 10, "reward_text": "10 Seeds", "daily": true},
		{"id": "daily_shortcut", "name": "Moonlit Explorer", "description": "Take a moonlit shortcut", "target": 1, "type": "shortcuts", "reward_gems": 2, "reward_text": "2 Gems", "daily": true},
	]

func _claim_quest_reward(quest: Dictionary) -> void:
	if quest.has("reward_seeds"):
		GameManager.seeds += quest["reward_seeds"]
	if quest.has("reward_gems"):
		GameManager.gems += quest["reward_gems"]

	var quest_data: Dictionary = SaveManager.get_value("quest_data", {})
	quest_data[quest["id"] + "_completed"] = true
	SaveManager.set_value("quest_data", quest_data)
	GameManager.save_game()

	EventBus.quest_completed.emit(quest["id"])

func _get_building_level(building_id: String) -> int:
	var grove_data: Dictionary = SaveManager.get_value("grove_data", {})
	return grove_data.get(building_id + "_level", 0)

func _get_upgrade_cost(building_id: String) -> int:
	var data: Dictionary = BUILDINGS[building_id]
	var level := _get_building_level(building_id)
	return int(data["base_cost"] * pow(data["cost_mult"], level))

func _build_or_upgrade(building_id: String) -> void:
	var cost := _get_upgrade_cost(building_id)
	if GameManager.seeds < cost:
		return

	GameManager.seeds -= cost
	var grove_data: Dictionary = SaveManager.get_value("grove_data", {})
	var current_level: int = grove_data.get(building_id + "_level", 0)
	var new_level := current_level + 1
	grove_data[building_id + "_level"] = new_level
	SaveManager.set_value("grove_data", grove_data)

	# Apply effects
	match building_id:
		"seed_house":
			GameManager.seed_house_level = new_level
		"lantern":
			GameManager.lantern_level = new_level
		"workshop":
			GameManager.workshop_level = new_level

	EventBus.building_upgraded.emit(building_id, new_level)
	GameManager.save_game()

	# Place visual on grid
	_place_building_visual(building_id, new_level)

func _place_building_visual(building_id: String, level: int) -> void:
	# Remove old visual if exists
	if _building_nodes.has(building_id):
		_building_nodes[building_id].queue_free()

	var data: Dictionary = BUILDINGS[building_id]
	var grid_pos := _find_free_grid_pos(data["size"])
	if grid_pos == Vector2i(-1, -1):
		return  # No space

	var world_pos := _grid_to_world(grid_pos)
	var building_node := Node2D.new()
	building_node.position = world_pos

	# Building visual
	var visual := Polygon2D.new()
	var w := data["size"].x * GRID_SIZE - 8
	var h := data["size"].y * GRID_SIZE - 8
	visual.polygon = PackedVector2Array([
		Vector2(4, 4), Vector2(w, 4),
		Vector2(w, h), Vector2(4, h),
	])
	visual.color = data["color"]
	building_node.add_child(visual)

	# Level indicator
	if level > 1:
		var lvl_label := Label.new()
		lvl_label.text = "Lv%d" % level
		lvl_label.position = Vector2(8, 4)
		lvl_label.add_theme_font_size_override("font_size", 11)
		lvl_label.add_theme_color_override("font_color", Color.WHITE)
		building_node.add_child(lvl_label)

	# Name label
	var name_label := Label.new()
	name_label.text = data["name"]
	name_label.position = Vector2(4, h - 18)
	name_label.add_theme_font_size_override("font_size", 9)
	name_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.7))
	building_node.add_child(name_label)

	add_child(building_node)
	_building_nodes[building_id] = building_node

	# Mark grid cells as occupied
	for row in data["size"].y:
		for col in data["size"].x:
			var r := grid_pos.y + row
			var c := grid_pos.x + col
			if r < GRID_ROWS and c < GRID_COLS:
				_grid[r][c] = building_id

func _find_free_grid_pos(building_size: Vector2i) -> Vector2i:
	for row in GRID_ROWS - building_size.y + 1:
		for col in GRID_COLS - building_size.x + 1:
			var fits := true
			for dr in building_size.y:
				for dc in building_size.x:
					if _grid[row + dr][col + dc] != "":
						fits = false
						break
				if not fits:
					break
			if fits:
				return Vector2i(col, row)
	return Vector2i(-1, -1)

func _load_grove_data() -> void:
	var grove_data: Dictionary = SaveManager.get_value("grove_data", {})
	for building_id in BUILDINGS:
		var level: int = grove_data.get(building_id + "_level", 0)
		if level > 0:
			# Sync with GameManager
			match building_id:
				"seed_house": GameManager.seed_house_level = level
				"lantern": GameManager.lantern_level = level
				"workshop": GameManager.workshop_level = level
			_place_building_visual(building_id, level)
