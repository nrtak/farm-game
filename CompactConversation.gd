extends Node
var panel: PanelContainer
var column: VBoxContainer
var picture: TextureRect
var queued := false
var actions: HBoxContainer
func setup(box: PanelContainer, content: VBoxContainer, portrait: Texture2D) -> void:
	panel=box
	column=content
	var anchor:=Node2D.new()
	panel.add_child(anchor)
	picture=TextureRect.new()
	picture.texture=portrait
	picture.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
	picture.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	picture.mouse_filter=Control.MOUSE_FILTER_IGNORE
	anchor.add_child(picture)
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
			child.reparent(actions)
			child.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	# Keep the bottom edge fixed as wrapped dialogue or request choices grow.
	var height:=maxf(150,panel.get_combined_minimum_size().y)
	panel.offset_top=-height-18
	panel.offset_bottom=-18
	var available:=maxf(0,panel.get_global_rect().position.y-10)
	var portrait_height:=minf(170,available)
	picture.position=Vector2(10,-portrait_height+4)
	picture.size=Vector2(165,portrait_height)

