extends SceneTree
const A=preload("res://TownActivities.gd")
func _initialize(): call_deferred("run")
func capture(f,name:String):
	await create_timer(.2).timeout
	await RenderingServer.frame_post_draw
	var panel=f.dialogue_panel.get_child(0)
	assert(panel.get_global_rect().position.y>=0,"Panel fits: "+name)
	assert(panel.get_global_rect().end.y<=root.get_visible_rect().size.y,"Panel bottom fits: "+name)
	root.get_texture().get_image().save_png(OS.get_cmdline_user_args()[0]+"/"+name+".png")
func run():
	var f=load("res://Main.tscn").instantiate();root.add_child(f)
	await process_frame
	f.set_physics_process(false);f.choose_character("boy")
	f.interior_progress.story={"intro":true};f.day=1;f.clock_minutes=780
	root.size=Vector2i(1170,540)
	f.enter_shop("Café",true);A.cafe(f);await capture(f,"activities-cafe")
	A.accept_delivery(f)
	f.enter_shop("Inn",true);A.traveler(f);await capture(f,"activities-traveler")
	A.accept_traveler(f)
	f.enter_shop("Archive",true);A.library(f,1);await capture(f,"activities-library")
	f.enter_shop("Town Hall",true);A.hall(f);await capture(f,"activities-hall")
	f.open_calendar();await capture(f,"activities-calendar")
	f.tea_delivery_stage=1;f.lost_item_stage=2;f.fishing_quest_stage=2
	preload("res://VolunteerRequests.gd").journal(f);await capture(f,"activities-journal")
	f.enter_shop("Blacksmith",true);f.open_service("Blacksmith");await capture(f,"activities-forge-menu")
	f.coins=500;f.ore_basket.Copper=4;f.purchase_upgrade();await capture(f,"activities-forge")
	print("PASS: activity menus and long journal fit phone viewport")
	quit()
