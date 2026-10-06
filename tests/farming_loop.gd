extends SceneTree
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	var farm = load("res://Main.tscn").instantiate()
	root.add_child(farm)
	await process_frame
	farm.set_physics_process(false)
	farm.choose_character("boy")
	farm.window_focused = true
	farm.clock_minutes = 600
	farm.day = 1
	farm.coins = 500
	farm.seeds = 5
	farm.extra_seeds = {"Potato": 5, "Strawberry": 5}
	farm.produce = {"Turnip": 0, "Potato": 0, "Strawberry": 0}
	farm.shipping_queue = farm.produce.duplicate()
	assert(farm.is_walkable(farm.SHIPPING_BOX), "Shipping box approachable")
	for crop_name in farm.CROPS:
		farm.selected_crop = crop_name
		farm.travel_to("farm", farm.plots[0].position, false)
		farm.nearest = 0
		farm.health = 100
		farm.plots[0].stage = 0
		farm.select_tool(0)
		var old_seeds: int = farm.seed_count(crop_name)
		farm.interact()
		assert(farm.plots[0].crop == crop_name and farm.seed_count(crop_name) == old_seeds - 1)
		farm.select_tool(1)
		farm.interact()
		farm._physics_process(20)
		assert(farm.plots[0].growth == 0 and farm.plots[0].stage == 2, "No growth in seconds")
		for night in range(farm.CROPS[crop_name].days):
			if night > 0:
				farm.nearest = 0
				farm.interact()
			farm.day += 1
			farm.settle_farm_day()
			var growth: float = farm.plots[0].growth
			farm.settle_farm_day()
			assert(farm.plots[0].growth == growth, "No duplicate nightly growth")
		assert(farm.plots[0].stage == 3)
		farm.nearest = 0
		farm.select_tool(2)
		farm.interact()
		assert(farm.produce[crop_name] == 1 and farm.coins == 500, "Harvest enters basket")
		farm.interact()
		assert(farm.produce[crop_name] == 1)
	farm.plots[0].stage = 1
	farm.plots[0].growth = 0
	farm.day += 1
	farm.settle_farm_day()
	assert(farm.plots[0].growth == 0, "Missed watering pauses growth")
	farm.open_shipping()
	farm.ship_produce()
	farm.ship_produce()
	assert(farm.shipping_queue.Turnip == 1 and farm.shipping_queue.Potato == 1 and farm.shipping_queue.Strawberry == 1)
	farm.close_dialogue()
	farm.save_game(false)
	farm.produce.Turnip = 99
	farm.shipping_queue.Turnip = 0
	farm.load_game()
	assert(farm.shipping_queue.Turnip == 1 and farm.produce.Turnip == 0)
	farm.day += 1
	farm.settle_farm_day()
	assert(farm.coins == 610)
	farm.settle_farm_day()
	assert(farm.coins == 610, "No duplicate shipping payout")
	farm.open_service("General Store")
	var count: int = farm.extra_seeds.Potato
	farm.purchase_crop_seeds("Potato")
	assert(farm.extra_seeds.Potato == count + 5 and farm.coins == 570)
	farm.coins = 0
	farm.purchase_crop_seeds("Strawberry")
	assert(farm.coins == 0)
	farm.close_dialogue()
	farm.open_seed_picker()
	farm.choose_crop("Potato")
	assert(farm.selected_crop == "Potato" and not farm.dialogue_open)
	print("PASS: three crops, overnight growth, daily watering, inventories, shipping, one-time payout, seed store, saves")
	farm.queue_free()
	await process_frame
	quit()
