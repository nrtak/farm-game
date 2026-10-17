extends Node
var panel: PanelContainer
var column: VBoxContainer
var picture: TextureRect
var queued := false
var actions: HBoxContainer
func setup(box: PanelContainer, content: VBoxContainer, portrait: Texture2D, dismiss: Callable) -> void:
	panel=box
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
	var close=Button.new();close.text="×";close.size=Vector2(44,44);close.position=Vector2(-50,6);close.pressed.connect(dismiss);anchor.add_child(close)
	panel.resized.connect(func(): close.position.x=panel.size.x-50)
	var row=column.get_parent()
	var scroll=ScrollContainer.new();scroll.custom_minimum_size.y=210;scroll.size_flags_horizontal=Control.SIZE_EXPAND_FILL;scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED
	panel.remove_child(row);panel.add_child(scroll);scroll.add_child(row)
	row.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	for child in column.get_children():
		if child is Label:child.add_theme_font_size_override("font_size",17)
	actions=HBoxContainer.new()
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
	var width=minf(590,get_viewport().get_visible_rect().size.x-170)
	panel.anchor_left=.5;panel.anchor_right=.5
	panel.offset_left=-width/2;panel.offset_right=width/2
	panel.offset_top=-265;panel.offset_bottom=-18
	picture.position=Vector2(-120,15)
	picture.size=Vector2(125,180)
