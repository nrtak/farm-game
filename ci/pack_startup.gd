extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
	assert(FileAccess.file_exists("res://data/map_habitats.json"),"CPU habitat data must be in the exported pack")
	var game=load("res://Main.tscn").instantiate()
	root.add_child(game)
	for frame in range(90): await process_frame
	assert(game.choosing_character,"Fresh exported launch reaches farmer selection")
	game.choose_character("boy")
	game.interior_progress.story={"intro":true}
	game.set_location(true,game.ROOM_ORIGIN+game.interior.BED_APPROACH)
	game.offer_sleep()
	game.sleep_until_morning()
	game.sleep_sequence.set_process(false)
	for duration in game.sleep_sequence.DURATIONS: game.sleep_sequence.step(duration)
	assert(game.day==2 and not game.sleep_in_progress)
	game.set_character("girl")
	game.save_game(false)
	game.queue_free()
	await process_frame
	var restored=load("res://Main.tscn").instantiate()
	root.add_child(restored)
	for frame in range(90): await process_frame
	assert(restored.day==2 and restored.character_choice=="girl")
	print("PASS: isolated exported startup, farmer selection, house sleep and saved relaunch")
	quit()
