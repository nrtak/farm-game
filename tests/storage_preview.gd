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
	farm.enter_house()
	farm.player.position = farm.ROOM_ORIGIN + farm.interior.CHEST_APPROACH
	farm.toast_time = 0
	farm.refresh_hud()
	await capture(farm, "storage-chest")
	farm.produce.Turnip = 4
	farm.stored_items.Turnip = 10
	farm.open_storage()
	await capture(farm, "storage-menu")
	farm.open_storage_item("Turnip")
	await capture(farm, "storage-transfer")
	quit()
func capture(farm: Node, title: String) -> void:
	farm.camera.force_update_scroll()
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OS.get_cmdline_user_args()[0] + "/draft-" + title + ".png")
