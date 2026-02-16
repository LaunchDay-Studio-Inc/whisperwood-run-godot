## RunnerHUD — In-game UI overlay for the runner
extends CanvasLayer

signal revive_requested
signal revive_declined
signal restart_requested
signal quit_to_menu
signal double_reward_requested

# Node references (created in code)
var _score_label: Label = null
var _distance_label: Label = null
var _seeds_label: Label = null
var _powerup_indicator: HBoxContainer = null
var _pause_btn: Button = null

# Panels
var _pause_panel: PanelContainer = null
var _game_over_panel: PanelContainer = null
var _revive_panel: PanelContainer = null

var _final_score: int = 0
var _final_distance: float = 0.0
var _final_seeds: int = 0

func _ready() -> void:
	layer = 10
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_ui()
	_connect_signals()

func _connect_signals() -> void:
	EventBus.score_changed.connect(_on_score_changed)
	EventBus.distance_changed.connect(_on_distance_changed)
	EventBus.seeds_changed.connect(_on_seeds_changed)
	EventBus.powerup_collected.connect(_on_powerup_collected)
	EventBus.powerup_expired.connect(_on_powerup_expired)

func _build_ui() -> void:
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	# Top bar
	var top_bar := HBoxContainer.new()
	top_bar.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top_bar.offset_top = 40
	top_bar.offset_left = 20
	top_bar.offset_right = -20
	top_bar.offset_bottom = 100
	root.add_child(top_bar)

	# Score
	var score_vbox := VBoxContainer.new()
	_score_label = Label.new()
	_score_label.text = "0"
	_score_label.add_theme_font_size_override("font_size", 32)
	_score_label.add_theme_color_override("font_color", Color(1, 0.95, 0.7))
	var score_title := Label.new()
	score_title.text = "SCORE"
	score_title.add_theme_font_size_override("font_size", 12)
	score_title.add_theme_color_override("font_color", Color(0.7, 0.65, 0.5))
	score_vbox.add_child(score_title)
	score_vbox.add_child(_score_label)
	top_bar.add_child(score_vbox)

	# Spacer
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_bar.add_child(spacer)

	# Distance
	_distance_label = Label.new()
	_distance_label.text = "0m"
	_distance_label.add_theme_font_size_override("font_size", 20)
	_distance_label.add_theme_color_override("font_color", Color(0.8, 0.85, 0.9))
	top_bar.add_child(_distance_label)

	var spacer2 := Control.new()
	spacer2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_bar.add_child(spacer2)

	# Seeds
	var seeds_hbox := HBoxContainer.new()
	var seed_icon := Polygon2D.new()  # Placeholder
	seeds_hbox.add_theme_constant_override("separation", 4)
	_seeds_label = Label.new()
	_seeds_label.text = "0"
	_seeds_label.add_theme_font_size_override("font_size", 22)
	_seeds_label.add_theme_color_override("font_color", Color(1, 0.85, 0.2))
	var seeds_icon_label := Label.new()
	seeds_icon_label.text = "🌱"
	seeds_icon_label.add_theme_font_size_override("font_size", 20)
	seeds_hbox.add_child(seeds_icon_label)
	seeds_hbox.add_child(_seeds_label)
	top_bar.add_child(seeds_hbox)

	# Pause button
	_pause_btn = Button.new()
	_pause_btn.text = "❚❚"
	_pause_btn.custom_minimum_size = Vector2(50, 50)
	_pause_btn.pressed.connect(_on_pause_pressed)
	_pause_btn.add_theme_font_size_override("font_size", 20)
	top_bar.add_child(_pause_btn)

	# Powerup indicators
	_powerup_indicator = HBoxContainer.new()
	_powerup_indicator.position = Vector2(20, 110)
	root.add_child(_powerup_indicator)

	# Build overlay panels (hidden by default)
	_build_pause_panel(root)
	_build_game_over_panel(root)
	_build_revive_panel(root)

