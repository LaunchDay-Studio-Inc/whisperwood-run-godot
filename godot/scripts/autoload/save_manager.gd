## SaveManager — Encrypted local save with checksum
extends Node

const SAVE_PATH := "user://whisperwood_save.dat"
const SAVE_KEY := "whisperwood_2026_key"  # Simple obfuscation key
const SAVE_VERSION := 1

var _cache: Dictionary = {}

func _ready() -> void:
	_cache = _load_raw()

func load_game() -> Dictionary:
	return _cache.duplicate(true)

func save_game(data: Dictionary) -> void:
	_cache = data.duplicate(true)
	_cache["_save_version"] = SAVE_VERSION
	_cache["_timestamp"] = Time.get_unix_time_from_system()
	_save_raw(_cache)

func get_value(key: String, default_value = null):
	return _cache.get(key, default_value)

func set_value(key: String, value) -> void:
	_cache[key] = value

func has_value(key: String) -> bool:
	return _cache.has(key)

func clear_save() -> void:
	_cache = {}
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)

func _save_raw(data: Dictionary) -> void:
	var json_str := JSON.stringify(data)
	var checksum := _compute_checksum(json_str)
	var payload := checksum + "|" + json_str

	# Simple XOR-based obfuscation (not true encryption, but deters trivial edits)
	var encrypted := _xor_cipher(payload)

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_buffer(encrypted)
		file.close()

func _load_raw() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {}

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return {}

	var encrypted := file.get_buffer(file.get_length())
	file.close()

	var payload := _xor_cipher(encrypted).get_string_from_utf8()
	var sep_idx := payload.find("|")
	if sep_idx < 0:
		push_warning("SaveManager: corrupt save (no separator)")
		return {}

	var stored_checksum := payload.substr(0, sep_idx)
	var json_str := payload.substr(sep_idx + 1)
	var computed_checksum := _compute_checksum(json_str)

	if stored_checksum != computed_checksum:
		push_warning("SaveManager: checksum mismatch — save may be tampered")
		# Still load, but flag it
		EventBus.analytics_event.emit("save_checksum_fail", {})

	var json := JSON.new()
	var err := json.parse(json_str)
	if err != OK:
		push_warning("SaveManager: JSON parse error")
		return {}

	if json.data is Dictionary:
		return json.data
	return {}

func _compute_checksum(text: String) -> String:
	return text.md5_text()

func _xor_cipher(data: PackedByteArray) -> PackedByteArray:
	var key_bytes := SAVE_KEY.to_utf8_buffer()
	var result := PackedByteArray()
	result.resize(data.size())
	for i in range(data.size()):
		result[i] = data[i] ^ key_bytes[i % key_bytes.size()]
	return result

# Overload for string input
func _xor_cipher_str(text: String) -> PackedByteArray:
	return _xor_cipher(text.to_utf8_buffer())
