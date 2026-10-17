extends RefCounted
const ROUTES:={
"town":[[Vector2(495,1260),Vector2(495,1350)],[Vector2(2105,560),Vector2(2105,800)],[Vector2(330,805),Vector2(1100,805)],[Vector2(1100,940),Vector2(1650,940)],[Vector2(500,1350),Vector2(2080,1350)]],
"mountain":[[Vector2(960,1090),Vector2(960,760)],[Vector2(830,1080),Vector2(830,540)],[Vector2(600,550),Vector2(1240,550)],[Vector2(830,760),Vector2(1450,760)]],
"tea":[[Vector2(70,675),Vector2(1520,675)],[Vector2(1280,675),Vector2(1280,350)],[Vector2(860,720),Vector2(860,1040)],[Vector2(1333,720),Vector2(1333,1010)]],
"harbor":[[Vector2(500,660),Vector2(1540,660)],[Vector2(660,430),Vector2(660,660)],[Vector2(1080,430),Vector2(1080,660)],[Vector2(1480,585),Vector2(1480,660)]],
"historic":[[Vector2(1050,700),Vector2(1050,540)],[Vector2(406,363),Vector2(406,700)],[Vector2(406,700),Vector2(1460,700)],[Vector2(1460,700),Vector2(1460,1100)],[Vector2(1460,1100),Vector2(1550,1100)]],
"farm":[[Vector2(1485,240),Vector2(1485,530)],[Vector2(1485,530),Vector2(2400,530)],[Vector2(850,700),Vector2(850,1430)]]}
static func clearances(kind: String) -> Array[Rect2]:
	var result: Array[Rect2]=[]
	for route in ROUTES.get(kind,[]):
		result.append(Rect2(route[0].min(route[1]),(route[1]-route[0]).abs()).grow( sixty(kind)))
	return result
static func sixty(kind: String) -> float: return 44.0 if kind=="town" else (90.0 if kind!="farm" else 85.0)
static func clip(kind: String,rects: Array) -> Array:
	var result: Array=rects.duplicate()
	for clearance in clearances(kind):
		var next: Array=[]
		for rect: Rect2 in result:
			if not rect.intersects(clearance): next.append(rect);continue
			var cut:=rect.intersection(clearance)
			for piece in [Rect2(rect.position,Vector2(rect.size.x,cut.position.y-rect.position.y)),Rect2(Vector2(rect.position.x,cut.end.y),Vector2(rect.size.x,rect.end.y-cut.end.y)),Rect2(Vector2(rect.position.x,cut.position.y),Vector2(cut.position.x-rect.position.x,cut.size.y)),Rect2(Vector2(cut.end.x,cut.position.y),Vector2(rect.end.x-cut.end.x,cut.size.y))]:
				if piece.size.x>0 and piece.size.y>0: next.append(piece)
		result=next
	return result
static func draw(surface,kind: String) -> void:
	# Feather the dirt into existing terrain instead of drawing outlined strips.
	for route in ROUTES.get(kind,[]):
		var axis: Vector2=(route[1]-route[0]).normalized()
		var side:=axis.orthogonal()
		var half:=sixty(kind)
		if kind=="mountain" and route[0]==Vector2(830,760):
			surface.draw_line(route[0],route[1],Color("d9c395"),95,true)
		for band in range(-int(half),int(half),4):
			var alpha:=0.25*(1.0-pow(absf(band)/half,3))
			var offset:=side*band
			surface.draw_line(route[0]+offset,route[1]+offset,Color(0.94,0.78,0.48,alpha),5,true)
