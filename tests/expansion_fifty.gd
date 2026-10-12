extends SceneTree
const Depth=preload("res://VillageDepth.gd")
const Comfort=preload("res://PlayerComfort.gd")
func _initialize(): call_deferred("run")
func run():
	var f=load("res://Main.tscn").instantiate();root.add_child(f);await process_frame
	f.set_physics_process(false);f.choose_character("boy");f.interior_progress.story={"intro":true};f.window_focused=true
	f.coins=2000;f.clock_minutes=800
	Comfort.settings(f).large_stick=true;Comfort.settings(f).right_stick=true;Comfort.settings(f).gentle_stick=true;f.layout_ui()
	assert(f.joystick.stick_radius==70 and f.joystick.sensitivity==0.75 and f.joystick.position.x>f.action_button.position.x)
	f.produce.Strawberry=3;f.friendship.Seira=0
	Depth.gifts(f,"Seira");Depth.give(f,"Seira","Strawberry")
	assert(f.produce.Strawberry==2 and f.friendship.Seira==3)
	Depth.give(f,"Seira","Strawberry");assert(f.produce.Strawberry==2 and f.friendship.Seira==3)
	f.close_dialogue();f.travel_to("waterfall",Vector2(800,700),false)
	Depth.waterfall(f);assert(Depth.state(f).falls==1)
	f.close_dialogue();Depth.waterfall(f);f.close_dialogue();assert(Depth.state(f).falls==1,"Declining has no progress or penalty")
	Depth.accept_falls(f);f.packed_tea=0;Depth.waterfall(f);Depth.finish_falls(f);assert(Depth.state(f).falls==2)
	f.packed_tea=2;Depth.finish_falls(f);Depth.finish_falls(f)
	assert(f.packed_tea==1 and Depth.state(f).keepsakes.has("Spring keeper's charm"))
	Comfort.set_pin(f,"Tea parcel → Naomi");assert(f.quest_label.visible)
	f.enter_shop("Barn",true);f.BarnLife.purchase(f,"Cow")
	Comfort.rename_animal(f,0)
	var field=find_type(f.dialogue_panel,"LineEdit");field.text="Mochi"
	var buttons:Array=[];find_buttons(f.dialogue_panel,buttons)
	for button in buttons:
		if button.text=="Save name": button.pressed.emit()
	assert(f.BarnLife.state(f).animals[0].name=="Mochi")
	f.save_game(false);f.interior_progress={};f.load_game()
	assert(Comfort.settings(f).large_stick and Depth.state(f).falls==3 and f.BarnLife.state(f).animals[0].name=="Mochi")
	f.close_dialogue();f.current_festival=SeasonalFestivals.EVENTS[1];f.scheduled_gathering=true
	Depth.festival_reward(f);assert(Depth.state(f).festival_recipe)
	f.set_location(true,f.ROOM_ORIGIN+f.interior.BED_APPROACH);f.interior_progress.home=2;f.health=50;f.packed_tea=1;f.BarnLife.state(f).products.Milk=1
	Depth.collection(f);Depth.cook_recipe(f);assert(f.health==80 and f.packed_tea==0)
	f.close_dialogue();f.scheduled_gathering=false
	f.travel_to("farm",Vector2(1485,400),false)
	for kind in ["home","barn","land","irrigation","greenhouse","second_story"]:
		f.interior_progress.construction={"kind":kind,"day":f.day,"level":1}
		await create_timer(.25).timeout
		for node in f.get_children():
			if node.get_script()==Comfort:
				assert(is_instance_valid(node.worker) and node.worker.visible)
				assert(f.polish.clear_position(node.worker.position),"Worker on clear ground: "+kind)
	f.interior_progress.erase("construction")
	print("PASS: saved controls, favorite gifts and daily cap, optional waterfall quest and single reward, naming, recipe and pin")
	quit()
func find_type(node,kind:String):
	if node.is_class(kind): return node
	for child in node.get_children():
		var found=find_type(child,kind)
		if found!=null: return found
	return null
func find_buttons(node,result:Array):
	if node is Button: result.append(node)
	for child in node.get_children(): find_buttons(child,result)
