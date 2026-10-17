extends SceneTree
func _initialize():call_deferred("run")
func shot(name):
 await create_timer(.4).timeout;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(OS.get_cmdline_user_args()[0]+"/"+name+".png")
func run():
 root.size=Vector2i(960,540)
 var town=load("res://concepts/angled-street-v1/MarketWalk.tscn").instantiate();root.add_child(town);await process_frame
 town.position_on_map=Vector2(780,620);await shot("angled-market-walk")
 town.camera.zoom=Vector2.ONE*.95;town.position_on_map=Vector2(1160,720);await shot("angled-market-close")
 town.enter("General Store",Vector2(400,514));await shot("angled-market-store")
 town.back_to_town(Vector2(780,620));town.show_routes=true;await shot("angled-market-routes")
 town.change_district("civic",Vector2(780,650));town.show_routes=false;await shot("angled-civic-walk")
 town.queue_free();await create_timer(.4).timeout
 print("PASS: angled market native street, close view, store and collision previews rendered")
 quit()
