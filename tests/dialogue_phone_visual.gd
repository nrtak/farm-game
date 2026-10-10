extends SceneTree
func _initialize(): call_deferred("run")
func run():
	var f=load("res://Main.tscn").instantiate()
	root.add_child(f)
	await process_frame
	f.set_physics_process(false)
	f.choose_character("boy")
	f.interior_progress.story={"intro":true}
	root.size=Vector2i(1170,540)
	f.enter_shop("Tea Farmhouse",true)
	f.tea_delivery_stage=0
	f.start_conversation(f.shops["Tea Farmhouse"].residents[1])
	await create_timer(.5).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OS.get_cmdline_user_args()[0]+"/dialogue-phone-review.png")
	var buttons=f.dialogue_text.get_parent().get_children()
	assert(buttons[-1].get_global_rect().end.y<=root.get_visible_rect().size.y)
	print("PASS: phone-sized request dialogue fits viewport")
	quit()
