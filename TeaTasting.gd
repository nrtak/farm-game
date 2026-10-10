extends RefCounted
const GUESTS := ["Mika", "Naomi", "Sachiko", "Chanel", "Haruka", "Emi"]
const BLENDS := ["Fresh green", "Roasted", "Strong green"]
const BREWS := ["Cool water · short steep", "Hot water · short steep", "Hot water · long steep"]
const PREFERENCES := [0,1,0,1,2,2]
static func available(farm) -> bool:
	return farm.location=="shop" and farm.shop_name=="Tea Processing Shed"
static func guest_index(farm) -> int:
	return posmod(farm.day-1,GUESTS.size())
static func open(farm) -> void:
	if not available(farm): return
	farm.close_dialogue()
	var column=farm.make_modal("Tea tasting")
	fit_choices(farm)
	var guest:String=GUESTS[guest_index(farm)]
	if int(farm.interior_progress.get("tasting_day",-1))==farm.day:
		farm.dialogue_text.text="Today's tasting is finished. A new guest visits tomorrow.\n"+str(farm.interior_progress.get("tasting_result",""))
	else:
		farm.dialogue_text.text="%s is joining today's tasting. Choose a blend, then how to brew it. Serving costs 1 handful of fresh leaves. You can cancel before serving.\nLeaves: %d · One tasting per day."%[guest,farm.tea_leaves]
		for i in range(BLENDS.size()):
			column.add_child(farm.make_button(BLENDS[i],choose_brew.bind(farm,i)))
	column.add_child(farm.make_button("Close",farm.close_dialogue))
static func choose_brew(farm, blend:int) -> void:
	if not available(farm) or blend<0 or blend>=BLENDS.size(): return
	farm.close_dialogue()
	var column=farm.make_modal("Brew "+BLENDS[blend])
	fit_choices(farm)
	farm.dialogue_text.text="Green tea stays gentle with cooler water. Roasted leaves suit hot water and a short steep. A longer steep makes a stronger cup. Choose your method; nothing is spent yet."
	for i in range(BREWS.size()): column.add_child(farm.make_button(BREWS[i],confirm.bind(farm,blend,i)))
	column.add_child(farm.make_button("Back",open.bind(farm)))
static func confirm(farm, blend:int, brew:int) -> void:
	if not available(farm): return
	farm.close_dialogue()
	var column=farm.make_modal("Ready to serve")
	farm.dialogue_text.text="%s\n%s\nServe to %s for 1 handful of leaves. A thoughtful brew earns a little more friendship and payment."%[BLENDS[blend],BREWS[brew],GUESTS[guest_index(farm)]]
	column.add_child(farm.make_button("Serve · 1 leaf",serve.bind(farm,blend,brew)))
	column.add_child(farm.make_button("Change brew",choose_brew.bind(farm,blend)))
	column.add_child(farm.make_button("Cancel",farm.close_dialogue))
static func serve(farm, blend:int, brew:int) -> void:
	if not available(farm) or blend<0 or blend>=3 or brew<0 or brew>=3: return
	if int(farm.interior_progress.get("tasting_day",-1))==farm.day: return
	if farm.tea_leaves<1:
		farm.dialogue_text.text="You need one handful of fresh tea leaves. Pick some in the tea fields and come back. Nothing has been spent."
		return
	var index:int=guest_index(farm)
	var guest:String=GUESTS[index]
	var well_brewed:bool=blend==brew
	var favorite:bool=blend==PREFERENCES[index]
	var payment:int=10+(10 if well_brewed else 0)+(5 if favorite else 0)
	var friendship:int=1+(1 if well_brewed else 0)+(1 if favorite else 0)
	farm.tea_leaves-=1
	farm.coins+=payment
	farm.friendship[guest]=mini(100,int(farm.friendship.get(guest,0))+friendship)
	farm.interior_progress["tasting_day"]=farm.day
	var response:String="The flavor is balanced. Thank you for brewing this for me!" if well_brewed else "Thank you! Try matching the water and steeping time to the leaves next time."
	if favorite: response+=" This is my favorite blend."
	var result:String=response+"\n¥%d earned · Friendship +%d"%[payment,friendship]
	farm.interior_progress["tasting_result"]=result
	farm.interior_progress["tastings"]=int(farm.interior_progress.get("tastings",0))+1
	var notes:Dictionary=farm.interior_progress.get("tasting_notes",{})
	if favorite: notes[guest]=BLENDS[blend]
	farm.interior_progress["tasting_notes"]=notes
	farm.save_game(false)
	farm.refresh_hud()
	farm.close_dialogue()
	var column=farm.make_modal(guest,true)
	farm.dialogue_text.text=result
	var cup=preload("res://TeaCup.gd").new()
	cup.brew=blend
	column.add_child(cup)
	column.add_child(farm.make_button("Finish tasting",farm.close_dialogue))
static func notebook(farm) -> void:
	if not available(farm): return
	farm.close_dialogue()
	var column=farm.make_modal("Tasting notebook")
	var notes:Dictionary=farm.interior_progress.get("tasting_notes",{})
	var lines:Array[String]=["Tastings completed: %d · Favorites discovered: %d / %d"%[int(farm.interior_progress.get("tastings",0)),notes.size(),GUESTS.size()]]
	for guest in GUESTS: lines.append(guest+": "+str(notes.get(guest,"Not discovered yet")))
	farm.dialogue_text.text="\n".join(lines)
	farm.dialogue_text.add_theme_font_size_override("font_size",18)
	column.add_child(farm.make_button("Close notebook",farm.close_dialogue))
static func fit_choices(farm) -> void:
	farm.dialogue_panel.get_child(0).offset_top=-minf(430,farm.get_viewport_rect().size.y-36)
	farm.dialogue_text.add_theme_font_size_override("font_size",20)
