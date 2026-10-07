extends RefCounted
const JOBS := [
	{"title":"Village rounds","stops":["Clinic","General Store"],"hint":"Stop inside the clinic and store."},
	{"title":"Harbor check-in","stops":["harbor","Fishing Shop"],"hint":"Visit the harbor and fishing shop."},
	{"title":"Mountain rounds","stops":["mountain","Onsen Resort"],"hint":"Visit the mountain and onsen reception."},
	{"title":"Tea country visit","stops":["tea","Tea Processing Shed"],"hint":"Visit tea country and the processing shed."}
]
static func current(farm) -> Dictionary:
	return JOBS[(farm.day-1)%JOBS.size()]
static func state(farm) -> Dictionary:
	var entry: Dictionary = farm.interior_progress.get("daily_errand",{})
	if int(entry.get("day",0)) != farm.day:
		entry={"day":farm.day,"accepted":false,"claimed":false,"visited":[]}
		farm.interior_progress.daily_errand=entry
	return entry
static func visit(farm,place: String) -> void:
	var entry := state(farm)
	if entry.accepted and not entry.claimed and place in current(farm).stops and place not in entry.visited:
		entry.visited.append(place)
static func ready(farm) -> bool:
	var entry := state(farm)
	return entry.accepted and not entry.claimed and entry.visited.size()==current(farm).stops.size()
static func accept(farm) -> void:
	state(farm).accepted=true
	farm.save_game(false)
	farm.close_dialogue()
	farm.say(current(farm).hint+" Optional; no penalty if left unfinished.")
static func claim(farm) -> void:
	if not ready(farm): return
	state(farm).claimed=true
	farm.coins+=30
	farm.save_game(false)
	farm.close_dialogue()
	farm.say("Village errand complete. Thank you! +¥30.")
static func append_journal(farm,column) -> void:
	var entry := state(farm)
	var job := current(farm)
	farm.dialogue_text.text += "\n\nToday: "+job.title+" · "+job.hint
	if entry.claimed: farm.dialogue_text.text += "\nCompleted · reward collected."
	elif ready(farm): column.add_child(farm.make_button("Collect errand reward · ¥30",claim.bind(farm)))
	elif entry.accepted: farm.dialogue_text.text += "\nVisited %d / %d · optional, no deadline penalty." % [entry.visited.size(),job.stops.size()]
	else: column.add_child(farm.make_button("Accept optional village errand",accept.bind(farm)))
