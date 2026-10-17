extends SceneTree
func _initialize(): call_deferred("run")
func run():
 root.size=Vector2i(1152,648)
 var f=load("res://Main.tscn").instantiate();root.add_child(f);await process_frame
 f.set_physics_process(false);f.choose_character("boy");f.interior_progress.story={"intro":true};f.close_dialogue();f.clock_minutes=800
 f.camera.position_smoothing_enabled=false
 for area in ["harbor","historic","tea"]:
  var point=f.regions[area].safe_point(Vector2(1000,580) if area=="harbor" else Vector2(800,750))
  f.travel_to(area,point,false);f.update_resident_presence();f.town.tick_ambient(0,f.clock_minutes,false,f.shops,f.regions)
  f.update_walk(0,false,Vector2.DOWN);f.toast_time=0;f.refresh_hud();f.camera.force_update_scroll()
  await create_timer(.5).timeout;await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png(OS.get_cmdline_user_args()[0]+"/current-"+area+".png")
 print("PASS: current harbor, shrine and tea gameplay captured")
 quit()
