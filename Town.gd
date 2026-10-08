extends Node2D
var festival_decorated := false

const SIZE := Vector2(2400, 1600)
const ART_SCALE := 1.0
const NpcScript = preload("res://Npc.gd")
const Cast = preload("res://Cast.gd")
const SpriteLibrary = preload("res://SpriteLibrary.gd")
const BUILDINGS := [
	{"name":"Town Hall","rect":Rect2(1055, 187.407, 344, 265.926),"door":Vector2(1225, 481.481)},
	{"name":"Clinic","rect":Rect2(609, 257.778, 297, 190.555),"door":Vector2(762, 473.333)},
	{"name":"General Store","rect":Rect2(481, 553.333, 286, 203.148),"door":Vector2(620, 781.481)},
	{"name":"Café","rect":Rect2(844, 531.111, 250, 225.37),"door":Vector2(997, 781.481)},
	{"name":"Archive","rect":Rect2(1562, 339.259, 344, 221.667),"door":Vector2(1719, 585.926)},
	{"name":"Blacksmith","rect":Rect2(1719, 715.556, 308, 197.222),"door":Vector2(1888, 937.778)},
	{"name":"Inn","rect":Rect2(950, 1017.04, 288, 231.29),"door":Vector2(1086, 1273.33)},
	{"name":"Police Box","rect":Rect2(638, 862.222, 269, 212.778),"door":Vector2(772, 1100)},
	{"name":"Fire Station","rect":Rect2(1400, 1011.11, 250, 221.67),"door":Vector2(1509, 1257.78)},
	{"name":"Carpentry","rect":Rect2(1828, 1031.11, 367, 225.37),"door":Vector2(1930, 1281.48)}
]
var npcs: Array[Node2D] = []
var visitors: Array[Node2D] = []
var pets: Array[Node2D] = []
var ambient_period := -1
var greeting_time := 0.0
const EXTRA_DIALOGUE := {
	"Ren": ["I'm Ren. I prepare the mountain onsen baths and keep the resort running.", "The water is warmest when the morning air is cool. Come by for a soak."],
	"Chanel": ["I am Chanel. I welcome guests at the mountain onsen.", "Stop by for a quiet soak after working on the farm."],
	"David": ["David here. I carry deliveries between the general store and harbor.", "If you see a sleepy dog on the road, give it a little room."],
	"Renji": ["I'm Renji. I help Kenta prepare timber and build at the workshops.", "We work near the mountains in the morning and in town after lunch."],
	"Midori": ["I'm Midori. I tend the tea fields and the onsen gardens.", "I like giving each season a little corner of the garden."]
}
const REST_BENCHES := [Rect2(1540, 562.963, 105, 23.7037), Rect2(865, 800, 105, 23.7037)]
var solids: Array[Rect2] = []
var navigation := AStarGrid2D.new()
var land_outline := PackedVector2Array()
const TREE_CLUSTERS := []

