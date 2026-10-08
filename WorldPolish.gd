extends Node2D
var farm
var path: Array[Vector2] = []
var grids := {}
var marker := Vector2.ZERO
var marker_time := 0.0
var light: CanvasModulate
var light_time := 0.0
func setup(game) -> void:
	farm = game
	light = CanvasModulate.new()
	add_child(light)
	z_index = 300
func _process(delta: float) -> void:
	if farm == null: return
	light_time -= delta
	if light_time <= 0:
		light_time = 0.5
		light.color = daylight(farm.clock_minutes) if farm.location != "shop" and not farm.inside_house else Color.WHITE
	marker_time = maxf(0,marker_time-delta)
	if marker_time > 0: queue_redraw()
	elif not path.is_empty(): queue_redraw()
static func daylight(minute: float) -> Color:
	var times := [0.0,300.0,420.0,600.0,900.0,1050.0,1140.0,1260.0,1440.0]
	var colors := [Color("687896"),Color("687896"),Color("f5dfc7"),Color.WHITE,Color.WHITE,Color("f2c69f"),Color("bc9fba"),Color("687896"),Color("687896")]
	for i in range(times.size()-1):
		if minute <= times[i+1]: return colors[i].lerp(colors[i+1],clampf((minute-times[i])/(times[i+1]-times[i]),0,1))
	return colors[-1]
func _unhandled_input(event: InputEvent) -> void:
	if farm == null or farm.choosing_character or farm.dialogue_open or farm.confirming_sleep or farm.paused_by_player: return
	if event is InputEventScreenTouch and event.pressed: tap(event.position)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed: tap(event.position)
func area_node():
	if farm.location == "shop": return farm.shops[farm.shop_name]
	if farm.inside_house: return farm.interior
	if farm.location == "town": return farm.town
	if farm.regions.has(farm.location): return farm.regions[farm.location]
	return farm
func area_origin() -> Vector2:
	if farm.location == "shop": return farm.SHOP_ORIGIN
	if farm.inside_house: return farm.ROOM_ORIGIN
	if farm.location == "town": return farm.TOWN_ORIGIN
	if farm.regions.has(farm.location): return farm.REGION_ORIGINS[farm.location]
	return Vector2.ZERO
func tap(screen: Vector2) -> void:
	var world: Vector2 = farm.get_canvas_transform().affine_inverse() * screen
	plan(world)
	get_viewport().set_input_as_handled()
func plan(world: Vector2) -> void:
	path.clear()
	var area = area_node()
	var origin := area_origin()
	var dimensions: Vector2 = farm.WORLD if area == farm else area.SIZE
	var local := world-origin
	if not Rect2(Vector2.ZERO,dimensions).has_point(local): return
	var key: String = farm.location + str(farm.inside_house) + farm.shop_name + str(dimensions)
	if not grids.has(key):
		var grid := AStarGrid2D.new()
		grid.region = Rect2i(Vector2i.ZERO,Vector2i(ceil(dimensions.x/32),ceil(dimensions.y/32)))
		grid.cell_size = Vector2(32,32)
		grid.offset = Vector2(16,16)
		grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
		grid.update()
		for y in range(grid.region.size.y):
			for x in range(grid.region.size.x):
				var point := Vector2(x*32+16,y*32+16)
				var clear: bool = area.is_walkable(point) if area.has_method("is_walkable") else false
				if area == farm.interior: clear = farm.interior.FLOOR.grow(-16).has_point(point) and not blocked(point+origin)
				grid.set_point_solid(Vector2i(x,y),not clear)
		grids[key] = grid
	var grid: AStarGrid2D = grids[key]
	var start := nearest_cell(grid,Vector2i((farm.player.position-origin)/32))
	var goal := nearest_cell(grid,Vector2i(local/32))
	for point in grid.get_point_path(start,goal): path.append(point+origin)
	if path.is_empty(): farm.say("That spot is blocked. Tap an open path."); return
	marker = path[-1]
	marker_time = 1.0
	queue_redraw()
func blocked(point: Vector2) -> bool:
	var query := PhysicsPointQueryParameters2D.new()
	query.position = point
	query.collision_mask = farm.player.collision_mask
	return not farm.get_world_2d().direct_space_state.intersect_point(query,1).is_empty()
func nearest_cell(grid: AStarGrid2D, cell: Vector2i) -> Vector2i:
	cell.x = clampi(cell.x,0,grid.region.size.x-1)
	cell.y = clampi(cell.y,0,grid.region.size.y-1)
	if not grid.is_point_solid(cell): return cell
	var nearest := cell
	var distance := INF
	for radius in range(1,8):
		for y in range(maxi(0,cell.y-radius),mini(grid.region.size.y-1,cell.y+radius)+1):
			for x in range(maxi(0,cell.x-radius),mini(grid.region.size.x-1,cell.x+radius)+1):
				var candidate := Vector2i(x,y)
				if grid.is_point_solid(candidate): continue
				var candidate_distance := Vector2(candidate-cell).length_squared()
				if candidate_distance < distance:
					nearest=candidate
					distance=candidate_distance
		if distance < float(radius*radius): return nearest
	return nearest
func direction(manual: Vector2) -> Vector2:
	if manual.length() > 0.1: path.clear(); return manual
	while not path.is_empty() and farm.player.position.distance_to(path[0]) < 12: path.pop_front()
	return (path[0]-farm.player.position).normalized() if not path.is_empty() else Vector2.ZERO
func nearest_pet():
	for pet in farm.town.pets:
		if pet.is_visible_in_tree() and pet.global_position.distance_to(farm.player.position) < 95: return pet
	return null
func pet_animal() -> void:
	var pet = nearest_pet()
	if pet == null: return
	pet.wait = 5.0
	pet.resting = false
	pet.facing = signf(farm.player.global_position.x-pet.global_position.x)
	pet.affection_time = 2.0
	pet.update_shiba()
	farm.player.velocity = Vector2.ZERO
	path.clear()
	farm.say("The cat leans into your hand and purrs." if pet.kind == "cat" else ("The Shiba wags its curled tail!" if pet.kind == "shiba" else "The dog wags its tail and enjoys a gentle pat."))
func _draw() -> void:
	if marker_time > 0:
		draw_arc(marker,18,0,TAU,24,Color(0.96,0.89,0.7,marker_time),3)
