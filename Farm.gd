extends Node2D

const WORLD := Vector2(3000, 2000)
const GROW_SECONDS := 12.0 # Legacy save compatibility only.
const CROPS := {"Turnip": {"days": 2, "pack": 25, "sale": 20, "color": "e6dac0"}, "Potato": {"days": 3, "pack": 40, "sale": 35, "color": "c39e72"}, "Strawberry": {"days": 4, "pack": 60, "sale": 55, "color": "bf7868"}}
const SHIPPING_BOX := Vector2(370, 650)
const BARN_DOOR := Vector2(2420, 435)
var resources: Node2D
var selected_crop := "Turnip"
var extra_seeds := {"Potato": 0, "Strawberry": 0}
var produce := {"Turnip": 0, "Potato": 0, "Strawberry": 0}
var shipping_queue := {"Turnip": 0, "Potato": 0, "Strawberry": 0}
const SPEED := 200.0
const RUN_SPEED := 340.0
var SAVE_FILE := "user://draft_save.json"
const TownScript = preload("res://Town.gd")
const RoadScript = preload("res://SouthRoad.gd")
const TOWN_ORIGIN := Vector2(6000, 0)
const ROAD_ORIGIN := Vector2(9000, 0)
const FARM_EXIT := Vector2(1485, 140)
const RegionScript = preload("res://Region.gd")
const Cast = preload("res://Cast.gd")
const CharacterScenes = preload("res://CharacterScenes.gd")
const REGION_ORIGINS := {"tea": Vector2(12000, 0), "harbor": Vector2(15000, 0), "mountain": Vector2(18000, 0), "historic": Vector2(21000, 0)}
var regions: Dictionary = {}
const ShopScript = preload("res://ShopInterior.gd")
var SHOP_ORIGIN := Vector2(24000, 0)
var shops: Dictionary = {}
var polish: Node2D
var shop_name := ""
var lost_item_stage := 0
var tea_delivery_stage := 0
var mine_lesson_seen := false
var ore_basket := {"Copper": 0, "Iron": 0}
var ore_shipping := {"Copper": 0, "Iron": 0}
var ore_picked_days := [0, 0, 0, 0]
const ORE := {"Copper": 30, "Iron": 50}
const MINE_SPOTS := [Vector2(300, 395), Vector2(800, 395), Vector2(300, 595), Vector2(800, 595)]
var tea_lesson_seen := false
var tea_leaves := 0
var packed_tea := 0
var tea_shipping := 0
var tea_picked_days := [0, 0, 0]
const TEA_SPOTS := [Vector2(860,826),Vector2(860,996),Vector2(1333,844)]
const FISH := {"Sardine": 12, "Mackerel": 25, "Sea Bream": 40}
const FISHING_SPOTS := [Vector2(600,865),Vector2(600,965)]
var fish_basket := {"Sardine": 0, "Mackerel": 0, "Sea Bream": 0}
var fish_shipping := {"Sardine": 0, "Mackerel": 0, "Sea Bream": 0}
var fishing_active := false
var fishing_elapsed := 0.0
var fish_catches := 0
var fishing_quest_stage := 0
const REGIONAL_ROOMS := {"Onsen Resort":["mountain",Vector2(615,445)],"Mountain Lodge":["mountain",Vector2(1073,480)],"Mountain Carpentry":["mountain",Vector2(1427,715)],"Mine":["mountain",Vector2(1380,205)],"Tea Farmhouse":["tea",Vector2(453,330)],"Tea Processing Shed":["tea",Vector2(1042,630)],"Fishing Shop":["harbor",Vector2(665,550)],"Harbor Homes":["harbor",Vector2(1016,610)],"Shrine Residence":["historic",Vector2(406,363)]}
var quest_label: Label
var hud_elapsed := 0.0
var draw_elapsed := 0.0
var health_fill: StyleBoxFlat
var scene_steps: Array = []
var scene_step := 0
var scene_actors: Array = []
var active_scene := ""
var seen_scenes: Array = []
var interior_progress: Dictionary = {}
var farm_visitor: Node2D
var tea_challenge_button: Button
const Stewardship = preload("res://Stewardship.gd")
const InteriorLife = preload("res://InteriorLife.gd")
const BarnLife = preload("res://BarnLife.gd")
const FarmBuildings = preload("res://FarmBuildings.gd")
const WeatherLife = preload("res://WeatherLife.gd")
var festival_active := false
var festival_elapsed := 0.0
var current_festival: Dictionary = {}
var festival_center := Vector2(1200,910)
var festival_origin := TOWN_ORIGIN
var festival_people: Array = []
var festival_years: Array = []
var scheduled_gathering := false
var festival_button: Button
var battery_saver := true
var location := "farm"
var town: Node2D
var road: Node2D
var dialogue_open := false
var dialogue_panel: Control
var talking_npc: Node2D
var dialogue_lines: Array = []
var dialogue_index := 0
var dialogue_text: Label
var seeds := 5
var tool_level := 0
var pick_level := 0
var harvest_level := 0
var rain_overlay: Control
var friendship: Dictionary = {"Seira": 0, "Shohei": 0, "Akira": 0, "Taro": 0}
var talked_on_day: Dictionary = {}
var running := false
const MAP_SCALE := 1.953125
const PLAYER_RADIUS := 12.0
const FarmhouseScene = preload("res://Farmhouse.tscn")
const InteriorScene = preload("res://FarmhouseInterior.tscn")
const ROOM_ORIGIN := Vector2(3000, 0)
const SEASONS := ["Spring", "Summer", "Autumn", "Winter"]
var outdoor_world: Node2D
var season_scenery = preload("res://SeasonScenery.gd").new()
var wildlife: Node2D
var door_retry := 0.0
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
var sleep_in_progress := false
var sleep_sequence: Node2D
var recovering_launch := false
var game_ready := false
# Coordinates follow the visible silhouettes on the 1536 x 1024 map.
const SOLID_OUTLINES := [
    [Vector2(215,107),Vector2(495,107),Vector2(495,266),Vector2(215,266)],
    [Vector2(0,0),Vector2(720,0),Vector2(720,88),Vector2(100,88),Vector2(100,0)],
    [Vector2(810,0),Vector2(1536,0),Vector2(1536,95),Vector2(810,95)],
    [Vector2(0,0),Vector2(110,0),Vector2(110,350),Vector2(95,420),Vector2(100,610),Vector2(85,720),Vector2(110,940),Vector2(0,1024)],
    [Vector2(1435,90),Vector2(1536,90),Vector2(1536,1024),Vector2(1410,1024),Vector2(1430,930),Vector2(1400,720),Vector2(1425,550)],
    [Vector2(0,960),Vector2(1536,960),Vector2(1536,1024),Vector2(0,1024)],
    [Vector2(1140,115),Vector2(1220,60),Vector2(1310,105),Vector2(1310,204),Vector2(1140,204)],
    [Vector2(225,385),Vector2(290,385),Vector2(295,475),Vector2(225,475)],
    [Vector2(1130,795),Vector2(1180,740),Vector2(1330,725),Vector2(1440,770),Vector2(1440,905),Vector2(1290,940),Vector2(1150,915)]
]
const JoystickScript = preload("res://Joystick.gd")
var item_moment: Node2D
var pickup_time := 0.0
var stored_items := {"Turnip": 0, "Potato": 0, "Strawberry": 0, "Sardine": 0, "Mackerel": 0, "Sea Bream": 0, "Copper": 0, "Iron": 0, "Tea leaves": 0, "Tea packets": 0, "Milk":0, "Goat milk":0, "Wool":0, "Egg":0}
const STORAGE_GROUPS := {"Crops": ["Turnip", "Potato", "Strawberry"], "Fish": ["Sardine", "Mackerel", "Sea Bream"], "Ore": ["Copper", "Iron"], "Tea": ["Tea leaves", "Tea packets"], "Animals":["Milk","Goat milk","Wool","Egg"]}
var backpack_level := 0
const BACKPACK_SIZES := [12, 24, 48]
const BACKPACK_PRICES := [300, 900]
var player: CharacterBody2D
var camera: Camera2D
var farmer: Sprite2D
const STRIDE_DISTANCE := 24.0
var active_texture: Texture2D
var side_offsets: Array[Vector2] = []
var walk_distance := 0.0
var front_scale := 1.0
var character_choice := "boy"
var choosing_character := false
var character_picker: Control
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
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--test-session="):
			SAVE_FILE = "user://test_" + argument.trim_prefix("--test-session=").validate_filename() + ".json"
	recovering_launch=FileAccess.file_exists(SAVE_FILE+".starting")
	var startup_marker := FileAccess.open(SAVE_FILE+".starting",FileAccess.WRITE)
	if startup_marker: startup_marker.store_string("Loading saved farm")
	get_tree().auto_accept_quit = false
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
	town = TownScript.new()
	town.position = TOWN_ORIGIN
	town.visible = false
	add_child(town)
	road = RoadScript.new()
	road.position = ROAD_ORIGIN
	road.visible = false
	add_child(road)
	town.add_supporting_cast()
	for service in ["General Store", "Blacksmith", "Café", "Inn", "Clinic", "Town Hall", "Police Box", "Fire Station", "Archive", "Shrine Residence", "Mountain Lodge", "Tea Farmhouse", "Tea Processing Shed", "Harbor Homes", "Fishing Shop", "Hiro Cabin", "Mine", "Carpentry", "Mountain Carpentry", "Onsen Resort", "Barn", "Greenhouse", "Upper Floor"]:
		var room := ShopScript.new()
		room.position = Vector2(24000 + shops.size() * 2000, 0)
		room.visible = false
		add_child(room)
		room.setup(service)
		shops[service] = room
	for key in REGION_ORIGINS:
		var area := RegionScript.new()
		area.position = REGION_ORIGINS[key]
		area.visible = false
		add_child(area)
		var people: Array = []
		for person in Cast.REGION:
			if Cast.REGION[person] == key: people.append(person)
		area.setup(key, people)
		regions[key] = area
	for group in Cast.GROUPS:
		for person in group: friendship[person] = 0
	preload("res://FarmPlots.gd").fill(self,0)
	for rect in [Rect2(-24, -24, 3048, 24), Rect2(-24, 2000, 3048, 24), Rect2(-24, 0, 24, 2000), Rect2(3000, 0, 24, 2000)]:
		obstacle(rect)
	# The separate farmhouse scene owns its facade collision.
	for outline in SOLID_OUTLINES.slice(1):
		var body := StaticBody2D.new()
		var collision := CollisionPolygon2D.new()
		collision.polygon = world_outline(outline)
		body.add_child(collision)
		outdoor_world.add_child(body)
	player = CharacterBody2D.new()
	player.position = Vector2(775, 590)
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
	var initial_image := preload("res://RuntimeArt.gd").readable_image(farmer.texture)
	farmer.region_rect = initial_image.get_used_rect() if initial_image!=null else Rect2(Vector2.ZERO,farmer.texture.get_size())
	farmer.scale = Vector2.ONE * (180.0 / farmer.region_rect.size.y)
	farmer.position.y = -90
	player.add_child(farmer)
	item_moment = preload("res://ItemMoment.gd").new()
	player.add_child(item_moment)
	item_moment.position = Vector2(0, -225)
	item_moment.z_index = 200
	item_moment.visible = false
	set_character("boy")
	camera = Camera2D.new()
	camera.offset = Vector2(0, -100)
	camera.zoom = Vector2(0.58, 0.58)
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 7
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = 3000
	camera.limit_bottom = 2000
	player.add_child(camera)
	get_viewport().size_changed.connect(refit_camera)
	polish = preload("res://WorldPolish.gd").new()
	add_child(polish)
	polish.setup(self)
	resources = preload("res://FarmResources.gd").new()
	add_child(resources)
	resources.setup(self)
	season_scenery.setup(self)
	wildlife=preload("res://Wildlife.gd").new()
	add_child(wildlife)
	wildlife.setup(self)
	make_ui()
	load_game()
	get_viewport().size_changed.connect(layout_ui)
	layout_ui()
	refresh_hud()
	if not FileAccess.file_exists(SAVE_FILE): show_character_picker()
	game_ready=true
	queue_redraw()
	call_deferred("finish_launch")

func finish_launch() -> void:
	# A failed launch retries at the farmhouse entrance without deleting progress.
	await get_tree().process_frame
	DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_FILE+".starting"))

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
	if interior_progress.get("greenhouse",false) and Rect2(400,1310,500,250).grow(PLAYER_RADIUS).has_point(position): return false
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
	rain_overlay = preload("res://RainOverlay.gd").new()
	hud.add_child(rain_overlay)
	rain_overlay.visible = false
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
	health_fill = StyleBoxFlat.new()
	health_fill.set_corner_radius_all(4)
	health_bar.add_theme_stylebox_override("fill", health_fill)
	hud.add_child(health_bar)
	health_label = Label.new()
	health_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	health_label.add_theme_color_override("font_color", Color("493b2d"))
	health_label.add_theme_font_size_override("font_size", 16)
	health_bar.add_child(health_label)
	health_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	message_label = Label.new()
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.add_theme_color_override("font_color", Color("493b2d"))
	message_label.add_theme_color_override("font_shadow_color", Color.TRANSPARENT)
	message_label.add_theme_constant_override("shadow_offset_x", 2)
	message_label.add_theme_constant_override("shadow_offset_y", 2)
	message_label.add_theme_font_size_override("font_size", 16)
	message_label.add_theme_stylebox_override("normal", parchment())
	message_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	message_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
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
		var button := make_button(["Seed", "Water", "Harvest"][i], func(): select_tool(index); if index == 0: open_seed_picker())
		button.custom_minimum_size = Vector2(138, 58)
		button.icon = load("res://assets/tool-%s.svg" % ["seed","water","harvest"][i])
		button.expand_icon = false
		button.add_theme_constant_override("icon_max_width",28)
		tool_bar.add_child(button)
		tool_buttons.append(button)
	var save_button := make_button("Save", save_game)
	save_button.name = "SaveButton"
	hud.add_child(save_button)
	var character_button := make_button("Bag", open_backpack)
	character_button.name = "CharacterButton"
	hud.add_child(character_button)
	var guide_button := make_button("Guide", open_guide)
	guide_button.name = "GuideButton"
	hud.add_child(guide_button)
	quest_label = Label.new()
	var quest_style := StyleBoxFlat.new()
	quest_style.bg_color = Color("f3e2b9")
	quest_style.content_margin_left = 8
	quest_style.content_margin_right = 8
	quest_style.content_margin_top = 4
	quest_style.content_margin_bottom = 4
	quest_label.add_theme_stylebox_override("normal", quest_style)
	quest_label.add_theme_font_size_override("font_size", 16)
	quest_label.add_theme_color_override("font_color", Color("493b2d"))
	hud.add_child(quest_label)
	var pause_button := make_button("Pause", toggle_pause)
	pause_button.name = "PauseButton"
	hud.add_child(pause_button)
	var battery_button := make_button("Routes", open_map)
	battery_button.name = "MapButton"
	hud.add_child(battery_button)
	festival_button = make_button("End Festival", end_festival)
	festival_button.visible = false
	hud.add_child(festival_button)
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
	quest_label.position = margin + Vector2(0, 132)
	date_label.position = margin
	health_bar.position = margin + Vector2(0, 94)
	health_bar.size = Vector2(240, 28)
	joystick.position = Vector2(margin.x, view.y - bottom - 168)
	action_button.position = Vector2(view.x - right - 138, view.y - bottom - 128)
	action_button.size = Vector2(138, 72)
	tool_bar.position = Vector2((view.x - 430) / 2, view.y - bottom - 102)
	message_label.position = Vector2(margin.x, view.y - bottom - 26)
	message_label.size = Vector2(view.x - margin.x - right, 26)
	hud.get_node("SaveButton").position = Vector2(view.x - right - 95, margin.y)
	hud.get_node("CharacterButton").position = Vector2(view.x - right - 200, margin.y)
	hud.get_node("GuideButton").position = Vector2(view.x - right - 295, margin.y)
	hud.get_node("PauseButton").position = Vector2(view.x - right - 95, margin.y + 50)
	hud.get_node("MapButton").position = Vector2(view.x - right - 265, margin.y + 50)
	Engine.max_fps = 30 if battery_saver else 60
	Engine.physics_ticks_per_second = 30 if battery_saver else 60
	festival_button.position = Vector2(view.x - right - 160, margin.y + 108)

