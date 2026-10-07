extends SceneTree
func _initialize(): call_deferred("run")
func run():
	var f = load("res://Main.tscn").instantiate()
	root.add_child(f)
	await process_frame
	f.set_physics_process(false)
	f.choose_character("boy")
	f.interior_progress.story = {"intro":true}
	for point in [Vector2(1000,100),Vector2(100,400),Vector2(2350,280),Vector2(2550,1700)]:
		assert(not f.is_walkable(point),"Distant scenery and tree/water clusters are blocked")
	f.travel_to("farm",Vector2(900,1050),false)
	f.polish.plan(f.FARM_EXIT)
	assert(not f.polish.path.is_empty())
	for point in f.polish.path: assert(f.is_walkable(point))
	f.polish.direction(Vector2.RIGHT)
	assert(f.polish.path.is_empty(),"Manual movement cancels a tap route")
	f.player.position = f.FARM_EXIT
	f.check_walk_exits()
	assert(f.location == "town","Town entrance changes screen automatically")
	f.town.tick_ambient(0.1,600,false,f.shops,f.regions)
	assert(f.town.visitors[1].get_parent() == f.shops["Onsen Resort"])
	assert(f.town.visitors[3].get_parent() == f.shops["Mountain Carpentry"])
	f.clock_minutes = 600
	f.refresh_hud()
	assert(f.shops["Mountain Carpentry"].residents[0].visible)
	assert(not f.shops.Carpentry.residents[0].visible)
	f.clock_minutes = 800
	f.refresh_hud()
	assert(f.shops.Carpentry.residents[0].visible)
	assert(not f.shops["Mountain Carpentry"].residents[0].visible)
	f.travel_to("mountain",Vector2(650,900),false)
	assert(f.interaction_action() == "onsen_bath")
	f.coins=100
	f.health=40
	f.open_onsen()
	f.take_onsen()
	assert(f.health == 75 and f.coins == 60)
	f.close_dialogue()
	f.enter_shop("Onsen Resort",true)
	assert(f.shops["Onsen Resort"].is_walkable(Vector2(690,500)))
	f.health=100
	f.open_onsen()
	f.take_onsen()
	assert(f.coins == 60,"Full Health never charges for a soak")
	f.close_dialogue()
	f.travel_to("town",Vector2(900,850),false)
	assert(f.polish.nearest_pet() != null)
	f.polish.pet_animal()
	assert(f.town.pets[0].affection_time > 0)
	assert(f.tool_buttons[0].icon != null and f.tool_buttons[1].icon != null and f.tool_buttons[2].icon != null)
	assert(f.polish.daylight(1200) != f.polish.daylight(720))
	assert(f.polish.daylight(360) != f.polish.daylight(720))
	assert(SeasonalFestivals.EVENTS.size() == 16)
	f.day=96
	f.clock_minutes=1100
	f.travel_to("mountain",SeasonalFestivals.center("mountain"),false)
	f.check_scheduled_gathering()
	assert(f.festival_active and f.current_festival.id == "onsen")
	assert(f.festival_people.size() == 6)
	var event: Dictionary = f.current_festival.duplicate()
	VolunteerRequests.choose(f,event,f.day,true)
	var money: int = f.coins
	SeasonalFestivals.open_activity(f)
	SeasonalFestivals.answer(f,0)
	assert(f.coins == money+65)
	SeasonalFestivals.answer(f,0)
	assert(f.coins == money+65,"Activity and volunteering pay once")
	f.close_dialogue()
	f.end_festival()
	assert(f.coins == money+115)
	f.check_scheduled_gathering()
	assert(not f.festival_active,"Completed festival does not repeat")
	VolunteerRequests.choose_delivery(f,true)
	f.produce.Turnip=2
	VolunteerRequests.deliver(f)
	assert(f.produce.Turnip == 0 and f.interior_progress.meal_request == "completed")
	var friendship: int = f.friendship.Akira
	VolunteerRequests.choose(f,SeasonalFestivals.EVENTS[0],116,false)
	assert(f.friendship.Akira == friendship,"Declining has no penalty")
	f.save_game(false)
	f.interior_progress = {}
	f.load_game()
	assert(f.interior_progress.meal_request == "completed")
	print("PASS: blocked scenery, tap navigation, automatic entrance, onsen staff and baths, petting, tool icons, daylight, 16 festivals, voluntary requests and saved one-time rewards")
	quit()
