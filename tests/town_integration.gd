extends SceneTree
func _initialize():call_deferred("run")
func run():
 var f=load("res://Main.tscn").instantiate();root.add_child(f);await process_frame
 f.set_physics_process(false);f.choose_character("boy");f.interior_progress.story={"intro":true};f.close_dialogue();f.clock_minutes=800
 assert(f.town.BUILDINGS.size()==13 and f.shops.has("Restaurant"))
 f.travel_to("town",f.town.arrival("farm"),false);await physics_frame
 for b in f.town.BUILDINGS:
  assert(f.town.is_walkable(b.door),"Clear doorway: "+b.name)
  assert(f.town.is_walkable(b.back),"Clear return: "+b.name)
  f.polish.plan(f.TOWN_ORIGIN+b.door)
  assert(not f.polish.path.is_empty(),"Route to "+b.name)
  assert(f.polish.path[-1].distance_to(f.TOWN_ORIGIN+b.door)<28,"Reach doorway: "+b.name)
  f.polish.path.clear();f.player.position=f.TOWN_ORIGIN+b.door;f.door_retry=0
  f.check_walk_exits();assert(f.location=="shop" and f.shop_name==b.name,"Enter "+b.name)
  f.player.position=f.SHOP_ORIGIN+Vector2(550,760);f.check_walk_exits()
  assert(f.location=="town" and f.town.is_walkable(f.player.position-f.TOWN_ORIGIN),"Return "+b.name)
 for b in f.town.BUILDINGS:
  if b.facing!="W":continue
  f.travel_to("town",f.town.G.project(b.raw_door-Vector2(8,0)),false);f.door_retry=0;f.check_walk_exits()
  assert(f.location=="town","Passing the west-facing facade does not enter: "+b.name)
 for gate in f.town.G.EXITS:
  f.travel_to("town",f.town.G.project(gate[1]),false);f.check_walk_exits()
  assert(f.location=={"Farm":"farm","Highlands":"mountain","Harbor":"harbor","Shrine":"historic"}[gate[0]],"Actual map: "+gate[0])
 f.travel_to("mountain",Vector2(960,1090),false)
 f.check_walk_exits();assert(f.location=="tea","Mountain to tea trail")
 f.player.position=f.REGION_ORIGINS.tea+Vector2(60,665);f.check_walk_exits();assert(f.location=="mountain")
 f.enter_shop("Restaurant",true);f.health=40;f.coins=100;f.open_service("Restaurant");f.purchase_meal();assert(f.coins==70 and f.health==70);f.close_dialogue()
 f.travel_to("town",f.town.arrival("farm"),false);f.coins=321;f.save_game(false);f.coins=0;f.load_game();assert(f.coins==321 and f.location=="town")
 var file=FileAccess.open(f.SAVE_FILE,FileAccess.READ);var save=JSON.parse_string(file.get_as_text());file.close();save.version=20;save.x=7000;save.y=400
 file=FileAccess.open(f.SAVE_FILE,FileAccess.WRITE);file.store_string(JSON.stringify(save));file.close();f.load_game()
 assert(f.town.is_walkable(f.player.position-f.TOWN_ORIGIN) and f.coins==321,"Legacy save migration preserves progress")
 print("PASS: 13 live interiors, door paths, real regional gates, tea connection, restaurant purchase, save/reload and legacy town migration")
 f.queue_free();await process_frame;quit()
