extends Node2D

const SIZE := Vector2(1000, 800)
const FLOOR := Rect2(90, 190, 820, 530)
const ENTRY := Vector2(500, 665)
const EXIT := Vector2(500, 700)
const BED_APPROACH := Vector2(670, 475)
const BED := Rect2(730, 230, 150, 230)
const TABLE := Rect2(290, 340, 190, 125)
const CALENDAR_APPROACH := Vector2(570, 320)
const CHEST := Rect2(125, 540, 125, 75)
const CHEST_APPROACH := Vector2(190, 665)
const SOLIDS := [BED, TABLE, CHEST, Rect2(110, 200, 140, 85), Rect2(500, 200, 140, 65)]

func _ready() -> void:
	for rect in [Rect2(70, 170, 860, 20), Rect2(70, 720, 860, 20), Rect2(70, 190, 20, 530), Rect2(910, 190, 20, 530)]:
		obstacle(rect)
	for rect in SOLIDS: obstacle(rect)

func obstacle(rect: Rect2) -> void:
	var body := StaticBody2D.new()
	body.collision_layer = 2
	body.collision_mask = 0
	body.position = rect.get_center()
	var collider := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = rect.size
	collider.shape = shape
	body.add_child(collider)
	add_child(body)

func is_walkable(point: Vector2, radius: float = 12.0) -> bool:
	if not FLOOR.grow(-radius).has_point(point): return false
	for rect in SOLIDS:
		if rect.grow(radius).has_point(point): return false
	return true

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, SIZE), Color("293e37"))
	draw_rect(Rect2(70, 90, 860, 650), Color("684a33"))
	draw_rect(Rect2(90, 110, 820, 80), Color("d9be8b"))
	draw_rect(FLOOR, Color("bc9563"))
	for x in range(90, 910, 82):
		draw_line(Vector2(x, 190), Vector2(x, 720), Color("9a754e"), 2)
	for y in range(190, 720, 35):
		draw_line(Vector2(90, y), Vector2(910, y), Color(0.4, 0.26, 0.15, 0.14), 1)
	for rect in [Rect2(150, 120, 130, 55), Rect2(520, 120, 130, 55)]:
		draw_rect(rect, Color("b3d4c6"))
		draw_rect(rect, Color("785a3b"), false, 5)
		for x in range(int(rect.position.x + 26), int(rect.end.x), 26):
			draw_line(Vector2(x, rect.position.y), Vector2(x, rect.end.y), Color("785a3b"), 3)
		draw_line(Vector2(rect.position.x, rect.get_center().y), Vector2(rect.end.x, rect.get_center().y), Color("785a3b"), 3)
	# Tatami sitting area, low table, tea tray and cushions.
	var tatami := Rect2(235, 300, 300, 245)
	draw_rect(tatami, Color("c8c78b"))
	draw_rect(tatami, Color("647f55"), false, 8)
	for y in range(310, 540, 6): draw_line(Vector2(243, y), Vector2(527, y), Color(0.34, 0.38, 0.24, 0.18), 1)
	draw_rect(TABLE, Color("593c2c"))
	draw_rect(TABLE.grow(-8), Color("9d7049"))
	draw_circle(Vector2(390, 390), 27, Color("624e38"))
	draw_circle(Vector2(382, 385), 13, Color("ded4ae"))
	draw_circle(Vector2(412, 403), 7, Color("ded4ae"))
	for point in [Vector2(320, 510), Vector2(470, 510)]:
		draw_style_box(panel(Color("749081")), Rect2(point - Vector2(25, 20), Vector2(50, 40)))
	# Bed remains a separate, solid prop with an accessible bedside.
	draw_rect(BED.grow(6), Color("634632"))
	draw_rect(BED, Color("e7d9b5"))
	draw_style_box(panel(Color("fff0cb")), Rect2(747, 243, 116, 45))
	draw_style_box(panel(Color("7d9b83")), Rect2(736, 305, 138, 145))
	draw_line(Vector2(744, 327), Vector2(866, 327), Color("d8d5ad"), 6)
	for rect in [Rect2(110, 200, 140, 85), Rect2(500, 200, 140, 65)]:
		draw_rect(rect, Color("78563b"))
		draw_rect(rect.grow(-8), Color("a58054"))
		draw_line(Vector2(rect.get_center().x, rect.position.y + 10), Vector2(rect.get_center().x, rect.end.y - 10), Color("78563b"), 3)
	draw_rect(CHEST, Color("78563b"))
	draw_rect(Rect2(CHEST.position, Vector2(CHEST.size.x, 25)), Color("a58054"))
	draw_rect(Rect2(CHEST.get_center() - Vector2(6, 10), Vector2(12, 22)), Color("d2b880"))
	draw_string(ThemeDB.fallback_font, Vector2(125, 640), "Storage", HORIZONTAL_ALIGNMENT_CENTER, 125, 22, Color("493b2d"))
	draw_rect(Rect2(525, 215, 90, 40), Color("e7d9b5"))
	draw_rect(Rect2(525, 215, 90, 10), Color("a66b52"))
	for x in [540, 560, 580, 600]: draw_line(Vector2(x, 230), Vector2(x, 250), Color("78563b"), 1)
	draw_string(ThemeDB.fallback_font, Vector2(505, 295), "Calendar", HORIZONTAL_ALIGNMENT_CENTER, 130, 20, Color("493b2d"))
	var pot := Vector2(860, 155)
	draw_rect(Rect2(pot - Vector2(15, 0), Vector2(30, 25)), Color("b77953"))
	for offset in [Vector2(-15, -12), Vector2(8, -20), Vector2(20, -5)]:
		draw_line(pot, pot + offset, Color("486941"), 3)
		draw_circle(pot + offset, 12, Color("6f9151"))
	# Front entry threshold and doormat.
	draw_rect(Rect2(435, 680, 130, 40), Color("70523a"))
	draw_rect(Rect2(449, 691, 102, 21), Color("d2b880"))

func panel(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(6)
	return style
