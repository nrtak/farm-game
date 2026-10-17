extends SceneTree
func _initialize():call_deferred("run")
func run():
	var f=load("res://Main.tscn").instantiate();root.add_child(f);await process_frame
	f.set_physics_process(false);f.choose_character("boy");f.close_dialogue();f.interior_progress.story={"intro":true}
	f.travel_to("tea",Vector2(270,675),false);await physics_frame
	for i in range(120):
		var previous:Vector2=f.player.position
		f.player.velocity=Vector2.LEFT*200
		f.player.move_and_slide();f.polish.constrain_motion(previous);f.check_walk_exits()
		if f.location=="mountain":break
	assert(f.location=="mountain","Walk west from tea arrival through exit")
	f.check_walk_exits();assert(f.location=="mountain","Return does not bounce back to tea")
	for name in ["Tea Farmhouse","Tea Processing Shed"]:
		var door:Vector2=f.REGIONAL_ROOMS[name][1]
		f.travel_to("tea",Vector2(1280,675),false);await physics_frame
		f.polish.plan(f.REGION_ORIGINS.tea+door)
		assert(not f.polish.path.is_empty(),"New tea frontage has a reachable entrance")
	f.travel_to("farm",f.SHIPPING_BOX+Vector2(0,50),false);await physics_frame
	assert(f.polish.clear_position(f.player.position),"Shipping approach clear")
	assert(f.interaction_action()=="shipping","Shipping remains usable beside fields")
	for plot in f.plots:assert(f.is_walkable(plot.position),"No utility blocks a crop bed")
	f.player.position=preload("res://FarmResources.gd").WELL
	assert(f.polish.clear_position(f.player.position),"Well approach clear")
	assert(f.resources.interaction()=="refill_water","Well refill remains reachable")
	f.player.position=Vector2(1220,700)
	assert(f.interaction_action()!="shipping","Shipping does not steal crop-bed actions")
	f.player.position=Vector2(1420,700)
	assert(f.resources.interaction()!="refill_water","Well does not steal crop-bed actions")
	print("PASS: continuous tea exit, no return bounce, tea shop access and farm utility/crop clearance")
	f.queue_free();await process_frame;quit()
