extends Node2D

const WORLD := Vector2(2400, 1600)
const GROW_SECONDS := 12.0
const SPEED := 200.0
const SAVE_FILE := "user://farm_save.json"
const MAP_SCALE := 1.5625
const PLAYER_RADIUS := 12.0
const FarmhouseScene = preload("res://Farmhouse.tscn")
const InteriorScene = preload("res://FarmhouseInterior.tscn")
const ROOM_ORIGIN := Vector2(3000, 0)
const SEASONS := ["Spring", "Summer", "Autumn", "Winter"]
var outdoor_world: Node2D
var farmhouse: Node2D
var interior: Node2D
var inside_house := false
var day := 1
const WAKE_MINUTE := 360.0
const LATE_MINUTE := 1260.0
const MAX_HEALTH := 100.0
const WORK_COSTS := [2.0, 2.0, 3.0]
var clock_minutes := WAKE_MINUTE
var health := MAX_HEALTH
var paused_by_player := false
var window_focused := true
var health_bar: ProgressBar
var health_label: Label
var sleep_prompt: Control
var confirming_sleep := false
# Coordinates follow the visible silhouettes on the 1536 x 1024 map.
const SOLID_OUTLINES := [
	[Vector2(5, 550), Vector2(50, 475), Vector2(130, 390), Vector2(325, 390), Vector2(415, 485), Vector2(380, 600), Vector2(120, 630), Vector2(5, 615)],
	[Vector2(925, 295), Vector2(990, 250), Vector2(1090, 265), Vector2(1130, 305), Vector2(1115, 378), Vector2(935, 375)],
	[Vector2(875, 0), Vector2(1536, 0), Vector2(1536, 520), Vector2(1370, 450), Vector2(1260, 415), Vector2(1150, 375), Vector2(1140, 245), Vector2(900, 215)],
	[Vector2(1115, 875), Vector2(1220, 815), Vector2(1400, 785), Vector2(1536, 805), Vector2(1536, 1024), Vector2(1320, 1024), Vector2(1220, 950)]
]
const JoystickScript = preload("res://Joystick.gd")
var player: CharacterBody2D
var camera: Camera2D
var farmer: Sprite2D
const WALK_TEXTURE = preload("res://assets/fieldwork-boy-v2.png")
const GIRL_TEXTURE = preload("res://assets/fieldwork-girl-v2.png")
const BOY_SIDE_TEXTURE = preload("res://assets/fieldwork-boy-side-v3.png")
const GIRL_SIDE_TEXTURE = preload("res://assets/fieldwork-girl-side-v3.png")
const STRIDE_DISTANCE := 24.0
var active_texture: Texture2D = WALK_TEXTURE
var side_texture: Texture2D
var side_regions: Array[Rect2] = []
var side_offsets: Array[Vector2] = []
var walk_distance := 0.0
var side_scale := 1.0
var front_scale := 1.0
var character_choice := "boy"
var choosing_character := false
var character_picker: Control
const IDLE_TEXTURE = preload("res://assets/farmer-v2.png")
var walk_regions: Array[Rect2] = []
var walk_clock := 0.0
var walk_frame := -2
var facing_direction := 0
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
	outdoor_world = Node2D.new()
	outdoor_world.name = "OutdoorWorld"
	add_child(outdoor_world)
	$Environment.reparent(outdoor_world)
	farmhouse = FarmhouseScene.instantiate()
	outdoor_world.add_child(farmhouse)
	interior = InteriorScene.instantiate()
	interior.position = ROOM_ORIGIN
	interior.visible = false
	add_child(interior)
	for row in range(3):
		for col in range(5):
			plots.append({"position": Vector2(300 + col * 68, 1200 + row * 68), "stage": 0, "growth": 0.0})
	for rect in [Rect2(-24, -24, 2448, 24), Rect2(-24, 1600, 2448, 24), Rect2(-24, 0, 24, 1600), Rect2(2400, 0, 24, 1600)]:
		obstacle(rect)
	# The separate farmhouse scene owns its facade collision.
	for outline in SOLID_OUTLINES.slice(1):
		var body := StaticBody2D.new()
		var collision := CollisionPolygon2D.new()
		collision.polygon = world_outline(outline)
		body.add_child(collision)
		outdoor_world.add_child(body)
	player = CharacterBody2D.new()
	player.position = Vector2(450, 1120)
	player.z_index = 5
	add_child(player)
	var collider := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = PLAYER_RADIUS
	collider.shape = shape
	player.add_child(collider)
	farmer = Sprite2D.new()
	farmer.texture = preload("res://assets/farmer-v2.png")
	farmer.region_enabled = true
	farmer.region_rect = farmer.texture.get_image().get_used_rect()
	farmer.scale = Vector2.ONE * (180.0 / farmer.region_rect.size.y)
	farmer.position.y = -90
	player.add_child(farmer)
	set_character("boy")
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
	refresh_hud()
	if not FileAccess.file_exists(SAVE_FILE): show_character_picker()
	queue_redraw()

