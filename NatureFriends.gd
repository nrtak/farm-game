extends Node2D
const NAMES=["Elder Moss","Dewdrop","Pebble","Thistle"]
const AREAS=["historic","historic","mountain","tea"]
const HOMES=[Vector2(1100,820),Vector2(920,900),Vector2(1160,850),Vector2(1110,1100)]
const FAVORITES=["Tea packets","Strawberry","Copper","Turnip"]
const GARDEN=Vector2(1740,310)
const KEEPSAKES=["Moss-wrapped wishing stone","Rain-blue river glass","Copper-flecked mountain pebble","Pressed violet leaf"]
var farm
var sprites=[]
var points=[]
var stamp=""
var idle_time=0.0
const VISIT_SPOTS=[Vector2(930,1450),Vector2(1350,1640),Vector2(2700,1050),Vector2(1740,310),Vector2(2600,1550),Vector2(900,620),Vector2(1510,530),Vector2(2050,1600)]
func visit_point(index:int)->Vector2:
 # Stable within a day and across reloads, with a different circuit on later visits.
 var first=posmod(int(farm.day/3)+index*3,VISIT_SPOTS.size())
 for step in range(VISIT_SPOTS.size()):
  var candidate:Vector2=VISIT_SPOTS[(first+step)%VISIT_SPOTS.size()]
  if not farm.is_walkable(candidate):continue
  var clear=true
  for plot in farm.plots:
   if candidate.distance_to(plot.position)<85:clear=false;break
  for door in [farm.farmhouse.DOOR_POSITION,farm.BARN_DOOR,farm.FarmBuildings.GREENHOUSE_DOOR,farm.FARM_EXIT]:
   if candidate.distance_to(door)<190:clear=false
  if clear:return candidate
 return Vector2.INF
static func seasonal_line(day:int)->String:
 return ["The spring blossoms have found your farm, too.","Your leaves make little patches of shade in the summer sun.","The autumn breeze carries the smell of your harvest.","Even in winter, the soil is dreaming of spring."][int((day-1)/28)%4]
static func state(f)->Dictionary:
 if not f.interior_progress.get("nature_friends") is Dictionary:f.interior_progress.nature_friends={}
 var s:Dictionary=f.interior_progress.nature_friends
 for key in ["friendship","gift_days","talk_days","keepsakes"]:
  if not s.get(key) is Dictionary:s[key]={}
 return s
func setup(f):
 farm=f;name="NatureFriends"
 var texture=load("res://assets/nature-friends-v1.png");var cell=texture.get_size()/2.0
 for i in range(4):
  var sprite=Sprite2D.new();sprite.texture=texture;sprite.region_enabled=true;sprite.region_filter_clip_enabled=true;sprite.region_rect=[Rect2(730,640,520,605),Rect2(735,25,490,610),Rect2(735,25,490,610),Rect2(730,640,520,605)][i];sprite.centered=false
  var tint=ShaderMaterial.new();tint.shader=preload("res://NatureTint.gdshader");tint.set_shader_parameter("hue_shift",[0.23,0.0,0.43,0.0][i]);sprite.material=tint
  sprite.visible=false;add_child(sprite);sprites.append(sprite);points.append(Vector2.ZERO)
func _process(_delta):
 if not farm.paused_by_player and farm.window_focused and not farm.dialogue_open:idle_time+=_delta
 var key=str([farm.location,farm.inside_house,farm.day,int(farm.clock_minutes/60),farm.is_rainy_day(),int(state(farm).friendship.get(NAMES[0],0))])
 if key!=stamp:
  stamp=key
  for i in range(4):
   var visit=farm.location=="farm" and farm.day%3==i%3 and int(state(farm).friendship.get(NAMES[0],0))>=12 and farm.clock_minutes>=600 and farm.clock_minutes<1020 and not farm.is_rainy_day()
   sprites[i].visible=visit or farm.location==AREAS[i]
   if visit:
    points[i]=visit_point(i)
    if not points[i].is_finite():sprites[i].visible=false
   elif farm.location==AREAS[i]:points[i]=farm.REGION_ORIGINS[AREAS[i]]+farm.regions[AREAS[i]].safe_point(HOMES[i])
 for i in range(4):
  var s=sprites[i]
  s.visible=s.visible and not farm.inside_house
  if not s.visible:continue
  var b=farm.perspective.BASIS;var ratio=52.0/s.region_rect.size.y
  s.transform=b.affine_inverse()*Transform2D(0,Vector2.ONE*ratio,0,b*points[i]-Vector2(s.region_rect.size.x*ratio/2,50+sin(idle_time*1.6+i*1.7)*1.5))
  s.z_as_relative=false;s.z_index=farm.perspective.depth(points[i])
 queue_redraw()