func toggle_pause() -> void:
	paused_by_player = not paused_by_player
	joystick.reset_stick()
	player.velocity = Vector2.ZERO
	hud.get_node("PauseButton").text = "Resume" if paused_by_player else "Pause"
	refresh_hud()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if is_instance_valid(player): save_game(false)
		get_tree().quit()
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		window_focused = false
		Engine.max_fps = 5
		if is_instance_valid(player): save_game(false)
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN:
		window_focused = true
		Engine.max_fps = 30 if battery_saver else 60
	if what == NOTIFICATION_APPLICATION_PAUSED and is_instance_valid(player):
		save_game(false)

func clock_text() -> String:
	var minute := int(clock_minutes / 30) * 30
	var hour := int(minute / 60)
	return "%d:%02d %s" % [12 if hour % 12 == 0 else hour % 12, minute % 60, "AM" if hour < 12 else "PM"]

func advance_clock(seconds: float) -> void:
	# One real second advances one game minute. Midnight rolls the calendar.
	if choosing_character or confirming_sleep or sleep_in_progress or dialogue_open or festival_active or paused_by_player or not window_focused: return
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
			InteriorLife.complete_construction(self)
			settle_farm_day()

func select_tool(index: int) -> void:
	selected_tool = index
	for i in range(tool_buttons.size()):
		tool_buttons[i].modulate = Color("ffdb89") if i == index else Color.WHITE
	action_button.text = ["Plant", "Water", "Harvest"][index]
	if is_instance_valid(player): refresh_hud()

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if dialogue_open:
			if event.physical_keycode in [KEY_SPACE, KEY_E, KEY_ENTER]: advance_dialogue()
			if event.physical_keycode == KEY_ESCAPE: close_dialogue()
			return
		if event.physical_keycode == KEY_1: select_tool(0)
		if event.physical_keycode == KEY_2: select_tool(1)
		if event.physical_keycode == KEY_3: select_tool(2)
		if event.physical_keycode in [KEY_SPACE, KEY_E, KEY_ENTER]: interact()

func _physics_process(delta: float) -> void:
	door_retry=maxf(0,door_retry-delta)
	if choosing_character or confirming_sleep or sleep_in_progress or dialogue_open or paused_by_player or not window_focused: return
	if pickup_time > 0:
		pickup_time = maxf(0, pickup_time - delta)
		item_moment.modulate.a = minf(1, pickup_time / 0.18)
		item_moment.position.y = -225 - sin((0.9 - pickup_time) * PI / 0.9) * 8
		player.velocity = Vector2.ZERO
		if pickup_time == 0: item_moment.visible = false
		return
	if Stewardship.check_visit(self): return
	if resources.action_time > 0:
		player.velocity = Vector2.ZERO
		return
	advance_clock(delta)
	if fishing_active:
		fishing_elapsed += delta
		player.velocity = Vector2.ZERO
		regions.harbor.fishing_state = 2 if fishing_elapsed >= 2.0 else 1
		regions.harbor.queue_redraw()
		if fishing_elapsed > 4.0:
			stop_fishing()
			say("The fish slipped away. Cast again when ready.")
		refresh_hud()
		return
	polish.recover_player()
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if Input.is_physical_key_pressed(KEY_A): direction.x -= 1
	if Input.is_physical_key_pressed(KEY_D): direction.x += 1
	if Input.is_physical_key_pressed(KEY_W): direction.y -= 1
	if Input.is_physical_key_pressed(KEY_S): direction.y += 1
	direction += joystick.direction
	direction = polish.direction(direction)
	running = Input.is_physical_key_pressed(KEY_SHIFT) or joystick.direction.length() > 0.72
	player.velocity = direction.limit_length() * (RUN_SPEED if running else SPEED)
	if not polish.path.is_empty():
		player.velocity = player.velocity.limit_length(player.position.distance_to(polish.path[0])/maxf(delta,0.001))
	var previous_position := player.position
	player.move_and_slide()
	polish.constrain_motion(previous_position)
	if not polish.path.is_empty() and player.position.distance_to(previous_position)<0.01 and direction.length()>0.1:
		polish.path.clear()
	var travel := player.position.distance_to(previous_position)
	update_walk(delta, travel > 0.01, direction, travel)
	if festival_active:
		festival_elapsed += delta
		animate_festival()
	if location == "town" or regions.has(location):
		var origin: Vector2 = TOWN_ORIGIN if location == "town" else REGION_ORIGINS[location]
		player.z_index = clampi(int((player.position.y - origin.y) / 10), 1, 179)
	else: player.z_index = 5
	if location == "town": town.update_label_visibility(player.position - TOWN_ORIGIN)
	if not festival_active: town.tick_ambient(delta, clock_minutes, is_rainy_day(), shops, regions)
	if location == "town" and not festival_active: town.tick(delta, clock_minutes, is_rainy_day())
	elif regions.has(location): regions[location].tick(delta, clock_minutes)
	elif location == "shop": shops[shop_name].tick(delta)
	check_walk_exits()
	check_scheduled_gathering()
	var previous_nearest := nearest
	nearest = -1
	var growing := false
	var distance := 78.0
	for i in range(plots.size()):
		var candidate: float = player.position.distance_to(plots[i].position)
		if location == "farm" and candidate < distance:
			distance = candidate
			nearest = i
	if location == "farm" and nearest != previous_nearest: queue_redraw()
	toast_time -= delta
	save_time += delta
	if save_time >= 30:
		save_game(false)
		save_time = 0
	hud_elapsed += delta
	draw_elapsed += delta
	if hud_elapsed >= 0.2:
		refresh_hud()
		hud_elapsed = 0.0
	if location == "farm" and growing and draw_elapsed >= 0.1:
		queue_redraw()
		draw_elapsed = 0.0

func interaction_action() -> String:
	if location=="farm" and not inside_house and player.position.distance_to(SHIPPING_BOX)<210: return "shipping"
	if location == "farm" and interior_progress.get("greenhouse",false) and player.position.distance_to(FarmBuildings.GREENHOUSE_DOOR)<90: return "greenhouse_enter"
	if inside_house and interior_progress.get("second_story",false) and (player.position-ROOM_ORIGIN).distance_to(FarmBuildings.STAIRS)<75: return "stairs"
	if location == "shop" and shop_name=="Greenhouse": return "greenhouse_bed"
	if location == "shop" and shop_name=="Upper Floor": return ""
	if is_instance_valid(resources) and resources.interaction() != "": return resources.interaction()
	if location == "farm" and not inside_house and player.position.distance_to(BARN_DOOR) < 90: return "barn_enter"
	if location == "shop" and shop_name == "Barn": return "barn_care"
	if fishing_active: return "catch_fish"
	if regions.has(location):
		var door_point: Vector2 = player.position - REGION_ORIGINS[location]
		for room_name in REGIONAL_ROOMS:
			if REGIONAL_ROOMS[room_name][0] == location and door_point.distance_to(REGIONAL_ROOMS[room_name][1]) < 90: return "regional_door"
	if is_instance_valid(polish) and polish.nearest_pet() != null: return "pet_animal"
	if location == "mountain" and (player.position-REGION_ORIGINS.mountain).distance_to(Vector2(520,550)) < 90: return "onsen_bath"
	if location == "shop" and shop_name == "Onsen Resort" and (player.position-SHOP_ORIGIN).distance_to(Vector2(690,500)) < 90: return "onsen_bath"
	if inside_house and int(interior_progress.get("home",0)) >= 2 and (player.position-ROOM_ORIGIN).distance_to(Vector2(1230,450)) < 85: return "cook"
	if location == "tea":
		for spot in TEA_SPOTS:
			if (player.position - REGION_ORIGINS.tea).distance_to(spot) < 70: return "pick_tea"
	if location == "harbor":
		for spot in FISHING_SPOTS:
			if (player.position - REGION_ORIGINS.harbor).distance_to(spot) < 70: return "fish"
	if location == "farm" and player.position.distance_to(SHIPPING_BOX) < 170: return "shipping"
	if location == "shop":
		if shop_name == "Mine":
			for spot in MINE_SPOTS:
				if (player.position - SHOP_ORIGIN).distance_to(spot) < 60: return "mine_ore"
			return ""
		if shop_name == "Archive" and lost_item_stage == 1 and player.position.distance_to(SHOP_ORIGIN + Vector2(230, 480)) < 85: return "collect_wallet"
		if shops[shop_name].nearest_resident(player.position - SHOP_ORIGIN) != null: return "talk_shop"
		if player.position.distance_to(SHOP_ORIGIN + ShopScript.COUNTER) < 110: return "counter"
		if InteriorLife.ACTIVITIES.has(shop_name) and (player.position-SHOP_ORIGIN).distance_to(Vector2(410,470)) < 80: return "room_activity"
		return ""
	if regions.has(location):
		var point: Vector2 = player.position - REGION_ORIGINS[location]
		for room_name in REGIONAL_ROOMS:
			if REGIONAL_ROOMS[room_name][0] == location and point.distance_to(REGIONAL_ROOMS[room_name][1]) < 90: return "regional_door"
		if regions[location].nearest_npc(point) != null: return "talk_region"
		if point.y > 1000 and absf(point.x - 800) < 200: return "return_town"
		return ""
	if location == "town":
		var point := player.position - TOWN_ORIGIN
		if point.distance_to(town.design(Vector2(1350, 730))) < 110: return "noticeboard"
		if town.nearest_service(point) != "" and point.distance_to(service_door(town.nearest_service(point))) < 80: return "service"
		if town.nearest_npc(point) != null: return "talk"
		if town.nearest_service(point) != "": return "service"
		if point.y > 1490 and absf(point.x - 1200) < 180: return "road"
		if point.y < 120: return "north"
		if point.x < 180: return "west"
		if point.x > 2200: return "east"
		if point.x < 400 and point.y < 340: return "historic"
		return ""
	if location == "road": return ""
	if location == "farm" and player.position.distance_to(FARM_EXIT) < 110: return "town"
	if inside_house:
		var local_position := player.position - ROOM_ORIGIN
		if local_position.distance_to(interior.CALENDAR_APPROACH) < 75: return "calendar"
		if local_position.distance_to(interior.CHEST_APPROACH) < 80 or (int(interior_progress.get("home",0)) > 0 and local_position.distance_to(Vector2(1010,340)) < 80): return "storage"
		if local_position.distance_to(interior.BED_APPROACH) < 100.0: return "sleep"
		if local_position.distance_to(interior.EXIT) < 90.0: return "leave"
	elif player.position.distance_to(farmhouse.DOOR_POSITION) < 90.0:
		return "enter"
	return ""

func calendar_text() -> String:
	var season_index := int((day - 1) / 28) % 4
	return "%s %d  |  Year %d" % [SEASONS[season_index], (day - 1) % 28 + 1, int((day - 1) / 112) + 1]

