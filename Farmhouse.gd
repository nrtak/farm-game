extends Node2D

const DOOR_POSITION := Vector2(400, 1005)
const OUTLINE := [Vector2(5, 550), Vector2(50, 475), Vector2(130, 390), Vector2(325, 390), Vector2(415, 485), Vector2(380, 600), Vector2(120, 630), Vector2(5, 615)]

func _ready() -> void:
	var body := StaticBody2D.new()
	var collision := CollisionPolygon2D.new()
	var points := PackedVector2Array()
	for point in OUTLINE: points.append(point * 1.5625)
	collision.polygon = points
	body.add_child(collision)
	add_child(body)
	var sprite := $Artwork as Sprite2D
	var image := sprite.texture.get_image()
	var bounds := image.get_used_rect()
	sprite.region_enabled = true
	sprite.region_rect = bounds
	sprite.centered = false
	sprite.position = Vector2(5, 390) * 1.5625
	sprite.scale = Vector2(410, 240) * 1.5625 / Vector2(bounds.size)

func _draw() -> void:
	# A small doormat marks the reachable entrance outside the solid facade.
	draw_style_box(doormat(), Rect2(DOOR_POSITION - Vector2(35, 15), Vector2(70, 30)))

func doormat() -> StyleBoxFlat:
	var mat := StyleBoxFlat.new()
	mat.bg_color = Color("9a754c")
	mat.border_color = Color("62452e")
	mat.set_border_width_all(2)
	mat.set_corner_radius_all(4)
	return mat
