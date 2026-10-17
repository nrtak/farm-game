extends Node2D
var farm
var pulse:=0.0
var check_time:=0.0
var worker
var cue:=""
var cue_point:=Vector2.ZERO
var held:=-1.0
static func settings(f) -> Dictionary:
	if not f.interior_progress.get("comfort") is Dictionary: f.interior_progress.comfort={}
	return f.interior_progress.comfort
func setup(f) -> void:
	farm=f;z_index=220
	f.action_button.button_down.connect(func(): held=0.0)
	f.action_button.button_up.connect(func(): held=-1.0)
func _process(delta:float) -> void:
	if farm==null or not farm.window_focused: return
	if held>=0:
		held+=delta
		if held>.75:
			held=0.0;preload("res://EverydayLife.gd").repeat_work(farm)
	check_time-=delta
	if check_time>0: return
	check_time=0.2;pulse+=0.2
	var working:bool=farm.location=="farm" and not farm.inside_house and farm.interior_progress.has("construction") and not farm.festival_active
	if working and not is_instance_valid(worker):
		worker=preload("res://Npc.gd").new();add_child(worker)
		worker.setup("Kenta",preload("res://CharacterArt.gd").walk("Kenta"));worker.paused=true
	if is_instance_valid(worker):
		worker.visible=working
		if working:
			var preferred:Vector2=project_point(farm,farm.interior_progress.construction.kind)+Vector2(95,25)
			if not farm.polish.clear_position(preferred):
				for offset in [Vector2(-190,0),Vector2(0,90),Vector2(-95,90),Vector2(0,160)]:
					if farm.polish.clear_position(preferred+offset): preferred+=offset;break
			worker.position=preferred
			worker.show_frame(1,int(pulse*2)%2)

	cue=""
	if not farm.dialogue_open and not farm.choosing_character and not farm.paused_by_player:
		var action:String=farm.interaction_action()
		if action in ["talk","talk_shop","talk_region"]: action="" # Tappable resident marker is drawn in the HUD.
		if action in ["counter","service"]: action="" # The service button already identifies shopping.
		if action=="pet_animal": action="pet"
		if action in ["regional_door","enter","barn_enter","greenhouse_enter","leave"]: action="shipping"
		if action in ["talk","shop","shipping","pet","water","plant","harvest","well"]:
			cue={"talk":"…","shop":"¥","shipping":"↓","pet":"♡","water":"~","plant":"+","harvest":"✓","well":"~"}[action]
			cue_point=farm.player.position+Vector2(55,-100)
		# The screen action button is the single interaction prompt in town.
		if farm.location=="town": cue=""
		if farm.location=="waterfall" and int(preload("res://VillageDepth.gd").state(farm).get("falls",0))==0 and (farm.player.position-farm.REGION_ORIGINS.waterfall).y<770:
			preload("res://VillageDepth.gd").waterfall(farm)
	queue_redraw()
