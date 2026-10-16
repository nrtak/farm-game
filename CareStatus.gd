extends Control
var fed:=false
var petted:=false
var product_count:=0
func _draw() -> void:
 for i in range(3):
  var p:=Vector2(size.x*(i+.5)/3,18)
  var done:bool=[fed,petted,product_count>0][i]
  draw_circle(p,16,Color("a4bd87") if done else Color("d5c5a1"))
  var ink:=Color("43573d") if done else Color("786b54")
  if i==0:
   draw_line(p+Vector2(-10,-3),p+Vector2(10,-3),ink,3)
   draw_polyline(PackedVector2Array([p+Vector2(-9,-3),p+Vector2(-6,7),p+Vector2(6,7),p+Vector2(9,-3)]),ink,2)
  elif i==1:
   draw_circle(p+Vector2(-4,-3),5,ink);draw_circle(p+Vector2(4,-3),5,ink)
   draw_colored_polygon(PackedVector2Array([p+Vector2(-9,-1),p+Vector2(9,-1),p+Vector2(0,10)]),ink)
  else:
   draw_rect(Rect2(p-Vector2(9,2),Vector2(18,12)),ink,false,2)
   draw_arc(p+Vector2(0,-2),7,PI,TAU,12,ink,2)
  if done:
   draw_polyline(PackedVector2Array([p+Vector2(7,-13),p+Vector2(10,-10),p+Vector2(16,-17)]),Color("365b35"),2)
  draw_string(ThemeDB.fallback_font,p+Vector2(-12,34),["Fed" if fed else "Feed","Pet",str(product_count)][i],HORIZONTAL_ALIGNMENT_LEFT,-1,13,ink)
