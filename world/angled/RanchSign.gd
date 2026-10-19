extends Node2D
# Large carved timber entrance sign, mounted above the open gateway.
func _draw():
 for x in [-70,70]:
  draw_rect(Rect2(x-8,-147,16,149),Color("60462d"))
  draw_rect(Rect2(x-5,-145,9,146),Color("a27847"))
  draw_line(Vector2(x-3,-140),Vector2(x-3,-3),Color("c09b65"),2,true)
  draw_rect(Rect2(x-10,-3,20,9),Color("8d8b70"))
  draw_rect(Rect2(x-11,-150,22,7),Color("c2a575"))
 draw_set_transform(Vector2(0,-45))
 var outline=PackedVector2Array([Vector2(-92,-94),Vector2(-65,-112),Vector2(65,-112),Vector2(92,-94),Vector2(92,-34),Vector2(82,-26),Vector2(-82,-26),Vector2(-92,-34)])
 draw_colored_polygon(outline,Color("6b482c"))
 var edge=outline.duplicate();edge.append(outline[0]);draw_polyline(edge,Color("442f22"),4,true)
 for y in [-93,-71,-49]:
  draw_line(Vector2(-86,y),Vector2(86,y),Color("a87944"),20,true)
  draw_line(Vector2(-85,y+10),Vector2(85,y+10),Color("5d402a"),2,true)
  for i in range(4):
   var x=-81+i*42
   draw_line(Vector2(x,y-5),Vector2(x+29,y-4),Color(.91,.72,.43,.28),1,true)
 for x in [-79,79]:
  for y in [-85,-39]:
   draw_circle(Vector2(x,y),3,Color("423d32"));draw_circle(Vector2(x-1,y-1),1,Color("d2c292"))
 var font=ThemeDB.fallback_font
 for entry in [["Town",-62,33]]:
  var text:String=entry[0];var size:int=entry[2];var w=font.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,size).x
  draw_string(font,Vector2(-w/2+1,entry[1]+2),text,HORIZONTAL_ALIGNMENT_LEFT,-1,size,Color("533822"))
  draw_string(font,Vector2(-w/2,entry[1]),text,HORIZONTAL_ALIGNMENT_LEFT,-1,size,Color("f4dfaa"))
