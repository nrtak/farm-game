extends Node2D

static var geometry_cache: Dictionary = {}

var first_name := ""
var route: Array = []
var route_index := 0
var target := Vector2.ZERO
var speed := 85.0
var travel := 0.0
var facing := 0
var paused := false
var frame := -1
var sprite: Sprite2D
var regions: Array[Rect2] = []
var offsets: Array[Vector2] = []
var height_scale := 1.0
var label: Label
var sheet: Texture2D
var period := -1
var turnaround := false
var footsteps: Array[Sprite2D] = []
var leg_origins: Array[Vector2] = []
var current_row := -1

func setup_turnaround(person: String, texture: Texture2D, character_row: int, group: int = 2) -> void:
	first_name = person
	sheet = texture
	turnaround = true
	sprite = Sprite2D.new()
	sprite.texture = texture
	sprite.region_enabled = true
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(sprite)
	var image := texture.get_image()
	# Explicit row cuts keep neighbouring figures and labels out of sprites.
	var cuts: Array = {2: [45, 248, 470, 692, 922, 1134, 1360], 3: [50, 280, 512, 780, 1018, 1248, 1448], 4: [45, 268, 532, 747, 1010, 1235, 1448]}[group]
	var reference_height := 1374.0 if group == 2 else 1448.0
	var top := int(cuts[character_row] * image.get_height() / reference_height)
	var bottom := int(cuts[character_row + 1] * image.get_height() / reference_height)
	var columns := [0.267, 0.455, 0.65, 0.844]
	var tallest := 1.0
	for column in range(4):
		var area := Rect2i(int(image.get_width() * (columns[column] - 0.077)), top, int(image.get_width() * 0.154), bottom - top)
		area = area.intersection(Rect2i(Vector2i.ZERO, image.get_size()))
		var bounds := alpha_bounds(image.get_region(area))
		regions.append(Rect2(area.position + bounds.position, bounds.size))
		offsets.append(Vector2.ZERO)
		tallest = maxf(tallest, bounds.size.y)
	height_scale = 150.0 / tallest
	sprite.scale = Vector2.ONE * height_scale
	for i in range(2):
		var foot := Sprite2D.new()
		foot.texture = texture
		foot.region_enabled = true
		foot.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		foot.scale = Vector2.ONE * height_scale
		add_child(foot)
		footsteps.append(foot)
	label = Label.new()
	label.text = person
	label.position = Vector2(-90, -180)
	label.size = Vector2(180, 30)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 20)
	label.add_theme_color_override("font_color", Color("fff5dc"))
	label.add_theme_color_override("font_shadow_color", Color("39372b"))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	add_child(label)
	show_frame(0, 1)

func setup(person: String, texture: Texture2D) -> void:
	first_name = person
	sheet = texture
	sprite = Sprite2D.new()
	sprite.texture = texture
	sprite.region_enabled = true
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(sprite)
	prepare_walk_geometry(person, texture)
	sprite.scale = Vector2.ONE * height_scale
	label = Label.new()
	label.text = first_name
	label.position = Vector2(-90, -185)
	label.size = Vector2(180, 30)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 20)
	label.add_theme_color_override("font_color", Color("fff5dc"))
	label.add_theme_color_override("font_shadow_color", Color("39372b"))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	add_child(label)
	show_frame(0, 1)

