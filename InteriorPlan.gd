extends RefCounted
const ROOMS := ["Shrine Residence","Tea Farmhouse","Harbor Homes","Mountain Lodge","Hiro Cabin"]
static func furnishings(kind: String) -> Array[Rect2]:
	match kind:
		"Shrine Residence": return [Rect2(140,235,200,85),Rect2(780,235,180,150),Rect2(170,520,190,110)]
		"Tea Farmhouse": return [Rect2(140,225,220,110),Rect2(790,225,170,230),Rect2(150,520,205,120)]
		"Harbor Homes": return [Rect2(140,230,180,210),Rect2(795,230,165,130),Rect2(780,520,180,130)]
		"Mountain Lodge": return [Rect2(140,230,210,130),Rect2(790,230,170,220),Rect2(150,560,200,70)]
		_: return [Rect2(140,230,170,220),Rect2(790,230,170,140),Rect2(780,530,180,110)]
static func draw_room(room) -> void:
	var traditional: bool=room.kind in ["Shrine Residence","Tea Farmhouse"]
	room.draw_rect(Rect2(Vector2.ZERO,room.SIZE),Color("33473d"))
	room.draw_rect(Rect2(90,70,920,740),Color("72543d"))
	room.draw_rect(Rect2(110,90,880,95),Color("e3d6b7"))
	room.draw_rect(Rect2(110,185,880,605),Color("b0b789") if traditional else Color("b99a70"))
	for y in range(195,790,100 if traditional else 45):
		room.draw_line(Vector2(110,y),Vector2(990,y),Color("8b906c") if traditional else Color("a18460"),3)
	if traditional:
		for x in range(110,990,220): room.draw_line(Vector2(x,185),Vector2(x,790),Color("8b906c"),3)
	for x in [160,770]:
		room.draw_rect(Rect2(x,100,165,70),Color("f0e6cb") if traditional else Color("a7c6bb"))
		for dx in range(0,166,33): room.draw_line(Vector2(x+dx,100),Vector2(x+dx,170),Color("72543d"),3)
		room.draw_line(Vector2(x,135),Vector2(x+165,135),Color("72543d"),3)
	for rect in room.solids:
		room.draw_rect(rect,Color("72543d"))
		room.draw_rect(rect.grow(-6),Color("a78259"))
	var decor=preload("res://InteriorDecor.gd")
	match room.kind:
		"Shrine Residence":
			room.draw_rect(Rect2(195,98,95,75),Color("d8c8a7"))
			room.draw_circle(Vector2(242,125),16,Color("b87259"))
			decor.cup(room,Vector2(220,565)); decor.cup(room,Vector2(300,565))
			decor.folded_towels(room,Vector2(820,285))
			for x in [175,220,265]: room.draw_rect(Rect2(x,255,30,40),Color("e7d5b5"))
		"Tea Farmhouse":
			for y in [265,325,385]:
				for x in [820,870,920]: decor.bottle(room,Vector2(x,y))
			for x in [185,240,300]: decor.cup(room,Vector2(x,570))
			for x in [185,240,295]: room.draw_circle(Vector2(x,275),18,Color("68845b"))
		"Harbor Homes":
			room.draw_rect(Rect2(155,245,150,175),Color("8caab1")); room.draw_rect(Rect2(165,255,130,40),Color("eadfc4"))
			for x in range(810,950,20): room.draw_line(Vector2(x,245),Vector2(x,345),Color("d4c69f"),2)
			for y in range(250,345,20): room.draw_line(Vector2(805,y),Vector2(950,y),Color("d4c69f"),2)
			decor.crate(room,Rect2(810,555,120,65))
		"Mountain Lodge":
			room.draw_rect(Rect2(180,105,120,60),Color("94a68a"))
			decor.folded_towels(room,Vector2(835,295)); decor.folded_towels(room,Vector2(835,385))
			decor.cup(room,Vector2(220,275))
		"Hiro Cabin":
			room.draw_rect(Rect2(155,245,140,185),Color("879b83")); room.draw_rect(Rect2(165,255,120,40),Color("eadfc4"))
			room.draw_rect(Rect2(810,250,115,75),Color("c5cfa8")); decor.bottle(room,Vector2(830,560)); decor.bottle(room,Vector2(875,560))
	room.draw_rect(Rect2(445,690,210,100),Color("89957c"))