func _build_pause_panel(root: Control) -> void:
	_pause_panel = _create_overlay_panel("PAUSED")
	_pause_panel.visible = false
	root.add_child(_pause_panel)

	var vbox: VBoxContainer = _pause_panel.get_child(0)

	var resume_btn := _create_styled_button("Resume")
	resume_btn.pressed.connect(func():
		hide_pause_menu()
		get_parent().resume_run()
	)
	vbox.add_child(resume_btn)

	var quit_btn := _create_styled_button("Quit to Menu")
	quit_btn.pressed.connect(func():
		get_tree().paused = false
		quit_to_menu.emit()
		GameManager.go_to_scene("res://scenes/main_menu.tscn")
	)
	vbox.add_child(quit_btn)

func _build_game_over_panel(root: Control) -> void:
	_game_over_panel = _create_overlay_panel("RUN COMPLETE")
	_game_over_panel.visible = false
	root.add_child(_game_over_panel)

	var vbox: VBoxContainer = _game_over_panel.get_child(0)

	var stats_label := Label.new()
	stats_label.name = "StatsLabel"
	stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats_label.add_theme_font_size_override("font_size", 18)
	stats_label.add_theme_color_override("font_color", Color(0.85, 0.8, 0.7))
	vbox.add_child(stats_label)

	var high_score_label := Label.new()
	high_score_label.name = "HighScoreLabel"
	high_score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	high_score_label.add_theme_font_size_override("font_size", 14)
	high_score_label.add_theme_color_override("font_color", Color(1, 0.85, 0.2))
	vbox.add_child(high_score_label)

	var spacer := Control.new()
	spacer.custom_minimum_size.y = 10
	vbox.add_child(spacer)

	var double_btn := _create_styled_button("Double Rewards (Ad)")
	double_btn.name = "DoubleBtn"
	double_btn.pressed.connect(func(): double_reward_requested.emit())
	vbox.add_child(double_btn)

	var restart_btn := _create_styled_button("Run Again")
	restart_btn.pressed.connect(func():
		_game_over_panel.visible = false
		restart_requested.emit()
		GameManager.go_to_scene("res://scenes/runner/runner.tscn")
	)
	vbox.add_child(restart_btn)

	var grove_btn := _create_styled_button("Return to Grove")
	grove_btn.pressed.connect(func():
		_game_over_panel.visible = false
		GameManager.go_to_scene("res://scenes/grove/grove.tscn")
	)
	vbox.add_child(grove_btn)

	var menu_btn := _create_styled_button("Main Menu")
	menu_btn.pressed.connect(func():
		_game_over_panel.visible = false
		GameManager.go_to_scene("res://scenes/main_menu.tscn")
	)
	vbox.add_child(menu_btn)

func _build_revive_panel(root: Control) -> void:
	_revive_panel = _create_overlay_panel("CRASHED!")
	_revive_panel.visible = false
	root.add_child(_revive_panel)

	var vbox: VBoxContainer = _revive_panel.get_child(0)

	var info := Label.new()
	info.text = "Continue your run?"
	info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	info.add_theme_font_size_override("font_size", 18)
	info.add_theme_color_override("font_color", Color(0.85, 0.8, 0.7))
	vbox.add_child(info)

	var revive_btn := _create_styled_button("Revive (Watch Ad)")
	revive_btn.name = "ReviveBtn"
	revive_btn.pressed.connect(func():
		_revive_panel.visible = false
		revive_requested.emit()
	)
	vbox.add_child(revive_btn)

	# Web alternative
	var web_info := Label.new()
	web_info.name = "WebReviveInfo"
	web_info.text = "Free revive available!" if not GameManager.free_revive_used_today else "Costs 5 gems"
	web_info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	web_info.add_theme_font_size_override("font_size", 12)
	web_info.add_theme_color_override("font_color", Color(0.6, 0.6, 0.5))
	web_info.visible = GameManager.is_web
	vbox.add_child(web_info)

	var decline_btn := _create_styled_button("End Run")
	decline_btn.pressed.connect(func():
		_revive_panel.visible = false
		revive_declined.emit()
	)
	vbox.add_child(decline_btn)

