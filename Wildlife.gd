extends Node2D
var farm
var sightings := {}
var elapsed := 0.0
var refresh := 0.0
var last_key := ""
var habitat_images := {}
func setup(game) -> void:
	farm=game
	z_index=180
func habitat(area: String,point: Vector2) -> bool:
	var node = farm if area=="farm" else (farm.town if area=="town" else farm.regions[area])
	if not node.is_walkable(point): return false
	var texture: Texture2D
	var size: Vector2 = farm.WORLD if area=="farm" else node.SIZE
	if area=="farm": texture=farm.get_node("OutdoorWorld/Environment").texture
	elif area=="town":
		for child in node.get_children():
			if child is Sprite2D and child.z_index==-10: texture=child.texture
	else: texture=node.background
	if not habitat_images.has(area): habitat_images[area]=texture.get_image()
	var image: Image=habitat_images[area]
	var pixel := Vector2i(point/size*Vector2(image.get_size()))
	var c := image.get_pixelv(pixel)
	return c.r>0.4 and c.g>0.52 and c.g>c.r*1.12 and c.g>c.b*1.2
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
	if farm.paused_by_player or farm.dialogue_open or not farm.window_focused: return
	if farm.inside_house or farm.location in ["shop","road"]: visible=false; return
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
