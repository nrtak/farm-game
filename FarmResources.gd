extends Node2D

const WELL := Vector2(530, 970)
const WATER_CAPACITY := 24
const WOOD_SPOTS := {"farm": [Vector2(350,1400),Vector2(650,1640),Vector2(1950,1640),Vector2(850,700)], "mountain": [Vector2(620,670),Vector2(1030,740),Vector2(880,970)]}
var farm
var action_time := 0.0
var action_kind := ""
var target := Vector2.ZERO
var last_view := ""
func setup(game) -> void:
	farm = game
	z_index = 190
func state() -> Dictionary:
	if not farm.interior_progress.has("resources"):
		farm.interior_progress.resources = {"water":WATER_CAPACITY,"lumber":0,"chopped":{},"irrigation":0}
	var data: Dictionary = farm.interior_progress.resources
	data.water = clampi(int(data.get("water",WATER_CAPACITY)),0,WATER_CAPACITY)
	data.lumber = clampi(int(data.get("lumber",0)),0,9999)
	data.irrigation = clampi(int(data.get("irrigation",0)),0,2)
	if not data.get("chopped",{}) is Dictionary: data.chopped = {}
	return data
func wood_index() -> int:
	if farm.inside_house or not WOOD_SPOTS.has(farm.location): return -1
	var origin: Vector2 = farm.REGION_ORIGINS.mountain if farm.location == "mountain" else Vector2.ZERO
	for i in range(WOOD_SPOTS[farm.location].size()):
		var key: String = farm.location+str(i)
		if farm.day-int(state().chopped.get(key,-10)) < 4: continue
		if farm.location=="farm" and not farm.is_walkable(WOOD_SPOTS.farm[i]): continue
		if farm.player.position.distance_to(origin+WOOD_SPOTS[farm.location][i]) < 90: return i
	return -1
func interaction() -> String:
	if farm.location == "farm" and not farm.inside_house and farm.player.position.distance_to(WELL) < 95: return "refill_water"
	return "chop_wood" if wood_index() >= 0 else ""
func refill() -> void:
	state().water = WATER_CAPACITY
	play("water",WELL)
	farm.say("Watering can refilled: 24 / 24.")
	farm.save_game(false)
func chop() -> void:
	var index := wood_index()
	if index < 0 or action_time > 0: return
	if farm.health < 3*preload("res://WeatherLife.gd").work_multiplier(farm): farm.say("Rest before chopping wood."); return
	var origin: Vector2 = farm.REGION_ORIGINS.mountain if farm.location == "mountain" else Vector2.ZERO
	state().chopped[farm.location+str(index)] = farm.day
	state().lumber += 3
	farm.health -= 3*preload("res://WeatherLife.gd").work_multiplier(farm)
	play("axe",origin+WOOD_SPOTS[farm.location][index])
	farm.show_item_moment("Lumber")
	farm.say("Collected 3 lumber. Stored in your materials supply for construction.")
	farm.save_game(false)
func play(kind: String, point: Vector2) -> void:
	action_kind = kind
	target = point
	action_time = 0.65
	queue_redraw()
func irrigate() -> void:
	var level: int = state().irrigation
	if level == 0: return
	for i in range(farm.plots.size()):
		if level == 1 and i >= 15: continue
		if farm.plots[i].stage == 1: farm.plots[i].stage = 2
func _process(delta: float) -> void:
	if farm == null: return
	var view: String = farm.location+str(farm.inside_house)+str(farm.day)+str(farm.interior_progress.get("greenhouse",false))
	if view != last_view:
		last_view = view
		queue_redraw()
	if action_time > 0:
		action_time = maxf(0,action_time-delta)
		queue_redraw()
