extends SceneTree
const T=preload("res://TeaTasting.gd")
func _initialize(): call_deferred("run")
func run():
	var f=load("res://Main.tscn").instantiate()
	root.add_child(f)
	await process_frame
	f.set_physics_process(false)
	f.choose_character("boy")
	f.interior_progress.story={"intro":true}
	f.day=1
	f.enter_shop("Tea Processing Shed")
	f.tea_leaves=2
	var money:int=f.coins
	var friendship:int=f.friendship.Mika
	T.open(f);T.choose_brew(f,0);T.confirm(f,0,0)
	f.close_dialogue()
	assert(f.tea_leaves==2 and f.coins==money,"Cancellation spends nothing")
	T.open(f);T.choose_brew(f,0);T.confirm(f,0,0);T.serve(f,0,0)
	assert(f.tea_leaves==1 and f.coins==money+25 and f.friendship.Mika==friendship+3)
	T.serve(f,0,0)
	assert(f.tea_leaves==1 and f.coins==money+25,"Repeated button cannot pay twice")
	f.close_dialogue();f.save_game(false);f.load_game()
	T.serve(f,0,0)
	assert(f.tea_leaves==1 and f.coins==money+25,"Save reload preserves daily limit")
	assert(f.interior_progress.tasting_notes.Mika=="Fresh green","Favorite discovery persists")
	f.day=2
	T.open(f);T.serve(f,0,2)
	assert(f.tea_leaves==0 and f.coins==money+35,"Imperfect brew still earns base reward")
	f.close_dialogue();f.day=3;T.open(f);T.serve(f,0,0)
	assert(f.coins==money+35 and int(f.interior_progress.tasting_day)==2,"No free tasting without leaves")
	f.tea_leaves=1;f.close_dialogue();f.travel_to("town",Vector2(1200,950),false)
	T.serve(f,0,0)
	assert(f.tea_leaves==1,"Cannot serve outside tea shed")
	print("PASS: tea tasting cancellation, recipes, friendship, daily reward, save persistence, shortages and location guard")
	quit()