func refresh_hud() -> void:
	season_scenery.update(day)
	if WeatherLife.forecast(day) == "Hurricane" and not inside_house:
		set_location(true,ROOM_ORIGIN+interior.ENTRY)
		return
	apply_rain_watering()
	if tool_buttons.size()>1: tool_buttons[1].text="Water %d" % resources.state().water
	if is_instance_valid(rain_overlay): rain_overlay.visible = is_rainy_day() and not inside_house and location != "shop" and not dialogue_open and not choosing_character and not paused_by_player and window_focused
	update_resident_presence()
	if is_instance_valid(town) and town.festival_decorated != (not SeasonalFestivals.today(day).is_empty()):
		town.festival_decorated = not SeasonalFestivals.today(day).is_empty()
		town.queue_redraw()
	quest_label.text = ["", "Wallet: search Haruka's archive.", "Wallet: return to Taro.", "Lost wallet returned ✓"][lost_item_stage]
	if tea_delivery_stage == 1 and lost_item_stage not in [1, 2]: quest_label.text = "Tea delivery: bring Mika's parcel to Naomi."
	if tea_delivery_stage == 1 and lost_item_stage in [1, 2]: quest_label.text += "\nTea: deliver to Naomi."
	if fishing_quest_stage in [1, 2]: quest_label.text += ("\nFishing: catch one fish." if fishing_quest_stage == 1 else "\nFishing: report to Masao.")
	quest_label.text = quest_label.text.strip_edges()
	quest_label.visible = not dialogue_open and (lost_item_stage > 0 or tea_delivery_stage > 0 or fishing_quest_stage > 0)
	date_label.text = "%s\n%s • ¥%d • %s\nSeeds %d · Harvested %d" % [calendar_text(), clock_text(), coins, WeatherLife.forecast(day), seed_count(selected_crop), harvests]
	health_bar.value = health
	health_label.text = "Health %d / 100" % int(ceil(health))
	health_fill.bg_color = Color("a5be83") if health >= 50 else (Color("e7c786") if health >= 25 else Color("da927c"))
	farmer.modulate = Color("d1c7bb") if health < 25 else Color.WHITE
	tool_bar.visible = location == "farm" and not dialogue_open
	joystick.visible = not dialogue_open
	action_button.visible = not dialogue_open
	hud.get_node("CharacterButton").visible = not dialogue_open
	hud.get_node("PauseButton").visible = not dialogue_open
	hud.get_node("GuideButton").visible = not dialogue_open
	hud.get_node("SaveButton").visible = not dialogue_open
	hud.get_node("MapButton").visible = not dialogue_open
	message_label.visible = not dialogue_open
	var action := interaction_action()
	if action in ["enter","leave","service","regional_door","barn_enter","greenhouse_enter","stairs","north","west","east","historic","town","road","return_town"]: action_button.visible=false
	action_button.disabled = false
	match action:
		"refill_water": action_button.text = "Refill"
		"chop_wood": action_button.text = "Chop"
		"barn_enter": action_button.text = "Enter"
		"barn_care": action_button.text = "Animals"
		"greenhouse_enter": action_button.text = "Enter"
		"greenhouse_bed": action_button.text = "Tend"
		"stairs": action_button.text = "Upstairs"
		"pet_animal": action_button.text = "Pet"
		"onsen_bath": action_button.text = "Soak"
		"mine_ore": action_button.text = "Mine"
		"pick_tea": action_button.text = "Pick tea"
		"fish": action_button.text = "Cast"
		"catch_fish": action_button.text = "Catch!" if fishing_elapsed >= 2.0 else "Wait…"
		"shipping": action_button.text = "Ship"
		"collect_wallet": action_button.text = "Pick up"
		"regional_door": action_button.text = "Visit"
		"talk_shop": action_button.text = "Talk"
		"counter": action_button.text = "Treat" if shop_name == "Clinic" else ("Rest" if shop_name == "Inn" else ("Info" if shop_name in ["Town Hall", "Police Box", "Fire Station"] else "Shop"))
		"noticeboard": action_button.text = "Events"
		"talk_region": action_button.text = "Talk"
		"return_town": action_button.text = "Town"
		"historic": action_button.text = "Shrine"
		"town": action_button.text = "Town"
		"road": action_button.text = "Farm"
		"talk": action_button.text = "Talk"
		"service": action_button.text = "Visit"
		"north", "west", "east": action_button.text = "Explore"
		"enter": action_button.text = "Enter"
		"leave": action_button.text = "Leave"
		"calendar": action_button.text = "Calendar"
		"storage": action_button.text = "Storage"
		"sleep": action_button.text = "Sleep"
		_:
			action_button.text = ["Plant", "Water", "Harvest"][selected_tool] if location == "farm" else "Explore"
			action_button.disabled = location != "farm"
	var hint := crop_hint()
	match action:
		"pet_animal": hint = "Greet the animal with a gentle pat."
		"onsen_bath": hint = "Onsen · A relaxing soak restores Health."
		"mine_ore": hint = "Gather ore · %d Health. Rocks refresh tomorrow." % [4 - pick_level * 2]
		"pick_tea": hint = "Pick fresh leaves, then pack them at the processing shed."
		"fish": hint = "Fishing spot · Cast, wait for a bite, then Catch."
		"catch_fish": hint = "Bite! Press Catch now." if fishing_elapsed >= 2.0 else "Watch the float. Wait for a bite…"
		"shipping": hint = "Shipping box · Ship harvests for payment next morning."
		"collect_wallet": hint = "Pick up the lost wallet."
		"regional_door": hint = "Visit the building."
		"talk_shop": hint = "Talk to %s." % shops[shop_name].nearest_resident(player.position - SHOP_ORIGIN).first_name
		"cook": hint = "Kitchen · Cook two vegetables into a meal."
		"room_activity": hint = "Explore " + InteriorLife.ACTIVITIES[shop_name][0] + "."
		"counter": hint = "Shop at the counter."
		"noticeboard": hint = "Plaza Noticeboard · Festivals, requests, and shop hours."
		"talk_region": hint = "Talk to %s." % regions[location].nearest_npc(player.position - REGION_ORIGINS[location]).first_name
		"return_town": hint = "Return to Main Town."
		"historic": hint = "Northwest path · Shrine and local history."
		"town": hint = "North to town. Walk onto the farm walkway to enter town."
		"talk": hint = "Talk to %s." % town.nearest_npc(player.position - TOWN_ORIGIN).first_name
		"service": hint = "Visit %s." % town.nearest_service(player.position - TOWN_ORIGIN)
		"road": hint = "Return south to your family farm."
		"enter": hint = "Welcome home. Enter the farmhouse."
		"leave": hint = "Leave the house to return to your farm."
		"calendar": hint = "Check upcoming festivals and tomorrow’s weather."
		"storage": hint = "Store items or take them back into your backpack."
		"sleep": hint = "Rest in bed to start the next day."
		_:
			if inside_house: hint = "Walk beside the bed to sleep, or the front doorway to leave."
			elif location == "shop": hint = "Talk to residents or use the counter. Walk through the south door to leave."
			elif location == "road": hint = "Town to the north · Farm to the south. Push farther or hold Shift to run."
			elif location == "town": hint = "Approach a resident to talk, or a shop door to visit."
			elif regions.has(location): hint = "Meet the residents or approach a building doorway to visit."
	if is_rainy_day() and not inside_house and location != "shop": hint = "Rain · " + hint
	message_label.text = hint if fishing_active else (toast if toast_time > 0 else hint)
	if paused_by_player: message_label.text = "Paused. Press Resume to continue."
	elif toast_time <= 0 and health < 25:
		message_label.text = "Health is low. Rest in bed." if health >= WORK_COSTS[selected_tool] else "Too tired to work. Rest in bed."

func set_location(indoors: bool, destination: Vector2) -> void:
	if is_instance_valid(polish): polish.path.clear()
	for room in shops.values():
		room.visible = false
		RenderingServer.canvas_item_clear(room.get_canvas_item())
	preload("res://InteriorArtwork.gd").textures.clear()
	location = "house" if indoors else "farm"
	if is_instance_valid(town): town.visible = false
	if is_instance_valid(road): road.visible = false
	for area in regions.values(): area.visible = false
	inside_house = indoors
	RenderingServer.set_default_clear_color(Color("293e37") if indoors else Color("78b9df"))
	outdoor_world.visible = not indoors
	interior.visible = indoors
	player.collision_mask = 2 if indoors else 1
	player.position = destination
	player.velocity = Vector2.ZERO
	joystick.reset_stick()
	nearest = -1
	update_walk(0.0, false, Vector2.DOWN)
	camera.limit_left = int(ROOM_ORIGIN.x) if indoors else 0
	camera.limit_top = 0
	camera.limit_right = int(ROOM_ORIGIN.x + interior.SIZE.x) if indoors else int(WORLD.x)
	camera.limit_bottom = int(interior.SIZE.y) if indoors else int(WORLD.y)
	camera.offset = Vector2(0, -60) if indoors else Vector2(0, -100)
	if indoors: fit_region_camera(interior.SIZE)
	camera.reset_smoothing()
	if not indoors: camera.zoom = Vector2.ONE * maxf(0.58,maxf(get_viewport_rect().size.x/WORLD.x,get_viewport_rect().size.y/WORLD.y))
	refresh_hud()
	queue_redraw()

func enter_house() -> void:
	if inside_house: return
	set_location(true, ROOM_ORIGIN + interior.ENTRY)
	say("Home sweet home. The bed is in the right corner.")
	save_game(false)

func leave_house() -> void:
	if WeatherLife.forecast(day) == "Hurricane":
		say("A hurricane is passing. Stay indoors and sleep until tomorrow.")
		return
	if not inside_house: return
	set_location(false, farmhouse.DOOR_POSITION + Vector2(0, 110))
	say("Back on the farm.")
	save_game(false)

func offer_sleep() -> void:
	if not inside_house or confirming_sleep or sleep_in_progress: return
	confirming_sleep = true
	player.velocity = Vector2.ZERO
	joystick.reset_stick()
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
	if not inside_house or not confirming_sleep or sleep_in_progress: return
	cancel_sleep()
	if not is_instance_valid(sleep_sequence):
		sleep_sequence=preload("res://SleepSequence.gd").new()
		add_child(sleep_sequence)
	sleep_sequence.begin(self)

func finish_sleep_day() -> void:
	if clock_minutes >= WAKE_MINUTE: day += 1
	InteriorLife.complete_construction(self)
	clock_minutes = WAKE_MINUTE
	health = MAX_HEALTH
	settle_farm_day()
	set_location(true, ROOM_ORIGIN + interior.BED_APPROACH)
	say(("Good morning! Rain is watering your crops today. " if is_rainy_day() else "Good morning! Check your crops and water them. ") + calendar_text())
	save_time = 0.0
	save_game(false)

func crop_hint() -> String:
	if nearest < 0 or nearest >= plots.size():
		return "Move beside a crop bed to tend it."
	var plot: Dictionary = plots[nearest]
	match int(plot.stage):
		0:
			return "Empty bed. Tap Seed to choose a crop, then Plant." if seeds > 0 else "No seeds. Buy some at the General Store in town."
		1:
			return "%s · Needs water today. %d growing nights remaining." % [plot.crop, maxi(0, CROPS[plot.crop].days - int(plot.growth))]
		2:
			return "%s · Watered. %d growing nights remaining." % [plot.crop, maxi(0, CROPS[plot.crop].days - int(plot.growth))]
		3:
			return "%s is ready. Harvest, then put it in the shipping box." % plot.crop
	return "Choose a tool, then use it beside a crop bed."

func say(text: String) -> void:
	toast = text
	toast_time = 4.0

func interact() -> void:
	if is_physics_processing() and is_instance_valid(resources) and resources.action_time > 0: return
	clear_item_moment()
	if dialogue_open:
		advance_dialogue()
		return
	if choosing_character or confirming_sleep or sleep_in_progress or paused_by_player: return
	if WeatherLife.forecast(day) == "Hurricane" and interaction_action() != "sleep":
		say("Hurricane: rest in bed until tomorrow.")
		return
	match interaction_action():
		"greenhouse_enter":
			enter_shop("Greenhouse")
			return
		"greenhouse_bed":
			FarmBuildings.open_bed(self)
			return
		"stairs":
			enter_shop("Upper Floor")
			return
		"refill_water":
			resources.refill()
			return
		"chop_wood":
			resources.chop()
			return
		"barn_enter":
			enter_shop("Barn")
			return
		"barn_care":
			BarnLife.open_care(self)
			return
		"pet_animal":
			polish.pet_animal()
			return
		"onsen_bath":
			open_onsen()
			return
		"mine_ore":
			mine_ore()
			return
		"pick_tea":
			harvest_tea()
			return
		"fish":
			begin_fishing()
			return
		"catch_fish":
			catch_fish()
			return
		"shipping":
			open_shipping()
			return
		"collect_wallet":
			lost_item_stage = 2
			show_item_moment("Wallet")
			shops.Archive.lost_item_visible = false
			shops.Archive.queue_redraw()
			say("Wallet found. Bring it back to Taro.")
			save_game(false)
			refresh_hud()
			return
		"regional_door":
			for room_name in REGIONAL_ROOMS:
				if REGIONAL_ROOMS[room_name][0] == location and (player.position - REGION_ORIGINS[location]).distance_to(REGIONAL_ROOMS[room_name][1]) < 90:
					enter_shop(room_name)
					return
		"talk_shop":
			start_conversation(shops[shop_name].nearest_resident(player.position - SHOP_ORIGIN))
			return
		"cook":
			InteriorLife.cook(self)
			return
		"room_activity":
			InteriorLife.open_room(self,shop_name)
			return
		"counter":
			open_service(shop_name)
			return
		"noticeboard":
			open_noticeboard()
			return
		"talk_region":
			start_conversation(regions[location].nearest_npc(player.position - REGION_ORIGINS[location]))
			return
		"return_town":
			travel_to("town", town.design(Vector2(1200,910)))
			return
		"historic":
			travel_to("historic", Vector2(1440,1060))
			return
		"town":
			travel_to("town", town.design(Vector2(1200,2000)))
			return
		"road":
			travel_to("farm", FARM_EXIT + Vector2(0, 100))
			return
		"talk":
			start_conversation(town.nearest_npc(player.position - TOWN_ORIGIN))
			return
		"service":
			enter_shop(town.nearest_service(player.position - TOWN_ORIGIN))
			return
		"north", "west", "east":
			var destination: String = {"north": "mountain", "west": "harbor", "east": "tea"}[interaction_action()]
			travel_to(destination, Vector2(1480,585) if destination=="harbor" else Vector2(800,950))
			return
		"enter":
			enter_house()
			return
		"leave":
			leave_house()
			return
		"calendar":
			open_calendar()
			return
		"storage":
			open_storage()
			return
		"sleep":
			offer_sleep()
			return
	if location != "farm": return
	if selected_tool==0 and int((day-1)/28)%4==3:
		say("Outdoor soil is too cold in winter. Plant in your greenhouse.")
		return
	if nearest < 0:
		say("Move closer to a crop bed.")
		return
	var work_cost: float = maxf(1.0, WORK_COSTS[1] - tool_level) if selected_tool == 1 else (maxf(1, WORK_COSTS[2] - harvest_level * 2) if selected_tool == 2 else WORK_COSTS[selected_tool])
	work_cost *= WeatherLife.work_multiplier(self)
	if health < work_cost:
		say("Too tired to work. Rest in bed to restore Health.")
		return
	var plot: Dictionary = plots[nearest]
	match selected_tool:
		0:
			if plot.stage != 0: say("This bed is already planted.")
			elif seed_count(selected_crop) < 1: say("No seeds. Visit the General Store in town.")
			else:
				if selected_crop == "Turnip": seeds -= 1
				else: extra_seeds[selected_crop] -= 1
				health -= work_cost
				resources.play("seed", plot.position)
				plot.crop = selected_crop
				plot.last_growth_day = day
				plot.stage = 1
				plot.growth = 0.0
				resources.irrigate()
				say("Planted! Select Water to help it grow.")
		1:
			if plot.stage == 1:
				if resources.state().water <= 0:
					say("Your watering can is empty. Refill it at the farm well.")
					return
				resources.state().water -= 1
				resources.play("water", plot.position)
				health -= work_cost
				plot.stage = 2
				say("Watered. This crop grows overnight. Water it again each new day.")
			elif plot.stage == 0: say("Plant a seed first.")
			else: say("This crop already has enough water.")
		2:
			if plot.stage == 3:
				if not backpack_has_room() or int(produce[plot.crop]) >= 999:
					say("Backpack full. Ship some items or buy a larger bag.")
					return
				health -= work_cost
				plot.stage = 0
				plot.growth = 0.0
				resources.play("harvest", plot.position)
				produce[plot.crop] += 1
				show_item_moment(plot.crop)
				harvests += 1
				say("%s harvested. Take it to the shipping box." % plot.crop)
			else: say("Harvest crops with golden leaves when ready.")
	save_game(false)

