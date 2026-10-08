extends RefCounted
# Static decoration is submitted once; ore overlays redraw only when mined.
static func stone(room, p:Vector2, size:Vector2, color:Color) -> void:
	var shape:=PackedVector2Array([p+Vector2(-size.x*.5,size.y*.25),p+Vector2(-size.x*.4,-size.y*.25),p+Vector2(-size.x*.12,-size.y*.5),p+Vector2(size.x*.35,-size.y*.4),p+size*.5,p+Vector2(size.x*.25,size.y*.5)])
	room.draw_colored_polygon(shape,color)
	room.draw_line(shape[1],shape[2],color.lightened(.22),3)
	room.draw_line(shape[2],shape[3],color.lightened(.22),3)
	room.draw_line(p+Vector2(-4,-size.y*.3),p+Vector2(9,size.y*.28),color.darkened(.18),2)
static func draw_room(room) -> void:
	room.draw_rect(Rect2(Vector2.ZERO,room.SIZE),Color("282d30"))
	room.draw_rect(Rect2(90,70,920,740),Color("535651"))
	room.draw_rect(Rect2(110,170,880,620),Color("b19e7b"))
	# Broad central aisle, low-contrast floor strata and inset rails.
	room.draw_rect(Rect2(435,180,230,610),Color("baa986"))
	for y in range(195,770,42):
		for x in range(145,975,67):
			var p:=Vector2(x+sin(y+x)*11,y+cos(x)*8)
			room.draw_line(p,p+Vector2(14,3),Color("a49172"),1.4)
	for y in range(225,725,34):room.draw_line(Vector2(502,y),Vector2(598,y),Color("927858"),7)
	for x in [514,586]:
		room.draw_line(Vector2(x,210),Vector2(x,725),Color("616766"),5)
		room.draw_line(Vector2(x-1,210),Vector2(x-1,725),Color("abb0a2"),1.5)
	# Layered rock face above the walking floor.
	for row in range(2):
		for i in range(12):stone(room,Vector2(125+i*77+row*13,102+row*40),Vector2(90,64),Color("626860") if i%2==0 else Color("73756a"))
	for x in [100,1000]:
		for y in range(205,785,75):stone(room,Vector2(x,y),Vector2(31,91),Color("656c64"))
	# Timber frames and warm lamps stay against the walls.
	for x in [127,953]:
		room.draw_rect(Rect2(x,176,20,595),Color("654b36"))
		room.draw_line(Vector2(x+6,182),Vector2(x+6,760),Color("aa8256"),4)
		for y in [230,455,675]:
			room.draw_circle(Vector2(x+10,y),25,Color(1,.77,.35,.08))
			room.draw_rect(Rect2(x+2,y-16,16,24),Color("413d32"))
			room.draw_rect(Rect2(x+5,y-12,10,16),Color("f3d88d"))
	room.draw_rect(Rect2(127,171,846,17),Color("805d3d"))
	# Wall seams distinguish copper and iron without obscuring mineable rocks.
	for x in [290,785]:
		for i in range(4):stone(room,Vector2(x+i*12,135+sin(i*2)*9),Vector2(14,12),Color("c58d5e") if x==290 else Color("c4d1cd"))
	# An old cart is tucked into the back wall, clear of the main aisle.
	room.draw_rect(Rect2(422,106,100,47),Color("6a7571"))
	room.draw_rect(Rect2(428,111,88,27),Color("394540"))
	for x in [440,503]:room.draw_circle(Vector2(x,157),9,Color("303c38"))
	for x in [445,465,490]:stone(room,Vector2(x,119),Vector2(26,20),Color("8f968b"))
	for i in range(room.solids.size()):
		var rect:Rect2=room.solids[i]
		var p:=rect.get_center()
		if room.depleted[i]:
			for j in range(5):stone(room,p+Vector2(-34+j*17,12+sin(j)*6),Vector2(18,13),Color("827e6c"))
		else:
			stone(room,p,rect.size,Color("777f78"))
			for j in range(3):stone(room,p+Vector2(-23+j*22,-4+sin(j*2)*9),Vector2(22,20),Color("ca9167") if i%2==0 else Color("c6d4d0"))
	room.draw_rect(Rect2(446,744,208,46),Color("d0bb8d"))
	room.draw_string(ThemeDB.fallback_font,Vector2(455,777),"Daylight · Exit ↓",HORIZONTAL_ALIGNMENT_CENTER,190,23,Color("514b3b"))
