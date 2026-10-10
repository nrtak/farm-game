extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
	assert(FileAccess.file_exists("res://data/map_habitats.json"),"CPU habitat data must be in the exported pack")
	var game=load("res://Main.tscn").instantiate()
	root.add_child(game)
	for frame in range(90): await process_frame
	assert(game.choosing_character,"Fresh exported launch reaches farmer selection")
	game.choose_character("boy")
	assert(game.regions.mountain.background.resource_path.ends_with("map-mountain-open-v2.png"))
	assert(game.regions.harbor.background.resource_path.ends_with("map-harbor-open-v2.png"))
	assert(game.regions.tea.background.resource_path.ends_with("map-tea-open-v2.png"))
	for name in preload("res://CharacterArt.gd").PORTRAITS:
		assert(preload("res://CharacterArt.gd").portrait(name)!=null,"Portrait exported: "+name)
	for room in preload("res://InteriorArtwork.gd").ROOMS:
		assert(preload("res://InteriorArtwork.gd").texture(room)!=null,"Interior exported: "+room)
	for room in preload("res://TownInteriorLayout.gd").FURNITURE:
		assert(preload("res://InteriorArtwork.gd").texture(room).resource_path.ends_with("-v3.png"),"Latest town interior exported: "+room)
	game.interior_progress.story={"intro":true}
	game.enter_shop("Tea Processing Shed",true)
	game.tea_leaves=1
	preload("res://TeaTasting.gd").open(game)
	preload("res://TeaTasting.gd").serve(game,0,0)
	assert(game.tea_leaves==0 and game.interior_progress.tasting_day==1)
	game.close_dialogue()
	game.clock_minutes=780
	game.enter_shop("Café",true)
	preload("res://TownActivities.gd").accept_delivery(game)
	assert(game.interior_progress.cafe_delivery.status=="accepted")
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
	assert(restored.interior_progress.cafe_delivery.status=="accepted","New request survives exported save/relaunch")
	assert(restored.day==2 and restored.character_choice=="girl")
	assert(restored.interior_progress.tasting_day==1 and restored.interior_progress.tasting_notes.Mika=="Fresh green")
	print("PASS: isolated exported startup, farmer selection, house sleep and saved relaunch")
	quit()
