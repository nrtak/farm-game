extends SceneTree
func _initialize() -> void: call_deferred("run")
func capture(f,name) -> void:
	f.camera.force_update_scroll()
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OS.get_cmdline_user_args()[0]+"/"+name+".png")
func run() -> void:
	var f=load("res://Main.tscn").instantiate()
	root.add_child(f)
	await process_frame
	f.set_physics_process(false)
	f.choose_character("boy")
	f.interior_progress.story={"intro":true}
	f.camera.position_smoothing_enabled=false
	root.size=Vector2i(1170,540)
	f.clock_minutes=900
	f.set_location(true,f.ROOM_ORIGIN+Vector2(600,500))
	await create_timer(0.2).timeout
	await capture(f,"home-detailed-game")
	f.set_location(true,f.ROOM_ORIGIN+f.interior.BED_APPROACH)
	f.offer_sleep()
	f.sleep_until_morning()
	f.sleep_sequence.set_process(false)
	f.sleep_sequence.step(0.65)
	f.sleep_sequence.step(0.45)
	await capture(f,"home-going-to-bed")
	f.sleep_sequence.step(0.6)
	f.sleep_sequence.step(0.6)
	await capture(f,"home-new-day")
	f.sleep_sequence.step(0.6)
	f.sleep_sequence.step(0.3)
	await capture(f,"home-waking-up")
	f.sleep_sequence.step(0.4)
	f.travel_to("farm",f.SHIPPING_BOX+Vector2(0,100),false)
	f.produce.Turnip=2
	f.action_button.pressed.emit()
	assert(f.dialogue_open,"Shipping dialog visible after wake completes")
	await capture(f,"home-shipping-dialog")
	f.close_dialogue()
	f.travel_to("farm",Vector2(1000,700),false)
	await capture(f,"home-shipping-placement")
	f.enter_shop("General Store",true)
	await process_frame
	f.enter_shop("Café",true)
	await process_frame
	f.enter_shop("General Store",true)
	await capture(f,"home-return-to-store")
	assert(preload("res://InteriorArtwork.gd").textures.size()<=1,"Only current room artwork remains cached")
	print("PASS: phone farmhouse, bed entry, new-day screen, wake hop and shipping UI rendered")
	quit()
