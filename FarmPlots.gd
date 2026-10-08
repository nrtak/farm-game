extends RefCounted
static func fill(farm, level: int) -> void:
	var positions: Array[Vector2]=[]
	# Keep the original save indices before adding the remaining soil beds.
	for row in range(3):
		for col in range(5): positions.append(Vector2(1120+col*100,900+row*100))
	for n in range(9): positions.append(Vector2(1620+int(n/3)*100,900+(n%3)*100))
	for y in range(700,1301,100):
		for x in range(1020,2521,100):
			var point:=Vector2(x,y)
			if not positions.has(point): positions.append(point)
	for n in range(clampi(level,0,3)*3): positions.append(Vector2(1120+n*100,1450))
	while farm.plots.size()<positions.size():
		farm.plots.append({"position":positions[farm.plots.size()],"stage":0,"growth":0.0,"crop":"Turnip","last_growth_day":farm.day})
