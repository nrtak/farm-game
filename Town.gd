extends Node2D
var festival_decorated := false

const SIZE := Vector2(2400, 2160)
const ART_SCALE := 2400.0 / 1448.0
const NpcScript = preload("res://Npc.gd")
const Cast = preload("res://Cast.gd")
const SpriteLibrary = preload("res://SpriteLibrary.gd")
const BUILDINGS := [
	{"name":"Carpentry","rect":Rect2(190,1050,250,135),"door":Vector2(315,1210)},
	{"name": "Town Hall", "rect": Rect2(245, 40, 300, 205), "door": Vector2(405, 265)},
	{"name": "Clinic", "rect": Rect2(975, 45, 235, 205), "door": Vector2(1080, 265)},
	{"name": "General Store", "rect": Rect2(205, 300, 280, 155), "door": Vector2(345, 475)},
	{"name": "Café", "rect": Rect2(1015, 300, 285, 160), "door": Vector2(1165, 480)},
	{"name": "Blacksmith", "rect": Rect2(170, 555, 305, 200), "door": Vector2(310, 780)},
	{"name": "Inn", "rect": Rect2(920, 565, 370, 195), "door": Vector2(1100, 790)},
	{"name": "Police Box", "rect": Rect2(325, 820, 190, 165), "door": Vector2(420, 1005)},
	{"name": "Fire Station", "rect": Rect2(900, 805, 310, 180), "door": Vector2(1050, 1005)}
]
var npcs: Array[Node2D] = []
var visitors: Array[Node2D] = []
var pets: Array[Node2D] = []
var ambient_period := -1
var greeting_time := 0.0
const EXTRA_DIALOGUE := {
	"Ren": ["I'm Ren. I like sketching the mountain from the plaza.", "Blue hair is easier to spot when my friends come looking for me!"],
	"Chanel": ["I'm Chanel. A little shopping, then tea at Naomi's café—that's my afternoon.", "It's lovely seeing the old farm come back to life."],
	"David": ["David here. I help carry deliveries around town.", "If you see a sleepy dog on the road, give it a little room."],
	"Renji": ["I'm Renji. I stop by the forge to see what Shohei is making.", "There is always someone to meet around the plaza."],
	"Midori": ["I'm Midori. I love the gardens around town.", "Green hair, green plants... I suppose I have a favorite color."]
}
var solids: Array[Rect2] = []
var navigation := AStarGrid2D.new()

func _ready() -> void:
	var background := Sprite2D.new()
	background.texture = preload("res://assets/town-background-v1.png")
	background.centered = false
	background.scale = Vector2.ONE * ART_SCALE
	background.z_index = -10
	add_child(background)
	for building in BUILDINGS:
		var rect: Rect2 = building.rect
		rect = Rect2(rect.position * ART_SCALE, rect.size * ART_SCALE)
		solids.append(rect)
		add_obstacle(rect)
		add_label(building.name, building.door * ART_SCALE + Vector2(-130, 25), Vector2(260, 35))
	for rect in [Rect2(-24, -24, 2448, 24), Rect2(-24, 2160, 2448, 24), Rect2(-24, 0, 24, 2160), Rect2(2400, 0, 24, 2160)]: add_obstacle(rect)
	add_label("South · Farm", Vector2(1020, 2040), Vector2(360, 40))
	add_label("North · Mountain & Lake", Vector2(980, 50), Vector2(440, 40))
	add_label("West · Harbor", Vector2(20, 875), Vector2(290, 40))
	add_label("East · Tea Country", Vector2(2030, 875), Vector2(340, 40))
	add_label("Northwest · Shrine", Vector2(20, 370), Vector2(340, 40))
	add_label("Events", Vector2(1260, 690), Vector2(180, 32))
	var board := Rect2(1310, 615, 80, 65)
	solids.append(board)
	add_obstacle(board)
	navigation.region = Rect2i(0, 0, 60, 54)
	navigation.cell_size = Vector2(40, 40)
	navigation.offset = Vector2(20, 20)
	navigation.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	navigation.update()
	for y in range(54):
		for x in range(60):
			navigation.set_point_solid(Vector2i(x, y), not is_walkable(Vector2(x * 40 + 20, y * 40 + 20)))
	var positions := [Vector2(750, 880), Vector2(780, 1310), Vector2(1200, 510), Vector2(1150, 1540)]
	var names := ["Seira", "Shohei", "Akira", "Taro"]
	for i in range(4):
		var npc := NpcScript.new()
		add_child(npc)
		npc.position = positions[i]
		npc.setup(names[i], load("res://assets/npc-%s-walk.png" % names[i].to_lower()))
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
				routes = [Vector2(570, 815), Vector2(960, 815), Vector2(960, 910), Vector2(570, 815)] if period == 0 else [Vector2(1200, 910), Vector2(1900, 820), Vector2(1200, 910), Vector2(570, 815)]
			1:
				routes = [Vector2(515, 1310), Vector2(930, 1310), Vector2(930, 1200)] if period == 0 else [Vector2(1200, 1310), Vector2(1200, 910), Vector2(1600, 910), Vector2(1200, 1310)]
			2:
				routes = [Vector2(1200, 460), Vector2(675, 460), Vector2(1200, 460)] if period == 0 else [Vector2(1200, 460), Vector2(1200, 910), Vector2(960, 815), Vector2(1200, 910)]
			3:
				routes = [Vector2(1200, 1645), Vector2(1200, 910), Vector2(1200, 460), Vector2(1200, 910)]
		if period == 2:
				routes = [Vector2(1200, 910), Vector2(1830, 1295), Vector2(1200, 1295)] if i != 3 else [Vector2(1200, 1645), Vector2(1200, 910)]
		npc.set_route(walk_route(npc.position, routes))

