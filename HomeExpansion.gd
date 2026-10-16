extends RefCounted
# Furniture rectangles are shared by rendering and collision; the corridor stays clear.
const STORAGE=Rect2(940,245,145,80)
const LINEN=Rect2(940,665,145,40)
const PANTRY=Rect2(1160,245,145,80)
const STOVE=Rect2(1160,370,140,45)
static func solids(level:int) -> Array:
 var result:Array=[]
 if level>=1: result.append_array([STORAGE,LINEN])
 if level>=2: result.append_array([PANTRY,STOVE])
 return result
static func cabinet(r,rect:Rect2,color:Color) -> void:
 r.draw_style_box(r.panel(color.darkened(.25)),rect.grow(3))
 r.draw_style_box(r.panel(color),rect)
 r.draw_rect(Rect2(rect.position,Vector2(rect.size.x,12)),color.lightened(.2))
 for x in [rect.position.x+rect.size.x*.25,rect.position.x+rect.size.x*.75]:
  r.draw_rect(Rect2(x-22,rect.position.y+20,44,rect.size.y-29),color.darkened(.12),false,2)
  r.draw_circle(Vector2(x,rect.position.y+30),3,Color("dcc286"))
static func draw_rooms(r) -> void:
 var level:int=r.home_level
 for index in range(level):
  var x:int=910+index*220
  var kitchen:bool=index==1
  r.draw_rect(Rect2(x,110,220,120),Color("c5d3c4") if kitchen else Color("d6cbb5"))
  r.draw_rect(Rect2(x,230,220,490),Color("d8d7c2") if kitchen else Color("bd9a72"))
  if kitchen:
   for gx in range(x, x+220,44): r.draw_line(Vector2(gx,230),Vector2(gx,720),Color("bac4b6"),2)
   for y in range(230,720,44): r.draw_line(Vector2(x,y),Vector2(x+220,y),Color("bac4b6"),2)
  else:
   for y in range(230,720,32): r.draw_line(Vector2(x,y),Vector2(x+220,y),Color("a98761"),2)
  r.draw_rect(Rect2(x,110,220,10),Color("725c45"))
  r.draw_rect(Rect2(x,215,220,15),Color("816c50"))
  r.draw_rect(Rect2(x+65,138,94,63),Color("79998f"))
  r.draw_rect(Rect2(x+71,144,82,51),Color("c0d8cb"))
  r.draw_line(Vector2(x+112,144),Vector2(x+112,195),Color("f2e7cb"),5)
  r.draw_line(Vector2(x+71,170),Vector2(x+153,170),Color("f2e7cb"),5)
  for rect in [Rect2(x,190,10,340),Rect2(x,630,10,90)]: r.draw_rect(rect,Color("806447"))
  r.draw_rect(Rect2(x+10,530,15,100),Color("a08763"))
  r.draw_rect(Rect2(x,720,220,14),Color("745c42"))
 if level>=1:
  cabinet(r,STORAGE,Color("9e7652"));cabinet(r,LINEN,Color("8b7255"))
  for i in range(3):
   r.draw_style_box(r.panel(Color(["8ea39b","d0b993","9cabb5"][i])),Rect2(951+i*40,239-i*4,34,14))
  r.draw_style_box(r.panel(Color("889e9d")),Rect2(967,405,90,100))
  r.draw_rect(Rect2(975,413,74,84),Color("d9d2ad"),false,3)
  r.draw_string(ThemeDB.fallback_font,Vector2(961,358),"Storage",HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("594b38"))
  # Wall hooks and a hanging market basket add detail without obstructing walking.
  for x in [952,980,1008]: r.draw_circle(Vector2(x,193),3,Color("6c5842"))
  r.draw_rect(Rect2(945,196,19,20),Color("b28c55"))
 if level>=2:
  cabinet(r,PANTRY,Color("8aab9c"));cabinet(r,STOVE,Color("789185"))
  for x in [1177,1206,1235]:
   r.draw_style_box(r.panel(Color("c9ad7e")),Rect2(x,229,19,24))
   r.draw_rect(Rect2(x-1,226,21,5),Color("75583f"))
  r.draw_rect(Rect2(1257,250,36,45),Color("ccd9d1"))
  r.draw_rect(Rect2(1263,255,24,31),Color("95b4b1"))
  for x in [1185,1220]:
   r.draw_circle(Vector2(x,383),11,Color("465957"));r.draw_circle(Vector2(x,383),6,Color("74867a"))
  r.draw_circle(Vector2(1185,380),9,Color("9dada4"))
  r.draw_line(Vector2(1185,376),Vector2(1185,370),Color("475c58"),3)
  r.draw_rect(Rect2(1250,375,35,22),Color("b8ccc5"))
  r.draw_string(ThemeDB.fallback_font,Vector2(1183,348),"Kitchen",HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("4d6255"))
  r.draw_style_box(r.panel(Color("b8c7a6")),Rect2(1183,480,95,35))
 if level>0: r.draw_rect(Rect2(910+level*220,110,15,625),Color("725b43"))
