extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var f=load("res://Main.tscn").instantiate()
	root.add_child(f)
	await process_frame
	f.set_physics_process(false)
	f.choose_character("boy")
	f.interior_progress.story={"intro":true}
	f.clock_minutes=800
	f.travel_to("farm",f.SHIPPING_BOX+Vector2(0,100),false)
	assert(f.is_walkable(f.player.position),"Shipping approach clear")
	f.produce.Turnip=2
	f.ore_basket.Iron=1
	assert(f.interaction_action()=="shipping","Box interaction takes priority")
	f.action_button.pressed.emit()
	assert(f.dialogue_open,"Actual touch action opens shipping")
	var buttons=[]
	collect_buttons(f.dialogue_panel,buttons)
	for button in buttons:
		if button.text=="Ship all carried goods": button.pressed.emit()
	assert(f.shipping_queue.Turnip==2 and f.ore_shipping.Iron==1 and f.produce.Turnip==0)
	f.close_dialogue()
	f.day=28
	f.set_location(true,f.ROOM_ORIGIN+f.interior.BED_APPROACH)
	f.offer_sleep()
	f.sleep_until_morning()
	assert(f.sleep_in_progress and f.day==28,"Sleep has a visible lead-in")
	f.sleep_sequence.set_process(false)
	f.sleep_until_morning()
	var sequence=f.sleep_sequence
	for stage in range(6): sequence.step(sequence.DURATIONS[stage])
	assert(not f.sleep_in_progress and f.day==29 and f.clock_minutes==f.WAKE_MINUTE)
	assert(f.farmer.visible and f.player.position==f.ROOM_ORIGIN+f.interior.BED_APPROACH)
	assert(f.coins>=590,"Queued produce pays on waking")
	f.save_game(false)
	assert(f.read_saved_json(f.SAVE_FILE) is Dictionary)
	assert(not FileAccess.file_exists(f.SAVE_FILE+".pending"),"Save replacement completes")
	# Old or incomplete feature dictionaries must not prevent the house reopening.
	f.interior_progress.barn=1
	f.interior_progress.resources={"water":3}
	assert(f.BarnLife.state(f).animals is Array)
	assert(f.resources.state().chopped is Dictionary)
	f.recovering_launch=true
	f.load_game()
	assert(not f.inside_house and f.location=="farm","Failed launch retries outside")
	assert(f.day==29,"Recovery keeps progress")
	print("PASS: touch shipping, payment, staged sleep/wake, season rollover, atomic saves, legacy feature state and safe house recovery")
	quit()
func collect_buttons(node, result) -> void:
	if node is Button: result.append(node)
	for child in node.get_children(): collect_buttons(child,result)
