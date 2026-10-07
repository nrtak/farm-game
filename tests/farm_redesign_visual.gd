extends SceneTree
func _initialize() -> void: call_deferred("run")
func capture(f,name: String) -> void:
	f.toast_time=0
	f.refresh_hud()
	f.camera.force_update_scroll()
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../previews/"+name+".png"))
func run() -> void:
	var f=load("res://Main.tscn").instantiate()
	root.add_child(f)
	await process_frame
	f.set_physics_process(false)
	f.choose_character("boy")
	f.day=1; f.clock_minutes=720; f.health=100; f.coins=60000
	f.interior_progress={"story":{"intro":true}}
	f.camera.position_smoothing_enabled=false
	root.size=Vector2i(960,640)
	f.travel_to("farm",Vector2(1500,1000),false)
	f.camera.zoom=Vector2.ONE*0.32
	f.camera.offset=Vector2.ZERO
	f.hud.hide()
	await create_timer(0.5).timeout
	await capture(f,"farm-redesign-overview")
	root.size=Vector2i(1170,540)
	f.hud.show()
	for name in ["house-yard","well","field","barn-yard"]:
		var point: Vector2={"house-yard":Vector2(775,610),"well":f.resources.WELL,"field":Vector2(1550,1050),"barn-yard":f.BARN_DOOR+Vector2(0,120)}[name]
		f.travel_to("farm",point,false)
		await create_timer(0.4).timeout
		await capture(f,"farm-redesign-"+name)
	f.enter_shop("Barn",true)
	f.BarnLife.open_manager(f)
	for species in ["Cow","Sheep","Goat","Chicken"]: f.BarnLife.purchase(f,species)
	f.close_dialogue()
	f.camera.zoom=Vector2.ONE*maxf(1170.0/1100.0,540.0/850.0)
	f.player.position=f.SHOP_ORIGIN+Vector2(550,530)
	await create_timer(0.3).timeout
	await capture(f,"farm-barn-interior")
	f.BarnLife.open_manager(f)
	await capture(f,"farm-barn-shop")
	f.close_dialogue()
	f.interior_progress.greenhouse=true
	f.enter_shop("Greenhouse",true)
	f.player.position=f.SHOP_ORIGIN+Vector2(550,530)
	await create_timer(0.3).timeout
	await capture(f,"farm-greenhouse-interior")
	f.interior_progress.home=2
	f.interior_progress.second_story=true
	f.interior.apply_upgrade(2)
	f.enter_house()
	f.player.position=f.ROOM_ORIGIN+Vector2(1000,580)
	f.camera.zoom=Vector2.ONE*0.82
	await create_timer(0.3).timeout
	await capture(f,"farm-three-room-home")
	f.enter_shop("Upper Floor",true)
	await create_timer(0.3).timeout
	await capture(f,"farm-upstairs")
	f.close_dialogue()
	f.travel_to("historic",Vector2(800,600),false)
	var column=f.make_modal("Haruka",true)
	f.dialogue_text.text="The farm has a new chapter ahead of it."
	column.add_child(f.make_button("Continue",f.close_dialogue))
	await capture(f,"haruka-dialogue-revised")
	print("PASS: phone-sized farm, house, barn, greenhouse, upstairs and portrait previews rendered")
	quit()