func _ready() -> void:
	for point in preload("res://ApprovedMapLayout.gd").spec("town").land: land_outline.append(Vector2(point[0],point[1]))
	var background := Sprite2D.new()
	background.texture = preload("res://assets/map-town-open-v2.png")
	background.centered = false
	background.scale = SIZE / Vector2(background.texture.get_size())
	background.z_index = -10
	add_child(background)
	for scenery in preload("res://ApprovedMapLayout.gd").scenery("town"):
		solids.append(scenery)
		add_obstacle(scenery)
	for building in BUILDINGS:
		var rect: Rect2 = building.rect
		rect = Rect2(rect.position * ART_SCALE, rect.size * ART_SCALE)
		solids.append(rect)
		add_obstacle(rect)
		pass # Physical name boards are included in the approved map artwork.
	for rect in [Rect2(-24, -17.7778, 2448, 17.7778), Rect2(-24, 1600, 2448, 17.7778), Rect2(-24, 0, 24, 1600), Rect2(2400, 0, 24, 1600)]: add_obstacle(rect)
	add_label("South · Farm", Vector2(1020, 1511.11), Vector2(360, 29.6296))
	add_label("North · Mountain & Lake", Vector2(980, 37.037), Vector2(440, 29.6296))
	add_label("West · Harbor", Vector2(260, 750), Vector2(290, 29.6296))
	add_label("East · Tea Country", Vector2(2030, 648.148), Vector2(340, 29.6296))
	add_label("Northwest · Shrine", Vector2(350, 300), Vector2(340, 40))
	add_label("Events", Vector2(1260, 511.111), Vector2(180, 23.7037))
	var board := Rect2(1310, 455.556, 80, 48.1481)
	var fountain := Rect2(1280, 696.296, 130, 133.333)
	solids.append(fountain)
	add_obstacle(fountain)
	solids.append(board)
	add_obstacle(board)
	for bench in REST_BENCHES:
		solids.append(bench)
		add_obstacle(bench)
	for cluster in TREE_CLUSTERS:
		var body := StaticBody2D.new()
		body.position=cluster[0]; body.collision_layer=4; body.collision_mask=0
		var collider := CollisionShape2D.new()
		var shape := CircleShape2D.new()
		shape.radius=cluster[1]; collider.shape=shape
		body.add_child(collider); add_child(body)
	navigation.region = Rect2i(0, 0, 60, 40)
	navigation.cell_size = Vector2(40, 40)
	navigation.offset = Vector2(20, 20)
	navigation.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	navigation.update()
	for y in range(40):
		for x in range(60):
			navigation.set_point_solid(Vector2i(x, y), not is_npc_walkable(Vector2(x * 40 + 20, y * 40 + 20)))
	var positions := [Vector2(750, 651.852), Vector2(780, 970.37), Vector2(1200, 377.778), Vector2(1150, 1140.74)]
	var names := ["Seira", "Shohei", "Akira", "Taro"]
	for i in range(4):
		var npc := NpcScript.new()
		add_child(npc)
		npc.position = positions[i]
		npc.setup(names[i], preload("res://CharacterArt.gd").walk(names[i]))
		npc.z_index = 4
		npcs.append(npc)
	update_schedules(360.0)
	add_ambient_life()

func add_obstacle(rect: Rect2) -> void:
	var body := StaticBody2D.new()
	body.collision_layer = 4
	body.collision_mask = 0
	body.position = rect.get_center()
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = rect.size
	collision.shape = shape
	body.add_child(collision)
	add_child(body)

func add_label(text: String, where: Vector2, dimensions: Vector2) -> void:
	var label := Label.new()
	label.text = text
	label.position = where
	label.size = dimensions
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 22)
	label.add_theme_color_override("font_color", Color("403a2c"))
	label.add_theme_color_override("font_shadow_color", Color("f4e3bb"))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	add_child(label)

func update_schedules(minute: float) -> void:
	var period := 0 if minute < 720 else (1 if minute < 1080 else 2)
	for i in range(mini(4, npcs.size())):
		var npc = npcs[i]
		if npc.period == period: continue
		npc.period = period
		var routes: Array = []
		# Routes follow door lanes and the central road, never cross facades.
		match i:
			0:
				routes = [Vector2(570, 603.704), Vector2(960, 603.704), Vector2(960, 674.074), Vector2(570, 603.704)] if period == 0 else [Vector2(1200, 674.074), Vector2(1900, 607.407), Vector2(1200, 674.074), Vector2(570, 603.704)]
			1:
				routes = [Vector2(515, 970.37), Vector2(930, 970.37), Vector2(930, 888.889)] if period == 0 else [Vector2(1200, 970.37), Vector2(1200, 674.074), Vector2(1600, 674.074), Vector2(1200, 970.37)]
			2:
				routes = [Vector2(1200, 340.741), Vector2(675, 340.741), Vector2(1200, 340.741)] if period == 0 else [Vector2(1200, 340.741), Vector2(1200, 674.074), Vector2(960, 603.704), Vector2(1200, 674.074)]
			3:
				routes = [Vector2(1200, 1218.52), Vector2(1200, 674.074), Vector2(1200, 340.741), Vector2(1200, 674.074)]
		if period == 2:
				routes = [Vector2(1200, 674.074), Vector2(1830, 959.259), Vector2(1200, 959.259)] if i != 3 else [Vector2(1200, 1218.52), Vector2(1200, 674.074)]
		settle_on_road(npc)
		npc.set_route(walk_route(npc.position, routes.slice(0,1)))

