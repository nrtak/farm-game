extends Control
var brew:=0
var age:=0.0
var redraw_time:=0.0
func _ready() -> void:
	custom_minimum_size=Vector2(150,80)
	mouse_filter=Control.MOUSE_FILTER_IGNORE
func _process(delta:float) -> void:
	age+=delta
	redraw_time+=delta
	if redraw_time>=0.05:
		redraw_time=0
		queue_redraw()
	if age>4: set_process(false)
func _draw() -> void:
	var center:=Vector2(size.x*.5,48)
	paint_oval(center+Vector2(0,18),Vector2(52,10),Color("bbab84"))
	var cup:=StyleBoxFlat.new()
	cup.bg_color=Color("f7efd6")
	cup.border_color=Color("826548")
	cup.set_border_width_all(3)
	cup.set_corner_radius_all(12)
	draw_style_box(cup,Rect2(center-Vector2(34,17),Vector2(68,39)))
	paint_oval(center-Vector2(0,14),Vector2(32,9),Color("826548"))
	paint_oval(center-Vector2(0,15),Vector2(28,6),[Color("a6b16d"),Color("ae7e49"),Color("7d9051")][brew])
	for i in range(3):
		var points:=PackedVector2Array()
		for step in range(12): points.append(center+Vector2((i-1)*17+sin(step*.45+age*2+i)*3,-25-step*1.6))
		draw_polyline(points,Color(1,1,.9,.65),2,true)
func paint_oval(center:Vector2,radius:Vector2,color:Color) -> void:
	var points:=PackedVector2Array()
	for i in range(40): points.append(center+Vector2(cos(i*TAU/40),sin(i*TAU/40))*radius)
	draw_colored_polygon(points,color)
