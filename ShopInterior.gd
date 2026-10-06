extends Node2D

const SIZE := Vector2(1100, 850)
const ENTRY := Vector2(550, 730)
const COUNTER := Vector2(550, 360)
var kind := ""
var depleted := [false, false, false, false]
var solids: Array[Rect2] = []
var lost_item_visible := false
var residents: Array[Node2D] = []

func setup(service: String) -> void:
	kind = service
	solids = [Rect2(360, 230, 380, 80)]
	if kind == "Mine":
		solids = [Rect2(250, 290, 100, 70), Rect2(750, 290, 100, 70), Rect2(250, 490, 100, 70), Rect2(750, 490, 100, 70)]
	elif kind == "General Store":
		solids.append_array([Rect2(130, 210, 140, 240), Rect2(830, 210, 140, 240), Rect2(160, 540, 170, 90)])
	elif kind == "Blacksmith":
		solids.append_array([Rect2(130, 200, 170, 200), Rect2(800, 230, 180, 110), Rect2(790, 530, 160, 100)])
	elif kind in ["Inn", "Tea Farmhouse", "Harbor Homes", "Hiro Cabin"]:
		solids.append_array([Rect2(140, 210, 150, 190), Rect2(810, 210, 150, 190), Rect2(170, 550, 160, 90)])
	elif kind in ["Town Hall", "Police Box", "Fire Station", "Archive", "Shrine Residence", "Mountain Lodge", "Tea Processing Shed", "Fishing Shop"]:
		solids.append_array([Rect2(150, 220, 160, 160), Rect2(800, 210, 150, 210), Rect2(160, 570, 180, 70)])
	elif kind == "Clinic":
		solids.append_array([Rect2(800, 210, 155, 240), Rect2(150, 220, 160, 80), Rect2(155, 540, 180, 65)])
	else:
		solids.append_array([Rect2(170, 440, 150, 100), Rect2(780, 440, 150, 100), Rect2(170, 650, 150, 100), Rect2(780, 650, 150, 100)])
	for rect in [Rect2(90, 150, 920, 20), Rect2(90, 790, 920, 20), Rect2(90, 170, 20, 620), Rect2(990, 170, 20, 620)]: obstacle(rect)
	for rect in solids: obstacle(rect)
	var people: Array = {"General Store": ["Keiko", "Seira"], "Blacksmith": ["Gen", "Shohei"], "Café": ["Naomi"], "Inn": ["Yumi", "Hana"], "Clinic": ["Kenji", "Aya"], "Town Hall": ["Akira"], "Police Box": ["Taro"], "Fire Station": ["Jiro", "Yuta"], "Archive": ["Yoshi"], "Shrine Residence": ["Rei"], "Mountain Lodge": ["Emi"], "Tea Farmhouse": ["Sachiko", "Mika"], "Tea Processing Shed": ["Sachiko"], "Harbor Homes": ["Ken", "Masao"], "Fishing Shop": ["Masao"], "Hiro Cabin": ["Hiro"], "Mine": []}[kind]
	for i in range(people.size()):
		var person: String = people[i]
		var keeper = preload("res://Npc.gd").new()
		add_child(keeper)
		keeper.setup(person, load("res://assets/npc-%s-walk.png" % person.to_lower()))
		keeper.position = Vector2(550, 230) if i == 0 else Vector2(730, 540)
		keeper.paused = i == 0
		if i > 0: keeper.set_route([Vector2(730, 540), Vector2(730, 660), Vector2(600, 660), Vector2(730, 540)])
		keeper.show_frame(0, 1)
		keeper.z_index = 4
		residents.append(keeper)
	queue_redraw()

func obstacle(rect: Rect2) -> void:
	var body := StaticBody2D.new()
	body.collision_layer = 32
	body.position = rect.get_center()
	var collider := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = rect.size
	collider.shape = shape
	body.add_child(collider)
	add_child(body)

func is_walkable(point: Vector2) -> bool:
	if not Rect2(125, 185, 850, 585).has_point(point): return false
	for rect in solids:
		if rect.grow(14).has_point(point): return false
	return true

