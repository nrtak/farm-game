extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var farm = load("res://Main.tscn").instantiate()
	root.add_child(farm)
	await process_frame
	farm.set_physics_process(false)
	farm.choose_character("boy")
	farm.set_location(false, Vector2(450, 1120))
	farm.day = 1
	farm.clock_minutes = farm.WAKE_MINUTE
	farm.health = farm.MAX_HEALTH
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
		assert(farm.walk_frame == index * 4, "Idle retains last facing")
	# Both farmers must alternate every facing without changing size or foot height.
	for choice in ["boy", "girl"]:
		farm.set_character(choice)
		for index in range(8):
			var heading := Vector2.DOWN.rotated(index * PI / 4.0)
			farm.update_walk(0.0, false, heading)
			farm.update_walk(0.0, true, heading)
			assert(farm.walk_frame == index * 4, "First stride must match facing")
			var stride_scale: Vector2 = farm.farmer.scale
			farm.update_walk(0.13, true, heading)
			assert(farm.walk_frame == index * 4 + 1, "Both farmers must switch stride in all directions")
			assert(farm.farmer.scale == stride_scale, "Stride must not resize the farmer")
			for phase in [2, 3]:
				farm.update_walk(0.0, true, heading, farm.STRIDE_DISTANCE)
				assert(farm.walk_frame == index * 4 + phase, "Walk must include opposite contact and passing phases")
				assert(farm.farmer.scale == stride_scale, "All four phases must retain scale")
			var paused_frame: int = farm.walk_frame
			farm.update_walk(1.0, true, heading, 0.0)
			assert(farm.walk_frame == paused_frame, "No travel must not advance the stride")
			assert(farm.farmer.flip_h == (index in [5, 6, 7]), "Rightward directions mirror the corresponding leftward cycle")
			farm.update_walk(0.0, false)
			assert(farm.walk_frame == index * 4, "Both farmers retain facing when stopped")
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
	assert(farm.farmer.texture == farm.GIRL_SIDE_TEXTURE and farm.facing_direction == 6, "Girl walks east")
	farm.set_character("boy")
	farm.load_game()
	assert(farm.character_choice == "girl" and farm.coins == 515, "Choice and progress persist")
	farm.choose_character("boy")
	await physics_frame
	# Sweep the real player collider toward each building from every side.
	for target in [Vector2(220, 510), Vector2(1030, 325)]:
		for direction in [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]:
			farm.player.position = (target + direction * 250.0) * farm.MAP_SCALE
			var hit = farm.player.move_and_collide(-direction * 250.0 * farm.MAP_SCALE, true)
			assert(hit != null, "Buildings must block approach from every side")
	farm.player.position = Vector2(1200, 650) * farm.MAP_SCALE
	assert(farm.player.move_and_collide(Vector2(250, -300) * farm.MAP_SCALE, true) != null, "Coastal scenery must block movement")
	farm.player.position = Vector2(700, 600) * farm.MAP_SCALE
	assert(farm.player.move_and_collide(Vector2(100, 0) * farm.MAP_SCALE, true) == null, "Expansion meadow must stay open")
	for plot in farm.plots:
		assert(farm.is_walkable(plot.position), "All crop beds must remain reachable")
	for index in range(3):
		assert(farm.tool_buttons[index].text == ["Seed", "Water", "Harvest"][index], "Tool labels must omit shortcut numbers")
	# Saves from the earlier map must not place the player inside solid scenery.
	farm.player.position = Vector2(220, 510) * farm.MAP_SCALE
	farm.save_game(false)
	farm.load_game()
	assert(farm.player.position == Vector2(450, 1120), "Blocked saved positions return to the starter field")
	# Context actions use the same controls as tending the field.
	farm.player.position = farm.farmhouse.DOOR_POSITION
	assert(farm.is_walkable(farm.player.position), "Front door must be reachable")
	farm.refresh_hud()
	assert(farm.action_button.text == "Enter", "Door offers entry")
	farm.interact()
	assert(farm.inside_house and farm.player.collision_mask == 2, "Entry switches to indoor collision")
	assert(not farm.tool_bar.visible and farm.interior.visible and not farm.outdoor_world.visible, "Room replaces exterior and tools")
	await physics_frame
	farm.player.position = farm.ROOM_ORIGIN + Vector2(700, 350)
	assert(farm.player.move_and_collide(Vector2(100, 0), true) != null, "Bed blocks walking")
	farm.player.position = farm.ROOM_ORIGIN + farm.interior.BED_APPROACH
	farm.plots[0].stage = 1
	farm.plots[1].stage = 2
	farm.plots[1].growth = 1.0
	var saved_coins: int = farm.coins
	farm.refresh_hud()
	assert(farm.action_button.text == "Sleep", "Bed offers sleep")
	farm.interact()
	assert(farm.confirming_sleep and farm.day == 1, "Sleep requires in-game confirmation")
	farm.cancel_sleep()
	assert(farm.day == 1 and farm.plots[1].stage == 2, "Cancel preserves day and crop growth")
	farm.interact()
	farm.sleep_until_morning()
	assert(farm.day == 2 and farm.plots[1].stage == 3 and farm.plots[0].stage == 1, "Only watered crops mature overnight")
	assert(farm.coins == saved_coins, "Sleeping must preserve coins")
	farm.sleep_until_morning()
	assert(farm.day == 2, "Repeated confirmation cannot skip another day")
	farm.day = 28
	farm.offer_sleep()
	farm.sleep_until_morning()
	assert(farm.calendar_text() == "Summer 1  |  Year 1", "Season rolls over after 28 days")
	farm.day = 112
	farm.offer_sleep()
	farm.sleep_until_morning()
	assert(farm.calendar_text() == "Spring 1  |  Year 2", "Year rolls over after four seasons")
	farm.save_game(false)
	farm.set_location(false, Vector2(450, 1120))
	farm.day = 1
	farm.load_game()
	assert(farm.inside_house and farm.day == 113 and farm.coins == saved_coins, "Save restores indoor location, calendar and money")
	farm.player.position = farm.ROOM_ORIGIN + farm.interior.EXIT
	farm.interact()
	assert(not farm.inside_house and farm.player.collision_mask == 1 and farm.tool_bar.visible, "Exit restores outdoor movement and tools")
	assert(farm.is_walkable(farm.player.position), "Exit must land on clear ground")
	# Legacy saves have no calendar/location fields; preserve their crops and money.
	var legacy := FileAccess.open(farm.SAVE_FILE, FileAccess.WRITE)
	legacy.store_string(JSON.stringify({"version": 2, "coins": 321, "harvests": 4, "character": "girl", "x": 450, "y": 1120, "plots": [{"stage": 1, "growth": 0}]}))
	legacy.close()
	farm.load_game()
	assert(not farm.inside_house and farm.day == 1 and farm.coins == 321 and farm.character_choice == "girl" and farm.plots[0].stage == 1, "Legacy saves migrate without losing farm progress")
	assert(farm.health == 100 and farm.clock_text() == "6:00 AM", "Legacy saves start rested at 6 AM")
	farm.window_focused = true
	farm.advance_clock(600.0)
	assert(farm.clock_text() == "4:00 PM" and farm.health == 100, "Ten real minutes reach 4 PM without passive daytime drain")
	farm.toggle_pause()
	farm.advance_clock(60.0)
	assert(farm.clock_text() == "4:00 PM", "Pause freezes clock")
	farm.toggle_pause()
	farm.clock_minutes = 1250.0
	farm.advance_clock(20.0)
	assert(is_equal_approx(farm.health, 99.0), "Only minutes after 9 PM drain Health")
	farm.clock_minutes = 1435.0
	farm.advance_clock(10.0)
	assert(farm.day == 2 and farm.clock_text() == "12:05 AM", "Midnight advances date without ending the day")
	farm.set_location(true, farm.ROOM_ORIGIN + farm.interior.BED_APPROACH)
	farm.offer_sleep()
	var frozen_time: float = farm.clock_minutes
	farm.advance_clock(30.0)
	assert(farm.clock_minutes == frozen_time, "Sleep dialog freezes clock")
	farm.sleep_until_morning()
	assert(farm.day == 2 and farm.health == 100 and farm.clock_text() == "6:00 AM", "After-midnight sleep wakes on the same date fully rested")
	farm.set_location(false, Vector2(450, 1120))
	farm.nearest = 0
	farm.plots[0].stage = 0
	farm.select_tool(0)
	farm.health = 1.0
	var balance: int = farm.coins
	farm.interact()
	assert(farm.plots[0].stage == 0 and farm.coins == balance and farm.health == 1, "Insufficient Health cannot spend money or plant")
	farm.health = 10.0
	farm.interact()
	assert(farm.health == 8, "Planting spends two Health")
	farm.interact()
	assert(farm.health == 8, "Invalid repeated work spends no Health")
	farm.select_tool(1)
	farm.interact()
	assert(farm.health == 6, "Watering spends two Health")
	farm.plots[0].stage = 3
	farm.select_tool(2)
	farm.interact()
	assert(farm.health == 3, "Harvesting spends three Health")
	farm.clock_minutes = 950.0
	farm.save_game(false)
	farm.health = 100
	farm.clock_minutes = 360.0
	farm.load_game()
	assert(farm.health == 3 and farm.clock_minutes == 950, "Save restores exact Health and clock")
	for resolution in [Vector2i(1170, 540), Vector2i(960, 720)]:
		root.size = resolution
		await process_frame
		farm.layout_ui()
		var view: Vector2 = farm.get_viewport_rect().size
		assert(farm.action_button.position.x + farm.action_button.size.x <= view.x, "Action stays on screen")
		assert(farm.health_bar.get_global_rect().end.y < farm.message_label.position.y, "Health does not overlap guidance")
		assert(farm.joystick.position.y + farm.joystick.size.y <= view.y, "Movement stays on screen")
		assert(farm.tool_bar.position.x > farm.joystick.position.x + farm.joystick.size.x, "Toolbar avoids movement controls")
	farm.coins = 500
	farm.health = 100
	farm.clock_minutes = 360.0
	farm.day = 1
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

