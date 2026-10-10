extends RefCounted
const ACTIVITIES := {
	"Mountain Carpentry":["Forest workshop plans","Kenta prepares timber here from 8 AM to noon, then works at his town workshop until 6 PM."],
	"Onsen Resort":["Bath etiquette","Rinse before entering the hot spring. Enjoy a quiet soak and leave the bath area tidy."],
	"Carpentry": ["Expansion plans", "Kenta can restore farmland and expand your home. Review the plans at the counter."],
	"General Store": ["Seed guide", "Turnips grow quickly; potatoes need more patience. Water each planted crop every day. Visit Keiko's counter for seeds and larger backpacks."],
	"Blacksmith": ["Tool workshop", "Shohei has left a practice tool here. Spend a little time cleaning its grip and sharpening its edge."],
	"Café": ["Community recipe book", "Naomi's seasonal soup starts with fresh vegetables from local farms. Three harvested crops are enough to contribute your first recipe."],
	"Inn": ["Guest sketchbook", "Hana's sketches show the inn through the seasons. Sit with the book for a quiet break."],
	"Clinic": ["Health notes", "Kenji recommends taking breaks before exhaustion. A quiet breathing exercise restores a little Health once each day."],
	"Town Hall": ["Community projects", "Help restore your inherited land and share your harvest with the community."],
	"Police Box": ["Patrol log", "Taro's log reminds travelers to leave narrow doorways and paths clear. Help him review today's walking routes."],
	"Fire Station": ["Safety drill", "Jiro and Yuta are practicing a simple drill: clear the exit, check the equipment, and meet at the plaza."],
	"Archive": ["Family land records", "An old map marks three neglected growing patches on your property. Town Hall can help organize their restoration."],
	"Shrine Residence": ["Festival preparations", "Rei has laid out the gathering decorations. Help fold and sort them before the next festival."],
	"Mountain Lodge": ["Trail journal", "Emi's journal recommends the lower trails in clear weather and a warm indoor break when it rains."],
	"Tea Farmhouse": ["Tea-growing notebook", "Sachiko's notes: pick tender leaves, keep the bushes rested, and sort before processing."],
	"Tea Processing Shed": ["Packing lesson", "Mika's packing notes explain how two handfuls of leaves make one packet. Use the counter to process your tea."],
	"Harbor Homes": ["Net-mending basket", "Ken and Masao have left a practice net. Repair a loose knot while listening to the harbor."],
	"Fishing Shop": ["Catch journal", "Watch the float before pressing Catch. Different fish bring different shipping prices."],
	"Hiro Cabin": ["Field notebook", "Hiro sketches local plants and records changes after rain. Add a note about your farm's first harvest."]
}
const PROJECTS := [
	["Clear the east patch", 150, 3],
	["Restore the old garden", 250, 8],
	["Reclaim the ancestral beds", 400, 15]
]
static func add_plots(farm, level: int) -> void:
	preload("res://FarmPlots.gd").fill(farm,level)
static func open_room(farm, room: String) -> void:
	farm.close_dialogue()
	var info: Array = ACTIVITIES[room]
	var column = farm.make_modal(info[0])
	farm.dialogue_text.text = info[1]
	if room == "Town Hall":
		column.add_child(farm.make_button("Community requests and restoration", open_projects.bind(farm)))
	elif room in ["Blacksmith","Café","Inn","Clinic","Police Box","Fire Station","Shrine Residence","Harbor Homes","Hiro Cabin"]:
		column.add_child(farm.make_button("Take part (once today)", participate.bind(farm,room)))
	column.add_child(farm.make_button("Close",farm.close_dialogue))
static func participate(farm, room: String) -> void:
	var days: Dictionary = farm.interior_progress.get("days",{})
	if int(days.get(room,-1)) == farm.day:
		farm.dialogue_text.text = "You've already taken part today. Come back tomorrow."
		return
	if room == "Café" and farm.harvests < 3:
		farm.dialogue_text.text = "Harvest three crops first, then return to share your recipe."
		return
	days[room] = farm.day
	farm.interior_progress["days"] = days
	var completed: Array = farm.interior_progress.get("activities",[])
	if not completed.has(room): completed.append(room)
	farm.interior_progress["activities"] = completed
	farm.health = minf(100,farm.health+5)
	var people := {"Blacksmith":"Shohei","Café":"Naomi","Inn":"Hana","Clinic":"Aya","Police Box":"Taro","Fire Station":"Yuta","Shrine Residence":"Rei","Harbor Homes":"Ken","Hiro Cabin":"Hiro"}
	var person: String = people.get(room,"Akira")
	farm.friendship[person] = mini(100,int(farm.friendship.get(person,0))+1)
	farm.dialogue_text.text = "Activity complete. +5 Health and a little friendship with %s. Your contribution is recorded at Town Hall." % person
	farm.save_game(false)
	farm.refresh_hud()
	if room == "Blacksmith": preload("res://ForgeMoment.gd").show_on(farm)
