extends RefCounted
class_name SeasonalFestivals
const EVENTS := [
	{"id":"planting","name":"Community Planting Day","day":4,"area":"town","game":"plant"},
	{"id":"lavender","name":"Lavender Festival","day":9,"area":"tea","game":"flowers"},
	{"id":"spring","name":"Spring Gathering","day":14,"area":"town","game":"tea"},
	{"id":"tea","name":"Tea Festival","day":22,"area":"tea","game":"blend"},
	{"id":"beach","name":"Beach Festival","day":34,"area":"harbor","game":"shells"},
	{"id":"fishing","name":"Fishing Festival","day":41,"area":"harbor","game":"catch"},
	{"id":"obon","name":"Obon Festival","day":47,"area":"historic","game":"memory"},
	{"id":"baseball","name":"Baseball Festival","day":53,"area":"town","game":"bat"},
	{"id":"pumpkin","name":"Pumpkin Festival","day":63,"area":"town","game":"carve"},
	{"id":"pie","name":"Pie Contest","day":69,"area":"town","game":"pie"},
	{"id":"lantern","name":"Lantern Festival","day":76,"area":"historic","game":"lantern"},
	{"id":"dinner","name":"Harvest Dinner","day":81,"area":"town","game":"dinner"},
	{"id":"chocolate","name":"Hot Chocolate Festival","day":90,"area":"town","game":"chocolate"},
	{"id":"onsen","name":"Winter Onsen Night","day":96,"area":"mountain","game":"onsen"},
	{"id":"winter","name":"Winter Festival","day":104,"area":"town","game":"snow"},
	{"id":"newyear","name":"New Year Gathering","day":112,"area":"historic","game":"wish"}
]
const PEOPLE := {
	"town":["Akira","Taro","Seira","Shohei","Hana","Yuta","Keiko","Naomi"],
	"tea":["Akira","Sachiko","Mika","Midori","Naomi","Seira"],
	"harbor":["Akira","Ken","Masao","David","Yuta","Hana"],
	"historic":["Akira","Haruka","Rei","Chanel","Hiro","Taro"],
	"mountain":["Akira","Emi","Hiro","Ren","Chanel","Midori"]
}
static func today(day: int) -> Dictionary:
	for event in EVENTS:
		if event.day == (day-1)%112+1: return event.duplicate()
	return {}
static func center(area: String) -> Vector2:
	return Vector2(1200,910) if area == "town" else (Vector2(820,945) if area == "mountain" else Vector2(800,610))
static func key(farm,event: Dictionary) -> String:
	return "%s_%d" % [event.id,int((farm.day-1)/112)+1]
static func maybe_start(farm) -> void:
	var event := today(farm.day)
	if event.is_empty() or event.id == "spring" or farm.dialogue_open or farm.festival_active or farm.active_scene != "" or farm.choosing_character: return
	var start: int = 1080 if event.id in ["obon","lantern","onsen","newyear"] else 600
	var finish: int = 1320 if start == 1080 else 1080
	if farm.location != event.area or farm.clock_minutes < start or farm.clock_minutes >= finish: return
	var attendance: Dictionary = farm.interior_progress.get("festival_attendance",{})
	if attendance.has(key(farm,event)): return
	var origin: Vector2 = farm.TOWN_ORIGIN if event.area == "town" else farm.REGION_ORIGINS[event.area]
	if farm.player.position.distance_to(origin+center(event.area)) > 220: return
	event.people = PEOPLE[event.area]
	farm.begin_festival(event)
	farm.scheduled_gathering = true
	farm.festival_button.text = "Finish Festival"
	farm.say(event.name+"! Greet your neighbors and try today's activity.")
static func finish(farm) -> void:
	if not farm.scheduled_gathering or farm.current_festival.is_empty(): return
	var attendance: Dictionary = farm.interior_progress.get("festival_attendance",{})
	var id := key(farm,farm.current_festival)
	if not attendance.has(id):
		attendance[id] = true
		farm.interior_progress["festival_attendance"] = attendance
		farm.coins += 50
		for record in farm.festival_people:
			var person: String = record.npc.first_name
			farm.friendship[person] = mini(100,int(farm.friendship.get(person,0))+2)
		farm.say(farm.current_festival.name+" complete! ¥50 and time with your neighbors.")
	farm.scheduled_gathering = false
	farm.save_game(false)
static func calendar(farm) -> String:
	var season: int = int(((farm.day-1)%112)/28)
	var text := "This season's gatherings:\n"
	for event in EVENTS:
		if int((event.day-1)/28) != season: continue
		var evening: bool = event.id in ["obon","lantern","onsen","newyear"]
		text += "%d · %s · %s\n" % [(event.day-1)%28+1,event.name,"6–10 PM" if evening else "10 AM–6 PM"]
	text += "\nWalk into the festival area to join. Akira visits before each event."
	return text
