extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var farm = load("res://Main.tscn").instantiate()
	root.add_child(farm)
	await process_frame
	farm.set_physics_process(false)
	farm.choose_character("boy")
	farm.festival_years = []
	farm.day = 14
	farm.clock_minutes = 599
	farm.enter_house()
	assert(farm.interior.is_walkable(farm.interior.CALENDAR_APPROACH))
	farm.player.position = farm.ROOM_ORIGIN + farm.interior.CALENDAR_APPROACH
	assert(farm.interaction_action() == "calendar")
	farm.interact()
	assert(farm.dialogue_open and farm.dialogue_text.text.contains("Spring 14"))
	farm.close_dialogue()
	farm.travel_to("town", Vector2(1200, 1000), false)
	farm.check_scheduled_gathering()
	assert(not farm.festival_active)
	farm.clock_minutes = 600
	farm.check_scheduled_gathering()
	assert(farm.festival_active and farm.scheduled_gathering and farm.town.festival_decorated)
	assert(farm.festival_people.size() == 22)
	while farm.dialogue_open: farm.advance_dialogue()
	var money: int = farm.coins
	farm.end_festival()
	assert(farm.coins == money + 100 and farm.festival_years.has(1))
	farm.check_scheduled_gathering()
	assert(not farm.festival_active)
	farm.begin_festival()
	farm.end_festival()
	assert(farm.coins == money + 100, "Preview grants no reward")
	farm.save_game(false)
	farm.festival_years = []
	farm.load_game()
	assert(farm.festival_years.has(1))
	farm.day = 126
	farm.clock_minutes = 1080
	assert(not farm.gathering_available())
	farm.clock_minutes = 600
	assert(farm.gathering_available())
	farm.day = 15
	farm.refresh_hud()
	assert(not farm.town.festival_decorated)
	print("PASS: farmhouse calendar, festival date/time, automatic plaza start, all cast, dialogue, reward once/year, preview no reward, saved attendance, decoration reset")
	quit()
