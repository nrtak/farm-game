extends SceneTree
func _initialize(): call_deferred("run")
func run():
	var f=load("res://Main.tscn").instantiate()
	root.add_child(f)
	await process_frame
	f.set_physics_process(false); f.choose_character("boy")
	f.interior_progress.story={"intro":true}
	var routes={
		"harbor":[[Vector2(1480,660),Vector2(500,660)],[Vector2(1480,585),Vector2(1480,660)],[Vector2(600,660),Vector2(600,990)],[Vector2(665,550),Vector2(665,660)],[Vector2(1016,610),Vector2(1016,660)]],
		"tea":[[Vector2(80,665),Vector2(1510,665)],[Vector2(453,665),Vector2(453,330)],[Vector2(1042,630),Vector2(1042,665)],[Vector2(860,700),Vector2(860,1050)],[Vector2(1333,700),Vector2(1333,1000)]]}
	for area in routes:
		f.travel_to(area,routes[area][0][0],false)
		await physics_frame
		for route in routes[area]:
			var start:Vector2=route[0]
			var finish:Vector2=route[1]
			var count:int=ceili(start.distance_to(finish)/8.0)
			var side:Vector2=(finish-start).normalized().orthogonal()*16
			for i in range(count+1):
				for offset in [Vector2.ZERO,side,-side]:
					var p:Vector2=start.lerp(finish,float(i)/count)+offset
					assert(f.regions[area].is_walkable(p),"Straight route blocked: %s %s"%[area,p])
					assert(f.polish.clear_position(f.REGION_ORIGINS[area]+p),"Body clearance blocked: %s %s"%[area,p])
	assert(not f.regions.harbor.is_walkable(Vector2(800,1000)))
	assert(not f.regions.tea.is_walkable(Vector2(200,850)))
	f.travel_to("tea",Vector2(60,665),false); f.check_walk_exits()
	assert(f.location=="town")
	print("PASS: wide continuous harbor promenade, pier, tea road and driveways have body clearance; water blocked and tea exit works")
	quit()
