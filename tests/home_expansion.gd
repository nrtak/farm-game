extends SceneTree
func _initialize(): call_deferred("run")
func run():
 var f=load("res://Main.tscn").instantiate();root.add_child(f);await process_frame
 f.set_physics_process(false);f.choose_character("boy")
 var art=preload("res://HomeExpansion.gd")
 for level in [1,2]:
  f.interior_progress.home=level;f.interior.apply_upgrade(level)
  f.set_location(true,f.ROOM_ORIGIN+Vector2(850,580));await physics_frame;await physics_frame
  for x in range(850,level*220+900,10):
   assert(f.polish.clear_position(f.ROOM_ORIGIN+Vector2(x,580)),"Open expansion corridor")
  for rect in art.solids(level):
   assert(not f.interior.is_walkable(rect.get_center()))
   assert(not f.polish.clear_position(f.ROOM_ORIGIN+rect.get_center()),"Furniture has matching collision")
  for y in range(355,581,10): assert(f.polish.clear_position(f.ROOM_ORIGIN+Vector2(1010,y)))
  f.player.position=f.ROOM_ORIGIN+Vector2(1010,355);assert(f.interaction_action()=="storage")
  if level==2:
   for y in range(450,581,10): assert(f.polish.clear_position(f.ROOM_ORIGIN+Vector2(1230,y)))
   f.player.position=f.ROOM_ORIGIN+Vector2(1230,450);assert(f.interaction_action()=="cook")
 f.save_game(false);f.load_game();assert(f.interior.home_level==2)
 assert(not f.interior.is_walkable(art.STOVE.get_center()))
 f.queue_free();await create_timer(.3).timeout
 print("PASS: furnished expansion rooms, clear corridor and service approaches, matching furniture collision and upgraded-save reload")
 quit()
