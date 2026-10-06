extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var farm = load("res://Main.tscn").instantiate()
	root.add_child(farm)
	await process_frame
	farm.set_physics_process(false)
	farm.choose_character("boy")
	farm.day = 1
	farm.clock_minutes = 600
	farm.backpack_level = 0
	farm.produce = {"Turnip": 12, "Potato": 0, "Strawberry": 0}
	farm.fish_basket = {"Sardine": 0, "Mackerel": 0, "Sea Bream": 0}
	farm.ore_basket = {"Copper": 0, "Iron": 0}
	farm.tea_leaves = 0
	farm.packed_tea = 0
	assert(farm.backpack_count() == 12 and not farm.backpack_has_room())
	farm.travel_to("tea", farm.TEA_SPOTS[0], false)
	farm.tea_picked_days = [0, 0, 0]
	farm.health = 100
	farm.harvest_tea()
	assert(farm.tea_leaves == 0 and farm.tea_picked_days[0] == 0 and farm.health == 100)
	farm.enter_shop("Mine")
	farm.ore_picked_days = [0, 0, 0, 0]
	farm.player.position = farm.SHOP_ORIGIN + farm.MINE_SPOTS[0]
	farm.mine_ore()
	assert(farm.ore_basket.Copper == 0 and farm.ore_picked_days[0] == 0 and farm.health == 100)
	farm.travel_to("farm", Vector2(400, 1200), false)
	farm.nearest = 0
	farm.selected_tool = 2
	farm.plots[0].stage = 3
	farm.plots[0].crop = "Turnip"
	farm.interact()
	assert(farm.plots[0].stage == 3 and farm.produce.Turnip == 12 and farm.health == 100)
	farm.travel_to("harbor", farm.FISHING_SPOTS[0], false)
	farm.begin_fishing()
	assert(not farm.fishing_active and farm.health == 100, "Full bag cannot spend Health casting")
	farm.coins = 299
	farm.open_backpack_shop()
	farm.purchase_backpack()
	assert(farm.backpack_level == 0 and farm.coins == 299)
	farm.coins = 1200
	farm.purchase_backpack()
	assert(farm.backpack_level == 1 and farm.coins == 900 and farm.backpack_has_room())
	farm.purchase_backpack()
	farm.purchase_backpack()
	assert(farm.backpack_level == 2 and farm.coins == 0)
	farm.close_dialogue()
	farm.save_game(false)
	farm.backpack_level = 0
	farm.load_game()
	assert(farm.backpack_level == 2 and farm.produce.Turnip == 12)
	farm.open_shipping()
	farm.ship_produce()
	farm.close_dialogue()
	assert(farm.backpack_count() == 0)
	farm.backpack_level = 0
	farm.produce.Turnip = 20
	farm.save_game(false)
	farm.load_game()
	assert(farm.produce.Turnip == 20 and not farm.backpack_has_room(), "Over-capacity saves preserve items")
	print("PASS: shared capacity, full-bag preserves crops/rows/rocks and Health, prices, upgrade cap, saved level, shipping frees space, legacy overflow preserved")
	quit()

