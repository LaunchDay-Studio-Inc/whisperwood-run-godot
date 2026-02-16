## MainMenu — Title screen with play, grove, settings
extends Control

var _title_label: Label = null
var _subtitle_label: Label = null
var _play_btn: Button = null
var _grove_btn: Button = null
var _settings_btn: Button = null
var _stats_label: Label = null
var _bg: ColorRect = null
var _particles_container: Node2D = null

func _ready() -> void:
	GameManager.change_state(GameManager.GameState.MENU)
	_build_ui()
	_animate_entrance()
	_spawn_floating_particles()

func _build_ui() -> void:
	# Background
	_bg = ColorRect.new()
	_bg.color = Color(0.1, 0.08, 0.15)
	_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_bg)

	# Decorative background elements
	var bg_canvas := Node2D.new()
	bg_canvas.z_index = -1
	add_child(bg_canvas)

	# Big moon
	var moon := Polygon2D.new()
	var moon_points := PackedVector2Array()
	for i in 32:
		var angle := TAU * i / 32
		moon_points.append(Vector2(cos(angle) * 80, sin(angle) * 80))
	moon.polygon = moon_points
	moon.color = Color(0.95, 0.9, 0.7, 0.15)
	moon.position = Vector2(500, 200)
	bg_canvas.add_child(moon)

	# Trees silhouette at bottom
	for i in 12:
		var tree := Polygon2D.new()
		var x := i * 70.0 - 50.0
		var h := randf_range(100, 250)
		tree.polygon = PackedVector2Array([
			Vector2(x - 15, 1280), Vector2(x, 1280 - h),
			Vector2(x + 15, 1280),
		])
		tree.color = Color(0.06, 0.05, 0.1, 0.8)
		bg_canvas.add_child(tree)

	# Particle container
	_particles_container = Node2D.new()
	add_child(_particles_container)

	# Content container
	var container := VBoxContainer.new()
	container.set_anchors_preset(Control.PRESET_CENTER)
	container.offset_left = -200
	container.offset_right = 200
	container.offset_top = -280
	container.offset_bottom = 280
	container.add_theme_constant_override("separation", 16)
	container.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(container)

	# Title
	_title_label = Label.new()
	_title_label.text = "Whisperwood\n    Run"
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_label.add_theme_font_size_override("font_size", 48)
	_title_label.add_theme_color_override("font_color", Color(1, 0.95, 0.7))
	container.add_child(_title_label)

	# Subtitle
	_subtitle_label = Label.new()
	_subtitle_label.text = "An Enchanted Endless Journey"
	_subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_subtitle_label.add_theme_font_size_override("font_size", 14)
	_subtitle_label.add_theme_color_override("font_color", Color(0.6, 0.7, 0.5))
	container.add_child(_subtitle_label)

	# Spacer
	var spacer := Control.new()
	spacer.custom_minimum_size.y = 40
	container.add_child(spacer)

	# Play button
	_play_btn = _create_main_button("Begin Run", Color(0.2, 0.5, 0.3))
	_play_btn.pressed.connect(_on_play_pressed)
	container.add_child(_play_btn)

	# Grove button
	_grove_btn = _create_main_button("Visit Grove", Color(0.3, 0.35, 0.5))
	_grove_btn.pressed.connect(_on_grove_pressed)
	container.add_child(_grove_btn)

	# Settings button
	_settings_btn = _create_main_button("Settings", Color(0.3, 0.25, 0.35))
	_settings_btn.pressed.connect(_on_settings_pressed)
	container.add_child(_settings_btn)

	# Stats
	var spacer2 := Control.new()
	spacer2.custom_minimum_size.y = 20
	container.add_child(spacer2)

	_stats_label = Label.new()
	var high_score: int = SaveManager.get_value("high_score", 0)
	var best_dist: float = SaveManager.get_value("best_distance", 0.0)
	_stats_label.text = "Best: %d pts  |  %dm  |  %d seeds" % [high_score, int(best_dist), GameManager.seeds]
	_stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_stats_label.add_theme_font_size_override("font_size", 12)
	_stats_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.45))
	container.add_child(_stats_label)

	# Version
	var version_label := Label.new()
	version_label.text = "v1.0.0"
	version_label.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	version_label.offset_left = -80
	version_label.offset_top = -30
	version_label.add_theme_font_size_override("font_size", 10)
	version_label.add_theme_color_override("font_color", Color(0.3, 0.3, 0.3))
	add_child(version_label)

func _create_main_button(text: String, base_color: Color) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(300, 56)
	btn.add_theme_font_size_override("font_size", 22)

	var style := StyleBoxFlat.new()
	style.bg_color = base_color
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = Color(base_color.r + 0.15, base_color.g + 0.15, base_color.b + 0.15, 0.6)
	style.content_margin_left = 16
	style.content_margin_right = 16
	btn.add_theme_stylebox_override("normal", style)

	var hover := style.duplicate()
	hover.bg_color = Color(base_color.r + 0.1, base_color.g + 0.1, base_color.b + 0.1)
	btn.add_theme_stylebox_override("hover", hover)

	var pressed := style.duplicate()
	pressed.bg_color = Color(base_color.r - 0.05, base_color.g - 0.05, base_color.b - 0.05)
	btn.add_theme_stylebox_override("pressed", pressed)

	return btn