func _draw() -> void:
	if farm == null or farm.inside_house: return
	if WOOD_SPOTS.has(farm.location):
		var origin: Vector2 = farm.REGION_ORIGINS.mountain if farm.location == "mountain" else Vector2.ZERO
		for i in range(WOOD_SPOTS[farm.location].size()):
			if farm.day-int(state().chopped.get(farm.location+str(i),-10)) < 4: continue
			var p: Vector2 = origin+WOOD_SPOTS[farm.location][i]
			if farm.location=="farm" and not farm.is_walkable(p): continue
			draw_line(p-Vector2(32,6),p+Vector2(30,-10),Color("57432f"),18,true)
			draw_line(p-Vector2(28,8),p+Vector2(26,-12),Color("a07d4f"),11,true)
			draw_circle(p+Vector2(30,-10),8,Color("d4b981"))
			draw_line(p,p+Vector2(5,-25),Color("765639"),7,true)

	if farm.location == "farm" and farm.interior_progress.get("greenhouse",false):
		draw_rect(Rect2(400,1310,500,250),Color("88714d"))
		draw_colored_polygon(PackedVector2Array([Vector2(400,1370),Vector2(650,1245),Vector2(900,1370)]),Color("9bbcaf"))
		for x in range(420,880,85):
			draw_rect(Rect2(x,1380,70,150),Color("add1c4"))
			draw_rect(Rect2(x,1380,70,150),Color("6c887c"),false,5)
		draw_rect(Rect2(610,1470,80,90),Color("718d80"))
		draw_string(ThemeDB.fallback_font,Vector2(578,1615),"Greenhouse",HORIZONTAL_ALIGNMENT_LEFT,-1,23,Color("493b2d"))
	if farm.location == "farm" and state().irrigation > 0:
		for i in range(farm.plots.size()):
			if i%5 != 0 or (state().irrigation == 1 and i>=15): continue
			var p: Vector2 = farm.plots[i].position+Vector2(-45,-30)
			draw_line(p+Vector2(0,10),p-Vector2(0,10),Color("6b7c7b"),5)
			draw_line(p-Vector2(12,10),p+Vector2(12,-10),Color("879b97"),5)
	if action_time <= 0: return
	var p: Vector2 = farm.player.position+Vector2(45,-65)
	var phase := (0.65-action_time)/0.65
	var side := -1.0 if target.x<farm.player.position.x else 1.0
	p.x = farm.player.position.x+45*side
	if action_kind == "pet":
		var heart := target+Vector2(0,-100-phase*35)
		draw_circle(heart+Vector2(-7,-5),9,Color("d9968c"))
		draw_circle(heart+Vector2(7,-5),9,Color("d9968c"))
		draw_colored_polygon(PackedVector2Array([heart+Vector2(-15,0),heart+Vector2(15,0),heart+Vector2(0,18)]),Color("d9968c"))
	elif action_kind == "water":
		draw_style_box(tool_box(Color("829ca3")),Rect2(p-Vector2(18,20),Vector2(36,30)))
		draw_arc(p+Vector2(-20,-8),12,PI/2,PI*1.5,12,Color("526f79"),5)
		draw_line(p+Vector2(15,0),p+Vector2(40*side,-12),Color("829ca3"),9)
		for i in range(6): draw_circle(p+Vector2((38+i*3)*side,8+fmod(phase*90+i*13,40)),3,Color("9ecbd2"))
	elif action_kind in ["axe","mine"]:
		var end := p+Vector2(cos(phase*PI)*35*side,-sin(phase*PI)*55)
		draw_line(p,end,Color("98734c"),9)
		if action_kind == "axe": draw_colored_polygon(PackedVector2Array([end+Vector2(-8,-15),end+Vector2(20,-12),end+Vector2(24,12),end+Vector2(-8,10)]),Color("a6b4b2"))
		else: draw_arc(end+Vector2(0,15),25,PI,TAU,12,Color("9cadad"),9)
		for i in range(4): draw_circle(target+Vector2((i-2)*12,-phase*35),3,Color("d6bc8b"))
	elif action_kind == "seed":
		draw_style_box(tool_box(Color("b49864")),Rect2(p-Vector2(16,5),Vector2(32,36)))
		for i in range(5): draw_circle(p+Vector2((i-2)*8,20+phase*55),3,Color("e6cb84"))
	else:
		draw_arc(target,25,PI,TAU,12,Color("eee2b3"),4)
		draw_line(p,target.lerp(p,1-phase),Color("edbd8f"),10)
func tool_box(color: Color) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = color
	box.border_color = Color("554a39")
	box.set_border_width_all(2)
	box.set_corner_radius_all(5)
	return box
