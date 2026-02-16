## AudioManager — Centralized audio playback with pooling
extends Node

const MAX_SFX_PLAYERS := 8
const MUSIC_FADE_TIME := 1.0

var _sfx_pool: Array[AudioStreamPlayer] = []
var _music_player: AudioStreamPlayer = null
var _music_tween: Tween = null

var sfx_volume: float = 1.0:
	set(v):
		sfx_volume = v
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(v))
var music_volume: float = 0.7:
	set(v):
		music_volume = v
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(v))

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_buses()
	_setup_pool()

func _setup_buses() -> void:
	# Create SFX and Music buses if they don't exist
	if AudioServer.get_bus_index("SFX") == -1:
		AudioServer.add_bus()
		AudioServer.set_bus_name(AudioServer.bus_count - 1, "SFX")
	if AudioServer.get_bus_index("Music") == -1:
		AudioServer.add_bus()
		AudioServer.set_bus_name(AudioServer.bus_count - 1, "Music")

func _setup_pool() -> void:
	for i in MAX_SFX_PLAYERS:
		var player := AudioStreamPlayer.new()
		player.bus = "SFX"
		add_child(player)
		_sfx_pool.append(player)

	_music_player = AudioStreamPlayer.new()
	_music_player.bus = "Music"
	add_child(_music_player)

func play_sfx(stream: AudioStream, pitch_variance: float = 0.0) -> void:
	if not stream:
		return
	for player in _sfx_pool:
		if not player.playing:
			player.stream = stream
			if pitch_variance > 0:
				player.pitch_scale = randf_range(1.0 - pitch_variance, 1.0 + pitch_variance)
			else:
				player.pitch_scale = 1.0
			player.play()
			return
	# All busy — skip this SFX

func play_music(stream: AudioStream, fade_in: bool = true) -> void:
	if not stream:
		return
	if _music_tween:
		_music_tween.kill()

	if fade_in and _music_player.playing:
		_music_tween = create_tween()
		_music_tween.tween_property(_music_player, "volume_db", -40.0, MUSIC_FADE_TIME)
		_music_tween.tween_callback(func():
			_music_player.stream = stream
			_music_player.volume_db = -40.0
			_music_player.play()
			var tw := create_tween()
			tw.tween_property(_music_player, "volume_db", 0.0, MUSIC_FADE_TIME)
		)
	else:
		_music_player.stream = stream
		_music_player.volume_db = 0.0
		_music_player.play()

func stop_music(fade_out: bool = true) -> void:
	if _music_tween:
		_music_tween.kill()
	if fade_out:
		_music_tween = create_tween()
		_music_tween.tween_property(_music_player, "volume_db", -40.0, MUSIC_FADE_TIME)
		_music_tween.tween_callback(_music_player.stop)
	else:
		_music_player.stop()

func stop_all_sfx() -> void:
	for player in _sfx_pool:
		player.stop()

## Generate simple procedural beep/blip for placeholder SFX
static func generate_blip(freq: float = 440.0, duration: float = 0.1) -> AudioStreamWAV:
	var sample_rate := 22050
	var num_samples := int(sample_rate * duration)
	var data := PackedByteArray()
	data.resize(num_samples * 2)
	for i in num_samples:
		var t := float(i) / sample_rate
		var envelope := 1.0 - float(i) / num_samples
		var sample_val := sin(TAU * freq * t) * envelope * 0.5
		var sample_int := int(clampf(sample_val, -1.0, 1.0) * 32767)
		data[i * 2] = sample_int & 0xFF
		data[i * 2 + 1] = (sample_int >> 8) & 0xFF
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.data = data
	return stream
