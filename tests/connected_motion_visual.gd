extends SceneTree
func _initialize():call_deferred("run")
func run():
 root.size=Vector2i(1000,560)
 var f=load("res://Main.tscn").instantiate();root.add_child(f);await process_frame
 f.set_physics_process(false);f.choose_character("boy");f.close_dialogue();f.clock_minutes=780
 var overlay=CanvasLayer.new();overlay.layer=100;root.add_child(overlay)
 var label=Label.new();label.position=Vector2(15,470);label.add_theme_font_size_override("font_size",18);label.add_theme_color_override("font_shadow_color",Color.BLACK);label.add_theme_constant_override("shadow_offset_x",2);label.add_theme_constant_override("shadow_offset_y",2);overlay.add_child(label)
 var cases=[["farm",Vector2(1485,220),Vector2.UP,"town"],["town",f.town.G.project(Vector2(1300,340)),Vector2.UP,"mountain"],["mountain",Vector2(1490,900),Vector2.RIGHT,"tea"],["town",f.town.G.project(Vector2(360,340)),Vector2.UP,"historic"],["harbor",Vector2(1480,585),Vector2.RIGHT,"town"]]
 var directory=OS.get_cmdline_user_args()[0];DirAccess.make_dir_recursive_absolute(directory)
 var frame=0
 for c in cases:
  f.travel_to(c[0],c[1],false);f.toast_time=0
  label.text="AUTOMATED GAMEPLAY CAPTURE | %s TO %s"%[c[0].to_upper(),c[3].to_upper()]
  var after_cross=0
  for i in range(100):
   await physics_frame
   var previous=f.player.position
   f.player.velocity=c[2]*180;f.player.move_and_slide();f.polish.constrain_motion(previous)
   f.update_walk(f.player.get_physics_process_delta_time(),true,c[2],f.player.position.distance_to(previous))
   f.check_walk_exits();f.perspective._process(0)
   if i%3==0:
    await RenderingServer.frame_post_draw
    root.get_texture().get_image().save_png(directory+"/%04d.png"%frame);frame+=1
   if f.location==c[3]:after_cross+=1
   if after_cross>20:break
  assert(f.location==c[3],"Motion capture crosses the intended boundary")
 print("PASS: ",frame," actual moving frames across five world connections");quit()
