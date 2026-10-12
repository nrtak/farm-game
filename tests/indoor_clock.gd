extends SceneTree
func _initialize(): call_deferred("run")
func run():
	var f=load("res://Main.tscn").instantiate();root.add_child(f)
	await process_frame
	f.set_physics_process(false);f.choose_character("boy");f.interior_progress.story={"intro":true}
	f.window_focused=true
	f.day=3;f.clock_minutes=1430;f.health=80
	f.set_location(true,f.ROOM_ORIGIN+f.interior.BED_APPROACH)
	f.advance_clock(120)
	assert(f.clock_minutes==1430 and f.day==3 and f.health==80,"House freezes time and late-night drain")
	for room in f.shops:
		f.enter_shop(room,true)
		f.advance_clock(120)
		assert(f.clock_minutes==1430 and f.day==3 and f.health==80,"Interior clock paused: "+room)
	f.travel_to("town",Vector2(1100,940),false)
	f.advance_clock(2)
	assert(f.clock_minutes==1432,"Time resumes outdoors")
	f.set_location(true,f.ROOM_ORIGIN+f.interior.BED_APPROACH)
	f.offer_sleep();f.sleep_until_morning();f.sleep_sequence.set_process(false)
	for stage in range(6): f.sleep_sequence.step(f.sleep_sequence.DURATIONS[stage])
	assert(f.day==4 and f.clock_minutes==f.WAKE_MINUTE,"Sleep still advances to morning")
	f.advance_clock(60)
	assert(f.clock_minutes==f.WAKE_MINUTE,"Time stays paused after waking indoors")
	print("PASS: all interiors freeze clock and midnight drain, outdoor time resumes, sleep advances normally")
	quit()
