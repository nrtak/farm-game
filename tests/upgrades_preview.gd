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
	farm.clock_minutes = 600
	farm.enter_shop("Blacksmith")
	farm.open_service("Blacksmith")
	await capture(farm, "forge-upgrades")
	farm.close_dialogue()
	farm.day = 3
	farm.travel_to("farm", Vector2(500, 1300), false)
	farm.toast_time = 0
	farm.refresh_hud()
	await capture(farm, "rain-farm")
	quit()
func capture(farm: Node, title: String) -> void:
	farm.camera.force_update_scroll()
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OS.get_cmdline_user_args()[0] + "/draft-" + title + ".png")
