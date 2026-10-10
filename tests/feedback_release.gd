extends SceneTree
func _initialize(): call_deferred("run")
func run():
	var f=load("res://Main.tscn").instantiate()
	root.add_child(f)
	await process_frame
	f.set_physics_process(false); f.choose_character("boy")
	f.interior_progress.story={"intro":true}
	f.travel_to("town",Vector2(2200,1330),false)
	await physics_frame
	for route in [[Vector2(1700,1330),Vector2(2300,1330)],[Vector2(2240,980),Vector2(2240,1400)],[Vector2(1930,1290),Vector2(1930,1380)]]:
		for i in range(101):
			var p:Vector2=route[0].lerp(route[1],i/100.0)
			for offset in [Vector2.ZERO,Vector2(12,0),Vector2(-12,0),Vector2(0,12),Vector2(0,-12)]:
				assert(f.polish.clear_position(f.TOWN_ORIGIN+p+offset),"Carpenter approach clearance "+str(p+offset))
	var npc=f.town.npcs[0]
	npc.position=Vector2(2140,1340);npc.visible=true
	f.player.position=f.TOWN_ORIGIN+Vector2(2070,1340)
	var before:Vector2=npc.position
	for step in range(25): f.polish.yield_residents(Vector2.RIGHT,.016)
	assert(npc.position.distance_to(before)>20,"Residents step aside")
	assert(f.town.is_walkable(npc.position))
	var mika=f.shops["Tea Farmhouse"].residents[1]
	f.tea_delivery_stage=0
	f.start_conversation(mika)
	assert(f.tea_delivery_stage==0 and f.pending_request=="tea")
	var buttons=f.dialogue_text.get_parent().get_children()
	assert(buttons[-2].text=="Accept request" and buttons[-1].text=="Not now")
	f.close_dialogue();assert(f.tea_delivery_stage==0)
	f.start_conversation(mika);f.accept_story_request();assert(f.tea_delivery_stage==1)
	f.accept_story_request();assert(f.tea_delivery_stage==1)
	for person in preload("res://CharacterArt.gd").PORTRAITS:
		var image=preload("res://CharacterArt.gd").portrait(person).get_image()
		assert(image!=null and image.get_pixel(0,0).a==0,"Transparent padded portrait "+person)
	for room in preload("res://InteriorArtwork.gd").ROOMS:
		assert(preload("res://InteriorArtwork.gd").texture(room)!=null,"Detailed art exists: "+room)
		assert(f.shops[room].solids==preload("res://InteriorArtwork.gd").furnishings(room),"Artwork collision active: "+room)
	assert(f.regions.harbor.background.resource_path.ends_with("map-harbor-open-v2.png"))
	assert(f.regions.tea.background.resource_path.ends_with("map-tea-open-v2.png"))
	assert(f.regions.mountain.background.resource_path.ends_with("map-mountain-open-v2.png"))
	print("PASS: carpenter routes, yielding residents, explicit quest consent, transparent portraits and detailed active interiors")
	quit()
