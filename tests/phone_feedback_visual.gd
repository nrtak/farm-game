extends SceneTree
func _initialize():call_deferred("run")
const PHOTO_LABELS={"town":"01 | TOWN - CIVIC STREET", "home":"02 | FARMHOUSE INTERIOR", "farm":"03 | FARM - FIELD UTILITIES", "tea":"04 | TEA COUNTRY", "tea-exit":"05 | TEA / HIGHLANDS CONNECTION", "pasture":"06 | FARM - PASTURE", "inn":"07 | INN INTERIOR", "harbor":"08 | HARBOR BEACH", "pier":"09 | FISHING PIER", "historic":"10 | SHRINE & MOONVEIL FALLS", "mountain":"11 | HIGHLANDS", "waterfall":"12 | WATERFALL CLOSE-UP", "conversation":"13 | CONVERSATION", "weekend-archive":"14 | WEEKEND - ARCHIVE", "school":"15 | VILLAGE SCHOOL", "playground":"16 | LIBRARY PLAYGROUND", "nature":"17 | NATURE FRIENDS", "world-map":"30 | EXPANDED WORLD MAP"}
var review_label:Label
func shot(name):
	if not is_instance_valid(review_label):
		var overlay=CanvasLayer.new();overlay.layer=100;root.add_child(overlay)
		var panel=PanelContainer.new();panel.position=Vector2(12,504);panel.mouse_filter=Control.MOUSE_FILTER_IGNORE;overlay.add_child(panel)
		var style=StyleBoxFlat.new();style.bg_color=Color(.08,.13,.12,.92);style.content_margin_left=12;style.content_margin_right=12;style.content_margin_top=5;style.content_margin_bottom=5;style.set_corner_radius_all(5);panel.add_theme_stylebox_override("panel",style)
		review_label=Label.new();review_label.add_theme_font_size_override("font_size",16);review_label.add_theme_color_override("font_color",Color.WHITE);panel.add_child(review_label)
	review_label.text="REVIEW PHOTO "+PHOTO_LABELS[name]
	await create_timer(.5).timeout;await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OS.get_cmdline_user_args()[0]+"/phone-"+name+".png")
func run():
	root.size=Vector2i(1311,603)
	var f=load("res://Main.tscn").instantiate();root.add_child(f);await process_frame
	f.set_physics_process(false);f.choose_character("boy");f.close_dialogue();f.clock_minutes=780;f.interior_progress.story={"intro":true};preload("res://VillageDepth.gd").state(f).falls=3
	for area in ["town","harbor","historic","mountain","tea","waterfall"]:
		var p=Vector2(800,750)
		if area=="town":p=f.town.G.project(Vector2(1660,960))
		elif area=="harbor":p=Vector2(850,500)
		elif area=="historic":p=Vector2(1100,365)
		elif area=="tea":p=Vector2(990,710)
		f.travel_to(area,p,false);f.update_walk(0,false,Vector2.DOWN);f.toast_time=0;f.refresh_hud();await shot(area)
	f.travel_to("harbor",Vector2(600,865),false);f.toast_time=0;f.refresh_hud();await shot("pier")
	f.travel_to("farm",f.SHIPPING_BOX+Vector2(0,90),false);f.toast_time=0;await shot("farm")
	f.travel_to("farm",preload("res://AnimalPasture.gd").GATE+Vector2(0,90),false);f.toast_time=0;await shot("pasture")
	f.enter_house();f.player.position=f.ROOM_ORIGIN+Vector2(500,470);f.toast_time=0;await shot("home")
	f.travel_to("tea",Vector2(270,675),false);f.toast_time=0;await shot("tea-exit")
	f.close_dialogue();f.enter_shop("Inn",true);f.toast_time=0;await shot("inn")
	f.start_conversation(f.shops["Inn"].residents[0]);await shot("conversation")
	f.close_dialogue();f.day=6;f.clock_minutes=900;f.enter_shop("Archive",true);f.toast_time=0;f.refresh_hud();await shot("weekend-archive")
	f.close_dialogue();f.day=2;f.clock_minutes=660;f.enter_shop("School",true);f.toast_time=0;await shot("school")
	f.close_dialogue();f.clock_minutes=900;f.travel_to("town",f.town.G.project(Vector2(900,450)),false);f.toast_time=0;await shot("playground")
	f.travel_to("historic",Vector2(1170,880),false);f.toast_time=0;await shot("nature")
	f.close_dialogue();f.open_map();await shot("world-map")
	print("PASS: phone proportion feedback screenshots captured");quit()