static func open_projects(farm) -> void:
	farm.close_dialogue()
	var column = farm.make_modal("Community projects")
	farm.dialogue_panel.get_child(0).offset_top = -minf(400,farm.get_viewport_rect().size.y-32)
	var level: int = int(farm.interior_progress.get("restoration",0))
	var done: Array = farm.interior_progress.get("activities",[])
	farm.dialogue_text.text = "Restoration: %d / 3 • Harvests: %d\nCommunity activities: %d / 9" % [level,farm.harvests,done.size()]
	if level < 3:
		column.add_child(farm.make_button("View expansion plans at Kenta’s workshop",open_carpentry.bind(farm)))
	if not farm.interior_progress.get("welcome_claimed",false):
		column.add_child(farm.make_button("Welcome request: meet all five new neighbors • ¥100",claim_request.bind(farm,"welcome")))
	if not farm.interior_progress.get("helper_claimed",false):
		column.add_child(farm.make_button("Town helper: join three room activities • ¥150",claim_request.bind(farm,"helper")))
	column.add_child(farm.make_button("Close",farm.close_dialogue))
static func claim_request(farm, which: String) -> void:
	if farm.interior_progress.get(which+"_claimed",false): return
	var ready := true
	if which == "welcome":
		for person in ["Ren","Chanel","David","Renji","Midori"]:
			if int(farm.friendship.get(person,0)) < 1: ready = false
	else: ready = farm.interior_progress.get("activities",[]).size() >= 3
	if not ready:
		farm.dialogue_text.text = "Keep exploring. This request isn't complete yet."
		return
	farm.interior_progress[which+"_claimed"] = true
	farm.coins += 100 if which == "welcome" else 150
	farm.save_game(false)
	open_projects(farm)

static func plan(farm, kind: String) -> Dictionary:
	var keys := {"land":"restoration","home":"home","barn":"barn","irrigation":"irrigation","second_story":"second_story","greenhouse":"greenhouse"}
	if not keys.has(kind): return {}
	var level: int = int(farm.interior_progress.get(keys[kind],0)) if kind in ["land","home"] else (int(preload("res://BarnLife.gd").state(farm).level) if kind == "barn" else int(farm.resources.state().irrigation) if kind=="irrigation" else 0)
	if kind in ["second_story","greenhouse"]:
		if farm.interior_progress.get(kind,false): return {}
		return {"level":0,"cost":2500 if kind=="second_story" else 5000,"wood":45 if kind=="second_story" else 75,"harvests":0,"title":"Second story" if kind=="second_story" else "Year-round greenhouse","benefit":"Open upstairs loft with extra beds and a sitting area" if kind=="second_story" else "Grow all seed varieties in any season, sheltered from heatwaves"}
	if level >= (3 if kind == "land" else 2): return {}
	if kind == "land": return {"level":level,"cost":PROJECTS[level][1],"wood":0,"harvests":PROJECTS[level][2],"title":PROJECTS[level][0],"benefit":"Three additional crop beds"}
	if kind == "home": return {"level":level,"cost":[500,900][level],"wood":[12,24][level],"harvests":[5,12][level],"title":["Second room: storage","Third room: kitchen"][level],"benefit":["Double chest capacity","Cook two vegetables for +25 Health"][level]}
	if kind == "barn": return {"level":level,"cost":[600,1000][level],"wood":[18,30][level],"harvests":0,"title":"Two more animal stalls","benefit":"Increase barn capacity to %d animals" % (6+level*2)}
	return {"level":level,"cost":[12000,20000][level],"wood":[90,150][level],"harvests":0,"title":["Starter field sprinklers","Full field irrigation"][level],"benefit":["Automatically water the first 15 beds each morning and after planting","Automatically water all crop beds each morning and after planting"][level]}
static func open_carpentry(farm) -> void:
	farm.close_dialogue()
	var column = farm.make_modal("Kenta's expansion plans")
	farm.dialogue_panel.get_child(0).offset_top = -minf(440,farm.get_viewport_rect().size.y-32)
	farm.dialogue_text.text = "Lumber supply: %d. Construction finishes after sleeping." % farm.resources.state().lumber
	if farm.interior_progress.has("construction"):
		farm.dialogue_text.text = "Kenta is working on your upgrade. Sleep to the next morning to finish construction."
	else:
		var scroll := ScrollContainer.new()
		scroll.custom_minimum_size = Vector2(0,160)
		scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
		column.add_child(scroll)
		var list := VBoxContainer.new()
		list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		scroll.add_child(list)
		for kind in ["land","home","second_story","barn","irrigation","greenhouse"]:
			var info := plan(farm,kind)
			if not info.is_empty(): list.add_child(farm.make_button(kind.capitalize()+": "+info.title,preview_upgrade.bind(farm,kind)))
	column.add_child(farm.make_button("Close",farm.close_dialogue))
