extends SceneTree
func _initialize():call_deferred("run")
func run():
	root.size=Vector2i(1311,603)
	var f=load("res://Main.tscn").instantiate();root.add_child(f);await process_frame
	f.set_physics_process(false);f.choose_character("boy");f.close_dialogue()
	f.travel_to("harbor",Vector2(800,650),false);await process_frame
	f.travel_to("town",f.town.arrival("farm"),false);await process_frame
	assert((f.perspective.BASIS*f.farmer.transform).y.normalized().dot(Vector2.DOWN)>.999,"Town return keeps farmer upright on screen")
	assert(f.farmer.scale.x<1,"Town return preserves character size")
	for area in f.regions:
		for title in preload("res://ApprovedMapLayout.gd").doors(area):
			assert(f.REGIONAL_ROOMS[title][1]==preload("res://ApprovedMapLayout.gd").doors(area)[title],"Artwork and automatic doorway agree")
	f.enter_shop("Inn",true);await process_frame
	var npc=f.shops["Inn"].residents[0]
	var phone_ui
	for child in f.get_children():
		if child.get_script()==preload("res://PhonePresentation.gd"):phone_ui=child
	f.player.position=npc.global_position+Vector2(0,40)
	f.camera.force_update_scroll();await process_frame;await process_frame
	assert(phone_ui.speech.visible,"Nearby resident has a talk indicator")
	var face_bounds:Rect2=npc.sprite.get_global_transform_with_canvas()*npc.sprite.get_rect()
	assert(phone_ui.speech.get_global_rect().end.y<=face_bounds.position.y,"Talk indicator clears the portrait sprite at indoor zoom")
	f.produce.Turnip=2;f.held_gift="Turnip"
	f.start_conversation(npc);await process_frame
	assert(f.produce.Turnip==1 and f.held_gift.is_empty(),"Talking gives exactly one held item")
	f.close_dialogue();f.held_gift="Turnip";f.start_conversation(npc);await process_frame
	assert(f.produce.Turnip==1,"Daily gift guard preserves the second item")
	f.close_dialogue();f.start_conversation(npc);await process_frame;await process_frame
	assert(f.dialogue_text.text=="\n\n".join(f.dialogue_lines),"Ordinary dialogue has every line in one panel")
	var panel=f.dialogue_panel.get_child(0)
	var viewport=f.get_viewport_rect().size
	assert(panel.size.x>viewport.x*.55 and panel.size.x<viewport.x-40,"Wide dialogue panel retains side margins")
	assert(panel.size.y<viewport.y*.48,"Dialogue leaves the scene visible")
	var conversation
	for child in panel.get_children():
		if child.get_script()==preload("res://CompactConversation.gd"):conversation=child
	assert(conversation.picture.get_global_rect().end.y<=panel.get_global_rect().position.y+5,"Portrait rises above the text panel")
	var close=panel.find_child("DialogueClose",true,false)
	assert(close.size.x>=44 and close.size.y>=44 and panel.get_global_rect().encloses(close.get_global_rect()),"Close control remains a visible touch target")
	f.close_dialogue();f.enter_shop("Tea Farmhouse",true);f.tea_delivery_stage=0
	f.start_conversation(f.shops["Tea Farmhouse"].residents[1]);assert(f.tea_delivery_stage==0,"Requests remain opt in")
	f.close_dialogue();assert(f.tea_delivery_stage==0,"Closing does not accept a request")
	print("PASS: upright town return, compact complete dialogue, held gift consumption and opt-in requests");quit()
