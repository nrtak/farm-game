extends Node2D
# Deliberately independent of Farm.gd: this preview never reads/writes player saves.
const MAP_SIZE=Vector2(1424,1105)
const RADIUS=6.0
const SPEED=130.0
const LANES=[Rect2(195,574,1005,36),Rect2(560,398,640,34),Rect2(560,398,40,558),Rect2(795,120,40,970),Rect2(965,408,40,548),Rect2(1165,250,35,550),Rect2(580,760,805,40),Rect2(580,930,425,26),Rect2(250,440,310,134),Rect2(400,365,150,80),Rect2(195,175,40,435),Rect2(195,550,365,60)]
const DOORS=[
 ["Town Hall",Vector2(704,394),Vector2.DOWN], ["Archive",Vector2(900,394),Vector2.DOWN],
 ["Police Box",Vector2(1075,394),Vector2.DOWN], ["Fire Station",Vector2(1245,340),Vector2.LEFT],
 ["Clinic",Vector2(690,568),Vector2.DOWN], ["General Store",Vector2(1080,568),Vector2.DOWN],
 ["Café",Vector2(1260,500),Vector2.LEFT], ["Inn",Vector2(700,752),Vector2.DOWN],
 ["Restaurant",Vector2(905,752),Vector2.DOWN], ["Carpentry",Vector2(1080,752),Vector2.DOWN],
 ["Blacksmith",Vector2(1245,680),Vector2.LEFT], ["Ranch",Vector2(700,927),Vector2.DOWN],
 ["Veterinarian",Vector2(905,927),Vector2.DOWN]]
const EXITS=[["Highlands",Vector2(815,145)],["Harbor",Vector2(205,590)],["Shrine",Vector2(215,195)],["Farm",Vector2(815,1050)]]
var position_on_map=Vector2(815,620)
var room=""
var return_point=Vector2.ZERO
var room_node:Node2D
var background:Texture2D
var avatar:Node2D
var camera:Camera2D
var title:Label
var hint:Label
var joystick:Control
var graph=AStarGrid2D.new()
var route=PackedVector2Array()
var walk_distance=0.0
var lock_time=0.0
var show_routes=false
var last_direction=Vector2.DOWN
var room_solids:Array=[]

func _ready():
 background=ImageTexture.create_from_image(Image.load_from_file("res://concepts/town-playable/town.png"))
 avatar=preload("res://Npc.gd").new();add_child(avatar)
 avatar.setup("boy",preload("res://CharacterArt.gd").walk("boy"));avatar.paused=true;avatar.label.hide();avatar.scale=Vector2.ONE*.28;avatar.set_physics_process(false)
 camera=Camera2D.new();camera.zoom=Vector2.ONE*1.7;add_child(camera);camera.make_current()
 var layer=CanvasLayer.new();add_child(layer)
 var backing=ColorRect.new();backing.color=Color(0.97,0.94,0.83,.94);backing.size=Vector2(1100,90);backing.mouse_filter=Control.MOUSE_FILTER_IGNORE;layer.add_child(backing)
 var bar=HBoxContainer.new();bar.position=Vector2(14,12);layer.add_child(bar)
 title=Label.new();title.add_theme_color_override("font_color",Color("243d35"));title.add_theme_font_size_override("font_size",20);bar.add_child(title)
 for text in ["Routes","Reset","Zoom"]:
  var button=Button.new();button.text=text;button.custom_minimum_size=Vector2(85,42);bar.add_child(button)
  button.pressed.connect(func():
   if text=="Routes": show_routes=not show_routes
   elif text=="Reset": back_to_town(Vector2(815,620))
   else: camera.zoom=Vector2.ONE*(1.0 if camera.zoom.x>1.2 else 1.7))
 hint=Label.new();hint.position=Vector2(16,60);hint.add_theme_color_override("font_color",Color("243d35"));layer.add_child(hint)
 joystick=preload("res://Joystick.gd").new();joystick.position=Vector2(24,380);joystick.size=Vector2(125,125);layer.add_child(joystick)
 get_viewport().size_changed.connect(layout_ui);layout_ui();rebuild_routes();refresh()

func layout_ui():
 if is_instance_valid(joystick):joystick.position.y=get_viewport_rect().size.y-150

func walkable(p:Vector2)->bool:
 if room!="":
  if room_node!=null:return room_node.is_walkable(p)
  if not Rect2(110,180,880,590).grow(-RADIUS).has_point(p):return false
  for r in room_solids:
   if r.grow(RADIUS).has_point(p):return false
  return true
 # Test the full foot circle against the union of roads, not each rectangle separately.
 for offset in [Vector2.ZERO,Vector2(RADIUS,0),Vector2(-RADIUS,0),Vector2(0,RADIUS),Vector2(0,-RADIUS)]:
  var inside=false
  for r in LANES:
   if r.has_point(p+offset):inside=true;break
  for door in DOORS:
   var d:Vector2=door[1];var approach:Vector2=Vector2(1180,d.y) if door[2]==Vector2.LEFT else d+door[2]*24
   if Rect2(d.min(approach)-Vector2(13,13),abs(approach-d)+Vector2(26,26)).has_point(p+offset):inside=true
  if not inside:return false
 return true

func rebuild_routes():
 graph.region=Rect2i(0,0,178,139);graph.cell_size=Vector2(8,8);graph.offset=Vector2(4,4)
 graph.diagonal_mode=AStarGrid2D.DIAGONAL_MODE_NEVER;graph.update()
 for y in range(139):
  for x in range(178):graph.set_point_solid(Vector2i(x,y),not walkable(Vector2(x*8+4,y*8+4)))

