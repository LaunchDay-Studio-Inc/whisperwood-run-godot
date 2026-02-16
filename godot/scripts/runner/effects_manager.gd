## EffectsManager — Particle effects, screen juice, and visual polish
extends Node2D

## Spawn a burst of small particles at a position
static func spawn_collect_burst(parent: Node, pos: Vector2, color: Color = Color(1, 0.85, 0.2), count: int = 8) -> void:
	for i in count:
		var p := Polygon2D.new()
		var s := randf_range(2, 5)
		p.polygon = PackedVector2Array([
			Vector2(-s, 0), Vector2(0, -s), Vector2(s, 0), Vector2(0, s)
		])
		p.color = color
		p.position = pos
		p.z_index = 20
		parent.add_child(p)

		var angle := randf() * TAU
		var dist := randf_range(30, 80)
		var target := pos + Vector2(cos(angle) * dist, sin(angle) * dist)
		var duration := randf_range(0.3, 0.6)

		var tw := parent.create_tween()
		tw.set_parallel(true)
		tw.tween_property(p, "position", target, duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		tw.tween_property(p, "modulate:a", 0.0, duration)
		tw.tween_property(p, "scale", Vector2(0.1, 0.1), duration)
		tw.set_parallel(false)
		tw.tween_callback(p.queue_free)

## Spawn a crash shockwave effect
static func spawn_crash_effect(parent: Node, pos: Vector2) -> void:
	# Ring expansion
	var ring := Polygon2D.new()
	var points := PackedVector2Array()
	for i in 24:
		var angle := TAU * i / 24
		points.append(Vector2(cos(angle) * 5, sin(angle) * 5))
	ring.polygon = points
	ring.color = Color(1, 0.3, 0.2, 0.8)
	ring.position = pos
	ring.z_index = 25
	parent.add_child(ring)

	var tw := parent.create_tween()
	tw.set_parallel(true)
	tw.tween_property(ring, "scale", Vector2(8, 8), 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tw.tween_property(ring, "modulate:a", 0.0, 0.4)
	tw.set_parallel(false)
	tw.tween_callback(ring.queue_free)

	# Screen shake via TransitionManager flash
	TransitionManager.flash(Color(1, 0.3, 0.2, 0.3), 0.2)

	# Debris particles
	spawn_collect_burst(parent, pos, Color(0.6, 0.3, 0.2), 12)

## Spawn a shield break effect
static func spawn_shield_break(parent: Node, pos: Vector2) -> void:
	for i in 6:
		var shard := Polygon2D.new()
		var w := randf_range(4, 10)
		var h := randf_range(8, 16)
		shard.polygon = PackedVector2Array([
			Vector2(-w/2, -h/2), Vector2(w/2, -h/3),
			Vector2(w/3, h/2), Vector2(-w/3, h/3),
		])
		shard.color = Color(0.3, 0.6, 1.0, 0.8)
		shard.position = pos
		shard.z_index = 22
		parent.add_child(shard)

		var angle := TAU * i / 6 + randf_range(-0.3, 0.3)
		var dist := randf_range(40, 100)
		var target := pos + Vector2(cos(angle) * dist, sin(angle) * dist)

		var tw := parent.create_tween()
		tw.set_parallel(true)
		tw.tween_property(shard, "position", target, 0.5).set_ease(Tween.EASE_OUT)
		tw.tween_property(shard, "rotation", randf_range(-3, 3), 0.5)
		tw.tween_property(shard, "modulate:a", 0.0, 0.5)
		tw.set_parallel(false)
		tw.tween_callback(shard.queue_free)

## Floating text popup (score, +seeds, etc.)
static func spawn_floating_text(parent: Node, pos: Vector2, text: String, color: Color = Color(1, 0.95, 0.7)) -> void:
	var label := Label.new()
	label.text = text
	label.position = pos
	label.z_index = 30
	label.add_theme_font_size_override("font_size", 22)
	label.add_theme_color_override("font_color", color)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	parent.add_child(label)

	var tw := parent.create_tween()
	tw.set_parallel(true)
	tw.tween_property(label, "position:y", pos.y - 60, 0.8).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tw.tween_property(label, "modulate:a", 0.0, 0.8).set_delay(0.3)
	tw.set_parallel(false)
	tw.tween_callback(label.queue_free)

## Spawn a trail particle behind the player
static func spawn_trail_particle(parent: Node, pos: Vector2, color: Color) -> void:
	var p := Polygon2D.new()
	var s := randf_range(2, 4)
	p.polygon = PackedVector2Array([
		Vector2(-s, -s), Vector2(s, -s), Vector2(s, s), Vector2(-s, s)
	])
	p.color = color
	p.position = pos + Vector2(randf_range(-8, 8), randf_range(20, 35))
	p.z_index = 5
	parent.add_child(p)

	var tw := parent.create_tween()
	tw.set_parallel(true)
	tw.tween_property(p, "modulate:a", 0.0, 0.5)
	tw.tween_property(p, "position:y", p.position.y + 30, 0.5)
	tw.tween_property(p, "scale", Vector2(0.2, 0.2), 0.5)
	tw.set_parallel(false)
	tw.tween_callback(p.queue_free)

## Light overlay for warm/moonlit atmosphere
static func create_light_overlay(parent: Node) -> ColorRect:
	var overlay := ColorRect.new()
	overlay.color = Color(1.0, 0.9, 0.6, 0.04)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.z_index = 50
	parent.add_child(overlay)

	# Subtle pulsing
	var tw := parent.create_tween().set_loops()
	tw.tween_property(overlay, "color:a", 0.06, 2.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tw.tween_property(overlay, "color:a", 0.02, 2.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)

	return overlay

## Vignette effect
static func create_vignette(parent: Node) -> ColorRect:
	var vignette := ColorRect.new()
	vignette.color = Color(0, 0, 0, 0.0)
	vignette.set_anchors_preset(Control.PRESET_FULL_RECT)
	vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vignette.z_index = 49
	# Note: true vignette needs a shader; this is a simplified version
	parent.add_child(vignette)
	return vignette
