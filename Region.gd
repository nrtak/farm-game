extends Node2D

const SIZE := Vector2(1600, 1200)
const NpcScript = preload("res://Npc.gd")
const SpriteLibrary = preload("res://SpriteLibrary.gd")
const Cast = preload("res://Cast.gd")
var kind := ""
var fishing_state := 0
var fishing_spot := Vector2.ZERO
var npcs: Array[Node2D] = []
var solids: Array[Rect2] = []
var title := ""
var background: Texture2D

func setup(area: String, people: Array) -> void:
	kind = area
	title = {"tea": "Tea Country", "harbor": "Western Harbor", "mountain": "Mountain & Lake", "historic": "Historic District"}[kind]
	background = load("res://assets/region-%s-v1.png" % kind)
	var building_bounds: Array = {
		"tea": [Rect2(190, 100, 365, 235), Rect2(895, 120, 360, 220)],
		"harbor": [Rect2(220, 110, 315, 220), Rect2(928, 110, 325, 220)],
		"mountain": [Rect2(230, 90, 350, 265), Rect2(940, 155, 265, 190)],
		"historic": [Rect2(195, 130, 355, 220), Rect2(915, 110, 330, 245)]
	}[kind]
	var scale_to_world := SIZE / Vector2(1448, 1086)
	for bounds in building_bounds:
		var rect := Rect2(bounds.position * scale_to_world, bounds.size * scale_to_world)
		solids.append(rect)
		obstacle(rect)
	if kind == "harbor":
		for rect in [Rect2(0, 850, 230, 350), Rect2(340, 880, 360, 320), Rect2(230, 1000, 110, 200), Rect2(900, 870, 350, 330), Rect2(1360, 820, 240, 380), Rect2(1250, 1000, 110, 200)]:
			solids.append(rect)
			obstacle(rect)
	if kind == "mountain":
		for rect in [Rect2(0, 890, 230, 310), Rect2(230, 1040, 300, 160)]:
			solids.append(rect)
			obstacle(rect)
	for rect in [Rect2(-24, -24, 1648, 24), Rect2(-24, 1200, 1648, 24), Rect2(-24, 0, 24, 1200), Rect2(1600, 0, 24, 1200)]: obstacle(rect)
	for i in range(people.size()):
		var person: String = people[i]
		var npc := NpcScript.new()
		add_child(npc)
		npc.position = Vector2(500 + i * 500, 550)
		var index := Cast.index_of(person)
		var walk_path := "res://assets/npc-%s-walk.png" % person.to_lower()
		if ResourceLoader.exists(walk_path): npc.setup(person, load(walk_path))
		else: npc.setup_turnaround(person, SpriteLibrary.turnaround(index.x), index.y, index.x)
		npc.z_index = 4
		npc.set_route([npc.position, Vector2(800, 630 + i * 130), Vector2(500 + i * 500, 780), npc.position])
		npcs.append(npc)
	add_label(title, Vector2(570, 60), Vector2(460, 50))
	add_label("South · Return to Town", Vector2(560, 1070), Vector2(480, 45))
	var labels: Array = {"tea": ["Tea Farmhouse", "Processing Shed"], "harbor": ["Harbor Homes", "Fishing Shop"], "mountain": ["Emi's Lodge", "Hiro's Cabin"], "historic": ["History Room", "Shrine"]}[kind]
	add_label(labels[0], Vector2(250, 420), Vector2(360, 40))
	add_label(labels[1], Vector2(1000, 420), Vector2(350, 40))
	queue_redraw()

func add_label(text: String, where: Vector2, dimensions: Vector2) -> void:
	var label := Label.new()
	label.text = text
	label.position = where
	label.size = dimensions
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 27)
	label.add_theme_color_override("font_color", Color("493b2d"))
	add_child(label)

func obstacle(rect: Rect2) -> void:
	var body := StaticBody2D.new()
	body.collision_layer = 16
	body.collision_mask = 0
	body.position = rect.get_center()
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = rect.size
	collision.shape = shape
	body.add_child(collision)
	add_child(body)

func tick(delta: float, _minute: float) -> void:
	for npc in npcs:
		if not npc.visible: continue
		npc.tick(delta)
		npc.z_index = clampi(int(npc.position.y / 10), 1, 119)

func nearest_npc(point: Vector2) -> Node2D:
	var result: Node2D
	var distance := 120.0
	for npc in get_children():
		if npc.get_script() != NpcScript or not npc.visible: continue
		var candidate := point.distance_to(npc.position)
		if candidate < distance:
			distance = candidate
			result = npc
	return result

