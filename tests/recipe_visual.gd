extends SceneTree
const Book=preload("res://RecipeBook.gd")
func _initialize(): call_deferred("run")
func capture(title:String):
 await create_timer(.4).timeout;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(OS.get_cmdline_user_args()[0]+"/"+title+".png")
func run():
 var f=load("res://Main.tscn").instantiate();root.add_child(f);await process_frame
 f.set_physics_process(false);f.choose_character("boy");f.window_focused=true;root.size=Vector2i(960,540)
 f.interior_progress.home=2;f.interior.apply_upgrade(2);f.set_location(true,f.ROOM_ORIGIN+Vector2(1230,450));f.health=50
 f.produce.Potato=1;f.change_carried("Milk",1);f.change_carried("Egg",1)
 Book.book(f);await capture("recipe-book")
 Book.detail(f,"omelet");await capture("recipe-detail")
 Book.cook(f,"omelet");await capture("recipe-cooking")
 f.queue_free();await create_timer(.3).timeout
 print("PASS: illustrated recipes, ingredient preview and cooking animation rendered")
 quit()
