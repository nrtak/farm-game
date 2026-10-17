extends SceneTree
func _initialize():call_deferred("run")
func shot(name):
 await create_timer(.6).timeout;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(OS.get_cmdline_user_args()[0]+"/"+name+".png")
func run():
 root.size=Vector2i(1152,648)
 var f=load("res://Main.tscn").instantiate();root.add_child(f);await process_frame
 f.set_physics_process(false);f.choose_character("boy");f.interior_progress.story={"intro":true};f.close_dialogue();f.clock_minutes=800
 f.travel_to("town",f.town.G.project(Vector2(1720,910)),false);f.update_resident_presence();f.town.tick_ambient(0,f.clock_minutes,false,f.shops,f.regions);f.update_walk(0,false,Vector2.DOWN)
 f.town.update_label_visibility(f.player.position-f.TOWN_ORIGIN);await shot("playable-town-market")
 f.travel_to("town",f.town.G.project(Vector2(1300,650)),false);f.update_walk(0,false,Vector2.DOWN);f.town.update_label_visibility(f.player.position-f.TOWN_ORIGIN);await shot("playable-town-civic")
 f.travel_to("town",f.town.G.project(Vector2(1200,980)),false);f.camera.zoom=Vector2.ONE*.43;f.camera.offset=Vector2.ZERO;await shot("playable-town-perimeter")
 f.enter_shop("Restaurant",true);await shot("playable-town-restaurant")
 f.travel_to("mountain",Vector2(960,1090),false);await shot("playable-highlands-trail")
 f.queue_free();await process_frame;print("PASS: playable production town and restaurant rendered");quit()
