extends SceneTree
func _initialize(): call_deferred("run")
func shot(f,name:String):
	await create_timer(.35).timeout
	await RenderingServer.frame_post_draw
	if is_instance_valid(f.dialogue_panel):
		var panel=f.dialogue_panel.get_child(0)
		assert(panel.get_global_rect().position.y>=0,"Panel stays in screen: "+name)
		assert(panel.get_global_rect().end.y<=root.size.y,"Panel bottom: "+name)
	root.get_texture().get_image().save_png(OS.get_cmdline_user_args()[0]+"/"+name+".png")
func run():
	var f=load("res://Main.tscn").instantiate();root.add_child(f);await process_frame
	f.set_physics_process(false);f.choose_character("boy");f.interior_progress.story={"intro":true};f.clock_minutes=800
	root.size=Vector2i(960,540)
	preload("res://PlayerComfort.gd").open_settings(f);await shot(f,"fifty-settings")
	f.close_dialogue();preload("res://PlayerComfort.gd").settings(f).large_text=true
	f.enter_shop("Tea Farmhouse",true);f.tea_delivery_stage=2
	f.start_conversation(f.shops["Tea Farmhouse"].residents[1]);await shot(f,"fifty-dialogue")
	f.close_dialogue();f.produce.Strawberry=2;f.produce.Turnip=3;f.ore_basket.Iron=2;f.fish_basket.Sardine=1;f.open_backpack();await shot(f,"fifty-bag")
	f.close_dialogue();VolunteerRequests.journal(f);await shot(f,"fifty-journal")
	f.close_dialogue();f.open_calendar();await shot(f,"fifty-calendar")
	f.close_dialogue();f.enter_shop("Carpentry",true);f.InteriorLife.preview_upgrade(f,"home");await shot(f,"fifty-construction")
	f.close_dialogue();f.travel_to("waterfall",Vector2(800,680),false);f.camera.position_smoothing_enabled=false;f.camera.force_update_scroll()
	preload("res://VillageDepth.gd").waterfall(f);await shot(f,"fifty-waterfall")
	print("PASS: 960x540 controls, large dialogue, bag grid, calendar, construction and waterfall panels stay in viewport")
	quit()