func save_game(show_message: bool = true) -> void:
	if choosing_character or not game_ready or sleep_in_progress: return
	if FileAccess.file_exists(SAVE_FILE):
		var previous = read_saved_json(SAVE_FILE)
		if previous is Dictionary:
			DirAccess.copy_absolute(ProjectSettings.globalize_path(SAVE_FILE), ProjectSettings.globalize_path(SAVE_FILE + ".bak"))
	var crop_data: Array = []
	for plot in plots:
		crop_data.append({"stage": plot.stage, "growth": plot.growth, "crop": plot.crop, "last_growth_day": plot.last_growth_day})
	var file := FileAccess.open(SAVE_FILE+".pending", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify({"version": 19, "interior_progress": interior_progress, "festival_years": festival_years, "pick_level": pick_level, "harvest_level": harvest_level, "stored_items": stored_items, "backpack_level": backpack_level, "mine_lesson_seen": mine_lesson_seen, "ore_basket": ore_basket, "ore_shipping": ore_shipping, "ore_picked_days": ore_picked_days, "tea_lesson_seen": tea_lesson_seen, "tea_leaves": tea_leaves, "packed_tea": packed_tea, "tea_shipping": tea_shipping, "tea_picked_days": tea_picked_days, "fish_basket": fish_basket, "fish_shipping": fish_shipping, "fish_catches": fish_catches, "fishing_quest_stage": fishing_quest_stage, "tea_delivery_stage": tea_delivery_stage, "selected_crop": selected_crop, "extra_seeds": extra_seeds, "produce": produce, "shipping_queue": shipping_queue, "lost_item_stage": lost_item_stage, "day": day, "clock_minutes": clock_minutes, "health": health, "location": location, "shop_name": shop_name, "character": character_choice, "coins": coins, "seeds": seeds, "tool_level": tool_level, "friendship": friendship, "talked_on_day": talked_on_day, "seen_scenes": seen_scenes, "harvests": harvests, "x": player.position.x, "y": player.position.y, "plots": crop_data}))
		file.flush()
		file.close()
		if DirAccess.rename_absolute(ProjectSettings.globalize_path(SAVE_FILE+".pending"),ProjectSettings.globalize_path(SAVE_FILE))!=OK:
			if show_message: say("Could not replace the save. Your previous save is preserved.")
			return
		if show_message: say("Farm saved.")
	elif show_message: say("Could not save. Check storage permissions.")

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_FILE): return
	var parsed = read_saved_json(SAVE_FILE)
	if not parsed is Dictionary and FileAccess.file_exists(SAVE_FILE + ".bak"):
		parsed = read_saved_json(SAVE_FILE + ".bak")
	if not parsed is Dictionary: return
	for field in ["friendship", "talked_on_day"]:
		var values = parsed.get(field, {})
		if values is Dictionary and values.has("Yoshi"):
			values["Haruka"] = maxi(int(values.get("Haruka", 0)), int(values["Yoshi"]))
			values.erase("Yoshi")
	var saved_progress = parsed.get("interior_progress",{})
	interior_progress = saved_progress if saved_progress is Dictionary else {}
	for section in ["resources","construction","story","activities"]:
		if interior_progress.has(section) and not interior_progress[section] is Dictionary: interior_progress.erase(section)
	interior_progress.home=clampi(int(interior_progress.get("home",0)),0,2)
	InteriorLife.add_plots(self,int(interior_progress.get("restoration",0)))
	coins = maxi(0, int(parsed.get("coins", 500)))
	festival_years = []
	var saved_festivals = parsed.get("festival_years", [])
	if saved_festivals is Array:
		for value in saved_festivals:
			var year := int(value)
			if year > 0 and not festival_years.has(year): festival_years.append(year)
	var saved_storage = parsed.get("stored_items", {})
	for item in stored_items:
		stored_items[item] = clampi(int(saved_storage.get(item, 0)), 0, storage_limit()) if saved_storage is Dictionary else 0
	backpack_level = clampi(int(parsed.get("backpack_level", 0)), 0, 2)
	seeds = clampi(int(parsed.get("seeds", 5)), 0, 999)
	selected_crop = str(parsed.get("selected_crop", "Turnip"))
	if not CROPS.has(selected_crop): selected_crop = "Turnip"
	for key in CROPS:
		for field in ["extra_seeds", "produce", "shipping_queue"]:
			var inventory = parsed.get(field, {})
			var count := clampi(int(inventory.get(key, 0)), 0, 999) if inventory is Dictionary else 0
			if field == "extra_seeds" and key != "Turnip": extra_seeds[key] = count
			elif field == "produce": produce[key] = count
			elif field == "shipping_queue": shipping_queue[key] = count
	pick_level = clampi(int(parsed.get("pick_level", 0)), 0, 1)
	harvest_level = clampi(int(parsed.get("harvest_level", 0)), 0, 1)
	tool_level = clampi(int(parsed.get("tool_level", 0)), 0, 1)
	var stored = parsed.get("friendship", {})
	if stored is Dictionary:
		for person in stored:
			if person in ["Seira", "Shohei", "Akira", "Taro"] or Cast.ROLES.has(person) or town.EXTRA_DIALOGUE.has(person):
				friendship[person] = clampi(int(stored[person]), 0, 100)
	var stored_days = parsed.get("talked_on_day", {})
	if stored_days is Dictionary: talked_on_day = stored_days
	var scenes = parsed.get("seen_scenes", [])
	if scenes is Array: seen_scenes = scenes
	set_character(str(parsed.get("character", "boy")))
	harvests = maxi(0, int(parsed.get("harvests", 0)))
	day = maxi(1, int(parsed.get("day", 1)))
	clock_minutes = clampf(float(parsed.get("clock_minutes", WAKE_MINUTE)), 0.0, 1439.999)
	health = clampf(float(parsed.get("health", MAX_HEALTH)), 0.0, MAX_HEALTH)
	for fish_name in FISH:
		var basket_data = parsed.get("fish_basket", {})
		var shipping_data = parsed.get("fish_shipping", {})
		fish_basket[fish_name] = clampi(int(basket_data.get(fish_name, 0)), 0, 999) if basket_data is Dictionary else 0
		fish_shipping[fish_name] = clampi(int(shipping_data.get(fish_name, 0)), 0, 999) if shipping_data is Dictionary else 0
	mine_lesson_seen = bool(parsed.get("mine_lesson_seen", false))
	for mineral in ORE:
		var bag = parsed.get("ore_basket", {})
		var box = parsed.get("ore_shipping", {})
		ore_basket[mineral] = clampi(int(bag.get(mineral, 0)), 0, 999) if bag is Dictionary else 0
		ore_shipping[mineral] = clampi(int(box.get(mineral, 0)), 0, 999) if box is Dictionary else 0
	ore_picked_days = [0, 0, 0, 0]
	var ore_days = parsed.get("ore_picked_days", [])
	if ore_days is Array:
		for i in range(mini(4, ore_days.size())): ore_picked_days[i] = maxi(0, int(ore_days[i]))
	tea_lesson_seen = bool(parsed.get("tea_lesson_seen", false))
	tea_leaves = clampi(int(parsed.get("tea_leaves", 0)), 0, 999)
	packed_tea = clampi(int(parsed.get("packed_tea", 0)), 0, 999)
	tea_shipping = clampi(int(parsed.get("tea_shipping", 0)), 0, 999)
	tea_picked_days = [0, 0, 0]
	var picked = parsed.get("tea_picked_days", [])
	if picked is Array:
		for i in range(mini(3, picked.size())): tea_picked_days[i] = maxi(0, int(picked[i]))
	fish_catches = maxi(0, int(parsed.get("fish_catches", 0)))
	fishing_quest_stage = clampi(int(parsed.get("fishing_quest_stage", 0)), 0, 3)
	var destination := Vector2(775, 590)
	if OS.has_feature("ios") and int(parsed.get("version",1))<=17 and str(parsed.get("location","farm"))=="house": recovering_launch=true
	var indoors := str(parsed.get("location", "farm")) == "house" and not recovering_launch
	if indoors: destination = ROOM_ORIGIN + interior.ENTRY
	if int(parsed.get("version", 1)) >= 2 and not recovering_launch:
		var saved_position := Vector2(float(parsed.get("x", 450)), float(parsed.get("y", 1120)))
		if (indoors and interior.is_walkable(saved_position - ROOM_ORIGIN)) or (not indoors and is_walkable(saved_position)):
			destination = saved_position
	interior.apply_upgrade(int(interior_progress.get("home",0)))
	var crops = parsed.get("plots", [])
	if crops is Array:
		for i in range(mini(crops.size(), plots.size())):
			if crops[i] is Dictionary:
				plots[i].stage = clampi(int(crops[i].get("stage", 0)), 0, 3)
				plots[i].crop = str(crops[i].get("crop", "Turnip"))
				if not CROPS.has(plots[i].crop): plots[i].crop = "Turnip"
				plots[i].growth = clampf(float(crops[i].get("growth", 0)), 0, CROPS[plots[i].crop].days) if int(parsed.get("version", 1)) >= 7 else 0.0
				plots[i].last_growth_day = int(crops[i].get("last_growth_day", day))
	set_location(indoors, destination)
	lost_item_stage = clampi(int(parsed.get("lost_item_stage", 0)), 0, 3)
	tea_delivery_stage = clampi(int(parsed.get("tea_delivery_stage", 0)), 0, 2)
	var saved_area := "farm" if recovering_launch else str(parsed.get("location", "farm"))
	if saved_area in ["town", "road"]:
		var origin := TOWN_ORIGIN if saved_area == "town" else ROAD_ORIGIN
		var point := Vector2(float(parsed.get("x", origin.x + 500)), float(parsed.get("y", 500))) - origin
		if saved_area=="town" and int(parsed.get("version",1))<19: point=town.design(point)
		var valid: bool = town.is_walkable(point) if saved_area == "town" else Rect2(Vector2(30, 90), Vector2(940, 820)).has_point(point)
		travel_to(saved_area, point if valid else (Vector2(1200, 1200) if saved_area == "town" else Vector2(500, 500)), false)
	elif regions.has(saved_area):
		var point := Vector2(float(parsed.get("x", 0)), float(parsed.get("y", 0))) - Vector2(REGION_ORIGINS[saved_area])
		travel_to(saved_area, point if regions[saved_area].is_walkable(point) else Vector2(800, 950), false)
	if saved_area == "shop" and shops.has(str(parsed.get("shop_name", ""))):
		enter_shop(str(parsed.shop_name), true)
	say("Welcome back. Your farm has been restored.")

func read_saved_json(path: String) -> Variant:
	var parser := JSON.new()
	if parser.parse(FileAccess.get_file_as_string(path)) != OK: return null
	return parser.data

func update_walk(delta: float, moving: bool, direction: Vector2 = Vector2.ZERO, travel: float = -1.0) -> void:
	if direction.length() > 0.15:
		facing_direction = posmod(int(round((direction.angle()-PI/2)/(PI/4))),8)
	walk_distance = walk_distance+(travel if travel>=0 else delta*SPEED) if moving else 0.0
	var phase := int(walk_distance/STRIDE_DISTANCE)%4 if moving else 1
	var row := 0 if facing_direction==0 else (2 if facing_direction==4 else (1 if facing_direction in [1,2,3] else 3))
	var mirror := row==1
	var index := (3 if mirror else row)*4+phase
	var key := row*4+phase
	if key==walk_frame: return
	walk_frame=key
	farmer.texture=active_texture
	farmer.flip_h=mirror
	farmer.region_rect=walk_regions[index]
	farmer.scale=Vector2.ONE*front_scale
	farmer.position=side_offsets[index]*front_scale
	if mirror: farmer.position.x*=-1
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
	character_choice="girl" if choice=="girl" else "boy"
	active_texture=preload("res://CharacterArt.gd").walk(character_choice)
	var geometry=preload("res://Npc.gd").new()
	geometry.prepare_walk_geometry(character_choice,active_texture)
	walk_regions.assign(geometry.regions)
	side_offsets.assign(geometry.offsets)
	front_scale=geometry.height_scale*1.2
	geometry.free()
	walk_frame=-2
	update_walk(0,false)
func choose_character(choice: String) -> void:
	set_character(choice)
	choosing_character = false
	joystick.reset_stick()
	if is_instance_valid(character_picker): character_picker.queue_free()
	save_game(false)
	say("Welcome home. Your farmer is ready.")

func show_character_picker() -> void:
	if choosing_character or confirming_sleep or sleep_in_progress or dialogue_open: return
	choosing_character = true
	player.velocity = Vector2.ZERO
	joystick.reset_stick()
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
		var texture: Texture2D = preload("res://CharacterArt.gd").walk(choice)
		if texture==null: continue
		var atlas := AtlasTexture.new()
		atlas.atlas = texture
		atlas.region = Rect2(Vector2(texture.get_width()/4.0,0), texture.get_size() / 4.0)
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
	if location != "farm": return
	if interior_progress.get("greenhouse",false):
		preload("res://EntrancePaths.gd").draw_path(self,PackedVector2Array([FarmBuildings.GREENHOUSE_DOOR,Vector2(780,1620),Vector2(920,1650)]),72)
	draw_set_transform(SHIPPING_BOX,0,Vector2.ONE*2.4)
	crop_oval(Vector2.ZERO + Vector2(0, 32), Vector2(48, 12), Color(0.15, 0.18, 0.12, 0.25))
	draw_rect(Rect2(Vector2.ZERO + Vector2(-42, -16), Vector2(84, 48)), Color("896748"))
	draw_colored_polygon(PackedVector2Array([Vector2.ZERO + Vector2(-42, -16), Vector2.ZERO + Vector2(-30, -36), Vector2.ZERO + Vector2(52, -36), Vector2.ZERO + Vector2(42, -16)]), Color("c1a16e"))
	draw_rect(Rect2(Vector2.ZERO + Vector2(-30, -26), Vector2(58, 7)), Color("594b38"))
	for x in [-33, 31]: draw_rect(Rect2(Vector2.ZERO + Vector2(x, -15), Vector2(6, 46)), Color("c1a16e"))
	draw_rect(Rect2(Vector2.ZERO + Vector2(-14, -6), Vector2(28, 26)), Color("e6dac0"))
	draw_line(Vector2.ZERO + Vector2(-7, 8), Vector2.ZERO + Vector2(7, 8), Color("687e56"), 4)
	draw_line(Vector2.ZERO + Vector2(2, 2), Vector2.ZERO + Vector2(8, 8), Color("687e56"), 4)
	var queued := 0
	for count in shipping_queue.values(): queued += int(count)
	for count in fish_shipping.values(): queued += int(count)
	queued += tea_shipping
	for count in ore_shipping.values(): queued += int(count)
	if queued > 0: draw_circle(Vector2.ZERO + Vector2(43, -30), 7, Color("e5cb85"))
	for y in [-3,10,24]: draw_line(Vector2(-30,y),Vector2(30,y),Color("705239"),1.5)
	draw_style_box(parchment(),Rect2(-42,42,92,22))
	draw_string(ThemeDB.fallback_font,Vector2(-34,59),"Shipping",HORIZONTAL_ALIGNMENT_LEFT,-1,15,Color("493b2d"))
	draw_set_transform(Vector2.ZERO,0,Vector2.ONE)
	if interior_progress.has("construction"):
		draw_rect(Rect2(650,1020,150,65),Color("ead8af"))
		draw_string(ThemeDB.fallback_font,Vector2(660,1048),"Kenta's work",HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("614b36"))
		draw_string(ThemeDB.fallback_font,Vector2(660,1075),"Ready tomorrow",HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color("614b36"))
	# The natural town lane is painted into the environment asset.
	# Dynamic beds and crops sit over the static environment, never baked into it.
	for i in range(plots.size()):
		var plot: Dictionary = plots[i]
		var pos: Vector2 = plot.position
		if plot.stage > 0:
			draw_colored_polygon(PackedVector2Array([pos + Vector2(-28, -25), pos + Vector2(26, -28), pos + Vector2(29, 24), pos + Vector2(-25, 28)]), Color(0.24, 0.16, 0.10, 0.38 if plot.stage == 2 else 0.20))
		for row in range(3):
			var y := -15 + row * 15
			draw_line(pos + Vector2(-22, y), pos + Vector2(22, y + 1), Color(0.28, 0.18, 0.10, 0.3), 2)
		if i == nearest:
			draw_rect(Rect2(pos - Vector2(29, 29), Vector2(58, 58)), Color(1.0, 0.89, 0.55, 0.8), false, 2)
		if plot.stage > 0: crop(pos + Vector2(0, -2), plot.stage, plot.crop, plot.growth)
		if i == nearest and plot.stage > 0:
			var nights: int = CROPS[plot.crop].days
			for n in range(nights):
				draw_circle(pos + Vector2((n - (nights - 1) / 2.0) * 11, 25), 4, Color("82976a") if n < int(plot.growth) else Color("d1c39e"))
			if plot.stage == 2:
				draw_colored_polygon(PackedVector2Array([pos + Vector2(24, -28), pos + Vector2(19, -18), pos + Vector2(29, -18)]), Color("86aeb1"))

