extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var farm = load("res://Main.tscn").instantiate()
	root.add_child(farm)
	await process_frame
	farm.set_physics_process(false)
	farm.choose_character("boy")
	for minute in [480, 800, 1140]:
		farm.clock_minutes = minute
		farm.refresh_hud()
		var counts := {}
		for npc in farm.town.npcs:
			if npc.visible: counts[npc.first_name] = int(counts.get(npc.first_name, 0)) + 1
		for region in farm.regions.values():
			for npc in region.npcs:
				if npc.visible: counts[npc.first_name] = int(counts.get(npc.first_name, 0)) + 1
		for room in farm.shops.values():
			for npc in room.residents:
				if npc.visible: counts[npc.first_name] = int(counts.get(npc.first_name, 0)) + 1
		assert(counts.size() == 22)
		for person in counts: assert(counts[person] == 1, "One location per resident: " + person)
	farm.clock_minutes = 1140
	farm.enter_shop("Tea Farmhouse")
	assert(farm.shops["Tea Farmhouse"].residents[1].visible)
	for step in range(300):
		farm.shops["Tea Farmhouse"].tick(0.1)
		for npc in farm.shops["Tea Farmhouse"].residents:
			if npc.visible and not npc.route.is_empty(): assert(farm.shops["Tea Farmhouse"].is_walkable(npc.position))
	farm.tea_delivery_stage = 0
	farm.start_conversation(farm.shops["Tea Farmhouse"].residents[1])
	assert(farm.tea_delivery_stage == 0)
	farm.accept_story_request()
	assert(farm.tea_delivery_stage == 1)
	farm.close_dialogue()
	farm.save_game(false)
	farm.tea_delivery_stage = 0
	farm.load_game()
	assert(farm.tea_delivery_stage == 1)
	farm.clock_minutes = 800
	farm.enter_shop("Café")
	var coins: int = farm.coins
	farm.start_conversation(farm.shops["Café"].residents[0])
	assert(farm.tea_delivery_stage == 2 and farm.coins == coins + 40)
	farm.close_dialogue()
	farm.start_conversation(farm.shops["Café"].residents[0])
	assert(farm.coins == coins + 40)
	farm.close_dialogue()
	farm.begin_festival()
	for record in farm.festival_people: assert(record.npc.visible)
	for room in farm.shops.values():
		for npc in room.residents: assert(not npc.visible)
	farm.end_festival()
	print("PASS: single resident presence, schedules, indoor routes, tea quest save and one-time reward, festival override")
	farm.queue_free()
	await process_frame
	quit()
