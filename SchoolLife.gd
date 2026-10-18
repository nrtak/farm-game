extends Node
const NAMES=["Nao","Sota","Rin","Jun"]
const DIALOGUE={"Nao":["I'm Nao, the village teacher. Our school is beside the library.","Lessons run from nine until two on weekdays. Afterwards, we spend time in the playground."],"Sota":["I'm Sota! We're growing a bean in a jar at school.","Keiko says I can help sort the seed packets when I get home."],"Rin":["I'm Rin. I drew a map of our village!", "I live at the inn. After lessons, I like the swings best."],"Jun":["I'm Jun! Sachiko showed me how to spot the tiniest tea leaves.","I'm learning to count the boats at the harbor. There are so many colors!"]}
var farm
var people=[]
var stamp=""
static func portrait(person:String)->Texture2D:
 var a=AtlasTexture.new();a.atlas=load("res://assets/school-cast-v1.png")
 var cuts=[0,350,655,980,1280];var row=NAMES.find(person)
 a.region=Rect2(70,cuts[row],230,cuts[row+1]-cuts[row]);return a
func setup(f):
 farm=f
 for i in range(4):
  var n=preload("res://Npc.gd").new();farm.shops.School.add_child(n);n.setup(NAMES[i],null)
  var texture=load("res://assets/school-cast-v1.png");n.sheet=texture;n.sprite.texture=texture
  n.regions.clear();n.offsets.clear()
  var cuts=[0,350,655,980,1280]
  var h=cuts[i+1]-cuts[i]
  for direction in range(4):
   for phase in range(4):
    n.regions.append(Rect2(direction*312,cuts[i],312,h));n.offsets.append(Vector2(0,-h/2.0))
  n.height_scale=(145.0 if i==0 else 103.0)/h;n.sprite.scale=Vector2.ONE*n.height_scale;n.frame=-1;n.show_frame(0,1)
  n.label.position.y=-165 if i==0 else -123
  n.speed=45;people.append(n)
 _process(0)
func _process(delta):
 if farm==null:return
 var period=int(farm.clock_minutes/60)
 var key=str([farm.day,period,farm.is_rainy_day(),farm.festival_active,farm.active_scene])
 if key!=stamp:
  stamp=key
  for i in range(people.size()):
   var n=people[i];var target=farm.shops.School
   var point=Vector2(460+(i%2)*180,410+int(i/2)*140)
   var lessons=not preload("res://ResidentRoutine.gd").weekend(farm.day) and period>=9 and period<14
   var play=period>=10 and period<17 and not lessons and not farm.is_rainy_day()
   if play:
    target=farm.town;point=farm.town.G.project(Vector2(850+(i%2)*90,400+int(i/2)*45))
   elif not lessons and not (farm.is_rainy_day() and period>=9 and period<17):
    target=farm.shops[["Inn","General Store","Inn","Tea Farmhouse"][i]];point=Vector2(440+(i%2)*180,610)
   if n.get_parent()!=target:n.reparent(target,false)
   n.position=target.safe_npc_point(point) if target.has_method("safe_npc_point") else target.safe_point(point)
   n.set_route([]);n.visible=not farm.festival_active and farm.active_scene==""
   n.scale=Vector2.ONE*(.4 if target==farm.town else .55)
 for n in people:
  if n.is_visible_in_tree() and not farm.dialogue_open:n.tick(delta)
