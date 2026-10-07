extends SceneTree
func _initialize(): call_deferred("run")
func capture(f,name):
	f.toast_time=0
	f.refresh_hud()
	f.camera.force_update_scroll()
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OS.get_cmdline_user_args()[0]+"/"+name+".png")
func run():
	var f = load("res://Main.tscn").instantiate()
	root.add_child(f)
	await process_frame
	f.set_physics_process(false)
	f.choose_character("boy")
	f.camera.position_smoothing_enabled=false
	root.size=Vector2i(1170,540)
	f.clock_minutes=800
	f.town.tick_ambient(0.1,800,false,f.shops,f.regions)
	for service in f.shops:
		if service == "Mine": continue
		f.enter_shop(service,true)
		await create_timer(0.55).timeout
		await capture(f,"polish-room-"+service.replace(" ","-"))
	for area in ["town","historic","mountain","harbor","tea","farm"]:
		f.travel_to(area,Vector2(800,890) if area == "mountain" else (Vector2(1200,1940) if area == "town" else (Vector2(1000,850) if area == "farm" else Vector2(800,600))),false)
		await create_timer(0.55).timeout
		await capture(f,"polish-"+area)
	for minute in [420,720,1050,1260]:
		f.clock_minutes=minute
		f.travel_to("town",Vector2(1200,950),false)
		await create_timer(0.55).timeout
		await capture(f,"polish-light-"+str(minute))
	f.day=96
	f.clock_minutes=1100
	f.travel_to("mountain",SeasonalFestivals.center("mountain"),false)
	f.check_scheduled_gathering()
	await create_timer(0.55).timeout
	await capture(f,"polish-onsen-festival")
	f.end_festival()
	f.day=1
	f.clock_minutes=720
	f.travel_to("farm",Vector2(1200,800),false)
	f.camera.zoom=Vector2.ONE*0.34
	f.camera.offset=Vector2.ZERO
	f.hud.hide()
	await create_timer(0.55).timeout
	await capture(f,"farm-layout-review")
	for seasonal_day in [1,29,57,85]:
		f.day=seasonal_day
		f.refresh_hud()
		await create_timer(0.2).timeout
		await capture(f,"farm-season-"+str(seasonal_day))
	f.hud.show()
	f.day=1
	for size in [Vector2i(1170,540),Vector2i(1024,768)]:
		root.size=size
		f.travel_to("town",Vector2(1200,950),false)
		f.layout_ui()
		await create_timer(0.3).timeout
		assert(Rect2(Vector2.ZERO,Vector2(size)).encloses(f.action_button.get_global_rect()))
		await capture(f,"mobile-layout-"+str(size.x))
	print("PASS: rendered all service rooms, paths, four lighting phases, mountain festival and farm overview")
	quit()
