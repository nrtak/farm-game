extends Node2D
var farm
var sightings := {}
var elapsed := 0.0
var refresh := 0.0
var last_key := ""
func setup(game) -> void:
	farm=game
	z_index=180
func habitat(area: String,point: Vector2) -> bool:
	var node = farm if area=="farm" else (farm.town if area=="town" else farm.regions[area])
	if not node.is_walkable(point): return false
	if area=="town":return not farm.town.G.on_road(farm.town.G.unproject(point),farm.town.data)
	if farm.has_meta("angled_world"):
		if area in ["harbor","historic"]:return false
		var routes:Array=preload("res://WideRoads.gd").ROUTES.get(area,[])
		for route in routes:
			if point.distance_to(Geometry2D.get_closest_point_to_segment(point,route[0],route[1]))<90:return false
		for door:Vector2 in preload("res://ApprovedMapLayout.gd").doors(area).values():
			var best=door;var distance=INF
			for route in routes:
				var p=Geometry2D.get_closest_point_to_segment(door,route[0],route[1])
				if p.distance_to(door)<distance:best=p;distance=p.distance_to(door)
			if point.distance_to(Geometry2D.get_closest_point_to_segment(point,door,best))<65:return false
		if area=="farm":
			for plot in farm.plots:
				if point.distance_to(plot.position)<55:return false
		return true
	var size: Vector2 = farm.WORLD if area=="farm" else node.SIZE
	return preload("res://MapHabitat.gd").sample(area,point,size,"grass")
func populate(area: String) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed=hash(area+str(farm.day))
	var size: Vector2 = farm.WORLD if area=="farm" else (farm.town.SIZE if area=="town" else farm.regions[area].SIZE)
	var animals: Array = []
	for i in range(3):
		for attempt in range(80):
			var p := Vector2(rng.randf_range(150,size.x-150),rng.randf_range(240,size.y-180))
			if not habitat(area,p): continue
			animals.append({"point":p,"kind":i,"phase":rng.randf()*TAU})
			break
	sightings[area+str(farm.day)]=animals
func _process(delta: float) -> void:
	if farm==null: return
	if farm.choosing_character or farm.sleep_in_progress or farm.paused_by_player or farm.dialogue_open or not farm.window_focused: return
	if farm.inside_house or farm.location in ["shop","road","waterfall"]: visible=false; return
	visible=true
	elapsed+=delta
	refresh-=delta
	if refresh>0: return
	refresh=0.16
	var key: String=farm.location+str(farm.day)
	if not sightings.has(key):
		if sightings.size()>12: sightings.clear()
		populate(farm.location)
	last_key=key
	queue_redraw()
func _draw() -> void:
	if farm==null or farm.inside_house or farm.location=="shop" or not sightings.has(last_key): return
	var area: String=farm.location
	var origin: Vector2=Vector2.ZERO if area=="farm" else (farm.TOWN_ORIGIN if area=="town" else farm.REGION_ORIGINS[area])
	for record in sightings[last_key]:
		if record.kind==2 and farm.clock_minutes<1080: continue
		var p: Vector2=record.point+origin
		var bob := sin(elapsed*2+record.phase)*2
		draw_set_transform(p+Vector2(0,bob))
		if is_instance_valid(farm.perspective) and area!="town":
			var b=farm.perspective.BASIS
			draw_set_transform_matrix(b.affine_inverse()*Transform2D(0,Vector2.ONE*.65,0,b*p+Vector2(0,bob)))
		var fur := Color("a1784e") if record.kind!=1 else Color("d6ccb3")
		draw_circle(Vector2.ZERO,14,fur)
		draw_circle(Vector2(13,-8),9,fur)
		if record.kind==0:
			draw_arc(Vector2(-15,-10),15,-1.4,1.4,12,fur,10)
		elif record.kind==1:
			draw_line(Vector2(11,-13),Vector2(9,-31),fur,7)
			draw_line(Vector2(18,-13),Vector2(21,-30),fur,7)
			draw_circle(Vector2(-13,2),6,Color("ece5d4"))
		else:
			draw_line(Vector2(-6,8),Vector2(-8,19),fur,5)
			draw_line(Vector2(9,8),Vector2(11,19),fur,5)
			draw_line(Vector2(-12,-2),Vector2(-32,3),fur,8)
			draw_colored_polygon(PackedVector2Array([Vector2(8,-13),Vector2(10,-26),Vector2(17,-15)]),fur)
			draw_circle(Vector2(24,-6),5,fur)
		draw_circle(Vector2(18,-10),2,Color("423d31"))
		draw_set_transform(Vector2.ZERO)
	# Fish are occasional silhouettes below natural water; never in the onsen.
	if area not in ["harbor","farm"] or fmod(elapsed,14)>4: return
	var spots: Array=[Vector2(450,960),Vector2(920,1080)] if area=="harbor" else [Vector2(2490,1660),Vector2(2600,1740)]
	for p in spots:
		var fish: Vector2=p+origin+Vector2(sin(elapsed)*14,cos(elapsed)*3)
		draw_set_transform(fish,0.1,Vector2(1.5,0.65))
		draw_circle(Vector2.ZERO,8,Color(0.21,0.43,0.44,0.5))
		draw_colored_polygon(PackedVector2Array([Vector2(-7,0),Vector2(-16,-8),Vector2(-16,8)]),Color(0.21,0.43,0.44,0.5))
		draw_set_transform(Vector2.ZERO)
