extends SceneTree
func _initialize(): call_deferred("run")
func run():
	var f=load("res://Main.tscn").instantiate()
	root.add_child(f)
	await process_frame
	f.set_physics_process(false); f.choose_character("boy")
	f.interior_progress.story={"intro":true}
	var routes={
		"farm":[[Vector2(1485,180),Vector2(1485,530)],[Vector2(1485,530),Vector2(2420,530)],[Vector2(850,650),Vector2(850,1450)],[Vector2(700,580),Vector2(1400,580)],[Vector2(630,970),Vector2(850,970)],[Vector2(850,1460),Vector2(2000,1460)]],
		"town":[[Vector2(350,820),Vector2(820,820)],[Vector2(1150,940),Vector2(1640,940)],[Vector2(500,1350),Vector2(2050,1350)]],
		"mountain":[[Vector2(830,1080),Vector2(830,540)],[Vector2(620,540),Vector2(1260,540)],[Vector2(830,760),Vector2(1450,760)]],
		"historic":[[Vector2(420,550),Vector2(1050,550)],[Vector2(420,700),Vector2(1050,700)],[Vector2(406,363),Vector2(406,600)]],
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
					var map=f if area=="farm" else (f.town if area=="town" else f.regions[area])
					var origin:Vector2=Vector2.ZERO if area=="farm" else (f.TOWN_ORIGIN if area=="town" else f.REGION_ORIGINS[area])
					assert(map.is_walkable(p),"Straight route blocked: %s %s"%[area,p])
					assert(f.polish.clear_position(origin+p),"Body clearance blocked: %s %s"%[area,p])
	assert(not f.regions.harbor.is_walkable(Vector2(800,1000)))
	assert(not f.regions.tea.is_walkable(Vector2(200,850)))
	f.travel_to("tea",Vector2(60,665),false); f.check_walk_exits()
	assert(f.location=="town")
	f.travel_to("town",Vector2(300,800),false); f.check_walk_exits()
	assert(f.location=="harbor","Town exits before the shoreline")
	assert(not f.town.is_walkable(Vector2(90,800)),"Removed town pier stays ocean")
	print("PASS: wide farm, town, mountain, shrine, harbor and tea routes have body clearance; shore transition and water boundaries work")
	quit()
