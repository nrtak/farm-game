extends SceneTree
func _initialize():call_deferred("run")
func run():
 var t=load("res://concepts/angled-street-v1/MarketWalk.tscn").instantiate();root.add_child(t);await process_frame;t.set_physics_process(false)
 for d in t.MARKET_DOORS:
  t.back_to_town(Vector2(780,620));t.lock_time=0
  assert(t.walkable(d[1]),"Door accessible: "+d[0])
  t.route=t.path_to(d[1]);assert(not t.route.is_empty())
  var previous=t.position_on_map
  for p in t.route:assert(t.segment_clear(previous,p));previous=p
  for i in range(3000):
   t._physics_process(1.0/60)
   if t.room!="":break
  assert(t.room==d[0],"Automatic entry after continuous walking "+d[0])
  t.lock_time=0;t.route=t.path_to(Vector2(550,750));assert(not t.route.is_empty())
  for i in range(2000):
   t._physics_process(1.0/60)
   if t.room=="":break
  assert(t.room=="" and t.walkable(t.position_on_map))
  t.check_transition();assert(t.room=="","No doorway re-entry")
  await process_frame
 for e in [t.MARKET_EXITS[0]]:
  t.back_to_town(Vector2(780,620));t.lock_time=0;t.route=t.path_to(e[1]);assert(not t.route.is_empty())
  for i in range(3000):
   t._physics_process(1.0/60)
   if t.room!="":break
  assert(t.room==e[0]+" gateway")
  t.position_on_map=Vector2(550,750);t.check_transition();assert(t.room=="" and t.walkable(t.position_on_map))
 t.back_to_town(Vector2(780,620))
 for p in [Vector2(400,320),Vector2(1250,400),Vector2(1080,500),Vector2(1190,850),Vector2(400,800),Vector2(1500,500)]:assert(not t.walkable(p),"Building, furnishing, lamp and garden block feet")
 var short=t.path_to(Vector2(950,660));assert(short.size()<=2,"Straight open paving should not produce a grid staircase")
 t.back_to_town(Vector2(780,620));t.lock_time=0;t.route=t.path_to(Vector2(1080,55))
 for i in range(3000):
  t._physics_process(1.0/60)
  if t.district=="civic":break
 assert(t.district=="civic" and t.room=="" and t.walkable(t.position_on_map))
 for d in t.CIVIC_DOORS:
  t.back_to_town(Vector2(780,755));t.lock_time=0;t.route=t.path_to(d[1]);assert(not t.route.is_empty(),d[0]+" route")
  for i in range(3000):
   t._physics_process(1.0/60)
   if t.room!="":break
  assert(t.room==d[0],d[0]+" entry")
  t.lock_time=0;t.route=t.path_to(Vector2(550,750))
  for i in range(2000):
   t._physics_process(1.0/60)
   if t.room=="":break
  assert(t.room=="" and t.district=="civic" and t.walkable(t.position_on_map))
  await process_frame
 t.back_to_town(Vector2(780,755));t.lock_time=0;t.route=t.path_to(Vector2(780,825))
 for i in range(2000):
  t._physics_process(1.0/60)
  if t.district=="market":break
 assert(t.district=="market" and t.walkable(t.position_on_map))
 t.queue_free();await create_timer(.4).timeout
 print("PASS: angled market smooth routes, 4 automatic interiors/returns, connected civic street round trip, painted obstacles blocked")
 quit()
