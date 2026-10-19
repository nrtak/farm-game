extends Node2D
# Perspective is painted into the artwork; keep the sprite upright in screen space.
var art:Texture2D=load("res://world/angled/town-sign-painted-v1.png")
func _draw():
 if art==null:return
 var height=210.0*art.get_height()/art.get_width()
 draw_texture_rect(art,Rect2(-105,-height+18,210,height),false)
