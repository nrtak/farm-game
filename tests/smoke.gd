extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var farm = load("res://Main.tscn").instantiate()
	root.add_child(farm)
	await process_frame
	farm.set_physics_process(false)
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
	# Test actual physics collision against the farmhouse front.
	farm.player.position = Vector2(520, 555)
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
	farm.player.position = Vector2(820, 710)
	for plot in farm.plots:
		plot.stage = 0
		plot.growth = 0.0
	farm.save_game(false)
	print("PASS: plant/water/grow/harvest, repeated action, save/load, collision, phone/tablet layout")
	farm.queue_free()
	await process_frame
	quit(0)