func _draw() -> void:
	if kind == "Mine":
		draw_rect(Rect2(Vector2.ZERO, SIZE), Color("454940"))
		draw_rect(Rect2(90, 70, 920, 740), Color("68665b"))
		draw_rect(Rect2(110, 170, 880, 620), Color("a7987b"))
		draw_rect(Rect2(440, 670, 220, 120), Color("c7b792"))
		for i in range(solids.size()):
			var rect: Rect2 = solids[i]
			draw_style_box(rock_box(), rect)
			if not depleted[i]:
				var tint := Color("bc8a63") if i % 2 == 0 else Color("c0c5c0")
				draw_rect(Rect2(rect.get_center() - Vector2(18, 10), Vector2(36, 20)), tint)
		for x in [160, 930]:
			draw_rect(Rect2(x, 185, 12, 420), Color("72523d"))
			draw_circle(Vector2(x + 6, 240), 14, Color("e5cb85"))
		draw_string(ThemeDB.fallback_font, Vector2(450, 770), "Exit ↓", HORIZONTAL_ALIGNMENT_CENTER, 200, 24, Color("493b2d"))
		return
	draw_rect(Rect2(Vector2.ZERO, SIZE), Color("33473d"))
	draw_rect(Rect2(90, 70, 920, 740), Color("72523d"))
	draw_rect(Rect2(110, 90, 880, 80), Color("e3cda4"))
	draw_rect(Rect2(110, 170, 880, 620), Color("bfa177"))
	for y in range(190, 790, 65): draw_line(Vector2(110, y), Vector2(990, y), Color("aa8b64"), 2)
	for x in [220, 810]:
		draw_rect(Rect2(x, 100, 90, 55), Color("a8c7bd"))
		draw_rect(Rect2(x, 100, 90, 55), Color("72523d"), false, 5)
	draw_rect(Rect2(440, 670, 220, 120), Color("8d9b77"))
	for rect in solids:
		draw_rect(rect, Color("72523d"))
		draw_rect(Rect2(rect.position, Vector2(rect.size.x, rect.size.y - 15)), Color("a47a52"))
	if kind == "General Store":
		for x in [150, 850]:
			for y in [235, 310, 385]:
				draw_rect(Rect2(x, y, 100, 35), Color("d8c896"))
				draw_circle(Vector2(x + 30, y + 17), 10, Color("82946d"))
		draw_rect(Rect2(185, 560, 120, 45), Color("87976e"))
	elif kind == "Blacksmith":
		draw_rect(Rect2(150, 220, 130, 120), Color("514b45"))
		draw_rect(Rect2(180, 270, 70, 45), Color("d69a52"))
		draw_rect(Rect2(820, 250, 140, 50), Color("6d7170"))
		draw_rect(Rect2(865, 300, 50, 30), Color("545c58"))
		draw_circle(Vector2(870, 565), 30, Color("798d83"))
	elif kind in ["Town Hall", "Police Box", "Fire Station", "Archive", "Shrine Residence", "Mountain Lodge", "Tea Processing Shed", "Fishing Shop"]:
		var accent := Color("82947c") if kind == "Town Hall" else (Color("80979e") if kind == "Police Box" else Color("ae7964"))
		draw_rect(Rect2(170, 235, 115, 115), Color("e6d5ad"))
		draw_rect(Rect2(185, 250, 85, 85), accent)
		for y in [245, 305, 365]:
			draw_rect(Rect2(815, y, 120, 35), accent)
		draw_rect(Rect2(170, 585, 160, 40), accent)
		if kind == "Tea Processing Shed":
			for y in [245, 305, 365]:
				for x in [835, 870, 905]: draw_circle(Vector2(x, y + 17), 9, Color("82947c"))
		elif kind == "Fishing Shop":
			for x in [825, 865, 905]:
				draw_line(Vector2(x, 250), Vector2(x, 395), Color("d9c998"), 4)
				draw_circle(Vector2(x + 7, 385), 7, Color("697e79"))
		var labels := {"Town Hall": ["Town plan", "Archives", "Waiting seats"], "Police Box": ["Patrol desk", "Lost property", "Waiting seats"], "Fire Station": ["Drill board", "Equipment", "Rest bench"], "Archive": ["Old maps", "Family records", "Reading bench"], "Shrine Residence": ["Festival plan", "Tea cabinet", "Sitting area"], "Mountain Lodge": ["Trail map", "Supplies", "Rest bench"], "Tea Processing Shed": ["Sorting table", "Drying trays", "Packing bench"], "Fishing Shop": ["Gear desk", "Fishing tackle", "Repair bench"]}
		for item in [[labels[kind][0], Vector2(140, 415)], [labels[kind][1], Vector2(790, 455)], [labels[kind][2], Vector2(140, 675)]]:
			draw_string(ThemeDB.fallback_font, item[1], item[0], HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("493b2d"))
	elif kind in ["Inn", "Clinic", "Tea Farmhouse", "Harbor Homes", "Hiro Cabin"]:
		var beds := [Rect2(140, 210, 150, 190), Rect2(810, 210, 150, 190)] if kind in ["Inn", "Tea Farmhouse", "Harbor Homes", "Hiro Cabin"] else [Rect2(800, 210, 155, 240)]
		if kind == "Hiro Cabin": beds = [Rect2(140, 210, 150, 190)]
		for bed in beds:
			draw_rect(bed.grow(-8), Color("e8dbba"))
			draw_rect(Rect2(bed.position + Vector2(15, 15), Vector2(bed.size.x - 30, 40)), Color("f3e9d4"))
			draw_rect(Rect2(bed.position + Vector2(10, 65), bed.size - Vector2(20, 75)), Color("8d9b87") if kind == "Clinic" else Color("a9a783"))
		if kind in ["Inn", "Tea Farmhouse", "Harbor Homes", "Hiro Cabin"]:
			if kind == "Hiro Cabin":
				for y in [245, 305, 365]: draw_rect(Rect2(825, y, 115, 30), Color("8d9b87"))
			draw_rect(Rect2(135, 530, 240, 145), Color("bac096"), false, 5)
			draw_circle(Vector2(245, 590), 20, Color("ded1af"))
			draw_string(ThemeDB.fallback_font, Vector2(140, 435), ({"Inn": "Guest room", "Tea Farmhouse": "Family room", "Harbor Homes": "Ken room", "Hiro Cabin": "Sleeping nook"}[kind]), HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("493b2d"))
			draw_string(ThemeDB.fallback_font, Vector2(805, 435), ({"Inn": "Guest room", "Tea Farmhouse": "Family room", "Harbor Homes": "Masao room", "Hiro Cabin": "Field notes"}[kind]), HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("493b2d"))
		else:
			draw_rect(Rect2(175, 235, 100, 45), Color("dedac6"))
			draw_line(Vector2(225, 245), Vector2(225, 270), Color("9c7768"), 6)
			draw_line(Vector2(213, 257), Vector2(237, 257), Color("9c7768"), 6)
			draw_rect(Rect2(165, 550, 160, 35), Color("8d9b87"))
			draw_string(ThemeDB.fallback_font, Vector2(140, 635), "Waiting area", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("493b2d"))
			draw_string(ThemeDB.fallback_font, Vector2(805, 480), "Treatment", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("493b2d"))
	else:
		for point in [Vector2(245, 490), Vector2(855, 490), Vector2(245, 700), Vector2(855, 700)]:
			draw_circle(point, 24, Color("e5d6b4"))
			draw_circle(point + Vector2(12, -5), 8, Color("735d44"))
			for dx in [-100, 100]: draw_rect(Rect2(point + Vector2(dx - 18, -20), Vector2(36, 40)), Color("7d927b"))
	if lost_item_visible:
		draw_rect(Rect2(210, 465, 40, 32), Color("b58654"))
		draw_rect(Rect2(215, 470, 30, 22), Color("e4cf9c"))
		draw_string(ThemeDB.fallback_font, Vector2(155, 520), "Lost wallet", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("493b2d"))
	
	draw_string(ThemeDB.fallback_font, Vector2(440, 350), "Counter", HORIZONTAL_ALIGNMENT_CENTER, 220, 23, Color("493b2d"))
	draw_string(ThemeDB.fallback_font, Vector2(440, 775), "Town ↓", HORIZONTAL_ALIGNMENT_CENTER, 220, 23, Color("493b2d"))

func nearest_resident(point: Vector2) -> Node2D:
	for resident in residents:
		if resident.visible and resident.position.distance_to(point) < 110: return resident
	return null
func tick(delta: float) -> void:
	for resident in residents:
		if resident.visible: resident.tick(delta)
func rock_box() -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = Color("747970")
	box.set_corner_radius_all(22)
	return box
