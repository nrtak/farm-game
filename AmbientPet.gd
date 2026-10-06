extends Node2D
var kind := "dog"
var coat := Color("c49b70")
var route: Array = []
var index := 0
var wait := 1.0
var travel := 0.0
var facing := 1.0
var resting := false
var shiba_sprite: Sprite2D
var artwork := ""
func _ready() -> void:
	if artwork.is_empty(): return
	shiba_sprite = Sprite2D.new()
	shiba_sprite.texture = load(artwork)
	shiba_sprite.hframes = 4
	shiba_sprite.vframes = 2
	var cell_height := shiba_sprite.texture.get_height() / 2.0
	shiba_sprite.scale = Vector2.ONE * (82.0 / cell_height)
	shiba_sprite.position.y = -39
	add_child(shiba_sprite)
func update_shiba() -> void:
	if not is_instance_valid(shiba_sprite): return
	shiba_sprite.flip_h = facing < 0
	shiba_sprite.frame = (6 if resting else (5 if index % 2 == 0 else 4)) if wait > 0 else int(travel / 13.0) % 4
func tick(delta: float) -> void:
	if wait > 0:
		wait -= delta
		update_shiba()
		queue_redraw()
		return
	if route.is_empty(): return
	var direction: Vector2 = route[index] - position
	if direction.length() < 5:
		index = (index + 1) % route.size()
		wait = 2.0 + index * 1.3
		resting = index % 3 == 0
	else:
		var step := minf(65.0 * delta, direction.length())
		position += direction.normalized() * step
		travel += step
		if absf(direction.x) > 1: facing = signf(direction.x)
		resting = false
	update_shiba()
	queue_redraw()
func _draw() -> void:
	if is_instance_valid(shiba_sprite): return
	draw_set_transform(Vector2.ZERO, 0, Vector2(facing, 1))
	paint_oval(Vector2(0, -3), Vector2(30, 8), Color(0, 0, 0, 0.15))
	var stride := sin(travel / 9.0) * 5 if wait <= 0 else 0.0
	for i in range(4):
		var x := -18.0 + i * 12
		draw_line(Vector2(x, -18), Vector2(x + stride * (1 if i % 2 == 0 else -1), -3), coat.darkened(0.2), 7)
	paint_oval(Vector2(-3, -24), Vector2(28, 16 if not resting else 11), coat)
	draw_line(Vector2(-26, -26), Vector2(-38, -40 + sin(travel / 16) * 3), coat, 7)
	draw_circle(Vector2(23, -36), 17, coat)
	if kind == "cat":
		for x in [13, 31]: draw_colored_polygon(PackedVector2Array([Vector2(x-7,-46),Vector2(x,-61),Vector2(x+7,-46)]),coat)
	else:
		paint_oval(Vector2(12,-38),Vector2(7,15),coat.darkened(0.3))
	draw_circle(Vector2(31,-38),2.4,Color("302a26"))
	draw_circle(Vector2(39,-31),3,Color("302a26"))
func paint_oval(center: Vector2, radius: Vector2, color: Color) -> void:
	var points := PackedVector2Array()
	for i in range(24): points.append(center + Vector2(cos(i*TAU/24), sin(i*TAU/24))*radius)
	draw_colored_polygon(points,color)
