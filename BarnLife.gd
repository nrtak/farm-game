extends RefCounted
const SPECIES := {"Cow":{"price":500,"product":"Milk","nights":1},"Sheep":{"price":400,"product":"Wool","nights":3},"Goat":{"price":350,"product":"Goat milk","nights":1},"Chicken":{"price":100,"product":"Egg","nights":1}}
const PRICES := {"Milk":35,"Wool":65,"Goat milk":30,"Egg":15}
static var art: Texture2D
static var art_regions: Array[Rect2] = []
static func state(farm) -> Dictionary:
	if not farm.interior_progress.get("barn") is Dictionary:
		farm.interior_progress.barn = {"animals":[],"feed":10,"products":{},"shipping":{},"level":0,"settled":farm.day}
	var data: Dictionary = farm.interior_progress.barn
	for key in ["products","shipping"]:
		if not data.get(key) is Dictionary: data[key] = {}
		for item in PRICES: data[key][item] = clampi(int(data[key].get(item,0)),0,999)
	if not data.get("animals") is Array: data.animals = []
	data.feed = clampi(int(data.get("feed",10)),0,999)
	data.level = clampi(int(data.get("level",0)),0,2)
	return data
static func capacity(farm) -> int: return 4+int(state(farm).level)*2
static func animal_point(index: int) -> Vector2:
	return Vector2(270 if index%2 == 0 else 830,300+int(index/2)*110)
static func open_care(farm) -> void:
	var data := state(farm)
	var point: Vector2 = farm.player.position-farm.SHOP_ORIGIN
	var nearest := -1
	var distance := 165.0
	for i in range(data.animals.size()):
		var d := point.distance_to(animal_point(i))
		if d<distance: distance=d; nearest=i
	if nearest < 0: open_manager(farm); return
	open_animal(farm,nearest)
static func open_manager(farm) -> void:
	farm.close_dialogue()
	var data := state(farm)
	var column = farm.make_modal("Barn animals & supplies")
	farm.dialogue_panel.get_child(0).offset_top = -minf(440,farm.get_viewport_rect().size.y-32)
	farm.dialogue_text.text = "Animals: %d / %d · Feed: %d\nFeed daily. Collect milk and eggs the next morning; wool after three fed nights." % [data.animals.size(),capacity(farm),data.feed]
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0,150)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(scroll)
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(list)
	for species in SPECIES: list.add_child(farm.make_button("Buy %s · ¥%d" % [species,SPECIES[species].price],purchase.bind(farm,species)))
	list.add_child(farm.make_button("Buy 10 feed · ¥30",buy_feed.bind(farm)))
	column.add_child(farm.make_button("Close",farm.close_dialogue))
static func purchase(farm, species: String) -> void:
	if farm.location != "shop" or farm.shop_name != "Barn" or not SPECIES.has(species): return
	var data := state(farm)
	if data.animals.size() >= capacity(farm): farm.dialogue_text.text = "The barn is full. Visit Kenta for more stalls."; return
	if farm.coins < SPECIES[species].price: farm.dialogue_text.text = "Not enough money for this animal."; return
	farm.coins -= SPECIES[species].price
	data.animals.append({"species":species,"fed":-1,"petted":-1,"affection":0,"nights":0,"ready":0,"settled":farm.day})
	farm.shops.Barn.queue_redraw()
	farm.save_game(false)
	open_manager(farm)
static func buy_feed(farm) -> void:
	if farm.coins < 30: farm.dialogue_text.text = "Feed costs ¥30."; return
	if state(farm).feed > 989: return
	farm.coins -= 30
	state(farm).feed += 10
	farm.save_game(false)
	open_manager(farm)
static func open_animal(farm, index: int) -> void:
	var data := state(farm)
	if index<0 or index>=data.animals.size(): return
	farm.close_dialogue()
	var animal: Dictionary = data.animals[index]
	var column = farm.make_modal("%s · Stall %d" % [animal.species,index+1])
	farm.dialogue_panel.get_child(0).offset_top = -minf(410,farm.get_viewport_rect().size.y-32)
	farm.dialogue_text.text = "%s today · Affection %d · %s ready: %d" % ["Fed" if animal.fed == farm.day else "Needs feed",animal.affection,SPECIES[animal.species].product,animal.ready]
	column.add_child(farm.make_button("Feed",care.bind(farm,index,"feed")))
	column.add_child(farm.make_button("Pet",care.bind(farm,index,"pet")))
	column.add_child(farm.make_button("Collect %s" % SPECIES[animal.species].product,care.bind(farm,index,"collect")))
	column.add_child(farm.make_button("Close",farm.close_dialogue))