func add_supporting_cast() -> void:
	for person in Cast.HOMES:
		var npc := NpcScript.new()
		add_child(npc)
		npc.position = Cast.HOMES[person]
		var source := Cast.index_of(person)
		var walk_path := "res://assets/npc-%s-walk.png" % person.to_lower()
		if ResourceLoader.exists(walk_path): npc.setup(person, load(walk_path))
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
			route = [home, lane, Vector2(1200, 910), Vector2(1450 + (i % 3) * 80, 910), Vector2(1200, 910), lane, home]
		npc.set_route(walk_route(npc.position, route))

func walk_route(start: Vector2, destinations: Array) -> Array:
	var points: Array = []
	var previous := start
	var loop := destinations.duplicate()
	if not destinations.is_empty(): loop.append(start)
	for destination in loop:
		var from := Vector2i(clampi(int(previous.x / 40), 0, 59), clampi(int(previous.y / 40), 0, 53))
		var to := Vector2i(clampi(int(destination.x / 40), 0, 59), clampi(int(destination.y / 40), 0, 53))
		if navigation.is_point_solid(to):
			to = nearest_clear_cell(to)
		if navigation.is_point_solid(from): from = nearest_clear_cell(from)
		var segment := navigation.get_point_path(from, to)
		for point in segment:
			if points.is_empty() or points[-1].distance_to(point) > 1: points.append(point)
		previous = destination
	return points

func nearest_clear_cell(cell: Vector2i) -> Vector2i:
	for radius in range(1, 8):
		for y in range(maxi(0, cell.y - radius), mini(53, cell.y + radius) + 1):
			for x in range(maxi(0, cell.x - radius), mini(59, cell.x + radius) + 1):
				if not navigation.is_point_solid(Vector2i(x, y)): return Vector2i(x, y)
	return Vector2i(30, 22)

