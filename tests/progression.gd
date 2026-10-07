extends SceneTree
func _initialize(): call_deferred("run")
func run():
	var f = load("res://Main.tscn").instantiate()
	root.add_child(f)
	await process_frame
	f.set_physics_process(false)
	f.choose_character("boy")
	f.interior_progress = {}
	f.resources.state().lumber = 100
	f.harvests = 30
	f.coins = 3000
	f.day = 20
	f.InteriorLife.add_plots(f,0)
	var before: int = f.coins
	f.InteriorLife.preview_upgrade(f,"land")
	f.close_dialogue()
	assert(f.coins == before and not f.interior_progress.has("construction"))
	f.clock_minutes = 800
	f.enter_shop("Carpentry")
	f.InteriorLife.order_upgrade(f,"land")
	assert(f.coins == before-150)
	f.InteriorLife.order_upgrade(f,"land")
	assert(f.coins == before-150)
	f.close_dialogue()
	f.save_game(false)
	f.interior_progress = {}
	f.load_game()
	assert(f.interior_progress.has("construction"))
	f.clock_minutes = 1439
	f.advance_clock(1)
	assert(f.plots.size() == 18 and not f.interior_progress.has("construction"))
	for level in [1,2]:
		f.InteriorLife.order_upgrade(f,"home")
		f.close_dialogue()
		f.day += 1
		f.InteriorLife.complete_construction(f)
		assert(f.interior.home_level == level)
	assert(f.storage_limit() == 2997)
	f.enter_house()
	f.player.position = f.ROOM_ORIGIN + Vector2(1230,450)
	assert(f.interaction_action() == "cook")
	f.produce = {"Turnip":1,"Potato":1,"Strawberry":0}
	f.health = 50
	f.InteriorLife.cook(f)
	assert(f.health == 75 and f.produce.Turnip == 0 and f.produce.Potato == 0)
	f.InteriorLife.cook(f)
	assert(f.health == 75)
	f.InteriorLife.open_room(f,"Clinic")
	f.InteriorLife.participate(f,"Clinic")
	var rested: float = f.health
	f.InteriorLife.participate(f,"Clinic")
	assert(f.health == rested)
	f.close_dialogue()
	f.interior_progress.activities = ["Clinic","Inn","Café"]
	before = f.coins
	f.InteriorLife.claim_request(f,"helper")
	f.close_dialogue()
	f.InteriorLife.claim_request(f,"helper")
	assert(f.coins == before+150)
	f.save_game(false)
	f.interior_progress = {}
	f.load_game()
	assert(f.interior.home_level == 2 and f.interior_progress.helper_claimed)
	f.close_dialogue()
	f.travel_to("town",Vector2(1200,950),false)
	f.begin_festival()
	f.scheduled_gathering = true
	f.interior_progress.erase("tea_challenge_years")
	before = f.coins
	f.InteriorLife.festival_game(f)
	f.InteriorLife.festival_answer(f,0,false)
	assert(f.coins == before)
	f.InteriorLife.festival_answer(f,2,true)
	assert(f.coins == before+50)
	f.InteriorLife.festival_game(f)
	f.InteriorLife.festival_answer(f,2,true)
	assert(f.coins == before+50)
	f.end_festival()
	print("PASS: cancelled orders, no duplicate charges, saved construction, midnight completion, both home upgrades, cooking, daily activities and one-time request rewards")
	quit()
