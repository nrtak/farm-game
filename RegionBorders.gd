extends RefCounted
const FENCES={"tea":[Rect2(1555,700,8,440),Rect2(1340,25,8,85)],"harbor":[Rect2(785,170,170,8),Rect2(1205,170,220,8)]}
static func rects(area:String)->Array:return FENCES.get(area,[])
