extends Control
var elapsed := 0.0
var redraw_time := 0.0
func _ready() -> void:
	custom_minimum_size=Vector2(0,62)
	mouse_filter=Control.MOUSE_FILTER_IGNORE
func _process(delta: float) -> void:
	elapsed+=delta
	redraw_time+=delta
	if redraw_time>=0.05:
		redraw_time=0.0
		queue_redraw()
	if elapsed>=2.4:
		set_process(false)
		queue_redraw()
func _draw() -> void:
	var center := Vector2(size.x/2,40)
	draw_rect(Rect2(center+Vector2(-34,0),Vector2(68,12)),Color("576675"))
	draw_rect(Rect2(center+Vector2(-16,12),Vector2(32,8)),Color("3d4a57"))
	var swing := absf(sin(elapsed*9))*22 if elapsed<2.4 else 18.0
	draw_line(center+Vector2(12,-swing),center+Vector2(37,-swing-14),Color("98673e"),6)
	draw_rect(Rect2(center+Vector2(-3,-swing-8),Vector2(24,13)),Color("778895"))
	if elapsed<2.4 and swing<8:
		for i in range(5):
			var direction := Vector2.from_angle(-PI+float(i)*PI/4)
			draw_line(center+direction*12,center+direction*20,Color("e5a33a"),2)
static func show_on(farm) -> void:
	if not is_instance_valid(farm.dialogue_text): return
	var animation = load("res://ForgeMoment.gd").new()
	farm.dialogue_text.get_parent().add_child(animation)
	farm.dialogue_text.get_parent().move_child(animation,2)