func obstacle(rect: Rect2) -> void:
	var body := StaticBody2D.new()
	body.position = rect.get_center()
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = rect.size
	collision.shape = shape
	body.add_child(collision)
	outdoor_world.add_child(body)

func world_outline(outline: Array) -> PackedVector2Array:
	var points := PackedVector2Array()
	for point in outline:
		points.append(point * MAP_SCALE)
	return points

func is_walkable(position: Vector2) -> bool:
	if not Rect2(Vector2.ONE * PLAYER_RADIUS, WORLD - Vector2.ONE * PLAYER_RADIUS * 2.0).has_point(position):
		return false
	for outline in SOLID_OUTLINES:
		var points := world_outline(outline)
		if Geometry2D.is_point_in_polygon(position, points):
			return false
		for index in range(points.size()):
			var closest := Geometry2D.get_closest_point_to_segment(position, points[index], points[(index + 1) % points.size()])
			if position.distance_to(closest) <= PLAYER_RADIUS:
				return false
	return true

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
	health_bar = ProgressBar.new()
	health_bar.max_value = MAX_HEALTH
	health_bar.show_percentage = false
	health_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	health_bar.add_theme_stylebox_override("background", parchment())
	hud.add_child(health_bar)
	health_label = Label.new()
	health_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	health_label.add_theme_color_override("font_color", Color("493b2d"))
	health_label.add_theme_font_size_override("font_size", 16)
	health_bar.add_child(health_label)
	health_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
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
		var button := make_button(["Seed", "Water", "Harvest"][i], func(): select_tool(index))
		button.custom_minimum_size = Vector2(104, 58)
		tool_bar.add_child(button)
		tool_buttons.append(button)
	var save_button := make_button("Save", save_game)
	save_button.name = "SaveButton"
	hud.add_child(save_button)
	var character_button := make_button("Farmer", show_character_picker)
	character_button.name = "CharacterButton"
	hud.add_child(character_button)
	var pause_button := make_button("Pause", toggle_pause)
	pause_button.name = "PauseButton"
	hud.add_child(pause_button)
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
	health_bar.position = margin + Vector2(0, 94)
	health_bar.size = Vector2(240, 28)
	joystick.position = Vector2(margin.x, view.y - bottom - 132)
	action_button.position = Vector2(view.x - right - 138, view.y - bottom - 92)
	action_button.size = Vector2(138, 72)
	tool_bar.position = Vector2((view.x - 328) / 2, view.y - bottom - 66)
	message_label.position = Vector2(margin.x, margin.y + 132)
	message_label.size = Vector2(view.x - margin.x - right, 40)
	hud.get_node("SaveButton").position = Vector2(view.x - right - 95, margin.y)
	hud.get_node("CharacterButton").position = Vector2(view.x - right - 200, margin.y)
	hud.get_node("PauseButton").position = Vector2(view.x - right - 95, margin.y + 50)

func toggle_pause() -> void:
	paused_by_player = not paused_by_player
	joystick.direction = Vector2.ZERO
	player.velocity = Vector2.ZERO
	hud.get_node("PauseButton").text = "Resume" if paused_by_player else "Pause"
	refresh_hud()

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT: window_focused = false
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN: window_focused = true
	if what == NOTIFICATION_APPLICATION_PAUSED and is_instance_valid(player):
		save_game(false)

func clock_text() -> String:
	var minute := int(clock_minutes)
	var hour := int(minute / 60)
	return "%d:%02d %s" % [12 if hour % 12 == 0 else hour % 12, minute % 60, "AM" if hour < 12 else "PM"]

