extends SceneTree
func _initialize(): call_deferred("run")
func run():
	var f = load("res://Main.tscn").instantiate()
	root.add_child(f)
	await process_frame
	f.set_physics_process(false)
	f.choose_character("boy")
	f.interior_progress = {}
	f.travel_to("farm",f.farmhouse.DOOR_POSITION+Vector2(0,60),false)
	assert(f.Stewardship.check_visit(f))
	assert(f.interior_progress.story.intro)
	f.close_dialogue()
	f.harvests = 0
	f.day = 224
	f.interior_progress.story.review = true
	assert(f.Stewardship.check_visit(f))
	assert(f.interior_progress.story.vote_day == 252)
	f.close_dialogue()
	f.day = 252
	f.harvests = 30
	f.interior_progress.restoration = 2
	f.interior_progress.activities = ["a","b","c","d","e"]
	assert(f.Stewardship.yes_votes(f) == 27)
	assert(f.Stewardship.check_visit(f))
	assert(f.interior_progress.story.won)
	f.close_dialogue()
	f.coins = 2000
	f.interior_progress = {}
	f.clock_minutes = 800
	f.enter_shop("Carpentry")
	f.InteriorLife.order_upgrade(f,"land")
	assert(f.interior_progress.has("construction"))
	var size_before: int = f.plots.size()
	f.InteriorLife.complete_construction(f)
	assert(f.plots.size() == size_before)
	f.day += 1
	f.InteriorLife.complete_construction(f)
	assert(f.plots.size() == 115)
	f.interior.apply_upgrade(2)
	assert(f.interior.is_walkable(Vector2(1010,450)))
	print("PASS: mayor visits, extension, village vote, overnight land upgrade and expanded home")
	quit()
