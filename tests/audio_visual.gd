extends SceneTree
func _initialize(): call_deferred("run")
func capture(f,name:String):
	await create_timer(.3).timeout;await RenderingServer.frame_post_draw
	var p=f.dialogue_panel.get_child(0)
	assert(p.get_global_rect().position.y>=0 and p.get_global_rect().end.y<=root.size.y)
	root.get_texture().get_image().save_png(OS.get_cmdline_user_args()[0]+"/"+name+".png")
func run():
	var f=load("res://Main.tscn").instantiate();root.add_child(f);await process_frame
	f.set_physics_process(false);f.choose_character("boy");root.size=Vector2i(960,540)
	preload("res://GameAudio.gd").menu(f);await capture(f,"audio-settings")
	f.close_dialogue();f.open_guide();await capture(f,"audio-guide")
	f.queue_free();await create_timer(.2).timeout
	print("PASS: audio sliders and guide remain in 960x540 safe viewport")
	quit()
