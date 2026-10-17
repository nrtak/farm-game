extends SceneTree
func _initialize():call_deferred("run")
func run():
 var town=load("res://concepts/town-playable/TownWalk.tscn").instantiate();root.add_child(town);await process_frame;town.set_physics_process(false)
 for d in town.DOORS:
  town.back_to_town(Vector2(815,620))
  assert(town.walkable(d[1]),"Door walkable: "+d[0])
  assert(town.path_to(d[1]).size()>0,"Route to "+d[0])
  town.lock_time=0;town.route=town.path_to(d[1])
  for step in range(2500):
   town._physics_process(1.0/60)
   if town.room!="":break
  assert(town.room==d[0],"Automatic entry "+d[0])
  assert(town.walkable(town.position_on_map),"Indoor spawn "+d[0])
  assert(town.path_to(Vector2(550,750)).size()>0,"Interior exit reachable "+d[0])
  town.lock_time=0;town.route=town.path_to(Vector2(550,750))
  for step in range(1000):
   town._physics_process(1.0/60)
   if town.room=="":break
  assert(town.room=="" and town.walkable(town.position_on_map),"Safe return "+d[0])
  town.check_transition();assert(town.room=="","No doorway bounce")
  await process_frame
 for e in town.EXITS:
  town.back_to_town(Vector2(815,620));assert(town.path_to(e[1]).size()>0,"Destination route "+e[0])
  town.position_on_map=e[1];town.check_transition();assert(town.room==e[0]+" gateway")
  town.position_on_map=Vector2(550,750);town.check_transition();assert(town.room=="" and town.walkable(town.position_on_map))
 town.back_to_town(Vector2(815,620))
 for p in [Vector2(50,500),Vector2(500,200),Vector2(710,300),Vector2(900,500)]:assert(not town.walkable(p),"Scenery must block feet")
 town.queue_free();await create_timer(.4).timeout
 print("PASS: new town simulated walking through all 13 doors, interior exits, 4 gateway returns, blocked scenery and navigation")
 quit()
