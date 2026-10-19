extends Node2D
# Original painted tackle display fitted to the existing solid footprint.
var art:Texture2D=load("res://world/angled/fishing-display-v1.png")
func _draw():
 if art==null:return
 var height=100.0*art.get_height()/art.get_width()
 draw_texture_rect(art,Rect2(-50,-height,100,height),false)
