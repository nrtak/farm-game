extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var farm = load("res://Main.tscn").instantiate()
	root.add_child(farm)
	await process_frame
	farm.set_physics_process(false)
	farm.choose_character("boy")
	farm.update_walk(0.0, true)
	assert(farm.walk_frame == 0, "Moving begins walk cycle")
	farm.update_walk(0.13, true)
	assert(farm.walk_frame == 1, "Stride must alternate")
	farm.update_walk(0.1, false)
	assert(farm.walk_frame == 0 and farm.walk_clock == 0.0, "Stopping restores idle")
	for index in range(8):
		var heading := Vector2.DOWN.rotated(index * PI / 4.0)
		farm.update_walk(0.0, true, heading)
		assert(farm.facing_direction == index, "Eight clock directions must select correct facing")
		farm.update_walk(0.0, false)
		assert(farm.walk_frame == index * 2, "Idle retains last facing")
	# Both farmers must alternate every facing without changing size or foot height.
	for choice in ["boy", "girl"]:
		farm.set_character(choice)
		for index in range(8):
			var heading := Vector2.DOWN.rotated(index * PI / 4.0)
			farm.update_walk(0.0, false, heading)
			farm.update_walk(0.0, true, heading)
			assert(farm.walk_frame == index * 2, "First stride must match facing")
			var stride_scale: Vector2 = farm.farmer.scale
			farm.update_walk(0.13, true, heading)
			assert(farm.walk_frame == index * 2 + 1, "Both farmers must switch stride in all directions")
			assert(farm.farmer.scale == stride_scale, "Stride must not resize the farmer")
			var foot_y: float = farm.farmer.position.y + farm.farmer.region_rect.size.y * farm.farmer.scale.y * 0.5
			assert(is_zero_approx(foot_y), "Stride feet must stay anchored to the player")
			farm.update_walk(0.0, false)
			assert(farm.walk_frame == index * 2, "Both farmers retain facing when stopped")
	farm.set_character("boy")
	farm.coins = 500
	farm.harvests = 0
	farm.nearest = 0
	farm.plots[0].stage = 0
	farm.player.position = farm.plots[0].position
	farm.select_tool(0)
	farm.interact()
	assert(farm.coins == 495 and farm.plots[0].stage == 1, "Planting must consume seed cost")
	farm._physics_process(20)
	assert(farm.plots[0].stage == 1, "Unwatered crop must not grow")
	farm.nearest = 0
	farm.select_tool(1)
	farm.interact()
	assert(farm.plots[0].stage == 2, "Watering must begin growth")
	farm._physics_process(12.1)
	assert(farm.plots[0].stage == 3, "Watered crop must mature")
	farm.nearest = 0
	farm.select_tool(2)
	farm.interact()
	assert(farm.coins == 515 and farm.harvests == 1 and farm.plots[0].stage == 0, "Harvest must pay out and clear bed")
	farm.interact()
	assert(farm.coins == 515, "Empty bed must not pay twice")
	farm.save_game(false)
	farm.coins = 0
	farm.load_game()
	assert(farm.coins == 515, "Save must restore state")
	farm.show_character_picker()
	assert(farm.choosing_character, "Picker opens")
	farm.choose_character("girl")
	farm.update_walk(0.13, true, Vector2.RIGHT)
	assert(farm.farmer.texture == farm.GIRL_TEXTURE and farm.facing_direction == 6, "Girl walks east")
	farm.set_character("boy")
	farm.load_game()
	assert(farm.character_choice == "girl" and farm.coins == 515, "Choice and progress persist")
	farm.choose_character("boy")
	# Test actual physics collision against the map boundary.
	farm.player.position = Vector2(900, 555)
	for i in range(30):
		farm.player.velocity = Vector2(0, -200)
		farm.player.move_and_slide()
		await physics_frame
	assert(farm.player.position.y >= 545, "Waterfront must block movement")
	for resolution in [Vector2i(1170, 540), Vector2i(960, 720)]:
		root.size = resolution
		await process_frame
		farm.layout_ui()
		var view: Vector2 = farm.get_viewport_rect().size
		assert(farm.action_button.position.x + farm.action_button.size.x <= view.x, "Action stays on screen")
		assert(farm.joystick.position.y + farm.joystick.size.y <= view.y, "Movement stays on screen")
		assert(farm.tool_bar.position.x > farm.joystick.position.x + farm.joystick.size.x, "Toolbar avoids movement controls")
	farm.coins = 500
	farm.harvests = 0
	farm.player.position = Vector2(450, 1120)
	for plot in farm.plots:
		plot.stage = 0
		plot.growth = 0.0
	farm.save_game(false)
	print("PASS: plant/water/grow/harvest, repeated action, save/load, collision, phone/tablet layout")
	farm.queue_free()
	await process_frame
	quit(0)

