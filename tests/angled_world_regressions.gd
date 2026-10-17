extends SceneTree
func _initialize():call_deferred("run")
func run():
	root.size=Vector2i(1152,648)
	var f=load("res://Main.tscn").instantiate();root.add_child(f);await process_frame
	f.set_physics_process(false);f.choose_character("boy");f.close_dialogue()
	for area in ["farm","town","tea","harbor","mountain","historic","waterfall"]:
		var point=f.town.arrival("farm") if area=="town" else Vector2(800,750)
		if f.regions.has(area):point=f.regions[area].safe_point(point)
		f.travel_to(area,point,false);f.show_item_moment("Turnip");f.perspective._process(.2)
		var screen=f.get_canvas_transform()
		var offset:Vector2=screen*(f.player.position+f.item_moment.position)-screen*f.player.position
		assert(absf(offset.x)<.1 and offset.y< -80 and offset.y> -170,"Pickup stays above farmer in "+area)
		f.clear_item_moment()
	for size in [Vector2i(1152,648),Vector2i(852,393)]:
		root.size=size;await process_frame
		f.travel_to("farm",Vector2(1100,800),false);f.layout_ui();await process_frame
		assert(not f.tool_bar.get_global_rect().intersects(f.message_label.get_global_rect()),"Tools and message remain separate")
	assert(not f.wildlife.habitat("tea",Vector2(860,675)),"Wildlife stays off widened road")
	assert(not f.wildlife.habitat("farm",f.plots[0].position),"Wildlife stays out of planted soil")
	for layer in f.perspective.layers:
		if layer.kind!="harbor":continue
		for spot in f.FISHING_SPOTS:
			f.regions.harbor.fishing_spot=spot
			var bob:Vector2=layer.fishing_float()
			assert(not f.regions.harbor.pier_area.has_point(bob) and not Geometry2D.is_point_in_polygon(bob,f.regions.harbor.land_outline),"Fishing float sits in water")
	f.travel_to("mountain",Vector2(800,650),false)
	f.day=60;f.season_scenery.update(f.day)
	for layer in f.perspective.layers:
		if layer.kind in ["farm","tea","harbor","mountain","historic","waterfall"]:
			assert(layer.material.get_shader_parameter("season")==2.0,"New scenery receives seasons")
	f.queue_free();await process_frame
	print("PASS: pickup anchoring across maps, small-screen HUD separation, wildlife road/crop exclusion and seasonal scenery")
	quit()
