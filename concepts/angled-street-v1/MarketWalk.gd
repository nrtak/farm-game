extends "res://concepts/town-playable/TownWalk.gd"
# Screen-space ground polygons match the approved diagonal artwork.
# Streets are straight in the scene; navigation never derives collision from painted colors.
const STREET=[Vector2(20,480),Vector2(320,520),Vector2(620,525),Vector2(860,575),Vector2(1060,630),Vector2(1640,795),Vector2(1640,925),Vector2(1140,925),Vector2(700,855),Vector2(400,755),Vector2(150,645),Vector2(20,590)]
const NORTH=[Vector2(620,540),Vector2(730,405),Vector2(805,300),Vector2(920,160),Vector2(1055,20),Vector2(1130,20),Vector2(1080,150),Vector2(1020,275),Vector2(950,420),Vector2(875,580)]
const STORE_APRON=[Vector2(330,530),Vector2(470,530),Vector2(470,470),Vector2(425,445),Vector2(365,445)]
const CAFE_APRON=[Vector2(1130,655),Vector2(1320,710),Vector2(1335,610),Vector2(1270,565),Vector2(1210,565)]
const MARKET_DOORS=[["General Store",Vector2(400,464),Vector2(0,50)],["Café",Vector2(1250,590),Vector2(0,50)]]
const MARKET_EXITS=[["Town square",Vector2(45,550),Vector2(95,555)],["Civic street",Vector2(1080,55),Vector2(1065,110)]]

var district="market"
const CIVIC_STREET=[Vector2(20,485),Vector2(320,530),Vector2(620,520),Vector2(860,570),Vector2(1060,620),Vector2(1650,770),Vector2(1650,925),Vector2(1140,925),Vector2(700,850),Vector2(400,740),Vector2(150,640),Vector2(20,570)]
const CIVIC_NORTH=[Vector2(620,540),Vector2(740,375),Vector2(850,240),Vector2(970,100),Vector2(1090,15),Vector2(1170,15),Vector2(1090,150),Vector2(1010,290),Vector2(940,430),Vector2(870,580)]
const POLICE_APRON=[Vector2(440,540),Vector2(590,540),Vector2(590,465),Vector2(555,435),Vector2(465,435)]
const FIRE_APRON=[Vector2(1320,710),Vector2(1460,730),Vector2(1460,600),Vector2(1430,570),Vector2(1360,570)]
const CIVIC_DOORS=[["Police Box",Vector2(510,456),Vector2(0,60)],["Fire Station",Vector2(1400,590),Vector2(0,70)]]
func ground_polygons():
 return [CIVIC_STREET,CIVIC_NORTH,POLICE_APRON,FIRE_APRON] if district=="civic" else [STREET,NORTH,STORE_APRON,CAFE_APRON]
func doors():return CIVIC_DOORS if district=="civic" else MARKET_DOORS
func change_district(next:String,point:Vector2):
 district=next
 background=load("res://concepts/angled-street-v1/"+("civic-background.png" if district=="civic" else "market-background.png"))
 back_to_town(point)

func _ready():
 super._ready()
 background=load("res://concepts/angled-street-v1/market-background.png")
 avatar.scale=Vector2.ONE*.65;camera.zoom=Vector2.ONE*.68;position_on_map=Vector2(780,620)
 # Replace inherited zoom/reset actions with scale-appropriate actions for this street.
 var bar=title.get_parent()
 for b in bar.get_children():
  if b is Button and b.text in ["Zoom","Reset"]:
   for connection in b.pressed.get_connections():b.pressed.disconnect(connection.callable)
   if b.text=="Zoom":b.pressed.connect(func():camera.zoom=Vector2.ONE*(.95 if camera.zoom.x<.8 else .68))
   else:b.pressed.connect(func():back_to_town(Vector2(780,620)))
 rebuild_routes();refresh()

func on_ground(p:Vector2)->bool:
 for polygon in ground_polygons():
  if Geometry2D.is_point_in_polygon(p,PackedVector2Array(polygon)):return true
 return false

