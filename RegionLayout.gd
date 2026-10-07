extends RefCounted
# Coordinates use the region's logical 1600 x 1200 map, shared by physics and taps.
static func boundary_polygons(kind: String) -> Array:
	match kind:
		"harbor": return [
			PackedVector2Array([Vector2(0,735),Vector2(120,755),Vector2(235,785),Vector2(350,785),Vector2(470,775),Vector2(605,740),Vector2(740,770),Vector2(870,790),Vector2(1050,800),Vector2(1210,780),Vector2(1210,1005),Vector2(1180,1005),Vector2(1180,1160),Vector2(0,1200)]),
			PackedVector2Array([Vector2(1345,780),Vector2(1480,750),Vector2(1600,740),Vector2(1600,1200),Vector2(1420,1200),Vector2(1420,1005),Vector2(1345,1005)]),
			PackedVector2Array([Vector2(1180,1160),Vector2(1420,1160),Vector2(1420,1200),Vector2(1180,1200)])]
		"mountain": return [
			PackedVector2Array([Vector2(0,0),Vector2(760,0),Vector2(760,95),Vector2(640,145),Vector2(600,190),Vector2(0,145)]),
			PackedVector2Array([Vector2(905,0),Vector2(1600,0),Vector2(1600,170),Vector2(1040,180),Vector2(905,100)]),
			PackedVector2Array([Vector2(0,800),Vector2(220,820),Vector2(360,890),Vector2(520,920),Vector2(650,1100),Vector2(660,1200),Vector2(0,1200)])]
		"tea": return [PackedVector2Array([Vector2(0,0),Vector2(1600,0),Vector2(1600,75),Vector2(0,75)])]
		"historic": return [PackedVector2Array([Vector2(0,0),Vector2(1600,0),Vector2(1600,90),Vector2(920,90),Vector2(840,60),Vector2(720,60),Vector2(610,130),Vector2(0,120)])]
	return []
static func tree_clusters(kind: String) -> Array:
	match kind:
		"harbor": return [[Vector2(70,55),60],[Vector2(330,30),60],[Vector2(500,70),55],[Vector2(945,50),60],[Vector2(1320,35),65],[Vector2(1560,290),45]]
		"mountain": return [[Vector2(90,550),70],[Vector2(220,520),40],[Vector2(670,960),45],[Vector2(950,1050),65],[Vector2(1480,450),65],[Vector2(1460,1050),95],[Vector2(1540,750),70]]
		"historic": return [[Vector2(800,485),70],[Vector2(525,740),60],[Vector2(210,510),45],[Vector2(380,550),65],[Vector2(1010,780),65],[Vector2(1230,525),65],[Vector2(1100,920),70],[Vector2(1310,1030),60],[Vector2(490,1090),75],[Vector2(1550,980),65]]
		"tea": return [[Vector2(630,585),45],[Vector2(970,610),40],[Vector2(80,910),45],[Vector2(1540,940),60]]
	return []