func tick(delta: float, minute: float, rainy: bool = false) -> void:
	update_schedules(minute)
	update_supporting_routes(minute)
	for npc in npcs:
		if not npc.visible: continue
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
	if not Rect2(Vector2(24, 24), SIZE - Vector2(48, 48)).has_point(point): return false
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
	draw_texture_rect_region(preload("res://assets/town-background-v1.png"), Rect2(0, 1798, 2400, 362), Rect2(0, 1000, 1448, 86))
	draw_rect(Rect2(1090, 1798, 220, 362), Color("dbc48f"))
	var workshop := Rect2(190*ART_SCALE,1050*ART_SCALE,250*ART_SCALE,135*ART_SCALE)
	draw_rect(workshop,Color("b99a70"))
	draw_colored_polygon(PackedVector2Array([workshop.position+Vector2(-15,0),workshop.position+Vector2(workshop.size.x/2,-70),workshop.position+Vector2(workshop.size.x+15,0)]),Color("6e7c70"))
	draw_rect(Rect2(workshop.get_center()+Vector2(-25,20),Vector2(50,90)),Color("75563b"))
	if festival_decorated:
		for y in [720, 1100]:
			draw_line(Vector2(1000, y), Vector2(1400, y), Color("765b3b"), 3)
			for i in range(9):
				var x := 1010 + i * 45
				draw_colored_polygon(PackedVector2Array([Vector2(x, y), Vector2(x + 24, y), Vector2(x + 12, y + 28)]), Color("a66b52") if i % 2 == 0 else Color("e6d3a5"))
	draw_rect(Rect2(1324, 675, 8, 35), Color("765b3b"))
	draw_rect(Rect2(1368, 675, 8, 35), Color("765b3b"))
	draw_rect(Rect2(1310, 615, 80, 65), Color("765b3b"))
	draw_rect(Rect2(1318, 623, 64, 49), Color("eddbb1"))
	draw_line(Vector2(1326, 635), Vector2(1373, 635), Color("907c5a"), 4)
	draw_line(Vector2(1326, 648), Vector2(1360, 648), Color("907c5a"), 4)

func update_label_visibility(point: Vector2) -> void:
	for child in get_children():
		if child is Label:
			child.visible = point.distance_to(child.position + child.size / 2) < 430
func add_ambient_life() -> void:
	var names := ["Ren", "Chanel", "David", "Renji", "Midori"]
	for i in range(5):
		var npc := NpcScript.new()
		add_child(npc)
		npc.setup(names[i], load("res://assets/npc-%s-walk-v1.png" % names[i].to_lower()))
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
		pet.route = walk_route(pet.position, [Vector2(1200, 910 + i*60), Vector2(1400, 910), Vector2(1200, 1250)])
		pets.append(pet)

func tick_ambient(delta: float, minute: float, rainy: bool, rooms: Dictionary = {}, regions: Dictionary = {}) -> void:
	var period := (0 if minute < 720 else (1 if minute < 1080 else 2)) + (3 if rainy else 0)
	if period != ambient_period:
		ambient_period = period
		var hangouts := [Vector2(1200, 520), Vector2(1880, 820), Vector2(1200, 1300), Vector2(820, 1310), Vector2(980, 910)]
		for i in range(visitors.size()):
			var npc = visitors[i]
			var destination: Vector2 = hangouts[(i + period) % hangouts.size()]
			if rainy or minute >= 1080: destination = Vector2(1820 + (i%2)*80, 1310 + (i/2)*45)
			if (rainy or minute >= 1080) and not rooms.is_empty():
				var room = rooms["Café" if i % 2 == 0 and minute < 1080 else "Inn"]
				if npc.get_parent() != room:
					npc.reparent(room)
					npc.position = Vector2(410 + (i % 3)*110, 510 + (i%2)*95)
				npc.set_route([npc.position, npc.position + Vector2(0, 45)])
			elif not regions.is_empty() and i >= 2:
				var area = regions[["harbor", "mountain", "tea"][(i-2+period)%3]]
				if npc.get_parent() != area:
					npc.reparent(area)
					npc.position = Vector2(650 + (i-2)*130, 610)
				npc.set_route([npc.position, Vector2(800, 760), Vector2(800, 610)])
			else:
				if npc.get_parent() != self:
					npc.reparent(self)
					npc.position = Vector2(1200 + i*60, 910)
				npc.set_route(walk_route(npc.position, [destination, destination + Vector2(60, 0)]))
		for i in range(pets.size()):
			var pet = pets[i]
			if not regions.is_empty() and i >= 2:
				var area = regions[["historic", "harbor", "tea"][i-2]]
				if pet.get_parent() != area:
					pet.reparent(area)
					pet.position = Vector2(620 + (i-2)*170, 600)
				pet.route = [pet.position, Vector2(800, 720), Vector2(800, 610)]
				if rainy: pet.route = [Vector2(640 + (i-2)*160, 430)]
				pet.index = 0
				continue
			var shelter := Vector2(1450 + i * 45, 1310)
			pet.route = walk_route(pet.position, [shelter, shelter + Vector2(30,0)] if rainy else [Vector2(700 + i*900, 960), Vector2(820 + i*850, 1100)])
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
