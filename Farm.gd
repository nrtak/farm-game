extends Node2D

const WORLD := Vector2(2400, 1600)
const GROW_SECONDS := 12.0
const SPEED := 200.0
const SAVE_FILE := "user://farm_save.json"
const JoystickScript = preload("res://Joystick.gd")
var player: CharacterBody2D
var camera: Camera2D
var farmer: Sprite2D
var joystick: Control
var hud: Control
var date_label: Label
var message_label: Label
var action_button: Button
var tool_bar: HBoxContainer
var plots: Array[Dictionary] = []
var grass: Array[Vector2] = []
var selected_tool := 0
var coins := 500
var harvests := 0
var toast := "Welcome home. Plant a seed, then water it."
var toast_time := 5.0
var save_time := 0.0
var nearest := -1
var tool_buttons: Array[Button] = []
var rocks := [Vector2(430, 810), Vector2(1410, 770), Vector2(1640, 1230)]

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color("77a5be"))
	var rng := RandomNumberGenerator.new()
	rng.seed = 214
	for i in range(1500):
		grass.append(Vector2(rng.randf_range(50, 2350), rng.randf_range(510, 1550)))
	for row in range(3):
		for col in range(5):
			plots.append({"position": Vector2(760 + col * 68, 780 + row * 68), "stage": 0, "growth": 0.0})
	for rect in [Rect2(0, 490, 2400, 24), Rect2(0, 1576, 2400, 24), Rect2(0, 490, 24, 1110), Rect2(2376, 490, 24, 1110), Rect2(390, 520, 350, 180), Rect2(1730, 680, 240, 190), Rect2(1350, 1150, 60, 250)]:
		obstacle(rect)
	for rock in rocks:
		obstacle(Rect2(rock - Vector2(30, 18), Vector2(60, 36)))
	player = CharacterBody2D.new()
	player.position = Vector2(820, 710)
	player.z_index = 5
	add_child(player)
	var collider := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 12
	collider.shape = shape
	player.add_child(collider)
	farmer = Sprite2D.new()
	farmer.texture = preload("res://assets/farmer.png")
	farmer.scale = Vector2(0.08, 0.08)
	farmer.position.y = -24
	player.add_child(farmer)
	camera = Camera2D.new()
	camera.offset = Vector2(0, -90)
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 7
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = 2400
	camera.limit_bottom = 1600
	player.add_child(camera)
	var home := Sprite2D.new()
	home.texture = preload("res://assets/farmhouse.png")
	var texture_size := home.texture.get_size()
	home.scale = Vector2.ONE * (460.0 / texture_size.x)
	home.position = Vector2(565, 550)
	add_child(home)
	make_ui()
	load_game()
	get_viewport().size_changed.connect(layout_ui)
	layout_ui()
	queue_redraw()

func obstacle(rect: Rect2) -> void:
	var body := StaticBody2D.new()
	body.position = rect.get_center()
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = rect.size
	collision.shape = shape
	body.add_child(collision)
	add_child(body)

func parchment() -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = Color("f4e3bb")
	box.border_color = Color("856341")
	box.set_border_width_all(3)
	box.set_corner_radius_all(9)
	box.content_margin_left = 14
	box.content_margin_right = 14
	box.content_margin_top = 8
	box.content_margin_bottom = 8
	return box