static func open_activity(farm) -> void:
	var event: Dictionary = farm.current_festival
	if event.is_empty(): return
	var column = farm.make_modal(event.name)
	farm.dialogue_panel.get_child(0).offset_top = -360
	var introductions := {
		"plant":"Help the neighbors prepare the community garden. What should we do first?",
		"flowers":"Choose a lavender sprig for the community bouquet.",
		"blend":"Mika invites you to blend tea. Which leaves make a gentle fresh tea?",
		"shells":"Ken's beach hunt: choose a shell to add to the display.",
		"catch":"Masao's casting challenge. Watch the signal, then press Reel!",
		"memory":"Rei invites you to share a quiet memory of someone who helped you.",
		"bat":"Yuta pitches! Press Swing when the moving ball reaches the center.",
		"carve":"Choose a pumpkin face for the plaza display.",
		"pie":"Naomi's pie contest: choose the filling for your entry.",
		"lantern":"Write a wish on your lantern, then send it into the evening.",
		"dinner":"Bring the neighbors together around the harvest table. What will you share?",
		"chocolate":"Chanel is serving warm chocolate. Choose your topping.",
		"onsen":"Enjoy the warm bath and quiet conversation beneath the winter sky.",
		"snow":"Help Hana choose a winter decoration for the plaza.",
		"wish":"A new year begins. What would you like to work toward?"
	}
	farm.dialogue_text.text = introductions.get(event.game,"Enjoy the gathering.")
	if event.game in ["bat","catch"]:
		var bar := ProgressBar.new()
		bar.custom_minimum_size = Vector2(300,28)
		bar.show_percentage = false
		column.add_child(bar)
		var timer := Timer.new()
		timer.wait_time = 0.05
		column.add_child(timer)
		timer.timeout.connect(func(): bar.value = timing_value(farm))
		timer.start()
		column.add_child(farm.make_button("Swing!" if event.game == "bat" else "Reel!",timed_action.bind(farm)))
	else:
		var choices: Array = {
			"plant":["Water the prepared beds","Plant in dry packed soil","Leave weeds in place"],
			"flowers":["A fragrant lavender sprig","A pale ribbon","A little green leaf"],
			"blend":["Tender young leaves","Dry old stems","A pinch of patience"],
			"shells":["A scallop shell","A spiral shell","A smooth pebble"],
			"memory":["A family memory","A neighbor's kindness","A wish to help others"],
			"carve":["A smiling pumpkin","A sleepy pumpkin","A surprised pumpkin"],
			"pie":["Pumpkin & spice","Strawberry","A savory vegetable pie"],
			"lantern":["A thriving farm","A happy village","A new friendship"],
			"dinner":["Fresh vegetables","A family recipe","Help setting the table"],
			"chocolate":["A little cream","A sprinkle of cinnamon","Keep it simple"],
			"onsen":["Share a farming story","Ask about the spring water","Enjoy a quiet moment"],
			"snow":["A snow lantern","A winter wreath","A little snow rabbit"],
			"wish":["Restore the family land","Get to know the village","Learn something new"]
		}.get(event.game,["Take part"])
		for i in range(choices.size()): column.add_child(farm.make_button(choices[i],answer.bind(farm,i)))
	column.add_child(farm.make_button("Back to festival",farm.close_dialogue))
static func timing_value(farm) -> float:
	return (sin(Time.get_ticks_msec()/400.0)+1)*50
static func timed_action(farm) -> void:
	# World animation pauses under a dialogue; wall time supplies the activity meter.
	var value: float = (sin(Time.get_ticks_msec()/400.0)+1)*50
	if absf(value-50) > 20:
		farm.dialogue_text.text = "A little early or late! Try again when the meter is near the center."
		return
	answer(farm,0)
static func answer(farm,choice: int) -> void:
	if farm.current_festival.is_empty(): return
	if farm.current_festival.game in ["plant","blend"] and choice == 1:
		farm.dialogue_text.text = "Let's try another approach. The neighbors offer a helpful hint."
		return
	var rewards: Dictionary = farm.interior_progress.get("festival_activities",{})
	var id := key(farm,farm.current_festival)
	if farm.scheduled_gathering and not rewards.has(id):
		rewards[id] = choice
		farm.interior_progress["festival_activities"] = rewards
		farm.coins += 25
		farm.health = minf(100,farm.health+5)
		farm.save_game(false)
	VolunteerRequests.complete(farm,farm.current_festival)
	farm.dialogue_text.text = "Thank you for taking part! The neighbors enjoy your contribution. Your festival activity is recorded."
