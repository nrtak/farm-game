extends RefCounted
static func draw_details(room) -> void:
	var wood := Color("765a40")
	var sage := Color("8c9f83")
	var cream := Color("e6d5ad")
	# Curtains, reception carpet, and a plant frame the room without filling the aisle.
	for x in [212,802]:
		room.draw_rect(Rect2(x,97,12,64),sage)
		room.draw_rect(Rect2(x+92,97,12,64),sage)
	var rug := StyleBoxFlat.new()
	rug.bg_color = Color("a9ae88")
	rug.border_color = cream
	rug.set_border_width_all(3)
	rug.set_corner_radius_all(8)
	room.draw_style_box(rug,Rect2(440,650,220,85))
	for x in [340,770]:
		room.draw_rect(Rect2(x,165,26,22),Color("a98059"))
		for dx in [-9,0,9]: room.draw_circle(Vector2(x+13+dx,157-abs(dx)),11,sage)
	if room.kind in ["General Store","Inn","Blacksmith","Café","Clinic","Carpentry","Mountain Carpentry"]: return
	if room.kind == "Onsen Resort":
		for y in [235,290,345]:
			room.furnishing(Rect2(155,y,140,40),wood)
			for x in [173,216,258]: room.draw_rect(Rect2(x,y+8,24,18),cream)
		room.room_label("Changing lockers",Vector2(135,450))
		room.furnishing(Rect2(160,575,145,55),cream)
		room.room_label("Rinse & towels",Vector2(135,675))
		var bath := StyleBoxFlat.new()
		bath.bg_color = Color("81b3b2")
		bath.border_color = Color("8a8c7b")
		bath.set_border_width_all(12)
		bath.set_corner_radius_all(28)
		room.draw_style_box(bath,Rect2(790,425,175,210))
		for y in [470,530,585]: room.draw_arc(Vector2(870,y),32,0.1,2.8,16,Color("bed5c8"),2)
		room.room_label("Hot spring",Vector2(795,690))
		return
	match room.kind:
		"Town Hall":
			room.draw_rect(Rect2(180,245,100,95),cream)
			for y in [260,282,305]: room.draw_line(Vector2(195,y),Vector2(264,y),sage,3)
			room.room_label("Village planning",Vector2(135,425))
			books(room,Vector2(815,230),3)
		"Police Box":
			room.draw_rect(Rect2(185,250,90,80),Color("b2bcb0"))
			room.draw_line(Vector2(197,275),Vector2(265,320),cream,5)
			for x in [820,860,900]: room.draw_rect(Rect2(x,250,28,52),cream)
			room.room_label("Patrol maps & radio",Vector2(130,430))
		"Fire Station":
			for x in [825,865,905]:
				room.draw_circle(Vector2(x,265),16,Color("b88465"))
				room.draw_rect(Rect2(x-10,290,20,70),sage)
			room.draw_arc(Vector2(230,290),39,0,TAU,24,wood,10)
			room.room_label("Hose station",Vector2(140,430))
		"Archive":
			books(room,Vector2(170,235),2)
			books(room,Vector2(815,230),3)
			room.draw_rect(Rect2(195,585,100,25),cream)
			room.draw_line(Vector2(245,585),Vector2(245,610),wood,2)
		"Shrine Residence":
			room.draw_rect(Rect2(183,250,105,90),sage)
			room.draw_circle(Vector2(234,275),18,cream)
			for x in [830,875,920]: room.draw_circle(Vector2(x,265),12,cream)
			room.room_label("Festival supplies",Vector2(785,455))
		"Mountain Lodge":
			room.draw_colored_polygon(PackedVector2Array([Vector2(180,335),Vector2(223,260),Vector2(278,335)]),sage)
			books(room,Vector2(815,230),2)
			room.room_label("Trail guides",Vector2(790,465))
		"Tea Farmhouse","Harbor Homes","Hiro Cabin":
			for x in [150,820]:
				room.draw_rect(Rect2(x,220,135,165),cream)
				room.draw_rect(Rect2(x+15,230,105,35),Color("f0e4c8"))
				room.draw_rect(Rect2(x+8,280,119,95),sage)
			room.draw_circle(Vector2(240,585),16,cream)
			if room.kind == "Hiro Cabin": books(room,Vector2(820,220),2)
		"Tea Processing Shed":
			for x in [185,220,255]: room.draw_circle(Vector2(x,285),14,sage)
			for y in [245,305,365]: room.draw_line(Vector2(815,y+17),Vector2(935,y+17),cream,3)
			room.draw_rect(Rect2(190,578,115,35),cream)
		"Fishing Shop":
			room.draw_arc(Vector2(230,290),40,0,TAU,24,wood,5)
			for y in [270,290,310]: room.draw_line(Vector2(192,y),Vector2(265,y),cream,2)
			room.draw_rect(Rect2(192,578,100,30),sage)
static func books(room,where: Vector2,rows: int) -> void:
	for row in range(rows):
		for column in range(6):
			room.draw_rect(Rect2(where+Vector2(column*19,row*52),Vector2(13,32)),[Color("81977f"),Color("c3a17b"),Color("d8c9a5")][column%3])
		room.draw_line(where+Vector2(0,row*52+35),where+Vector2(118,row*52+35),Color("765a40"),5)
