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
	farm.health = 100
	farm.ore_basket = {"Copper": 0, "Iron": 0}
	farm.ore_shipping = farm.ore_basket.duplicate()
	farm.ore_picked_days = [0, 0, 0, 0]
	farm.mine_lesson_seen = false
	for npc in farm.regions.mountain.npcs:
		if npc.first_name == "Hiro":
			farm.start_conversation(npc)
			assert(farm.mine_lesson_seen and farm.dialogue_lines.size() == 3)
			farm.close_dialogue()
	assert(farm.regions.mountain.is_walkable(farm.RegionScript.MINE_DOOR))
	farm.travel_to("mountain", farm.RegionScript.MINE_DOOR, false)
	farm.check_walk_exits()
	assert(farm.shop_name == "Mine" and farm.location == "shop")
	for spot in farm.MINE_SPOTS:
		assert(farm.shops.Mine.is_walkable(spot))
		farm.player.position = farm.SHOP_ORIGIN + spot
		assert(farm.interaction_action() == "mine_ore")
		farm.interact()
		farm.interact()
	assert(farm.ore_basket == {"Copper": 2, "Iron": 2} and farm.health == 84)
	farm.save_game(false)
	farm.ore_basket.Copper = 0
	farm.load_game()
	assert(farm.ore_basket.Copper == 2 and farm.shops.Mine.depleted == [true, true, true, true])
	farm.player.position = farm.SHOP_ORIGIN + Vector2(550, 770)
	farm.check_walk_exits()
	assert(farm.location == "mountain")
	farm.check_walk_exits()
	assert(farm.location == "mountain", "Exit does not immediately reenter mine")
	farm.open_shipping()
	farm.ship_produce()
	farm.ship_produce()
	farm.close_dialogue()
	var money: int = farm.coins
	farm.day = 2
	farm.settle_farm_day()
	farm.settle_farm_day()
	assert(farm.coins == money + 160)
	farm.enter_shop("Mine")
	farm.player.position = farm.SHOP_ORIGIN + farm.MINE_SPOTS[0]
	farm.interact()
	assert(farm.ore_basket.Copper == 1)
	farm.health = 3
	farm.player.position = farm.SHOP_ORIGIN + farm.MINE_SPOTS[1]
	farm.interact()
	assert(farm.ore_basket.Iron == 0)
	print("PASS: mine walking entrance/exit, ore reachability, daily limits, Health, saves/depletion, shipping once, refreshed rocks")
	quit()
