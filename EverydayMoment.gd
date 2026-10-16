extends Control
var species:=""
var elapsed:=0.0
var cooking:=false
func setup(animal:String=""):
 species=animal;cooking=animal.is_empty();custom_minimum_size=Vector2(300,130);mouse_filter=Control.MOUSE_FILTER_IGNORE
 if not cooking: preload("res://BarnLife.gd").prepare_art()
func _process(delta:float):
 elapsed=minf(3.0,elapsed+delta);queue_redraw()
 if elapsed>=3.0: set_process(false)
func _draw():
 var middle:=Vector2(size.x*.5,100)
 if cooking:
  draw_rect(Rect2(middle-Vector2(72,15),Vector2(144,25)),Color("826347"))
  draw_style_box(box(Color("637c82")),Rect2(middle-Vector2(48,60),Vector2(96,55)))
  draw_line(middle+Vector2(-60,-52),middle+Vector2(60,-52),Color("475e64"),7)
  for i in range(3):
   var p:=middle+Vector2(-25+i*25,-70-fmod(elapsed*25+i*9,36))
   draw_circle(p,6,Color(.95,.93,.85,.5))
  draw_line(middle+Vector2(17,-45),middle+Vector2(27+sin(elapsed*5)*15,-92),Color("bd9b64"),6)
 else:
  draw_rect(Rect2(middle+Vector2(-100,-90),Vector2(200,100)),Color("98794c"))
  draw_rect(Rect2(middle+Vector2(-60,-70),Vector2(120,80)),Color("594c38"))
  draw_line(middle+Vector2(-120,18),middle+Vector2(120,18),Color("c1a16e"),10)
  var art=preload("res://BarnLife.gd")
  var region:Rect2=art.art_regions[art.SPECIES.keys().find(species)]
  var dimensions:Vector2=region.size*(90.0/region.size.y)
  var p:=middle+Vector2(lerpf(-180,0,minf(1,elapsed/2.0)),0)
  if elapsed<2: p.y-=absf(sin(elapsed*9))*4
  draw_texture_rect_region(art.art,Rect2(p-Vector2(dimensions.x/2,dimensions.y),dimensions),region)
func box(color:Color) -> StyleBoxFlat:
 var s:=StyleBoxFlat.new();s.bg_color=color;s.set_corner_radius_all(12);return s
