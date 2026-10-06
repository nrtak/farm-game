extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var farm = load("res://Main.tscn").instantiate()
	root.add_child(farm)
	await process_frame
	farm.set_physics_process(false)
	farm.choose_character("boy")
	farm.camera.position_smoothing_enabled = false
	root.size = Vector2i(1170, 540)
	farm.day = 14
	farm.clock_minutes = 600
	farm.festival_years = []
	farm.enter_house()
	farm.open_calendar()
	await capture(farm, "calendar")
	farm.close_dialogue()
	farm.travel_to("town", Vector2(1200, 1000), false)
	farm.check_scheduled_gathering()
	await capture(farm, "scheduled-gathering-intro")
	while farm.dialogue_open: farm.advance_dialogue()
	farm.animate_festival()
	await capture(farm, "scheduled-gathering")
	quit()
func capture(farm: Node, title: String) -> void:
	farm.camera.force_update_scroll()
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OS.get_cmdline_user_args()[0] + "/draft-" + title + ".png")
