extends RefCounted
class_name VolunteerRequests
static func festival_key(day: int,event: Dictionary) -> String:
	return "%s_%d" % [event.id,int((day-1)/112)+1]
static func offer(farm,column,event: Dictionary,target_day: int) -> void:
	farm.dialogue_text.text += "\n\nWould you volunteer to help with the festival activity? It's optional—coming as a guest is just as welcome."
	column.add_child(farm.make_button("Accept volunteer job",choose.bind(farm,event,target_day,true)))
	column.add_child(farm.make_button("Decline · attend as a guest",choose.bind(farm,event,target_day,false)))
static func choose(farm,event: Dictionary,target_day: int,accepted: bool) -> void:
	var jobs: Dictionary = farm.interior_progress.get("volunteering",{})
	jobs[festival_key(target_day,event)] = {"name":event.name,"day":target_day,"status":"accepted" if accepted else "declined"}
	farm.interior_progress["volunteering"] = jobs
	farm.save_game(false)
	farm.close_dialogue()
	farm.say("Thank you! Join the festival and help with its activity to complete your volunteer job." if accepted else "You're welcome to enjoy the festival as a guest. No friendship is lost.")
static func complete(farm,event: Dictionary) -> void:
	if event.is_empty() or not farm.scheduled_gathering: return
	var jobs: Dictionary = farm.interior_progress.get("volunteering",{})
	var id := festival_key(farm.day,event)
	if not jobs.has(id) or jobs[id].status != "accepted": return
	jobs[id].status = "completed"
	farm.interior_progress["volunteering"] = jobs
	farm.coins += 40
	farm.friendship.Akira = mini(100,int(farm.friendship.Akira)+2)
	farm.save_game(false)
static func offer_delivery(farm,column) -> void:
	farm.dialogue_text.text += "\n\nCould you bring two harvested vegetables for the café's community meal?"
	column.add_child(farm.make_button("Accept · two vegetables",choose_delivery.bind(farm,true)))
	column.add_child(farm.make_button("Decline for now",choose_delivery.bind(farm,false)))
static func choose_delivery(farm,accepted: bool) -> void:
	farm.interior_progress["meal_request"] = "accepted" if accepted else "declined"
	farm.save_game(false)
	farm.close_dialogue()
	farm.say("Bring two vegetables in your backpack. Seira will collect them on her next farm visit." if accepted else "Seira understands. Maybe another time!")
static func delivery_ready(farm) -> bool:
	if farm.interior_progress.get("meal_request","") != "accepted": return false
	var total := 0
	for item in farm.produce: total += int(farm.produce[item])
	return total >= 2
static func deliver(farm) -> void:
	if not delivery_ready(farm): return
	var remaining := 2
	for item in farm.produce:
		var amount := mini(remaining,int(farm.produce[item]))
		farm.produce[item] -= amount
		remaining -= amount
	farm.interior_progress.meal_request = "completed"
	farm.coins += 40
	farm.friendship.Seira = mini(100,int(farm.friendship.Seira)+2)
	farm.save_game(false)
	farm.close_dialogue()
	farm.say("Two vegetables delivered. Thank you! ¥40 and friendship with Seira.")
static func journal(farm) -> void:
	farm.close_dialogue()
	var column = farm.make_modal("Requests & volunteering")
	farm.dialogue_panel.get_child(0).offset_top = -minf(430,farm.get_viewport_rect().size.y-32)
	var text := "ACCEPTED REQUESTS\n"
	if farm.tea_delivery_stage == 1: text += "Mika · deliver her tea parcel to Naomi at the café. No deadline.\n\n"
	if farm.lost_item_stage == 1: text += "Taro · find the wallet beside the maps inside the town library.\n\n"
	if farm.lost_item_stage == 2: text += "Taro · return the wallet to him at the police box or plaza.\n\n"
	if farm.fishing_quest_stage == 1: text += "Ken · catch a fish at a marked harbor spot, then talk to Masao.\n\n"
	if farm.fishing_quest_stage == 2: text += "Ken · report your first catch to Masao at the harbor/fishing shop.\n\n"
	var lunch: Dictionary = farm.interior_progress.get("cafe_delivery",{})
	if lunch.get("status","") == "accepted": text += "Naomi · take lunch to %s near %s. Talk to deliver; no deadline.\n\n" % [lunch.person,lunch.place]
	var traveler: Dictionary = farm.interior_progress.get("traveler_request",{})
	if traveler.get("status","") == "accepted": text += "%s · bring one packed tea to the inn counter. Choose Visit the traveler, then Give tea. No deadline.\n\n" % traveler.person
	if farm.interior_progress.get("meal_request","") == "accepted": text += "Seira · keep two harvested vegetables in your bag for her next farm visit.\n\n"
	var jobs: Dictionary = farm.interior_progress.get("volunteering",{})
	for id in jobs:
		var job: Dictionary = jobs[id]
		if job.status != "accepted": continue
		text += "%s · day %d · %s\n\n" % [job.name,job.day,"ended, no penalty" if int(job.day)<farm.day else "join the scheduled festival and help with its activity"]
	if text == "ACCEPTED REQUESTS\n": text += "No active requests. Speak to residents or visit the café and inn for offers.\n"
	farm.dialogue_text.text=text
	preload("res://DailyErrands.gd").append_journal(farm,column)
	# Keep long journals inside the phone viewport; buttons remain outside the scroll area.
	var label = farm.dialogue_text
	column.remove_child(label)
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size=Vector2(0,120)
	scroll.size_flags_vertical=Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED
	column.add_child(scroll)
	column.move_child(scroll,1)
	scroll.add_child(label)
	label.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	label.size_flags_vertical=Control.SIZE_SHRINK_BEGIN
	column.add_child(farm.make_button("Close",farm.close_dialogue))
