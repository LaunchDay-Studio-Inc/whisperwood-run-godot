## ObstacleSpawner — Procedural obstacle and collectible generation
## Difficulty scales with distance traveled
extends Node2D

signal portal_spawn_ready(distance: float)

# Spawn configuration
const SPAWN_INTERVAL_BASE := 0.8
const SPAWN_INTERVAL_MIN := 0.35
const COLLECTIBLE_CHANCE := 0.4
const POWERUP_CHANCE := 0.08
const PORTAL_DISTANCE_INTERVAL := 500.0

# Difficulty
var difficulty_level: int = 0
var _distance: float = 0.0
var _last_portal_distance: float = 0.0
var _spawn_timer: float = 0.0
var _speed: float = 400.0

# Pool
var _obstacle_pool: Array[Node2D] = []
var _collectible_pool: Array[Node2D] = []
const POOL_SIZE := 20
const SPAWN_Y := -200.0
const DESPAWN_Y := 1400.0

# Lane config (must match PlayerRunner)
const LANE_COUNT := 3
const LANE_WIDTH := 160.0

# Difficulty thresholds
const DIFFICULTY_TABLE := [
	{"distance": 0, "speed": 400, "interval": 0.8, "moving_chance": 0.0, "double_chance": 0.0},
	{"distance": 200, "speed": 460, "interval": 0.7, "moving_chance": 0.1, "double_chance": 0.1},
	{"distance": 500, "speed": 520, "interval": 0.6, "moving_chance": 0.2, "double_chance": 0.2},
	{"distance": 1000, "speed": 580, "interval": 0.5, "moving_chance": 0.3, "double_chance": 0.3},
	{"distance": 2000, "speed": 640, "interval": 0.45, "moving_chance": 0.35, "double_chance": 0.35},
	{"distance": 3500, "speed": 700, "interval": 0.4, "moving_chance": 0.4, "double_chance": 0.4},
	{"distance": 5000, "speed": 740, "interval": 0.38, "moving_chance": 0.45, "double_chance": 0.45},
]

var _biome: String = "enchanted_forest"
var _active_objects: Array[Node2D] = []
var _paused: bool = false
var _running: bool = false

func _ready() -> void:
	_pre_warm_pools()

func start(biome: String = "enchanted_forest") -> void:
	_biome = biome
	_distance = 0.0
	_last_portal_distance = 0.0
	_spawn_timer = 0.0
	difficulty_level = 0
	_speed = DIFFICULTY_TABLE[0]["speed"]
	_running = true
	_clear_active()

func stop() -> void:
	_running = false

func pause(p: bool) -> void:
	_paused = p

func get_distance() -> float:
	return _distance

func get_speed() -> float:
	return _speed

func _process(delta: float) -> void:
	if not _running or _paused:
		return

	_distance += _speed * delta * 0.01  # Convert to "meters"
	_update_difficulty()
	_spawn_timer -= delta

	if _spawn_timer <= 0:
		_spawn_row()
		_spawn_timer = _get_spawn_interval()

	_move_active_objects(delta)
	_check_portal_spawn()

func _update_difficulty() -> void:
	var new_level := 0
	for i in range(DIFFICULTY_TABLE.size() - 1, -1, -1):
		if _distance >= DIFFICULTY_TABLE[i]["distance"]:
			new_level = i
			break
	if new_level != difficulty_level:
		difficulty_level = new_level
		_speed = DIFFICULTY_TABLE[difficulty_level]["speed"]
		EventBus.difficulty_changed.emit(difficulty_level)

func _get_spawn_interval() -> float:
	return DIFFICULTY_TABLE[difficulty_level]["interval"]

func _spawn_row() -> void:
	var roll := randf()

	if roll < COLLECTIBLE_CHANCE:
		_spawn_collectible_row()
	elif roll < COLLECTIBLE_CHANCE + POWERUP_CHANCE:
		_spawn_powerup()
	else:
		_spawn_obstacle_row()

func _spawn_obstacle_row() -> void:
	var diff_data: Dictionary = DIFFICULTY_TABLE[difficulty_level]
	var lanes_blocked: Array[int] = []

	# Always leave at least 1 lane open
	var num_obstacles := 1
	if randf() < diff_data["double_chance"]:
		num_obstacles = 2

	var available_lanes := range(LANE_COUNT) as Array
	available_lanes.shuffle()

	for i in num_obstacles:
		if i >= available_lanes.size():
			break
		var lane: int = available_lanes[i]
		var is_moving := randf() < diff_data["moving_chance"]
		_spawn_obstacle(lane, is_moving)
		lanes_blocked.append(lane)

	# Optionally place a seed in the open lane
	if lanes_blocked.size() < LANE_COUNT and randf() < 0.5:
		for lane in range(LANE_COUNT):
			if lane not in lanes_blocked:
				_spawn_seed(lane)
				break