func prepare_walk_geometry(person: String, texture: Texture2D) -> void:
	if geometry_cache.is_empty() and FileAccess.file_exists("res://assets/npc-geometry.json"):
		var cached = JSON.parse_string(FileAccess.get_file_as_string("res://assets/npc-geometry.json"))
		if cached is Dictionary: geometry_cache = cached
	var entry: Dictionary = geometry_cache.get(person, {})
	if entry.get("width", 0) == texture.get_width() and entry.get("height", 0) == texture.get_height():
		for values in entry.regions: regions.append(Rect2(values[0], values[1], values[2], values[3]))
		for values in entry.offsets: offsets.append(Vector2(values[0], values[1]))
		height_scale = entry.scale
		return
	var image := texture.get_image()
	var cell := Vector2i(image.get_width() / 4, image.get_height() / 4)
	var tallest := 1.0
	for row in range(4):
		var bounds_list: Array[Rect2i] = []
		var ground := 0.0
		for phase in range(4):
			var bounds := alpha_bounds(image.get_region(Rect2i(Vector2i(phase, row) * cell, cell)))
			bounds_list.append(bounds)
			ground = maxf(ground, bounds.end.y)
			tallest = maxf(tallest, bounds.size.y)
		for phase in range(4):
			var bounds := bounds_list[phase]
			regions.append(Rect2(bounds.position + Vector2i(phase, row) * cell, bounds.size))
			offsets.append(Vector2(bounds.get_center()) - Vector2(cell.x * 0.5, ground))
	height_scale = 150.0 / tallest

func alpha_bounds(image: Image) -> Rect2i:
	var first := image.get_size()
	var last := Vector2i(-1, -1)
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			if image.get_pixel(x, y).a < 0.15: continue
			first.x = mini(first.x, x)
			first.y = mini(first.y, y)
			last.x = maxi(last.x, x)
			last.y = maxi(last.y, y)
	return Rect2i(first, last - first + Vector2i.ONE)

func set_route(points: Array) -> void:
	route = points
	route_index = 0
	if not route.is_empty(): target = route[0]

func tick(delta: float) -> void:
	if paused or route.is_empty(): return
	var direction := target - position
	if direction.length() < 4.0:
		route_index = (route_index + 1) % route.size()
		target = route[route_index]
		direction = target - position
	var distance := minf(speed * delta, direction.length())
	position += direction.normalized() * distance
	travel += distance
	if absf(direction.x) > absf(direction.y): facing = 1 if direction.x < 0 else 3
	else: facing = 0 if direction.y >= 0 else 2
	show_frame(facing, int(travel / 24.0) % 4 if distance > 0.1 else 1)

func face_player(player_position: Vector2) -> void:
	var direction := player_position - global_position
	if absf(direction.x) > absf(direction.y): facing = 1 if direction.x < 0 else 3
	else: facing = 0 if direction.y >= 0 else 2
	show_frame(facing, 1)

func show_frame(row: int, phase: int) -> void:
	if turnaround:
		show_turnaround(row, phase)
		return
	# Some generated last left-profile frames face right. Reuse the matching
	# right-profile passing frame mirrored, rather than showing a direction jump.
	var mirror := row == 1 and phase == 3
	var index := (3 if mirror else row) * 4 + phase
	if index == frame and sprite.flip_h == mirror: return
	frame = index
	sprite.flip_h = mirror
	sprite.region_rect = regions[index]
	sprite.position = offsets[index] * height_scale
	if mirror: sprite.position.x *= -1

func show_turnaround(row: int, phase: int) -> void:
	var key := row * 4 + phase
	if frame == key: return
	frame = key
	var index := row
	var bounds := regions[index]
	var lower := bounds.size.y * 0.22
	var upper := bounds.size.y - lower
	sprite.region_rect = Rect2(bounds.position, Vector2(bounds.size.x, upper))
	sprite.position = Vector2(0, -(lower + upper * 0.5) * height_scale)
	var offset := 2.0 if phase in [0, 2] else 0.0
	for i in range(2):
		var foot := footsteps[i]
		foot.region_rect = Rect2(bounds.position + Vector2(i * bounds.size.x * 0.5, upper), Vector2(bounds.size.x * 0.5, lower))
		foot.position = Vector2((i - 0.5) * bounds.size.x * 0.5, -lower * 0.5) * height_scale
		foot.position.y -= offset if (phase == 0 and i == 0) or (phase == 2 and i == 1) else 0.0
