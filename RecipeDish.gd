extends Control
var dish:="supper"
func _draw() -> void:
 var p:=Vector2(size.x/2,size.y/2)
 paint_oval(p+Vector2(0,23),Vector2(40,7),Color("cbbd91"))
 if dish=="tea":
  draw_arc(p+Vector2(28,-2),13,-1.6,1.6,18,Color("607b67"),7)
  draw_style_box(box(Color("8ca382")),Rect2(p-Vector2(29,25),Vector2(58,48)))
  paint_oval(p+Vector2(0,-22),Vector2(27,9),Color("98784b"))
  for x in [-10,8]: draw_line(p+Vector2(x,-36),p+Vector2(x+4,-46),Color("f2e9d1"),3)
 elif dish=="omelet":
  paint_oval(p,Vector2(43,28),Color("f5eacb"))
  paint_oval(p,Vector2(32,19),Color("edc35d"))
  for x in [-15,0,15]: draw_line(p+Vector2(x-5,-5),p+Vector2(x+5,8),Color("c87948"),3)
  for q in [Vector2(-24,-12),Vector2(22,12),Vector2(8,-14)]: draw_circle(p+q,4,Color("698557"))
 else:
  draw_style_box(box(Color("728b91")),Rect2(p-Vector2(39,8),Vector2(78,35)))
  paint_oval(p-Vector2(0,6),Vector2(39,15),Color("d1a963"))
  for q in [Vector2(-19,-9),Vector2(1,-2),Vector2(18,-10)]:
   draw_circle(p+q,7,Color("efdbb2"));draw_line(p+q,p+q+Vector2(2,-8),Color("719057"),4)
func paint_oval(p:Vector2,r:Vector2,color:Color) -> void:
 var points:=PackedVector2Array()
 for i in range(32): points.append(p+Vector2(cos(i*TAU/32),sin(i*TAU/32))*r)
 draw_colored_polygon(points,color)
func box(color:Color) -> StyleBoxFlat:
 var s:=StyleBoxFlat.new();s.bg_color=color;s.set_corner_radius_all(12);return s