func advance_clock(seconds: float) -> void:
	# One real second advances one game minute. Midnight rolls the calendar.
	if choosing_character or confirming_sleep or paused_by_player or not window_focused: return
	var remaining := maxf(0.0, seconds)
	while remaining > 0.0:
		var step := minf(remaining, 1440.0 - clock_minutes)
		var night_minutes := maxf(0.0, clock_minutes + step - maxf(clock_minutes, LATE_MINUTE))
		if clock_minutes < WAKE_MINUTE:
			night_minutes += minf(step, WAKE_MINUTE - clock_minutes)
		health = maxf(0.0, health - night_minutes * 0.1)
		clock_minutes += step
		remaining -= step
		if clock_minutes >= 1440.0:
			clock_minutes = 0.0
			day += 1

func select_tool(index: int) -> void:
	selected_tool = index
	for i in range(tool_buttons.size()):
		tool_buttons[i].modulate = Color("ffdb89") if i == index else Color.WHITE
	action_button.text = ["Plant", "Water", "Harvest"][index]
	if is_instance_valid(player): refresh_hud()

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_1: select_tool(0)
		if event.physical_keycode == KEY_2: select_tool(1)
		if event.physical_keycode == KEY_3: select_tool(2)
		if event.physical_keycode in [KEY_SPACE, KEY_E, KEY_ENTER]: interact()

func _physics_process(delta: float) -> void:
	if choosing_character or confirming_sleep or paused_by_player or not window_focused: return
	advance_clock(delta)
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if Input.is_physical_key_pressed(KEY_A): direction.x -= 1
	if Input.is_physical_key_pressed(KEY_D): direction.x += 1
	if Input.is_physical_key_pressed(KEY_W): direction.y -= 1
	if Input.is_physical_key_pressed(KEY_S): direction.y += 1
	direction += joystick.direction
	player.velocity = direction.limit_length() * SPEED
	var previous_position := player.position
	player.move_and_slide()
	var travel := player.position.distance_to(previous_position)
	update_walk(delta, travel > 0.01, direction, travel)
	nearest = -1
	var distance := 78.0
	for i in range(plots.size()):
		var candidate: float = player.position.distance_to(plots[i].position)
		if not inside_house and candidate < distance:
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
	refresh_hud()
	queue_redraw()

func interaction_action() -> String:
	if inside_house:
		var local_position := player.position - ROOM_ORIGIN
		if local_position.distance_to(interior.BED_APPROACH) < 100.0: return "sleep"
		if local_position.distance_to(interior.EXIT) < 90.0: return "leave"
	elif player.position.distance_to(farmhouse.DOOR_POSITION) < 90.0:
		return "enter"
	return ""

func calendar_text() -> String:
	var season_index := int((day - 1) / 28) % 4
	return "%s %d  |  Year %d" % [SEASONS[season_index], (day - 1) % 28 + 1, int((day - 1) / 112) + 1]

func refresh_hud() -> void:
	date_label.text = "%s\n%s   •   ¥%d\nHarvested %d" % [calendar_text(), clock_text(), coins, harvests]
	health_bar.value = health
	health_label.text = "Health %d / 100" % int(ceil(health))
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color("a5be83") if health >= 50 else (Color("e7c786") if health >= 25 else Color("da927c"))
	fill.set_corner_radius_all(4)
	health_bar.add_theme_stylebox_override("fill", fill)
	farmer.modulate = Color("d1c7bb") if health < 25 else Color.WHITE
	tool_bar.visible = not inside_house
	var action := interaction_action()
	action_button.disabled = false
	match action:
		"enter": action_button.text = "Enter"
		"leave": action_button.text = "Leave"
		"sleep": action_button.text = "Sleep"
		_:
			action_button.text = "Explore" if inside_house else ["Plant", "Water", "Harvest"][selected_tool]
			action_button.disabled = inside_house
	var hint := crop_hint()
	match action:
		"enter": hint = "Welcome home. Enter the farmhouse."
		"leave": hint = "Leave the house to return to your farm."
		"sleep": hint = "Rest in bed to start the next day."
		_:
			if inside_house: hint = "Walk beside the bed to sleep, or the front doorway to leave."
	message_label.text = toast if toast_time > 0 else hint
	if paused_by_player: message_label.text = "Paused. Press Resume to continue."
	elif toast_time <= 0 and health < 25:
		message_label.text = "Health is low. Rest in bed." if health >= WORK_COSTS[selected_tool] else "Too tired to work. Rest in bed."

