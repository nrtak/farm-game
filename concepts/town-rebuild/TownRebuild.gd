extends "res://concepts/angled-street-v1/MarketWalk.gd"
const G=preload("res://concepts/town-rebuild/TownGeometry.gd")
# Atlas regions and entrance anchors are in source pixels, never inferred from painted colors.
const ART={
 "Town Hall":["civic",Rect2(0,0,632,662),Vector2(435,598),false],
 "Library":["civic",Rect2(640,0,614,675),Vector2(342,620),false],
 "Police":["civic",Rect2(0,690,630,564),Vector2(430,470),false],
 "Fire":["civic",Rect2(640,640,614,614),Vector2(163,510),false],
 "Hospital":["market",Rect2(0,0,627,625),Vector2(448,560),false],
 "Store":["market",Rect2(627,0,627,625),Vector2(430,530),false],
 "Cafe":["cafe",Rect2(0,0,1254,1254),Vector2(445,1050),false],
 "Inn":["market",Rect2(627,635,627,619),Vector2(396,544),false],
 "Restaurant":["trades",Rect2(0,0,627,625),Vector2(400,582),false],
 "Carpenter":["trades",Rect2(627,0,627,625),Vector2(370,562),false],
 "Blacksmith":["trades",Rect2(0,635,627,619),Vector2(213,515),false],
 "Ranch":["trades",Rect2(627,635,627,619),Vector2(215,520),false],
 "Vet":["garden",Rect2(0,0,682,666),Vector2(475,607),false]}
var town_data:Dictionary={}
var town_layer:Node2D
var art_cache={}
var trunks:Array[Vector2]=[]
var overview=false
var destination=""
var building_sprites:Array[Sprite2D]=[]
var map_button:Button

func _ready():
 town_data=G.layout()
 super._ready()
 background=null
 town_layer=Node2D.new();add_child(town_layer)
 var ground=preload("res://concepts/town-rebuild/TownGround.gd").new();town_layer.add_child(ground)
 for b in town_data.buildings:place_building(b)
 place_decoration("garden",Rect2(690,0,564,625),Vector2(282,578),Vector2(680,650),90)
 place_decoration("garden",Rect2(610,640,644,614),Vector2(322,550),Vector2(360,395),140)
 # Trees are planted in verges, never in a road or a doorway approach.
 for p in [Vector2(460,510),Vector2(460,690),Vector2(510,1040),Vector2(550,1280),Vector2(880,1120),Vector2(870,1390),Vector2(1480,780),Vector2(1480,1040),Vector2(1480,1320),Vector2(2100,1380),Vector2(2050,280),Vector2(1780,280),Vector2(1510,280)]:
  trunks.append(p);place_decoration("garden",Rect2(0,670,605,584),Vector2(300,565),p,105)
 for e in G.EXITS:place_sign(e[0],e[1]+Vector2(38,0))
 place_sign("Festival Square",Vector2(850,625))
 position_on_map=Vector2(1300,910);camera.zoom=Vector2.ONE*1.45;avatar.scale=Vector2.ONE*.35
 var bar=title.get_parent()
 for b in bar.get_children():
  if b is Button and b.text in ["Reset","Zoom"]:
   for c in b.pressed.get_connections():b.pressed.disconnect(c.callable)
   if b.text=="Reset":b.pressed.connect(func():back_to_town(Vector2(1300,910)))
   else:b.pressed.connect(func():overview=not overview;refresh())
 title.add_theme_font_size_override("font_size",17)
 hint.hide()
 for ui in title.get_parent().get_parent().get_children():
  if ui is ColorRect:ui.size.y=62
 rebuild_routes();refresh()

func atlas(name:String,region:Rect2)->Texture2D:
 if not art_cache.has(name):art_cache[name]=load("res://concepts/town-rebuild/"+name+"-atlas.png")
 var a=AtlasTexture.new();a.atlas=art_cache[name];a.region=region;return a
func place_building(b:Array):
 var a=ART[b[0]];var sprite=Sprite2D.new();sprite.texture=atlas(a[0],a[1]);sprite.centered=false
 if b[0] in ["Library","Vet","Fire"]:
  var material=ShaderMaterial.new();material.shader=preload("res://concepts/town-rebuild/AtlasBounds.gdshader")
  material.set_shader_parameter("clipping_shape",{"Library":1,"Vet":2,"Fire":3}[b[0]]);sprite.material=material
 var scale_factor=225.0/a[1].size.x
 var anchor:Vector2=a[2]
 if a[3]:sprite.flip_h=true;anchor.x=a[1].size.x-anchor.x
 sprite.scale=Vector2.ONE*scale_factor;sprite.position=G.project(G.door(b))-anchor*scale_factor
 sprite.z_index=roundi(G.project(G.door(b)).y)-2
 town_layer.add_child(sprite);building_sprites.append(sprite)
func place_decoration(sheet:String,region:Rect2,anchor:Vector2,point:Vector2,width:float):
 var sprite=Sprite2D.new();sprite.texture=atlas(sheet,region);sprite.centered=false;sprite.scale=Vector2.ONE*(width/region.size.x)
 sprite.position=G.project(point)-anchor*sprite.scale;sprite.z_index=roundi(G.project(point).y);town_layer.add_child(sprite)
func place_sign(text:String,point:Vector2):
 var sign=Label.new();sign.text=text;sign.position=G.project(point)-Vector2(45,35);sign.z_index=roundi(G.project(point).y)
 sign.add_theme_font_size_override("font_size",14);sign.add_theme_color_override("font_color",Color("473827"))
 var style=StyleBoxFlat.new();style.bg_color=Color("f1dfb3");style.border_color=Color("8a6846");style.set_border_width_all(2);style.content_margin_left=7;style.content_margin_right=7;style.content_margin_top=4;style.content_margin_bottom=4
 sign.add_theme_stylebox_override("normal",style);town_layer.add_child(sign)

