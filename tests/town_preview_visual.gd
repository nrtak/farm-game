extends SceneTree
func _initialize():call_deferred("run")
func shot(name):
 await create_timer(.4).timeout;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(OS.get_cmdline_user_args()[0]+"/"+name+".png")
func run():
 root.size=Vector2i(960,540)
 var town=load("res://concepts/town-playable/TownWalk.tscn").instantiate();root.add_child(town);await process_frame
 town.position_on_map=Vector2(815,590);await shot("new-town-walk")
 town.position_on_map=Vector2(1180,510);await shot("new-town-west-doors")
 town.position_on_map=Vector2(815,280);await shot("new-town-highlands")
 town.enter("Restaurant",Vector2(905,776));town.camera.zoom=Vector2.ONE;town.position_on_map=Vector2(550,480);await shot("new-town-restaurant")
 town.queue_free();await create_timer(.4).timeout
 print("PASS: new town native walk, west doors, highlands and restaurant previews rendered")
 quit()
