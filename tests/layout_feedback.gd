extends SceneTree
func _initialize(): call_deferred("run")
func run():
	var f=load("res://Main.tscn").instantiate()
	root.add_child(f)
	await process_frame
	f.set_physics_process(false)
	f.choose_character("boy")
	assert(f.plots.size()==112,"Entire main field has planting beds")
	for y in range(700,1301,100):
		for x in range(1020,2521,100):
			var found:=false
			for plot in f.plots:
				if plot.position==Vector2(x,y): found=true
			assert(found,"Visible soil bed exists")
			assert(f.is_walkable(Vector2(x,y)),"Soil bed can be reached")
	assert(not f.interior.is_walkable(Vector2(650,210)),"House wall is blocked")
	assert(f.interior.is_walkable(f.interior.ENTRY),"House entry remains open")
	assert(is_equal_approx(f.town.SIZE.x/f.town.SIZE.y,1.5),"Town preserves artwork proportions")
	for npc in f.regions.tea.npcs:
		assert(f.regions.tea.is_walkable(npc.position),"Tea residents stand on ground")
	for name in preload("res://InteriorPlan.gd").ROOMS:
		var room=f.shops[name]
		assert(room.is_walkable(room.ENTRY),"Room exit is open")
		for npc in room.residents: assert(room.is_walkable(npc.position),"Interior resident stands on floor")
	assert(preload("res://Cast.gd").HOMES.Jiro.distance_to(preload("res://Cast.gd").HOMES.Yuta)>200,"Firefighters have separate posts")
	print("PASS: complete soil grid, house walls, town proportions, grounded tea residents and distinct interior floor plans")
	quit()
