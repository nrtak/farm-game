extends SceneTree
const A=preload("res://TownActivities.gd")
func _initialize(): call_deferred("run")
func run():
	var f=load("res://Main.tscn").instantiate()
	root.add_child(f)
	await process_frame
	f.set_physics_process(false);f.choose_character("boy")
	f.interior_progress.story={"intro":true}
	f.day=1;f.clock_minutes=780
	f.enter_shop("Café",true)
	A.delivery_offer(f);f.close_dialogue()
	assert(not f.interior_progress.has("cafe_delivery"),"Closing offer does not accept")
	A.accept_delivery(f)
	assert(f.interior_progress.cafe_delivery.person=="Haruka")
	f.day=2;A.accept_delivery(f)
	assert(f.interior_progress.cafe_delivery.person=="Haruka","Next day preserves active request")
	var money:int=f.coins
	assert(A.deliver_to(f,"Taro")=="")
	assert(A.deliver_to(f,"Haruka")!="")
	assert(A.deliver_to(f,"Haruka")=="" and f.coins==money+35,"Cannot reward twice")
	f.save_game(false);f.load_game()
	assert(A.deliver_to(f,"Haruka")=="","Completion survives reload")
	f.enter_shop("Inn",true);A.traveler(f)
	assert(not f.interior_progress.has("traveler_request"))
	A.accept_traveler(f);f.packed_tea=0
	A.complete_traveler(f)
	assert(f.coins==money+35,"No reward without tea")
	f.day=3;f.packed_tea=1;A.complete_traveler(f);A.complete_traveler(f)
	assert(f.coins==money+95 and f.packed_tea==0,"Old traveler request completes once")
	f.save_game(false);f.load_game()
	assert(f.interior_progress.traveler_request.status=="completed")
	f.enter_shop("Archive",true);A.library(f,0);A.library(f,1);A.library(f,0)
	assert(f.interior_progress.library_pages.size()==2,"Records saved once")
	f.tea_delivery_stage=1;f.lost_item_stage=2;f.fishing_quest_stage=2
	preload("res://VolunteerRequests.gd").journal(f)
	assert("Mika" in f.dialogue_text.text and "Taro" in f.dialogue_text.text and "Masao" in f.dialogue_text.text)
	var previous_panel=f.dialogue_panel
	f.open_calendar()
	assert(not previous_panel.visible and previous_panel.is_queued_for_deletion(),"Replacing a menu releases its old panel")
	f.close_dialogue();f.tea_delivery_stage=2;f.lost_item_stage=3;f.fishing_quest_stage=3;f.refresh_hud()
	assert(not f.quest_label.visible,"Completed tasks don't leave blank HUD")
	f.clock_minutes=780;f.enter_shop("Blacksmith",true);f.open_service("Blacksmith")
	f.coins=500;f.ore_basket.Copper=4;f.tool_level=0
	f.purchase_upgrade();f.purchase_upgrade()
	assert(f.coins==400 and f.ore_basket.Copper==2 and f.tool_level==1)
	await create_timer(2.6).timeout
	var animations=0
	for child in f.dialogue_text.get_parent().get_children():
		if child.get_script()==load("res://ForgeMoment.gd"):
			animations+=1
			assert(not child.is_processing(),"Forge animation stops spending CPU when complete")
	assert(animations==1)
	print("PASS: town requests opt-in, shortages, daily rotation, persistence, journal and forge reward guards")
	quit()
