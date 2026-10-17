extends Node2D
var residents:Array=[]
# Footprints follow the furnished artwork at its 1100 x 850 game size.
const SOLIDS=[Rect2(125,185,110,320),Rect2(850,185,125,320),Rect2(340,185,420,150),Rect2(310,350,180,110),Rect2(620,350,190,110),Rect2(310,505,180,115),Rect2(620,505,190,115)]
var artwork:Texture2D
func _ready():artwork=load("res://concepts/town-rebuild/restaurant.png");queue_redraw()
func is_walkable(p:Vector2)->bool:
 if not Rect2(125,185,850,585).has_point(p):return false
 if p.y>695 and (p.x<485 or p.x>615):return false
 for r in SOLIDS:
  if r.grow(14).has_point(p):return false
 return true
func _draw():
 if artwork!=null:draw_texture_rect(artwork,Rect2(0,0,1100,850),false)