func add_supporting_cast() -> void:
	for person in Cast.HOMES:
		var npc := NpcScript.new()
		add_child(npc)
		npc.position = Cast.HOMES[person]
		var source := Cast.index_of(person)
		var walk_path := "res://assets/npc-%s-walk.png" % person.to_lower()
		if preload("res://CharacterArt.gd").walk(person) != null: npc.setup(person, preload("res://CharacterArt.gd").walk(person))
		else: npc.setup_turnaround(person, SpriteLibrary.turnaround(source.x), source.y, source.x)
		npc.z_index = 4
		npcs.append(npc)
	update_supporting_routes(360)

func update_supporting_routes(minute: float) -> void:
	var period := 0 if minute < 720 else (1 if minute < 1080 else 2)
	for i in range(4, npcs.size()):
		var npc = npcs[i]
		if npc.period == period: continue
		npc.period = period
		var home: Vector2 = Cast.HOMES[npc.first_name]
		var lane := Vector2(1200, home.y)
		var route: Array = [home, lane, home + Vector2(45, 0)]
		if period == 1:
			route = [home, lane, Vector2(1200, 674.074), Vector2(1450 + (i % 3) * 80, 910), Vector2(1200, 674.074), lane, home]
		settle_on_road(npc)
		npc.set_route(walk_route(npc.position, route.slice(0,1)))

func walk_route(start: Vector2, destinations: Array) -> Array:
	var points: Array = []
	var previous := start
	var loop := destinations.duplicate()
	# Scheduled trips end at the destination; residents settle rather than loop.
	for destination in loop:
		var from := Vector2i(clampi(int(previous.x / 40), 0, 59), clampi(int(previous.y / 40), 0, 39))
		var to := Vector2i(clampi(int(destination.x / 40), 0, 59), clampi(int(destination.y / 40), 0, 39))
		if navigation.is_point_solid(to):
			to = nearest_clear_cell(to)
		if navigation.is_point_solid(from): from = nearest_clear_cell(from)
		var segment := navigation.get_point_path(from, to)
		for point in segment:
			if points.is_empty() or points[-1].distance_to(point) > 1: points.append(point)
		previous = destination
	return points

func settle_on_road(npc) -> void:
	if is_npc_walkable(npc.position): return
	var cell := nearest_clear_cell(Vector2i(npc.position / 40))
	npc.position = navigation.get_point_position(cell)

func nearest_clear_cell(cell: Vector2i) -> Vector2i:
	cell=Vector2i(clampi(cell.x,0,59),clampi(cell.y,0,39))
	for radius in range(1, 8):
		for y in range(maxi(0, cell.y - radius), mini(39, cell.y + radius) + 1):
			for x in range(maxi(0, cell.x - radius), mini(59, cell.x + radius) + 1):
				if not navigation.is_point_solid(Vector2i(x, y)): return Vector2i(x, y)
	return Vector2i(30, 22)

func tick(delta: float, minute: float, rainy: bool = false) -> void:
	update_schedules(minute)
	update_supporting_routes(minute)
	for npc in npcs:
		if not npc.visible: continue
		if not is_npc_walkable(npc.position): settle_on_road(npc)
		npc.tick(delta)
		npc.z_index = clampi(int(npc.position.y / 10), 1, 179)
	for i in range(npcs.size()):
		for j in range(i + 1, npcs.size()):
			var first = npcs[i]
			var second = npcs[j]
			if not first.visible or not second.visible: continue
			var difference: Vector2 = first.position - second.position
			var distance := difference.length()
			if distance >= 55: continue
			if distance < 0.1: difference = Vector2(1, 0)
			var push := difference.normalized() * minf(20 * delta, (55 - distance) * 0.5)
			if not first.paused and is_walkable(first.position + push): first.position += push
			if not second.paused and is_walkable(second.position - push): second.position -= push

