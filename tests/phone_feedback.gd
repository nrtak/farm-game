extends SceneTree
func _initialize():call_deferred("run")
func run():
	root.size=Vector2i(1311,603)
	var f=load("res://Main.tscn").instantiate();root.add_child(f);await process_frame
	f.set_physics_process(false);f.choose_character("boy");f.close_dialogue()
	f.travel_to("harbor",Vector2(800,650),false);await process_frame
	f.travel_to("town",f.town.arrival("farm"),false);await process_frame
	assert(absf(f.farmer.rotation)<.001 and absf(f.farmer.skew)<.001,"Town return keeps farmer upright")
	assert(f.farmer.scale.x<1,"Town return preserves character size")
	for area in f.regions:
		for title in preload("res://ApprovedMapLayout.gd").doors(area):
			assert(f.REGIONAL_ROOMS[title][1]==preload("res://ApprovedMapLayout.gd").doors(area)[title],"Artwork and automatic doorway agree")
	f.enter_shop("Inn",true);await process_frame
	var npc=f.shops["Inn"].residents[0]
	f.produce.Turnip=2;f.held_gift="Turnip"
	f.start_conversation(npc);await process_frame
	assert(f.produce.Turnip==1 and f.held_gift.is_empty(),"Talking gives exactly one held item")
	f.close_dialogue();f.held_gift="Turnip";f.start_conversation(npc);await process_frame
	assert(f.produce.Turnip==1,"Daily gift guard preserves the second item")
	f.close_dialogue();f.start_conversation(npc);await process_frame;await process_frame
	assert(f.dialogue_text.text=="\n\n".join(f.dialogue_lines),"Ordinary dialogue has every line in one panel")
	assert(f.dialogue_panel.get_child(0).size.x<700,"Compact conversation width")
	f.close_dialogue();f.enter_shop("Tea Farmhouse",true);f.tea_delivery_stage=0
	f.start_conversation(f.shops["Tea Farmhouse"].residents[1]);assert(f.tea_delivery_stage==0,"Requests remain opt in")
	f.close_dialogue();assert(f.tea_delivery_stage==0,"Closing does not accept a request")
	print("PASS: upright town return, compact complete dialogue, held gift consumption and opt-in requests");quit()
