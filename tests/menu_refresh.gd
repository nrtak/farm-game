extends SceneTree
func _initialize(): call_deferred("run")
func capture(f,title:String):
 await create_timer(.25).timeout
 await RenderingServer.frame_post_draw
 var panel=f.dialogue_panel.get_child(0)
 assert(panel.get_global_rect().position.y>=0,title)
 root.get_texture().get_image().save_png(OS.get_cmdline_user_args()[0]+"/"+title+".png")
func run():
 var f=load("res://Main.tscn").instantiate();root.add_child(f);await process_frame
 f.set_physics_process(false);f.choose_character("boy");f.window_focused=true;root.size=Vector2i(960,540)
 f.produce.Turnip=5;f.produce.Strawberry=3;f.fish_basket.Sardine=2
 f.open_backpack();await capture(f,"menu-bag")
 f.close_dialogue();f.open_seed_picker();await capture(f,"menu-seeds")
 preload("res://VillageDepth.gd").gifts(f,"Seira");await capture(f,"menu-gifts")
 preload("res://VillageDepth.gd").confirm_gift(f,"Seira","Strawberry")
 assert(f.produce.Strawberry==3)
 preload("res://GameAudio.gd").menu(f);await capture(f,"menu-sound")
 f.make_modal("Seira",true);f.dialogue_text.text="A little strawberry always makes my day.";await capture(f,"menu-heart")
 f.close_dialogue();f.enter_shop("Onsen Resort",true);f.health=50;f.coins=100;var clock=f.clock_minutes
 f.open_onsen();f.take_onsen();assert(not f.dialogue_open and f.paused_by_player)
 assert(f.coins==60 and f.health==85 and f.clock_minutes==clock)
 await create_timer(1.5).timeout;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(OS.get_cmdline_user_args()[0]+"/onsen-soak.png")
 await create_timer(3.0).timeout
 assert(not f.paused_by_player and not f.dialogue_open)
 for service in ["Ranch","Veterinarian"]:
  f.enter_shop(service,true);await create_timer(.2).timeout;await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png(OS.get_cmdline_user_args()[0]+"/interior-"+service+".png")
  f.travel_to("town",f.service_door(service)+Vector2(0,100),false);await create_timer(.3).timeout;await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png(OS.get_cmdline_user_args()[0]+"/exterior-"+service+".png")
 f.queue_free();await create_timer(.2).timeout
 print("PASS: tile menus, gift confirmation, heart, sound controls and onsen charge/indoor clock/automatic return")
 quit()
