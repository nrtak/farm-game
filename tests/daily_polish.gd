extends SceneTree
func _initialize(): call_deferred("run")
func run():
	var f=load("res://Main.tscn").instantiate()
	root.add_child(f)
	await process_frame
	f.set_physics_process(false)
	f.choose_character("boy")
	f.day=1
	f.clock_minutes=800
	var errands=preload("res://DailyErrands.gd")
	errands.visit(f,"Clinic")
	assert(errands.state(f).visited.is_empty(),"Visits before acceptance do not complete errands")
	errands.accept(f)
	f.enter_shop("Clinic")
	f.enter_shop("Clinic")
	assert(errands.state(f).visited.size()==1,"Repeat visits count once")
	f.enter_shop("General Store")
	assert(errands.ready(f))
	f.save_game(false)
	f.interior_progress.erase("daily_errand")
	f.load_game()
	assert(errands.ready(f),"Accepted progress persists")
	var coins: int=f.coins
	errands.claim(f); errands.claim(f)
	assert(f.coins==coins+30,"Reward paid once")
	f.day=2
	assert(not errands.state(f).accepted and not errands.state(f).claimed)
	assert(f.coins==coins+30,"No missed-request penalty")
	for minute in [480,1100,1250]:
		f.clock_minutes=minute
		f.update_resident_presence()
		var count:=0
		for room in f.shops.values():
			for npc in room.residents:
				if npc.first_name=="Keiko" and npc.visible: count+=1
		assert(count==1,"Keiko has one workplace/cafe/home presence")
	for kind in ["seed","water","axe","mine","harvest"]:
		f.resources.play(kind,f.player.position+Vector2(30,30))
		assert(f.resources.action_time>0 and f.resources.sounds[kind]!=null)
	for day in [1,29,57,85,113]:
		f.day=day
		f.refresh_hud()
		assert(f.season_scenery.last_season==int((day-1)/28)%4)
		for material in f.season_scenery.materials:
			assert(int(material.get_shader_parameter("season"))==f.season_scenery.last_season)
	print("PASS: optional rotating errands, acceptance, duplicate visits, saved progress, one-time reward, no penalty, cafe routines and tool audio")
	quit()
