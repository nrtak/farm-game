extends SceneTree
func _initialize():call_deferred("run")
func run():
 var f=load("res://Main.tscn").instantiate();root.add_child(f);await process_frame
 f.set_physics_process(false);f.choose_character("boy");f.close_dialogue()
 f.plots[0].stage=2;f.plots[0].crop="Potato";f.save_game(false)
 var saved=f.read_saved_json(f.SAVE_FILE)
 saved.plots.resize(1)
 var file=FileAccess.open(f.SAVE_FILE,FileAccess.WRITE);file.store_string(JSON.stringify(saved));file.close()
 f.plots[0].stage=3;f.plots[50].stage=3;f.plots[50].crop="Strawberry"
 f.load_game()
 assert(f.plots[0].stage==2 and f.plots[0].crop=="Potato","Saved crops restore by stable index")
 assert(f.plots[50].stage==0 and f.plots[50].growth==0,"Beds absent from a legacy save cannot inherit unsaved crops")
 f.interior_progress.home=2;f.enter_house();f.open_storage()
 assert(f.dialogue_text.text.contains(str(f.storage_limit())),"Storage displays upgraded capacity")
 f.queue_free();await create_timer(.2).timeout
 print("PASS: legacy crop reload replaces unsaved beds and storage UI matches upgraded capacity")
 quit()
