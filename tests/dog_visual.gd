extends SceneTree
const Dog=preload("res://FarmDog.gd")
func _initialize(): call_deferred("run")
func capture(title:String):
 await create_timer(.4).timeout;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(OS.get_cmdline_user_args()[0]+"/"+title+".png")
func run():
 var f=load("res://Main.tscn").instantiate();root.add_child(f);await process_frame
 f.set_physics_process(false);f.choose_character("boy");f.window_focused=true;root.size=Vector2i(960,540)
 f.day=7;f.clock_minutes=800;f.enter_shop("Ranch",true);Dog.adopt(f,"Sora")
 f.close_dialogue();f.day=1;f.travel_to("farm",Vector2(950,720),false)
 await capture("dog-puppy")
 Dog.menu(f);await capture("dog-care")
 f.close_dialogue();f.day=35;Dog.state(f).arrival=7;Dog.state(f).fed_days=14
 f.set_location(true,f.ROOM_ORIGIN+Vector2(670,595));await capture("dog-home")
 f.queue_free();await create_timer(.3).timeout
 print("PASS: puppy, care menu and adult dog at home rendered")
 quit()
