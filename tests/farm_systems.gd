extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var f=load("res://Main.tscn").instantiate()
	root.add_child(f)
	await process_frame
	f.set_physics_process(false)
	f.choose_character("boy")
	f.interior_progress={"story":{"intro":true}}
	f.day=1; f.clock_minutes=800; f.health=100; f.coins=60000; f.harvests=50
	for destination in [f.FARM_EXIT,f.BARN_DOOR,f.resources.WELL,f.plots[0].position]:
		assert(f.is_walkable(destination),"Farm interaction approach is walkable")
		f.travel_to("farm",Vector2(775,590),false)
		f.polish.plan(destination)
		assert(not f.polish.path.is_empty(),"Tap route connects farm entrances")
		for point in f.polish.path: assert(f.is_walkable(point))
	f.player.position=f.BARN_DOOR
	f.check_walk_exits()
	assert(f.shop_name=="Barn" and f.location=="shop","Walking into barn needs no button")
	f.BarnLife.open_manager(f)
	for species in ["Cow","Sheep","Goat","Chicken"]: f.BarnLife.purchase(f,species)
	assert(f.BarnLife.state(f).animals.size()==4)
	var money: int=f.coins
	f.BarnLife.purchase(f,"Cow")
	assert(f.coins==money,"Full barn cannot charge for another animal")
	for i in range(4):
		f.BarnLife.care(f,i,"feed")
		f.BarnLife.care(f,i,"pet")
		f.BarnLife.care(f,i,"pet")
		assert(f.BarnLife.state(f).animals[i].affection==1)
	assert(f.BarnLife.state(f).feed==6)
	f.day+=1
	f.BarnLife.new_day(f)
	f.BarnLife.new_day(f)
	assert(f.BarnLife.state(f).animals[0].ready==1 and f.BarnLife.state(f).animals[1].ready==0)
	f.BarnLife.care(f,0,"collect")
	assert(f.backpack_count()==1 and f.BarnLife.state(f).products.Milk==1)
	f.enter_house()
	f.transfer_storage("Milk",1,true)
	assert(f.stored_items.Milk==1 and f.BarnLife.state(f).products.Milk==0)
	f.transfer_storage("Milk",1,false)
	assert(f.stored_items.Milk==0 and f.BarnLife.state(f).products.Milk==1)
	f.close_dialogue()
	f.BarnLife.ship(f)
	f.day+=1
	money=f.coins
	f.BarnLife.new_day(f); f.BarnLife.new_day(f)
	assert(f.coins==money+35,"Animal shipping pays once")
	f.close_dialogue()
	f.travel_to("farm",f.resources.WELL,false)
	f.resources.state().water=0
	f.resources.refill()
	assert(f.resources.state().water==24)
	f.resources.action_time=0
	f.player.position=f.resources.WOOD_SPOTS.farm[0]
	f.resources.chop()
	assert(f.resources.state().lumber==3)
	f.resources.action_time=0
	f.resources.chop()
	assert(f.resources.state().lumber==3,"Same wood cannot be harvested twice")
	f.resources.state().lumber=500
	f.clock_minutes=800
	f.enter_shop("Carpentry",true)
	for kind in ["home","home","second_story","barn","irrigation","greenhouse"]:
		f.InteriorLife.open_carpentry(f)
		f.InteriorLife.order_upgrade(f,kind)
		assert(f.interior_progress.has("construction"),"Upgrade ordered: "+kind)
		f.day+=1
		f.InteriorLife.complete_construction(f)
	assert(f.interior.home_level==2 and f.interior_progress.second_story)
	assert(f.BarnLife.capacity(f)==6 and f.resources.state().irrigation==1 and f.interior_progress.greenhouse)
	f.plots[0].stage=1; f.resources.irrigate()
	assert(f.plots[0].stage==2)
	f.close_dialogue()
	f.enter_shop("Greenhouse",true)
	f.extra_seeds.Strawberry=1
	f.FarmBuildings.tend(f,0,"seed","Strawberry")
	f.FarmBuildings.tend(f,0,"water","")
	f.day+=1; f.FarmBuildings.new_day(f); f.FarmBuildings.new_day(f)
	assert(f.FarmBuildings.greenhouse(f)[0].growth==1,"Greenhouse growth occurs once each night")
	f.save_game(false)
	f.interior_progress={}
	f.load_game()
	assert(f.BarnLife.state(f).animals.size()==4 and f.interior_progress.greenhouse and f.resources.state().irrigation==1)
	var storm := -1; var heat := -1
	for d in range(1,113):
		if f.WeatherLife.forecast(d)=="Hurricane": storm=d
		if f.WeatherLife.forecast(d)=="Heatwave": heat=d
	assert(storm>0 and heat>0)
	f.day=storm; f.close_dialogue(); f.travel_to("town",Vector2(1200,900),false)
	assert(f.inside_house)
	f.leave_house(); assert(f.inside_house)
	var bed={"stage":2,"growth":2}
	assert(f.WeatherLife.heatwave_growth(bed,heat+1) and bed.growth==1 and bed.stage==1)
	f.day=3; f.inside_house=false; f.location="farm"
	assert(f.WeatherLife.work_multiplier(f)==1.5)
	var art = preload("res://CharacterArt.gd")
	for person in art.PORTRAITS:
		assert(art.walk(person)!=null and art.portrait(person)!=null,"Updated art available for "+person)
	print("PASS: farm routes, automatic barn entry, purchases, feed/care, animal production and shipping, well, wood cooldown, all carpenter projects, greenhouse, saves and weather")
	quit()
