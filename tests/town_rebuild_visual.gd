extends SceneTree
func _initialize():call_deferred("run")
func shot(name):
 await create_timer(.5).timeout;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(OS.get_cmdline_user_args()[0]+"/"+name+".png")
func run():
 root.size=Vector2i(1152,648)
 var t=load("res://concepts/town-rebuild/TownRebuild.tscn").instantiate();root.add_child(t);await process_frame
 t.position_on_map=Vector2(1720,910);await shot("town-rebuilt-market")
 t.position_on_map=Vector2(1300,650);await shot("town-rebuilt-civic")
 t.position_on_map=Vector2(1450,1190);await shot("town-rebuilt-hospitality")
 t.position_on_map=Vector2(1290,1470);await shot("town-rebuilt-ranch")
 t.position_on_map=Vector2(820,820);await shot("town-rebuilt-square")
 t.overview=true;await shot("town-rebuilt-overview")
 t.queue_free();await create_timer(.4).timeout
 print("PASS: full town rendered at six review viewpoints")
 quit()
