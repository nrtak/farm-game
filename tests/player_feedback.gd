extends SceneTree
func _initialize(): call_deferred("run")
func run():
	var f=load("res://Main.tscn").instantiate();root.add_child(f)
	await process_frame
	f.set_physics_process(false);f.choose_character("boy")
	f.interior_progress.story={"intro":true}
	assert(f.Cast.is_love_interest("Mika","boy") and not f.Cast.is_love_interest("Mika","girl"))
	assert(f.Cast.is_love_interest("Ken","girl") and not f.Cast.is_love_interest("Ken","boy"))
	assert(not f.Cast.is_love_interest("Akira","girl"))
	var column=f.make_modal("Mika",true)
	assert("Love interest" in column.get_child(0).text)
	f.character_choice="girl";column=f.make_modal("Mika",true)
	assert("Love interest" not in column.get_child(0).text)
	column=f.make_modal("Ken",true);assert("Love interest" in column.get_child(0).text)
	for text in ["Turnip seeds","Buy Cow","Buy 10 feed","Enjoy a meal","12-item backpack","Copper pick"]:
		var button=f.make_button(text,func(): pass)
		assert(button.has_meta("item_art"),text)
		button.free()
	f.close_dialogue();f.day=4;f.clock_minutes=900;f.coins=613
	f.shipping_queue.Turnip=2
	f.set_location(true,f.ROOM_ORIGIN+f.interior.BED_APPROACH)
	f.offer_sleep();f.sleep_until_morning();f.sleep_sequence.set_process(false)
	var before=f.read_saved_json(f.SAVE_FILE)
	assert(int(before.day)==4 and int(before.coins)==613,"Evening checkpoint")
	for i in range(4): f.sleep_sequence.step(f.sleep_sequence.DURATIONS[i])
	var after=f.read_saved_json(f.SAVE_FILE)
	assert(f.sleep_in_progress and int(after.day)==5,"Morning saved before animation ends")
	assert(int(after.coins)==613+2*f.CROPS.Turnip.sale and int(after.shipping_queue.Turnip)==0)
	assert(Vector2(after.x,after.y)==f.ROOM_ORIGIN+f.interior.BED_APPROACH,"Save uses safe bedside position")
	for i in range(4,6): f.sleep_sequence.step(f.sleep_sequence.DURATIONS[i])
	f.interior_progress.activities=["Blacksmith","Clinic"];f.save_game(false)
	f.load_game();assert(f.interior_progress.activities.size()==2,"Activity history survives load")
	assert(f.day==5 and f.coins==int(after.coins),"Reload doesn't pay twice")
	f.travel_to("town",Vector2(480,800),false)
	await physics_frame
	for x in range(300,481,10): assert(f.polish.clear_position(f.TOWN_ORIGIN+Vector2(x,800)),"Harbor approach clear")
	print("PASS: item artwork, farmer-specific hearts, interrupted-sleep checkpoints and harbor approach")
	quit()
