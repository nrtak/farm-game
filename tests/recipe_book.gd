extends SceneTree
const Book=preload("res://RecipeBook.gd")
func _initialize(): call_deferred("run")
func run():
 var f=load("res://Main.tscn").instantiate();root.add_child(f);await process_frame
 f.set_physics_process(false);f.choose_character("boy");f.health=20;f.produce.Turnip=5
 Book.book(f);Book.detail(f,"supper");Book.cook(f,"supper");assert(f.produce.Turnip==5,"No cooking away from kitchen")
 f.interior_progress.home=2;f.set_location(true,f.ROOM_ORIGIN+Vector2(1230,450))
 Book.book(f);Book.detail(f,"supper");Book.book(f);assert(f.produce.Turnip==5,"Backing out consumes nothing")
 Book.detail(f,"supper");Book.cook(f,"supper");Book.cook(f,"supper")
 assert(f.health==45 and f.produce.Turnip==3,"One meal per selection")
 Book.detail(f,"omelet");Book.cook(f,"omelet");assert(f.health==45,"Shortage consumes nothing")
 f.change_carried("Milk",1);f.change_carried("Egg",1);f.produce.Potato=1
 Book.detail(f,"omelet");Book.cook(f,"omelet")
 assert(f.health==80 and f.carried_count("Milk")==0 and f.carried_count("Egg")==0 and f.produce.Potato==0)
 f.packed_tea=1;f.change_carried("Milk",1);Book.detail(f,"tea");Book.cook(f,"tea")
 assert(f.packed_tea==1 and f.health==80,"Festival recipe must be earned")
 preload("res://VillageDepth.gd").state(f).festival_recipe=true
 Book.detail(f,"tea");Book.cook(f,"tea");assert(f.health==100 and f.packed_tea==0)
 Book.detail(f,"supper");Book.cook(f,"supper");assert(f.produce.Turnip==3,"No waste at full health")
 assert(f.read_saved_json(f.SAVE_FILE).interior_progress.cooked_recipes.size()==3)
 f.queue_free();await create_timer(.3).timeout
 print("PASS: recipe previews, kitchen lock, cancellation, shortages, exact ingredients, single execution, festival unlock and saved cooking history")
 quit()
