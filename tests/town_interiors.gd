extends SceneTree
func _initialize(): call_deferred("run")
func run():
	var f=load("res://Main.tscn").instantiate()
	root.add_child(f)
	await process_frame
	f.set_physics_process(false);f.choose_character("boy")
	f.interior_progress.story={"intro":true}
	var art=preload("res://InteriorArtwork.gd")
	var layouts=preload("res://TownInteriorLayout.gd")
	for kind in layouts.FURNITURE:
		assert(art.texture(kind).resource_path.ends_with("-v3.png"),"New artwork active: "+kind)
		f.enter_shop(kind,true)
		await physics_frame
		var room=f.shops[kind]
		for npc in room.residents: assert(room.is_walkable(npc.position),"Resident grounded: "+kind)
		for furnishing in room.solids: assert(not room.is_walkable(furnishing.get_center()),"Furniture solid: "+kind)
		for x in [410,550,730]:
			for y in range(350,691,20): assert(f.polish.clear_position(f.SHOP_ORIGIN+Vector2(x,y)),"Clear aisle: "+kind)
		assert(not room.is_walkable(Vector2(350,740)),"South wall blocks walking: "+kind)
		assert(room.is_walkable(room.ENTRY),"Door corridor remains open: "+kind)
		f.player.position=f.SHOP_ORIGIN+room.COUNTER
		assert(f.interaction_action()=="counter","Service reachable: "+kind)
	print("PASS: all ten revised town interiors use new artwork, solid furnishings, grounded residents and clear service aisles")
	quit()
