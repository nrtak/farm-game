extends SceneTree
func _initialize(): call_deferred("run")
func run():
	var f=load("res://Main.tscn").instantiate();root.add_child(f)
	await process_frame
	f.set_physics_process(false);f.choose_character("boy");f.interior_progress.story={"intro":true}
	var failures: Array=[]
	for area in preload("res://WideRoads.gd").ROUTES:
		if area=="farm": continue
		f.travel_to(area,Vector2(800,950),false)
		await physics_frame
		var origin: Vector2=f.TOWN_ORIGIN if area=="town" else f.REGION_ORIGINS[area]
		for route in preload("res://WideRoads.gd").ROUTES[area]:
			var side: Vector2=(route[1]-route[0]).normalized().orthogonal()*32
			for i in range(21):
				for offset in [Vector2.ZERO,side,-side]:
					var p: Vector2=route[0].lerp(route[1],i/20.0)+offset
					if not f.polish.clear_position(origin+p): failures.append("%s %s" % [area,p])
	print("LANE FAILURES: ",failures)
	assert(failures.is_empty())
	f.travel_to("mountain",Vector2(1490,760),false);f.check_walk_exits()
	assert(f.location=="waterfall")
	assert(f.regions.waterfall.background!=null)
	assert(not f.regions.waterfall.is_walkable(Vector2(800,350)),"Pool cannot be walked on")
	for y in range(550,1100,20): assert(f.regions.waterfall.is_walkable(Vector2(800,y)))
	f.save_game(false);f.load_game();assert(f.location=="waterfall")
	f.player.position=f.REGION_ORIGINS.waterfall+Vector2(800,1140);f.check_walk_exits()
	assert(f.location=="mountain")
	f.clock_minutes=850
	for d in range(1,40):
		f.day=d
		if f.is_rainy_day(): break
	assert(f.resident_room("Mika")=="Tea Farmhouse" and f.resident_room("Hana")=="Inn" and f.resident_room("Yuta")=="Fire Station")
	f.refresh_hud()
	for npc in f.town.npcs:
		if npc.first_name in ["Seira","Shohei","Akira","Hana","Yuta"]: assert(not npc.visible,"Rain shelter hides outdoor duplicate")
	assert(f.shops["Tea Farmhouse"].residents[1].visible,"Mika is reachable indoors in rain")
	assert(f.date_label.get_line_count()==1)
	var column=f.make_modal("Mika",true)
	await process_frame
	var controllers=f.dialogue_panel.get_child(0).get_children()
	var bust_found:=false
	for controller in controllers:
		if controller.get_script()==load("res://CompactConversation.gd"):
			assert(controller.picture.texture is AtlasTexture)
			assert(controller.picture.texture.region.size.y<controller.picture.texture.atlas.get_height()*0.6)
			bust_found=true
	assert(bust_found)
	print("PASS: wider road lanes, waterfall travel/save/pool boundaries, rainy shelter and compact status")
	quit()