func is_walkable(point: Vector2) -> bool:
	if not Rect2(Vector2(24, 24), SIZE - Vector2(48, 48)).has_point(point): return false
	for rect in solids:
		if rect.grow(16).has_point(point): return false
	return true

func _draw() -> void:
	if background != null:
		draw_texture_rect(background, Rect2(Vector2.ZERO, SIZE), false)
		if kind == "historic":
			# These side lanes end within the region; reserve the south road for travel.
			for side in [0, 1]:
				var cap := PackedVector2Array()
				var uv := PackedVector2Array()
				for point in [Vector2(0,470),Vector2(70,485),Vector2(115,520),Vector2(137,570),Vector2(128,625),Vector2(92,674),Vector2(0,700)]:
					cap.append(Vector2(SIZE.x-point.x,point.y) if side == 1 else point)
					uv.append(Vector2(390+point.x*0.55,680+(point.y-470)*0.5)/background.get_size())
				draw_polygon(cap,PackedColorArray([Color.WHITE]),uv,background)
		if kind == "mountain":
			draw_style_box(mine_arch(), Rect2(740, 135, 120, 120))
			draw_rect(Rect2(762, 175, 76, 80), Color("454940"))
			draw_string(ThemeDB.fallback_font, Vector2(745, 290), "Mine", HORIZONTAL_ALIGNMENT_CENTER, 110, 24, Color("493b2d"))
		if kind == "tea":
			for spot in [Vector2(430, 800), Vector2(430, 950), Vector2(1150, 800)]:
				draw_circle(spot, 25, Color("d8c393"))
				draw_line(spot + Vector2(0, 10), spot + Vector2(0, -10), Color("60834f"), 4)
				draw_circle(spot + Vector2(-7, -3), 8, Color("60834f"))
				draw_circle(spot + Vector2(7, -9), 8, Color("60834f"))
		if kind == "harbor":
			for spot in [Vector2(285, 940), Vector2(1305, 940)]:
				draw_circle(spot, 26, Color(0.90, 0.83, 0.63, 0.7))
				draw_line(spot + Vector2(-8, 8), spot + Vector2(8, -8), Color("493b2d"), 4)
				draw_string(ThemeDB.fallback_font, spot + Vector2(-42, -36), "Fish", HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color("493b2d"))
			if fishing_state > 0:
				var bob := fishing_spot + Vector2(0, 75)
				draw_line(fishing_spot, bob, Color("e4dab9"), 2)
				draw_circle(bob, 7, Color("b97764") if fishing_state == 1 else Color("e5cb85"))
				if fishing_state == 2: draw_circle(bob, 16, Color("e5cb85"), false, 3)
		return
	draw_rect(Rect2(Vector2.ZERO, SIZE), Color("92aa77"))
	if kind == "harbor":
		draw_rect(Rect2(0, 800, 1600, 400), Color("78a7ae"))
		draw_rect(Rect2(0, 790, 1600, 80), Color("d8c393"))
		for x in [280, 1250]:
			draw_rect(Rect2(x, 820, 100, 270), Color("a18c64"))
	elif kind == "tea":
		for y in range(720, 1100, 65):
			for x in [100, 1050]:
				draw_style_box(hedge_box(), Rect2(x, y, 440, 30))
	elif kind == "mountain":
		draw_circle(Vector2(1230, 880), 240, Color("82adb0"))
		for x in range(40, 1500, 160): draw_circle(Vector2(x, 90), 65, Color("607e55"))
	elif kind == "historic":
		draw_rect(Rect2(1110, 90, 18, 75), Color("a66b52"))
		draw_rect(Rect2(1250, 90, 18, 75), Color("a66b52"))
		draw_line(Vector2(1090, 80), Vector2(1280, 80), Color("a66b52"), 16)
	draw_rect(Rect2(680, 440, 240, 760), Color("d8c393"))
	draw_rect(Rect2(200, 460, 1200, 180), Color("d8c393"))
	for rect in solids:
		draw_rect(rect, Color("c8ad7f"))
		draw_rect(Rect2(rect.position - Vector2(20, 0), Vector2(rect.size.x + 40, 110)), Color("596267"))
		draw_rect(Rect2(rect.get_center().x - 35, rect.end.y - 100, 70, 100), Color("786246"))
		for x in [rect.position.x + 40, rect.end.x - 95]: draw_rect(Rect2(x, rect.end.y - 100, 55, 55), Color("e6d3a5"))

func hedge_box() -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = Color("60834f")
	box.set_corner_radius_all(12)
	return box

func mine_arch() -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = Color("747970")
	box.corner_radius_top_left = 45
	box.corner_radius_top_right = 45
	return box
