## PlayerRunner — The player character in the runner scene
## Uses a finite state machine for movement states
extends Node2D

enum PlayerState { RUNNING, JUMPING, SLIDING, CRASHING, DEAD, INVULNERABLE }

signal crashed
signal collected(type: String, value: int)

# Lane configuration
const LANE_COUNT := 3
const LANE_WIDTH := 160.0
var current_lane: int = 1  # 0=left, 1=center, 2=right
var target_x: float = 0.0

# State machine
var state: PlayerState = PlayerState.RUNNING
var _state_timer: float = 0.0

# Movement
const LANE_SWITCH_SPEED := 12.0
const JUMP_DURATION := 0.6
const SLIDE_DURATION := 0.5
const INVULNERABLE_DURATION := 2.5
const CRASH_DURATION := 0.5

# Powerup state
var has_shield: bool = false
var has_magnet: bool = false
var magnet_radius: float = 200.0
var score_multiplier: float = 1.0

# Visual nodes
var _sprite: Polygon2D = null
var _collision_shape: Area2D = null
var _collision_rect: CollisionShape2D = null
var _magnet_area: Area2D = null
var _trail_particles: GPUParticles2D = null
var _blink_timer: float = 0.0

# Swipe input
var _swipe_detector: Node = null

# Placeholder SFX
var _sfx_jump: AudioStream = null
var _sfx_collect: AudioStream = null
var _sfx_crash: AudioStream = null
var _sfx_shield: AudioStream = null

func _ready() -> void:
	_create_placeholder_visuals()
	_create_collision()
	_create_magnet_area()
	_setup_input()
	_generate_sfx()
	target_x = _get_lane_x(current_lane)
	position.x = target_x

	# Start shield from workshop upgrade
	if GameManager.has_start_shield():
		activate_shield()

func _create_placeholder_visuals() -> void:
	# Main body — a rounded rectangle character placeholder
	_sprite = Polygon2D.new()
	_sprite.polygon = PackedVector2Array([
		Vector2(-20, -40), Vector2(20, -40),
		Vector2(24, -36), Vector2(24, 30),
		Vector2(20, 36), Vector2(-20, 36),
		Vector2(-24, 30), Vector2(-24, -36),
	])
	_sprite.color = Color(0.3, 0.85, 0.5)  # Forest green character
	add_child(_sprite)

	# Eyes
	var left_eye := Polygon2D.new()
	left_eye.polygon = _make_circle(4, 6)
	left_eye.position = Vector2(-8, -22)
	left_eye.color = Color.WHITE
	_sprite.add_child(left_eye)

	var right_eye := Polygon2D.new()
	right_eye.polygon = _make_circle(4, 6)
	right_eye.position = Vector2(8, -22)
	right_eye.color = Color.WHITE
	_sprite.add_child(right_eye)

	# Pupils
	var left_pupil := Polygon2D.new()
	left_pupil.polygon = _make_circle(2, 6)
	left_pupil.position = Vector2(-7, -23)
	left_pupil.color = Color(0.1, 0.1, 0.15)
	_sprite.add_child(left_pupil)

	var right_pupil := Polygon2D.new()
	right_pupil.polygon = _make_circle(2, 6)
	right_pupil.position = Vector2(9, -23)
	right_pupil.color = Color(0.1, 0.1, 0.15)
	_sprite.add_child(right_pupil)

func _make_circle(radius: float, segments: int = 12) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i in segments:
		var angle := TAU * i / segments
		points.append(Vector2(cos(angle) * radius, sin(angle) * radius))
	return points

func _create_collision() -> void:
	_collision_shape = Area2D.new()
	_collision_shape.collision_layer = 1  # player
	_collision_shape.collision_mask = 6   # obstacles (2) + collectibles (4)
	add_child(_collision_shape)

	_collision_rect = CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(40, 70)
	_collision_rect.shape = shape
	_collision_rect.position = Vector2(0, -2)
	_collision_shape.add_child(_collision_rect)

	_collision_shape.area_entered.connect(_on_area_entered)

