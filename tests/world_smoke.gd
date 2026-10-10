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
	farm.day = 1
	farm.clock_minutes = 600
	farm.coins = 500
	farm.seeds = 5
	farm.travel_to("farm", farm.FARM_EXIT, false)
	assert(farm.interaction_action() == "town", "Farm gateway reachable")
	farm.interact()
	assert(farm.location == "town" and farm.player.collision_mask == 4, "Farm directly reaches town")
	await physics_frame
	for building in farm.town.BUILDINGS:
		var door: Vector2 = building.door * farm.town.ART_SCALE
		assert(farm.town.is_walkable(door), "Every shop entrance is reachable: " + building.name)
		farm.player.position = farm.TOWN_ORIGIN + door
		assert(farm.player.move_and_collide(Vector2(0, -150), true) != null, "Buildings block movement")
	var cast_count: int = farm.town.npcs.size()
	for area in farm.regions.values(): cast_count += area.npcs.size()
	assert(cast_count == 22, "Full established cast present")
	for minute in [360, 800, 1100]:
		farm.town.update_schedules(minute)
		farm.town.update_supporting_routes(minute)
		for npc in farm.town.npcs:
			for point in npc.route:
				assert(farm.town.is_walkable(point), "NPC waypoint clear for %s at %s, minute %s" % [npc.first_name, point, minute])
		for step in range(600):
			farm.town.tick(0.1, minute)
			for npc in farm.town.npcs: assert(farm.town.is_walkable(npc.position), "NPC path avoids buildings: %s %s minute %s" % [npc.first_name, npc.position, minute])
	for area_name in farm.regions:
		var area = farm.regions[area_name]
		farm.travel_to(area_name, Vector2(800, 950), false)
		assert(area.visible and farm.player.collision_mask == 16, "Region has its collision layer")
		for step in range(600):
			area.tick(0.1, 600)
			for resident in area.npcs: assert(area.is_walkable(resident.position), "Regional paths remain on clear ground")
		for npc in area.npcs:
			farm.start_conversation(npc)
			assert(farm.dialogue_open and farm.dialogue_lines.size() >= 1, "Regional cast conversations")
			while farm.dialogue_open: farm.advance_dialogue()
			assert(not farm.dialogue_open and not npc.paused, "Dialogue releases controls and NPC")
		await process_frame
		farm.player.position = farm.REGION_ORIGINS[area_name] + Vector2(800, 1100)
		farm.interact()
		assert(farm.location == "town", "All regions return to town")
	var npc = farm.town.npcs[0]
	farm.start_conversation(npc)
	var time: float = farm.clock_minutes
	var friendship: int = farm.friendship[npc.first_name]
	farm.advance_clock(100)
	assert(farm.clock_minutes == time, "Conversation freezes game time")
	farm.advance_dialogue()
	farm.advance_dialogue()
	farm.start_conversation(npc)
	assert(farm.friendship[npc.first_name] == friendship, "Daily talk reward cannot be farmed")
	farm.close_dialogue()
	await process_frame
	farm.open_service("General Store")
	assert(farm.dialogue_open, "Store opens during hours")
	farm.purchase_seeds()
	assert(farm.seeds == 10 and farm.coins == 475, "Seed purchase has correct stock and cost")
	farm.coins = 0
	farm.purchase_seeds()
	assert(farm.seeds == 10, "No purchase without sufficient yen")
	farm.close_dialogue()
	await process_frame
	farm.clock_minutes = 800
	farm.coins = 500
	farm.health = 50
	farm.open_service("Café")
	farm.purchase_meal()
	assert(farm.health == 80 and farm.coins == 470, "Meal restores Health for yen")
	farm.health = 100
	farm.purchase_meal()
	assert(farm.coins == 470, "Full Health avoids wasted meal purchase")
	farm.close_dialogue()
	await process_frame
	farm.tool_level = 0
	farm.ore_basket.Copper = 2
	farm.open_service("Blacksmith")
	farm.purchase_upgrade()
	assert(farm.tool_level == 1 and farm.coins == 370, "Tool upgrade purchased once")
	farm.purchase_upgrade()
	assert(farm.coins == 370, "Cannot buy same upgrade twice")
	farm.close_dialogue()
	await process_frame
	farm.travel_to("farm", Vector2(450, 1120), false)
	farm.nearest = 0
	farm.plots[0].stage = 1
	farm.select_tool(1)
	farm.health = 1
	farm.interact()
	assert(farm.health == 0 and farm.plots[0].stage == 2, "Upgraded watering works with one Health")
	for area_name in ["town", "tea", "harbor", "mountain", "historic"]:
		var point := Vector2(1200, 1200) if area_name == "town" else (Vector2(500, 500) if area_name == "road" else Vector2(800, 950))
		farm.travel_to(area_name, point, false)
		farm.save_game(false)
		var saved_position: Vector2 = farm.player.position
		farm.travel_to("farm", Vector2(450, 1120), false)
		farm.load_game()
		assert(farm.location == area_name and farm.player.position == saved_position, "Save restores every area: " + area_name)
	assert(farm.seeds == 10 and farm.tool_level == 1, "Save keeps inventory and tool upgrade")
	farm.friendship["Emi"] = 17
	farm.save_game(false)
	farm.friendship.erase("Emi")
	farm.load_game()
	assert(farm.friendship.Emi == 17, "Regional friendship survives a fresh dictionary")
	farm.save_game(false)
	var damaged := FileAccess.open(farm.SAVE_FILE, FileAccess.WRITE)
	damaged.store_string("interrupted save")
	damaged.close()
	farm.friendship.erase("Emi")
	farm.load_game()
	assert(farm.friendship.Emi == 17, "Recovery copy restores an interrupted save")
	farm.travel_to("farm", Vector2(900, 1200), false)
	farm.resources.action_time = 0
	farm.joystick.direction = Vector2(0.5, 0)
	farm._physics_process(0.016)
	var walking: float = farm.player.velocity.length()
	farm.joystick.direction = Vector2(1, 0)
	farm._physics_process(0.016)
	assert(farm.running and farm.player.velocity.length() > walking, "Strong joystick runs faster")
	farm.toggle_pause()
	var paused_time: float = farm.clock_minutes
	farm._physics_process(100)
	assert(farm.clock_minutes == paused_time, "Pause blocks movement and time")
	farm.toggle_pause()
	farm.travel_to("town", Vector2(1200, 950), false)
	farm.begin_festival()
	assert(farm.festival_people.size() == 27, "Entire cast attends rehearsal")
	var before: float = farm.clock_minutes
	farm.advance_clock(5)
	assert(farm.clock_minutes == before, "Festival pauses the daily clock")
	for record in farm.festival_people:
		var visitor = record.npc
		assert(visitor.get_parent() == farm.town, "Festival visitor moves into plaza")
		assert(farm.town.nearest_npc(visitor.position) != null, "Festival visitors are approachable")
	farm.end_festival()
	for area in farm.regions.values():
		for visitor in area.npcs: assert(visitor.get_parent() == area and not visitor.paused, "Visitors return home")
	for title in farm.CharacterScenes.SCENES:
		farm.start_scene(title)
		while farm.active_scene != "": farm.advance_scene()
		assert(farm.seen_scenes.has(title), "Scene completes and is recorded")
	assert(farm.scene_actors.is_empty(), "Scene actors return to normal routines")
	farm.clock_minutes = 439
	assert(farm.clock_text() == "7:00 AM")
	farm.clock_minutes = 450
	assert(farm.clock_text() == "7:30 AM")
	var exits := {"mountain": Vector2(1280, 60), "harbor": Vector2(60, 1080), "tea": Vector2(2340, 1080), "historic": Vector2(180,150)}
	for area in exits:
		farm.travel_to("town", farm.town.design(exits[area]), false)
		farm._physics_process(0.016)
		assert(farm.location == area, "Walk into " + area)
		farm._physics_process(0.016)
		assert(farm.location == area, "Arrival does not bounce back")
		var returns := {"harbor":Vector2(1540,585),"tea":Vector2(60,665),"historic":Vector2(1540,1100),"mountain":Vector2(800,1130)}
		farm.player.position = farm.REGION_ORIGINS[area] + returns[area]
		farm._physics_process(0.016)
		assert(farm.location == "town", "Walk back from " + area)
		farm._physics_process(0.016)
		assert(farm.location == "town", "Town arrival remains in town")
	farm.travel_to("town", Vector2(1200, farm.town.SIZE.y - 60), false)
	farm._physics_process(0.016)
	assert(farm.location == "farm", "Town south directly reaches farm")
	farm.player.position = farm.FARM_EXIT
	farm._physics_process(0.016)
	assert(farm.location == "town", "Farm walkway automatically enters town")
	farm.open_guide()
	assert(farm.dialogue_open and not farm.message_label.visible, "Guide pauses play and hides unrelated hints")
	var touch := InputEventScreenTouch.new()
	touch.position = farm.joystick.global_position + farm.joystick.size / 2
	touch.index = 0
	touch.pressed = true
	farm.joystick._input(touch)
	assert(farm.joystick.finger == -1 and farm.joystick.direction == Vector2.ZERO, "Hidden joystick cannot intercept dialogue taps")
	farm.close_dialogue()
	for service in ["General Store", "Blacksmith", "Café", "Inn", "Clinic", "Town Hall", "Police Box", "Fire Station"]:
		farm.clock_minutes = 800
		farm.travel_to("town", farm.service_door(service), false)
		farm.interact()
		assert(farm.location == "shop" and farm.shop_name == service)
		var room = farm.shops[service]
		assert(room.visible and room.is_walkable(room.ENTRY) and room.is_walkable(room.COUNTER))
		farm.player.position = farm.SHOP_ORIGIN + room.residents[0].position + Vector2(0, 65)
		if room.residents[0].visible:
			assert(farm.interaction_action() == "talk_shop")
			farm.interact()
			assert(farm.dialogue_open)
			farm.close_dialogue()
		farm.player.position = farm.SHOP_ORIGIN + room.COUNTER
		await physics_frame
		assert(farm.player.move_and_collide(Vector2(0, -100), true) != null, "Solid counter")
		assert(farm.interaction_action() == "counter")
		farm.interact()
		assert(farm.dialogue_open)
		farm.close_dialogue()
		farm.save_game(false)
		farm.travel_to("farm", Vector2(900, 1120), false)
		farm.load_game()
		assert(farm.location == "shop" and farm.shop_name == service, "Interior save restores")
		farm.player.position = farm.SHOP_ORIGIN + Vector2(550, 765)
		farm._physics_process(0.016)
		assert(farm.location == "town" and not room.visible, "Walk out the door")
		farm.clock_minutes = 200
		farm.enter_shop(service)
		assert(farm.location == "town", "Closed hours respected")
	farm.clock_minutes = 800
	farm.enter_shop("Clinic")
	farm.player.position = farm.SHOP_ORIGIN + farm.shops.Clinic.COUNTER
	farm.interact()
	farm.health = 20
	farm.coins = 100
	farm.clinic_treatment()
	assert(farm.health == 100 and farm.coins == 50)
	farm.clinic_treatment()
	assert(farm.coins == 50, "Healthy player not charged")
	farm.health = 20
	farm.coins = 49
	farm.clinic_treatment()
	assert(farm.health == 20 and farm.coins == 49, "Unaffordable treatment not charged")
	farm.close_dialogue()
	for room_name in farm.REGIONAL_ROOMS:
		farm.clock_minutes = 600 if room_name == "Mountain Carpentry" else 800
		var entrance = farm.REGIONAL_ROOMS[room_name]
		assert(farm.regions[entrance[0]].is_walkable(entrance[1]), "Exterior door has clear approach: " + room_name)
		farm.travel_to(entrance[0], entrance[1], false)
		assert(farm.interaction_action() == "regional_door", "Regional doorway reachable: " + room_name + " (" + farm.interaction_action() + ")")
		farm.interact()
		assert(farm.location == "shop" and farm.shop_name == room_name)
		assert(farm.shops[room_name].is_walkable(farm.ShopScript.ENTRY))
		var room = farm.shops[room_name]
		var fixture: Rect2 = room.solids[0]
		farm.player.position = farm.SHOP_ORIGIN + Vector2(fixture.get_center().x,fixture.end.y+35)
		await physics_frame
		assert(farm.player.move_and_collide(Vector2(0, -100), true) != null, "Rock or counter blocks movement")
		for resident in room.residents:
			farm.start_conversation(resident)
			assert(farm.dialogue_open)
			farm.close_dialogue()
		farm.save_game(false)
		farm.travel_to("farm", Vector2(900, 1150), false)
		farm.load_game()
		assert(farm.location == "shop" and farm.shop_name == room_name)
		farm.player.position = farm.SHOP_ORIGIN + Vector2(550, 765)
		farm._physics_process(0.016)
		assert(farm.location == entrance[0], "Exit returns to original region")
	farm.lost_item_stage = 0
	farm.enter_shop("Police Box")
	var taro = farm.shops["Police Box"].residents[0]
	farm.start_conversation(taro)
	assert(farm.lost_item_stage == 0)
	farm.accept_story_request()
	assert(farm.lost_item_stage == 1)
	farm.close_dialogue()
	farm.enter_shop("Archive")
	assert(farm.shops.Archive.lost_item_visible)
	farm.player.position = farm.SHOP_ORIGIN + farm.shops.Archive.WALLET
	assert(farm.shops.Archive.is_walkable(farm.shops.Archive.WALLET), "Wallet approachable")
	assert(farm.interaction_action() == "collect_wallet")
	farm.interact()
	assert(farm.lost_item_stage == 2 and not farm.shops.Archive.lost_item_visible)
	farm.save_game(false)
	farm.lost_item_stage = 0
	farm.load_game()
	assert(farm.lost_item_stage == 2)
	farm.enter_shop("Police Box")
	var old_coins: int = farm.coins
	farm.start_conversation(taro)
	assert(farm.lost_item_stage == 3 and farm.coins == old_coins + 75)
	farm.close_dialogue()
	farm.start_conversation(taro)
	assert(farm.coins == old_coins + 75, "Quest rewarded only once")
	farm.close_dialogue()
	farm.save_game(false)
	farm.load_game()
	assert(farm.lost_item_stage == 3)
	print("PASS: farm-road-town, 22 cast, routes, dialogue, shops, upgrades, saves, movement, pause, festival, ten scenes")
	farm.queue_free()
	await process_frame
	quit(0)
