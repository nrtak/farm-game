extends Node2D
var farm
var phase := -1
var elapsed := 0.0
var start := Vector2.ZERO
var bedside := Vector2.ZERO
var pillow := Vector2.ZERO
var curtain: ColorRect
var title: Label
var overlay: CanvasLayer
const DURATIONS := [0.65,0.45,0.6,0.6,0.6,0.65]
func begin(game) -> void:
	farm=game
	z_index=200
	phase=0
	elapsed=0
	start=farm.player.position
	bedside=farm.ROOM_ORIGIN+farm.interior.BED_APPROACH
	pillow=farm.ROOM_ORIGIN+farm.interior.BED.get_center()+Vector2(0,25)
	farm.sleep_in_progress=true
	farm.player.velocity=Vector2.ZERO
	farm.polish.path.clear()
	farm.joystick.reset_stick()
	curtain=ColorRect.new()
	curtain.color=Color(0.08,0.1,0.17,0)
	curtain.mouse_filter=Control.MOUSE_FILTER_STOP
	overlay=CanvasLayer.new()
	overlay.layer=10
	add_child(overlay)
	overlay.add_child(curtain)
	farm.hud.hide()
	curtain.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	title=Label.new()
	title.text="Good night\n"+farm.calendar_text()
	title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	title.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size",36)
	title.modulate.a=0
	curtain.add_child(title)
	title.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	farm.refresh_hud()
func _process(delta: float) -> void:
	if phase<0 or not farm.window_focused: return
	step(delta)
func step(delta: float) -> void:
	if phase<0: return
	elapsed+=delta
	var t := clampf(elapsed/DURATIONS[phase],0,1)
	match phase:
		0:
			farm.player.position=start.lerp(bedside,t)
			farm.update_walk(delta,true,bedside-start,delta*100)
		1:
			farm.player.position=bedside.lerp(pillow,t)
			farm.update_walk(0,false,Vector2.DOWN)
			farm.farmer.rotation=0
		2:
			curtain.color.a=t
			title.modulate.a=t
		3: pass
		4:
			curtain.color.a=1-t
			title.modulate.a=1-t
		5:
			farm.farmer.visible=true
			farm.farmer.rotation=0
			farm.player.position=pillow.lerp(bedside,t)+Vector2(0,-sin(t*PI)*35)
			farm.update_walk(0,false,Vector2.DOWN)
	queue_redraw()
	if t<1: return
	if phase==2:
		farm.farmer.visible=false
	if phase==3:
		farm.finish_sleep_day()
		title.text="A new day!\n"+farm.calendar_text()+"\n"+farm.clock_text()
		farm.player.position=pillow
	phase+=1
	elapsed=0
	if phase<DURATIONS.size(): return
	phase=-1
	farm.player.position=bedside
	farm.farmer.visible=true
	farm.farmer.rotation=0
	farm.sleep_in_progress=false
	overlay.queue_free()
	farm.hud.show()
	farm.refresh_hud()
	farm.save_game(false)
	queue_redraw()
func _draw() -> void:
	if phase not in [1,2,3,4]: return
	var bed: Rect2 = farm.interior.BED
	var blanket := Rect2(farm.ROOM_ORIGIN+bed.position+Vector2(5,60),Vector2(bed.size.x-10,bed.size.y-65))
	draw_style_box(farm.interior.panel(Color("7d9b83")),blanket)
	draw_line(blanket.position+Vector2(4,14),blanket.position+Vector2(blanket.size.x-4,14),Color("d8d5ad"),5)
	for flower in [Vector2(28,155),Vector2(75,170),Vector2(120,150)]:
		for petal in [Vector2(-4,0),Vector2(4,0),Vector2(0,-4),Vector2(0,4)]: draw_circle(blanket.position+flower+petal,3,Color("d8d5ad"))
	draw_string(ThemeDB.fallback_font,farm.ROOM_ORIGIN+bed.position+Vector2(110,-15),"Z z z",HORIZONTAL_ALIGNMENT_LEFT,-1,24,Color("eadfc4"))