func make_button(text: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_stylebox_override("normal", parchment())
	var active := parchment()
	active.bg_color = Color("e7c786")
	button.add_theme_stylebox_override("pressed", active)
	button.add_theme_stylebox_override("hover", active)
	button.add_theme_color_override("font_color", Color("493b2d"))
	button.add_theme_color_override("font_hover_color", Color("493b2d"))
	button.add_theme_color_override("font_pressed_color", Color("493b2d"))
	button.add_theme_font_size_override("font_size", 18)
	button.pressed.connect(callback)
	return button

func make_ui() -> void:
	var canvas := CanvasLayer.new()
	add_child(canvas)
	hud = Control.new()
	hud.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(hud)
	date_label = Label.new()
	date_label.add_theme_stylebox_override("normal", parchment())
	date_label.add_theme_color_override("font_color", Color("493b2d"))
	date_label.add_theme_font_size_override("font_size", 20)
	hud.add_child(date_label)
	message_label = Label.new()
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.add_theme_color_override("font_color", Color("fff5dc"))
	message_label.add_theme_color_override("font_shadow_color", Color("293c29"))
	message_label.add_theme_constant_override("shadow_offset_x", 2)
	message_label.add_theme_constant_override("shadow_offset_y", 2)
	message_label.add_theme_font_size_override("font_size", 18)
	hud.add_child(message_label)
	joystick = JoystickScript.new()
	joystick.size = Vector2(132, 132)
	hud.add_child(joystick)
	action_button = make_button("Plant", interact)
	action_button.custom_minimum_size = Vector2(138, 72)
	hud.add_child(action_button)
	tool_bar = HBoxContainer.new()
	tool_bar.add_theme_constant_override("separation", 8)
	hud.add_child(tool_bar)
	for i in range(3):
		var index := i
		var button := make_button(["1 Seed", "2 Water", "3 Harvest"][i], func(): select_tool(index))
		button.custom_minimum_size = Vector2(104, 58)
		tool_bar.add_child(button)
		tool_buttons.append(button)
	var save_button := make_button("Save", save_game)
	save_button.name = "SaveButton"
	hud.add_child(save_button)
	select_tool(0)

func layout_ui() -> void:
	var view := get_viewport_rect().size
	var margin := Vector2(28, 24)
	var right := 28.0
	var bottom := 28.0
	if OS.get_name() in ["iOS", "Android"]:
		var safe := DisplayServer.get_display_safe_area()
		var screen := DisplayServer.screen_get_size()
		if screen.x > 0 and screen.y > 0:
			var ratio := view / Vector2(screen)
			margin = Vector2(safe.position) * ratio + Vector2(20, 20)
			right = (screen.x - safe.end.x) * ratio.x + 20
			bottom = (screen.y - safe.end.y) * ratio.y + 24
	date_label.position = margin
	joystick.position = Vector2(margin.x, view.y - bottom - 132)
	action_button.position = Vector2(view.x - right - 138, view.y - bottom - 92)
	action_button.size = Vector2(138, 72)
	tool_bar.position = Vector2((view.x - 328) / 2, view.y - bottom - 66)
	message_label.position = Vector2(margin.x, margin.y + 76)
	message_label.size = Vector2(view.x - margin.x - right, 40)
	hud.get_node("SaveButton").position = Vector2(view.x - right - 95, margin.y)

func select_tool(index: int) -> void:
	selected_tool = index
	for i in range(tool_buttons.size()):
		tool_buttons[i].modulate = Color("ffdb89") if i == index else Color.WHITE
	action_button.text = ["Plant", "Water", "Harvest"][index]

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_1: select_tool(0)
		if event.physical_keycode == KEY_2: select_tool(1)
		if event.physical_keycode == KEY_3: select_tool(2)
		if event.physical_keycode in [KEY_SPACE, KEY_E, KEY_ENTER]: interact()

func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if Input.is_physical_key_pressed(KEY_A): direction.x -= 1
	if Input.is_physical_key_pressed(KEY_D): direction.x += 1
	if Input.is_physical_key_pressed(KEY_W): direction.y -= 1
	if Input.is_physical_key_pressed(KEY_S): direction.y += 1
	direction += joystick.direction
	player.velocity = direction.limit_length() * SPEED
	player.move_and_slide()
	if absf(direction.x) > 0.1: farmer.flip_h = direction.x < 0
	farmer.position.y = -24 + sin(Time.get_ticks_msec() * 0.015) * 1.5 if direction.length() > 0 else -24
	nearest = -1
	var distance := 78.0
	for i in range(plots.size()):
		var candidate: float = player.position.distance_to(plots[i].position)
		if candidate < distance:
			distance = candidate
			nearest = i
		if plots[i].stage == 2:
			plots[i].growth += delta
			if plots[i].growth >= GROW_SECONDS:
				plots[i].stage = 3
	toast_time -= delta
	save_time += delta
	if save_time >= 10:
		save_game(false)
		save_time = 0
	date_label.text = "Spring 1  |  Year 1\n%dg   •   Harvested %d" % [coins, harvests]
	message_label.text = toast if toast_time > 0 else "Choose a tool, then use it beside a crop bed."
	queue_redraw()

func say(text: String) -> void:
	toast = text
	toast_time = 4.0

func interact() -> void:
	if nearest < 0:
		say("Move closer to a crop bed.")
		return
	var plot: Dictionary = plots[nearest]
	match selected_tool:
		0:
			if plot.stage != 0: say("This bed is already planted.")
			elif coins < 5: say("Seeds cost 5g.")
			else:
				coins -= 5
				plot.stage = 1
				plot.growth = 0.0
				say("Planted! Select Water to help it grow.")
		1:
			if plot.stage == 1:
				plot.stage = 2
				say("Watered. Ready to harvest in 12 seconds.")
			elif plot.stage == 0: say("Plant a seed first.")
			else: say("This crop already has enough water.")
		2:
			if plot.stage == 3:
				plot.stage = 0
				plot.growth = 0.0
				coins += 20
				harvests += 1
				say("Harvested! +20g. This bed can be replanted.")
			else: say("Harvest crops with golden leaves when ready.")
	save_game(false)

func save_game(show_message: bool = true) -> void:
	var crop_data: Array = []
	for plot in plots:
		crop_data.append({"stage": plot.stage, "growth": plot.growth})
	var file := FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify({"version": 1, "coins": coins, "harvests": harvests, "x": player.position.x, "y": player.position.y, "plots": crop_data}))
		if show_message: say("Farm saved.")
	elif show_message: say("Could not save. Check storage permissions.")

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_FILE): return
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(SAVE_FILE))
	if not parsed is Dictionary: return
	coins = maxi(0, int(parsed.get("coins", 500)))
	harvests = maxi(0, int(parsed.get("harvests", 0)))
	player.position = Vector2(clampf(float(parsed.get("x", 820)), 60, 2340), clampf(float(parsed.get("y", 710)), 730, 1520))
	var crops = parsed.get("plots", [])
	if crops is Array:
		for i in range(mini(crops.size(), plots.size())):
			if crops[i] is Dictionary:
				plots[i].stage = clampi(int(crops[i].get("stage", 0)), 0, 3)
				plots[i].growth = clampf(float(crops[i].get("growth", 0)), 0, GROW_SECONDS)
	say("Welcome back. Your farm has been restored.")

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED and is_instance_valid(player):
		save_game(false)

