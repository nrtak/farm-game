extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var farm = load("res://Main.tscn").instantiate()
	root.add_child(farm)
	await process_frame
	farm.set_physics_process(false)
	farm.choose_character("boy")
	farm.camera.position_smoothing_enabled = false
	farm.clock_minutes = 600
	farm.travel_to("town", Vector2(1200, 950), false)
	farm.toast_time = 0
	farm.refresh_hud()
	await capture(farm, "town")
	farm.open_map()
	await capture(farm, "map")
	farm.close_dialogue()
	await process_frame
	farm.player.position = farm.TOWN_ORIGIN + farm.town.npcs[0].position + Vector2(100, 0)
	farm.start_conversation(farm.town.npcs[0])
	await capture(farm, "dialogue")
	farm.close_dialogue()
	await process_frame
	farm.open_service("General Store")
	await capture(farm, "store")
	farm.close_dialogue()
	await process_frame
	farm.player.position = farm.TOWN_ORIGIN + Vector2(1200, 1000)
	farm.open_noticeboard()
	await capture(farm, "noticeboard")
	farm.close_dialogue()
	await process_frame
	farm.begin_festival()
	farm.festival_elapsed = 1.2
	farm.animate_festival()
	await capture(farm, "festival")
	farm.end_festival()
	farm.start_scene("Brothers on Patrol")
	await capture(farm, "character-scene")
	farm.close_dialogue()
	await process_frame
	farm.travel_to("tea", Vector2(800, 650), false)
	farm.toast_time = 0
	farm.refresh_hud()
	await capture(farm, "tea")
	farm.start_conversation(farm.regions.tea.npcs[0])
	await capture(farm, "regional-dialogue")
	farm.close_dialogue()
	await process_frame
	farm.travel_to("road", Vector2(500, 500), false)
	farm.toast_time = 0
	farm.refresh_hud()
	await capture(farm, "road")
	for area in ["harbor", "mountain", "historic"]:
		farm.travel_to(area, Vector2(800, 650), false)
		farm.toast_time = 0
		farm.refresh_hud()
		await capture(farm, area)
	for service in ["General Store", "Blacksmith", "Café", "Inn", "Clinic", "Town Hall", "Police Box", "Fire Station", "Archive", "Shrine Residence", "Mountain Lodge", "Tea Farmhouse", "Tea Processing Shed", "Harbor Homes", "Fishing Shop", "Hiro Cabin"]:
		farm.clock_minutes = 800
		if service == "Archive": farm.lost_item_stage = 1
		farm.enter_shop(service)
		farm.toast_time = 0
		farm.refresh_hud()
		await capture(farm, "interior-" + service.to_lower().replace(" ", "-"))
	farm.travel_to("harbor", farm.FISHING_SPOTS[0], false)
	farm.begin_fishing()
	farm.fishing_elapsed = 2.2
	farm.regions.harbor.fishing_state = 2
	farm.regions.harbor.queue_redraw()
	farm.refresh_hud()
	await capture(farm, "fishing-bite")
	farm.catch_fish()
	await capture(farm, "fishing-catch")
	farm.travel_to("farm", Vector2(700, 1100), false)
	farm.toast_time = 0
	farm.refresh_hud()
	await capture(farm, "farm")
	for i in range(9):
		farm.plots[i].crop = ["Turnip", "Potato", "Strawberry"][i % 3]
		farm.plots[i].stage = 3 if i < 3 else 2
		farm.plots[i].growth = 1 if i >= 3 else farm.CROPS[farm.plots[i].crop].days
	farm.player.position = Vector2(480, 1390)
	farm.nearest = 4
	farm.shipping_queue.Turnip = 1
	farm.queue_redraw()
	await capture(farm, "crop-visuals")
	farm.open_seed_picker()
	await capture(farm, "seed-selection")
	farm.close_dialogue()
	await process_frame
	farm.open_shipping()
	await capture(farm, "shipping")
	farm.close_dialogue()
	await process_frame
	for resolution in [Vector2i(1170, 540), Vector2i(960, 720)]:
		root.size = resolution
		await process_frame
		farm.layout_ui()
		farm.travel_to("town", Vector2(900, 870), false)
		farm.start_conversation(farm.town.npcs[0])
		await capture(farm, "dialogue-%dx%d" % [resolution.x, resolution.y])
		farm.close_dialogue()
		await process_frame
		farm.clock_minutes = 800
		for service in ["Tea Farmhouse", "Tea Processing Shed", "Harbor Homes", "Fishing Shop", "Hiro Cabin"]:
			farm.enter_shop(service)
			farm.toast_time = 0
			farm.refresh_hud()
			await capture(farm, "%s-%dx%d" % [service.to_lower().replace(" ", "-"), resolution.x, resolution.y])
		farm.travel_to("farm", Vector2(700, 1300), false)
		farm.open_seed_picker()
		await capture(farm, "seeds-%dx%d" % [resolution.x, resolution.y])
		farm.close_dialogue()
		await process_frame
		farm.open_guide()
		await capture(farm, "guide-%dx%d" % [resolution.x, resolution.y])
		farm.close_dialogue()
		await process_frame
	quit(0)

func capture(farm: Node, title: String) -> void:
	farm.camera.force_update_scroll()
	await process_frame
	await RenderingServer.frame_post_draw
	var destination := ProjectSettings.globalize_path("res://../previews/")
	var arguments := OS.get_cmdline_user_args()
	if not arguments.is_empty(): destination = arguments[0].trim_suffix("/") + "/"
	DirAccess.make_dir_recursive_absolute(destination)
	assert(root.get_texture().get_image().save_png(destination + "draft-" + title + ".png") == OK, "Screenshot saved")
