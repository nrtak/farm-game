extends SceneTree
func _initialize():call_deferred("run")
func run():
 var f=load("res://Main.tscn").instantiate();root.add_child(f);await process_frame
 f.set_physics_process(false);f.choose_character("boy");f.close_dialogue()
 var friends=f.get_node("NatureFriends");var s=friends.state(f)
 friends.welcome_garden();assert(not s.get("garden",false))
 s.friendship["Elder Moss"]=19
 f.travel_to("historic",friends.HOMES[0],false);friends._process(0);f.player.position=friends.points[0]
 friends.interact();assert(s.keepsakes.size()==1)
 friends.welcome_garden();assert(s.garden)
 friends.interact();assert(s.keepsakes.size()==1,"Keepsake awarded once")
 f.close_dialogue();f.save_game(false);f.load_game();assert(friends.state(f).garden and friends.state(f).keepsakes.size()==1)
 var A=load("res://FarmAutomation.gd");f.day=29;A.state(f).tractor=true
 for plot in f.plots:plot.stage=3;plot.crop="Turnip"
 A.morning(f);var count=f.harvests;var inventory=f.stored_items.duplicate(true)
 f.travel_to("farm",Vector2(1400,1000),false)
 var vehicle=f.get_node("FarmEquipmentVisual");vehicle._process(1)
 assert(vehicle.route.size()>2 and vehicle.foot!=vehicle.PARK)
 var position=vehicle.foot;f.paused_by_player=true;vehicle._process(2);assert(vehicle.foot==position)
 f.paused_by_player=false;f.player.position=vehicle.foot;vehicle._process(2);assert(vehicle.foot==position,"Tractor yields to player")
 f.player.position=Vector2(1400,1000)
 for i in range(400):vehicle._process(1)
 assert(f.harvests==count and f.stored_items==inventory,"Animation cannot repeat settled harvest")
 print("PASS: garden unlock/keepsakes persist; tractor animates, pauses and never repeats harvest")
 quit()
