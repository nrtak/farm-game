extends RefCounted
const NEIGHBORS := ["Seira","Shohei","Akira","Taro","Aya","Hana","Mika","Yuta","Ken","Hiro","Keiko","Kenji","Gen","Yumi","Jiro","Naomi","Sachiko","Kenta","Yoshi","Rei","Masao","Emi","Ren","Chanel","David","Renji","Midori"]
static func check_visit(farm) -> bool:
	if farm.location != "farm" or farm.inside_house or farm.festival_active or farm.active_scene != "": return false
	if farm.player.position.distance_to(Vector2(450,1080)) > 90: return false
	if farm.joystick.direction.length() > 0.1 or farm.player.velocity.length() > 1: return false
	var state: Dictionary = farm.interior_progress.get("story",{})
	var key := ""
	var person := "Akira"
	var words := ""
	if not state.get("intro",false):
		key = "intro"
		words = "Welcome to your family's farm. The village land trust has given you two years to restore it. At the end of Year 2, all 27 residents will vote on permanent stewardship.\n\nGrow and harvest 30 crops, restore two land patches, join five different room activities, and get to know your neighbors. Money alone won't decide your future. I'll return after Year 1 to review your progress."
	elif farm.day >= 112 and not state.get("review",false):
		key = "review"
		words = "It's time for your Year 1 review. You still have another year before the village vote.\n\n" + progress(farm)
	elif farm.day >= int(state.get("vote_day",224)) and not state.get("won",false):
		key = "vote"
		var votes := yes_votes(farm)
		if votes >= 14:
			state["won"] = true
			words = "The village has voted: %d in favor, %d asking for more time. You have earned permanent stewardship of your family farm!\n\nThank you for bringing this land back to life. This closes the main story, but your farm life continues. There are still seasons, friendships, and celebrations ahead." % [votes,27-votes]
		else:
			state["vote_day"] = farm.day+28
			words = "The vote was %d in favor and %d asking for more progress. You keep working the farm. We have granted another season and will review it again in 28 days.\n\n" % [votes,27-votes] + progress(farm)
	elif (farm.day-1)%112 == 12 and not state.has("invite_%d" % farm.day):
		key = "invite_%d" % farm.day
		words = "I stopped by to invite you to tomorrow's Spring Gathering. Join us in the town plaza between 10 AM and 6 PM. You're part of this community, and we'd love to see you there."
	elif farm.harvests >= 3 and not state.get("seira_visit",false):
		key = "seira_visit"
		person = "Seira"
		words = "I heard about your first harvests! Mum is glad to see these fields growing again. If you need more seeds or backpack space, stop by the store. Naomi would love a contribution to her recipe book, too."
	elif int(farm.interior_progress.get("restoration",0)) >= 1 and not state.get("kenta_visit",false):
		key = "kenta_visit"
		person = "Kenta"
		words = "That reclaimed patch is looking good. I'll be at the carpentry workshop on the southwest edge of town. We can expand the house next—first a storage room, then a kitchen wing."
	if key.is_empty(): return false
	state[key] = true
	farm.interior_progress["story"] = state
	var visitor = preload("res://Npc.gd").new()
	farm.farm_visitor = visitor
	farm.add_child(visitor)
	visitor.setup(person,load("res://assets/npc-%s-walk.png" % person.to_lower()))
	visitor.position = Vector2(650,1080)
	visitor.z_index = 5
	visitor.face_player(farm.player.position)
	var column = farm.make_modal(person,true)
	farm.dialogue_panel.get_child(0).offset_top = -minf(380,farm.get_viewport_rect().size.y-32)
	farm.dialogue_text.text = words
	column.add_child(farm.make_button("Thanks for stopping by",finish_visit.bind(farm,visitor)))
	farm.save_game(false)
	return true
static func finish_visit(farm, visitor) -> void:
	if is_instance_valid(visitor): visitor.queue_free()
	farm.close_dialogue()
static func progress(farm) -> String:
	var met := 0
	for person in NEIGHBORS:
		if int(farm.friendship.get(person,0)) >= 2: met += 1
	return "Harvests: %d / 30\nLand restored: %d / 2\nDifferent room activities: %d / 5\nNeighbors with two friendship points: %d / 27\n\nVisit Kenta for expansion plans, explore room activities, and talk with residents." % [farm.harvests,int(farm.interior_progress.get("restoration",0)),farm.interior_progress.get("activities",[]).size(),met]
static func yes_votes(farm) -> int:
	var contribution := 0
	if farm.harvests >= 30: contribution += 1
	if int(farm.interior_progress.get("restoration",0)) >= 2: contribution += 1
	if farm.interior_progress.get("activities",[]).size() >= 5: contribution += 1
	var votes := 0
	for person in NEIGHBORS:
		var bond: int = int(farm.friendship.get(person,0))
		if contribution >= 3 or (contribution >= 2 and bond >= 2) or (contribution >= 1 and bond >= 8): votes += 1
	return votes
