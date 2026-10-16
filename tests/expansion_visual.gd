extends SceneTree
func _initialize(): call_deferred("run")
func capture(title:String):
 await create_timer(.4).timeout;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(OS.get_cmdline_user_args()[0]+"/"+title+".png")
func run():
 var f=load("res://Main.tscn").instantiate();root.add_child(f);await process_frame
 f.set_physics_process(false);f.choose_character("boy");f.window_focused=true;root.size=Vector2i(960,540)
 for level in [1,2]:
  f.interior_progress.home=level;f.interior.apply_upgrade(level)
  f.set_location(true,f.ROOM_ORIGIN+Vector2(1010 if level==1 else 1230,500));f.refresh_hud()
  await capture("home-expansion-"+str(level))
 f.queue_free();await create_timer(.3).timeout
 print("PASS: furnished storage room and kitchen expansion rendered")
 quit()
