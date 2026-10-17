extends SceneTree
func _initialize():call_deferred("run")
func run():
 var scene=ProjectSettings.get_setting_with_override("application/run/main_scene")
 assert(scene=="res://concepts/town-rebuild/TownRebuild.tscn","Review package must boot the rebuilt town")
 root.size=Vector2i(1152,648)
 var t=load(scene).instantiate();root.add_child(t);await process_frame
 t.position_on_map=Vector2(1720,910)
 await create_timer(.7).timeout;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(OS.get_cmdline_user_args()[0]+"/town-review-packaged.png")
 t.overview=true
 await create_timer(.5).timeout;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(OS.get_cmdline_user_args()[0]+"/town-review-packaged-overview.png")
 t.overview=false;t.position_on_map=Vector2(1300,650)
 await create_timer(.5).timeout;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(OS.get_cmdline_user_args()[0]+"/town-review-visibility.png")
 t.enter("Restaurant",Vector2(1445,1168))
 await create_timer(.5).timeout;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(OS.get_cmdline_user_args()[0]+"/town-review-restaurant.png")
 t.queue_free();await create_timer(.4).timeout
 print("PASS: packaged review boots correct scene and renders town artwork")
 quit()
