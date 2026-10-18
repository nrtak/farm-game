extends Node
var farm
var speech: Button
var clock: Label
var held: Button
var held_art
var displayed_item := ""
var minimap:Control
var character_panel:Panel
var avatar:TextureRect
var avatar_frame=AtlasTexture.new()
func setup(f):
	farm=f;process_priority=1100
	minimap=preload("res://WorldMiniMap.gd").new();minimap.farm=f;f.hud.add_child(minimap)
	character_panel=Panel.new();character_panel.mouse_filter=Control.MOUSE_FILTER_IGNORE;character_panel.add_theme_stylebox_override("panel",f.parchment());f.hud.add_child(character_panel);f.hud.move_child(character_panel,0)
	avatar=TextureRect.new();avatar.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;avatar.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;avatar.mouse_filter=Control.MOUSE_FILTER_IGNORE;character_panel.add_child(avatar)

	speech=f.make_button("…",f.interact);f.hud.add_child(speech);speech.size=Vector2(48,44)
	clock=Label.new();clock.add_theme_font_size_override("font_size",20);clock.add_theme_color_override("font_color",Color("493b2d"));clock.add_theme_stylebox_override("normal",f.parchment());f.hud.add_child(clock)
	held_art=preload("res://ItemMoment.gd").new();held_art.show_caption=false;held_art.scale=Vector2.ONE*.55;f.hud.add_child(held_art)
	held=f.make_button("",func(): f.held_gift="");f.hud.add_child(held)
func _process(_delta):
	if farm==null:return
	var f=farm
	f.date_label.text="%s %d · Year %d\n%s%s" % [f.SEASONS[int((f.day-1)/28)%4],(f.day-1)%28+1,int((f.day-1)/112)+1,"Ⅱ " if f.inside_house or f.location=="shop" else "",f.clock_text()]
	var font=f.date_label.get_theme_font("font")
	var text_width=font.get_string_size(f.date_label.text.split("\n")[0],HORIZONTAL_ALIGNMENT_LEFT,-1,f.date_label.get_theme_font_size("font_size")).x
	f.date_label.size=Vector2(text_width+28,64)
	clock.hide()
	f.weather_icon.position=f.date_label.position+Vector2(text_width+36,10)
	var bag=f.hud.get_node("CharacterButton")
	var panel_width=220.0
	character_panel.position=Vector2(f.get_viewport_rect().size.x-panel_width-24,100);character_panel.size=Vector2(panel_width,104)
	character_panel.visible=not f.dialogue_open and not f.choosing_character
	f.pocket_label.visible=character_panel.visible
	avatar.position=Vector2(8,5);avatar.size=Vector2(65,90);avatar.texture=f.farmer.texture
	# The farmer sprite already holds the current walk-frame region.
	if f.farmer.region_enabled:
		avatar_frame.atlas=f.farmer.texture;avatar_frame.region=f.farmer.region_rect;avatar.texture=avatar_frame
	bag.position=character_panel.position+Vector2(84,10);bag.size=Vector2(120,36)
	f.pocket_label.position=character_panel.position+Vector2(85,50);f.pocket_label.size=Vector2(120,25)
	f.health_bar.position=character_panel.position+Vector2(84,80);f.health_bar.size=Vector2(120,16)
	var map=f.hud.get_node("MapButton");map.hide()
	minimap.position=Vector2(f.date_label.position.x,132);minimap.size=Vector2(145,115);minimap.visible=character_panel.visible
	f.quest_label.hide()
	var action:String=f.interaction_action()
	var npc
	if action=="talk":npc=f.town.nearest_npc(f.player.position-f.TOWN_ORIGIN)
	elif action=="talk_region":npc=f.regions[f.location].nearest_npc(f.player.position-f.REGION_ORIGINS[f.location])
	elif action=="talk_shop":npc=f.shops[f.shop_name].nearest_resident(f.player.position-f.SHOP_ORIGIN)
	speech.visible=is_instance_valid(npc) and not f.dialogue_open and not f.choosing_character and not f.paused_by_player and not f.sleep_in_progress and f.window_focused
	if speech.visible:
		var bounds:Rect2=npc.sprite.get_global_transform_with_canvas()*npc.sprite.get_rect()
		speech.position=Vector2(bounds.get_center().x-24,bounds.position.y-68)
		speech.position.x=clampf(speech.position.x,8,f.get_viewport_rect().size.x-56)
		speech.position.y=maxf(82,speech.position.y)
		speech.text="…" if f.held_gift.is_empty() else "♥"
	if action in ["talk","talk_region","talk_shop"] or f.action_button.disabled:f.action_button.hide()
	var quiet=action in ["","talk","talk_region","talk_shop","service","regional_door","enter","leave","return_town","historic","north","west","east","town","road"]
	if quiet and f.toast_time<=0 and not f.paused_by_player and f.health>=25:f.message_label.hide()
	held.visible=not f.held_gift.is_empty() and not f.dialogue_open and not f.choosing_character and not f.paused_by_player and f.window_focused
	held.text="Holding: "+f.held_gift+"  ×";held.position=Vector2((f.get_viewport_rect().size.x-230)/2,70);held.size=Vector2(230,42)

	held_art.visible=held.visible
	if held_art.visible:
		if displayed_item!=f.held_gift:held_art.show_item(f.held_gift);displayed_item=f.held_gift
		held_art.position=f.get_viewport().canvas_transform*f.player.position+Vector2(20,-40)
