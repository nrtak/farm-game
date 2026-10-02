extends Control

var direction := Vector2.ZERO
var finger := -1
var knob := Vector2.ZERO
const RADIUS := 58.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var local: Vector2 = event.position - global_position
		if event.pressed and finger == -1 and local.distance_to(size / 2) < RADIUS + 14:
			finger = event.index
			update_knob(local)
			get_viewport().set_input_as_handled()
		elif not event.pressed and event.index == finger:
			finger = -1
			direction = Vector2.ZERO
			knob = Vector2.ZERO
			queue_redraw()
	elif event is InputEventScreenDrag and event.index == finger:
		update_knob(event.position - global_position)
		get_viewport().set_input_as_handled()

func update_knob(point: Vector2) -> void:
	knob = (point - size / 2).limit_length(RADIUS - 12)
	direction = knob / (RADIUS - 12)
	if direction.length() < 0.15:
		direction = Vector2.ZERO
	queue_redraw()

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		finger = -1
		direction = Vector2.ZERO
		knob = Vector2.ZERO
		queue_redraw()

func _draw() -> void:
	draw_circle(size / 2, RADIUS, Color(0.20, 0.25, 0.18, 0.45))
	draw_arc(size / 2, RADIUS, 0, TAU, 48, Color("ddcfa4"), 3)
	draw_circle(size / 2 + knob, 23, Color(0.94, 0.87, 0.69, 0.85))
