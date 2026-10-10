extends RefCounted
# Furniture footprints in the 1100 x 850 room design space.
const FURNITURE := {
	"General Store": [Rect2(400,170,340,155),Rect2(110,170,215,215),Rect2(110,440,235,170),Rect2(800,340,180,240),Rect2(800,170,180,130)],
	"Café": [Rect2(345,170,425,120),Rect2(790,190,190,420),Rect2(145,250,165,140),Rect2(145,460,170,150)],
	"Clinic": [Rect2(390,200,320,110),Rect2(790,180,190,310),Rect2(110,530,205,105),Rect2(110,180,190,170)],
	"Inn": [Rect2(385,200,335,105),Rect2(110,170,230,250),Rect2(780,170,200,205),Rect2(790,470,190,150),Rect2(110,465,195,155)],
	"Blacksmith": [Rect2(400,190,305,115),Rect2(110,170,245,230),Rect2(120,445,210,190),Rect2(800,170,180,240),Rect2(780,490,200,210)],
	"Carpentry": [Rect2(400,190,325,115),Rect2(110,170,225,220),Rect2(790,170,190,225),Rect2(790,430,190,210),Rect2(110,475,195,150)],
	"Archive": [Rect2(375,185,360,125),Rect2(110,170,200,245),Rect2(805,175,175,150),Rect2(780,395,200,250),Rect2(110,470,215,170)],
	"Town Hall": [Rect2(375,200,365,125),Rect2(110,170,205,260),Rect2(800,170,180,160),Rect2(790,470,190,220),Rect2(110,470,210,215)],
	"Police Box": [Rect2(390,200,350,100),Rect2(110,170,230,160),Rect2(805,170,175,130),Rect2(120,485,215,125),Rect2(790,470,190,175)],
	"Fire Station": [Rect2(390,185,345,130),Rect2(110,170,215,230),Rect2(800,170,180,230),Rect2(790,470,190,170),Rect2(110,495,195,130)],
}
static func furnishings(kind:String) -> Array[Rect2]:
	var result:Array[Rect2]=[]
	result.assign(FURNITURE[kind])
	return result