func walkable(p:Vector2)->bool:
 if room!="":return super.walkable(p)
 for offset in [Vector2.ZERO,Vector2(10,0),Vector2(-10,0),Vector2(0,10),Vector2(0,-10),Vector2(7,7),Vector2(-7,7),Vector2(7,-7),Vector2(-7,-7)]:
  if not on_ground(p+offset):return false
 # The foreground lamp remains solid even though it stands inside paving.
 if district=="market" and p.distance_to(Vector2(1190,850))<40:return false
 return true

func rebuild_routes():
 graph.region=Rect2i(0,0,210,118);graph.cell_size=Vector2(8,8);graph.offset=Vector2(4,4)
 graph.diagonal_mode=AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES;graph.update()
 for y in range(118):
  for x in range(210):graph.set_point_solid(Vector2i(x,y),not walkable(Vector2(x*8+4,y*8+4)))

func segment_clear(a:Vector2,b:Vector2)->bool:
 var steps=maxi(1,ceili(a.distance_to(b)/3))
 for i in range(steps+1):
  if not walkable(a.lerp(b,float(i)/steps)):return false
 return true

func path_to(p:Vector2)->PackedVector2Array:
 var raw=super.path_to(p)
 if raw.is_empty():return raw
 # Collapse the grid staircase into straight lines, but never cut a blocked corner.
 var clean=PackedVector2Array();var start=position_on_map;var index=0
 while index<raw.size():
  var furthest=index
  while furthest+1<raw.size() and segment_clear(start,raw[furthest+1]):furthest+=1
  if not segment_clear(start,raw[furthest]):return PackedVector2Array()
  clean.append(raw[furthest]);start=raw[furthest];index=furthest+1
 return clean

func check_transition():
 if room!="":
  if Rect2(500,735,100,45).has_point(position_on_map):back_to_town(return_point)
  return
 for d in doors():
  if position_on_map.distance_to(d[1])<18:enter(d[0],d[1]+d[2]);return
 if district=="civic":
  if position_on_map.distance_to(Vector2(780,825))<24:change_district("market",Vector2(1065,110))
  return
 if position_on_map.distance_to(Vector2(1080,55))<18:
  change_district("civic",Vector2(780,755));return
 for e in MARKET_EXITS:
  if position_on_map.distance_to(e[1])<18:enter(e[0]+" gateway",e[2]);return

func enter(kind:String,back:Vector2):
 super.enter(kind,back)
 avatar.scale=Vector2.ONE*.5;camera.zoom=Vector2.ONE*.85

func back_to_town(point:Vector2):
 super.back_to_town(point)
 avatar.scale=Vector2.ONE*.65;camera.zoom=Vector2.ONE*.68

func refresh():
 if not is_instance_valid(camera):return
 avatar.position=position_on_map
 var bounds=Vector2(1672,941) if room=="" else Vector2(1100,850)
 var half=get_viewport_rect().size/camera.zoom/2
 camera.position=Vector2(clampf(position_on_map.x,minf(half.x,bounds.x/2),maxf(bounds.x-half.x,bounds.x/2)),clampf(position_on_map.y,minf(half.y,bounds.y/2),maxf(bounds.y-half.y,bounds.y/2)))
 title.text=("Civic street" if district=="civic" else "Market street")+" · angled preview" if room=="" else room+" · preview"
 hint.text="Walk into Store / Café. Follow the street north to Police and Fire." if room=="" else "Walk south to return. This preview does not change your save."
 if room=="" and district=="civic":hint.text="Walk into Police / Fire. Follow the Market sign south to return."
 queue_redraw()

func _draw():
 if room!="":super._draw();return
 if background==null:return
 draw_texture(background,Vector2.ZERO)
 if district=="civic":
  draw_circle(Vector2(780,825),23,Color(.98,.86,.57,.5))
  draw_string(ThemeDB.fallback_font,Vector2(710,875),"Market ↓",HORIZONTAL_ALIGNMENT_LEFT,-1,24,Color("293e35"))
 if show_routes:
  for polygon in ground_polygons():draw_colored_polygon(PackedVector2Array(polygon),Color(0,.8,.6,.22))
  for d in doors():draw_circle(d[1],18,Color(1,.6,0,.6))
 if route.size()>0:draw_circle(route[-1],9,Color("ffe2a0"))


