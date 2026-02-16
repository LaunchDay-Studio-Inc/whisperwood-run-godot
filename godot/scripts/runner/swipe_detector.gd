## SwipeDetector — Handles touch/swipe input and emits directional signals
extends Node

signal swiped_left
signal swiped_right
signal swiped_up
signal swiped_down
signal tapped

const MIN_SWIPE_DISTANCE := 50.0
const MAX_SWIPE_TIME := 0.4

var _touch_start_pos: Vector2 = Vector2.ZERO
var _touch_start_time: float = 0.0
var _is_touching: bool = false

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			_touch_start_pos = event.position
			_touch_start_time = Time.get_ticks_msec() / 1000.0
			_is_touching = true
		else:
			if _is_touching:
				_process_swipe(event.position)
				_is_touching = false

	elif event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_touch_start_pos = event.position
			_touch_start_time = Time.get_ticks_msec() / 1000.0
			_is_touching = true
		elif not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if _is_touching:
				_process_swipe(event.position)
				_is_touching = false

func _process_swipe(end_pos: Vector2) -> void:
	var elapsed := Time.get_ticks_msec() / 1000.0 - _touch_start_time
	if elapsed > MAX_SWIPE_TIME:
		return

	var delta := end_pos - _touch_start_pos
	var distance := delta.length()

	if distance < MIN_SWIPE_DISTANCE:
		tapped.emit()
		return

	if abs(delta.x) > abs(delta.y):
		if delta.x < 0:
			swiped_left.emit()
		else:
			swiped_right.emit()
	else:
		if delta.y < 0:
			swiped_up.emit()
		else:
			swiped_down.emit()
