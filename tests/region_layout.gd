extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var f=load("res://Main.tscn").instantiate()
	root.add_child(f)
	await process_frame
	f.set_physics_process(false); f.choose_character("boy")
	f.interior_progress.story={"intro":true}; f.day=1
	for area in f.regions:
		var region=f.regions[area]
		var arrivals := {"harbor":Vector2(1480,585),"tea":Vector2(140,665),"historic":Vector2(1440,1060),"mountain":Vector2(800,950)}
		f.travel_to(area,arrivals[area],false)
		for room in f.REGIONAL_ROOMS:
			if f.REGIONAL_ROOMS[room][0]!=area: continue
			var target: Vector2=f.REGIONAL_ROOMS[room][1]
			assert(region.is_walkable(target),"Door lies on clear ground: "+room)
			f.polish.plan(f.REGION_ORIGINS[area]+target)
			assert(not f.polish.path.is_empty(),"Reachable doorway: "+room)
			assert(f.polish.path[-1].distance_to(f.REGION_ORIGINS[area]+target)<45,"Route reaches actual door: "+room)
			for point in f.polish.path: assert(region.is_walkable(point-f.REGION_ORIGINS[area]))
		for npc in region.npcs: assert(region.is_walkable(npc.position),"Resident starts on dry clear ground")
	for spot in f.FISHING_SPOTS:
		f.travel_to("harbor",Vector2(1480,610),false)
		f.polish.plan(f.REGION_ORIGINS.harbor+spot)
		assert(not f.polish.path.is_empty())
		assert(f.polish.path[-1].distance_to(f.REGION_ORIGINS.harbor+spot)<45)
	assert(not f.regions.harbor.is_walkable(Vector2(285,940)),"Removed pier is water")
	assert(not f.regions.harbor.is_walkable(Vector2(800,950)),"No road across ocean")
	f.travel_to("harbor",Vector2(1540,610),false); f.check_walk_exits()
	assert(f.location=="town","Harbor east exit returns automatically")
	for minute in [480,800,1140]:
		f.town.ambient_period=-1
		f.town.tick_ambient(0.1,minute,false,f.shops,f.regions)
		for npc in f.town.visitors: assert(npc.get_parent().is_walkable(npc.position),"Visiting staff on dry ground")
		for pet in f.town.pets: assert(pet.get_parent().is_walkable(pet.position))
	f.town.ambient_period=-1; f.town.tick_ambient(0.1,480,false,f.shops,f.regions)
	var ren=f.town.visitors[0]
	assert(ren.get_parent()==f.regions.mountain and f.regions.mountain.is_walkable(ren.position),"Ren stands on dry ground beside the onsen")
	f.day=96; f.clock_minutes=1100
	f.travel_to("mountain",Vector2(820,945),false); f.check_scheduled_gathering()
	assert(f.festival_active)
	for record in f.festival_people: assert(f.regions.mountain.is_walkable(record.npc.position))
	f.animate_festival()
	for record in f.festival_people: assert(f.regions.mountain.is_walkable(record.npc.position))
	print("PASS: all regional doors reachable, single pier fishing, automatic harbor exit, dry staff/pets and safe onsen festival positions")
	quit()