func _create_magnet_area() -> void:
	_magnet_area = Area2D.new()
	_magnet_area.collision_layer = 0
	_magnet_area.collision_mask = 4  # collectibles
	_magnet_area.monitoring = false
	add_child(_magnet_area)

	var magnet_shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = magnet_radius
	magnet_shape.shape = circle
	_magnet_area.add_child(magnet_shape)

func _setup_input() -> void:
	var SwipeDetectorScript = load("res://scripts/runner/swipe_detector.gd")
	_swipe_detector = Node.new()
	_swipe_detector.set_script(SwipeDetectorScript)
	add_child(_swipe_detector)
	_swipe_detector.swiped_left.connect(_on_swipe_left)
	_swipe_detector.swiped_right.connect(_on_swipe_right)
	_swipe_detector.swiped_up.connect(_on_swipe_up)
	_swipe_detector.swiped_down.connect(_on_swipe_down)

func _generate_sfx() -> void:
	_sfx_jump = AudioManager.generate_blip(520.0, 0.15)
	_sfx_collect = AudioManager.generate_blip(880.0, 0.08)
	_sfx_crash = AudioManager.generate_blip(150.0, 0.3)
	_sfx_shield = AudioManager.generate_blip(660.0, 0.2)

func _process(delta: float) -> void:
	if state == PlayerState.DEAD:
		return

	_update_state(delta)
	_update_position(delta)
	_update_visuals(delta)
	_update_magnet(delta)
	_handle_keyboard_input()

func _handle_keyboard_input() -> void:
	if state == PlayerState.CRASHING or state == PlayerState.DEAD:
		return
	if Input.is_action_just_pressed("move_left"):
		_on_swipe_left()
	if Input.is_action_just_pressed("move_right"):
		_on_swipe_right()
	if Input.is_action_just_pressed("jump"):
		_on_swipe_up()
	if Input.is_action_just_pressed("slide"):
		_on_swipe_down()

func _update_state(delta: float) -> void:
	_state_timer -= delta
	match state:
		PlayerState.JUMPING:
			if _state_timer <= 0:
				_set_state(PlayerState.RUNNING)
		PlayerState.SLIDING:
			if _state_timer <= 0:
				_set_state(PlayerState.RUNNING)
		PlayerState.CRASHING:
			if _state_timer <= 0:
				_set_state(PlayerState.DEAD)
		PlayerState.INVULNERABLE:
			if _state_timer <= 0:
				_set_state(PlayerState.RUNNING)

func _update_position(delta: float) -> void:
	target_x = _get_lane_x(current_lane)
	position.x = lerpf(position.x, target_x, LANE_SWITCH_SPEED * delta)

	# Jump arc
	if state == PlayerState.JUMPING:
		var progress := 1.0 - (_state_timer / JUMP_DURATION)
		var arc := sin(progress * PI) * 80.0
		_sprite.position.y = -arc
	else:
		_sprite.position.y = lerpf(_sprite.position.y, 0.0, 10.0 * delta)

func _update_visuals(delta: float) -> void:
	# Slide squash
	if state == PlayerState.SLIDING:
		_sprite.scale = _sprite.scale.lerp(Vector2(1.3, 0.5), 10.0 * delta)
		_sprite.position.y = lerpf(_sprite.position.y, 18.0, 10.0 * delta)
	elif state != PlayerState.JUMPING:
		_sprite.scale = _sprite.scale.lerp(Vector2(1.0, 1.0), 10.0 * delta)

	# Invulnerability blink
	if state == PlayerState.INVULNERABLE:
		_blink_timer += delta * 12.0
		_sprite.modulate.a = 0.5 + sin(_blink_timer * PI) * 0.5
	elif has_shield:
		_sprite.modulate = Color(0.5, 0.8, 1.0, 1.0)  # Blue tint for shield
	else:
		_sprite.modulate = Color.WHITE

	# Crash spin
	if state == PlayerState.CRASHING:
		_sprite.rotation += delta * 8.0

	# Running bob
	if state == PlayerState.RUNNING:
		_sprite.position.y = sin(Time.get_ticks_msec() * 0.008) * 3.0

func _update_magnet(delta: float) -> void:
	_magnet_area.monitoring = has_magnet
	if has_magnet:
		var overlapping := _magnet_area.get_overlapping_areas()
		for area in overlapping:
			var parent := area.get_parent()
			if parent.has_method("attract_to"):
				parent.attract_to(global_position, delta)

