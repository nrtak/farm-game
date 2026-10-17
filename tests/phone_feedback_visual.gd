extends SceneTree
func _initialize():call_deferred("run")
func shot(name):
	await create_timer(.5).timeout;await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OS.get_cmdline_user_args()[0]+"/phone-"+name+".png")
func run():
	root.size=Vector2i(1311,603)
	var f=load("res://Main.tscn").instantiate();root.add_child(f);await process_frame
	f.set_physics_process(false);f.choose_character("boy");f.close_dialogue();f.clock_minutes=780;f.interior_progress.story={"intro":true};preload("res://VillageDepth.gd").state(f).falls=3
	for area in ["town","harbor","historic","mountain","tea","waterfall"]:
		var p=Vector2(800,750)
		if area=="town":p=f.town.G.project(Vector2(1660,960))
		elif area=="harbor":p=Vector2(900,640)
		elif area=="historic":p=Vector2(500,650)
		f.travel_to(area,p,false);f.update_walk(0,false,Vector2.DOWN);f.toast_time=0;f.refresh_hud();await shot(area)
	f.close_dialogue();f.enter_shop("Inn",true);f.toast_time=0;await shot("inn")
	f.start_conversation(f.shops["Inn"].residents[0]);await shot("conversation")
	print("PASS: phone proportion feedback screenshots captured");quit()
