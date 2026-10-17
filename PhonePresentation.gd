extends Node
var farm
var speech: Button
var clock: Label
var held: Button
var held_art
var displayed_item := ""
func setup(f):
	farm=f;process_priority=1100
	speech=f.make_button("…",f.interact);f.hud.add_child(speech);speech.size=Vector2(48,44)
	clock=Label.new();clock.add_theme_font_size_override("font_size",20);clock.add_theme_color_override("font_color",Color("493b2d"));clock.add_theme_stylebox_override("normal",f.parchment());f.hud.add_child(clock)
	held_art=preload("res://ItemMoment.gd").new();held_art.show_caption=false;held_art.scale=Vector2.ONE*.55;f.hud.add_child(held_art)
	held=f.make_button("",func(): f.held_gift="");f.hud.add_child(held)
func _process(_delta):
	if farm==null:return
	var f=farm
	f.date_label.text="%s %d · Year %d" % [f.SEASONS[int((f.day-1)/28)%4],(f.day-1)%28+1,int((f.day-1)/112)+1]
	f.date_label.size=Vector2(225,40)
	clock.text=("Ⅱ " if f.inside_house or f.location=="shop" else "")+f.clock_text()
	clock.position=Vector2((f.get_viewport_rect().size.x-135)/2,24);clock.size=Vector2(135,36)
	f.weather_icon.position=f.date_label.position+Vector2(230,8)
	f.quest_label.hide()
	var action:String=f.interaction_action()
	var npc
	if action=="talk":npc=f.town.nearest_npc(f.player.position-f.TOWN_ORIGIN)
	elif action=="talk_region":npc=f.regions[f.location].nearest_npc(f.player.position-f.REGION_ORIGINS[f.location])
	elif action=="talk_shop":npc=f.shops[f.shop_name].nearest_resident(f.player.position-f.SHOP_ORIGIN)
	speech.visible=is_instance_valid(npc) and not f.dialogue_open and not f.choosing_character
	if speech.visible:
		speech.position=f.get_viewport().canvas_transform*npc.global_position-Vector2(24,100)
		speech.text="…" if f.held_gift.is_empty() else "♥"
	if action in ["talk","talk_region","talk_shop"] or f.action_button.disabled:f.action_button.hide()
	var quiet=action in ["","talk","talk_region","talk_shop","service","regional_door","enter","leave","return_town","historic","north","west","east","town","road"]
	if quiet and f.toast_time<=0 and not f.paused_by_player and f.health>=25:f.message_label.hide()
	held.visible=not f.held_gift.is_empty() and not f.dialogue_open
	held.text="Holding: "+f.held_gift+"  ×";held.position=Vector2((f.get_viewport_rect().size.x-230)/2,70);held.size=Vector2(230,42)

	held_art.visible=held.visible
	if held_art.visible:
		if displayed_item!=f.held_gift:held_art.show_item(f.held_gift);displayed_item=f.held_gift
		held_art.position=f.get_viewport().canvas_transform*f.player.position+Vector2(20,-40)
