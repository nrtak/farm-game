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
	farm.tea_picked_days = [0, 0, 0]
	farm.tea_leaves = 0
	farm.packed_tea = 0
	farm.tea_shipping = 0
	farm.health = 100
	for npc in farm.regions.tea.npcs:
		if npc.first_name == "Sachiko":
			farm.start_conversation(npc)
			assert(farm.tea_lesson_seen and farm.dialogue_lines.size() == 3)
			farm.close_dialogue()
	for spot in farm.TEA_SPOTS:
		assert(farm.regions.tea.is_walkable(spot))
		farm.travel_to("tea", spot, false)
		assert(farm.interaction_action() == "pick_tea")
		farm.interact()
		farm.interact()
	assert(farm.tea_leaves == 3 and farm.health == 94)
	farm.enter_shop("Tea Processing Shed")
	farm.open_service("Tea Processing Shed")
	farm.process_tea()
	farm.process_tea()
	assert(farm.tea_leaves == 1 and farm.packed_tea == 1)
	farm.close_dialogue()
	farm.save_game(false)
	farm.tea_leaves = 0
	farm.packed_tea = 0
	farm.load_game()
	assert(farm.tea_leaves == 1 and farm.packed_tea == 1 and farm.tea_picked_days == [1, 1, 1])
	farm.open_shipping()
	farm.ship_produce()
	farm.ship_produce()
	farm.close_dialogue()
	var money: int = farm.coins
	farm.day = 2
	farm.settle_farm_day()
	farm.settle_farm_day()
	assert(farm.coins == money + 45 and farm.tea_shipping == 0)
	farm.travel_to("tea", farm.TEA_SPOTS[0], false)
	farm.interact()
	assert(farm.tea_leaves == 2)
	farm.health = 1
	farm.travel_to("tea", farm.TEA_SPOTS[1], false)
	farm.interact()
	assert(farm.tea_leaves == 2)
	print("PASS: tea lesson, accessible rows, daily harvest limits, Health, packing, saves, shipping payment once, next-day regrowth")
	quit()
