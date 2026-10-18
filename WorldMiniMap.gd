extends Control
var farm
var expanded=false
const COLORS={"farm":"b3bd75","town":"d6c6a0","mountain":"8d9e81","tea":"78a975","historic":"97b399","harbor":"cbbf91"}
func _ready():
 mouse_filter=Control.MOUSE_FILTER_STOP
 tooltip_text="World map · your location"
func _gui_input(event):
 if not expanded and ((event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT and event.pressed) or (event is InputEventScreenTouch and event.pressed)):
  farm.open_map();accept_event()
func _process(_delta):queue_redraw()
func point(world:Vector2)->Vector2:
 return Vector2(10,10)+(world-Vector2(-2100,-3250))/Vector2(6200,5350)*(size-Vector2(20,20))
func _draw():
 if farm==null:return
 var style=StyleBoxFlat.new();style.bg_color=Color(.10,.20,.18,.65);style.border_color=Color(.88,.81,.61,.65);style.set_border_width_all(1);style.set_corner_radius_all(9)
 draw_style_box(style,Rect2(Vector2.ZERO,size))
 for area in COLORS:
  var origin=Vector2.ZERO if area=="farm" else farm.TOWN_ORIGIN if area=="town" else farm.REGION_ORIGINS[area]
  var polygon=PackedVector2Array()
  if area=="town":
   for corner in [Vector2(165,275),Vector2(1900,275),Vector2(1900,1585),Vector2(165,1585)]:polygon.append(point(origin+farm.town.G.project(corner)))
  else:
   var dimensions=Vector2(3000,2000) if area=="farm" else Vector2(1600,1200)
   for corner in [Vector2.ZERO,Vector2(dimensions.x,0),dimensions,Vector2(0,dimensions.y)]:polygon.append(point(origin+corner))
  draw_colored_polygon(polygon,Color(COLORS[area],.66))
  var center=Vector2.ZERO
  for p in polygon:center+=p
  center/=polygon.size()
  var title={"farm":"Farm","town":"Village","mountain":"Highlands","tea":"Tea Country","historic":"Shrine & Falls","harbor":"Harbor"}[area]
  if expanded:draw_string(ThemeDB.fallback_font,center+Vector2(-32,0),title,HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("fff2cd"))
  if area in farm.regions:
   for water in farm.regions[area].water_polygons:
    var outline=PackedVector2Array()
    for vertex in water:outline.append(point(origin+vertex))
    draw_colored_polygon(outline,Color("7abcca"))
  for route in preload("res://WideRoads.gd").ROUTES.get(area,[]):
   if area!="town":draw_line(point(origin+route[0]),point(origin+route[1]),Color(.95,.88,.65,.6),1 if not expanded else 2,true)
 var location=farm.player.position
 if farm.inside_house:location=Vector2(775,530)
 elif farm.location=="shop":
  location=farm.TOWN_ORIGIN+farm.town.G.project(Vector2(1200,900))
  if farm.REGIONAL_ROOMS.has(farm.shop_name):
   var room=farm.REGIONAL_ROOMS[farm.shop_name];location=farm.REGION_ORIGINS[room[0]]+room[1]
 var p=point(location)
 draw_circle(p,6 if expanded else 4,Color("fff6dc"));draw_circle(p,3 if expanded else 2,Color("c36548"))
 draw_string(ThemeDB.fallback_font,Vector2(7,16),"N ↑",HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color("fff2cd"))
