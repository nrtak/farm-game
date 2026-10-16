extends SceneTree
const Journal=preload("res://ConstructionJournal.gd")
func _initialize(): call_deferred("run")
func capture(title:String):
 await create_timer(.3).timeout;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(OS.get_cmdline_user_args()[0]+"/"+title+".png")
func run():
 var f=load("res://Main.tscn").instantiate();root.add_child(f);await process_frame
 f.set_physics_process(false);f.choose_character("boy");root.size=Vector2i(960,540);f.window_focused=true
 f.coins=2000;f.harvests=20;f.resources.state().lumber=100;f.day=1;f.clock_minutes=540;f.enter_shop("Carpentry",true)
 f.InteriorLife.order_upgrade(f,"home");Journal.open(f);await capture("construction-progress")
 f.day=2;f.InteriorLife.complete_construction(f);Journal.review(f,0);await capture("construction-complete")
 preload("res://EverydayLife.gd").morning(f);await capture("construction-morning")
 f.queue_free();await create_timer(.3).timeout
 print("PASS: construction journal, completion map and morning notice rendered")
 quit()
