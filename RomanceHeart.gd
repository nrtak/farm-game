extends Node2D
func _draw() -> void:
 var color:=Color("d55578")
 draw_circle(Vector2(-6,-4),8,color)
 draw_circle(Vector2(6,-4),8,color)
 draw_colored_polygon(PackedVector2Array([Vector2(-14,-2),Vector2(14,-2),Vector2(0,16)]),color)
