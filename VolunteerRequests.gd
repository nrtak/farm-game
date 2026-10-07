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
	var column = farm.make_modal("Requests & volunteering")
	farm.dialogue_panel.get_child(0).offset_top = -380
	var text := ""
	var jobs: Dictionary = farm.interior_progress.get("volunteering",{})
	for id in jobs:
		var job: Dictionary = jobs[id]
		if job.status == "declined": continue
		var status: String = job.status
		if status == "accepted" and int(job.day) < farm.day: status = "ended · no penalty"
		text += job.name+" · "+status+"\n"
	var meal: String = farm.interior_progress.get("meal_request","")
	if meal in ["accepted","completed"]: text += "Seira's community meal · two vegetables · "+meal+"\n"
	farm.dialogue_text.text = "No accepted requests yet. Residents may stop by the farmhouse with an offer." if text.is_empty() else text
	preload("res://DailyErrands.gd").append_journal(farm,column)
	column.add_child(farm.make_button("Close",farm.close_dialogue))
