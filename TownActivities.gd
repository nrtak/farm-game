extends RefCounted
const MEALS := ["Vegetable curry", "Grilled fish lunch", "Roasted tea rice"]
const CUSTOMERS := ["Haruka", "Taro", "Sachiko"]
const PLACES := ["the library in town", "the police box or town plaza", "tea country"]
const TRAVELERS := ["Natsu the illustrator", "Sora the walking guide", "Jun the tea merchant"]
const STORIES := ["I sketch the harbor at dawn. The fishing boats make wonderful silhouettes.", "The mountain spring is my favorite stop. I always leave room in my bag for the walk home.", "Every village brews tea differently. Your hills have a fragrance I haven't found anywhere else."]
static func index(farm) -> int:
	return posmod(farm.day-1,3)
static func menu(farm, title: String):
	farm.close_dialogue()
	var column = farm.make_modal(title)
	farm.dialogue_panel.get_child(0).offset_top = -minf(430,farm.get_viewport_rect().size.y-32)
	return column
static func cafe(farm) -> void:
	var column = menu(farm,"Café · Naomi")
	farm.dialogue_text.text = "Today's meal: %s. Restores 30 Health for ¥30.\nHealth %d / 100 · Money ¥%d" % [MEALS[index(farm)],farm.health,farm.coins]
	column.add_child(farm.make_button("Enjoy today's meal · ¥30",farm.purchase_meal))
	column.add_child(farm.make_button("Customer delivery",delivery_offer.bind(farm)))
	column.add_child(farm.make_button("Close",farm.close_dialogue))
static func delivery_offer(farm) -> void:
	var column = menu(farm,"Naomi's lunch delivery")
	var job: Dictionary = farm.interior_progress.get("cafe_delivery",{})
	if job.get("status","") == "accepted":
		farm.dialogue_text.text = "Take the lunch to %s near %s. Talk to them to deliver it. No deadline." % [job.person,job.place]
	elif int(job.get("day",-1)) == farm.day:
		farm.dialogue_text.text = "You've delivered today's lunch. Thank you!"
	else:
		farm.dialogue_text.text = "Could you take a packed lunch to %s near %s? I'll supply it. Reward ¥35; no deadline." % [CUSTOMERS[index(farm)],PLACES[index(farm)]]
		column.add_child(farm.make_button("Accept lunch delivery",accept_delivery.bind(farm)))
	column.add_child(farm.make_button("Not now / Close",farm.close_dialogue))
static func accept_delivery(farm) -> void:
	if farm.location != "shop" or farm.shop_name != "Café": return
	var job: Dictionary = farm.interior_progress.get("cafe_delivery",{})
	if job.get("status","") == "accepted" or int(job.get("day",-1)) == farm.day: return
	farm.interior_progress.cafe_delivery={"day":farm.day,"person":CUSTOMERS[index(farm)],"place":PLACES[index(farm)],"status":"accepted"}
	farm.save_game(false)
	farm.close_dialogue()
	farm.say("Lunch packed in your request pouch. See Requests for the destination.")
static func deliver_to(farm, person: String) -> String:
	var job: Dictionary = farm.interior_progress.get("cafe_delivery",{})
	if job.get("status","") != "accepted" or job.get("person","") != person: return ""
	job.status="completed"
	farm.coins+=35
	farm.friendship[person]=mini(100,int(farm.friendship.get(person,0))+2)
	farm.save_game(false)
	return "Thank you for bringing Naomi's lunch! Here is ¥35 for the delivery."
static func inn(farm) -> void:
	var column = menu(farm,"Inn · Yumi")
	farm.dialogue_text.text = "Rest restores 30 Health for ¥30. A traveler is staying in the guest room today."
	column.add_child(farm.make_button("Rest · ¥30",farm.purchase_meal))
	column.add_child(farm.make_button("Visit the traveler",traveler.bind(farm)))
	column.add_child(farm.make_button("Close",farm.close_dialogue))
static func traveler(farm) -> void:
	var column = menu(farm,TRAVELERS[index(farm)])
	var job: Dictionary = farm.interior_progress.get("traveler_request",{})
	farm.dialogue_text.text = STORIES[index(farm)]
	if job.get("status","") == "accepted":
		farm.dialogue_text.text += "\nYumi is holding %s's request: bring one packet of tea here for ¥60. No deadline." % job.person
		column.add_child(farm.make_button("Give one packed tea · ¥60",complete_traveler.bind(farm)))
	elif int(job.get("day",-1)) == farm.day:
		farm.dialogue_text.text += "\nYour tea was lovely. Thank you!"
	else:
		farm.dialogue_text.text += "\nCould I buy one packet of local tea for ¥60? Yumi can receive it if I've left. No deadline."
		column.add_child(farm.make_button("Accept tea request",accept_traveler.bind(farm)))
	column.add_child(farm.make_button("Not now / Close",farm.close_dialogue))
static func accept_traveler(farm) -> void:
	if farm.location != "shop" or farm.shop_name != "Inn": return
	var job: Dictionary = farm.interior_progress.get("traveler_request",{})
	if job.get("status","") == "accepted" or int(job.get("day",-1)) == farm.day: return
	farm.interior_progress.traveler_request={"status":"accepted","day":farm.day,"person":TRAVELERS[index(farm)]}
	farm.save_game(false)
	traveler(farm)
static func complete_traveler(farm) -> void:
	if farm.location != "shop" or farm.shop_name != "Inn": return
	var job: Dictionary = farm.interior_progress.get("traveler_request",{})
	if job.get("status","") != "accepted": return
	if farm.packed_tea < 1:
		farm.dialogue_text.text="Bring one packed tea. Pack two leaves at the Tea Processing Shed counter."
		return
	farm.packed_tea-=1
	farm.coins+=60
	job.status="completed"
	farm.save_game(false)
	traveler(farm)
static func library(farm, page: int = 0) -> void:
	var texts := ["The first tea gardens began with neighbors sharing seedlings. The village square became a place to trade harvests and stories.","Your family's old map marks three growing patches. Kenta's carpenter counter lists the harvest and money needed to restore them.","A margin note reads: 'A farm lasts through the hands that help it.' Visit Town Hall for community projects and festival volunteering."]
	var column = menu(farm,"Library · village and family records (%d/3)" % (page+1))
	farm.dialogue_text.text=texts[page]
	var read: Array = farm.interior_progress.get("library_pages",[])
	if page not in read:
		read.append(page)
		farm.interior_progress.library_pages=read
		farm.save_game(false)
	column.add_child(farm.make_button("Next record",library.bind(farm,(page+1)%3)))
	column.add_child(farm.make_button("Close",farm.close_dialogue))
static func hall(farm) -> void:
	var column = menu(farm,"Town Hall · community board")
	farm.dialogue_text.text="Festival dates, accepted requests, and the village projects you have helped complete."
	column.add_child(farm.make_button("Festival calendar",farm.open_calendar))
	column.add_child(farm.make_button("Requests & volunteering",preload("res://VolunteerRequests.gd").journal.bind(farm)))
	column.add_child(farm.make_button("Village progress",farm.InteriorLife.open_projects.bind(farm)))
	column.add_child(farm.make_button("Close",farm.close_dialogue))