static func care(farm,index: int,kind: String) -> void:
	var data := state(farm)
	if index<0 or index>=data.animals.size(): return
	var animal: Dictionary = data.animals[index]
	if kind == "feed":
		if animal.fed == farm.day: farm.dialogue_text.text = "Already fed today."; return
		if data.feed <= 0: farm.dialogue_text.text = "Buy more feed at the barn supplies desk."; return
		data.feed -= 1
		animal.fed = farm.day
	elif kind == "pet":
		if animal.petted == farm.day: farm.dialogue_text.text = "Already petted today. Your animal is content."; return
		animal.petted = farm.day
		animal.affection = mini(100,int(animal.affection)+1)
		farm.close_dialogue()
		farm.resources.play("pet",farm.SHOP_ORIGIN+animal_point(index))
		farm.say("Your %s enjoys the attention." % animal.species.to_lower())
		farm.save_game(false)
		return
	elif kind == "collect":
		if animal.ready <= 0: farm.dialogue_text.text = "No product ready. Feed your animal and return after sleeping."; return
		if not farm.backpack_has_room(): farm.dialogue_text.text = "Your backpack is full. Ship some items first."; return
		var product: String = SPECIES[animal.species].product
		animal.ready -= 1
		data.products[product] += 1
		farm.close_dialogue()
		farm.show_item_moment(product)
		farm.say("Collected %s. Ship it from the farm." % product)
		farm.save_game(false)
		return
	farm.save_game(false)
	open_animal(farm,index)
static func product_count(farm) -> int:
	var total := 0
	for count in state(farm).products.values(): total += int(count)
	return total
static func shipping_value(farm) -> int:
	var total := 0
	for product in PRICES: total += int(state(farm).shipping[product])*PRICES[product]
	return total
static func ship(farm) -> void:
	var data := state(farm)
	for product in PRICES:
		data.shipping[product] += data.products[product]
		data.products[product] = 0
static func new_day(farm) -> void:
	var data := state(farm)
	if int(data.get("settled",farm.day)) >= farm.day: return
	farm.coins += shipping_value(farm)
	for product in PRICES: data.shipping[product] = 0
	for animal in data.animals:
		if int(animal.get("settled",farm.day)) >= farm.day: continue
		if animal.fed == farm.day-1:
			animal.nights += 1
			if animal.nights >= SPECIES[animal.species].nights:
				animal.ready = mini(9,int(animal.ready)+1)
				animal.nights = 0
		animal.settled = farm.day
	data.settled = farm.day
static func draw_room(room) -> void:
	var farm = room.get_parent()
	var data := state(farm)
	room.draw_rect(Rect2(Vector2.ZERO,room.SIZE),Color("344438"))
	room.draw_rect(Rect2(90,70,920,740),Color("76583d"))
	room.draw_rect(Rect2(110,170,880,620),Color("c4ab7e"))
	for y in range(180,790,40): room.draw_line(Vector2(110,y),Vector2(990,y),Color("af966b"),2)
	for i in range(8):
		var p := animal_point(i)
		room.draw_rect(Rect2(p-Vector2(110,50),Vector2(220,95)),Color("ceb478"))
		for dx in [-110,110]: room.draw_line(p+Vector2(dx,-50),p+Vector2(dx,45),Color("85643e"),8)
		room.draw_line(p-Vector2(110,50),p+Vector2(110,-50),Color("85643e"),8)
		# Straw bedding and troughs sit inside the solid stalls.
		for dx in [-75,-30,20,65]:
			room.draw_line(p+Vector2(dx,17),p+Vector2(dx+14,22),Color("b49354"),3)
		room.draw_rect(Rect2(p+Vector2(65,-40),Vector2(35,18)),Color("8d7450"))
		room.draw_rect(Rect2(p+Vector2(69,-36),Vector2(27,10)),Color("849c96"))
		if i >= capacity(farm): room.draw_string(ThemeDB.fallback_font,p-Vector2(40,0),"Expand",HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("76583d")); continue
		if i>=data.animals.size(): continue
		var animal: Dictionary = data.animals[i]
		if art == null and ResourceLoader.exists("res://assets/characters/barn-animals-v1.png"):
			art=load("res://assets/characters/barn-animals-v1.png")
			var image := preload("res://RuntimeArt.gd").readable_image(art)
			var cell_size := Vector2(art.get_size())/Vector2(4,1) if art!=null else Vector2.ONE
			for column in range(4):
				var bounds := Rect2i(Vector2i.ZERO,Vector2i(cell_size))
				if image!=null: bounds=image.get_region(Rect2i(Vector2i(column*cell_size.x,0),Vector2i(cell_size))).get_used_rect()
				art_regions.append(Rect2(bounds.position+Vector2i(column*cell_size.x,0),bounds.size))
		if art != null:
			var species_index: int = SPECIES.keys().find(animal.species)
			var region := art_regions[species_index]
			var size := region.size*(95.0/region.size.y)
			room.draw_texture_rect_region(art,Rect2(p-Vector2(size.x/2,size.y-12),size),region)
		room.draw_string(ThemeDB.fallback_font,p+Vector2(-45,35),animal.species,HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("584631"))
		if animal.ready>0: room.draw_circle(p+Vector2(70,-20),7,Color("f3df9d"))
	room.draw_rect(Rect2(420,185,260,75),Color("92714d"))
	preload("res://InteriorDecor.gd").crate(room,Rect2(438,191,50,26))
	room.draw_rect(Rect2(612,192,45,24),Color("e6d5ad"))
	room.draw_string(ThemeDB.fallback_font,Vector2(438,230),"Animals & feed",HORIZONTAL_ALIGNMENT_LEFT,-1,24,Color("f4e3bb"))
	room.draw_string(ThemeDB.fallback_font,Vector2(460,780),"Exit ↓",HORIZONTAL_ALIGNMENT_LEFT,-1,24,Color("584631"))
