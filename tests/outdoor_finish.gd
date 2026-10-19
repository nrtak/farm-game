extends SceneTree
func _initialize():call_deferred("run")
func run():
 var f=load("res://Main.tscn").instantiate();root.add_child(f);await process_frame
 f.set_physics_process(false);f.choose_character("boy");f.close_dialogue()
 for level in range(4):
  preload("res://FarmPlots.gd").fill(f,level)
  for plot in f.plots:assert(f.is_walkable(plot.position),"Every restored crop bed stays outside the pond and fences")
 f.travel_to("harbor",Vector2(430,555),false);await physics_frame
 for p in [Vector2(400,555),Vector2(300,555),Vector2(150,555)]:
  assert(f.regions.harbor.is_walkable(p),"Extended marina deck has a clear walking center")
  f.polish.plan(f.REGION_ORIGINS.harbor+p);assert(not f.polish.path.is_empty(),"Marina deck joins the land")
 for p in [Vector2(115,555),Vector2(150,490),Vector2(150,620)]:
  assert(not f.regions.harbor.is_walkable(p),"Marina edges remain water")
 print("PASS: all restoration beds clear and extended marina joins land without opening surrounding water")
 quit()
