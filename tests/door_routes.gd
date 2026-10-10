extends SceneTree
func _initialize(): call_deferred("run")
func run():
	var f=load("res://Main.tscn").instantiate()
	root.add_child(f)
	await process_frame
	f.set_physics_process(false);f.choose_character("boy")
	f.interior_progress.story={"intro":true}
	f.travel_to("town",Vector2(1200,950),false)
	await physics_frame
	for building in f.town.BUILDINGS:
		var target:Vector2=f.TOWN_ORIGIN+building.door
		f.polish.plan(target)
		assert(not f.polish.path.is_empty(),"Town route to "+building.name)
		assert(f.polish.path[-1].distance_to(target)<45,"Door proximity: "+building.name)
		var previous:Vector2=f.player.position
		for point in f.polish.path:
			for sample in range(9):
				assert(f.polish.clear_position(previous.lerp(point,sample/8.0)),"Route segment body clearance: "+building.name)
			previous=point
	for room in preload("res://InteriorArtwork.gd").ROOMS:
		f.enter_shop(room,true)
		await physics_frame
		f.polish.plan(f.SHOP_ORIGIN+Vector2(550,360))
		assert(not f.polish.path.is_empty(),"Interior reception reachable: "+room)
		for point in f.polish.path: assert(f.polish.clear_position(point),"Interior body clearance: "+room)
		f.player.position=f.SHOP_ORIGIN+Vector2(550,360)
		f.polish.plan(f.SHOP_ORIGIN+Vector2(550,730))
		assert(not f.polish.path.is_empty(),"Interior exit reachable: "+room)
	print("PASS: every town doorway and detailed interior counter/exit has a body-clear walking route")
	quit()
