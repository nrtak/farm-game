extends SceneTree
func _initialize():call_deferred("run")
func run():
 root.size=Vector2i(1311,603)
 var f=load("res://Main.tscn").instantiate();root.add_child(f);await process_frame
 f.set_physics_process(false);f.choose_character("boy");f.close_dialogue();f.clock_minutes=780
 f.travel_to("mountain",Vector2(1560,900),false)
 await create_timer(.8).timeout;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(OS.get_cmdline_user_args()[0]+"/seam-highlands-tea.png")
 print("PASS: seam screenshot captured");quit()