func _create_overlay_panel(title_text: String) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(400, 300)
	panel.offset_left = -200
	panel.offset_right = 200
	panel.offset_top = -200
	panel.offset_bottom = 150

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.1, 0.18, 0.95)
	style.corner_radius_top_left = 16
	style.corner_radius_top_right = 16
	style.corner_radius_bottom_left = 16
	style.corner_radius_bottom_right = 16
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.4, 0.35, 0.5, 0.6)
	style.content_margin_left = 20
	style.content_margin_right = 20
	style.content_margin_top = 20
	style.content_margin_bottom = 20
	panel.add_theme_stylebox_override("panel", style)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER

	var title := Label.new()
	title.text = title_text
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color(1, 0.95, 0.7))
	vbox.add_child(title)

	panel.add_child(vbox)
	return panel

func _create_styled_button(text: String) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(250, 48)
	btn.add_theme_font_size_override("font_size", 18)

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.25, 0.2, 0.35)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.border_color = Color(0.5, 0.45, 0.6, 0.5)
	btn.add_theme_stylebox_override("normal", style)

	var hover_style := style.duplicate()
	hover_style.bg_color = Color(0.35, 0.28, 0.45)
	btn.add_theme_stylebox_override("hover", hover_style)

	var pressed_style := style.duplicate()
	pressed_style.bg_color = Color(0.2, 0.15, 0.3)
	btn.add_theme_stylebox_override("pressed", pressed_style)

	return btn

# --- Public API ---

func show_pause_menu() -> void:
	_pause_panel.visible = true

func hide_pause_menu() -> void:
	_pause_panel.visible = false

func show_revive_prompt() -> void:
	_revive_panel.visible = true
	# Update web revive info
	var web_info := _revive_panel.get_child(0).get_node_or_null("WebReviveInfo")
	if web_info:
		web_info.visible = GameManager.is_web
		if GameManager.is_web:
			if not GameManager.free_revive_used_today:
				web_info.text = "Free revive available!"
			else:
				web_info.text = "Costs 5 gems (%d available)" % GameManager.gems

func show_game_over(score: int, distance: float, seeds_count: int) -> void:
	_final_score = score
	_final_distance = distance
	_final_seeds = seeds_count
	_game_over_panel.visible = true

	var vbox := _game_over_panel.get_child(0)
	var stats: Label = vbox.get_node("StatsLabel")
	stats.text = "Score: %d\nDistance: %dm\nSeeds: %d" % [score, int(distance), seeds_count]

	var high_score_label: Label = vbox.get_node("HighScoreLabel")
	var high_score: int = SaveManager.get_value("high_score", 0)
	if score >= high_score:
		high_score_label.text = "NEW HIGH SCORE!"
	else:
		high_score_label.text = "Best: %d" % high_score

	# Hide double reward button on web if no gems
	var double_btn: Button = vbox.get_node("DoubleBtn")
	if GameManager.is_web:
		double_btn.text = "Double Rewards (3 gems)"
		double_btn.disabled = GameManager.gems < 3
	else:
		double_btn.visible = true

func _on_score_changed(new_score: int) -> void:
	if _score_label:
		_score_label.text = str(new_score)

func _on_distance_changed(new_distance: float) -> void:
	if _distance_label:
		_distance_label.text = "%dm" % int(new_distance)

func _on_seeds_changed(new_seeds: int) -> void:
	if _seeds_label:
		_seeds_label.text = str(new_seeds)

func _on_powerup_collected(type: String) -> void:
	var indicator := Label.new()
	indicator.name = "pw_" + type
	indicator.text = _get_powerup_icon(type)
	indicator.add_theme_font_size_override("font_size", 24)
	_powerup_indicator.add_child(indicator)

func _on_powerup_expired(type: String) -> void:
	var node := _powerup_indicator.get_node_or_null("pw_" + type)
	if node:
		node.queue_free()

func _get_powerup_icon(type: String) -> String:
	match type:
		"shield": return "🛡"
		"magnet": return "🧲"
		"multiplier": return "✖2"
	return "?"

func _on_pause_pressed() -> void:
	get_parent().pause_run()
	show_pause_menu()
