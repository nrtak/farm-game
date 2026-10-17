extends SceneTree
func _initialize():call_deferred("run")
func shot(name):
	await create_timer(.4).timeout;await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OS.get_cmdline_user_args()[0]+"/angled-"+name+".png")
func run():
	root.size=Vector2i(1152,648)
	var f=load("res://Main.tscn").instantiate();root.add_child(f);await process_frame
	f.set_physics_process(false);f.choose_character("boy");f.interior_progress.story={"intro":true};f.close_dialogue();f.clock_minutes=800
	for area in ["farm","harbor","historic","tea","mountain","waterfall"]:
		var p:Vector2={"farm":Vector2(1100,800),"harbor":Vector2(1120,700),"historic":Vector2(650,600),"tea":Vector2(800,750),"mountain":Vector2(800,650),"waterfall":Vector2(800,800)}[area]
		f.travel_to(area,p,false);f.update_resident_presence();f.update_walk(0,false,Vector2.DOWN);f.toast_time=0;f.refresh_hud();await shot(area)
	f.travel_to("farm",f.farmhouse.DOOR_POSITION,false);f.enter_house();await shot("home")
	for room in f.shops:
		f.enter_shop(room,true);f.update_walk(0,false,Vector2.DOWN);await shot(room.to_lower().replace(" ","-"))
	f.travel_to("harbor",f.FISHING_SPOTS[0],false);f.begin_fishing();f.fishing_elapsed=2.4;f.regions.harbor.fishing_state=2;f.refresh_hud();await shot("fishing-cue");f.stop_fishing()
	f.travel_to("farm",Vector2(1100,800),false);f.show_item_moment("Turnip");await shot("pickup-cue");f.clear_item_moment()
	f.enter_house();f.player.position=f.ROOM_ORIGIN+preload("res://HomeWeather.gd").APPROACH;await shot("weather-tv")
	print("PASS: all angled regions, interiors, fishing, pickup and TV captured");quit()