func walkable(p:Vector2)->bool:
 if room!="":return super.walkable(p)
 if town_data.is_empty():return false
 if not G.WORLD.grow(-10).has_point(p):return false
 if G.river_distance(p,town_data)<43:return false
 for b in town_data.buildings:
  if Rect2(b[1],b[2],b[3],b[4]).grow(10).has_point(p):return false
 if G.rect(town_data.fountain).grow(10).has_point(p):return false
 for t in trunks:
  if p.distance_to(t)<18:return false
 return true
func rebuild_routes():
 var dims=Vector2i(300,200) if room=="" else Vector2i(138,107)
 graph.region=Rect2i(Vector2i.ZERO,dims);graph.cell_size=Vector2(8,8);graph.offset=Vector2(4,4)
 graph.diagonal_mode=AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES;graph.update()
 for y in range(dims.y):
  for x in range(dims.x):graph.set_point_solid(Vector2i(x,y),not walkable(Vector2(x*8+4,y*8+4)))
func _unhandled_input(event):
 var point=Vector2.ZERO;var tapped=false
 if event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_LEFT:point=get_global_mouse_position();tapped=true
 elif event is InputEventScreenTouch and event.pressed:point=get_canvas_transform().affine_inverse()*event.position;tapped=true
 if tapped:route=path_to(G.unproject(point) if room=="" else point)
func _physics_process(delta):
 lock_time=maxf(0,lock_time-delta)
 var screen_direction=Input.get_vector("ui_left","ui_right","ui_up","ui_down")+joystick.direction
 var direction=screen_direction
 if screen_direction.length()>.1:
  route.clear()
  if room=="":direction=G.unproject(G.ORIGIN+screen_direction)
 elif route.size()>0:
  if position_on_map.distance_to(route[0])<3:route.remove_at(0)
  direction=position_on_map.direction_to(route[0]) if route.size()>0 else Vector2.ZERO
 var old=position_on_map
 if direction.length()>.1:
  var step=direction.normalized()*175*delta
  if route.size()>0:step=step.limit_length(position_on_map.distance_to(route[0]))
  var count=maxi(1,ceili(step.length()/3))
  for i in range(count):
   var move=step/count
   if walkable(position_on_map+Vector2(move.x,0)):position_on_map.x+=move.x
   if walkable(position_on_map+Vector2(0,move.y)):position_on_map.y+=move.y
 var movement=position_on_map-old;var travelled=movement.length()
 walk_distance=walk_distance+travelled if travelled>.01 else 0
 if travelled>.01:last_direction=(G.project(position_on_map)-G.project(old)).normalized() if room=="" else movement.normalized()
 var facing=0 if last_direction.y>.4 else (2 if last_direction.y<-.4 else (1 if last_direction.x<0 else 3))
 avatar.show_frame(facing,int(walk_distance/10)%4 if travelled>.01 else 1)
 if lock_time==0 and travelled>.01:check_transition()
 refresh()
func check_transition():
 if room!="":
  if Rect2(500,735,100,45).has_point(position_on_map):back_to_town(return_point)
  return
 for b in town_data.buildings:
  if route.size()>0 and route[-1].distance_to(G.door(b))>25:continue
  if position_on_map.distance_to(G.door(b))<18:enter(G.ALIASES.get(b[0],b[0]),G.back(b));return
 for e in G.EXITS:
  if position_on_map.distance_to(e[1])<22:enter(e[0]+" gateway",e[2]);return
func enter(kind:String,back:Vector2):
 super.enter(kind,back)
 if kind=="Restaurant":
  room_node=preload("res://concepts/town-rebuild/RestaurantRoom.gd").new();add_child(room_node);room_node.z_index=-1;rebuild_routes()
 if is_instance_valid(town_layer):town_layer.hide()
 avatar.scale=Vector2.ONE*.65;avatar.z_index=10;overview=false
 if is_instance_valid(room_node):
  for resident in room_node.residents:resident.scale=Vector2.ONE*.65
 refresh()
func back_to_town(point:Vector2):
 super.back_to_town(point)
 if is_instance_valid(town_layer):town_layer.show()
 avatar.scale=Vector2.ONE*.35;overview=false;refresh()
func refresh():
 if not is_instance_valid(camera):return
 if room=="":
  avatar.position=G.project(position_on_map);avatar.z_index=roundi(avatar.position.y)
  for sprite in building_sprites:
   var screen_rect=Rect2(sprite.position,sprite.texture.get_size()*sprite.scale)
   sprite.modulate.a=.3 if not overview and screen_rect.intersects(Rect2(avatar.position-Vector2(18,65),Vector2(36,65))) and sprite.z_index>avatar.z_index else 1.0
  camera.zoom=Vector2.ONE*(.43 if overview else 1.45)
  camera.position=G.project(Vector2(1180,900))-Vector2(0,160) if overview else avatar.position+Vector2(0,-80)
  title.text="Tea Blossom Hills · town rebuild"
  hint.text="Walk or tap · Enter any doorway · Zoom for town overview"
 else:
  avatar.position=position_on_map;camera.zoom=Vector2.ONE*.85;camera.position=Vector2(550,440)
  title.text=room;hint.text="Walk to the south doorway to return to town"
 queue_redraw()
func _draw():
 if room!="":super._draw();return
 if show_routes:
  for a in town_data.get("roads",[]):draw_colored_polygon(G.polygon(G.rect(a)),Color(0,.8,.6,.25))
  for b in town_data.get("buildings",[]):draw_circle(G.project(G.door(b)),10,Color("ffe49a"))
 if route.size()>0:draw_circle(G.project(route[-1]),8,Color("ffe2a0"))
