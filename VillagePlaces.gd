extends Node2D
const PLACES=[
 ["town",Vector2(1300,700),"Library bench","Sit and watch the town","The pages rustle in the breeze. Haruka says every old map has a story."],
 ["town",Vector2(1530,440),"School noticeboard","Read","This week: growing beans, drawing the village, and an afternoon nature walk. Lessons end at two."],
 ["town",Vector2(1120,1240),"Restaurant menu","Read","Today's kitchen uses local vegetables. Ask inside for a warm seasonal meal."],
 ["harbor",Vector2(1310,445),"Harbor bench","Sit and watch the tide","A gull circles the boats while someone sorts a net along the quay."],
 ["harbor",Vector2(800,260),"Catch board","Read","Take only what you need. Small fish and tide-pool creatures stay in the sea."],
 ["historic",Vector2(1320,790),"Shrine wishes","Read","For a gentle year. For someone far away. For the courage to begin again."],
 ["tea",Vector2(1150,600),"Tea garden bench","Sit and listen","Warm leaves and damp soil scent the air. Sachiko says good tea starts with patience."]]
var farm
var marks=[]
var previous=Vector2.ZERO
var area=""
var age=0.0
var seated:Node2D
func stand_up():
 if is_instance_valid(seated):seated.finish()
 seated=null
func setup(f):farm=f;name="VillagePlaces";z_index=3
func point(entry:Array)->Vector2:
 return farm.TOWN_ORIGIN+farm.town.G.project(entry[1]) if entry[0]=="town" else farm.REGION_ORIGINS[entry[0]]+entry[1]
func nearest()->int:
 for i in range(PLACES.size()):
  if farm.location==PLACES[i][0] and farm.player.position.distance_to(point(PLACES[i]))<60:return i
 return -1
func interact():
 var i=nearest()
 if i<0:return
 farm.close_dialogue()
 var place=PLACES[i];var c=farm.make_modal(place[2],true);farm.dialogue_text.text=place[4]
 if place[3].begins_with("Sit"):
  seated=load("res://BenchPose.gd").new();farm.add_child(seated);seated.begin(farm,point(place))
 c.add_child(farm.make_button("Stand up" if place[3].begins_with("Sit") else "Close",farm.close_dialogue))
func _process(delta):
 if farm==null:return
 if area!=farm.location:area=farm.location;marks.clear();previous=farm.player.position
 if not farm.paused_by_player and farm.window_focused:age+=delta
 if farm.location=="harbor" and not farm.dialogue_open and farm.player.position.distance_to(previous)>24:
  marks.append([farm.player.position,age]);previous=farm.player.position
  if marks.size()>28:marks.pop_front()
 while not marks.is_empty() and age-marks[0][1]>15:marks.pop_front()
 queue_redraw()
func _draw():
 if farm==null or farm.inside_house or farm.location=="shop":return
 for mark in marks:
  draw_circle(mark[0]+Vector2(-5,0),3,Color(.55,.43,.29,.35*(1-(age-mark[1])/15)))
  draw_circle(mark[0]+Vector2(5,8),3,Color(.55,.43,.29,.35*(1-(age-mark[1])/15)))
 for p in PLACES:
  if farm.location!=p[0]:continue
  var at=point(p);var b=farm.perspective.BASIS if farm.location!="town" else Transform2D.IDENTITY
  draw_set_transform_matrix(b.affine_inverse()*Transform2D(0,b*at))
  if "bench" in p[2]:
   for x in [-25,25]:draw_line(Vector2(x,0),Vector2(x,-18),Color("76553a"),4)
   for y in [-12,-18,-28]:draw_line(Vector2(-32,y),Vector2(32,y),Color("b88755"),5)
  else:
   draw_line(Vector2.ZERO,Vector2(0,-30),Color("84633f"),4)
   draw_rect(Rect2(-22,-53,44,30),Color("805c3e"));draw_rect(Rect2(-18,-49,36,22),Color("eadbb7"))
   for y in [-43,-37,-31]:draw_line(Vector2(-13,y),Vector2(12,y),Color("9a8b70"),1)
  draw_set_transform_matrix(Transform2D.IDENTITY)
