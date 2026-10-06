extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var farm = load("res://Main.tscn").instantiate()
	root.add_child(farm)
	await process_frame
	farm.set_physics_process(false)
	farm.choose_character("boy")
	farm.window_focused = true
	farm.day = 1
	farm.clock_minutes = 600
	farm.coins = 1000
	farm.tool_level = 0
	farm.pick_level = 0
	farm.harvest_level = 0
	farm.ore_basket = {"Copper": 0, "Iron": 0}
	farm.open_service("Blacksmith")
	farm.purchase_upgrade()
	assert(farm.coins == 1000 and farm.tool_level == 0)
	farm.ore_basket = {"Copper": 4, "Iron": 2}
	farm.purchase_upgrade()
	farm.purchase_ore_upgrade("pick")
	farm.purchase_ore_upgrade("harvest")
	assert(farm.coins == 500 and farm.ore_basket == {"Copper": 0, "Iron": 0})
	farm.purchase_ore_upgrade("pick")
	assert(farm.coins == 500)
	farm.close_dialogue()
	farm.enter_shop("Mine")
	farm.ore_picked_days = [0, 0, 0, 0]
	farm.player.position = farm.SHOP_ORIGIN + farm.MINE_SPOTS[0]
	farm.health = 2
	farm.interact()
	assert(farm.health == 0 and farm.ore_basket.Copper == 1)
	farm.travel_to("farm", farm.plots[0].position, false)
	farm.nearest = 0
	farm.plots[0].stage = 3
	farm.plots[0].crop = "Turnip"
	farm.selected_tool = 2
	farm.health = 1
	farm.interact()
	assert(farm.health == 0 and farm.plots[0].stage == 0)
	farm.save_game(false)
	farm.pick_level = 0
	farm.harvest_level = 0
	farm.load_game()
	assert(farm.pick_level == 1 and farm.harvest_level == 1)
	farm.day = 2
	farm.plots[0].stage = 1
	farm.plots[0].growth = 0
	farm.plots[0].crop = "Potato"
	farm.plots[0].last_growth_day = 2
	farm.apply_rain_watering()
	assert(farm.plots[0].stage == 1)
	farm.day = 3
	farm.settle_farm_day()
	assert(farm.plots[0].stage == 2 and farm.plots[0].growth == 0, "Rain waters after overnight settlement")
	farm.settle_farm_day()
	assert(farm.plots[0].growth == 0)
	farm.refresh_hud()
	assert(farm.rain_overlay.visible)
	farm.enter_house()
	assert(not farm.rain_overlay.visible)
	farm.day = 4
	farm.settle_farm_day()
	assert(farm.plots[0].growth == 1 and farm.plots[0].stage == 1)
	farm.settle_farm_day()
	assert(farm.plots[0].growth == 1)
	print("PASS: ore/money requirements, three upgrades, one-time purchase, reduced work costs, saved tools, dry/rain days, free watering, single nightly growth, indoor rain hidden")
	quit()