func crop_oval(center: Vector2, radius: Vector2, color: Color) -> void:
	var points := PackedVector2Array()
	for n in range(16): points.append(center + Vector2(cos(n * TAU / 16), sin(n * TAU / 16)) * radius)
	draw_colored_polygon(points, color)

func crop(pos: Vector2, stage: int, crop_name: String = "Turnip", growth: float = 0) -> void:
	var ripe := stage == 3
	var size := 1.0 if ripe else (0.65 if growth > 0 else 0.45)
	var green := Color("789456")
	crop_oval(pos + Vector2(0, 6), Vector2(22, 7), Color(0.15, 0.22, 0.12, 0.22))
	match crop_name:
		"Turnip":
			for side in [-1, 1]:
				crop_oval(pos + Vector2(side * 10, -19) * size, Vector2(8, 15) * size, green)
			if ripe:
				crop_oval(pos, Vector2(17, 14), Color("e6dac0"))
				draw_colored_polygon(PackedVector2Array([pos + Vector2(-5, 9), pos + Vector2(0, 20), pos + Vector2(5, 9)]), Color("e6dac0"))
		"Potato":
			for offset in [Vector2(-12, -10), Vector2(12, -10), Vector2(0, -22)]:
				crop_oval(pos + offset * size, Vector2(11, 8) * size, green)
			if ripe:
				crop_oval(pos + Vector2(-8, 3), Vector2(13, 9), Color("c39e72"))
				crop_oval(pos + Vector2(10, -1), Vector2(10, 8), Color("c39e72"))
				draw_circle(pos + Vector2(-10, 1), 2, Color("96764f"))
		"Strawberry":
			for offset in [Vector2(-13, -10), Vector2(13, -10), Vector2(0, -21)]:
				crop_oval(pos + offset * size, Vector2(11, 9) * size, green)
			if ripe:
				for offset in [Vector2(-9, 0), Vector2(10, 3)]:
					var berry: Vector2 = pos + offset
					draw_colored_polygon(PackedVector2Array([berry + Vector2(-8, -6), berry + Vector2(8, -6), berry + Vector2(7, 3), berry + Vector2(0, 12), berry + Vector2(-7, 3)]), Color("bf7868"))
					draw_line(berry + Vector2(-5, -6), berry + Vector2(5, -6), green, 4)
					draw_circle(berry, 1.8, Color("e7cf95"))
func travel_to(area: String, point: Vector2, persist: bool = true) -> void:
	if WeatherLife.forecast(day) == "Hurricane":
		set_location(true,ROOM_ORIGIN+interior.ENTRY)
		say("Hurricane: stay inside and sleep until tomorrow.")
		return
	if is_instance_valid(polish): polish.path.clear()
	clear_item_moment()
	stop_fishing()
	# Migrate earlier saves from the removed connecting road.
	if area == "road":
		travel_to("town", town.design(Vector2(1200,2000)), persist)
		return
	for room in shops.values():
		room.visible = false
		RenderingServer.canvas_item_clear(room.get_canvas_item())
	preload("res://InteriorArtwork.gd").textures.clear()
	if festival_active: end_festival()
	for region in regions.values(): region.visible = false
	if area == "farm":
		set_location(false, point)
	else:
		location = area
		preload("res://DailyErrands.gd").visit(self,area)
		inside_house = false
		outdoor_world.visible = false
		interior.visible = false
		town.visible = area == "town"
		road.visible = area == "road"
		var origin: Vector2 = REGION_ORIGINS[area] if regions.has(area) else (TOWN_ORIGIN if area == "town" else ROAD_ORIGIN)
		var dimensions: Vector2 = regions[area].SIZE if regions.has(area) else (town.SIZE if area == "town" else road.SIZE)
		if regions.has(area): regions[area].visible = true
		var arrival: Vector2 = regions[area].safe_point(point) if regions.has(area) else point
		player.position = origin + arrival
		player.collision_mask = 16 if regions.has(area) else (4 if area == "town" else 8)
		camera.limit_left = int(origin.x)
		camera.limit_top = 0
		camera.limit_right = int(origin.x + dimensions.x)
		camera.limit_bottom = int(dimensions.y)
		camera.offset = Vector2.ZERO
		fit_region_camera(dimensions)
		camera.reset_smoothing()
	player.velocity = Vector2.ZERO
	joystick.reset_stick()
	nearest = -1
	update_walk(0.0, false, Vector2.UP)
	say("Main Town. Visit the store or meet the residents." if area == "town" else ("South Road. Town north, family farm south." if area == "road" else "Welcome back to the farm."))
	refresh_hud()
	queue_redraw()
	if persist: save_game(false)

func start_conversation(npc: Node2D) -> void:
	talking_npc = npc
	npc.paused = true
	npc.face_player(player.position)
	var person: String = npc.first_name
	if not friendship.has(person): friendship[person] = 0
	if town.EXTRA_DIALOGUE.has(person): dialogue_lines.assign(town.EXTRA_DIALOGUE[person])
	if int(talked_on_day.get(person, -1)) != day:
		friendship[person] = mini(100, int(friendship[person]) + 1)
		talked_on_day[person] = day
	var first := int(friendship[person]) <= 1
	if Cast.DIALOGUE.has(person):
		dialogue_lines.assign(Cast.DIALOGUE[person])
	match person:
		"Seira":
			dialogue_lines = ["You're the new farmer, right? I'm Seira. Come by the store if you need seeds!", "I grew up here. Sometimes I wonder what life is like somewhere bigger. You'll have to tell me about your life before coming here."] if first else ["How is the farm coming along? Mum likes seeing someone put that old land to use.", "I'll be around the plaza after work. There's more to this town than the shop shelves!"]
		"Shohei":
			dialogue_lines = ["I'm Shohei. I work at the forge with Gen. Treat your tools well and they'll return the favor.", "We're trying out a lighter watering can. Stop by the Blacksmith if farm work is wearing you out."] if first else ["Still farming? Good. I thought you might give up after the first sore morning.", "Gen has his way of doing things. I'm figuring out mine. There's room for both, I think."]
		"Akira":
			dialogue_lines = ["Welcome! I'm Akira, the mayor. It's good to see someone back on your family's land.", "The store sells seeds, the café has a hot meal, and the forge can help with your tools. Take your time settling in."] if first else ["Every restored field makes this place feel a little more alive.", "The roads lead to tea country, the harbor, and the mountains. We'll have more to explore as the town grows."]
		"Taro":
			dialogue_lines = ["Taro. I'm the town police officer. Let me know if you need a hand finding your way.", "My younger brother Jiro runs the fire station. He's the loud one. You'll hear him before you meet him."] if first else ["Keeping well? Don't work yourself into the ground. Even an ambitious farmer needs sleep.", "I make a few rounds each day. If I'm not at the police box, try the main road or plaza."]
	if person == "Taro":
		if lost_item_stage == 0:
			lost_item_stage = 1
			dialogue_lines = ["Someone lost a wallet near Haruka's archive. Could you look inside the library in town?", "Bring it back to me when you find it. I'll make sure it reaches its owner."]
		elif lost_item_stage == 1:
			dialogue_lines = ["Try Haruka's library in town. Look beside the old maps."]
		elif lost_item_stage == 2:
			lost_item_stage = 3
			coins += 75
			friendship.Taro = mini(100, int(friendship.Taro) + 5)
			dialogue_lines = ["That's the missing wallet! Thank you. I'll get it back to its owner.", "Here's ¥75 for your help. It's good to have you looking out for the town."]
		else:
			dialogue_lines = ["The wallet is safely back with its owner. Thanks again for helping."]
	if person == "Hiro" and not mine_lesson_seen:
		mine_lesson_seen = true
		dialogue_lines = ["The old mine entrance is north of the lodge road. Walk through the dark opening to enter; there's a spare pick inside.", "Each rock takes four Health to work. Copper and iron go in your basket, then into the farm shipping box.", "Take breaks at Emi's lodge. Fresh ore can be gathered the next day. This first chamber is enough to get started."]
	if person == "Sachiko" and not tea_lesson_seen:
		tea_lesson_seen = true
		dialogue_lines = ["Mika and I have set aside three small tea rows for you. Look for the leaf signs in our fields.", "Pick the tender leaves once each day. Two handfuls make one packet at the processing shed counter.", "Put the packets in your farm shipping box. Each sells for ¥45 the next morning. Leave the bushes to rest until tomorrow."]
	if person == "Mika":
		if tea_delivery_stage == 0:
			tea_delivery_stage = 1
			dialogue_lines = ["Could you take this small tea parcel to Naomi at the café? She wants to try our latest batch.", "I've packed it for you. Find Naomi and talk to her whenever you have time."]
		elif tea_delivery_stage == 1:
			dialogue_lines = ["The tea parcel is for Naomi at the café. Thank you for taking it over."]
		else:
			dialogue_lines = ["Naomi loved the tea. Thanks for helping us share a little of the farm with town."]
	if person == "Naomi" and tea_delivery_stage == 1:
		tea_delivery_stage = 2
		coins += 40
		friendship.Mika = mini(100, int(friendship.Mika) + 3)
		friendship.Naomi = mini(100, int(friendship.Naomi) + 3)
		dialogue_lines = ["Tea from Mika? Lovely! I'll brew some for the café.", "Here's ¥40 for bringing it over. Tell Mika I'll put a pot on tomorrow."]
	if person == "Ken" and fishing_quest_stage == 0:
		fishing_quest_stage = 1
		dialogue_lines = ["Want to try fishing? Use either marked fishing spot at the harbor. I've left a spare rod there.", "Cast, wait until the float dips and Catch lights up, then press Catch. Catch one fish and tell Masao about it."]
	if person == "Masao":
		if fishing_quest_stage == 1:
			dialogue_lines = ["Try the marked harbor spots. Wait for the bite before pressing Catch. Then come back and tell me."]
		elif fishing_quest_stage == 2:
			fishing_quest_stage = 3
			coins += 50
			friendship.Masao = mini(100, int(friendship.Masao) + 3)
			friendship.Ken = mini(100, int(friendship.Ken) + 3)
			dialogue_lines = ["Your first catch! Nicely done. Here's ¥50 to help you get started.", "Fish go into your basket. Put them in the farm shipping box to sell them next day."]
	dialogue_index = 0
	make_modal(person, true)
	dialogue_text.text = dialogue_lines[0]
	dialogue_text.get_parent().add_child(make_button("Continue  ▶", advance_dialogue))
	save_game(false)

func make_modal(title: String, portrait: bool = false) -> VBoxContainer:
	dialogue_open = true
	if is_instance_valid(polish): polish.path.clear()
	player.velocity = Vector2.ZERO
	joystick.reset_stick()
	dialogue_panel = ColorRect.new()
	dialogue_panel.color = Color(0.06, 0.09, 0.06, 0.28)
	hud.add_child(dialogue_panel)
	dialogue_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", parchment())
	dialogue_panel.add_child(panel)
	panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	panel.offset_left = 24
	panel.offset_right = -24
	panel.offset_top = -255
	panel.offset_bottom = -20
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 20)
	panel.add_child(row)
	if portrait:
		var portrait_texture := preload("res://CharacterArt.gd").portrait(title)
		var picture := TextureRect.new()
		picture.texture = portrait_texture
		picture.custom_minimum_size = Vector2(150, 215)
		picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		row.add_child(picture)
	var column := VBoxContainer.new()
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.add_theme_constant_override("separation", 8)
	row.add_child(column)
	var name_label := Label.new()
	name_label.text = title
	name_label.add_theme_font_size_override("font_size", 27)
	name_label.add_theme_color_override("font_color", Color("493b2d"))
	column.add_child(name_label)
	dialogue_text = Label.new()
	dialogue_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dialogue_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	dialogue_text.add_theme_font_size_override("font_size", 21)
	dialogue_text.add_theme_color_override("font_color", Color("493b2d"))
	column.add_child(dialogue_text)
	refresh_hud()
	return column

func advance_dialogue() -> void:
	if not dialogue_open: return
	if active_scene != "":
		advance_scene()
		return
	if not is_instance_valid(talking_npc):
		close_dialogue()
		return
	dialogue_index += 1
	if dialogue_index >= dialogue_lines.size():
		close_dialogue()
	else: dialogue_text.text = dialogue_lines[dialogue_index]

func close_dialogue() -> void:
	if is_instance_valid(farm_visitor): farm_visitor.queue_free()
	farm_visitor = null
	for record in scene_actors:
		var actor = record.npc
		if actor.get_parent() != record.parent: actor.reparent(record.parent, false)
		actor.position = record.position
		actor.paused = record.paused
		actor.show_frame(record.facing, 1)
	scene_actors.clear()
	if is_instance_valid(talking_npc): talking_npc.paused = festival_active or (location == "shop" and shops[shop_name].residents.find(talking_npc) == 0)
	talking_npc = null
	active_scene = ""
	dialogue_open = false
	if is_instance_valid(dialogue_panel): dialogue_panel.queue_free()
	joystick.reset_stick()
	refresh_hud()

