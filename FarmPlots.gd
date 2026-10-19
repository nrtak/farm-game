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
	if farm.plots.size()>positions.size():farm.plots.resize(positions.size())
	# Relocate beds by stable index; preserve crops, stages and growth on old saves.
	# Keep a generous northern lawn without pushing the last row into the pond.
	for i in range(positions.size()):positions[i]=Vector2(positions[i].x+100,900+(positions[i].y-700)*.8)
	for i in range(mini(farm.plots.size(),positions.size())):farm.plots[i].position=positions[i]
	while farm.plots.size()<positions.size():
		farm.plots.append({"position":positions[farm.plots.size()],"stage":0,"growth":0.0,"crop":"Turnip","last_growth_day":farm.day})
