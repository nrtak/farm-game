extends RefCounted
static var cached: Dictionary = {}
static var images: Dictionary = {}
static func spec(kind: String) -> Dictionary:
	if cached.is_empty(): cached=JSON.parse_string(FileAccess.get_file_as_string("res://data/approved_maps.json"))
	return cached.get(kind,{})
static func doors(kind: String) -> Dictionary:
	var result: Dictionary={}
	for name in spec(kind).get("doors",{}):
		var p=spec(kind).doors[name]
		result[name]=Vector2(p[0],p[1])
	return result
static func rects(kind: String, key: String) -> Array:
	var result: Array=[]
	for r in spec(kind).get(key,[]): result.append(Rect2(r[0],r[1],r[2],r[3]))
	return result
static func scenery(kind: String) -> Array:
	var result: Array = rects(kind,"scenery")
	# Door glass and dark entrance steps can resemble water or tree canopy.
	# Keep narrow approach corridors clear while retaining adjacent scenery.
	var approaches: Array = []
	for door in doors(kind).values(): approaches.append(Rect2(door-Vector2(56,18),Vector2(112,150)))
	# The tea-house doorstep joins the road around its southwest garden.
	if kind=="tea": approaches.append(Rect2(880,660,220,80))
	if kind=="mountain":
		var mine_trail := [Vector2(1380,205),Vector2(1390,280),Vector2(1320,330),Vector2(1320,400),Vector2(1260,500)]
		for i in range(mine_trail.size()-1):
			var count := int(ceil(mine_trail[i].distance_to(mine_trail[i+1])/24.0))
			for step in range(count+1):
				var point: Vector2 = mine_trail[i].lerp(mine_trail[i+1],float(step)/count)
				approaches.append(Rect2(point-Vector2(48,48),Vector2(96,96)))
	for clearance: Rect2 in approaches:
		var clipped: Array = []
		for rect: Rect2 in result:
			if not rect.intersects(clearance):
				clipped.append(rect)
				continue
			var cut := rect.intersection(clearance)
			for piece in [Rect2(rect.position,Vector2(rect.size.x,cut.position.y-rect.position.y)), Rect2(Vector2(rect.position.x,cut.end.y),Vector2(rect.size.x,rect.end.y-cut.end.y)), Rect2(Vector2(rect.position.x,cut.position.y),Vector2(cut.position.x-rect.position.x,cut.size.y)), Rect2(Vector2(cut.end.x,cut.position.y),Vector2(rect.end.x-cut.end.x,cut.size.y))]:
				if piece.size.x>0 and piece.size.y>0: clipped.append(piece)
		result=clipped
	return result
static func buildings(kind: String) -> Array: return rects(kind,"buildings")
static func is_path(kind: String, point: Vector2, size: Vector2) -> bool:
	if not images.has(kind): images[kind]=load("res://assets/map-"+kind+"-approved-v1.png").get_image()
	var img: Image=images[kind]
	var uv=point/size
	var c=img.get_pixel(clampi(int(uv.x*img.get_width()),0,img.get_width()-1),clampi(int(uv.y*img.get_height()),0,img.get_height()-1))
	return c.r>0.55 and c.g>0.45 and c.r>c.g*0.97
