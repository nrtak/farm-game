extends SceneTree
func _initialize():call_deferred("run")
func run():
 var f=load("res://Main.tscn").instantiate();root.add_child(f);await process_frame
 f.set_physics_process(false);f.choose_character("boy");f.close_dialogue()
 for c in [["mountain",Vector2(1540,900),Vector2(1610,900),"tea"],["tea",Vector2(60,675),Vector2(-10,675),"mountain"],["harbor",Vector2(1540,585),Vector2(1610,585),"town"],["historic",Vector2(1440,1140),Vector2(1440,1210),"town"]]:
  f.travel_to(c[0],c[1],false);await physics_frame
  var target:Vector2=f.REGION_ORIGINS[c[0]]+c[2]
  f.polish.plan(target)
  assert(not f.polish.path.is_empty(),"Tap just beyond boundary must create route: "+c[0])
  for i in range(180):
   var direction=f.polish.direction(Vector2.ZERO)
   var previous=f.player.position
   f.player.velocity=direction*300
   if not f.polish.path.is_empty():f.player.velocity=f.player.velocity.limit_length(f.player.position.distance_to(f.polish.path[0])/f.player.get_physics_process_delta_time())
   f.player.move_and_slide();f.polish.constrain_motion(previous);f.check_walk_exits()
   if f.location==c[3] and f.player.position.distance_to(target)<2:break
   await physics_frame
  assert(f.location==c[3] and f.player.position.distance_to(target)<2,"Near-seam tap reaches exact target: "+c[0])
 print("PASS: near-boundary tap targets remain reachable in both directions")
 quit()
