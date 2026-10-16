extends SceneTree
func _initialize(): call_deferred("run")
func capture(title:String):
 await create_timer(.3).timeout;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(OS.get_cmdline_user_args()[0]+"/"+title+".png")
func run():
 var f=load("res://Main.tscn").instantiate();root.add_child(f);await process_frame
 f.set_physics_process(false);f.choose_character("boy");f.window_focused=true;root.size=Vector2i(960,540)
 f.set_location(true,f.ROOM_ORIGIN+preload("res://HomeWeather.gd").APPROACH);f.refresh_hud()
 await capture("weather-tv-home")
 preload("res://HomeWeather.gd").show_forecast(f);await capture("weather-broadcast")
 f.day=196;preload("res://StoryArc.gd").journal(f);await capture("story-progress")
 f.queue_free();await create_timer(.3).timeout
 print("PASS: home TV, illustrated forecast and chapter progress rendered")
 quit()
