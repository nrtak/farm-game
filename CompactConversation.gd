extends Node
var panel: PanelContainer
var column: VBoxContainer
var picture: TextureRect
var queued := false
var scroll: ScrollContainer
var actions: HFlowContainer
var portrait_margin:=140
func setup(box: PanelContainer, content: VBoxContainer, portrait: Texture2D, dismiss: Callable) -> void:
	panel=box
	portrait_margin=140 if portrait!=null else 18
	column=content
	var anchor:=Node2D.new()
	panel.add_child(anchor)
	picture=TextureRect.new()
	if portrait != null:
		var bust:=AtlasTexture.new()
		bust.atlas=portrait
		bust.region=Rect2(0,0,portrait.get_width(),portrait.get_height()*0.55)
		picture.texture=bust
	picture.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
	picture.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	picture.mouse_filter=Control.MOUSE_FILTER_IGNORE
	anchor.add_child(picture)
	var close=Button.new();close.name="DialogueClose";close.text="×";close.size=Vector2(44,44);close.position=Vector2(-50,6);close.pressed.connect(dismiss);anchor.add_child(close)
	panel.resized.connect(func(): close.position.x=panel.size.x-50)
	var row=column.get_parent()
	scroll=ScrollContainer.new();scroll.custom_minimum_size.y=140;scroll.size_flags_horizontal=Control.SIZE_EXPAND_FILL;scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED
	panel.remove_child(row)
	var margin=MarginContainer.new();margin.add_theme_constant_override("margin_left",portrait_margin);margin.add_theme_constant_override("margin_right",48);margin.add_theme_constant_override("margin_top",10);margin.add_theme_constant_override("margin_bottom",10)
	panel.add_child(margin);margin.add_child(scroll);scroll.add_child(row)
	# Keep the dismiss control above the scrolling content for touch hit-testing.
	panel.move_child(anchor,panel.get_child_count()-1)
	row.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	for child in column.get_children():
		if child is Label and child==column.get_child(1) and child.get_theme_font_size("font_size")<25:child.add_theme_font_size_override("font_size",17)
	actions=HFlowContainer.new()
	actions.add_theme_constant_override("separation",10)
	column.add_child(actions)
	column.minimum_size_changed.connect(schedule)
	panel.resized.connect(schedule)
	get_viewport().size_changed.connect(schedule)
	schedule()
func schedule() -> void:
	if queued: return
	queued=true
	call_deferred("fit")
func fit() -> void:
	queued=false
	if not is_instance_valid(panel): return
	for child in column.get_children():
		if child is Button:
			if child.text=="Close":child.hide()
			child.reparent(actions)
			child.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	var viewport=get_viewport().get_visible_rect().size
	var width=minf(590,viewport.x-48)
	var text_height=0.0
	for child in column.get_children():
		if child is Label:
			var font=child.get_theme_font("font");var font_size=child.get_theme_font_size("font_size")
			text_height+=font.get_multiline_string_size(child.text,HORIZONTAL_ALIGNMENT_LEFT,width-portrait_margin-70,font_size).y+12
	var body_height=clampf(text_height+actions.get_combined_minimum_size().y,140,viewport.y-110)
	scroll.custom_minimum_size.y=body_height
	panel.anchor_left=.5;panel.anchor_right=.5
	panel.offset_left=-width/2;panel.offset_right=width/2
	panel.offset_top=-body_height-38;panel.offset_bottom=-18
	var ratio=picture.texture.get_width()/float(picture.texture.get_height()) if picture.texture else 1.0
	var height=minf(125/ratio,minf(210,body_height+28))
	picture.size=Vector2(height*ratio,height)
	picture.position=Vector2(8,panel.size.y-8-height)
