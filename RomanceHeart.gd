extends Node2D
var color:=Color("d55578")
func _draw() -> void:
 draw_circle(Vector2(-6,-4),8,color)
 draw_circle(Vector2(6,-4),8,color)
 draw_colored_polygon(PackedVector2Array([Vector2(-14,-2),Vector2(14,-2),Vector2(0,16)]),color)