func is_walkable(point: Vector2) -> bool:
	for offset in [Vector2.ZERO,Vector2(12,0),Vector2(-12,0),Vector2(0,12),Vector2(0,-12)]:
		if not Geometry2D.is_point_in_polygon(point+offset,land_outline): return false
	if not Rect2(Vector2(24, 24), SIZE - Vector2(48, 48)).has_point(point): return false
	for cluster in TREE_CLUSTERS:
		if point.distance_to(cluster[0]) < float(cluster[1])+16: return false
	for rect in solids:
		if rect.grow(16).has_point(point): return false
	return true

func nearest_npc(point: Vector2) -> Node2D:
	var result: Node2D
	var distance := 120.0
	for npc in get_children():
		if not npc.get_script() == NpcScript or not npc.visible: continue
		var candidate := point.distance_to(npc.position)
		if candidate < distance:
			distance = candidate
			result = npc
	return result

func nearest_service(point: Vector2) -> String:
	for building in BUILDINGS:
		if point.distance_to(building.door * ART_SCALE) < 110.0: return building.name
	return ""

func _draw() -> void:
	for bench in REST_BENCHES:
		for dx in [8,87]: draw_rect(Rect2(bench.position+Vector2(dx,8),Vector2(9,22)),Color("624830"))
		draw_rect(bench,Color("aa7849"))
		for dy in [2,10,19]: draw_line(bench.position+Vector2(0,dy),bench.position+Vector2(105,dy),Color("d0a16b"),3)
		draw_rect(Rect2(bench.position-Vector2(0,14),Vector2(105,12)),Color("9a693e"))
	if festival_decorated:
		for y in [720, 1100]:
			draw_line(Vector2(1000, y), Vector2(1400, y), Color("765b3b"), 3)
			for i in range(9):
				var x := 1010 + i * 45
				draw_colored_polygon(PackedVector2Array([Vector2(x, y), Vector2(x + 24, y), Vector2(x + 12, y + 28)]), Color("a66b52") if i % 2 == 0 else Color("e6d3a5"))
	draw_rect(Rect2(1324, 500, 8, 25.9259), Color("765b3b"))
	draw_rect(Rect2(1368, 500, 8, 25.9259), Color("765b3b"))
	draw_rect(Rect2(1310, 455.556, 80, 48.1481), Color("765b3b"))
	draw_rect(Rect2(1318, 461.481, 64, 36.2963), Color("eddbb1"))
	draw_line(Vector2(1326, 470.37), Vector2(1373, 470.37), Color("907c5a"), 4)
	draw_line(Vector2(1326, 480), Vector2(1360, 480), Color("907c5a"), 4)

func update_label_visibility(point: Vector2) -> void:
	for child in get_children():
		if child is Label:
			child.visible = point.distance_to(child.position + child.size / 2) < 430
func add_ambient_life() -> void:
	var names := ["Ren", "Chanel", "David", "Renji", "Midori"]
	for i in range(5):
		var npc := NpcScript.new()
		add_child(npc)
		npc.setup(names[i], preload("res://CharacterArt.gd").walk(names[i]))
		npc.first_name = names[i]
		npc.label.text = names[i]
		npc.position = Vector2(1140 + i * 90, 950)
		npc.speed = 65 + i * 4
		visitors.append(npc)
	for i in range(5):
		var pet := preload("res://AmbientPet.gd").new()
		pet.kind = "shiba" if i == 4 else ("dog" if i < 2 else "cat")
		pet.artwork = "res://assets/%s-walk-rest-v1.png" % ["tan-dog", "cream-dog", "gray-cat", "orange-cat", "shiba"][i]
		add_child(pet)
		pet.coat = [Color("c49b70"), Color("ede0ca"), Color("777f87"), Color("ce9161"), Color("d5a064")][i]
		pet.position = Vector2(1120 + i * 35, 1100)
		pet.route = walk_route(pet.position, [Vector2(1200, 910 + i*60), Vector2(1400, 674.074), Vector2(1200, 925.926)])
		pets.append(pet)

