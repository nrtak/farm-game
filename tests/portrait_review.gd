extends SceneTree
func _initialize(): call_deferred("run")
func run():
	root.size=Vector2i(1680,1200)
	root.content_scale_size=Vector2i(1680,1200)
	var layer:=CanvasLayer.new()
	root.add_child(layer)
	var bg:=ColorRect.new()
	bg.color=Color("ead8ae"); bg.size=Vector2(1680,1200); layer.add_child(bg)
	var names=preload("res://CharacterArt.gd").PORTRAITS.keys()
	for i in range(names.size()):
		var x: int=(i%7)*240
		var y: int=int(i/7)*300
		var picture:=TextureRect.new()
		picture.texture=preload("res://CharacterArt.gd").portrait(names[i])
		assert(picture.texture!=null)
		picture.position=Vector2(x+10,y+10)
		picture.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
		picture.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		picture.size=Vector2(220,250)
		layer.add_child(picture)
		var label:=Label.new(); label.text=names[i]; label.position=Vector2(x+70,y+265)
		label.add_theme_color_override("font_color",Color("48392e")); layer.add_child(label)
	await process_frame
	for child in layer.get_children():
		if child is TextureRect: child.size=Vector2(220,250)
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OS.get_cmdline_user_args()[0]+"/portrait-framing-review.png")
	print("PASS: all dialogue portraits rendered")
	quit()
