extends SceneTree
func _initialize(): call_deferred("run")
func write_file(path:String,text:String):
	var file=FileAccess.open(path,FileAccess.WRITE);file.store_string(text);file.close()
func run():
	var f=load("res://Main.tscn").instantiate();root.add_child(f);await process_frame
	f.set_physics_process(false);f.choose_character("boy");f.interior_progress.story={"intro":true}
	f.day=1;f.coins=789;f.save_game(false)
	f.day=2;f.save_game(false)
	assert(int(f.read_saved_json(f.SAVE_FILE+".daily").coins)==789)
	write_file(f.SAVE_FILE,"{");write_file(f.SAVE_FILE+".bak","{")
	f.coins=0;f.load_game();assert(f.coins==789 and f.day==1,"Daily checkpoint recovers two damaged saves")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(f.SAVE_FILE))
	f.save_loaded=false;f.load_game();assert(f.save_loaded and f.coins==789,"Missing primary file can recover")
	f.day=1;f.clock_minutes=800;f.close_dialogue()
	preload("res://VillageDepth.gd").state(f).falls=3
	var start:=Time.get_ticks_msec()
	var baseline:=0
	for round_index in range(3):
		for room in f.shops:
			f.enter_shop(room,true);await process_frame
			f.open_backpack();await process_frame;f.close_dialogue();await process_frame
			assert(preload("res://InteriorArtwork.gd").textures.size()<=1,"Interior artwork cache stays bounded")
		for area in f.regions:
			f.travel_to(area,Vector2(800,950),false);await process_frame
		f.travel_to("farm",Vector2(1485,400),false);f.save_game(false);f.load_game();await process_frame
		var count:int=int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT))
		if round_index==0: baseline=count
		else: assert(count<=baseline+5,"Repeated area/menu changes do not accumulate nodes")
	print("PASS: daily and missing-file recovery; three complete interior/map/menu/save cycles, bounded artwork and node counts; elapsed ms ",Time.get_ticks_msec()-start)
	f.queue_free()
	await process_frame
	await process_frame
	quit()
