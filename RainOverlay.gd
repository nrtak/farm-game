extends Control
var elapsed := 0.0
var redraw_time := 0.0
func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	visibility_changed.connect(func(): set_process(visible))
	set_process(visible)
func _process(delta: float) -> void:
	elapsed += delta
	redraw_time += delta
	if redraw_time >= 0.1:
		redraw_time = 0
		queue_redraw()
func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.3, 0.4, 0.5, 0.08))
	for i in range(18):
		var x := fmod(i * 173.0 + elapsed * 20, maxf(1, size.x))
		var y := fmod(i * 97.0 + elapsed * 190, maxf(1, size.y))
		draw_line(Vector2(x, y), Vector2(x - 5, y + 16), Color(0.75, 0.85, 0.9, 0.35), 2)
