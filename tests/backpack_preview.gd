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
	farm.travel_to("tea", Vector2(430, 800), false)
	farm.toast_time = 0
	farm.refresh_hud()
	await capture(farm, "tea-harvest")
	farm.enter_shop("General Store")
	farm.tea_leaves = 3
	farm.open_service("General Store")
	await capture(farm, "store-backpack-option")
	farm.open_backpack_shop()
	await capture(farm, "backpack-store")
	farm.close_dialogue()
	farm.produce = {"Turnip": 2, "Potato": 1, "Strawberry": 1}
	farm.fish_basket = {"Sardine": 1, "Mackerel": 1, "Sea Bream": 1}
	farm.ore_basket = {"Copper": 1, "Iron": 1}
	farm.open_backpack()
	await capture(farm, "backpack")
	quit()
func capture(farm: Node, title: String) -> void:
	farm.camera.force_update_scroll()
	await process_frame
	await RenderingServer.frame_post_draw
	var destination = OS.get_cmdline_user_args()[0]
	root.get_texture().get_image().save_png(destination + "/draft-" + title + ".png")