func _spawn_collectible_row() -> void:
	var lane := randi_range(0, LANE_COUNT - 1)
	# Spawn a line of seeds
	for i in range(randi_range(2, 5)):
		var seed_obj := _create_seed()
		seed_obj.position = Vector2(_get_lane_x(lane), SPAWN_Y - i * 60)
		add_child(seed_obj)
		_active_objects.append(seed_obj)

func _spawn_powerup() -> void:
	var lane := randi_range(0, LANE_COUNT - 1)
	var types := ["shield", "magnet", "multiplier"]
	var powerup_type: String = types[randi_range(0, types.size() - 1)]
	var powerup := _create_powerup(powerup_type)
	powerup.position = Vector2(_get_lane_x(lane), SPAWN_Y)
	add_child(powerup)
	_active_objects.append(powerup)

func _spawn_obstacle(lane: int, is_moving: bool) -> void:
	var obstacle := _create_obstacle(is_moving)
	obstacle.position = Vector2(_get_lane_x(lane), SPAWN_Y)
	add_child(obstacle)
	_active_objects.append(obstacle)

func _spawn_seed(lane: int) -> void:
	var seed_obj := _create_seed()
	seed_obj.position = Vector2(_get_lane_x(lane), SPAWN_Y)
	add_child(seed_obj)
	_active_objects.append(seed_obj)

func _move_active_objects(delta: float) -> void:
	var to_remove: Array[Node2D] = []
	for obj in _active_objects:
		if is_instance_valid(obj) and obj.is_inside_tree():
			obj.position.y += _speed * delta
			if obj.position.y > DESPAWN_Y:
				to_remove.append(obj)
		else:
			to_remove.append(obj)

	for obj in to_remove:
		_active_objects.erase(obj)
		if is_instance_valid(obj):
			obj.queue_free()

func _check_portal_spawn() -> void:
	if _distance - _last_portal_distance >= PORTAL_DISTANCE_INTERVAL:
		_last_portal_distance = _distance
		portal_spawn_ready.emit(_distance)

func _get_lane_x(lane: int) -> float:
	var center_offset := (LANE_COUNT - 1) / 2.0
	return (lane - center_offset) * LANE_WIDTH

func _clear_active() -> void:
	for obj in _active_objects:
		if is_instance_valid(obj):
			obj.queue_free()
	_active_objects.clear()

func _pre_warm_pools() -> void:
	pass  # Pools managed via instantiation for simplicity

# --- Factory methods for game objects ---

func _create_obstacle(is_moving: bool = false) -> Node2D:
	var obj := Node2D.new()
	obj.add_to_group("obstacles")

	# Visual — rock/log placeholder
	var visual := Polygon2D.new()
	if randf() < 0.5:
		# Rock shape
		visual.polygon = PackedVector2Array([
			Vector2(-25, 15), Vector2(-20, -15), Vector2(-5, -25),
			Vector2(10, -20), Vector2(25, -10), Vector2(22, 15),
		])
		visual.color = Color(0.45, 0.35, 0.3)
	else:
		# Log shape
		visual.polygon = PackedVector2Array([
			Vector2(-30, -10), Vector2(30, -10),
			Vector2(32, 0), Vector2(30, 10),
			Vector2(-30, 10), Vector2(-32, 0),
		])
		visual.color = Color(0.5, 0.35, 0.2)
	obj.add_child(visual)

	# Collision
	var area := Area2D.new()
	area.collision_layer = 2  # obstacles
	area.collision_mask = 0
	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(50, 30)
	col.shape = shape
	area.add_child(col)
	obj.add_child(area)

	# Moving behavior
	if is_moving:
		var mover := Node.new()
		mover.set_script(_create_mover_script())
		obj.add_child(mover)

	return obj

func _create_seed() -> Node2D:
	var obj := Node2D.new()
	obj.add_to_group("collectibles")

	# Visual — glowing seed
	var visual := Polygon2D.new()
	visual.polygon = _make_diamond(10)
	visual.color = Color(1.0, 0.85, 0.2)  # Golden
	obj.add_child(visual)

	# Glow
	var glow := Polygon2D.new()
	glow.polygon = _make_diamond(14)
	glow.color = Color(1.0, 0.9, 0.3, 0.3)
	obj.add_child(glow)

	# Collision
	var area := Area2D.new()
	area.collision_layer = 4  # collectibles
	area.collision_mask = 0
	var col := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 15
	col.shape = shape
	area.add_child(col)
	obj.add_child(area)

	# Script for collect behavior
	obj.set_meta("type", "seed")
	obj.set_meta("value", 1)
	var script := GDScript.new()
	script.source_code = """extends Node2D
func collect() -> Dictionary:
	var data := {"type": get_meta("type", "seed"), "value": get_meta("value", 1)}
	queue_free()
	return data
func attract_to(target_pos: Vector2, delta: float) -> void:
	global_position = global_position.lerp(target_pos, 8.0 * delta)
"""
	script.reload()
	obj.set_script(script)

	return obj