func _draw() -> void:
	if farm==null: return
	if not farm.festival_active and not farm.inside_house:
		for event in SeasonalFestivals.EVENTS:
			var until:int=posmod(int(event.day)-(farm.day-1)%112-1,112)
			if until<1 or until>2 or farm.location!=event.area: continue
			var origin:Vector2=farm.TOWN_ORIGIN if event.area=="town" else farm.REGION_ORIGINS[event.area]
			var center:Vector2=origin+(farm.town.design(SeasonalFestivals.center(event.area)) if event.area=="town" else SeasonalFestivals.center(event.area))
			for side in [-1,1]:
				var point:Vector2=center+Vector2(side*235,-100)
				draw_line(point,point+Vector2(0,-100),Color("765b3b"),5)
				draw_colored_polygon(PackedVector2Array([point+Vector2(0,-100),point+Vector2(46,-90),point+Vector2(0,-65)]),Color("d4b875"))
	if farm.festival_active and not farm.current_festival.is_empty():
		var key:String=VolunteerRequests.festival_key(farm.day,farm.current_festival)
		if farm.interior_progress.get("volunteering",{}).get(key,{}).get("status","")=="completed":
			var origin:Vector2=farm.TOWN_ORIGIN if farm.location=="town" else farm.REGION_ORIGINS.get(farm.location,Vector2.ZERO)
			var p:Vector2=origin+farm.festival_center+Vector2(0,-135)
			draw_line(p-Vector2(90,0),p+Vector2(90,0),Color("765b3b"),3)
			for i in range(7): draw_circle(p+Vector2(-75+i*25,10),8,Color("e6c374"))
	if farm.location=="mountain" and not farm.has_meta("angled_world"):
		var trail:Vector2=farm.REGION_ORIGINS.mountain+Vector2(1320,760)
		draw_line(trail+Vector2(-10,-55),trail+Vector2(-10,-105),Color("775333"),9)
		draw_style_box(farm.parchment(),Rect2(trail+Vector2(-145,-160),Vector2(285,55)))
		draw_string(ThemeDB.fallback_font,trail+Vector2(-130,-125),"Moonveil Falls →",HORIZONTAL_ALIGNMENT_LEFT,-1,24,Color("493b2d"))
	if cue!="":
		draw_circle(cue_point,22,Color("f4e3bb"));draw_arc(cue_point,22,0,TAU,24,Color("735536"),2)
		draw_string(ThemeDB.fallback_font,cue_point+Vector2(-9,8),cue,HORIZONTAL_ALIGNMENT_LEFT,-1,27,Color("493b2d"))
	if farm.location=="farm" and not farm.inside_house and farm.interior_progress.has("construction"):
		var kind:String=farm.interior_progress.construction.kind
		var p:Vector2=project_point(farm,kind)
		for x in [-70,70]: draw_line(p+Vector2(x,-45),p+Vector2(x,35),Color("977245"),8)
		draw_line(p+Vector2(-85,-15),p+Vector2(85,-15),Color("d7b967"),12)
		draw_string(ThemeDB.fallback_font,p+Vector2(-65,-45),"Work in progress",HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("493b2d"))
static func project_point(f,kind:String) -> Vector2:
	match kind:
		"home","second_story": return f.farmhouse.DOOR_POSITION+Vector2(150,55)
		"barn": return f.BARN_DOOR+Vector2(130,30)
		"greenhouse": return preload("res://FarmBuildings.gd").GREENHOUSE_DOOR+Vector2(100,25)
		_: return Vector2(1300,1330)
static func scroll_text(f,c) -> void:
	var label=f.dialogue_text;c.remove_child(label)
	var scroll:=ScrollContainer.new();scroll.custom_minimum_size.y=90;scroll.size_flags_vertical=Control.SIZE_EXPAND_FILL;scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED
	c.add_child(scroll);c.move_child(scroll,1);scroll.add_child(label);label.size_flags_horizontal=Control.SIZE_EXPAND_FILL;label.size_flags_vertical=Control.SIZE_SHRINK_BEGIN
static func open_settings(f) -> void:
	f.close_dialogue();var c=f.make_modal("Settings")
	f.dialogue_panel.get_child(0).offset_top=-minf(445,f.get_viewport_rect().size.y-32)
	f.dialogue_text.size_flags_vertical=Control.SIZE_SHRINK_BEGIN
	var release:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://data/build_info.json"))
	f.dialogue_text.text="%s · v%s · Build %s\nThese preferences are saved with your farm. Tap the ground or use the joystick to move." % [release.get("edition","Tea Blossom Hills"),release.get("version","0.2.0"),release.get("build","100")]
	var scroll:=ScrollContainer.new();scroll.custom_minimum_size.y=120;scroll.size_flags_vertical=Control.SIZE_EXPAND_FILL;c.add_child(scroll)
	var list:=VBoxContainer.new();list.size_flags_horizontal=Control.SIZE_EXPAND_FILL;scroll.add_child(list)
	var s:=settings(f)
	for option in ["large_stick","right_stick","gentle_stick","large_text"]:
		var names={"large_stick":"Larger joystick","right_stick":"Joystick on right","gentle_stick":"Gentler joystick sensitivity","large_text":"Larger dialogue text"}
		list.add_child(f.make_button(names[option]+(" · On" if s.get(option,false) else " · Off"),toggle.bind(f,option)))
	list.add_child(f.make_button("Farm journal",preload("res://EverydayLife.gd").journal.bind(f)))
	list.add_child(f.make_button("Move me to clear ground",preload("res://EverydayLife.gd").unstuck.bind(f)))
	list.add_child(f.make_button("Music & sound",preload("res://GameAudio.gd").menu.bind(f)))
	c.add_child(f.make_button("Guide",func(): f.close_dialogue();f.open_guide()))
	c.add_child(f.make_button("Back",f.close_dialogue))
