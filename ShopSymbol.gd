extends Control
var shop:=""
func _draw() -> void:
 var p:=size/2;var ink:=Color("5d513b")
 match shop:
  "Clinic":
   draw_rect(Rect2(p-Vector2(3,11),Vector2(6,22)),Color("a56254"));draw_rect(Rect2(p-Vector2(11,3),Vector2(22,6)),Color("a56254"))
  "Veterinarian":
   draw_circle(p+Vector2(0,5),6,ink)
   for q in [Vector2(-8,-3),Vector2(-3,-9),Vector2(4,-9),Vector2(9,-2)]: draw_circle(p+q,3,ink)
  "Town Hall":
   draw_circle(p,11,ink);draw_circle(p,8,Color("f5e7c3"));draw_line(p,p+Vector2(0,-6),ink,2);draw_line(p,p+Vector2(5,2),ink,2)
  "General Store":
   draw_rect(Rect2(p-Vector2(10,3),Vector2(20,13)),ink,false,2)
   draw_line(p+Vector2(-7,-3),p+Vector2(-3,-10),ink,2);draw_line(p+Vector2(7,-3),p+Vector2(3,-10),ink,2)
  "Café":
   draw_rect(Rect2(p-Vector2(9,7),Vector2(16,16)),ink,false,3);draw_arc(p+Vector2(8,0),5,-PI/2,PI/2,10,ink,2)
   draw_line(p+Vector2(-12,12),p+Vector2(12,12),ink,2)
  "Archive":
   draw_rect(Rect2(p-Vector2(12,10),Vector2(24,20)),ink,false,2);draw_line(p-Vector2(0,10),p+Vector2(0,10),ink,2)
   for y in [-5,0,5]: draw_line(p+Vector2(4,y),p+Vector2(9,y),ink,1)
  "Inn":
   draw_rect(Rect2(p-Vector2(11,2),Vector2(23,10)),ink);draw_circle(p+Vector2(-6,-5),4,ink)
   for x in [-12,12]: draw_line(p+Vector2(x,-8),p+Vector2(x,13),ink,2)
  "Police Box":
   draw_colored_polygon(PackedVector2Array([p+Vector2(-10,-10),p+Vector2(10,-10),p+Vector2(9,4),p+Vector2(0,13),p+Vector2(-9,4)]),ink)
   draw_circle(p-Vector2(0,2),4,Color("e9ce83"))
  "Fire Station":
   draw_colored_polygon(PackedVector2Array([p+Vector2(0,-14),p+Vector2(4,-3),p+Vector2(9,-7),p+Vector2(11,5),p+Vector2(5,12),p+Vector2(-5,12),p+Vector2(-11,5),p+Vector2(-7,-6),p+Vector2(-3,0)]),Color("b56d48"))
  "Carpentry":
   draw_line(p+Vector2(-9,11),p+Vector2(6,-6),ink,5);draw_line(p+Vector2(-1,-11),p+Vector2(12,0),ink,7)
  "Blacksmith":
   draw_colored_polygon(PackedVector2Array([p+Vector2(-13,-7),p+Vector2(13,-7),p+Vector2(8,-1),p+Vector2(3,0),p+Vector2(3,7),p+Vector2(10,9),p+Vector2(10,12),p+Vector2(-10,12),p+Vector2(-10,9),p+Vector2(-3,7),p+Vector2(-3,-1),p+Vector2(-9,-1)]),ink)
  "Ranch":
   draw_circle(p,9,ink);draw_circle(p+Vector2(-11,-6),4,ink);draw_circle(p+Vector2(11,-6),4,ink)
   draw_rect(Rect2(p+Vector2(-6,3),Vector2(12,7)),Color("d5b28c"))
   for x in [-4,4]: draw_circle(p+Vector2(x,-2),2,Color("f5e7c3"))
