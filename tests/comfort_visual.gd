extends SceneTree
func _initialize(): call_deferred("run")
func capture(f,name:String):
	await create_timer(.3).timeout
	await RenderingServer.frame_post_draw
	var box=f.dialogue_panel.get_child(0)
	assert(box.get_global_rect().end.y<=root.get_visible_rect().size.y)
	assert(box.size.y<280,"Conversation leaves the world visible")
	assert(f.dialogue_panel.color.a==0,"World stays undimmed")
	root.get_texture().get_image().save_png(OS.get_cmdline_user_args()[0]+"/"+name+".png")
func run():
	var f=load("res://Main.tscn").instantiate();root.add_child(f)
	await process_frame
	f.set_physics_process(false);f.choose_character("boy")
	f.interior_progress.story={"intro":true};root.size=Vector2i(1170,540)
	f.enter_shop("Tea Farmhouse",true);f.tea_delivery_stage=0
	f.start_conversation(f.shops["Tea Farmhouse"].residents[1]);await capture(f,"compact-request")
	assert("♥" in f.dialogue_text.get_parent().get_child(0).text)
	f.accept_story_request();assert(f.tea_delivery_stage==1)
	f.start_conversation(f.shops["Tea Farmhouse"].residents[1]);await capture(f,"compact-conversation")
	f.close_dialogue()
	var column=f.make_modal("Akira",true)
	f.dialogue_text.text="The Tea Festival is tomorrow. We will gather at the plaza to share the season's tea. Would you volunteer to help prepare the tasting? You are also welcome to come along as a guest."
	column.add_child(f.make_button("Accept volunteer job",f.close_dialogue))
	column.add_child(f.make_button("Attend as a guest",f.close_dialogue))
	column.add_child(f.make_button("Thanks for stopping by",f.close_dialogue))
	await capture(f,"compact-visitor")
	root.size=Vector2i(960,540)
	await capture(f,"compact-visitor-small")
	f.close_dialogue()
	root.size=Vector2i(1170,540)
	for area in ["town","harbor","mountain","waterfall","tea"]:
		f.travel_to(area,Vector2(800,580) if area=="waterfall" else Vector2(800,800),false)
		f.camera.position_smoothing_enabled=false;f.camera.force_update_scroll()
		await create_timer(.3).timeout
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(OS.get_cmdline_user_args()[0]+"/comfort-"+area+".png")
	print("PASS: compact ordinary, request and visitor dialogue, heart and acceptance behavior")
	quit()