func set_location(indoors: bool, destination: Vector2) -> void:
	inside_house = indoors
	RenderingServer.set_default_clear_color(Color("293e37") if indoors else Color("78b9df"))
	outdoor_world.visible = not indoors
	interior.visible = indoors
	player.collision_mask = 2 if indoors else 1
	player.position = destination
	player.velocity = Vector2.ZERO
	joystick.direction = Vector2.ZERO
	nearest = -1
	update_walk(0.0, false, Vector2.DOWN)
	camera.limit_left = int(ROOM_ORIGIN.x) if indoors else 0
	camera.limit_top = 0
	camera.limit_right = int(ROOM_ORIGIN.x + interior.SIZE.x) if indoors else int(WORLD.x)
	camera.limit_bottom = int(interior.SIZE.y) if indoors else int(WORLD.y)
	camera.offset = Vector2(0, -60) if indoors else Vector2(0, -100)
	camera.reset_smoothing()
	refresh_hud()
	queue_redraw()

func enter_house() -> void:
	if inside_house: return
	set_location(true, ROOM_ORIGIN + interior.ENTRY)
	say("Home sweet home. The bed is in the right corner.")
	save_game(false)

func leave_house() -> void:
	if not inside_house: return
	set_location(false, farmhouse.DOOR_POSITION + Vector2(0, 35))
	say("Back on the farm.")
	save_game(false)

func offer_sleep() -> void:
	if not inside_house or confirming_sleep: return
	confirming_sleep = true
	player.velocity = Vector2.ZERO
	joystick.direction = Vector2.ZERO
	sleep_prompt = ColorRect.new()
	sleep_prompt.color = Color(0.08, 0.13, 0.10, 0.85)
	hud.add_child(sleep_prompt)
	sleep_prompt.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var center := CenterContainer.new()
	sleep_prompt.add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", parchment())
	center.add_child(panel)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 16)
	panel.add_child(column)
	var title := Label.new()
	title.text = "Sleep until tomorrow?"
	title.add_theme_color_override("font_color", Color("493b2d"))
	title.add_theme_font_size_override("font_size", 24)
	column.add_child(title)
	column.add_child(make_button("Sleep until morning", sleep_until_morning))
	column.add_child(make_button("Stay awake", cancel_sleep))

func cancel_sleep() -> void:
	confirming_sleep = false
	if is_instance_valid(sleep_prompt): sleep_prompt.queue_free()

func sleep_until_morning() -> void:
	if not inside_house or not confirming_sleep: return
	cancel_sleep()
	if clock_minutes >= WAKE_MINUTE: day += 1
	clock_minutes = WAKE_MINUTE
	health = MAX_HEALTH
	for plot in plots:
		if plot.stage == 2:
			plot.growth = GROW_SECONDS
			plot.stage = 3
	set_location(true, ROOM_ORIGIN + interior.BED_APPROACH)
	say("Good morning! Watered crops are ready. %s." % calendar_text())
	save_time = 0.0
	save_game(false)

func crop_hint() -> String:
	if nearest < 0 or nearest >= plots.size():
		return "Move beside a crop bed to tend it."
	var plot: Dictionary = plots[nearest]
	match int(plot.stage):
		0:
			return "Empty bed. Select Seed and Plant (¥5)." if coins >= 5 else "Seeds cost ¥5. Harvest a ripe crop to earn yen."
		1:
			return "This seed needs water. Select Water and use it."
		2:
			var seconds := maxi(1, int(ceil(GROW_SECONDS - float(plot.growth))))
			return "Growing. Ready in %ds." % seconds
		3:
			return "Ready! Select Harvest to collect ¥20."
	return "Choose a tool, then use it beside a crop bed."

func say(text: String) -> void:
	toast = text
	toast_time = 4.0

func interact() -> void:
	if choosing_character or confirming_sleep or paused_by_player: return
	match interaction_action():
		"enter":
			enter_house()
			return
		"leave":
			leave_house()
			return
		"sleep":
			offer_sleep()
			return
	if inside_house: return
	if nearest < 0:
		say("Move closer to a crop bed.")
		return
	if health < WORK_COSTS[selected_tool]:
		say("Too tired to work. Rest in bed to restore Health.")
		return
	var plot: Dictionary = plots[nearest]
	match selected_tool:
		0:
			if plot.stage != 0: say("This bed is already planted.")
			elif coins < 5: say("Seeds cost ¥5.")
			else:
				coins -= 5
				health -= WORK_COSTS[0]
				plot.stage = 1
				plot.growth = 0.0
				say("Planted! Select Water to help it grow.")
		1:
			if plot.stage == 1:
				health -= WORK_COSTS[1]
				plot.stage = 2
				say("Watered. Ready to harvest in 12 seconds.")
			elif plot.stage == 0: say("Plant a seed first.")
			else: say("This crop already has enough water.")
		2:
			if plot.stage == 3:
				health -= WORK_COSTS[2]
				plot.stage = 0
				plot.growth = 0.0
				coins += 20
				harvests += 1
				say("Harvested! +¥20. This bed can be replanted.")
			else: say("Harvest crops with golden leaves when ready.")
	save_game(false)

