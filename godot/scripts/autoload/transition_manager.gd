## TransitionManager — Scene transitions with fade effect
extends CanvasLayer

var _transition_rect: ColorRect = null
var _tween: Tween = null
const FADE_TIME := 0.3

func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_overlay()

func _setup_overlay() -> void:
	_transition_rect = ColorRect.new()
	_transition_rect.color = Color(0.12, 0.1, 0.15, 1.0)
	_transition_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_transition_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_transition_rect.modulate.a = 0.0
	_transition_rect.visible = false
	add_child(_transition_rect)

func transition_to(scene_path: String) -> void:
	_transition_rect.visible = true
	_transition_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(_transition_rect, "modulate:a", 1.0, FADE_TIME)
	_tween.tween_callback(func():
		get_tree().change_scene_to_file(scene_path)
		var tw := create_tween()
		tw.tween_property(_transition_rect, "modulate:a", 0.0, FADE_TIME)
		tw.tween_callback(func():
			_transition_rect.visible = false
			_transition_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		)
	)

func flash(color: Color = Color.WHITE, duration: float = 0.15) -> void:
	_transition_rect.color = color
	_transition_rect.visible = true
	_transition_rect.modulate.a = 0.8
	var tw := create_tween()
	tw.tween_property(_transition_rect, "modulate:a", 0.0, duration)
	tw.tween_callback(func():
		_transition_rect.visible = false
		_transition_rect.color = Color(0.12, 0.1, 0.15, 1.0)
	)
