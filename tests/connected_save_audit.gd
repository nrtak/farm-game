extends SceneTree
func _initialize():call_deferred("run")
func run():
 var f=load("res://Main.tscn").instantiate();root.add_child(f);await process_frame
 f.set_physics_process(false);f.choose_character("boy");f.close_dialogue()
 var old_origins={"town":Vector2(6000,0),"mountain":Vector2(18000,0),"tea":Vector2(12000,0),"harbor":Vector2(15000,0),"historic":Vector2(21000,0)}
 for version in [23,24,25]:
  for area in old_origins:
   var local=f.town.G.project(Vector2(1300,910)) if area=="town" else f.regions[area].safe_point(Vector2(800,750))
   f.travel_to(area,local,false);f.friendship.Akira=37;f.save_game(false)
   var expected=f.player.position;var data=f.read_saved_json(f.SAVE_FILE)
   if version<25:
    var old=old_origins[area]+local
    if area=="town":old=old_origins.town+f.perspective.BASIS*local+f.town.G.ORIGIN
    elif version==24 and area=="mountain":old=Vector2(18000,-6000)+local
    elif version==24 and area=="tea":old=Vector2(19600,-5775)+local
    data.x=old.x;data.y=old.y
   data.version=version
   var file=FileAccess.open(f.SAVE_FILE,FileAccess.WRITE);file.store_string(JSON.stringify(data));file.close()
   f.load_game()
   assert(f.location==area and f.player.position.distance_to(expected)<1,"Version %d %s migration preserves local position"%[version,area])
   assert(f.friendship.Akira==37,"Migration preserves relationships")
   f.save_game(false);f.load_game()
   assert(f.player.position.distance_to(expected)<1,"Migration does not apply twice")
 f.travel_to("tea",Vector2(1280,700),false);f.perspective._process(0)
 assert(not f.regions.harbor.visible,"Distant residents and scenery are culled")
 f.day=4;f.clock_minutes=800;f.travel_to("town",f.town.design(Vector2(1200,910)),false)
 preload("res://SeasonalFestivals.gd").maybe_start(f);assert(f.festival_active)
 f.player.position=f.TOWN_ORIGIN+f.town.G.project(Vector2(1300,1586));f.check_walk_exits()
 assert(f.location=="farm" and not f.festival_active and f.festival_people.is_empty(),"Walking out restores festival participants")
 f.enter_shop("School",true);f.perspective._process(0)
 for layer in f.perspective.layers:
  if layer.visible:assert(layer.kind=="room" and layer.host==f.shops.School,"No outdoor scenery leaks into rooms")
 print("PASS: 15 legacy/current map saves retain position and friendship, migration is idempotent, distant scenery and interiors stay isolated")
 quit()
