extends RefCounted
# Small, readable props stay on existing solid furnishings, never in the aisle.
const WOOD := Color("72543d")
const CREAM := Color("eadfc4")
const SAGE := Color("889b82")
const SLATE := Color("687d7b")
static func cup(room,p: Vector2) -> void:
	room.draw_circle(p,10,CREAM)
	room.draw_circle(p,6,WOOD)
	room.draw_arc(p+Vector2(10,0),5,-1.3,1.3,8,CREAM,3)
static func bottle(room,p: Vector2) -> void:
	room.draw_rect(Rect2(p,Vector2(16,25)),SLATE)
	room.draw_rect(Rect2(p+Vector2(4,-6),Vector2(8,7)),WOOD)
	room.draw_rect(Rect2(p+Vector2(2,8),Vector2(12,8)),CREAM)
static func drawer(room,rect: Rect2) -> void:
	room.draw_rect(rect,WOOD,false,3)
	room.draw_line(rect.get_center()-Vector2(8,0),rect.get_center()+Vector2(8,0),CREAM,3)
static func clock(room,p: Vector2) -> void:
	room.draw_circle(p,22,WOOD)
	room.draw_circle(p,18,CREAM)
	room.draw_line(p,p+Vector2(0,-11),WOOD,3)
	room.draw_line(p,p+Vector2(10,4),WOOD,3)
static func folded_towels(room,p: Vector2) -> void:
	for i in range(3):
		room.draw_rect(Rect2(p+Vector2(3*i,-7*i),Vector2(50,13)),CREAM)
		room.draw_line(p+Vector2(8+3*i,3-7*i),p+Vector2(42+3*i,3-7*i),SAGE,2)
static func crate(room,rect: Rect2) -> void:
	room.draw_rect(rect,Color("ad8b5e"))
	room.draw_rect(rect,WOOD,false,4)
	for x in range(int(rect.position.x)+16,int(rect.end.x),20): room.draw_line(Vector2(x,rect.position.y),Vector2(x,rect.end.y),WOOD,2)
static func draw_service(room) -> void:
	clock(room,Vector2(550,125))
	# A ledger, tea cup and cash drawer make the reception counter recognizable.
	room.draw_rect(Rect2(390,243,65,40),CREAM)
	room.draw_line(Vector2(423,243),Vector2(423,283),WOOD,2)
	for y in [251,261,271]: room.draw_line(Vector2(432,y),Vector2(448,y),SAGE,2)
	cup(room,Vector2(705,260))
	drawer(room,Rect2(475,286,115,20))
	match room.kind:
		"General Store":
			for x in [175,220,260]:
				room.draw_circle(Vector2(x,585),12,SAGE)
				room.draw_line(Vector2(x,574),Vector2(x+4,565),WOOD,3)
			for x in [850,895,938]: bottle(room,Vector2(x,370))
			for x in [835,900]: crate(room,Rect2(x,580,45,50))
		"Café":
			for x in [220,870]:
				for y in [490,685]:
					room.draw_circle(Vector2(x,y),20,CREAM)
					room.draw_colored_polygon(PackedVector2Array([Vector2(x-12,y-8),Vector2(x+13,y-8),Vector2(x,y+10)]),Color("bf9a6c"))
					cup(room,Vector2(x+40,y-8))
			for x in [845,895,940]: room.draw_circle(Vector2(x,275),8,Color("bf9a6c"))
			room.draw_rect(Rect2(162,240,60,43),SLATE)
			for x in [177,206]: room.draw_circle(Vector2(x,261),9,WOOD)
		"Inn":
			for x in [155,825]:
				folded_towels(room,Vector2(x+15,375))
				drawer(room,Rect2(x,365,125,23))
			cup(room,Vector2(268,578))
			room.draw_rect(Rect2(840,552,80,27),CREAM)
			room.draw_line(Vector2(880,552),Vector2(880,579),WOOD,2)
		"Clinic":
			for x in [163,207,253]: bottle(room,Vector2(x,245))
			folded_towels(room,Vector2(845,604))
			room.draw_rect(Rect2(830,315,130,8),CREAM)
			for x in [170,220,270]: room.draw_line(Vector2(x,565),Vector2(x,604),WOOD,3)
		"Blacksmith":
			for x in [842,903]:
				room.draw_rect(Rect2(x,580,38,13),SLATE)
				room.draw_rect(Rect2(x+3,562,32,13),Color("92a29a"))
			room.draw_line(Vector2(163,590),Vector2(205,570),WOOD,7)
			room.draw_rect(Rect2(183,557,30,15),SLATE)
		"Carpentry","Mountain Carpentry":
			for y in [250,310,370]:
				for x in [830,877,923]:
					room.draw_circle(Vector2(x,y),15,Color("b99b6e"))
					room.draw_circle(Vector2(x,y),8,WOOD,false,2)
			room.draw_line(Vector2(177,582),Vector2(265,582),SLATE,9)
			room.draw_line(Vector2(270,575),Vector2(290,605),WOOD,8)
			bottle(room,Vector2(300,558))
		"Onsen Resort":
			folded_towels(room,Vector2(181,602))
			folded_towels(room,Vector2(239,602))
			for y in [247,302,357]:
				for x in [193,236,278]: room.draw_circle(Vector2(x,y),3,WOOD)
		"Town Hall","Archive","Police Box":
			for x in [180,222,266]: drawer(room,Rect2(x,330,35,28))
			room.draw_rect(Rect2(197,587,72,22),CREAM)
			for x in [210,244]: room.draw_line(Vector2(x,590),Vector2(x+15,605),SAGE,2)
		"Fire Station":
			for x in [828,873,915]:
				room.draw_rect(Rect2(x-12,340,24,20),WOOD)
				room.draw_line(Vector2(x-9,322),Vector2(x+9,322),CREAM,3)
		"Tea Processing Shed":
			for y in [260,320,380]:
				for x in [834,875,916]: room.draw_circle(Vector2(x,y),11,SAGE)
			crate(room,Rect2(179,581,50,40))
			crate(room,Rect2(259,581,50,40))
		"Fishing Shop":
			for x in [190,235,280]: bottle(room,Vector2(x,595))
			for y in [245,295,345]:
				room.draw_arc(Vector2(860,y),15,0,TAU,12,CREAM,3)
		"Tea Farmhouse","Harbor Homes","Hiro Cabin","Mountain Lodge","Shrine Residence":
			cup(room,Vector2(230,594))
			folded_towels(room,Vector2(180,365))
			room.draw_rect(Rect2(260,578,48,32),CREAM)
			room.draw_line(Vector2(284,578),Vector2(284,610),WOOD,2)
static func draw_home(room) -> void:
	clock(room,Vector2(375,148))
	for x in [126,166,206]: bottle(room,Vector2(x,228))
	for x in [510,549,588]: drawer(room,Rect2(x,250,35,12))
	room.draw_rect(Rect2(307,357,47,30),CREAM)
	room.draw_line(Vector2(330,357),Vector2(330,387),WOOD,2)
	if room.home_level>0:
		for x in [948,995,1042]: drawer(room,Rect2(x,283,40,30))
	if room.home_level>1:
		room.draw_rect(Rect2(1160,380,140,31),Color("c5c1a7"))
		for x in [1180,1206]: room.draw_circle(Vector2(x,390),9,WOOD)
		room.draw_rect(Rect2(1242,380,46,25),SLATE)
		room.draw_arc(Vector2(1265,378),12,PI,TAU,10,SLATE,4)
