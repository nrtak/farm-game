extends SceneTree
func _initialize(): call_deferred("run")
func run():
 var f=load("res://Main.tscn").instantiate();root.add_child(f);await process_frame
 f.set_physics_process(false);f.choose_character("boy");root.size=Vector2i(960,540)
 f.set_location(true,f.ROOM_ORIGIN+f.interior.CHEST_APPROACH);f.produce.Turnip=5;f.stored_items.Turnip=17
 f.open_storage_item("Turnip");await create_timer(.4).timeout;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(OS.get_cmdline_user_args()[0]+"/storage-quantity.png")
 f.queue_free();await create_timer(.3).timeout
 print("PASS: storage quantity screen rendered")
 quit()
