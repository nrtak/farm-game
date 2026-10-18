extends Node2D
# A visual replay of the settled morning job; never mutates crops or inventory.
const PARK=Vector2(2150,250)
var farm
var sprite:Sprite2D
var foot= PARK
var route:Array[Vector2]=[]
var index=0
var day=-1
var elapsed=0.0
func setup(f):
 farm=f;name="FarmEquipmentVisual"
 sprite=Sprite2D.new();sprite.texture=load("res://world/angled/harvest-tractor-v1.png");add_child(sprite)
func _process(delta):
 var s=load("res://FarmAutomation.gd").state(farm)
 visible=bool(s.get("tractor",false)) and farm.location=="farm" and not farm.inside_house
 if not visible:return
 if day!=farm.day:
  day=farm.day;foot=PARK;route.clear();index=0
  if int(s.get("morning",-1))==day and not s.get("harvest_route",[]).is_empty():
   route.append(Vector2(PARK.x,650))
   for pair in s.harvest_route:
    if pair is Array and pair.size()==2:route.append(Vector2(float(pair[0]),float(pair[1])))
   route.append(Vector2(PARK.x,route.back().y));route.append(Vector2(PARK.x,650));route.append(PARK)
 var moving=false
 if farm.window_focused and not farm.paused_by_player and not farm.dialogue_open and index<route.size():
  # Yield instead of visually driving through the farmer.
  if foot.distance_to(farm.player.position)>100:
   var next=foot.move_toward(route[index],delta*105)
   sprite.flip_h=(farm.perspective.BASIS*(next-foot)).x<0
   moving=next!=foot;foot=next
   if foot.distance_to(route[index])<1:index+=1
  elapsed+=delta
 var b=farm.perspective.BASIS
 var ratio=100.0/sprite.texture.get_width()
 sprite.transform=b.affine_inverse()*Transform2D(0,Vector2.ONE*ratio,0,b*foot+Vector2(0,-sprite.texture.get_height()*ratio*.39+(sin(elapsed*16)*.5 if moving else 0)))
 sprite.z_as_relative=false;sprite.z_index=farm.perspective.depth(foot)
