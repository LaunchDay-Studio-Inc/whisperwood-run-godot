## ParallaxBG — Procedural parallax background for runner
extends Node2D

var _layers: Array[Dictionary] = []
var _speed_ref: float = 400.0

const LAYER_CONFIG := [
	{"name": "sky", "speed_mult": 0.1, "y": -200, "color": Color(0.15, 0.12, 0.25)},
	{"name": "far_mountains", "speed_mult": 0.2, "y": 0, "color": Color(0.2, 0.18, 0.3)},
	{"name": "mid_trees", "speed_mult": 0.5, "y": 200, "color": Color(0.15, 0.3, 0.2)},
	{"name": "near_bushes", "speed_mult": 0.8, "y": 400, "color": Color(0.1, 0.25, 0.15)},
	{"name": "ground", "speed_mult": 1.0, "y": 550, "color": Color(0.2, 0.15, 0.1)},
]

func _ready() -> void:
	_create_layers()

func _create_layers() -> void:
	for config in LAYER_CONFIG:
		var layer_data := {"node": null, "speed_mult": config["speed_mult"], "offset": 0.0}

		var layer_node := Node2D.new()
		layer_node.z_index = -10 + LAYER_CONFIG.find(config)
		add_child(layer_node)

		match config["name"]:
			"sky":
				_create_sky_layer(layer_node, config["color"])
			"far_mountains":
				_create_mountain_layer(layer_node, config["color"])
			"mid_trees":
				_create_tree_layer(layer_node, config["color"], 80, 5)
			"near_bushes":
				_create_bush_layer(layer_node, config["color"])
			"ground":
				_create_ground_layer(layer_node, config["color"])

		layer_data["node"] = layer_node
		_layers.append(layer_data)

func _create_sky_layer(parent: Node2D, color: Color) -> void:
	var rect := Polygon2D.new()
	rect.polygon = PackedVector2Array([
		Vector2(-400, -700), Vector2(400, -700),
		Vector2(400, 200), Vector2(-400, 200),
	])
	rect.color = color
	parent.add_child(rect)

	# Stars
	for i in 30:
		var star := Polygon2D.new()
		var s := randf_range(1, 3)
		star.polygon = PackedVector2Array([
			Vector2(-s, 0), Vector2(0, -s), Vector2(s, 0), Vector2(0, s)
		])
		star.color = Color(1, 1, 0.9, randf_range(0.3, 0.8))
		star.position = Vector2(randf_range(-380, 380), randf_range(-680, 100))
		parent.add_child(star)

func _create_mountain_layer(parent: Node2D, color: Color) -> void:
	# Two copies for seamless scrolling
	for offset in [0, 1600]:
		for i in 6:
			var mountain := Polygon2D.new()
			var cx := -400 + i * 300 + offset + randf_range(-50, 50)
			var h := randf_range(150, 300)
			var w := randf_range(120, 200)
			mountain.polygon = PackedVector2Array([
				Vector2(cx - w, 200),
				Vector2(cx - w * 0.3, 200 - h * 0.8),
				Vector2(cx, 200 - h),
				Vector2(cx + w * 0.3, 200 - h * 0.7),
				Vector2(cx + w, 200),
			])
			mountain.color = Color(color, 0.8 + randf_range(-0.1, 0.1))
			parent.add_child(mountain)

func _create_tree_layer(parent: Node2D, color: Color, height: float, count: int) -> void:
	for offset in [0, 1600]:
		for i in count:
			var tree_node := Node2D.new()
			var x := -400 + i * 320 + offset + randf_range(-30, 30)
			tree_node.position = Vector2(x, 200)

			# Trunk
			var trunk := Polygon2D.new()
			trunk.polygon = PackedVector2Array([
				Vector2(-6, 0), Vector2(6, 0),
				Vector2(4, -height * 0.4), Vector2(-4, -height * 0.4),
			])
			trunk.color = Color(0.35, 0.25, 0.15)
			tree_node.add_child(trunk)

			# Canopy
			var canopy := Polygon2D.new()
			var cw := randf_range(30, 50)
			var ch := randf_range(40, 70)
			canopy.polygon = PackedVector2Array([
				Vector2(-cw, -height * 0.3),
				Vector2(0, -height * 0.3 - ch),
				Vector2(cw, -height * 0.3),
			])
			canopy.color = color
			tree_node.add_child(canopy)

			parent.add_child(tree_node)

func _create_bush_layer(parent: Node2D, color: Color) -> void:
	for offset in [0, 1600]:
		for i in 8:
			var bush := Polygon2D.new()
			var x := -400 + i * 200 + offset + randf_range(-20, 20)
			var w := randf_range(25, 45)
			var h := randf_range(15, 30)
			bush.polygon = PackedVector2Array([
				Vector2(x - w, 200),
				Vector2(x - w * 0.7, 200 - h),
				Vector2(x, 200 - h * 1.2),
				Vector2(x + w * 0.7, 200 - h),
				Vector2(x + w, 200),
			])
			bush.color = color
			parent.add_child(bush)

func _create_ground_layer(parent: Node2D, color: Color) -> void:
	# Ground with lane markers
	var ground := Polygon2D.new()
	ground.polygon = PackedVector2Array([
		Vector2(-400, -50), Vector2(400, -50),
		Vector2(400, 800), Vector2(-400, 800),
	])
	ground.color = color
	parent.add_child(ground)

	# Path/road surface
	var path := Polygon2D.new()
	path.polygon = PackedVector2Array([
		Vector2(-250, -50), Vector2(250, -50),
		Vector2(250, 800), Vector2(-250, 800),
	])
	path.color = Color(color.r + 0.05, color.g + 0.05, color.b + 0.03)
	parent.add_child(path)

	# Lane dividers
	for lane_div in [-80, 80]:
		for offset in [0, 1600]:
			for j in 20:
				var divider := Polygon2D.new()
				var y := -50 + j * 80 + offset
				divider.polygon = PackedVector2Array([
					Vector2(lane_div - 2, y), Vector2(lane_div + 2, y),
					Vector2(lane_div + 2, y + 40), Vector2(lane_div - 2, y + 40),
				])
				divider.color = Color(1, 1, 0.8, 0.15)
				parent.add_child(divider)

func set_speed(speed: float) -> void:
	_speed_ref = speed

func _process(delta: float) -> void:
	for layer_data in _layers:
		var node: Node2D = layer_data["node"]
		var mult: float = layer_data["speed_mult"]
		layer_data["offset"] += _speed_ref * mult * delta

		# Loop scrolling
		if layer_data["offset"] > 1600:
			layer_data["offset"] -= 1600

		node.position.y = layer_data["offset"]

func set_biome(biome: String) -> void:
	# Adjust colors based on biome
	match biome:
		"crystal_caverns":
			_recolor([
				Color(0.1, 0.08, 0.2),
				Color(0.15, 0.12, 0.3),
				Color(0.2, 0.15, 0.4),
				Color(0.15, 0.1, 0.35),
				Color(0.12, 0.1, 0.2),
			])
		"starlit_meadow":
			_recolor([
				Color(0.08, 0.05, 0.15),
				Color(0.12, 0.1, 0.2),
				Color(0.15, 0.25, 0.15),
				Color(0.1, 0.2, 0.1),
				Color(0.15, 0.12, 0.08),
			])

func _recolor(colors: Array) -> void:
	for i in min(colors.size(), _layers.size()):
		var node: Node2D = _layers[i]["node"]
		for child in node.get_children():
			if child is Polygon2D:
				child.color = colors[i]
