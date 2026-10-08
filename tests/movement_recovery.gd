extends SceneTree
func _initialize(): call_deferred("run")
func run():
	var f=load("res://Main.tscn").instantiate()
	root.add_child(f)
	await process_frame
	f.set_physics_process(false); f.choose_character("boy")
	f.interior_progress.story={"intro":true}
	f.day=1; f.clock_minutes=720
	f.travel_to("farm",Vector2(1200,900),false)
	await physics_frame
	assert(f.polish.clear_position(f.player.position),"The player must not collide with their own probe")
	assert(not f.polish.recover_player(),"Standing on clear ground must not teleport")
	f.travel_to("town",f.town.BUILDINGS[0].rect.get_center(),false)
	await physics_frame
	assert(f.polish.recover_player(),"Recover an old save trapped in building geometry")
	assert(f.polish.clear_position(f.player.position),"Recovery lands on clear ground")
	var recovered: Vector2=f.player.position
	assert(not f.polish.recover_player() and f.player.position==recovered,"Recovery must not cause circling or repeated snapping")
	f.travel_to("town",Vector2(1200,1200),false)
	await physics_frame
	f.polish.plan(f.TOWN_ORIGIN+Vector2(1300,1150))
	assert(not f.polish.path.is_empty())
	for point in f.polish.path: assert(f.polish.clear_position(point),"Tap route leaves room for player body")
	assert(preload("res://WorldPolish.gd").daylight(720)==Color.WHITE)
	assert(preload("res://WorldPolish.gd").daylight(1050).b>0.9,"Evening tint stays subtle")
	print("PASS: no self collision, trapped-save recovery, stable recovery, body-width tap routes and neutral daylight")
	quit()