func _draw() -> void:
	# Sky, sea and a single smooth Kaimon-inspired coastal mountain.
	draw_rect(Rect2(0, 0, 2400, 510), Color("9cc8db"))
	draw_rect(Rect2(0, 280, 2400, 240), Color("518aa9"))
	draw_colored_polygon(PackedVector2Array([Vector2(1200, 310), Vector2(1340, 285), Vector2(1480, 238), Vector2(1570, 180), Vector2(1640, 98), Vector2(1670, 82), Vector2(1700, 98), Vector2(1770, 180), Vector2(1860, 238), Vector2(2000, 285), Vector2(2140, 310)]), Color("527b72"))
	for i in range(30):
		draw_line(Vector2(100 + i * 78, 360 + (i % 5) * 25), Vector2(145 + i * 78, 360 + (i % 5) * 25), Color("84b4c7"), 2)
	draw_rect(Rect2(0, 490, 2400, 1110), Color("75945b"))
	draw_rect(Rect2(260, 700, 1720, 74), Color("c5b080"))
	draw_rect(Rect2(1120, 720, 82, 850), Color("c5b080"))
	draw_rect(Rect2(290, 1110, 1600, 64), Color("c5b080"))
	for point in grass:
		if (point.y > 690 and point.y < 788) or (point.x > 1100 and point.x < 1220) or (point.y > 1100 and point.y < 1185): continue
		if Rect2(710, 740, 420, 250).has_point(point): continue
		draw_line(point, point + Vector2(-3, -7), Color("567844"), 2)
		if int(point.x) % 7 == 0:
			draw_circle(point + Vector2(0, -8), 3, Color("f4df9c"))
	# Terrace retaining wall.
	draw_rect(Rect2(700, 997, 420, 23), Color("888675"))
	for i in range(14): draw_rect(Rect2(700 + i * 30, 997, 28, 21), Color("a19d84"), false, 2)
	for i in range(9):
		tree(Vector2(120 + i * 260, 560))
	for pos in [Vector2(150, 920), Vector2(210, 1330), Vector2(2110, 980), Vector2(2010, 1260), Vector2(2180, 1410)]: tree(pos)
	for rock in rocks:
		draw_circle(rock, 32, Color("6d776c"))
		draw_circle(rock + Vector2(-7, -8), 22, Color("9a9e8a"))
	draw_rect(Rect2(1350, 1150, 60, 250), Color("654933"))
	for i in range(7): draw_line(Vector2(1350, 1160 + i * 35), Vector2(1410, 1160 + i * 35), Color("977348"), 3)
	# Placeholder expansion building and gates.
	draw_rect(Rect2(1730, 680, 240, 190), Color("a78056"))
	draw_colored_polygon(PackedVector2Array([Vector2(1710, 680), Vector2(1850, 610), Vector2(1990, 680)]), Color("665d52"))
	draw_rect(Rect2(1810, 770, 75, 100), Color("514b3d"))
	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(1740, 920), "Future animal yard", HORIZONTAL_ALIGNMENT_LEFT, -1, 23, Color("fff0cb"))
	draw_string(font, Vector2(1460, 1280), "Woodland • future expansion", HORIZONTAL_ALIGNMENT_LEFT, -1, 23, Color("fff0cb"))
	for i in range(10):
		var x := 1700 + i * 32
		draw_line(Vector2(x, 960), Vector2(x, 1020), Color("745d3d"), 8)
	draw_line(Vector2(1700, 975), Vector2(1990, 975), Color("9b7c50"), 8)
	for i in range(plots.size()):
		var plot: Dictionary = plots[i]
		var pos: Vector2 = plot.position
		draw_rect(Rect2(pos - Vector2(29, 29), Vector2(58, 58)), Color("574532") if plot.stage == 2 else Color("816044"))
		for offset in [-16, 0, 16]: draw_line(pos + Vector2(-22, offset), pos + Vector2(22, offset), Color("9a7550"), 2)
		if i == nearest: draw_rect(Rect2(pos - Vector2(30, 30), Vector2(60, 60)), Color("ffe0a0"), false, 3)
		if plot.stage > 0:
			draw_line(pos + Vector2(0, 10), pos + Vector2(0, -9), Color("2e613e"), 4)
			draw_circle(pos + Vector2(-7, -3), 7, Color("85b756"))
			draw_circle(pos + Vector2(7, -7), 7, Color("85b756"))
		if plot.stage == 1: draw_circle(pos + Vector2(17, -17), 4, Color("dfba72"))
		if plot.stage == 2:
			draw_rect(Rect2(pos + Vector2(-22, 21), Vector2(44 * minf(plot.growth / GROW_SECONDS, 1), 3)), Color("89cbd8"))
		if plot.stage == 3: draw_circle(pos + Vector2(0, -11), 10, Color("ecc161"))

func tree(pos: Vector2) -> void:
	draw_rect(Rect2(pos - Vector2(8, 35), Vector2(16, 45)), Color("77583c"))
	draw_circle(pos + Vector2(0, -66), 55, Color("395c3d"))
	draw_circle(pos + Vector2(-19, -78), 35, Color("547b43"))
	draw_circle(pos + Vector2(18, -90), 32, Color("769449"))