func _set_state(new_state: PlayerState) -> void:
	state = new_state
	match new_state:
		PlayerState.JUMPING:
			_state_timer = JUMP_DURATION
			_collision_rect.shape.size.y = 35  # Smaller hitbox while jumping
			AudioManager.play_sfx(_sfx_jump, 0.1)
		PlayerState.SLIDING:
			_state_timer = SLIDE_DURATION
			_collision_rect.shape.size.y = 35
			_collision_rect.position.y = 15
		PlayerState.RUNNING:
			_collision_rect.shape.size.y = 70
			_collision_rect.position.y = -2
			_sprite.rotation = 0.0
		PlayerState.CRASHING:
			_state_timer = CRASH_DURATION
			AudioManager.play_sfx(_sfx_crash)
		PlayerState.INVULNERABLE:
			_state_timer = INVULNERABLE_DURATION
			_blink_timer = 0.0
			_collision_rect.shape.size.y = 70
			_collision_rect.position.y = -2
		PlayerState.DEAD:
			crashed.emit()

func _get_lane_x(lane: int) -> float:
	# Center the lanes around 0
	var center_offset := (LANE_COUNT - 1) / 2.0
	return (lane - center_offset) * LANE_WIDTH

func _on_swipe_left() -> void:
	if state == PlayerState.CRASHING or state == PlayerState.DEAD:
		return
	if current_lane > 0:
		current_lane -= 1
		EventBus.lane_changed.emit(current_lane)

func _on_swipe_right() -> void:
	if state == PlayerState.CRASHING or state == PlayerState.DEAD:
		return
	if current_lane < LANE_COUNT - 1:
		current_lane += 1
		EventBus.lane_changed.emit(current_lane)

func _on_swipe_up() -> void:
	if state == PlayerState.RUNNING or state == PlayerState.INVULNERABLE:
		_set_state(PlayerState.JUMPING)

func _on_swipe_down() -> void:
	if state == PlayerState.RUNNING or state == PlayerState.INVULNERABLE:
		_set_state(PlayerState.SLIDING)

func _on_area_entered(area: Area2D) -> void:
	var parent := area.get_parent()
	if parent.is_in_group("obstacles"):
		_handle_obstacle_hit()
	elif parent.is_in_group("collectibles"):
		_handle_collectible(parent)
	elif parent.is_in_group("portals"):
		_handle_portal(parent)

func _handle_obstacle_hit() -> void:
	if state == PlayerState.INVULNERABLE or state == PlayerState.CRASHING or state == PlayerState.DEAD:
		return
	if has_shield:
		has_shield = false
		AudioManager.play_sfx(_sfx_shield)
		_set_state(PlayerState.INVULNERABLE)
		EventBus.powerup_expired.emit("shield")
		return
	_set_state(PlayerState.CRASHING)

func _handle_collectible(collectible: Node2D) -> void:
	if collectible.has_method("collect"):
		var data: Dictionary = collectible.collect()
		collected.emit(data.get("type", "seed"), data.get("value", 1))
		AudioManager.play_sfx(_sfx_collect, 0.15)

func _handle_portal(portal: Node2D) -> void:
	if portal.has_method("enter"):
		portal.enter()

func activate_shield() -> void:
	has_shield = true
	EventBus.powerup_collected.emit("shield")
	AudioManager.play_sfx(_sfx_shield)

func activate_magnet(duration: float) -> void:
	has_magnet = true
	var bonus := GameManager.get_magnet_bonus_duration()
	EventBus.powerup_collected.emit("magnet")
	await get_tree().create_timer(duration + bonus).timeout
	has_magnet = false
	EventBus.powerup_expired.emit("magnet")

func activate_score_multiplier(multiplier: float, duration: float) -> void:
	score_multiplier = multiplier
	EventBus.powerup_collected.emit("multiplier")
	await get_tree().create_timer(duration).timeout
	score_multiplier = 1.0
	EventBus.powerup_expired.emit("multiplier")

func revive() -> void:
	_set_state(PlayerState.INVULNERABLE)
	activate_shield()
	position.x = _get_lane_x(1)
	current_lane = 1
	_sprite.rotation = 0.0
