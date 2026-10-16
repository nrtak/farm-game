extends SceneTree
const Story=preload("res://StoryArc.gd")
func _initialize(): call_deferred("run")
func capture(title:String):
 await create_timer(.4).timeout;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(OS.get_cmdline_user_args()[0]+"/"+title+".png")
func run():
 var f=load("res://Main.tscn").instantiate();root.add_child(f);await process_frame
 f.set_physics_process(false);f.choose_character("boy");f.window_focused=true;root.size=Vector2i(960,540)
 f.day=10;f.clock_minutes=420;f.interior_progress.story={"intro":true}
 f.travel_to("farm",f.farmhouse.DOOR_POSITION+Vector2(0,60),false)
 Story.maybe_visit(f);await capture("story-invitation")
 Story.accept(f,0);await capture("story-journal")
 f.enter_shop("Archive",true);Story.scene(f,0);await capture("story-letter")
 f.interior_progress.story.won=true;Story.ending(f);await capture("story-ending")
 f.queue_free();await create_timer(.3).timeout
 print("PASS: chapter invitation, journal, Archive scene and ending rendered")
 quit()