func tick_ambient(delta: float, minute: float, rainy: bool, rooms: Dictionary = {}, regions: Dictionary = {}) -> void:
	var period := (0 if minute < 720 else (1 if minute < 1080 else (2 if minute<1260 else 3))) + (4 if rainy else 0)
	if period != ambient_period:
		ambient_period = period
		for i in range(visitors.size()):
			var npc = visitors[i]
			var destination = self
			var point := Vector2(1200, 674.074)
			if not rooms.is_empty() and not regions.is_empty():
				match npc.first_name:
					"Chanel": destination = rooms["Onsen Resort"]; point = Vector2(530, 288.889)
					"Ren":
						destination = rooms["Onsen Resort"] if minute >= 720 or rainy else regions.mountain
						point = Vector2(690, 377.778) if destination == rooms["Onsen Resort"] else Vector2(530, 432.593)
					"Renji": destination = rooms["Mountain Carpentry" if minute < 720 else "Carpentry"]; point = Vector2(730, 385.185)
					"David":
						destination = regions.harbor if minute < 720 and not rainy else rooms["General Store"]
						point = Vector2(1020, 444.444) if destination == regions.harbor else Vector2(730, 444.444)
					"Midori": destination = rooms["Tea Farmhouse"] if rainy else regions.tea; point = Vector2(730, 422.222) if rainy else Vector2(1060, 518.519)
				if minute >= 1260: destination = rooms["Inn"]; point = Vector2(450+(i%3)*110,510+(i/3)*90)
			else: point = Vector2(1200,520+i*260)
			if npc.get_parent() != destination: npc.reparent(destination,false)
			npc.position = destination.safe_npc_point(point) if destination.has_method("safe_npc_point") else destination.safe_point(point) if destination.has_method("safe_point") else point
			npc.set_route([])
			npc.show_frame(0,1)
		for i in range(pets.size()):
			var pet = pets[i]
			if not regions.is_empty() and i >= 2:
				var area = regions[["historic", "harbor", "tea"][i-2]]
				if pet.get_parent() != area:
					pet.reparent(area)
					pet.position = area.safe_point(Vector2(620+(i-2)*170,600))
				pet.route = [pet.position, pet.position + Vector2(0, 25.9259)]
				if rainy: pet.route = [area.safe_point(Vector2(640+(i-2)*160,430))]
				pet.index = 0
				continue
			var shelter := Vector2(1450 + i * 45, 1310)
			pet.position = Vector2(900+i*900,850)
			settle_on_road(pet)
			pet.route = walk_route(pet.position,[shelter] if rainy else [pet.position+Vector2(35, 0)])
			pet.index = 0
	for npc in visitors:
		npc.tick(delta)
		npc.z_index = clampi(int(npc.position.y / 10), 1, 215)
	for pet in pets:
		pet.tick(delta)
		pet.z_index = clampi(int(pet.position.y / 10), 1, 215)
	greeting_time -= delta
	if greeting_time <= 0:
		greeting_time = 12.0
		for i in range(visitors.size()):
			var npc = visitors[i]
			npc.label.text = npc.first_name
			for other in visitors:
				if other != npc and other.get_parent() == npc.get_parent() and npc.position.distance_to(other.position) < 120:
					npc.label.text = "Hello, " + other.first_name + "!"
					npc.face_player(other.global_position)
					break
	elif greeting_time < 9:
		for npc in visitors: npc.label.text = npc.first_name

func is_npc_walkable(point: Vector2) -> bool:
	for building in BUILDINGS:
		var door: Vector2 = building.door*ART_SCALE
		if absf(point.x-door.x)<maxf(100,building.rect.size.x*ART_SCALE*0.5+30) and point.y>door.y-35 and point.y<door.y+170: return false
	if not is_walkable(point): return false
	return preload("res://ApprovedMapLayout.gd").is_path("town",point,SIZE)

static func design(point: Vector2) -> Vector2: return point*Vector2(1.0,1600.0/2160.0)