func open_service(service: String) -> void:
	if service in ["Carpentry", "Mountain Carpentry"]:
		InteriorLife.open_carpentry(self)
		return
	if service == "Onsen Resort":
		open_onsen()
		return
	if service == "Mine":
		say("Walk to a rock and press Mine. Exit through the south doorway.")
		return
	if REGIONAL_ROOMS.has(service):
		var column := make_modal(service)
		dialogue_text.text = {"Archive": "Old maps and family records preserve the town's history. Talk to Haruka to learn more.", "Shrine Residence": "Rei prepares tea and festival plans here. Walk over to talk.", "Mountain Lodge": "Emi welcomes walkers here. Rest at the lodge for ¥30 to recover 30 Health.", "Tea Farmhouse": "Sachiko and Mika welcome you to their farmhouse. A sitting area and family rooms overlook the tea fields.", "Tea Processing Shed": "Fresh leaves are sorted, dried, and packed here. Talk to Sachiko about tea. Two handfuls of fresh leaves make one packet. Each packet ships for ¥45.", "Harbor Homes": "Ken and Masao have rooms near the harbor. Talk to them about life on the coast.", "Fishing Shop": "Masao keeps tackle and repairs gear here. Fishing equipment purchases will come in a later draft.", "Hiro Cabin": "Hiro keeps field notes and trail supplies in his cabin. Walk over to talk about the mountains."}[service]
		if service == "Tea Processing Shed":
			dialogue_text.text = "Fresh leaves: %d · Packed tea: %d\nTwo handfuls make one packet. Ship packets for ¥45 each." % [tea_leaves, packed_tea]
			column.add_child(make_button("Pack tea · 2 leaves", process_tea))
		if service == "Mountain Lodge": column.add_child(make_button("Rest · ¥30", purchase_meal))
		column.add_child(make_button("Close", close_dialogue))
		return
	if service in ["Town Hall", "Police Box", "Fire Station"]:
		var column := make_modal(service)
		dialogue_text.text = {"Town Hall": "Welcome to town hall. Akira can tell you about the community. The plaza noticeboard hosts our draft festivals and character scenes.", "Police Box": "Taro keeps watch over the town. Walk over to talk with him. Lost-property quests will come in a future draft.", "Fire Station": "Jiro and Yuta prepare equipment here between calls. Walk over to talk with them. Rescue missions will come in a future draft."}[service]
		column.add_child(make_button("Close", close_dialogue))
		return
	if service == "Clinic":
		var column := make_modal("Clinic · Dr. Kenji")
		dialogue_text.text = "Treatment restores Health fully for ¥50.\nHealth: %d / 100   ·   Money: ¥%d" % [int(health), coins]
		column.add_child(make_button("Treatment · ¥50", clinic_treatment))
		column.add_child(make_button("Close", close_dialogue))
		return
	if service == "Inn":
		var column := make_modal("Inn · Yumi")
		dialogue_text.text = "Welcome. Take a short rest in a guest room.\nA rest restores 30 Health for ¥30."
		column.add_child(make_button("Rest · ¥30", purchase_meal))
		column.add_child(make_button("Close", close_dialogue))
		return
	if service == "General Store":
		if clock_minutes < 480 or clock_minutes >= 1080:
			say("General Store opens 8 AM–6 PM. Come back during the day.")
			return
		var column := make_modal("General Store · Keiko")
		dialogue_panel.get_child(0).offset_top = -410
		dialogue_text.text = "Choose seeds. Each pack has five; crops need daily watering and grow overnight."
		for crop_name in CROPS:
			column.add_child(make_button("%s · %d nights · 5 seeds ¥%d" % [crop_name, CROPS[crop_name].days, CROPS[crop_name].pack], purchase_crop_seeds.bind(crop_name)))
		column.add_child(make_button("Backpacks", open_backpack_shop))
		column.add_child(make_button("Close", close_dialogue))
	elif service == "Café":
		if clock_minutes < 720 or clock_minutes >= 1140:
			say("Naomi's café opens noon–7 PM. Lunch will be ready then.")
			return
		var column := make_modal("Café · Naomi")
		dialogue_text.text = "A warm home-cooked meal restores 30 Health.\nHealth: %d / 100   ·   Money: ¥%d" % [int(health), coins]
		column.add_child(make_button("Enjoy a meal · ¥30", purchase_meal))
		column.add_child(make_button("Leave", close_dialogue))
	elif service == "Blacksmith":
		if clock_minutes < 420 or clock_minutes >= 1020:
			say("The forge opens 7 AM–5 PM.")
			return
		var column := make_modal("Blacksmith · Gen")
		dialogue_panel.get_child(0).offset_top = -380
		dialogue_text.text = "Bring ore in your backpack. Money ¥%d\nCopper %d · Iron %d. Upgrades reduce work Health." % [coins, ore_basket.Copper, ore_basket.Iron]
		if tool_level == 0: column.add_child(make_button("Light watering can · ¥100 + 2 Copper", purchase_upgrade))
		if pick_level == 0: column.add_child(make_button("Copper pick · ¥150 + 2 Copper", purchase_ore_upgrade.bind("pick")))
		if harvest_level == 0: column.add_child(make_button("Harvest tools · ¥250 + 2 Iron", purchase_ore_upgrade.bind("harvest")))
		if tool_level + pick_level + harvest_level == 3: dialogue_text.text += "\nAll three tools are upgraded."
		column.add_child(make_button("Leave", close_dialogue))
	else:
		var column := make_modal(service)
		dialogue_text.text = {"Town Hall": "Akira is often outside visiting residents. You may find him around the plaza.", "Clinic": "Kenji and Aya work here. Clinic visits are coming in a later draft.", "Inn": "Yumi and Hana run the inn. Guest rooms are coming in a later draft.", "Police Box": "Taro is out on patrol. Try the main road or plaza.", "Fire Station": "Jiro and Yuta work here. The station interior is coming in a later draft."}.get(service, "This building is not open yet.")
		column.add_child(make_button("Leave", close_dialogue))
	# Conversation continue control is separate from purchase buttons.

func purchase_seeds() -> void:
	purchase_crop_seeds("Turnip")

func purchase_crop_seeds(crop_name: String) -> void:
	if coins < CROPS[crop_name].pack:
		dialogue_text.text = "Not enough money for that pack."
		return
	if seed_count(crop_name) > 994:
		dialogue_text.text = "Your seed bag is full."
		return
	coins -= CROPS[crop_name].pack
	if crop_name == "Turnip": seeds += 5
	else: extra_seeds[crop_name] += 5
	dialogue_text.text = "%s seeds: %d · Money ¥%d" % [crop_name, seed_count(crop_name), coins]
	save_game(false)
	refresh_hud()

func purchase_meal() -> void:
	if health >= MAX_HEALTH:
		dialogue_text.text = "You're already well rested. Come back when you need a meal."
		return
	if coins < 30:
		dialogue_text.text = "A meal costs ¥30. You're welcome to rest here a little."
		return
	coins -= 30
	health = minf(MAX_HEALTH, health + 30)
	dialogue_text.text = "Enjoy! Health: %d / 100   ·   Money: ¥%d" % [int(health), coins]
	save_game(false)
	refresh_hud()

func purchase_upgrade() -> void:
	purchase_ore_upgrade("water")

func purchase_ore_upgrade(kind: String) -> void:
	if kind not in ["water", "pick", "harvest"]: return
	if (kind == "water" and tool_level > 0) or (kind == "pick" and pick_level > 0) or (kind == "harvest" and harvest_level > 0): return
	var price: int = {"water": 100, "pick": 150, "harvest": 250}[kind]
	var mineral: String = "Iron" if kind == "harvest" else "Copper"
	if clock_minutes < 420 or clock_minutes >= 1020:
		dialogue_text.text = "The forge is closed. Return between 7 AM and 5 PM."
		return
	if coins < price or int(ore_basket[mineral]) < 2:
		dialogue_text.text = "This upgrade needs ¥%d and 2 %s in your backpack. Chest ore must be collected first." % [price, mineral]
		return
	coins -= price
	ore_basket[mineral] -= 2
	if kind == "water": tool_level = 1
	elif kind == "pick": pick_level = 1
	else: harvest_level = 1
	close_dialogue()
	open_service("Blacksmith")
	dialogue_text.text += "\nUpgrade ready: watering %d, mining %d, harvesting %d Health." % [2 - tool_level, 4 - pick_level * 2, 3 - harvest_level * 2]
	save_game(false)
	refresh_hud()

func service_door(service: String) -> Vector2:
	for building in town.BUILDINGS:
		if building.name == service: return building.door * town.ART_SCALE
	return Vector2(-1000, -1000)

func shop_opening_hours() -> Dictionary:
	return {"General Store": Vector2(480, 1080), "Blacksmith": Vector2(420, 1020), "Café": Vector2(720, 1140), "Inn": Vector2(360, 1320), "Clinic": Vector2(540, 1020), "Town Hall": Vector2(540, 1020), "Police Box": Vector2(360, 1320), "Fire Station": Vector2(360, 1320), "Archive": Vector2(540, 1080), "Shrine Residence": Vector2(360, 1200), "Mountain Lodge": Vector2(360, 1200), "Tea Farmhouse": Vector2(360, 1200), "Tea Processing Shed": Vector2(360, 1080), "Harbor Homes": Vector2(360, 1200), "Fishing Shop": Vector2(360, 1080), "Hiro Cabin": Vector2(360, 1200), "Mine": Vector2(0, 1440), "Carpentry":Vector2(720,1080), "Mountain Carpentry":Vector2(480,720), "Onsen Resort":Vector2(480,1260), "Barn":Vector2(0,1440),"Greenhouse":Vector2(0,1440),"Upper Floor":Vector2(0,1440)}

func open_shop_hours() -> void:
	var column := make_modal("Shop opening hours")
	dialogue_panel.get_child(0).offset_top = -380
	dialogue_text.text = "Plan your visit. Kenta works in the mountains in the morning and town after noon."
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 160)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(scroll)
	var label := Label.new()
	label.text = ""
	for service in shop_opening_hours():
		var hours: Vector2 = shop_opening_hours()[service]
		label.text += "%s: %02d:%02d – %02d:%02d\n" % [service, int(hours.x) / 60, int(hours.x) % 60, int(hours.y) / 60, int(hours.y) % 60]
	scroll.add_child(label)
	column.add_child(make_button("Back to noticeboard", open_noticeboard))
	column.add_child(make_button("Close", close_dialogue))

func open_noticeboard() -> void:
	var column := make_modal("Plaza Noticeboard")
	# A scrollable catalog makes every original scene available for critique.
	dialogue_panel.get_child(0).offset_top = -380
	dialogue_text.text = "Check festival dates, volunteer requests, and opening hours here. Scene previews are below."
	dialogue_text.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 160)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(scroll)
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(list)
	if gathering_available(): list.add_child(make_button("Join today’s Spring Gathering", start_scheduled_gathering))
	list.add_child(make_button("Festival calendar", open_calendar))
	list.add_child(make_button("Requests & volunteering", VolunteerRequests.journal.bind(self)))
	list.add_child(make_button("Shop opening hours", open_shop_hours))
	list.add_child(make_button("Community requests and restoration", InteriorLife.open_projects.bind(self)))
	list.add_child(make_button("Spring Gathering · Preview", begin_festival))
	for title in CharacterScenes.SCENES:
		list.add_child(make_button(title + (" · Seen" if seen_scenes.has(title) else ""), start_scene.bind(title)))
	column.add_child(make_button("Leave", close_dialogue))

func start_scene(title: String) -> void:
	close_dialogue()
	travel_to("town", town.design(Vector2(1200,1090)), false)
	scene_steps = CharacterScenes.SCENES[title]
	scene_step = 0
	active_scene = title
	var names: Array = []
	for step in scene_steps:
		if not names.has(step[0]): names.append(step[0])
	var all: Array = town.npcs.duplicate()
	all.append_array(town.visitors)
	for area in regions.values(): all.append_array(area.npcs)
	for actor in all:
		if not names.has(actor.first_name): continue
		scene_actors.append({"npc": actor, "parent": actor.get_parent(), "position": actor.position, "paused": actor.paused, "facing": actor.facing})
		if actor.get_parent() != town: actor.reparent(town, false)
		actor.visible = true
		actor.position = Vector2(1200 + (names.find(actor.first_name) - (names.size() - 1) * 0.5) * 120, 980)
		actor.paused = true
		actor.show_frame(0, 1)
	show_scene_step()

func show_scene_step() -> void:
	var step: Array = scene_steps[scene_step]
	var column := make_modal(step[0], true)
	dialogue_text.text = step[1]
	column.add_child(make_button("Continue  ▶", advance_scene))

func advance_scene() -> void:
	scene_step += 1
	if scene_step >= scene_steps.size():
		if not seen_scenes.has(active_scene): seen_scenes.append(active_scene)
		close_dialogue()
		save_game(false)
		return
	if is_instance_valid(dialogue_panel): dialogue_panel.queue_free()
	show_scene_step()

func begin_festival(spec: Dictionary = {}) -> void:
	current_festival = spec
	festival_center = Vector2(1200,910) if spec.is_empty() else SeasonalFestivals.center(spec.area)
	if spec.is_empty() or spec.area=="town": festival_center=town.design(festival_center)
	festival_origin = TOWN_ORIGIN if spec.is_empty() or spec.area == "town" else REGION_ORIGINS[spec.area]
	var host = town if spec.is_empty() or spec.area == "town" else regions[spec.area]
	scheduled_gathering = false
	close_dialogue()
	festival_active = true
	var view := get_viewport_rect().size
	camera.zoom = Vector2.ONE * maxf(0.48,maxf(view.x/host.SIZE.x,view.y/host.SIZE.y))
	festival_elapsed = 0.0
	festival_people.clear()
	var all: Array = town.npcs.duplicate()
	all.append_array(town.visitors)
	for area in regions.values(): all.append_array(area.npcs)
	if spec.has("people"): all = all.filter(func(npc): return npc.first_name in spec.people)
	for i in range(all.size()):
		var npc = all[i]
		festival_people.append({"npc": npc, "parent": npc.get_parent(), "position": npc.position, "paused": npc.paused, "facing": npc.facing})
		if npc.get_parent() != host: npc.reparent(host, false)
		npc.visible = true
		npc.paused = true
		npc.label.visible = false
		npc.position = festival_center + Vector2(170 if not current_festival.is_empty() else 270, 0).rotated(TAU * i / all.size())
		if host.has_method("safe_point"): npc.position=host.safe_point(npc.position)
		npc.show_frame(0, 1)
	player.position = festival_origin + festival_center + Vector2(0,110)
	festival_button.visible = true
	if is_instance_valid(tea_challenge_button): tea_challenge_button.queue_free()
	tea_challenge_button = make_button("Activity",SeasonalFestivals.open_activity.bind(self)) if not spec.is_empty() else make_button("Tea challenge",InteriorLife.festival_game.bind(self,0))
	hud.add_child(tea_challenge_button)
	tea_challenge_button.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	tea_challenge_button.position = Vector2(get_viewport_rect().size.x/2-90,85)
	tea_challenge_button.size = Vector2(180,48)
	say("Spring Gathering rehearsal! Walk around, meet everyone, then End Festival.")
	refresh_hud()

func animate_festival() -> void:
	for i in range(festival_people.size()):
		var npc = festival_people[i].npc
		var angle := TAU * i / festival_people.size()
		npc.position = festival_center + Vector2(170 if not current_festival.is_empty() else 270, 0).rotated(angle) + Vector2(sin(festival_elapsed * 2.0 + i) * 8, cos(festival_elapsed * 3.0 + i) * 3)
		var host=npc.get_parent()
		if host.has_method("safe_point"): npc.position=host.safe_point(npc.position)
		npc.show_frame(0, int(festival_elapsed * 5.0 + i) % 4)
		npc.z_index = int(npc.position.y / 10)

func end_festival() -> void:
	if is_instance_valid(tea_challenge_button): tea_challenge_button.queue_free()
	if not festival_active: return
	for record in festival_people:
		var npc = record.npc
		if npc.get_parent() != record.parent: npc.reparent(record.parent, false)
		npc.position = record.position
		npc.paused = record.paused
		npc.facing = record.facing
		npc.label.visible = true
		npc.show_frame(npc.facing, 1)
	festival_people.clear()
	SeasonalFestivals.finish(self)
	if scheduled_gathering:
		var year := int((day - 1) / 112) + 1
		if not festival_years.has(year):
			festival_years.append(year)
			coins += 100
			for person in friendship: friendship[person] = mini(100, int(friendship[person]) + 2)
			say("Spring Gathering complete! ¥100 and friendship with the town.")
		scheduled_gathering = false
		save_game(false)
	festival_active = false
	current_festival = {}
	town.ambient_period = -1
	festival_button.text = "End Festival"
	fit_region_camera(regions[location].SIZE if regions.has(location) else town.SIZE)
	festival_button.visible = false
	if toast_time <= 0: say("Thanks for joining the gathering. Town life resumes.")
	refresh_hud()

