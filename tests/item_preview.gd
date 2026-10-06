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
	farm.travel_to("mountain", Vector2(800, 350), false)
	farm.toast_time = 0
	farm.refresh_hud()
	await capture(farm, "mine-entrance")
	farm.enter_shop("Mine")
	farm.tea_leaves = 3
	farm.player.position = farm.SHOP_ORIGIN + farm.MINE_SPOTS[0]
	farm.toast_time = 0
	farm.refresh_hud()
	farm.show_item_moment("Iron")
	await capture(farm, "item-ore")
	farm.travel_to("farm", Vector2(500, 1300), false)
	farm.show_item_moment("Turnip")
	await capture(farm, "item-turnip")
	quit()
func capture(farm: Node, title: String) -> void:
	farm.camera.force_update_scroll()
	await process_frame
	await RenderingServer.frame_post_draw
	var destination = OS.get_cmdline_user_args()[0]
	root.get_texture().get_image().save_png(destination + "/draft-" + title + ".png")


