extends SceneTree
func _initialize():call_deferred("run")
func run():
 var f=load("res://Main.tscn").instantiate();root.add_child(f);await process_frame
 f.set_physics_process(false);f.choose_character("boy");f.close_dialogue()
 f.travel_to("mountain",Vector2(1480,900),false);await physics_frame
 var crossed=false
 for i in range(160):
  var before=f.player.position;f.player.velocity=Vector2.RIGHT*200
  f.player.move_and_slide();f.polish.constrain_motion(before)
  var foot=f.player.position;f.perspective._process(0);var camera=f.get_canvas_transform()
  f.check_walk_exits();f.perspective._process(0)
  assert(f.player.position==foot,"Seam never teleports the player")
  assert(f.get_canvas_transform().is_equal_approx(camera),"Seam never snaps the camera")
  if f.location=="tea":crossed=true;break
  await physics_frame
 assert(crossed,"Walk physically from Highlands to Tea Country")
 assert(f.regions.tea.visible and f.regions.mountain.visible,"Both landscapes remain visible")
 f.player.position+=Vector2(40,0)
 for i in range(100):
  var before=f.player.position;f.player.velocity=Vector2.LEFT*200
  f.player.move_and_slide();f.polish.constrain_motion(before);f.check_walk_exits()
  if f.location=="mountain":break
  await physics_frame
 assert(f.location=="mountain","Walk back without a transition scene")
 var old=f.read_saved_json(f.SAVE_FILE);old.version=23;old.location="tea";old.x=13250;old.y=710
 var file=FileAccess.open(f.SAVE_FILE,FileAccess.WRITE);file.store_string(JSON.stringify(old));file.close()
 f.load_game();assert(f.location=="tea" and f.player.position.distance_to(f.REGION_ORIGINS.tea+Vector2(1250,710))<1,"Old regional save migrates without losing local position")
 print("PASS: bidirectional physical seam, continuous camera and legacy coordinate migration")
 quit()
