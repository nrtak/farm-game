extends SceneTree
const Life=preload("res://EverydayLife.gd")
func _initialize(): call_deferred("run")
func capture(f,title:String):
 await create_timer(.3).timeout;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(OS.get_cmdline_user_args()[0]+"/"+title+".png")
func run():
 var f=load("res://Main.tscn").instantiate();root.add_child(f);await process_frame
 f.set_physics_process(false);f.choose_character("boy");f.window_focused=true;root.size=Vector2i(960,540)
 f.day=1;f.clock_minutes=800;f.coins=5000;f.interior_progress.story={"intro":true}
 f.enter_shop("Ranch",true)
 for species in f.BarnLife.SPECIES: f.BarnLife.purchase(f,species)
 f.close_dialogue();f.BarnLife.state(f).pasture=true
 f.travel_to("farm",Vector2(1450,1660),false);await capture(f,"everyday-pasture")
 Life.care_board(f);await capture(f,"everyday-care")
 f.close_dialogue();f.travel_to("town",Vector2(1200,950),false)
 Life.town_map(f);await capture(f,"everyday-map")
 f.close_dialogue();f.set_location(true,f.ROOM_ORIGIN+f.interior.BED_APPROACH)
 Life.state(f).home_color="739ab2";preload("res://VillageDepth.gd").state(f).keepsakes["Test ribbon"]=true;f.interior.queue_redraw()
 await capture(f,"everyday-home")
 Life.remember(f,"A day at home","Home decoration and seasonal keepsakes.")
 assert(FileAccess.file_exists(Life.state(f).memories["A day at home"].photo))
 Life.memory_card(f,"A day at home");await capture(f,"everyday-memory")
 Life.cooking_moment(f,"Vegetable supper","Health +25");await capture(f,"everyday-cooking")
 f.enter_shop("Ranch",true);Life.preview_animal(f,"Cow");await capture(f,"everyday-purchase")
 f.queue_free();await create_timer(.3).timeout
 print("PASS: everyday care, pasture, map and home rendered")
 quit()
