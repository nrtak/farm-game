extends RefCounted
# Short connectors share the same sandy palette as the surrounding roads.
static func draw_path(surface,points: PackedVector2Array,width: float=66) -> void:
	surface.draw_polyline(points,Color("bca16c"),width+8,true)
	for p in points: surface.draw_circle(p,(width+8)/2,Color("bca16c"))
	surface.draw_polyline(points,Color("dbc38c"),width,true)
	for p in points: surface.draw_circle(p,width/2,Color("dbc38c"))
	for i in range(points.size()-1):
		var length: float=points[i].distance_to(points[i+1])
		for step in range(int(length/38)):
			var p: Vector2=points[i].lerp(points[i+1],(step+0.5)/maxf(1,length/38))
			var offset := Vector2(sin(step*2.7)*13,cos(step*1.4)*12)
			surface.draw_circle(p+offset,2.5,Color("c7ad79"))
