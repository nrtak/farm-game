extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var farm = load("res://Main.tscn").instantiate()
	root.add_child(farm)
	await process_frame
	farm.set_physics_process(false)
	farm.choose_character("boy")
	farm.backpack_level = 0
	farm.produce = {"Turnip": 12, "Potato": 0, "Strawberry": 0}
	farm.fish_basket = {"Sardine": 0, "Mackerel": 0, "Sea Bream": 0}
	farm.ore_basket = {"Copper": 0, "Iron": 0}
	farm.tea_leaves = 0
	farm.packed_tea = 0
	for item in farm.stored_items: farm.stored_items[item] = 0
	farm.enter_house()
	assert(farm.interior.is_walkable(farm.interior.CHEST_APPROACH))
	farm.player.position = farm.ROOM_ORIGIN + farm.interior.CHEST_APPROACH
	assert(farm.interaction_action() == "storage")
	farm.interact()
	farm.transfer_storage("Turnip", 1, true)
	assert(farm.produce.Turnip == 11 and farm.stored_items.Turnip == 1)
	farm.transfer_storage("Turnip", 999, true)
	assert(farm.backpack_count() == 0 and farm.stored_items.Turnip == 12)
	farm.stored_items.Iron = 20
	farm.transfer_storage("Iron", 999, false)
	assert(farm.ore_basket.Iron == 12 and farm.stored_items.Iron == 8)
	farm.transfer_storage("Turnip", 1, false)
	assert(farm.produce.Turnip == 0 and farm.stored_items.Turnip == 12, "Full bag refuses withdrawal")
	farm.store_everything()
	assert(farm.backpack_count() == 0 and farm.stored_items.Iron == 20)
	farm.tea_leaves = 3
	farm.packed_tea = 2
	farm.fish_basket.Sardine = 4
	farm.store_everything()
	assert(farm.stored_items["Tea leaves"] == 3 and farm.stored_items["Tea packets"] == 2 and farm.stored_items.Sardine == 4)
	farm.stored_items.Copper = 998
	farm.ore_basket.Copper = 5
	farm.store_everything()
	assert(farm.stored_items.Copper == 999 and farm.ore_basket.Copper == 4, "Chest overflow retained in bag")
	farm.close_dialogue()
	farm.save_game(false)
	farm.stored_items.Iron = 0
	farm.load_game()
	assert(farm.stored_items.Iron == 20 and farm.stored_items.Copper == 999)
	farm.day += 1
	var coins: int = farm.coins
	farm.settle_farm_day()
	assert(farm.stored_items.Iron == 20 and farm.coins == coins, "Stored goods do not ship overnight")
	farm.leave_house()
	farm.open_shipping()
	farm.ship_produce()
	farm.close_dialogue()
	assert(farm.stored_items.Iron == 20 and farm.ore_shipping.Copper == 4)
	print("PASS: chest approach, one/all transfers, backpack limit, all inventories, chest overflow, persistence, stored goods separate from shipping")
	quit()
