extends RefCounted
const GREENHOUSE_DOOR := Vector2(650,1580)
const STAIRS := Vector2(610,600)
static func greenhouse(farm) -> Array:
	if not farm.interior_progress.has("greenhouse_beds"):
		var beds: Array = []
		for row in range(3):
			for col in range(5): beds.append({"position":[300+col*120,330+row*110],"crop":"Turnip","stage":0,"growth":0,"settled":farm.day})
		farm.interior_progress.greenhouse_beds = beds
	return farm.interior_progress.greenhouse_beds
static func new_day(farm) -> void:
	if not farm.interior_progress.get("greenhouse",false): return
	for bed in greenhouse(farm):
		if int(bed.settled) >= farm.day: continue
		bed.settled = farm.day
		if bed.stage == 2:
			bed.growth += 1
			bed.stage = 3 if bed.growth >= farm.CROPS[bed.crop].days else 1
static func open_bed(farm) -> void:
	var nearest := -1
	var distance := 90.0
	var point: Vector2 = farm.player.position-farm.SHOP_ORIGIN
	for i in range(greenhouse(farm).size()):
		var bed: Dictionary = greenhouse(farm)[i]
		var d := point.distance_to(Vector2(bed.position[0],bed.position[1]))
		if d<distance: distance=d; nearest=i
	if nearest<0:
		var column = farm.make_modal("Greenhouse")
		farm.dialogue_text.text = "All seed varieties grow here year-round. Approach a growing bed. Refill water at the indoor cistern."
		column.add_child(farm.make_button("Refill watering can",refill.bind(farm)))
		column.add_child(farm.make_button("Close",farm.close_dialogue))
		return
	show_bed(farm,nearest)
static func refill(farm) -> void:
	farm.resources.state().water=24
	farm.dialogue_text.text="Watering can refilled: 24 / 24."
	farm.save_game(false)
static func show_bed(farm,index: int) -> void:
	farm.close_dialogue()
	var bed: Dictionary = greenhouse(farm)[index]
	var column = farm.make_modal("Greenhouse bed %d" % (index+1))
	farm.dialogue_panel.get_child(0).offset_top=-minf(440,farm.get_viewport_rect().size.y-32)
	farm.dialogue_text.text="%s · %s" % [bed.crop,["Empty","Needs water","Watered","Ready to harvest"][bed.stage]]
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size=Vector2(0,170)
	scroll.size_flags_vertical=Control.SIZE_EXPAND_FILL
	column.add_child(scroll)
	var list := VBoxContainer.new()
	list.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	scroll.add_child(list)
	if bed.stage == 0:
		for crop in farm.CROPS: list.add_child(farm.make_button("Plant "+crop,tend.bind(farm,index,"seed",crop)))
	elif bed.stage == 1: list.add_child(farm.make_button("Water",tend.bind(farm,index,"water","")))
	elif bed.stage == 3: list.add_child(farm.make_button("Harvest",tend.bind(farm,index,"harvest","")))
	column.add_child(farm.make_button("Close",farm.close_dialogue))
static func tend(farm,index: int,action: String,crop: String) -> void:
	var bed: Dictionary = greenhouse(farm)[index]
	if farm.health<2: farm.dialogue_text.text="Rest before working."; return
	if action=="seed" and bed.stage==0 and farm.CROPS.has(crop):
		if farm.seed_count(crop)<1: farm.dialogue_text.text="Buy these seeds at the store first."; return
		if crop=="Turnip": farm.seeds-=1
		else: farm.extra_seeds[crop]-=1
		bed.crop=crop; bed.stage=1; bed.growth=0; bed.settled=farm.day
	elif action=="water" and bed.stage==1:
		if farm.resources.state().water<=0: farm.dialogue_text.text="Refill the watering can at the cistern."; return
		farm.resources.state().water-=1; bed.stage=2
	elif action=="harvest" and bed.stage==3:
		if not farm.backpack_has_room(): farm.dialogue_text.text="Your backpack is full."; return
		farm.produce[bed.crop]+=1; farm.harvests+=1; bed.stage=0; bed.growth=0
		farm.show_item_moment(bed.crop)
	else: return
	farm.health-=2
	farm.close_dialogue()
	farm.resources.play(action,farm.SHOP_ORIGIN+Vector2(bed.position[0],bed.position[1]))
	farm.shops.Greenhouse.queue_redraw()
	farm.save_game(false)
static func draw_room(room) -> void:
	var farm=room.get_parent()
	room.draw_rect(Rect2(Vector2.ZERO,room.SIZE),Color("344438"))
	room.draw_rect(Rect2(90,70,920,740),Color("88704e"))
	room.draw_rect(Rect2(110,170,880,620),Color("ceba91"))
	if room.kind=="Greenhouse":
		for y in range(190,700,110):
			for x in [112,937]:
				room.draw_rect(Rect2(x,y,50,95),Color("a9cabb"))
				room.draw_rect(Rect2(x,y,50,95),Color("6c8274"),false,5)
		for x in range(120,990,110):
			room.draw_rect(Rect2(x,90,95,65),Color("add1c4"))
			room.draw_rect(Rect2(x,90,95,65),Color("6b8274"),false,5)
		for bed in greenhouse(farm):
			var p:=Vector2(bed.position[0],bed.position[1])
			room.draw_rect(Rect2(p-Vector2(43,36),Vector2(86,72)),Color("93704a"))
			if bed.stage>0:
				room.draw_line(p+Vector2(0,15),p-Vector2(0,20),Color("667f4e"),6)
				for dx in [-12,12]: room.draw_circle(p+Vector2(dx,-7),11,Color("819b60"))
				if bed.stage==3: room.draw_circle(p+Vector2(0,9),12,Color(farm.CROPS[bed.crop].color))
		room.draw_rect(Rect2(150,210,95,45),Color("7b9f9f"))
		room.draw_string(ThemeDB.fallback_font,Vector2(160,240),"Water",HORIZONTAL_ALIGNMENT_LEFT,-1,20,Color("e9e4cc"))
	else:
		for x in [170,710]:
			room.draw_rect(Rect2(x,220,150,200),Color("876747"))
			room.draw_rect(Rect2(x+8,265,134,140),Color("91a993"))
			room.draw_rect(Rect2(x+20,235,110,35),Color("e9dfc4"))
		room.draw_rect(Rect2(420,280,260,130),Color("997651"))
		room.draw_circle(Vector2(550,335),35,Color("d8c39a"))
		room.draw_string(ThemeDB.fallback_font,Vector2(420,500),"Upstairs family rooms",HORIZONTAL_ALIGNMENT_LEFT,-1,24,Color("584631"))
	room.draw_string(ThemeDB.fallback_font,Vector2(475,780),"Exit ↓",HORIZONTAL_ALIGNMENT_LEFT,-1,24,Color("584631"))
