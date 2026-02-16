## RunnerScene — Main runner gameplay controller
extends Node2D

@onready var player: Node2D = $Player
@onready var spawner: Node2D = $ObstacleSpawner
@onready var hud: CanvasLayer = $HUD
@onready var background: Node2D = $Background
@onready var camera: Camera2D = $Camera2D

var _score: int = 0
var _seeds: int = 0
var _distance: float = 0.0
var _is_paused: bool = false
var _is_running: bool = false
var _has_revived: bool = false

func _ready() -> void:
	_setup_scene()
	_connect_signals()
	_start_run()

func _setup_scene() -> void:
	# Show tutorial on first run
	if not SaveManager.get_value("tutorial_complete", false):
		var tutorial := preload("res://scripts/tutorial/tutorial_overlay.gd").new()
		add_child(tutorial)
	# Add light overlay for atmosphere
	var light := EffectsManager.create_light_overlay()
	add_child(light)

func _connect_signals() -> void:
	player.crashed.connect(_on_player_crashed)
	player.collected.connect(_on_player_collected)
	spawner.portal_spawn_ready.connect(_on_portal_spawn_ready)
	EventBus.portal_entered.connect(_on_portal_entered)

func _start_run() -> void:
	GameManager.start_run()
	_score = 0
	_seeds = 0
	_distance = 0.0
	_is_running = true
	_has_revived = false

	var biomes := GameManager.get_available_biomes()
	var biome: String = biomes[randi() % biomes.size()]
	spawner.start(biome)

	EventBus.score_changed.emit(_score)
	EventBus.seeds_changed.emit(_seeds)
	EventBus.distance_changed.emit(_distance)

func _process(delta: float) -> void:
	if not _is_running or _is_paused:
		return

	_distance = spawner.get_distance()
	_score += int(spawner.get_speed() * delta * 0.1 * player.score_multiplier)

	EventBus.score_changed.emit(_score)
	EventBus.distance_changed.emit(_distance)

	if GameManager.current_run:
		GameManager.current_run.score = _score
		GameManager.current_run.distance = _distance

func _on_player_crashed() -> void:
	_is_running = false
	spawner.stop()

	# Visual crash effects
	EffectsManager.spawn_crash_effect(self, player.global_position)
	TransitionManager.flash()

	if not _has_revived:
		# Show revive prompt
		hud.show_revive_prompt()
	else:
		_end_run()

func _on_player_collected(type: String, value: int) -> void:
	match type:
		"seed":
			_seeds += value
			if GameManager.current_run:
				GameManager.current_run.add_seeds(value)
			EventBus.seeds_changed.emit(_seeds)
			_score += value * 10
			# Collect burst effect
			EffectsManager.spawn_collect_burst(self, player.global_position, Color("#FFD933"))
			EffectsManager.spawn_floating_text(self, player.global_position + Vector2(0, -40), "+" + str(value), Color("#FFD933"))
		"shield":
			player.activate_shield()
			EffectsManager.spawn_collect_burst(self, player.global_position, Color("#4D9FCC"))
		"magnet":
			player.activate_magnet(5.0)
			EffectsManager.spawn_collect_burst(self, player.global_position, Color("#CC4D6E"))
		"multiplier":
			player.activate_score_multiplier(2.0, 8.0)
			EffectsManager.spawn_collect_burst(self, player.global_position, Color("#9966CC"))

func _on_portal_spawn_ready(_dist: float) -> void:
	spawner.spawn_portal_choices()

func _on_portal_entered(portal_type: String) -> void:
	if GameManager.current_run:
		GameManager.current_run.shortcuts_taken += 1
	_score += 50  # Bonus for taking a shortcut

func revive_player() -> void:
	_has_revived = true
	_is_running = true
	player.revive()
	spawner.start()
	if GameManager.current_run:
		GameManager.current_run.revived = true

func _end_run() -> void:
	if GameManager.current_run:
		GameManager.current_run.seeds_collected = _seeds
	GameManager.end_run()
	hud.show_game_over(_score, _distance, _seeds)

func pause_run() -> void:
	_is_paused = true
	spawner.pause(true)
	get_tree().paused = true

func resume_run() -> void:
	_is_paused = false
	spawner.pause(false)
	get_tree().paused = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and _is_running:
		if _is_paused:
			resume_run()
			hud.hide_pause_menu()
		else:
			pause_run()
			hud.show_pause_menu()
