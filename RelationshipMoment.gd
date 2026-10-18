extends Node
# Temporary staging in the real world. Progress is saved before staging; temporary
# actors and positions must never enter a save or replace a resident's routine.
var farm
var origin:Dictionary
var actors:Array=[]
var hidden:Array=[]
var finished:=false
func begin(f,person:String,occasion:String,words:String):
 farm=f
 process_priority=500
 f.close_dialogue()
 origin={"location":f.location,"shop":f.shop_name,"inside":f.inside_house,"position":f.player.position,"frame":f.walk_frame}
 f.relationship_moment=self
 f.add_child(self)
 if occasion=="Tea":
  f.enter_shop("Café",true)
  f.player.position=f.SHOP_ORIGIN+Vector2(550,520)
 elif occasion=="Wedding" and f.is_rainy_day():
  f.enter_shop("Shrine Residence",true)
  f.player.position=f.SHOP_ORIGIN+Vector2(550,440)
 else:
  f.travel_to("harbor" if occasion=="Beach walk" else "historic",Vector2(1070,700) if occasion=="Beach walk" else Vector2(1410,650),false)
 # Hide only residents in the scene's host, leaving their schedules intact.
 for host in f.perspective.actor_roots:
  for child in host.get_children():
   if child.get_script()==load("res://Npc.gd"):
    hidden.append([child,child.visible]);child.hide()
 add_actor(person,f.player.position+Vector2(90,-30))
 if occasion=="Wedding":
  for i in range(3):add_actor(["Akira","Haruka","Rei"][i],f.player.position+f.perspective.BASIS.affine_inverse()*[Vector2(-60,-40),Vector2(-20,-75),Vector2(25,-85)][i])
 f.update_walk(0,false,Vector2.RIGHT)
 var column=f.make_modal(person,true)
 f.dialogue_text.text=words
 column.add_child(f.make_button("Return",f.close_dialogue))
 f.perspective._process(0)
func _process(_delta):
 if finished:return
 for record in hidden:
  if is_instance_valid(record[0]):record[0].hide()
func add_actor(person:String,foot:Vector2):
 var actor=load("res://Npc.gd").new()
 farm.add_child(actor);actor.setup(person,load("res://CharacterArt.gd").walk(person))
 var host=farm.polish.area_node();var offset=farm.polish.area_origin()
 actor.position=offset+host.safe_point(foot-offset) if host.has_method("safe_point") else foot
 actor.paused=true;actor.face_player(farm.player.position)
 actors.append(actor)
func finish():
 if finished:return
 finished=true
 for actor in actors:
  actor.hide();actor.queue_free()
 for record in hidden:
  if is_instance_valid(record[0]):record[0].visible=record[1]
 # Keep the save guard active through enter_shop's normal autosave.
 if origin.inside:farm.set_location(true,origin.position)
 elif origin.location=="shop":farm.enter_shop(origin.shop,true)
 else:
  var offset=Vector2.ZERO if origin.location=="farm" else (farm.TOWN_ORIGIN if origin.location=="town" else farm.REGION_ORIGINS.get(origin.location,Vector2.ZERO))
  farm.travel_to(origin.location,origin.position-offset,false)
 farm.player.position=origin.position
 farm.player.velocity=Vector2.ZERO
 farm.polish.path.clear();farm.joystick.reset_stick()
 farm.relationship_moment=null
 farm.update_walk(0,false,Vector2.DOWN)
 farm.perspective._process(0)
 queue_free()
