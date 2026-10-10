extends SceneTree
func _initialize(): call_deferred("run")
func capture(name:String):
	await create_timer(.3).timeout
	await RenderingServer.frame_post_draw
	var game=root.get_child(root.get_child_count()-1)
	if game.dialogue_open:
		var last=game.dialogue_text.get_parent().get_children()[-1]
		assert(last.get_global_rect().end.y<=root.get_visible_rect().size.y-8,"All controls visible: "+name)
	root.get_texture().get_image().save_png(OS.get_cmdline_user_args()[0]+"/"+name+".png")
func run():
	var f=load("res://Main.tscn").instantiate()
	root.add_child(f)
	await process_frame
	f.set_physics_process(false);f.choose_character("boy")
	f.interior_progress.story={"intro":true}
	root.size=Vector2i(1170,540)
	f.enter_shop("Tea Processing Shed",true)
	f.tea_leaves=3;f.day=1
	var tea=preload("res://TeaTasting.gd")
	tea.open(f);await capture("tasting-blends")
	tea.choose_brew(f,0);await capture("tasting-brew")
	tea.confirm(f,0,0);await capture("tasting-confirm")
	tea.serve(f,0,0);await capture("tasting-result")
	var column=f.dialogue_text.get_parent()
	assert(column.get_children()[-1].get_global_rect().end.y<=root.get_visible_rect().size.y)
	f.close_dialogue()
	for room in ["Harbor Homes","Mountain Lodge","Hiro Cabin"]:
		f.enter_shop(room,true)
		f.camera.position_smoothing_enabled=false
		f.camera.force_update_scroll()
		await capture("new-"+room.replace(" ","-"))
	print("PASS: tasting and distinct interiors rendered at phone dimensions")
	quit()
