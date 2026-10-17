extends SceneTree
func _initialize():call_deferred("run")
func run():
	var f=load("res://Main.tscn").instantiate();root.add_child(f);await process_frame
	f.set_physics_process(false);f.choose_character("boy");f.close_dialogue()
	var b=f.perspective.BASIS
	for area in ["farm","harbor","tea","mountain","historic","waterfall"]:
		var p=Vector2(800,750)
		if f.regions.has(area):p=f.regions[area].safe_point(p)
		f.travel_to(area,p,false);await process_frame;f.perspective._process(0)
		var screen=f.get_canvas_transform()*f.player.position
		assert(screen.distance_to(f.get_viewport_rect().size/2+Vector2(0,65))<.1,"Camera tracks logical position")
		for d in [Vector2.RIGHT,Vector2.LEFT,Vector2.UP,Vector2.DOWN]:
			assert((b*f.perspective.manual_direction(d)).normalized().dot(d)>.999,"Screen-aligned control")
		assert((b*f.farmer.transform).y.normalized().dot(Vector2.DOWN)>.999,"Upright farmer")
		assert(f.get_canvas_transform().affine_inverse()*screen==f.player.position or (f.get_canvas_transform().affine_inverse()*screen).distance_to(f.player.position)<.01)
	f.travel_to("town",f.town.arrival("farm"),false);await process_frame;f.perspective._process(0)
	assert(f.camera.enabled and f.perspective.manual_direction(Vector2.RIGHT)==Vector2.RIGHT)
	for room in f.shops:
		f.enter_shop(room,true);await process_frame
		var count=0
		for layer in f.perspective.layers:
			if layer.active():count+=1
		assert(count==1,"Exactly one scene visible: "+room)
	print("PASS: world camera, screen controls, upright sprites, scene isolation and every interior");quit()
