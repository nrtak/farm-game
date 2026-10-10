extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var farm = load("res://Main.tscn").instantiate()
	root.add_child(farm)
	await process_frame
	farm.set_physics_process(false)
	farm.choose_character("boy")
	farm.window_focused = true
	farm.clock_minutes = 600
	farm.fish_basket = {"Sardine": 0, "Mackerel": 0, "Sea Bream": 0}
	farm.fish_shipping = farm.fish_basket.duplicate()
	farm.fish_catches = 0
	farm.fishing_quest_stage = 0
	farm.start_conversation(farm.regions.harbor.npcs[0])
	# Find Ken by name, independent of roster order.
	farm.close_dialogue()
	for npc in farm.regions.harbor.npcs:
		if npc.first_name == "Ken": farm.start_conversation(npc); farm.accept_story_request(); farm.close_dialogue()
	assert(farm.fishing_quest_stage == 1)
	for spot in farm.FISHING_SPOTS: assert(farm.regions.harbor.is_walkable(spot))
	farm.travel_to("harbor", farm.FISHING_SPOTS[0], false)
	farm.health = 100
	for n in range(3):
		assert(farm.interaction_action() == "fish")
		farm.interact()
		assert(farm.fishing_active)
		farm.interact()
		assert(farm.fish_catches == n, "Early tap catches nothing")
		farm._physics_process(2.2)
		farm.interact()
		assert(farm.fish_catches == n + 1 and not farm.fishing_active)
	assert(farm.health == 94 and farm.fishing_quest_stage == 2)
	farm.begin_fishing()
	farm._physics_process(4.1)
	assert(not farm.fishing_active and farm.fish_catches == 3, "Missed bite adds no fish")
	farm.health = 1
	farm.begin_fishing()
	assert(not farm.fishing_active, "Exhausted player cannot cast")
	farm.save_game(false)
	farm.fish_basket.Sardine = 0
	farm.load_game()
	assert(farm.fish_basket.Sardine == 1)
	var coins: int = farm.coins
	farm.open_shipping()
	farm.ship_produce()
	farm.ship_produce()
	farm.close_dialogue()
	farm.day += 1
	farm.settle_farm_day()
	assert(farm.coins == coins + 77)
	farm.settle_farm_day()
	assert(farm.coins == coins + 77)
	for npc in farm.regions.harbor.npcs:
		if npc.first_name == "Masao":
			farm.start_conversation(npc)
			farm.close_dialogue()
			farm.start_conversation(npc)
			farm.close_dialogue()
	assert(farm.fishing_quest_stage == 3 and farm.coins == coins + 127)
	farm.health = 100
	farm.travel_to("harbor", farm.FISHING_SPOTS[0], false)
	farm.begin_fishing()
	farm.travel_to("town", Vector2(1200, 910), false)
	assert(not farm.fishing_active, "Travel cancels fishing")
	print("PASS: fishing spots, early/missed bites, three fish, Health, saved basket, shipping, one-time quest reward")
	farm.queue_free()
	await process_frame
	quit()
