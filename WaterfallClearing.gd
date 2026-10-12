extends Node2D
const SIZE:=Vector2(1600,1200)
const GROUND:= [Vector2(220,550),Vector2(550,500),Vector2(1050,500),Vector2(1380,550),Vector2(1390,940),Vector2(1030,1080),Vector2(980,1175),Vector2(620,1175),Vector2(560,1080),Vector2(220,950)]
var npcs: Array[Node2D]=[]
var title:="Moonveil Falls"
var background: Texture2D
var kind:="waterfall"
var time:=0.0
var redraw_time:=0.0
func setup(_area: String,_people: Array) -> void:
	background=load("res://assets/map-waterfall-clearing-v1.png")
	queue_redraw()
func is_walkable(point: Vector2) -> bool:
	for offset in [Vector2.ZERO,Vector2(16,0),Vector2(-16,0),Vector2(0,16),Vector2(0,-16)]:
		if not Geometry2D.is_point_in_polygon(point+offset,PackedVector2Array(GROUND)): return false
	return true
func safe_point(point: Vector2) -> Vector2:
	return point if is_walkable(point) else Vector2(800,950)
func nearest_npc(_point: Vector2) -> Node2D: return null
func tick(delta: float,_minute: float) -> void:
	time+=delta
	redraw_time+=delta
	if redraw_time>0.1:
		redraw_time=0
		queue_redraw()
func _draw() -> void:
	if background==null: return
	draw_texture_rect(background,Rect2(Vector2.ZERO,SIZE),false)
	for i in range(10):
		var p:=Vector2(520+i*55,300+sin(time*0.8+i)*25)
		draw_circle(p,2.5,Color(0.7,1,0.94,0.3+0.2*sin(time+i)))
	draw_string(ThemeDB.fallback_font,Vector2(670,1120),"South · Mountain trail",HORIZONTAL_ALIGNMENT_LEFT,-1,24,Color("493b2d"))
