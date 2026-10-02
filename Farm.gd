extends Node2D

const WORLD := Vector2(2400, 1600)
const GROW_SECONDS := 12.0
const SPEED := 200.0
const SAVE_FILE := "user://farm_save.json"
const JoystickScript = preload("res://Joystick.gd")
var player: CharacterBody2D
var camera: Camera2D
var farmer: Sprite2D
const WALK_TEXTURE = preload("res://assets/farmer-walk.png")
const IDLE_TEXTURE = preload("res://assets/farmer-v2.png")
var walk_regions: Array[Rect2] = []
var walk_clock := 0.0
var walk_frame := -2
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
	for row in range(3):
		for col in range(5):
			plots.append({"position": Vector2(300 + col * 68, 1120 + row * 68), "stage": 0, "growth": 0.0})
	# Buildings, waterfront, and crop terrace walls aligned with the painted map.
	for rect in [Rect2(0, 510, 2400, 24), Rect2(0, 1576, 2400, 24), Rect2(0, 510, 24, 1090), Rect2(2376, 510, 24, 1090), Rect2(30, 650, 550, 180), Rect2(1380, 390, 270, 125), Rect2(1690, 1160, 690, 320), Rect2(65, 1080, 24, 260), Rect2(70, 1340, 840, 24), Rect2(70, 1020, 760, 24)]:
		obstacle(rect)
	player = CharacterBody2D.new()
	player.position = Vector2(450, 1120)
	player.z_index = 5
	add_child(player)
	var collider := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 12
	collider.shape = shape
	player.add_child(collider)
	farmer = Sprite2D.new()
	farmer.texture = preload("res://assets/farmer-v2.png")
	farmer.region_enabled = true
	farmer.region_rect = farmer.texture.get_image().get_used_rect()
	farmer.scale = Vector2.ONE * (180.0 / farmer.region_rect.size.y)
	farmer.position.y = -90
	player.add_child(farmer)
	var sheet_image := WALK_TEXTURE.get_image()
	var cell := sheet_image.get_size() / 2
	for index in range(4):
		var origin := Vector2i(index % 2, index / 2) * cell
		var bounds := sheet_image.get_region(Rect2i(origin, cell)).get_used_rect()
		walk_regions.append(Rect2(bounds.position + origin, bounds.size))
	camera = Camera2D.new()
	camera.offset = Vector2(0, -100)
	camera.zoom = Vector2(0.70, 0.70)
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 7
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = 2400
	camera.limit_bottom = 1600
	player.add_child(camera)
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
	var previous_position := player.position
	player.move_and_slide()
	if absf(direction.x) > 0.1: farmer.flip_h = direction.x < 0
	update_walk(delta, player.position.distance_to(previous_position) > 0.01)
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
		file.store_string(JSON.stringify({"version": 2, "coins": coins, "harvests": harvests, "x": player.position.x, "y": player.position.y, "plots": crop_data}))
		if show_message: say("Farm saved.")
	elif show_message: say("Could not save. Check storage permissions.")

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_FILE): return
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(SAVE_FILE))
	if not parsed is Dictionary: return
	coins = maxi(0, int(parsed.get("coins", 500)))
	harvests = maxi(0, int(parsed.get("harvests", 0)))
	player.position = Vector2(450, 1120)
	if int(parsed.get("version", 1)) >= 2:
		player.position = Vector2(clampf(float(parsed.get("x", 450)), 60, 2340), clampf(float(parsed.get("y", 1120)), 550, 1520))
	var crops = parsed.get("plots", [])
	if crops is Array:
		for i in range(mini(crops.size(), plots.size())):
			if crops[i] is Dictionary:
				plots[i].stage = clampi(int(crops[i].get("stage", 0)), 0, 3)
				plots[i].growth = clampf(float(crops[i].get("growth", 0)), 0, GROW_SECONDS)
	say("Welcome back. Your farm has been restored.")

func update_walk(delta: float, moving: bool) -> void:
	walk_clock = walk_clock + delta if moving else 0.0
	var next_frame := int(walk_clock * 8.0) % 4 if moving else -1
	if next_frame == walk_frame: return
	walk_frame = next_frame
	farmer.texture = WALK_TEXTURE if moving else IDLE_TEXTURE
	farmer.region_rect = walk_regions[next_frame] if moving else Rect2(IDLE_TEXTURE.get_image().get_used_rect())
	farmer.scale = Vector2.ONE * (180.0 / farmer.region_rect.size.y)
	farmer.position.y = -90

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED and is_instance_valid(player):
		save_game(false)

func _draw() -> void:
	# Dynamic beds and crops sit over the static environment, never baked into it.
	for i in range(plots.size()):
		var plot: Dictionary = plots[i]
		var pos: Vector2 = plot.position
		var rng := RandomNumberGenerator.new()
		rng.seed = i + 72
		if plot.stage > 0:
			draw_colored_polygon(PackedVector2Array([pos + Vector2(-28, -25), pos + Vector2(26, -28), pos + Vector2(29, 24), pos + Vector2(-25, 28)]), Color(0.24, 0.16, 0.10, 0.38 if plot.stage == 2 else 0.20))
		for row in range(3):
			var y := -15 + row * 15
			draw_line(pos + Vector2(-22, y), pos + Vector2(22, y + 1), Color(0.28, 0.18, 0.10, 0.3), 2)
		for j in range(24):
			var dirt := pos + Vector2(rng.randf_range(-25, 25), rng.randf_range(-23, 23))
			draw_rect(Rect2(dirt, Vector2(2, 1)), Color(0.78, 0.58, 0.34, 0.35))
		if i == nearest:
			draw_rect(Rect2(pos - Vector2(29, 29), Vector2(58, 58)), Color(1.0, 0.89, 0.55, 0.8), false, 2)
		if plot.stage > 0:
			for offset in [Vector2(-12, 5), Vector2(13, -9)]:
				crop(pos + offset, plot.stage)
		if plot.stage == 1:
			draw_circle(pos + Vector2(22, -23), 3, Color("cfab76"))
		if plot.stage == 2:
			draw_rect(Rect2(pos + Vector2(-22, 24), Vector2(44 * minf(plot.growth / GROW_SECONDS, 1), 2)), Color("9acbd0"))

func crop(pos: Vector2, stage: int) -> void:
	var spread := 1.3 if stage == 3 else 0.8
	draw_circle(pos + Vector2(1, 3), 10 * spread, Color(0.14, 0.22, 0.10, 0.30))
	draw_line(pos, pos + Vector2(0, -15 * spread), Color("36542b"), 3)
	for side in [-1, 1]:
		var tip := pos + Vector2(side * 12, -15) * spread
		draw_colored_polygon(PackedVector2Array([pos, tip + Vector2(-3, -5), tip + Vector2(3, -6), tip + Vector2(5, 0), pos + Vector2(0, -7)]), Color("b7c269") if stage == 3 else Color("5d933d"))
		draw_line(pos + Vector2(0, -3), tip, Color("98b54c"), 2)
	if stage == 3:
		draw_circle(pos + Vector2(0, -5), 8, Color("f3d8a1"))
		draw_circle(pos + Vector2(-3, -8), 4, Color("fff1c4"))