func _create_powerup(type: String) -> Node2D:
	var obj := Node2D.new()
	obj.add_to_group("collectibles")

	var color := Color.WHITE
	match type:
		"shield": color = Color(0.3, 0.6, 1.0)
		"magnet": color = Color(1.0, 0.3, 0.5)
		"multiplier": color = Color(0.9, 0.5, 1.0)

	# Visual — star shape
	var visual := Polygon2D.new()
	visual.polygon = _make_star(16, 8, 5)
	visual.color = color
	obj.add_child(visual)

	var glow := Polygon2D.new()
	glow.polygon = _make_star(20, 10, 5)
	glow.color = Color(color, 0.3)
	obj.add_child(glow)

	# Collision
	var area := Area2D.new()
	area.collision_layer = 4  # collectibles
	area.collision_mask = 0
	var col := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 20
	col.shape = shape
	area.add_child(col)
	obj.add_child(area)

	obj.set_meta("type", type)
	obj.set_meta("value", 1)
	var script := GDScript.new()
	script.source_code = """extends Node2D
func collect() -> Dictionary:
	var data := {"type": get_meta("type", "powerup"), "value": get_meta("value", 1)}
	queue_free()
	return data
func attract_to(target_pos: Vector2, delta: float) -> void:
	global_position = global_position.lerp(target_pos, 8.0 * delta)
"""
	script.reload()
	obj.set_script(script)

	return obj

func _make_diamond(size: float) -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(0, -size), Vector2(size * 0.6, 0),
		Vector2(0, size), Vector2(-size * 0.6, 0),
	])

func _make_star(outer: float, inner: float, points: int) -> PackedVector2Array:
	var verts := PackedVector2Array()
	for i in points * 2:
		var angle: float = TAU * i / (points * 2) - PI / 2
		var r: float = outer if i % 2 == 0 else inner
		verts.append(Vector2(cos(angle) * r, sin(angle) * r))
	return verts

func _create_mover_script() -> GDScript:
	var script := GDScript.new()
	script.source_code = """extends Node
var _time: float = 0.0
var _amplitude: float = 80.0
var _frequency: float = 2.0
func _ready() -> void:
	_amplitude = randf_range(60, 120)
	_frequency = randf_range(1.5, 3.0)
func _process(delta: float) -> void:
	_time += delta
	if get_parent():
		get_parent().position.x += cos(_time * _frequency) * _amplitude * delta
"""
	script.reload()
	return script

# --- Portal factory ---
func create_portal_choice(lane: int, portal_type: String) -> Node2D:
	var obj := Node2D.new()
	obj.add_to_group("portals")

	var color := Color(0.4, 0.2, 0.8, 0.8)
	match portal_type:
		"safe": color = Color(0.2, 0.7, 0.4, 0.8)
		"risky": color = Color(0.8, 0.3, 0.2, 0.8)
		"mystery": color = Color(0.6, 0.4, 0.9, 0.8)

	# Portal ring visual
	var ring := Polygon2D.new()
	var ring_points := PackedVector2Array()
	for i in 24:
		var angle := TAU * i / 24
		ring_points.append(Vector2(cos(angle) * 30, sin(angle) * 20))
	ring.polygon = ring_points
	ring.color = color
	obj.add_child(ring)

	# Inner glow
	var inner := Polygon2D.new()
	var inner_points := PackedVector2Array()
	for i in 24:
		var angle := TAU * i / 24
		inner_points.append(Vector2(cos(angle) * 22, sin(angle) * 14))
	inner.polygon = inner_points
	inner.color = Color(color, 0.4)
	obj.add_child(inner)

	# Collision
	var area := Area2D.new()
	area.collision_layer = 8  # portals
	area.collision_mask = 0
	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(60, 40)
	col.shape = shape
	area.add_child(col)
	obj.add_child(area)

	obj.set_meta("portal_type", portal_type)
	var script := GDScript.new()
	script.source_code = """extends Node2D
signal portal_entered(portal_type: String)
func enter() -> void:
	portal_entered.emit(get_meta("portal_type", "safe"))
	queue_free()
"""
	script.reload()
	obj.set_script(script)

	obj.position = Vector2(_get_lane_x(lane), SPAWN_Y)
	add_child(obj)
	_active_objects.append(obj)

	return obj

func spawn_portal_choices() -> void:
	var types := ["safe", "risky", "mystery"]
	types.shuffle()
	for i in LANE_COUNT:
		var portal := create_portal_choice(i, types[i])
		portal.portal_entered.connect(_on_portal_entered)

func _on_portal_entered(portal_type: String) -> void:
	EventBus.portal_entered.emit(portal_type)
	match portal_type:
		"safe":
			pass  # Normal reward
		"risky":
			_speed *= 1.3  # Speed boost, more rewards
		"mystery":
			if randf() < 0.5:
				_speed *= 1.2
			else:
				_speed *= 0.8  # Slow down = easier
