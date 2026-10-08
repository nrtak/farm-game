extends SceneTree
func _initialize(): call_deferred("run")
func run():
	var f=load("res://Main.tscn").instantiate()
	root.add_child(f)
	await process_frame
	f.set_physics_process(false); f.choose_character("boy")
	f.interior_progress.story={"intro":true}; f.day=1; f.clock_minutes=800
	for building in f.town.BUILDINGS:
		f.travel_to("town",building.door*f.town.ART_SCALE,false)
		f.door_retry=0; f.check_walk_exits()
		assert(f.location=="shop" and f.shop_name==building.name,"Automatic town building entry: "+building.name)
		f.player.position=f.SHOP_ORIGIN+Vector2(550,760)
		f.check_walk_exits()
		assert(f.location=="town")
		f.check_walk_exits()
		assert(f.location=="town","No immediate doorway bounce")
	for room in f.REGIONAL_ROOMS:
		f.clock_minutes=f.shop_opening_hours()[room].x+10
		var area: String=f.REGIONAL_ROOMS[room][0]
		f.travel_to(area,f.REGIONAL_ROOMS[room][1],false)
		f.door_retry=0; f.check_walk_exits()
		assert(f.location=="shop" and f.shop_name==room,"Automatic region door: "+room)
	f.travel_to("farm",f.farmhouse.DOOR_POSITION,false)
	f.check_walk_exits(); assert(f.inside_house)
	f.check_walk_exits(); assert(f.inside_house,"Arrival remains indoors")
	f.player.position=f.ROOM_ORIGIN+f.interior.EXIT
	f.check_walk_exits(); assert(not f.inside_house)
	f.check_walk_exits(); assert(not f.inside_house)
	f.travel_to("town",Vector2(180,150),false)
	f.check_walk_exits(); assert(f.location=="historic")
	f.player.position=f.REGION_ORIGINS.historic+Vector2(1540,1100)
	f.check_walk_exits(); assert(f.location=="town")
	assert(not f.REGIONAL_ROOMS.has("Archive"))
	assert(f.service_door("Archive").x>1400)
	for area in ["farm","town","harbor","mountain","historic","tea"]:
		f.wildlife.populate(area)
		for sighting in f.wildlife.sightings[area+str(f.day)]:
			assert(f.wildlife.habitat(area,sighting.point),"Wildlife lives on grassy clear ground")
	for region in f.regions.values():
		for npc in region.npcs: assert(npc.position==region.safe_npc_point(npc.position))
	f.town.tick(0.1,800)
	for npc in f.town.npcs:
		for building in f.town.BUILDINGS:
			var door: Vector2=building.door*f.town.ART_SCALE
			assert(not(absf(npc.position.x-door.x)<100 and npc.position.y>door.y-35 and npc.position.y<door.y+170),"Town resident leaves the doorway approach clear")
	print("PASS: automatic building/house/map travel, no entry bounce, town library, shrine return, dry NPC posts and grassy wildlife habitats")
	quit()