func enter_shop(service: String, restoring: bool = false) -> void:
	if not shops.has(service):
		open_service(service)
		return
	if not restoring:
		var hours := shop_opening_hours()
		if clock_minutes < hours[service].x or clock_minutes >= hours[service].y:
			say("%s is closed. Please return during opening hours." % service)
			return
	for room in shops.values():
		room.visible = false
		RenderingServer.canvas_item_clear(room.get_canvas_item())
	preload("res://InteriorArtwork.gd").textures.clear()
	for region in regions.values(): region.visible = false
	outdoor_world.visible = false
	interior.visible = false
	town.visible = false
	road.visible = false
	inside_house = false
	if is_instance_valid(polish): polish.path.clear()
	location = "shop"
	shop_name = service
	if not restoring: preload("res://DailyErrands.gd").visit(self,service)
	SHOP_ORIGIN = shops[service].position
	shops[service].visible = true
	shops[service].queue_redraw()
	if service == "Mine":
		shops.Mine.depleted = []
		for picked_day in ore_picked_days: shops.Mine.depleted.append(int(picked_day) >= day)
		shops.Mine.queue_redraw()
	if service == "Archive":
		shops[service].lost_item_visible = lost_item_stage == 1
		shops[service].queue_redraw()
	player.position = SHOP_ORIGIN + ShopScript.ENTRY
	player.collision_mask = 32
	player.velocity = Vector2.ZERO
	joystick.reset_stick()
	camera.limit_left = int(SHOP_ORIGIN.x)
	camera.limit_top = 0
	camera.limit_right = int(SHOP_ORIGIN.x + ShopScript.SIZE.x)
	camera.limit_bottom = int(ShopScript.SIZE.y)
	fit_region_camera(ShopScript.SIZE)
	camera.offset = Vector2.ZERO
	camera.reset_smoothing()
	say("Approach a rock and press Mine. Walk out the south doorway to leave." if service == "Mine" else "Welcome to %s. Approach residents or the counter; walk out the south door to leave." % service)
	refresh_hud()
	save_game(false)

func check_walk_exits() -> void:
	if location == "shop":
		var point := player.position - SHOP_ORIGIN
		if point.y > 755 and absf(point.x - 550) < 110:
			if shop_name == "Upper Floor":
				set_location(true,ROOM_ORIGIN+FarmBuildings.STAIRS+Vector2(0,90))
			elif shop_name == "Greenhouse":
				travel_to("farm",FarmBuildings.GREENHOUSE_DOOR+Vector2(0,100))
			elif shop_name == "Barn":
				travel_to("farm", BARN_DOOR + Vector2(0,110))
			elif REGIONAL_ROOMS.has(shop_name):
				travel_to(REGIONAL_ROOMS[shop_name][0], REGIONAL_ROOMS[shop_name][1] + (Vector2(0,70) if shop_name == "Onsen Resort" else Vector2(0,70)))
			else:
				travel_to("town", service_door(shop_name) + Vector2(0, 70))
		return
	if festival_active or dialogue_open: return
	if inside_house:
		var local := player.position-ROOM_ORIGIN
		if local.distance_to(interior.EXIT)<20: leave_house()
		elif interior_progress.get("second_story",false) and local.distance_to(FarmBuildings.STAIRS)<45: enter_shop("Upper Floor")
		return
	if location=="farm" and player.position.distance_to(farmhouse.DOOR_POSITION)<50:
		enter_house()
		return
	if door_retry<=0:
		if location=="town":
			for building in town.BUILDINGS:
				if player.position.distance_to(TOWN_ORIGIN+building.door*town.ART_SCALE)<50:
					door_retry=1.5
					enter_shop(building.name)
					return
		elif regions.has(location):
			for room in REGIONAL_ROOMS:
				if REGIONAL_ROOMS[room][0]==location and player.position.distance_to(REGION_ORIGINS[location]+REGIONAL_ROOMS[room][1])<50:
					door_retry=1.5
					enter_shop(room)
					return
	if location == "mountain" and (player.position - REGION_ORIGINS.mountain).distance_to(RegionScript.MINE_DOOR) < 45:
		enter_shop("Mine")
		return
	match location:
		"farm":
			if interior_progress.get("greenhouse",false) and player.position.distance_to(FarmBuildings.GREENHOUSE_DOOR)<55:
				enter_shop("Greenhouse")
				return
			if player.position.distance_to(BARN_DOOR) < 55:
				enter_shop("Barn")
				return
			if player.position.distance_to(FARM_EXIT) < 55:
				travel_to("town", town.design(Vector2(1200,2000)))
		"road":
			var point := player.position - ROAD_ORIGIN
			if point.y < 70 and absf(point.x - 500) < 170:
				travel_to("town", town.design(Vector2(1200,2000)))
			elif point.y > 930 and absf(point.x - 500) < 170:
				travel_to("farm", FARM_EXIT + Vector2(0, 100))
		"town":
			var point := player.position - TOWN_ORIGIN
			if point.y > 1520 and absf(point.x - 1200) < 180:
				travel_to("farm", FARM_EXIT + Vector2(0, 100))
			elif point.y < 65 and absf(point.x - 1280) < 180:
				travel_to("mountain", Vector2(800, 950))
			elif point.x < 100 and absf(point.y - 800) < 130:
				travel_to("harbor", Vector2(1480,585))
			elif point.x > 2300 and absf(point.y - 800) < 130:
				travel_to("tea", Vector2(140,665))
			elif point.x < 430 and point.y < 160:
				travel_to("historic", Vector2(1440,1060))
		_:
			if regions.has(location):
				var point: Vector2 = player.position - REGION_ORIGINS[location]
				if ((location=="harbor" and point.x>1520 and absf(point.y-585)<120) or (location=="tea" and point.x<75 and absf(point.y-665)<120) or (location=="historic" and point.x>1520 and point.y>1070) or (location=="mountain" and point.y>1120 and absf(point.x-800)<100)):
					var arrivals := {"mountain": Vector2(1200, 180), "harbor": Vector2(220, 1080), "tea": Vector2(2180, 1080), "historic": Vector2(180,300)}
					travel_to("town", town.design(arrivals[location]))

func open_map() -> void:
	if choosing_character or confirming_sleep or sleep_in_progress or dialogue_open: return
	var column := make_modal("Walking Routes")
	dialogue_panel.get_child(0).offset_top = -340
	dialogue_text.text = "Farm → Town walkway → Main Town.\n\nFrom town: north to Mountain & Onsen; east to Tea Country; west to the Harbor; northwest through the large torii to Shrine Grounds.\n\nHarbor: return east toward town. Tea Country: return west. Shrine Grounds: return southeast. Mountains: return south. Walk through doors and gateways to change areas automatically. The library is northeast of the town square."
	column.add_child(make_button("Close", close_dialogue))

func open_guide() -> void:
	if choosing_character or confirming_sleep or sleep_in_progress or dialogue_open: return
	var column := make_modal("Welcome Home")
	dialogue_panel.get_child(0).offset_top = -380
	dialogue_text.text = "Move with arrows/WASD or the joystick. Hold Shift, or push the joystick farther, to run.\n\nChoose seeds → Plant → Water daily → Sleep → Harvest → Shipping box. Sleep in the house to recover Health.\n\nWalk onto the Town walkway on the farm to enter town directly. All marked region exits work by walking through them; Routes shows directions. Visit the store for seeds, the forge for an upgrade, and the café for meals.\n\nTown exits: north mountain/lake, east tea fields, west harbor, northwest shrine. The plaza Events board previews scenes and the festival."
	dialogue_text.add_theme_font_size_override("font_size", 18)
	column.add_child(make_button("Let's explore", close_dialogue))



func clinic_treatment() -> void:
	if health >= MAX_HEALTH:
		dialogue_text.text = "You're already healthy. No treatment needed."
		return
	if coins < 50:
		dialogue_text.text = "Treatment costs ¥50. Resting at home can also restore Health."
		return
	coins -= 50
	health = MAX_HEALTH
	dialogue_text.text = "All better. Take care out there!"
	save_game(false)
	refresh_hud()
func seed_count(crop_name: String) -> int:
	return seeds if crop_name == "Turnip" else int(extra_seeds[crop_name])

func open_seed_picker() -> void:
	if dialogue_open or choosing_character or confirming_sleep: return
	var column := make_modal("Choose Seeds")
	dialogue_panel.get_child(0).offset_top = -410
	dialogue_text.text = "Water daily. Harvests go into your basket, then the shipping box."
	for crop_name in CROPS:
		column.add_child(make_button("%s · %d seeds · %d nights · sells ¥%d" % [crop_name, seed_count(crop_name), CROPS[crop_name].days, CROPS[crop_name].sale], choose_crop.bind(crop_name)))
	column.add_child(make_button("Close", close_dialogue))

func choose_crop(crop_name: String) -> void:
	selected_crop = crop_name
	close_dialogue()
	say("Selected %s seeds." % crop_name)
	save_game(false)

func open_shipping() -> void:
	if dialogue_open: close_dialogue()
	var column := make_modal("Shipping Box")
	var value: int = BarnLife.shipping_value(self)
	var basket: int = packed_tea + BarnLife.product_count(self)
	for mineral in ORE:
		value += int(ore_shipping[mineral]) * ORE[mineral]
		basket += int(ore_basket[mineral])
	value += tea_shipping * 45
	for crop_name in CROPS:
		value += int(shipping_queue[crop_name]) * CROPS[crop_name].sale
		basket += int(produce[crop_name])
	for fish_name in FISH:
		value += int(fish_shipping[fish_name]) * FISH[fish_name]
		basket += int(fish_basket[fish_name])
	dialogue_text.text = "Carrying: %d goods. Queued payment: ¥%d.\nShipped crops, fish, ore, tea packets and animal products are paid for next morning." % [basket, value]
	var ship_button := make_button("Ship all carried goods" if basket>0 else "Nothing to ship — harvest or gather first",ship_produce)
	ship_button.disabled=basket==0
	column.add_child(ship_button)
	column.add_child(make_button("Close", close_dialogue))

func ship_produce() -> void:
	var shipped_count := backpack_count()
	BarnLife.ship(self)
	for mineral in ORE:
		ore_shipping[mineral] += ore_basket[mineral]
		ore_basket[mineral] = 0
	tea_shipping += packed_tea
	packed_tea = 0
	for crop_name in CROPS:
		shipping_queue[crop_name] += produce[crop_name]
		produce[crop_name] = 0
	for fish_name in FISH:
		fish_shipping[fish_name] += fish_basket[fish_name]
		fish_basket[fish_name] = 0
	save_game(false)
	open_shipping()
	dialogue_text.text = "Shipped %d goods.\n" % (shipped_count-backpack_count()) + dialogue_text.text

func settle_farm_day() -> void:
	for mineral in ORE:
		coins += int(ore_shipping[mineral]) * ORE[mineral]
		ore_shipping[mineral] = 0
	if shops.has("Mine"):
		shops.Mine.depleted = []
		for picked_day in ore_picked_days: shops.Mine.depleted.append(int(picked_day) >= day)
		shops.Mine.queue_redraw()
	coins += tea_shipping * 45
	tea_shipping = 0
	for plot in plots:
		if int(plot.get("last_growth_day", day)) >= day: continue
		plot.last_growth_day = day
		if WeatherLife.heatwave_growth(plot,day): continue
		if plot.stage == 2:
			plot.growth += 1
			plot.stage = 3 if plot.growth >= CROPS[plot.crop].days else 1
	for crop_name in CROPS:
		coins += int(shipping_queue[crop_name]) * CROPS[crop_name].sale
		shipping_queue[crop_name] = 0
	for fish_name in FISH:
		coins += int(fish_shipping[fish_name]) * FISH[fish_name]
		fish_shipping[fish_name] = 0
	apply_rain_watering()
	resources.irrigate()
	BarnLife.new_day(self)
	FarmBuildings.new_day(self)
	queue_redraw()
func resident_room(person: String) -> String:
	var morning := clock_minutes < 720
	var evening := clock_minutes >= 1080
	match person:
		"Seira": return "General Store" if morning or evening else ""
		"Keiko": return "Café" if clock_minutes >= 1080 and clock_minutes < 1200 else "General Store"
		"Shohei": return "Blacksmith" if morning or evening else ""
		"Gen": return "Blacksmith" if clock_minutes < 1020 else ""
		"Akira": return "Town Hall" if morning or clock_minutes >= 1200 else ("Café" if evening else "")
		"Taro": return "Police Box" if clock_minutes >= 1200 or (clock_minutes >= 660 and clock_minutes < 840) else ""
		"Kenji", "Aya": return "Clinic" if clock_minutes >= 540 and clock_minutes < 1020 else ""
		"Yumi": return "Inn"
		"Hana": return "Inn" if morning or evening else ""
		"Naomi": return "Café" if clock_minutes >= 720 and clock_minutes < 1140 else ""
		"Jiro": return "Fire Station" if morning else ""
		"Yuta": return "Fire Station" if int((day + int(clock_minutes / 360)) % 2) == 0 else ""
		"Sachiko": return "Tea Farmhouse" if evening else ("Tea Processing Shed" if not morning else "")
		"Mika": return "Tea Farmhouse" if evening else ""
		"Masao": return "Harbor Homes" if evening else ("Fishing Shop" if not morning else "")
		"Ken": return "Harbor Homes" if evening else ""
		"Hiro": return "Mountain Lodge" if evening else ""
		"Emi": return "Mountain Lodge" if not evening else ""
		"Haruka": return "Archive" if morning else ""
		"Rei": return ""
		"Kenta": return "Mountain Carpentry" if clock_minutes >= 480 and clock_minutes < 720 else ("Carpentry" if clock_minutes >= 720 and clock_minutes < 1080 else "")
	return ""

func update_resident_presence() -> void:
	if not is_instance_valid(town): return
	var event_override := festival_active or active_scene != ""
	for room_name in shops:
		for resident in shops[room_name].residents:
			resident.visible = not event_override and resident_room(resident.first_name) == room_name
	if event_override: return
	for resident in town.npcs:
		resident.visible = resident_room(resident.first_name) == ""
	for region in regions.values():
		for resident in region.npcs:
			resident.visible = resident_room(resident.first_name) == ""
func begin_fishing() -> void:
	clear_item_moment()
	if location != "harbor" or fishing_active: return
	if not backpack_has_room():
		say("Backpack full. Ship some items before fishing.")
		return
	if health < 2*WeatherLife.work_multiplier(self):
		say("Too tired to cast. Rest first.")
		return
	health -= 2*WeatherLife.work_multiplier(self)
	fishing_active = true
	fishing_elapsed = 0
	joystick.reset_stick()
	regions.harbor.fishing_spot = player.position - REGION_ORIGINS.harbor
	regions.harbor.fishing_state = 1
	regions.harbor.queue_redraw()
	save_game(false)
	refresh_hud()

