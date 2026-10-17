extends SceneTree
const G=preload("res://concepts/town-rebuild/TownGeometry.gd")
func _initialize():call_deferred("run")
func run():
 var t=load("res://concepts/town-rebuild/TownRebuild.tscn").instantiate();root.add_child(t);await process_frame;t.set_physics_process(false)
 for p in [Vector2(300,700),Vector2(1300,900),Vector2(2100,1200)]:assert(G.unproject(G.project(p)).distance_to(p)<.01)
 for b in t.town_data.buildings:
  t.back_to_town(Vector2(1300,910));t.lock_time=0
  assert(t.walkable(G.door(b)),b[0]+" door")
  t.route=t.path_to(G.door(b));assert(not t.route.is_empty(),b[0]+" route")
  var prev=t.position_on_map
  for p in t.route:assert(t.segment_clear(prev,p));prev=p
  for i in range(5000):
   t._physics_process(1.0/60)
   if t.room!="":break
  if t.room!=G.ALIASES.get(b[0],b[0]):print("FAIL DETAIL ",b[0]," actual ",t.room," pos ",t.position_on_map," route ",t.route)
  assert(t.room==G.ALIASES.get(b[0],b[0]),b[0]+" automatic entrance")
  t.lock_time=0;t.route=t.path_to(Vector2(550,750));assert(not t.route.is_empty(),b[0]+" room exit route")
  for i in range(3000):
   t._physics_process(1.0/60)
   if t.room=="":break
  assert(t.room=="" and t.walkable(t.position_on_map),b[0]+" safe return")
  t.check_transition();assert(t.room=="",b[0]+" bounce")
  await process_frame
 for e in G.EXITS:
  t.back_to_town(Vector2(1300,910));t.lock_time=0;t.route=t.path_to(e[1]);assert(not t.route.is_empty(),e[0]+" route")
  for i in range(5000):
   t._physics_process(1.0/60)
   if t.room!="":break
  assert(t.room==e[0]+" gateway",e[0]+" gateway")
  t.position_on_map=Vector2(550,750);t.check_transition();assert(t.room=="" and t.walkable(t.position_on_map))
 t.back_to_town(Vector2(1300,910))
 for b in t.town_data.buildings:assert(not t.walkable(Vector2(b[1]+20,b[2]+20)))
 assert(not t.walkable(Vector2(850,490)),"River blocks feet")
 assert(not t.walkable(Vector2(80,900)),"Ocean blocks feet")
 for p in t.trunks:assert(not t.walkable(p),"Tree trunks block feet")
 t.position_on_map=Vector2(1300,650);t.refresh()
 var faded=false
 for sprite in t.building_sprites:
  if sprite.modulate.a<.9:faded=true
 assert(faded,"Foreground buildings fade when they overlap the player")
 for a in t.town_data.buildings:
  t.position_on_map=G.back(a)
  for b in t.town_data.buildings:
   var route=t.path_to(G.door(b));assert(not route.is_empty(),"Every building is connected")
   var prev=t.position_on_map
   for point in route:assert(t.segment_clear(prev,point),"No clipped corners between buildings");prev=point
 t.queue_free();await create_timer(.4).timeout
 print("PASS: continuous angled town, all 13 interiors/returns, 4 signed exits, 169 inter-building routes, player visibility, collision and projection checks")
 quit()
