extends Node2D

const DOOR_POSITION := Vector2(775, 550)
const OUTLINE := [Vector2(215,107),Vector2(495,107),Vector2(495,266),Vector2(215,266)]

func _ready() -> void:
	var body := StaticBody2D.new()
	var collision := CollisionPolygon2D.new()
	var points := PackedVector2Array()
	for point in OUTLINE: points.append(point * 1.953125)
	collision.polygon = points
	body.add_child(collision)
	add_child(body)
	var sprite := $Artwork as Sprite2D
	var image := sprite.texture.get_image()
	var bounds := image.get_used_rect()
	sprite.region_enabled = true
	sprite.region_rect = bounds
	sprite.centered = false
	sprite.position = Vector2(215, 107) * 1.953125
	sprite.scale = Vector2(280, 159) * 1.953125 / Vector2(bounds.size)

func _draw() -> void:
	if get_parent().get_parent().interior_progress.get("second_story",false):
		draw_rect(Rect2(700,505,80,24),Color("e5d6ae"))
		draw_string(ThemeDB.fallback_font,Vector2(711,524),"2F",HORIZONTAL_ALIGNMENT_LEFT,-1,19,Color("604a34"))
	# A small doormat marks the reachable entrance outside the solid facade.
	draw_style_box(doormat(), Rect2(DOOR_POSITION - Vector2(35, 15), Vector2(70, 30)))

func doormat() -> StyleBoxFlat:
	var mat := StyleBoxFlat.new()
	mat.bg_color = Color("9a754c")
	mat.border_color = Color("62452e")
	mat.set_border_width_all(2)
	mat.set_corner_radius_all(4)
	return mat