static func toggle(f,key:String) -> void:
	var s:=settings(f);s[key]=not s.get(key,false);f.layout_ui();f.save_game(false);open_settings(f)
static func layout(f,margin:Vector2,right:float,bottom:float) -> void:
	var s:=settings(f)
	f.joystick.stick_radius=70.0 if s.get("large_stick",false) else 58.0
	f.joystick.sensitivity=0.75 if s.get("gentle_stick",false) else 1.0
	f.joystick.queue_redraw()
	if s.get("right_stick",false):
		f.joystick.position.x=f.get_viewport_rect().size.x-right-168
		f.action_button.position.x=margin.x
		f.hud.get_node("MapButton").position.x=margin.x
		f.hud.get_node("CharacterButton").position.x=margin.x+88
static func pin_menu(f) -> void:
	f.close_dialogue();var c=f.make_modal("Pin a request")
	f.dialogue_text.text="Choose one reminder for the small on-screen tracker."
	var options:Array=["None"]
	if f.tea_delivery_stage==1: options.append("Tea parcel → Naomi")
	if f.lost_item_stage in [1,2]: options.append("Wallet → Taro / Library")
	if f.fishing_quest_stage in [1,2]: options.append("Fish → Masao")
	if int(preload("res://VillageDepth.gd").state(f).get("falls",0))==2: options.append("Tea packet → Moonveil Falls")
	for item in options: c.add_child(f.make_button(item,set_pin.bind(f,item)))
static func set_pin(f,item:String) -> void:
	settings(f).pin="" if item=="None" else item;f.save_game(false);f.close_dialogue();f.refresh_hud()
static func rename_animal(f,index:int) -> void:
	f.close_dialogue();var c=f.make_modal("Name your animal")
	var animals:Array=f.BarnLife.state(f).animals
	if index<0 or index>=animals.size(): f.close_dialogue();return
	f.dialogue_text.text="Choose a name, up to 16 characters."
	var input:=LineEdit.new();input.max_length=16;input.text=animals[index].get("name",animals[index].species);input.custom_minimum_size.y=48;c.add_child(input)
	c.add_child(f.make_button("Save name",func():
		var value:String=input.text.strip_edges()
		if value.is_empty(): return
		animals[index].name=value;f.save_game(false);f.BarnLife.open_animal(f,index);f.shops.Barn.queue_redraw()))
	c.add_child(f.make_button("Cancel",f.close_dialogue))
static func preview(f,c,kind:String) -> void:
	var label:=Label.new();label.text="Farm placement: "+{"home":"beside your house","second_story":"above your house","barn":"inside the existing barn","greenhouse":"southwest field","land":"cultivation field","irrigation":"crop beds"}.get(kind,"farm")
	label.add_theme_color_override("font_color",Color("493b2d"));c.add_child(label)
	var map:=Control.new();map.custom_minimum_size=Vector2(300,85);c.add_child(map)
	map.draw.connect(func():
		map.draw_rect(Rect2(0,0,300,80),Color("a6b97b"))
		for rect in [Rect2(20,12,55,30),Rect2(210,12,60,28),Rect2(80,43,120,32)]: map.draw_rect(rect,Color("96774d"))
		var p:Vector2={"home":Vector2(48,28),"second_story":Vector2(48,28),"barn":Vector2(238,25),"greenhouse":Vector2(40,63)}.get(kind,Vector2(135,58))
		map.draw_arc(p,22,0,TAU,28,Color("fff3a3"),4))