func _animate_entrance() -> void:
	# Fade in title
	_title_label.modulate.a = 0.0
	_subtitle_label.modulate.a = 0.0
	_play_btn.modulate.a = 0.0
	_grove_btn.modulate.a = 0.0
	_settings_btn.modulate.a = 0.0
	_stats_label.modulate.a = 0.0

	var tw := create_tween()
	tw.set_ease(Tween.EASE_OUT)
	tw.set_trans(Tween.TRANS_CUBIC)
	tw.tween_property(_title_label, "modulate:a", 1.0, 0.6)
	tw.tween_property(_subtitle_label, "modulate:a", 1.0, 0.4)
	tw.tween_property(_play_btn, "modulate:a", 1.0, 0.3)
	tw.tween_property(_grove_btn, "modulate:a", 1.0, 0.3)
	tw.tween_property(_settings_btn, "modulate:a", 1.0, 0.3)
	tw.tween_property(_stats_label, "modulate:a", 1.0, 0.3)

func _spawn_floating_particles() -> void:
	# Floating firefly-like particles
	for i in 15:
		var particle := Polygon2D.new()
		var size := randf_range(2, 5)
		particle.polygon = PackedVector2Array([
			Vector2(-size, 0), Vector2(0, -size), Vector2(size, 0), Vector2(0, size)
		])
		particle.color = Color(0.9, 0.85, 0.4, randf_range(0.1, 0.4))
		particle.position = Vector2(randf_range(0, 720), randf_range(0, 1280))
		_particles_container.add_child(particle)

		# Animate floating
		var tw := create_tween().set_loops()
		tw.set_ease(Tween.EASE_IN_OUT)
		tw.set_trans(Tween.TRANS_SINE)
		var target := particle.position + Vector2(randf_range(-100, 100), randf_range(-100, 100))
		tw.tween_property(particle, "position", target, randf_range(3, 6))
		tw.tween_property(particle, "position", particle.position, randf_range(3, 6))

func _on_play_pressed() -> void:
	GameManager.go_to_scene("res://scenes/runner/runner.tscn")

func _on_grove_pressed() -> void:
	GameManager.go_to_scene("res://scenes/grove/grove.tscn")

func _on_settings_pressed() -> void:
	# Open settings panel
	_show_settings_popup()

func _show_settings_popup() -> void:
	var overlay := ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.5)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(overlay)

	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(400, 400)
	panel.offset_left = -200
	panel.offset_right = 200
	panel.offset_top = -200
	panel.offset_bottom = 200

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.1, 0.18, 0.98)
	style.corner_radius_top_left = 16
	style.corner_radius_top_right = 16
	style.corner_radius_bottom_left = 16
	style.corner_radius_bottom_right = 16
	style.content_margin_left = 20
	style.content_margin_right = 20
	style.content_margin_top = 20
	style.content_margin_bottom = 20
	panel.add_theme_stylebox_override("panel", style)
	overlay.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 16)

	var title := Label.new()
	title.text = "Settings"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color(1, 0.95, 0.7))
	vbox.add_child(title)

	# SFX Volume
	var sfx_label := Label.new()
	sfx_label.text = "Sound Effects"
	sfx_label.add_theme_font_size_override("font_size", 16)
	vbox.add_child(sfx_label)
	var sfx_slider := HSlider.new()
	sfx_slider.min_value = 0.0
	sfx_slider.max_value = 1.0
	sfx_slider.step = 0.05
	sfx_slider.value = AudioManager.sfx_volume
	sfx_slider.value_changed.connect(func(v): AudioManager.sfx_volume = v)
	vbox.add_child(sfx_slider)

	# Music Volume
	var music_label := Label.new()
	music_label.text = "Music"
	music_label.add_theme_font_size_override("font_size", 16)
	vbox.add_child(music_label)
	var music_slider := HSlider.new()
	music_slider.min_value = 0.0
	music_slider.max_value = 1.0
	music_slider.step = 0.05
	music_slider.value = AudioManager.music_volume
	music_slider.value_changed.connect(func(v): AudioManager.music_volume = v)
	vbox.add_child(music_slider)

	# Clear save
	var clear_btn := _create_main_button("Reset Progress", Color(0.5, 0.2, 0.2))
	clear_btn.custom_minimum_size.y = 44
	clear_btn.pressed.connect(func():
		SaveManager.clear_save()
		get_tree().reload_current_scene()
	)
	vbox.add_child(clear_btn)

	var close_btn := _create_main_button("Close", Color(0.3, 0.3, 0.35))
	close_btn.custom_minimum_size.y = 44
	close_btn.pressed.connect(func(): overlay.queue_free())
	vbox.add_child(close_btn)

	panel.add_child(vbox)
