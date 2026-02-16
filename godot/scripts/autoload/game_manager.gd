## GameManager — Central game state and session management
extends Node

enum GameState { MENU, RUNNING, PAUSED, GAME_OVER, GROVE, LOADING }

var state: GameState = GameState.MENU
var current_run: RunData = null
var player_data: PlayerData = null
var is_web: bool = false
var is_mobile: bool = false

# Economy
var seeds: int = 0:
	set(v):
		seeds = v
		EventBus.seeds_updated.emit(seeds)
var gems: int = 0:
	set(v):
		gems = v
		EventBus.gems_updated.emit(gems)

# Progression
var total_runs: int = 0
var runs_since_interstitial: int = 0
var ads_removed: bool = false
var free_revive_used_today: bool = false
var last_daily_date: String = ""

# Upgrade levels (from Grove)
var seed_house_level: int = 0
var lantern_level: int = 0
var workshop_level: int = 0

func _ready() -> void:
	is_web = OS.has_feature("web")
	is_mobile = OS.has_feature("mobile") or OS.has_feature("android") or OS.has_feature("ios")
	process_mode = Node.PROCESS_MODE_ALWAYS
	_load_player_data()
	_check_daily_reset()

func _load_player_data() -> void:
	var data := SaveManager.load_game()
	if data:
		seeds = data.get("seeds", 0)
		gems = data.get("gems", 0)
		total_runs = data.get("total_runs", 0)
		ads_removed = data.get("ads_removed", false)
		seed_house_level = data.get("seed_house_level", 0)
		lantern_level = data.get("lantern_level", 0)
		workshop_level = data.get("workshop_level", 0)
		last_daily_date = data.get("last_daily_date", "")
		free_revive_used_today = data.get("free_revive_used_today", false)

func save_game() -> void:
	var data := {
		"seeds": seeds,
		"gems": gems,
		"total_runs": total_runs,
		"ads_removed": ads_removed,
		"seed_house_level": seed_house_level,
		"lantern_level": lantern_level,
		"workshop_level": workshop_level,
		"last_daily_date": last_daily_date,
		"free_revive_used_today": free_revive_used_today,
		"high_score": SaveManager.get_value("high_score", 0),
		"best_distance": SaveManager.get_value("best_distance", 0.0),
		"quest_data": SaveManager.get_value("quest_data", {}),
		"grove_data": SaveManager.get_value("grove_data", {}),
		"unlocked_skins": SaveManager.get_value("unlocked_skins", ["default"]),
		"selected_skin": SaveManager.get_value("selected_skin", "default"),
	}
	SaveManager.save_game(data)

func _check_daily_reset() -> void:
	var today := Time.get_date_string_from_system()
	if today != last_daily_date:
		last_daily_date = today
		free_revive_used_today = false
		runs_since_interstitial = 0
		EventBus.analytics_event.emit("daily_reset", {"date": today})
		save_game()

func change_state(new_state: GameState) -> void:
	state = new_state
	match new_state:
		GameState.RUNNING:
			EventBus.run_started.emit()
		GameState.GROVE:
			EventBus.grove_entered.emit()

func start_run() -> void:
	current_run = RunData.new()
	current_run.seed_multiplier = get_seed_multiplier()
	change_state(GameState.RUNNING)

func end_run() -> void:
	if current_run:
		total_runs += 1
		runs_since_interstitial += 1
		seeds += current_run.seeds_collected
		EventBus.run_ended.emit(current_run.score, current_run.distance, current_run.seeds_collected)
		EventBus.analytics_event.emit("run_ended", {
			"score": current_run.score,
			"distance": current_run.distance,
			"seeds": current_run.seeds_collected,
			"run_number": total_runs,
		})
		# Update high score
		var high_score: int = SaveManager.get_value("high_score", 0)
		if current_run.score > high_score:
			SaveManager.set_value("high_score", current_run.score)
		var best_dist: float = SaveManager.get_value("best_distance", 0.0)
		if current_run.distance > best_dist:
			SaveManager.set_value("best_distance", current_run.distance)
		save_game()
	change_state(GameState.GAME_OVER)

func get_seed_multiplier() -> float:
	return 1.0 + seed_house_level * 0.15

func get_available_biomes() -> Array[String]:
	var biomes: Array[String] = ["enchanted_forest"]
	if lantern_level >= 1:
		biomes.append("crystal_caverns")
	if lantern_level >= 2:
		biomes.append("starlit_meadow")
	return biomes

func has_start_shield() -> bool:
	return workshop_level >= 1

func get_magnet_bonus_duration() -> float:
	return workshop_level * 1.0  # +1s per level

func should_show_interstitial() -> bool:
	if ads_removed:
		return false
	if is_web:
		return false
	return runs_since_interstitial >= 3

func go_to_scene(scene_path: String) -> void:
	TransitionManager.transition_to(scene_path)

## RunData inner resource
class RunData:
	var score: int = 0
	var distance: float = 0.0
	var seeds_collected: int = 0
	var gems_collected: int = 0
	var seed_multiplier: float = 1.0
	var shortcuts_taken: int = 0
	var powerups_used: Array[String] = []
	var revived: bool = false

	func add_seeds(amount: int) -> void:
		seeds_collected += int(amount * seed_multiplier)

	func add_score(amount: int) -> void:
		score += amount
