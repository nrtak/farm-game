extends Node2D

const SIZE := Vector2(1000, 1000)

func _ready() -> void:
	for rect in [Rect2(-24, -24, 1048, 24), Rect2(-24, 1000, 1048, 24), Rect2(-24, 0, 24, 1000), Rect2(1000, 0, 24, 1000)]:
		var body := StaticBody2D.new()
		body.collision_layer = 8
		var collision := CollisionShape2D.new()
		var shape := RectangleShape2D.new()
		shape.size = rect.size
		collision.shape = shape
		body.position = rect.get_center()
		body.add_child(collision)
		add_child(body)
	for item in [["Main Town", Vector2(330, 65)], ["Family Farm", Vector2(330, 870)]]:
		var label := Label.new()
		label.text = item[0]
		label.position = item[1]
		label.size = Vector2(340, 45)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.add_theme_color_override("font_color", Color("493b2d"))
		label.add_theme_font_size_override("font_size", 28)
		add_child(label)
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, SIZE), Color("91aa73"))
	draw_rect(Rect2(350, 0, 300, 1000), Color("d8c393"))
	for y in range(120, 850, 130):
		for x in [200, 800]:
			draw_rect(Rect2(x - 9, y + 25, 18, 55), Color("786246"))
			draw_circle(Vector2(x, y), 65, Color("607e55"))
			draw_circle(Vector2(x - 18, y - 20), 43, Color("769362"))
	for y in range(120, 880, 80):
		draw_line(Vector2(285, y), Vector2(285, y + 50), Color("806c4d"), 6)
		draw_line(Vector2(715, y), Vector2(715, y + 50), Color("806c4d"), 6)
