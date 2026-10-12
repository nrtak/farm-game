extends SceneTree
func _initialize(): call_deferred("run")
func run():
 var f=load("res://Main.tscn").instantiate();root.add_child(f);await process_frame
 f.set_physics_process(false);f.choose_character("boy");f.clock_minutes=800;f.coins=1000
 f.enter_shop("Barn",true);f.BarnLife.purchase(f,"Cow");assert(f.BarnLife.state(f).animals.is_empty())
 f.enter_shop("Ranch",true);f.BarnLife.open_manager(f);f.BarnLife.purchase(f,"Cow")
 assert(f.coins==500 and f.BarnLife.state(f).animals.size()==1)
 f.BarnLife.buy_feed(f);assert(f.coins==470 and f.BarnLife.state(f).feed==20)
 f.close_dialogue();f.player.position=f.SHOP_ORIGIN+Vector2(550,770);f.check_walk_exits()
 assert(f.location=="town")
 f.enter_shop("Veterinarian",true);preload("res://RanchServices.gd").vet_menu(f)
 preload("res://RanchServices.gd").checkup(f,0)
 preload("res://RanchServices.gd").checkup(f,0)
 assert(f.coins==440 and f.BarnLife.state(f).animals[0].affection==1)
 f.save_game(false)
 assert(f.read_saved_json(f.SAVE_FILE).interior_progress.barn.animals[0].vet_day==f.day)
 for name in ["Ranch","Veterinarian"]:
  f.enter_shop(name,true);await physics_frame
  f.polish.plan(f.SHOP_ORIGIN+Vector2(550,360));assert(not f.polish.path.is_empty())
 f.town.ambient_period=-1;f.town.tick_ambient(0,800,false,f.shops,f.regions)
 for npc in f.town.visitors:
  if npc.first_name=="Renji": assert(npc.get_parent()==f.shops.Ranch)
  if npc.first_name=="Midori": assert(npc.get_parent()==f.shops.Veterinarian)
 print("PASS: ranch-only purchases, feed, barn delivery, automatic exit, vet daily charge guard, persistence and staffing")
 f.queue_free();await process_frame;quit()
