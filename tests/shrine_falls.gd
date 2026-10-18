extends SceneTree
func _initialize():call_deferred("run")
func run():
	var f=load("res://Main.tscn").instantiate();root.add_child(f);await process_frame
	f.set_physics_process(false);f.choose_character("boy");f.close_dialogue();f.interior_progress.story={"intro":true}
	f.travel_to("historic",Vector2(1440,650),false);await physics_frame
	f.polish.plan(f.REGION_ORIGINS.historic+preload("res://ShrineFalls.gd").APPROACH)
	assert(not f.polish.path.is_empty(),"Shrine and waterfall share a reachable path")
	for i in range(1600):
		var before:Vector2=f.player.position
		f.player.velocity=f.polish.direction(Vector2.ZERO)*180
		if not f.polish.path.is_empty():f.player.velocity=f.player.velocity.limit_length(f.player.position.distance_to(f.polish.path[0])/f.player.get_physics_process_delta_time())
		f.player.move_and_slide();f.polish.constrain_motion(before);f.check_walk_exits()
		assert(f.location=="historic","No map transition between shrine and falls")
		if preload("res://ShrineFalls.gd").nearby(f):break
	assert(f.interaction_action()=="falls","Waterfall interaction at the shrine")
	assert(not f.regions.historic.is_walkable(Vector2(700,400)),"Waterfall pool blocks walking")
	f.travel_to("waterfall",Vector2(800,700),false)
	assert(f.location=="historic","Legacy waterfall location migrates")
	f.save_game(false);f.load_game();assert(preload("res://ShrineFalls.gd").nearby(f),"Combined-area save reload")
	f.travel_to("mountain",Vector2(1490,760),false);f.check_walk_exits();assert(f.location=="mountain","Old mountain gate removed")
	f.travel_to("waterfall",Vector2.ZERO,false)
	var depth=preload("res://VillageDepth.gd");depth.state(f).falls=2;f.packed_tea=1
	depth.waterfall(f);depth.finish_falls(f);assert(depth.state(f).falls==3 and f.packed_tea==0,"Quest still completes at relocated falls")
	print("PASS: shared shrine/falls walking, dry pool, legacy migration, save reload and relocated quest")
	f.queue_free();await process_frame;quit()
