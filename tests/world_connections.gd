extends SceneTree
func _initialize():call_deferred("run")
func run():
 var f=load("res://Main.tscn").instantiate();root.add_child(f);await process_frame
 f.set_physics_process(false);f.choose_character("boy");f.close_dialogue()
 var cases=[
 ["farm",Vector2(1485,210),Vector2.UP,"town"],
 ["town",f.town.G.project(Vector2(1300,1530)),Vector2.DOWN,"farm"],
 ["town",f.town.G.project(Vector2(1300,330)),Vector2.UP,"mountain"],
 ["mountain",Vector2(800,1130),Vector2.DOWN,"town"],
 ["town",f.town.G.project(Vector2(360,330)),Vector2.UP,"historic"],
 ["historic",Vector2(1440,1130),Vector2.DOWN,"town"],
 ["town",f.town.G.project(Vector2(220,910)),Vector2.LEFT,"harbor"],
 ["harbor",Vector2(1530,585),Vector2.RIGHT,"town"]]
 for c in cases:
  f.travel_to(c[0],c[1],false);await physics_frame
  for i in range(120):
   var previous=f.player.position;f.player.velocity=c[2]*240
   f.player.move_and_slide();f.polish.constrain_motion(previous)
   f.perspective._process(0);var camera=f.get_canvas_transform();var point=f.player.position
   f.check_walk_exits();f.perspective._process(0)
   assert(point.is_equal_approx(f.player.position),"No teleport: "+c[0]+" to "+c[3])
   assert(camera.is_equal_approx(f.get_canvas_transform()),"No camera snap: "+c[0]+" to "+c[3])
   if f.location==c[3]:break
   await physics_frame
  assert(f.location==c[3],"Blocked connection: "+c[0]+" to "+c[3]+" at "+str(f.player.position))
  print("PASS: physical crossing ",c[0]," -> ",c[3])
 print("PASS: all town and farm connections preserve movement and camera")
 for c in [["harbor",Vector2(1490,585),"town",f.town.G.project(Vector2(230,910))],["town",f.town.G.project(Vector2(1300,345)),"mountain",Vector2(800,1100)]]:
  f.travel_to(c[0],c[1],false);await physics_frame
  var target=(f.TOWN_ORIGIN if c[2]=="town" else f.REGION_ORIGINS[c[2]])+c[3]
  f.polish.plan(target)
  assert(not f.polish.path.is_empty(),"Cross-map tap creates a route")
  for i in range(400):
   var direction=f.polish.direction(Vector2.ZERO)
   var previous=f.player.position
   f.player.velocity=direction*300
   if not f.polish.path.is_empty():f.player.velocity=f.player.velocity.limit_length(f.player.position.distance_to(f.polish.path[0])/f.player.get_physics_process_delta_time())
   f.player.move_and_slide();f.polish.constrain_motion(previous);f.check_walk_exits()
   if f.location==c[2] and f.player.position.distance_to(target)<2:break
   await physics_frame
  assert(f.location==c[2] and f.player.position.distance_to(target)<2,"Tap reaches destination across boundary "+str([c[0],f.location,f.player.position,target,f.polish.path,f.polish.crossing_target]))
 print("PASS: cross-map tap routes finish in the neighboring area")
 quit()
