extends SceneTree
func _initialize(): call_deferred("run")
func capture(f,name:String):
	await create_timer(.25).timeout
	await RenderingServer.frame_post_draw
	if f.dialogue_open:
		var rect=f.dialogue_panel.get_child(0).get_global_rect()
		assert(rect.position.y>=0 and rect.end.y<=root.get_visible_rect().size.y,"Fits: "+name)
	root.get_texture().get_image().save_png(OS.get_cmdline_user_args()[0]+"/"+name+".png")
func run():
	var f=load("res://Main.tscn").instantiate();root.add_child(f)
	await process_frame
	f.set_physics_process(false);f.choose_character("boy")
	f.interior_progress.story={"intro":true};root.size=Vector2i(1170,540);f.clock_minutes=780
	f.enter_shop("General Store",true);f.open_service("General Store");await capture(f,"feedback14-store")
	f.close_dialogue();f.produce.Turnip=3;f.fish_basket.Sardine=2;f.packed_tea=1
	f.open_shipping();await capture(f,"feedback14-shipping")
	f.close_dialogue();f.enter_shop("Blacksmith",true);f.open_service("Blacksmith");await capture(f,"feedback14-forge")
	f.close_dialogue();f.make_modal("Mika",true);f.dialogue_text.text="Welcome to the tea fields!";await capture(f,"feedback14-heart")
	f.close_dialogue();f.travel_to("town",Vector2(510,800),false)
	f.camera.position_smoothing_enabled=false;f.camera.force_update_scroll()
	await capture(f,"feedback14-harbor")
	print("PASS: item and relationship screens rendered at phone dimensions")
	quit()
