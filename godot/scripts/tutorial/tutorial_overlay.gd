## TutorialOverlay — Quick 30-second onboarding
extends CanvasLayer

signal tutorial_completed

var _step: int = 0
var _overlay: ColorRect = null
var _instruction_label: Label = null
var _arrow: Polygon2D = null
var _tap_label: Label = null
var _completed: bool = false

const STEPS := [
	{
		"text": "Swipe LEFT or RIGHT\nto change lanes",
		"arrow_dir": "horizontal",
		"duration": 4.0,
	},
	{
		"text": "Swipe UP to JUMP\nover obstacles",
		"arrow_dir": "up",
		"duration": 4.0,
	},
	{
		"text": "Swipe DOWN to SLIDE\nunder barriers",
		"arrow_dir": "down",
		"duration": 3.5,
	},
	{
		"text": "Collect golden seeds\nto build your Grove!",
		"arrow_dir": "none",
		"duration": 3.0,
	},
	{
		"text": "Watch for power-ups:\n🛡 Shield  🧲 Magnet  ✖2 Score",
		"arrow_dir": "none",
		"duration": 4.0,
	},
]

func _ready() -> void:
	layer = 20
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Check if tutorial already done
	if SaveManager.get_value("tutorial_completed", false):
		_completed = true
		queue_free()
		return

	_build_overlay()
	_show_step(0)

func _build_overlay() -> void:
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	_overlay = ColorRect.new()
	_overlay.color = Color(0, 0, 0, 0.5)
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(_overlay)

	_instruction_label = Label.new()
	_instruction_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_instruction_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_instruction_label.set_anchors_preset(Control.PRESET_CENTER)
	_instruction_label.offset_left = -200
	_instruction_label.offset_right = 200
	_instruction_label.offset_top = -80
	_instruction_label.offset_bottom = 20
	_instruction_label.add_theme_font_size_override("font_size", 26)
	_instruction_label.add_theme_color_override("font_color", Color(1, 0.95, 0.7))
	root.add_child(_instruction_label)

	_tap_label = Label.new()
	_tap_label.text = "Tap to continue"
	_tap_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_tap_label.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_tap_label.offset_top = -60
	_tap_label.offset_bottom = -30
	_tap_label.offset_left = -100
	_tap_label.offset_right = 100
	_tap_label.add_theme_font_size_override("font_size", 14)
	_tap_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.5))
	root.add_child(_tap_label)

	# Pulsing tap label
	var tw := create_tween().set_loops()
	tw.tween_property(_tap_label, "modulate:a", 0.3, 0.8)
	tw.tween_property(_tap_label, "modulate:a", 1.0, 0.8)

	# Arrow indicator
	_arrow = Polygon2D.new()
	_arrow.polygon = PackedVector2Array([
		Vector2(0, -20), Vector2(15, 10), Vector2(-15, 10)
	])
	_arrow.color = Color(1, 0.9, 0.4, 0.8)
	_arrow.position = Vector2(360, 800)
	_arrow.visible = false
	root.add_child(_arrow)

func _show_step(step_idx: int) -> void:
	if step_idx >= STEPS.size():
		_complete_tutorial()
		return

	_step = step_idx
	var step_data: Dictionary = STEPS[step_idx]
	_instruction_label.text = step_data["text"]

	# Animate in
	_instruction_label.modulate.a = 0
	var tw := create_tween()
	tw.tween_property(_instruction_label, "modulate:a", 1.0, 0.3)

	# Arrow
	_arrow.visible = step_data["arrow_dir"] != "none"
	match step_data["arrow_dir"]:
		"horizontal":
			_arrow.rotation = PI / 2
			_arrow.position = Vector2(360, 950)
			var atw := create_tween().set_loops(3)
			atw.tween_property(_arrow, "position:x", 260, 0.5)
			atw.tween_property(_arrow, "position:x", 460, 0.5)
		"up":
			_arrow.rotation = 0
			_arrow.position = Vector2(360, 850)
			var atw := create_tween().set_loops(3)
			atw.tween_property(_arrow, "position:y", 800, 0.4)
			atw.tween_property(_arrow, "position:y", 850, 0.4)
		"down":
			_arrow.rotation = PI
			_arrow.position = Vector2(360, 850)
			var atw := create_tween().set_loops(3)
			atw.tween_property(_arrow, "position:y", 900, 0.4)
			atw.tween_property(_arrow, "position:y", 850, 0.4)

func _unhandled_input(event: InputEvent) -> void:
	if _completed:
		return
	if event is InputEventScreenTouch and event.pressed:
		_advance()
	elif event is InputEventMouseButton and event.pressed:
		_advance()
	elif event is InputEventKey and event.pressed:
		_advance()

func _advance() -> void:
	_show_step(_step + 1)

func _complete_tutorial() -> void:
	_completed = true
	SaveManager.set_value("tutorial_completed", true)
	GameManager.save_game()
	tutorial_completed.emit()

	# Fade out
	var tw := create_tween()
	tw.tween_property(_overlay, "modulate:a", 0.0, 0.3)
	tw.tween_callback(queue_free)