func nearby_cell(p:Vector2)->Vector2i:
 var best=Vector2i(-1,-1);var distance=40.0
 var cell=Vector2i(p/8)
 for y in range(cell.y-5,cell.y+6):
  for x in range(cell.x-5,cell.x+6):
   var candidate=Vector2i(x,y)
   if graph.is_in_boundsv(candidate) and not graph.is_point_solid(candidate):
    var d=p.distance_to(graph.get_point_position(candidate))
    if d<distance:distance=d;best=candidate
 return best

func path_to(p:Vector2)->PackedVector2Array:
 var start=nearby_cell(position_on_map);var end=nearby_cell(p)
 if start.x<0 or end.x<0:return PackedVector2Array()
 return graph.get_point_path(start,end)

func _unhandled_input(event):
 if event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_LEFT:
  route=path_to(get_global_mouse_position())
 if event is InputEventScreenTouch and event.pressed:
  route=path_to(get_canvas_transform().affine_inverse()*event.position)

func _physics_process(delta):
 lock_time=maxf(0,lock_time-delta)
 var direction=Input.get_vector("ui_left","ui_right","ui_up","ui_down")+joystick.direction
 if direction.length()>.1:route.clear()
 elif route.size()>0:
  if position_on_map.distance_to(route[0])<3:route.remove_at(0)
  if route.size()>0:direction=position_on_map.direction_to(route[0])
 var old=position_on_map
 if direction.length()>.1:
  var step=direction.normalized()*SPEED*delta
  if route.size()>0:step=step.limit_length(position_on_map.distance_to(route[0]))
  # Short substeps keep collision stable even after a slow frame.
  var count=maxi(1,ceili(step.length()/3))
  for i in range(count):
   var move=step/count
   if walkable(position_on_map+Vector2(move.x,0)):position_on_map.x+=move.x
   if walkable(position_on_map+Vector2(0,move.y)):position_on_map.y+=move.y
  last_direction=direction
 var travelled=old.distance_to(position_on_map);walk_distance=walk_distance+travelled if travelled>.01 else 0
 var facing=0 if last_direction.y>.4 else (2 if last_direction.y<-.4 else (1 if last_direction.x<0 else 3))
 avatar.show_frame(facing,int(walk_distance/8)%4 if travelled>.01 else 1)
 if lock_time==0 and travelled>.01:check_transition()
 refresh()

func refresh():
 avatar.position=position_on_map
 var bounds=MAP_SIZE if room=="" else Vector2(1100,850)
 var half=get_viewport_rect().size/camera.zoom/2
 camera.position=Vector2(clampf(position_on_map.x,minf(half.x,bounds.x/2),maxf(bounds.x-half.x,bounds.x/2)),clampf(position_on_map.y,minf(half.y,bounds.y/2),maxf(bounds.y-half.y,bounds.y/2)))
 title.text="New town · movement preview" if room=="" else room+" · preview"
 hint.text="Walk or tap a road. Walk into a doorway to enter. No saved progress is changed." if room=="" else "Walk south to return. Preview only: shops and story are not active here."
 queue_redraw()

func check_transition():
 if room!="":
  if Rect2(500,735,100,45).has_point(position_on_map):back_to_town(return_point)
  return
 for d in DOORS:
  if position_on_map.distance_to(d[1])<13:
   enter(d[0],d[1]+d[2]*24);return
 for e in EXITS:
  if position_on_map.distance_to(e[1])<15:
   enter(e[0]+" gateway",e[1]+Vector2(35,0) if e[0]=="Harbor" else e[1]+Vector2(0,35 if e[0]!="Farm" else -35));return

func enter(kind:String,back:Vector2):
 room=kind;return_point=back;route.clear();lock_time=.8;position_on_map=Vector2(550,700)
 if kind!="Restaurant" and not kind.ends_with(" gateway"):
  room_node=preload("res://ShopInterior.gd").new();add_child(room_node);room_node.z_index=-1;room_node.setup(kind)
  for resident in room_node.residents:resident.paused=true;resident.set_physics_process(false)
 else:
  room_solids=[Rect2(180,260,170,85),Rect2(750,260,170,85),Rect2(180,460,170,85),Rect2(750,460,170,85),Rect2(370,190,360,80)] if kind=="Restaurant" else []
 rebuild_routes();refresh()

func back_to_town(point:Vector2):
 if is_instance_valid(room_node):room_node.queue_free()
 room_node=null;room="";room_solids.clear();position_on_map=point;route.clear();lock_time=.8;rebuild_routes();refresh()

func _draw():
 if room=="":
  draw_texture(background,Vector2.ZERO)
  if show_routes:
   for r in LANES:draw_rect(r,Color(0,.9,.6,.25))
   for d in DOORS:draw_circle(d[1],13,Color(1,.6,0,.8))
  if route.size()>0:draw_circle(route[-1],7,Color("ffe2a0"))
 elif room_node==null:
  draw_rect(Rect2(0,0,1100,850),Color("a9c6b5"))
  draw_rect(Rect2(110,180,880,590),Color("e9dfbc"))
  for r in room_solids:
   draw_rect(r,Color("805b43"));draw_rect(r.grow(-12),Color("f3e8ca"))
  draw_string(ThemeDB.fallback_font,Vector2(300,130),"Restaurant dining-room blockout" if room=="Restaurant" else room+": adjoining map not rebuilt yet",HORIZONTAL_ALIGNMENT_LEFT,-1,24,Color("294437"))
  draw_rect(Rect2(500,735,100,45),Color("b4c9a1"))
  draw_string(ThemeDB.fallback_font,Vector2(510,765),"Town ↓",HORIZONTAL_ALIGNMENT_LEFT,-1,20,Color("294437"))

