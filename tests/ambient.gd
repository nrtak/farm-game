extends SceneTree
func _initialize(): call_deferred("run")
func run():
	var f = load("res://Main.tscn").instantiate()
	root.add_child(f)
	await process_frame
	f.set_physics_process(false)
	f.choose_character("boy")
	assert(f.town.visitors.size() == 5 and f.town.pets.size() == 5)
	f.town.tick_ambient(0.1, 480, false, f.shops)
	for step in range(1200):
		f.town.tick_ambient(0.1, 480, false, f.shops)
		for npc in f.town.visitors: assert(f.town.is_walkable(npc.position))
		for pet in f.town.pets: assert(f.town.is_walkable(pet.position))
	for npc in f.town.visitors:
		f.start_conversation(npc)
		assert(f.dialogue_lines.size() >= 2)
		f.close_dialogue()
	f.town.tick_ambient(0.1, 800, true, f.shops)
	for npc in f.town.visitors:
		assert(npc.get_parent() != f.town)
		assert(npc.get_parent().is_walkable(npc.position))
	f.town.tick_ambient(0.1, 480, false, f.shops)
	for npc in f.town.visitors: assert(npc.get_parent() == f.town)
	print("PASS: five visitors, five pets, safe paths, conversations, rain shelter and return")
	quit()