func save_game(show_message: bool = true) -> void:
	if choosing_character: return
	var crop_data: Array = []
	for plot in plots:
		crop_data.append({"stage": plot.stage, "growth": plot.growth})
	var file := FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify({"version": 4, "day": day, "clock_minutes": clock_minutes, "health": health, "location": "house" if inside_house else "farm", "character": character_choice, "coins": coins, "harvests": harvests, "x": player.position.x, "y": player.position.y, "plots": crop_data}))
		if show_message: say("Farm saved.")
	elif show_message: say("Could not save. Check storage permissions.")

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_FILE): return
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(SAVE_FILE))
	if not parsed is Dictionary: return
	coins = maxi(0, int(parsed.get("coins", 500)))
	set_character(str(parsed.get("character", "boy")))
	harvests = maxi(0, int(parsed.get("harvests", 0)))
	day = maxi(1, int(parsed.get("day", 1)))
	clock_minutes = clampf(float(parsed.get("clock_minutes", WAKE_MINUTE)), 0.0, 1439.999)
	health = clampf(float(parsed.get("health", MAX_HEALTH)), 0.0, MAX_HEALTH)
	var destination := Vector2(450, 1120)
	var indoors := str(parsed.get("location", "farm")) == "house"
	if indoors: destination = ROOM_ORIGIN + interior.ENTRY
	if int(parsed.get("version", 1)) >= 2:
		var saved_position := Vector2(float(parsed.get("x", 450)), float(parsed.get("y", 1120)))
		if (indoors and interior.is_walkable(saved_position - ROOM_ORIGIN)) or (not indoors and is_walkable(saved_position)):
			destination = saved_position
	var crops = parsed.get("plots", [])
	if crops is Array:
		for i in range(mini(crops.size(), plots.size())):
			if crops[i] is Dictionary:
				plots[i].stage = clampi(int(crops[i].get("stage", 0)), 0, 3)
				plots[i].growth = clampf(float(crops[i].get("growth", 0)), 0, GROW_SECONDS)
	set_location(indoors, destination)
	say("Welcome back. Your farm has been restored.")

func update_walk(delta: float, moving: bool, direction: Vector2 = Vector2.ZERO, travel: float = -1.0) -> void:
	if direction.length() > 0.15:
		facing_direction = posmod(int(round((direction.angle() - PI / 2.0) / (PI / 4.0))), 8)
	walk_clock = walk_clock + delta if moving else 0.0
	walk_distance = walk_distance + (travel if travel >= 0.0 else delta * SPEED) if moving else 0.0
	var step := int(walk_distance / STRIDE_DISTANCE) % 4 if moving else 0
	var next_frame := facing_direction * 4 + step
	if next_frame == walk_frame: return
	walk_frame = next_frame
	farmer.flip_h = facing_direction in [5, 6, 7]
	if facing_direction in [0, 4]:
		farmer.scale = Vector2.ONE * front_scale
		farmer.texture = active_texture
		farmer.region_rect = walk_regions[facing_direction * 2 + step % 2]
		farmer.position = Vector2(0, -farmer.region_rect.size.y * farmer.scale.y * 0.5)
	else:
		var row: int = {1: 1, 2: 0, 3: 2, 5: 2, 6: 0, 7: 1}[facing_direction]
		var index := row * 4 + step
		farmer.texture = side_texture
		farmer.region_rect = side_regions[index]
		# Preserve the cell's hip center and shared ground line instead of
		# re-centering each trimmed pose, which makes boots slide sideways.
		farmer.position = side_offsets[index] * side_scale
		if farmer.flip_h: farmer.position.x = -farmer.position.x
		farmer.scale = Vector2.ONE * side_scale
