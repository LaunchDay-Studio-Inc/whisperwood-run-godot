## QuestManager — Tracks quest progress and daily resets
extends Node

const QUESTS := {
	# Beginner (persistent)
	"beg_run_100": {"type": "total_distance", "target": 100},
	"beg_seeds_50": {"type": "total_seeds", "target": 50},
	"beg_runs_5": {"type": "total_runs", "target": 5},
	# Daily (reset each day)
	"daily_run_200": {"type": "single_distance", "target": 200, "daily": true},
	"daily_seeds_20": {"type": "daily_seeds", "target": 20, "daily": true},
	"daily_shortcut": {"type": "shortcuts", "target": 1, "daily": true},
}

var _quest_data: Dictionary = {}

func _ready() -> void:
	_quest_data = SaveManager.get_value("quest_data", {})
	EventBus.run_ended.connect(_on_run_ended)
	EventBus.portal_entered.connect(_on_shortcut_taken)

func _on_run_ended(score: int, distance: float, seeds: int) -> void:
	_update_quest("beg_run_100", int(distance))
	_update_quest("beg_seeds_50", seeds)
	_update_quest("beg_runs_5", 1)
	_update_quest("daily_run_200", int(distance))
	_update_quest("daily_seeds_20", seeds)
	_save()

func _on_shortcut_taken(_type: String) -> void:
	_update_quest("daily_shortcut", 1)
	_save()

func _update_quest(quest_id: String, value: int) -> void:
	if not QUESTS.has(quest_id):
		return
	if _quest_data.get(quest_id + "_completed", false):
		return

	var current: int = _quest_data.get(quest_id + "_progress", 0)
	var quest_info: Dictionary = QUESTS[quest_id]

	match quest_info["type"]:
		"total_distance", "total_seeds", "total_runs":
			current += value
		"single_distance":
			current = max(current, value)  # Best single run
		"daily_seeds":
			current += value
		"shortcuts":
			current += value

	_quest_data[quest_id + "_progress"] = current
	var target: int = quest_info["target"]
	EventBus.quest_progress.emit(quest_id, min(current, target), target)

func _save() -> void:
	SaveManager.set_value("quest_data", _quest_data)
	GameManager.save_game()

func check_daily_reset() -> void:
	var today := Time.get_date_string_from_system()
	var last_date: String = _quest_data.get("_last_daily_date", "")
	if today != last_date:
		# Reset daily quests
		for quest_id in QUESTS:
			var info: Dictionary = QUESTS[quest_id]
			if info.get("daily", false):
				_quest_data[quest_id + "_progress"] = 0
				_quest_data[quest_id + "_completed"] = false
		_quest_data["_last_daily_date"] = today
		_save()
