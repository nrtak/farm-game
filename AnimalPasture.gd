extends Node2D
const BOUNDS:=Rect2(2560,470,220,290)
const GATE:=Vector2(2560,555)
const FENCES:=[Rect2(2560,470,220,8),Rect2(2560,470,8,30),Rect2(2560,630,8,130),Rect2(2772,470,8,290),Rect2(2560,752,220,8)]
var farm
var elapsed:=0.0
var redraw_clock:=0.0
func setup(f):
 farm=f;z_index=4
 for rect in FENCES: farm.obstacle(rect)
static func outside(f) -> bool:
 return bool(f.BarnLife.state(f).get("pasture",false)) and f.clock_minutes>=540 and f.clock_minutes<1020 and preload("res://WeatherLife.gd").forecast(f.day)=="Normal"
static func point(index:int) -> Vector2:
 return Vector2(2610+(index%3)*60,525+int(index/3)*90)
static func nearest(f) -> int:
 if f.location!="farm" or f.inside_house or not outside(f): return -1
 var index:=-1;var distance:=78.0
 for i in range(f.BarnLife.state(f).animals.size()):
  var d:float=f.player.position.distance_to(point(i))
  if d<distance: index=i;distance=d
 return index
static func toggle(f) -> void:
 var data:Dictionary=f.BarnLife.state(f);data.pasture=not data.get("pasture",false)
 f.save_game(false);f.BarnLife.open_manager(f)
func _process(delta:float):
 visible=farm.location=="farm" and not farm.inside_house
 if not visible or not farm.window_focused or farm.paused_by_player: return
 elapsed+=delta;redraw_clock+=delta
 if redraw_clock>.15: redraw_clock=0;queue_redraw()
func _draw():
 if farm==null or not visible: return
 for rect in FENCES:
  draw_rect(rect,Color("846443"))
  var horizontal:bool=rect.size.x>rect.size.y
  var length:float=rect.size.x if horizontal else rect.size.y
  var rise=Vector2(0,-25)
  if is_instance_valid(farm.perspective):rise=farm.perspective.BASIS.affine_inverse()*Vector2(0,-24)
  var end=rect.position+(Vector2(length,0) if horizontal else Vector2(0,length))
  preload("res://world/angled/YardFence.gd").paint(self,rect.position,end,rise*1.25)
 if not is_instance_valid(farm.perspective):draw_string(ThemeDB.fallback_font,GATE+Vector2(-45,-10),"Pasture",HORIZONTAL_ALIGNMENT_LEFT,-1,21,Color("584631"))
 if not outside(farm): return
 farm.BarnLife.prepare_art()
 var animals:Array=farm.BarnLife.state(farm).animals
 for i in range(animals.size()):
  var a:Dictionary=animals[i];var p:Vector2=point(i)
  var personality:String=a.get("personality","Calm")
  if personality=="Playful": p.y-=maxf(0,sin(elapsed*2.5+i))*5
  elif personality=="Curious": p.x+=sin(elapsed*.7+i)*7
  var region:Rect2=farm.BarnLife.art_regions[farm.BarnLife.SPECIES.keys().find(a.species)]
  var size:Vector2=region.size*(100.0/region.size.y)
  draw_circle(point(i)+Vector2(0,4),16,Color(0.2,.25,.15,.18))
  if is_instance_valid(farm.perspective):
   var b=farm.perspective.BASIS
   draw_set_transform_matrix(b.affine_inverse()*Transform2D(0,Vector2.ONE*.65,0,b*p));p=Vector2.ZERO
  draw_texture_rect_region(farm.BarnLife.art,Rect2(p-Vector2(size.x/2,size.y-10),size),region)
  if farm.player.position.distance_to(point(i))<110:
   draw_string(ThemeDB.fallback_font,p+Vector2(-38,-65),a.get("name",a.species),HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("493b2d"))
  draw_set_transform_matrix(Transform2D.IDENTITY)
