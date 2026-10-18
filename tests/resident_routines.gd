extends SceneTree
func _initialize():call_deferred("run")
func run():
 var f=load("res://Main.tscn").instantiate();root.add_child(f);await process_frame
 f.set_physics_process(false);f.choose_character("boy");f.close_dialogue()
 var R=preload("res://ResidentRoutine.gd")
 assert(R.room_override("Aya",6,900,false)=="Archive")
 assert(R.room_override("Aya",6,900,true)=="@default")
 assert(R.room_override("Taro",6,900,true)=="Police Box")
 for day in [1,6,7,8,28,112]:
  f.day=day
  for minute in [360,540,720,840,900,1020,1140,1260,1380]:
   f.clock_minutes=minute;f.update_resident_presence()
   var counts={}
   var actors=[];actors.append_array(f.town.npcs)
   for area in f.regions.values():actors.append_array(area.npcs)
   for room in f.shops.values():actors.append_array(room.residents)
   for npc in actors:
    if npc.visible:
     counts[npc.first_name]=int(counts.get(npc.first_name,0))+1
     assert(npc.get_parent().is_walkable(npc.position),npc.first_name)
   assert(counts.size()==22,"Missing resident at "+str([day,minute,counts]))
   for name in counts:assert(counts[name]==1,"Duplicate "+name)
 # Actual routes, not only endpoint checks, stay clear of buildings and doorways.
 var moving=0
 for npc in f.town.npcs:
  npc.visible=true;npc.period=-1
 f.town.update_schedules(720)
 f.town.update_schedules(1080)
 for npc in f.town.npcs:
  if not npc.route.is_empty():moving+=1
  var previous=npc.position
  for point in npc.route:
   assert(f.town.route_edge_clear(previous,point));previous=point
 assert(moving>=8,"Residents need usable routes: "+str(moving))
 for step in range(500):
  for npc in f.town.npcs:
   npc.tick(.1);assert(f.town.is_npc_walkable(npc.position))
 # Social calls persist across saves and never accept a quest.
 f.day=9;f.clock_minutes=420;f.friendship.Mika=5
 assert(not f.is_rainy_day())
 assert(R.maybe_visit(f));assert(f.pending_request.is_empty());f.close_dialogue()
 assert(not R.maybe_visit(f));f.save_game(false);f.load_game();assert(not R.maybe_visit(f))
 print("PASS: weekday/weekend/weather presence, safe walking routes, evening coverage and saved social visit limits")
 f.queue_free();await process_frame;quit()
