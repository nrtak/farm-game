extends SceneTree
const Journal=preload("res://ConstructionJournal.gd")
func _initialize(): call_deferred("run")
func run():
 var f=load("res://Main.tscn").instantiate();root.add_child(f);await process_frame
 f.set_physics_process(false);f.choose_character("boy");f.coins=2000;f.harvests=20;f.resources.state().lumber=100
 f.day=1;f.clock_minutes=540;f.enter_shop("Carpentry",true)
 f.InteriorLife.order_upgrade(f,"home");var coins=f.coins
 assert(Journal.stage(f)=="Materials prepared")
 f.clock_minutes=660;assert(Journal.stage(f)=="Work underway")
 f.InteriorLife.order_upgrade(f,"home");assert(f.coins==coins)
 Journal.open(f);assert(f.dialogue_text.text.contains("Work underway"))
 f.day=2;f.InteriorLife.complete_construction(f);f.InteriorLife.complete_construction(f)
 assert(f.interior_progress.building_history.size()==1 and Journal.notice(f).contains("storage"))
 Journal.review(f,0);assert(f.dialogue_text.text.contains("Double chest capacity"))
 f.save_game(false);f.load_game();assert(f.interior_progress.building_history.size()==1)
 f.day=3;assert(Journal.notice(f).is_empty())
 # An in-progress save from before project metadata still completes safely.
 f.interior_progress.construction={"kind":"home","day":2,"level":2}
 f.InteriorLife.complete_construction(f);assert(f.interior_progress.building_history.size()==2)
 Journal.review(f,1);assert(f.dialogue_text.text.contains("ready to use"))
 f.queue_free();await create_timer(.3).timeout
 print("PASS: construction stages, duplicate-order guard, single completion history, morning notice, save reload and legacy job compatibility")
 quit()