func stop_fishing() -> void:
	fishing_active = false
	if regions.has("harbor"):
		regions.harbor.fishing_state = 0
		regions.harbor.queue_redraw()

func catch_fish() -> void:
	if not fishing_active: return
	if fishing_elapsed < 2:
		say("Wait until the float dips.")
		return
	if fishing_elapsed > 4:
		stop_fishing()
		say("The fish got away.")
		return
	var fish_name: String = FISH.keys()[fish_catches % FISH.size()]
	if not backpack_has_room() or fish_basket[fish_name] >= 999:
		stop_fishing()
		say("Backpack full. Use the shipping box or buy a larger bag.")
		return
	fish_basket[fish_name] += 1
	show_item_moment(fish_name)
	fish_catches += 1
	if fishing_quest_stage == 1: fishing_quest_stage = 2
	stop_fishing()
	say("Caught %s! Shipping value ¥%d." % [fish_name, FISH[fish_name]])
	save_game(false)
	refresh_hud()
func harvest_tea() -> void:
	if location != "tea": return
	for i in range(TEA_SPOTS.size()):
		if (player.position - REGION_ORIGINS.tea).distance_to(TEA_SPOTS[i]) >= 70: continue
		if tea_picked_days[i] >= day:
			say("This row needs to rest. Come back tomorrow.")
			return
		if health < 2*WeatherLife.work_multiplier(self) or tea_leaves >= 999 or not backpack_has_room():
			say("Rest or make room in your leaf basket first.")
			return
		tea_picked_days[i] = day
		resources.play("harvest",player.position)
		tea_leaves += 1
		show_item_moment("Tea leaves")
		health -= 2*WeatherLife.work_multiplier(self)
		say("Fresh tea leaves collected. Basket: %d." % tea_leaves)
		save_game(false)
		refresh_hud()
		return

func process_tea() -> void:
	if location != "shop" or shop_name != "Tea Processing Shed": return
	if tea_leaves < 2 or packed_tea >= 999:
		dialogue_text.text = "Bring two handfuls of fresh tea leaves to make a packet."
		return
	tea_leaves -= 2
	packed_tea += 1
	dialogue_text.text = "One packet ready. Leaves: %d · Packets: %d. Ship at your farm for ¥45 each." % [tea_leaves, packed_tea]
	save_game(false)

func mine_ore() -> void:
	if location != "shop" or shop_name != "Mine": return
	for i in range(MINE_SPOTS.size()):
		if (player.position - SHOP_ORIGIN).distance_to(MINE_SPOTS[i]) >= 60: continue
		var mineral: String = "Copper" if i % 2 == 0 else "Iron"
		if ore_picked_days[i] >= day:
			say("This rock is worked out. Return tomorrow.")
			return
		if health < 4 - pick_level * 2 or int(ore_basket[mineral]) >= 999 or not backpack_has_room():
			say("Rest or empty your ore basket first.")
			return
		health -= 4 - pick_level * 2
		ore_basket[mineral] += 1
		show_item_moment(mineral)
		resources.play("mine",SHOP_ORIGIN+MINE_SPOTS[i])
		ore_picked_days[i] = day
		shops.Mine.depleted[i] = true
		shops.Mine.queue_redraw()
		say("%s ore collected. Ship it from your farm for ¥%d." % [mineral, ORE[mineral]])
		save_game(false)
		refresh_hud()
		return

func show_item_moment(item: String) -> void:
	if not is_instance_valid(item_moment): return
	pickup_time = 0.9
	joystick.reset_stick()
	player.velocity = Vector2.ZERO
	facing_direction = 0
	walk_frame = -2
	update_walk(0, false)
	item_moment.modulate = Color.WHITE
	item_moment.position = Vector2(0, -225)
	item_moment.show_item(item)

func clear_item_moment() -> void:
	pickup_time = 0
	if is_instance_valid(item_moment): item_moment.visible = false


func backpack_count() -> int:
	var total: int = tea_leaves + packed_tea + BarnLife.product_count(self)
	for inventory in [produce, fish_basket, ore_basket]:
		for count in inventory.values(): total += int(count)
	return total

func backpack_has_room() -> bool:
	return backpack_count() < BACKPACK_SIZES[backpack_level]

func open_backpack() -> void:
	clear_item_moment()
	var column := make_modal("Backpack · %d / %d" % [backpack_count(), BACKPACK_SIZES[backpack_level]])
	dialogue_text.text = "Seeds and tools use separate pouches. Lumber: %d · Water: %d / 24. Ship items to free space." % [resources.state().lumber,resources.state().water]
	dialogue_text.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 160)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(scroll)
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(list)
	var contents: Dictionary = {}
	for inventory in [produce, fish_basket, ore_basket, BarnLife.state(self).products]:
		for item in inventory:
			if int(inventory[item]) > 0: contents[item] = int(inventory[item])
	if tea_leaves > 0: contents["Tea leaves"] = tea_leaves
	if packed_tea > 0: contents["Tea packets"] = packed_tea
	for item in contents:
		var row := HBoxContainer.new()
		list.add_child(row)
		var slot := Control.new()
		slot.custom_minimum_size = Vector2(64, 64)
		row.add_child(slot)
		var icon := preload("res://ItemMoment.gd").new()
		icon.show_caption = false
		icon.position = Vector2(32, 32)
		icon.scale = Vector2.ONE * 0.8
		slot.add_child(icon)
		icon.show_item(item)
		var label := Label.new()
		label.text = "%s ×%d" % [item, contents[item]]
		label.add_theme_color_override("font_color", Color("493b2d"))
		row.add_child(label)
	if contents.is_empty(): dialogue_text.text = "Your backpack is empty. Collect crops, fish, tea or ore."
	dialogue_panel.get_child(0).offset_top = -380
	column.add_child(make_button("Requests & volunteering",VolunteerRequests.journal.bind(self)))
	column.add_child(make_button("Change farmer", backpack_change_farmer))
	column.add_child(make_button("Close", close_dialogue))

func backpack_change_farmer() -> void:
	close_dialogue()
	show_character_picker()

func open_backpack_shop() -> void:
	if dialogue_open: close_dialogue()
	var column := make_modal("General Store · Backpacks")
	dialogue_text.text = "Current bag: %d items. Money: ¥%d. Seeds and tools stay separate." % [BACKPACK_SIZES[backpack_level], coins]
	if backpack_level < 2:
		column.add_child(make_button("%d-item backpack · ¥%d" % [BACKPACK_SIZES[backpack_level + 1], BACKPACK_PRICES[backpack_level]], purchase_backpack))
	else: dialogue_text.text += "\nYou have the largest backpack."
	column.add_child(make_button("Back to seeds", backpack_back_to_store))
	column.add_child(make_button("Close", close_dialogue))

func backpack_back_to_store() -> void:
	close_dialogue()
	open_service("General Store")

func purchase_backpack() -> void:
	if backpack_level >= 2: return
	if clock_minutes < 480 or clock_minutes >= 1080:
		dialogue_text.text = "The store is closed. Return between 8 AM and 6 PM."
		return
	var price: int = BACKPACK_PRICES[backpack_level]
	if coins < price:
		dialogue_text.text = "You need ¥%d for the next backpack. You have ¥%d." % [price, coins]
		return
	coins -= price
	backpack_level += 1
	save_game(false)
	open_backpack_shop()

func carried_count(item: String) -> int:
	if BarnLife.PRICES.has(item): return int(BarnLife.state(self).products[item])
	if produce.has(item): return int(produce[item])
	if fish_basket.has(item): return int(fish_basket[item])
	if ore_basket.has(item): return int(ore_basket[item])
	return tea_leaves if item == "Tea leaves" else packed_tea

func change_carried(item: String, amount: int) -> void:
	if BarnLife.PRICES.has(item): BarnLife.state(self).products[item] += amount
	elif produce.has(item): produce[item] += amount
	elif fish_basket.has(item): fish_basket[item] += amount
	elif ore_basket.has(item): ore_basket[item] += amount
	elif item == "Tea leaves": tea_leaves += amount
	elif item == "Tea packets": packed_tea += amount

func open_storage(category: String = "Crops") -> void:
	if not inside_house: return
	if dialogue_open: close_dialogue()
	clear_item_moment()
	var column := make_modal("Farmhouse Storage")
	dialogue_panel.get_child(0).offset_top = -410
	dialogue_text.text = "Bag %d / %d · Chest holds 999 of each item. Stored goods stay safe overnight." % [backpack_count(), BACKPACK_SIZES[backpack_level]]
	var tabs := HBoxContainer.new()
	column.add_child(tabs)
	for group in STORAGE_GROUPS:
		var button := make_button(group, open_storage.bind(group))
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tabs.add_child(button)
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size=Vector2(0,120)
	scroll.size_flags_vertical=Control.SIZE_EXPAND_FILL
	column.add_child(scroll)
	var list:=VBoxContainer.new()
	list.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	scroll.add_child(list)
	for item in STORAGE_GROUPS[category]:
		list.add_child(make_button("%s · Bag %d · Chest %d" % [item, carried_count(item), stored_items[item]], open_storage_item.bind(item)))
	column.add_child(make_button("Store everything from bag", store_everything))
	column.add_child(make_button("Close", close_dialogue))

func open_storage_item(item: String) -> void:
	if not inside_house: return
	if dialogue_open: close_dialogue()
	var column := make_modal(item)
	dialogue_panel.get_child(0).offset_top = -370
	dialogue_text.text = "Bag: %d · Chest: %d\nBackpack space: %d / %d" % [carried_count(item), stored_items[item], backpack_count(), BACKPACK_SIZES[backpack_level]]
	for depositing in [true, false]:
		var row := HBoxContainer.new()
		column.add_child(row)
		for amount in [1, 999]:
			var button := make_button(("Store " if depositing else "Take ") + ("1" if amount == 1 else "all"), transfer_storage.bind(item, amount, depositing))
			button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			row.add_child(button)
	column.add_child(make_button("Back to chest", open_storage))
	column.add_child(make_button("Close", close_dialogue))

func transfer_storage(item: String, requested: int, depositing: bool) -> void:
	if not inside_house or not stored_items.has(item): return
	var available: int = carried_count(item) if depositing else int(stored_items[item])
	var room: int = storage_limit() - int(stored_items[item]) if depositing else maxi(0, mini(BACKPACK_SIZES[backpack_level] - backpack_count(), 999 - carried_count(item)))
	var amount := mini(requested, mini(available, room))
	if amount <= 0:
		dialogue_text.text = "No items to move, or no space in the destination."
		return
	stored_items[item] += amount if depositing else -amount
	change_carried(item, -amount if depositing else amount)
	save_game(false)
	open_storage_item(item)

func store_everything() -> void:
	if not inside_house: return
	for item in stored_items:
		var amount := mini(carried_count(item), storage_limit() - int(stored_items[item]))
		stored_items[item] += amount
		change_carried(item, -amount)
	save_game(false)
	open_storage()

func is_rainy_day(value: int = -1) -> bool:
	return WeatherLife.forecast(day if value<0 else value) in ["Rain","Hurricane"]

func apply_rain_watering() -> void:
	if not is_rainy_day(): return
	var changed := false
	for plot in plots:
		if plot.stage == 1:
			plot.stage = 2
			changed = true
	if changed: queue_redraw()

func gathering_date() -> bool:
	return (day - 1) % 112 == 13

func gathering_available() -> bool:
	return gathering_date() and clock_minutes >= 600 and clock_minutes < 1080 and not festival_years.has(int((day - 1) / 112) + 1)

func check_scheduled_gathering() -> void:
	SeasonalFestivals.maybe_start(self)
	if location != "town" or dialogue_open or festival_active or active_scene != "" or choosing_character: return
	if gathering_available() and (player.position - TOWN_ORIGIN).distance_to(Vector2(1200, 910)) < 340:
		start_scheduled_gathering()

func start_scheduled_gathering() -> void:
	if not gathering_available() or festival_active: return
	begin_festival()
	scheduled_gathering = true
	festival_button.text = "Finish Gathering"
	say("Spring Gathering! Meet everyone, then choose Finish Gathering.")
	dialogue_lines = ["Welcome to our Spring Gathering! Every year, we come together in this plaza to celebrate the season.", "Seeing your family's farm come alive again gives us something extra to celebrate. Take a moment to meet everyone.", "When you're ready, choose Finish Gathering. We've set aside a small welcome gift for you."]
	dialogue_index = 0
	var column := make_modal("Akira", true)
	dialogue_text.text = dialogue_lines[0]
	column.add_child(make_button("Continue ▶", advance_dialogue))

func open_calendar() -> void:
	var column := make_modal("Farmhouse Calendar")
	dialogue_panel.get_child(0).offset_top = -410
	var year := int((day - 1) / 112) + 1
	var next_year := year + 1 if (day - 1) % 112 > 13 or festival_years.has(year) else year
	dialogue_text.text = "%s\nTomorrow: %s\n\nSpring Gathering · Spring 14, Year %d\nTown Plaza · 10 AM–6 PM\nWalk into the plaza to join. Finish the gathering for a welcome gift." % [calendar_text(), "Rain (crops watered)" if is_rainy_day(day + 1) else "Clear", next_year]
	dialogue_text.text = "%s\nTomorrow: %s\n\n" % [calendar_text(),WeatherLife.forecast(day+1)] + SeasonalFestivals.calendar(self)
	column.add_child(make_button("Close", close_dialogue))

func storage_limit() -> int:
	return 999 * (1 + int(interior_progress.get("home",0)))

func fit_region_camera(dimensions: Vector2) -> void:
	var viewport_size := get_viewport_rect().size
	var fit := maxf(0.58, maxf(viewport_size.x / dimensions.x, viewport_size.y / dimensions.y))
	camera.zoom = Vector2.ONE * fit
func refit_camera() -> void:
	if location == "farm" and not inside_house:
		camera.zoom = Vector2.ONE * maxf(0.58,maxf(get_viewport_rect().size.x/WORLD.x,get_viewport_rect().size.y/WORLD.y))
	if inside_house:
		fit_region_camera(interior.SIZE)
	elif location=="shop":
		fit_region_camera(ShopScript.SIZE)
	elif regions.has(location):
		fit_region_camera(regions[location].SIZE)
		camera.offset = Vector2.ZERO

func open_onsen() -> void:
	var column := make_modal("Mountain Onsen")
	dialogue_text.text = "A quiet hot-spring bath among the mountain gardens. A soak costs ¥40 and restores 35 Health. Chanel welcomes guests; Ren prepares the baths."
	column.add_child(make_button("Take a soak · ¥40",take_onsen))
	column.add_child(make_button("Close",close_dialogue))
func take_onsen() -> void:
	if health >= 100: dialogue_text.text = "You are already refreshed. Enjoy the view!"; return
	if coins < 40: dialogue_text.text = "A bath costs ¥40. Come back when you can spare it."; return
	coins -= 40
	health = minf(100,health+35)
	clock_minutes = minf(LATE_MINUTE,clock_minutes+30)
	dialogue_text.text = "Warm water, mountain air, and a quiet moment. You feel refreshed."
	save_game(false)
	refresh_hud()
