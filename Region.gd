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
var scenery_polygons: Array = []
var scenery_circles: Array = []
const MINE_DOOR := Vector2(1380,205)

func setup(area: String, people: Array) -> void:
	kind = area
	title = {"tea": "Tea Country", "harbor": "Western Harbor", "mountain": "Mountain & Lake", "historic": "Shrine Grounds"}[kind]
	var art := {"harbor":"map-harbor-approved-v1.png","mountain":"map-mountain-approved-v1.png","historic":"map-historic-approved-v1.png","tea":"map-tea-approved-v1.png"}
	background = load("res://assets/"+art[kind])
	for rect in preload("res://ApprovedMapLayout.gd").buildings(kind)+preload("res://ApprovedMapLayout.gd").scenery(kind):
		solids.append(rect)
		obstacle(rect)
	scenery_polygons=[]
	scenery_circles=[]
	for polygon in scenery_polygons:
		var body := StaticBody2D.new()
		body.collision_layer=16; body.collision_mask=0
		var shape := CollisionPolygon2D.new()
		shape.polygon=polygon; body.add_child(shape); add_child(body)
	for circle in scenery_circles:
		var body := StaticBody2D.new()
		body.collision_layer=16; body.collision_mask=0; body.position=circle[0]
		var collider := CollisionShape2D.new()
		var shape := CircleShape2D.new()
		shape.radius=circle[1]; collider.shape=shape
		body.add_child(collider); add_child(body)
	for rect in [Rect2(-24, -24, 1648, 24), Rect2(-24, 1200, 1648, 24), Rect2(-24, 0, 24, 1200), Rect2(1600, 0, 24, 1200)]: obstacle(rect)
	for i in range(people.size()):
		var person: String = people[i]
		var npc := NpcScript.new()
		add_child(npc)
		var posts := {"Mika":Vector2(470,510),"Sachiko":Vector2(1235,680),"Ken":Vector2(420,620),"Masao":Vector2(1200,530),"Emi":Vector2(470,520),"Hiro":Vector2(1210,530),"Haruka":Vector2(470,520),"Rei":Vector2(1190,550)}
		npc.position = safe_npc_point(posts.get(person,Vector2(800,600)))
		var index := Cast.index_of(person)
		var walk_path := "res://assets/npc-%s-walk.png" % person.to_lower()
		if preload("res://CharacterArt.gd").walk(person) != null: npc.setup(person, preload("res://CharacterArt.gd").walk(person))
		else: npc.setup_turnaround(person, SpriteLibrary.turnaround(index.x), index.y, index.x)
		npc.z_index = 4
		npc.set_route([])
		npcs.append(npc)
	add_label(title, Vector2(570, 60), Vector2(460, 50))
	var return_labels := {"harbor":["East · Town",Vector2(1350,555)],"tea":["West · Town",Vector2(24,555)],"historic":["Southeast · Town",Vector2(1300,1070)],"mountain":["South · Town",Vector2(680,1070)]}
	add_label(return_labels[kind][0],return_labels[kind][1],Vector2(260,45))
	# Signs are painted beside each building in the approved artwork.
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
		npc.position = safe_npc_point(npc.position)
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
	for polygon in scenery_polygons:
		if Geometry2D.is_point_in_polygon(point,polygon): return false
	for circle in scenery_circles:
		if point.distance_to(circle[0]) < float(circle[1])+16: return false
	for rect in solids:
		if rect.grow(16).has_point(point): return false
	return true

func safe_point(preferred: Vector2) -> Vector2:
	if is_walkable(preferred): return preferred
	for radius in range(32,481,32):
		for i in range(24):
			var candidate := preferred+Vector2(radius,0).rotated(TAU*i/24.0)
			if is_walkable(candidate): return candidate
	return Vector2(800,600)

func _draw() -> void:
	if background != null:
		draw_texture_rect(background, Rect2(Vector2.ZERO, SIZE), false)
		if kind == "mountain":
			pass # Onsen and workshop are included in the map artwork.
			draw_string(ThemeDB.fallback_font, MINE_DOOR+Vector2(-40,45), "Mine", HORIZONTAL_ALIGNMENT_CENTER, 110, 24, Color("493b2d"))
		if kind == "tea":
			for spot in [Vector2(788,812),Vector2(900,910),Vector2(1354,810)]:
				draw_circle(spot, 25, Color("d8c393"))
				draw_line(spot + Vector2(0, 10), spot + Vector2(0, -10), Color("60834f"), 4)
				draw_circle(spot + Vector2(-7, -3), 8, Color("60834f"))
				draw_circle(spot + Vector2(7, -9), 8, Color("60834f"))
		if kind == "harbor":
			for spot in [Vector2(570,865),Vector2(570,965)]:
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

func draw_mountain_resort() -> void:
	preload("res://EntrancePaths.gd").draw_path(self,PackedVector2Array([Vector2(350,750),Vector2(480,770),Vector2(650,800),Vector2(800,800)]))
	preload("res://EntrancePaths.gd").draw_path(self,PackedVector2Array([Vector2(1310,880),Vector2(1170,910),Vector2(970,920),Vector2(800,930)]))
	draw_texture_rect(preload("res://assets/onsen-exterior-v1.png"),Rect2(140,480,420,260),false)
	draw_texture_rect(preload("res://assets/carpentry-exterior-v1.png"),Rect2(1130,630,360,250),false)
	# Steam belongs to the natural spring at the left shoreline.
	for p in [Vector2(180,940),Vector2(360,1030),Vector2(480,1110)]:
		draw_arc(p,28,-1.7,0.4,14,Color(0.95,0.97,0.93,0.55),3)

func safe_npc_point(preferred: Vector2) -> Vector2:
	var doors: Array = preload("res://ApprovedMapLayout.gd").doors(kind).values()
	for radius in range(0,500,32):
		for step in range(24):
			var candidate := preferred+Vector2.from_angle(step*TAU/24)*radius
			if not is_walkable(candidate): continue
			var clear := true
			for door in doors:
				if absf(candidate.x-door.x)<180 and candidate.y>door.y-40 and candidate.y<door.y+180: clear=false
			if clear: return candidate
	return safe_point(Vector2(800,600))
