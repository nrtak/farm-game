extends SceneTree
func _initialize(): call_deferred("run")
func run():
	var f=load("res://Main.tscn").instantiate()
	root.add_child(f)
	await process_frame
	f.set_physics_process(false);f.choose_character("boy")
	f.interior_progress.story={"intro":true}
	root.size=Vector2i(1170,540)
	f.camera.position_smoothing_enabled=false
	var rooms=preload("res://TownInteriorLayout.gd").FURNITURE.keys()
	for kind in rooms:
		f.enter_shop(kind,true)
		f.player.position=f.SHOP_ORIGIN+Vector2(550,470)
		f.camera.force_update_scroll()
		await create_timer(.25).timeout
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(OS.get_cmdline_user_args()[0]+"/town-interior-"+kind.replace(" ","-")+".png")
	f.queue_free();await process_frame
	root.size=Vector2i(2000,1320)
	root.content_scale_size=Vector2i(2000,1320)
	var canvas=Control.new();root.add_child(canvas)
	var bg=ColorRect.new();bg.color=Color("e5e6df");bg.size=Vector2(2000,1320);canvas.add_child(bg)
	for i in range(rooms.size()):
		var origin=Vector2((i%4)*500,int(i/4)*440)
		var picture=TextureRect.new()
		picture.texture=preload("res://InteriorArtwork.gd").texture(rooms[i])
		picture.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
		picture.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		picture.position=origin+Vector2(8,40);picture.size=Vector2(484,385)
		canvas.add_child(picture)
		var label=Label.new();label.text=rooms[i];label.position=origin+Vector2(16,6)
		label.add_theme_color_override("font_color",Color("253d47"));label.add_theme_font_size_override("font_size",26)
		canvas.add_child(label)
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OS.get_cmdline_user_args()[0]+"/town-interiors-overview.png")
	print("PASS: ten town interiors rendered in game and overview")
	quit()
