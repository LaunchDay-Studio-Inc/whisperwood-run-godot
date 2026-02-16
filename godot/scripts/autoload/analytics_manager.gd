## AnalyticsManager — Privacy-respecting event logging
extends Node

var _log_file_path := "user://analytics_log.jsonl"
var _enabled: bool = true
var _remote_enabled: bool = false
var _remote_endpoint: String = ""
var _session_id: String = ""
var _event_queue: Array[Dictionary] = []

const FLUSH_INTERVAL := 30.0
const MAX_QUEUE_SIZE := 100

func _ready() -> void:
	_session_id = _generate_session_id()
	# Disable remote by default on web for privacy
	if GameManager.is_web:
		_remote_enabled = false
	EventBus.analytics_event.connect(_on_event)
	# Periodic flush
	var timer := Timer.new()
	timer.wait_time = FLUSH_INTERVAL
	timer.autostart = true
	timer.timeout.connect(_flush_queue)
	add_child(timer)

func set_remote_enabled(enabled: bool, endpoint: String = "") -> void:
	_remote_enabled = enabled
	_remote_endpoint = endpoint

func log_event(event_name: String, params: Dictionary = {}) -> void:
	if not _enabled:
		return
	var entry := {
		"event": event_name,
		"params": params,
		"timestamp": Time.get_unix_time_from_system(),
		"session": _session_id,
	}
	_event_queue.append(entry)
	if _event_queue.size() >= MAX_QUEUE_SIZE:
		_flush_queue()

func _on_event(event_name: String, params: Dictionary) -> void:
	log_event(event_name, params)

func _flush_queue() -> void:
	if _event_queue.is_empty():
		return
	# Write to local log
	var file := FileAccess.open(_log_file_path, FileAccess.READ_WRITE)
	if not file:
		file = FileAccess.open(_log_file_path, FileAccess.WRITE)
	if file:
		file.seek_end()
		for entry in _event_queue:
			file.store_line(JSON.stringify(entry))
		file.close()
	# Optional remote hook
	if _remote_enabled and _remote_endpoint != "":
		_send_remote(_event_queue.duplicate())
	_event_queue.clear()

func _send_remote(events: Array) -> void:
	var http := HTTPRequest.new()
	add_child(http)
	var body := JSON.stringify({"events": events})
	http.request(_remote_endpoint, ["Content-Type: application/json"], HTTPClient.METHOD_POST, body)
	# Clean up after request completes
	http.request_completed.connect(func(_r, _c, _h, _b): http.queue_free())

func _generate_session_id() -> String:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var parts: PackedStringArray = []
	for i in 4:
		parts.append("%04x" % rng.randi_range(0, 65535))
	return "-".join(parts)

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_WM_GO_BACK_REQUEST:
		_flush_queue()
