extends Node2D
const SIZE:=Vector2(1600,1200)
const GROUND:= [Vector2(220,550),Vector2(550,500),Vector2(1050,500),Vector2(1380,550),Vector2(1390,940),Vector2(1030,1080),Vector2(980,1175),Vector2(620,1175),Vector2(560,1080),Vector2(220,950)]
var npcs: Array[Node2D]=[]
var title:="Moonveil Falls"
var background: Texture2D
var kind:="waterfall"
var ambience:AudioStreamPlayer
var time:=0.0
var redraw_time:=0.0
func setup(_area: String,_people: Array) -> void:
	background=load("res://assets/map-waterfall-clearing-v1.png")
	ambience=AudioStreamPlayer.new();ambience.stream=load("res://assets/audio/waterfall.wav");ambience.volume_db=-20;add_child(ambience)
	queue_redraw()
func _process(_delta:float) -> void:
	if ambience==null: return
	var f=get_parent()
	if preload("res://ShrineFalls.gd").nearby(f) and f.window_focused and not f.paused_by_player:
		if not ambience.playing: ambience.play()
	elif ambience.playing: ambience.stop()
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
	if get_parent().has_meta("angled_world"): return
	if background==null: return
	draw_texture_rect(background,Rect2(Vector2.ZERO,SIZE),false)
	for i in range(4):
		draw_arc(Vector2(650+i*85,405+sin(time*.3+i)*12),60,PI,TAU,24,Color(0.85,0.98,1,0.12),6,true)
	for i in range(10):
		var p:=Vector2(520+i*55,300+sin(time*0.8+i)*25)
		draw_circle(p,2.5,Color(0.7,1,0.94,0.3+0.2*sin(time+i)))
	draw_string(ThemeDB.fallback_font,Vector2(670,1120),"South · Mountain trail",HORIZONTAL_ALIGNMENT_LEFT,-1,24,Color("493b2d"))
