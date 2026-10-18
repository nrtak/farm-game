extends SceneTree
func _initialize():call_deferred("run")
func run():
 var f=load("res://Main.tscn").instantiate();root.add_child(f);await process_frame
 f.set_physics_process(false);f.choose_character("boy");f.close_dialogue()
 f.friendship.erase("Nao");f.interior_progress.restoration=0
 f.save_game(false)
 var count=f.plots.size()
 f.friendship.Nao=80
 preload("res://FarmPlots.gd").fill(f,3)
 f.load_game()
 assert(int(f.friendship.get("Nao",0))==0,"Reload removes friendship absent from saved state")
 assert(f.plots.size()==count,"Reload removes restoration beds absent from saved state")
 f.interior_progress.home=1;f.day=30
 var automation=preload("res://FarmAutomation.gd")
 automation.state(f).tractor=true
 for p in f.plots:p.stage=0
 f.plots[0].stage=3;f.plots[0].crop="Turnip"
 f.stored_items.Turnip=999;automation.morning(f)
 assert(f.stored_items.Turnip==1000 and f.plots[0].stage==0,"Tractor uses upgraded storage capacity")
 f.day+=1;f.stored_items.Turnip=f.storage_limit();f.plots[0].stage=3
 automation.morning(f)
 assert(f.stored_items.Turnip==f.storage_limit() and f.plots[0].stage==3,"Full storage preserves ripe crops")
 print("PASS: reload replaces transient relationships/beds; tractor respects upgraded and full storage")
 quit()