func sprite_bounds(image: Image) -> Rect2i:
	# Ignore nearly transparent export noise when measuring a stride.
	var first := image.get_size()
	var last := Vector2i(-1, -1)
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			if image.get_pixel(x, y).a < 0.1:
				continue
			first.x = mini(first.x, x)
			first.y = mini(first.y, y)
			last.x = maxi(last.x, x)
			last.y = maxi(last.y, y)
	return Rect2i(first, last - first + Vector2i.ONE) if last.x >= 0 else Rect2i(Vector2i.ZERO, image.get_size())

func set_character(choice: String) -> void:
	character_choice = "girl" if choice == "girl" else "boy"
	active_texture = GIRL_TEXTURE if character_choice == "girl" else WALK_TEXTURE
	side_texture = GIRL_SIDE_TEXTURE if character_choice == "girl" else BOY_SIDE_TEXTURE
	walk_regions.clear()
	var sheet_image := active_texture.get_image()
	var cell := sheet_image.get_size() / 4
	var tallest_frame := 1.0
	for index in range(16):
		var origin := Vector2i(index % 4, index / 4) * cell
		var bounds := sprite_bounds(sheet_image.get_region(Rect2i(origin, cell)))
		walk_regions.append(Rect2(bounds.position + origin, bounds.size))
		tallest_frame = maxf(tallest_frame, bounds.size.y)
	front_scale = 180.0 / tallest_frame
	farmer.scale = Vector2.ONE * front_scale
	build_side_regions()
	walk_frame = -2
	update_walk(0.0, false)

func build_side_regions() -> void:
	side_regions.clear()
	side_offsets.clear()
	var sheet := side_texture.get_image()
	var cell := Vector2i(sheet.get_width() / 4, sheet.get_height() / 3)
	var tallest := 1.0
	for row in range(3):
		var bounds_list: Array[Rect2i] = []
		var ground := 0.0
		for phase in range(4):
			var bounds := sprite_bounds(sheet.get_region(Rect2i(Vector2i(phase, row) * cell, cell)))
			bounds_list.append(bounds)
			ground = maxf(ground, bounds.end.y)
			tallest = maxf(tallest, bounds.size.y)
		for phase in range(4):
			var bounds := bounds_list[phase]
			side_regions.append(Rect2(bounds.position + Vector2i(phase, row) * cell, bounds.size))
			side_offsets.append(Vector2(bounds.get_center()) - Vector2(cell.x * 0.5, ground))
	side_scale = 180.0 / tallest

func choose_character(choice: String) -> void:
	set_character(choice)
	choosing_character = false
	joystick.direction = Vector2.ZERO
	if is_instance_valid(character_picker): character_picker.queue_free()
	save_game(false)
	say("Welcome home. Your farmer is ready.")

func show_character_picker() -> void:
	if choosing_character or confirming_sleep: return
	choosing_character = true
	player.velocity = Vector2.ZERO
	joystick.direction = Vector2.ZERO
	character_picker = ColorRect.new()
	character_picker.color = Color(0.08, 0.13, 0.10, 0.85)
	hud.add_child(character_picker)
	character_picker.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var center := CenterContainer.new()
	character_picker.add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", parchment())
	center.add_child(panel)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 16)
	panel.add_child(column)
	var title := Label.new()
	title.text = "Choose your farmer"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color("493b2d"))
	title.add_theme_font_size_override("font_size", 24)
	column.add_child(title)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 24)
	column.add_child(row)
	for choice in ["boy", "girl"]:
		var option := VBoxContainer.new()
		row.add_child(option)
		var texture: Texture2D = GIRL_TEXTURE if choice == "girl" else WALK_TEXTURE
		var atlas := AtlasTexture.new()
		atlas.atlas = texture
		atlas.region = Rect2(Vector2.ZERO, texture.get_size() / 4.0)
		var preview := TextureRect.new()
		preview.texture = atlas
		preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		preview.custom_minimum_size = Vector2(150, 180)
		option.add_child(preview)
		var button := make_button("Girl" if choice == "girl" else "Boy", choose_character.bind(choice))
		button.custom_minimum_size = Vector2(150, 58)
		option.add_child(button)

func _draw() -> void:
	if inside_house: return
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
		draw_colored_polygon(PackedVector2Array([pos, tip + Vector2(-side * 4, -3), tip + Vector2(side * 4, 3)]), Color("b7c269") if stage == 3 else Color("5d933d"))
		draw_line(pos + Vector2(0, -3), tip, Color("98b54c"), 2)
	if stage == 3:
		draw_circle(pos + Vector2(0, -5), 8, Color("f3d8a1"))
		draw_circle(pos + Vector2(-3, -8), 4, Color("fff1c4"))