static func preview_upgrade(farm, kind: String) -> void:
	var info := plan(farm,kind)
	if info.is_empty(): return
	farm.close_dialogue()
	var column = farm.make_modal("Expansion preview")
	farm.dialogue_panel.get_child(0).offset_top = -minf(400,farm.get_viewport_rect().size.y-32)
	farm.dialogue_text.text = "%s\n¥%d + %d lumber · %d total harvests required\nReady tomorrow. Existing crops and animals are preserved." % [info.benefit,info.cost,info.wood,info.harvests]
	column.add_child(farm.make_button("Order construction",order_upgrade.bind(farm,kind)))
	column.add_child(farm.make_button("Back",open_carpentry.bind(farm)))
static func order_upgrade(farm, kind: String) -> void:
	if farm.location != "shop" or farm.shop_name not in ["Carpentry","Mountain Carpentry"]:
		farm.dialogue_text.text = "Visit Kenta at either workshop to order construction."
		return
	if farm.interior_progress.has("construction"): return
	var info := plan(farm,kind)
	if info.is_empty(): return
	if farm.coins < info.cost or farm.harvests < info.harvests or farm.resources.state().lumber < info.wood:
		farm.dialogue_text.text = "Not enough money, lumber or harvest experience. Nothing was charged."
		return
	farm.coins -= info.cost
	farm.resources.state().lumber -= info.wood
	farm.interior_progress.construction = {"kind":kind,"day":farm.day,"level":info.level+1}
	farm.save_game(false)
	open_carpentry(farm)
static func complete_construction(farm) -> void:
	var job: Dictionary = farm.interior_progress.get("construction",{})
	if job.is_empty() or farm.day <= int(job.get("day",farm.day)): return
	match job.kind:
		"land":
			farm.interior_progress.restoration = int(job.level)
			add_plots(farm,int(job.level))
		"home":
			farm.interior_progress.home = int(job.level)
			farm.interior.apply_upgrade(int(job.level))
		"barn": farm.BarnLife.state(farm).level = int(job.level)
		"irrigation": farm.resources.state().irrigation = int(job.level)
		"second_story", "greenhouse": farm.interior_progress[job.kind] = true
	farm.interior_progress.erase("construction")
	farm.resources.irrigate()
	farm.resources.queue_redraw()
	farm.polish.grids.clear()
	farm.farmhouse.queue_redraw()
	farm.interior.queue_redraw()
	farm.queue_redraw()
static func cook(farm) -> void:
	if int(farm.interior_progress.get("home",0)) < 2: return
	var count := 0
	for item in farm.produce: count += int(farm.produce[item])
	if count < 2:
		farm.say("Cooking needs two vegetables in your backpack.")
		return
	if farm.health >= 100:
		farm.say("You're already rested. Save your ingredients for later.")
		return
	var left := 2
	for item in farm.produce:
		var take := mini(left,int(farm.produce[item]))
		farm.produce[item] -= take
		left -= take
	farm.health = minf(100,farm.health+25)
	farm.say("A warm vegetable meal! +25 Health.")
	farm.save_game(false)

static func festival_game(farm, round_index: int = 0) -> void:
	if not farm.festival_active: return
	farm.close_dialogue()
	var column = farm.make_modal("Spring tea challenge")
	var questions := ["Which leaves make the best tea?","What should you do before packing tea?","What helps a tea bush after picking?"]
	var choices := [["Tender young leaves","Old woody stems"],["Sort and dry the leaves","Pack wet leaves immediately"],["Give it time to rest","Pick it again immediately"]]
	farm.dialogue_text.text = "Round %d / 3: %s" % [round_index+1,questions[round_index]]
	for i in range(2): column.add_child(farm.make_button(choices[round_index][i],festival_answer.bind(farm,round_index,i == 0)))
	column.add_child(farm.make_button("Back to gathering",farm.close_dialogue))
static func festival_answer(farm, round_index: int, correct: bool) -> void:
	if not correct:
		farm.dialogue_text.text = "Not quite. Think about Sachiko's tea-growing advice and try again."
		return
	if round_index < 2:
		festival_game(farm,round_index+1)
		return
	var year := int((farm.day-1)/112)+1
	var winners: Array = farm.interior_progress.get("tea_challenge_years",[])
	var reward: bool = farm.scheduled_gathering and not winners.has(year)
	if reward:
		winners.append(year)
		farm.interior_progress["tea_challenge_years"] = winners
		farm.coins += 50
		farm.save_game(false)
	VolunteerRequests.complete(farm,SeasonalFestivals.today(farm.day))
	farm.close_dialogue()
	farm.say("Tea challenge complete! ¥50 prize." if reward else "Tea challenge complete! Rehearsal and repeat rounds have no cash prize.")