func welcome_garden():
 var s=state(farm)
 if int(s.friendship.get(NAMES[0],0))<12 or s.get("garden",false):return
 s.garden=true;farm.save_game(false);farm.close_dialogue()
 farm.say("A little wildflower garden now welcomes your nature friends beside the farm lane.")
func _draw():
 if farm==null or farm.location!="farm" or farm.inside_house or not state(farm).get("garden",false):return
 var b=farm.perspective.BASIS
 draw_set_transform_matrix(b.affine_inverse()*Transform2D(0,b*GARDEN))
 for i in range(24):
  var p=Vector2(cos(i*2.4)*sqrt(i)*9,sin(i*2.4)*sqrt(i)*4)
  draw_line(p,p+Vector2(sin(idle_time+i)*1.5,-9),Color("638746"),2)
  var tip=p+Vector2(sin(idle_time+i)*1.5,-10)
  for petal in range(5):draw_circle(tip+Vector2(cos(petal*TAU/5),sin(petal*TAU/5))*2,2,Color("eee7c6") if i%2==0 else Color("b9a3d0"))
  draw_circle(tip,1.5,Color("e9bf66"))
 for i in range(4):
  if state(farm).keepsakes.has(NAMES[i]):
   draw_circle(Vector2(-18+i*12,8),5,[Color("779663"),Color("8bc9d2"),Color("bd936c"),Color("b29abd")][i])
 draw_set_transform_matrix(Transform2D.IDENTITY)
func nearest()->int:
 if farm.location not in AREAS and farm.location!="farm":return -1
 for i in range(4):
  if sprites[i].visible and farm.player.position.distance_to(points[i])<75:return i
 return -1
func interact():
 var i=nearest()
 if i<0:return
 var s=state(farm);var person=NAMES[i];var c=farm.make_modal(person,true)
 var item:String=farm.held_gift
 if item!="" and farm.carried_count(item)>0:
  if int(s.gift_days.get(person,-1))==farm.day:farm.dialogue_text.text="Thank you, one gift is plenty today."
  else:
   farm.change_carried(item,-1);farm.held_gift="";s.gift_days[person]=farm.day
   s.friendship[person]=mini(100,int(s.friendship.get(person,0))+(3 if item==FAVORITES[i] else 1))
   farm.dialogue_text.text="A gift for me? I'll treasure the thought."+(" This is my favorite!" if item==FAVORITES[i] else "")
 else:
  if int(s.talk_days.get(person,-1))!=farm.day:
   s.talk_days[person]=farm.day;s.friendship[person]=mini(100,int(s.friendship.get(person,0))+1)
  farm.dialogue_text.text=["We listen to the valley. Visit us when you like; friendship has no timetable.","The waterfall tells a different story after rain.","Mountains grow slowly. It's all right if you do too.","Your fields smell of warm earth. May I watch the seedlings?"][i]
 if farm.location=="farm":farm.dialogue_text.text+="\n"+seasonal_line(farm.day)
 farm.dialogue_text.text+="\nFriendship %d / 100" % int(s.friendship.get(person,0))
 if int(s.friendship.get(person,0))>=20 and not s.keepsakes.has(person):
  s.keepsakes[person]=KEEPSAKES[i]
  farm.dialogue_text.text+="\nA keepsake for our friendship: "+KEEPSAKES[i]+". It will rest in your welcoming garden."
 if int(s.friendship.get(NAMES[0],0))>=12 and not s.get("garden",false):
  c.add_child(farm.make_button("Welcome them with a wildflower garden",welcome_garden))
 elif not s.keepsakes.is_empty():farm.dialogue_text.text+="\nGarden keepsakes: "+", ".join(s.keepsakes.values())
 c.add_child(farm.make_button("Close",farm.close_dialogue));farm.save_game(false)
