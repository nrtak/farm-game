extends SceneTree
func _initialize():call_deferred("run")
func run():
 var f=load("res://Main.tscn").instantiate();root.add_child(f);await process_frame
 f.set_physics_process(false);f.choose_character("boy");f.interior_progress.story={"intro":true};f.close_dialogue();f.clock_minutes=800
 f.travel_to("town",f.town.arrival("farm"),false);await physics_frame
 for b in f.town.BUILDINGS:
  f.polish.plan(f.TOWN_ORIGIN+b.door);f.door_retry=0
  var arrived=false
  for i in range(2400):
   var previous=f.player.position
   f.player.velocity=f.polish.direction(Vector2.ZERO)*200
   if not f.polish.path.is_empty():f.player.velocity=f.player.velocity.limit_length(f.player.position.distance_to(f.polish.path[0])/f.player.get_physics_process_delta_time())
   f.player.move_and_slide();f.polish.constrain_motion(previous)
   if not f.town.is_walkable(f.player.position-f.TOWN_ORIGIN):print("BAD ",f.location," prev ",previous-f.TOWN_ORIGIN," now ",f.player.position-f.TOWN_ORIGIN," goal ",b.name," path ",f.polish.path.size())
   assert(f.town.is_walkable(f.player.position-f.TOWN_ORIGIN),"Walk stays clear: "+b.name)
   f.check_walk_exits()
   if f.location=="shop":
    assert(f.shop_name==b.name,"No accidental neighboring doorway")
    arrived=true;break
  if not arrived:print("STUCK ",b.name," at ",f.player.position-f.TOWN_ORIGIN," goal ",b.door," path ",f.polish.path," delta ",f.player.get_physics_process_delta_time())
  assert(arrived,"Continuous walking reaches "+b.name)
  f.player.position=f.SHOP_ORIGIN+Vector2(550,760);f.check_walk_exits();await physics_frame
 f.day=4;f.clock_minutes=800;f.travel_to("town",f.town.design(Vector2(1200,910)),false)
 SeasonalFestivals.maybe_start(f);assert(f.festival_active,"Festival starts at relocated square")
 for record in f.festival_people:assert(f.town.is_walkable(record.npc.position),"Festival guest on dry land")
 var guest=f.festival_people[0].npc
 var friendship_before=int(f.friendship.get(guest.first_name,0))
 var guest_record=f.festival_people[0].duplicate()
 var coins_before=f.coins
 f.end_festival()
 assert(int(f.friendship.get(guest.first_name,0))==mini(100,friendship_before+2),"Festival awards friendship before clearing attendees")
 assert(f.coins==coins_before+50,"Seasonal festival pays once")
 assert(guest.visible==guest_record.visible and guest.z_index==guest_record.z_index,"Festival restores guest visibility and drawing order")
 f.end_festival();assert(f.coins==coins_before+50,"Repeated festival exit cannot repeat rewards")
 assert(not f.festival_active and is_equal_approx(f.camera.zoom.x,1.45))
 for name in ["mountain","harbor","historic"]:
  var exits={"mountain":Vector2(800,1201),"harbor":Vector2(1601,585),"historic":Vector2(1440,1201)}
  f.travel_to(name,exits[name],false);f.player.position=f.REGION_ORIGINS[name]+exits[name];f.check_walk_exits()
  assert(f.location=="town" and f.town.is_walkable(f.player.position-f.TOWN_ORIGIN),"Return from "+name)
 print("PASS: continuous physics walking to every town building, no accidental doors, festival at new square, neighboring map returns")
 f.queue_free();await process_frame;quit()
