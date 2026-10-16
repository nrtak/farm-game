extends Node2D
# A single optional companion; it never occupies a collision body or a barn stall.
const ART="res://assets/shiba-walk-rest-v1.png"
var farm
var pet
var home:=Vector2.ZERO
var view:=""
var target:=Vector2.ZERO
var follow:=false
var poll:=0.0
static func state(f) -> Dictionary:
 if not f.interior_progress.get("dog") is Dictionary: f.interior_progress.dog={}
 var s:Dictionary=f.interior_progress.dog
 s.food=clampi(int(s.get("food",0)),0,999)
 s.affection=clampi(int(s.get("affection",0)),0,100)
 return s
static func owned(f) -> bool: return bool(state(f).get("adopted",false))
static func adult(f) -> bool:
 return owned(f) and f.day-int(state(f).get("arrival",f.day))>=28 and int(state(f).get("fed_days",0))>=14
func setup(f) -> void:
 farm=f;name="FarmDog";z_index=8
 pet=preload("res://AmbientPet.gd").new();pet.kind="shiba";pet.artwork=ART;add_child(pet)
 visible=false
func safe_point(preferred:Vector2) -> Vector2:
 if farm.polish.clear_position(preferred): return preferred
 for radius in range(24,241,24):
  for i in range(16):
   var p:Vector2=preferred+Vector2.from_angle(i*TAU/16)*radius
   if farm.polish.clear_position(p): return p
 return farm.player.position
func segment_clear(start:Vector2,finish:Vector2) -> bool:
 var count:int=maxi(1,ceili(start.distance_to(finish)/10.0))
 for i in range(count+1):
  if not farm.polish.clear_position(start.lerp(finish,float(i)/count)): return false
 return true
func _process(delta:float) -> void:
 if farm==null: return
 visible=owned(farm) and farm.location in ["farm","house"] and not farm.choosing_character
 if not visible: view="";return
 var sheltered:bool=farm.is_rainy_day() or preload("res://WeatherLife.gd").forecast(farm.day) in ["Hurricane","Heatwave"] or farm.clock_minutes>=1140
 if sheltered and not farm.inside_house: visible=false;view="";return
 var key:String=str(farm.inside_house)
 if view!=key:
  view=key;follow=false
  home=safe_point(farm.ROOM_ORIGIN+Vector2(610,595) if farm.inside_house else farm.farmhouse.DOOR_POSITION+Vector2(155,155))
  pet.position=home;target=home
 pet.scale=Vector2.ONE*(1.0 if adult(farm) else .68)
 pet.affection_time=maxf(0,pet.affection_time-delta)
 if not farm.window_focused or farm.paused_by_player or farm.dialogue_open or farm.sleep_in_progress:
  pet.wait=1;pet.resting=farm.sleep_in_progress;pet.update_shiba();return
 poll-=delta
 if poll<=0:
  poll=.35
  if not farm.polish.clear_position(pet.position): pet.position=safe_point(home);target=pet.position
  if follow and pet.position.distance_to(farm.player.position)<300:
   var goal:Vector2=farm.player.position+Vector2(80,45)
   if farm.polish.clear_position(goal) and segment_clear(pet.position,goal): target=goal
 var direction:Vector2=target-pet.position
 if direction.length()>6:
  var next:Vector2=pet.position+direction.normalized()*minf(95*delta,direction.length())
  if farm.polish.clear_position(next):
   pet.travel+=pet.position.distance_to(next);pet.position=next;pet.wait=0;pet.resting=false
   if absf(direction.x)>1: pet.facing=signf(direction.x)
  else: target=pet.position;pet.wait=1
 else: pet.wait=1;pet.resting=farm.clock_minutes>=1140
 pet.update_shiba();pet.queue_redraw();queue_redraw()
func _draw() -> void:
 if not visible: return
 draw_circle(home+Vector2(-35,0),23,Color("a68d64"))
 draw_circle(home+Vector2(-35,-3),17,Color("d2be94"))
 draw_circle(home+Vector2(30,0),11,Color("758f96"))
 draw_circle(home+Vector2(30,-2),7,Color("b3d6d6"))
 if pet.position.distance_to(farm.player.position)<150:
  draw_string(ThemeDB.fallback_font,pet.position+Vector2(-28,-85 if adult(farm) else -62),str(state(farm).get("name","Mochi")),HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("493b2d"))
static func nearby(f) -> bool:
 var node=f.get_node_or_null("FarmDog")
 return owned(f) and node!=null and node.visible and node.pet.position.distance_to(f.player.position)<105
static func panel(f,title:String,text:String): return preload("res://EverydayLife.gd").panel(f,title,text)
static func menu(f) -> void:
 if not owned(f): offer(f);return
 var s:Dictionary=state(f)
 var c=panel(f,str(s.get("name","Mochi"))+" · "+("Dog" if adult(f) else "Puppy"),"Together %d days · Affection %d / 100\nFood: %d · %s today · %s today\nYour dog stays home in bad weather and rests indoors at night." % [maxi(1,f.day-int(s.arrival)+1),s.affection,s.food,"Fed" if int(s.get("fed",-1))==f.day else "Not fed","Played" if int(s.get("played",-1))==f.day else "Not played"])
 if nearby(f):
  for entry in [["Feed one dog meal","fed"],["Pet","petted"],["Play together","played"]]:
   var b=f.make_button(entry[0],care.bind(f,entry[1]));b.disabled=int(s.get(entry[1],-1))==f.day;c.add_child(b)
 elif f.location in ["farm","house"]: c.add_child(f.make_button("Whistle",whistle.bind(f)))
 if f.location=="shop" and f.shop_name=="Ranch": c.add_child(f.make_button("10 dog meals · ¥20",buy_food.bind(f)))
 c.add_child(f.make_button("Back",f.close_dialogue))
static func offer(f) -> void:
 if owned(f): menu(f);return
 var allowed:bool=f.day>=7 and ((f.location=="shop" and f.shop_name=="Ranch") or (f.location=="farm" and int(state(f).get("offer_day",-1))==f.day))
 var c=panel(f,"A home for a puppy","Renji is looking for a home for a young Shiba. Adoption is free and includes ten dog meals. The puppy grows after 28 days together and at least 14 days of feeding. It does not take a barn stall.")
 if not allowed:
  f.dialogue_text.text="Visit Renji at the town ranch from Spring 7 onward to meet a puppy. Adoption is optional."
 else:
  var name_field:=LineEdit.new();name_field.text="Mochi";name_field.max_length=16;name_field.custom_minimum_size.y=48;c.add_child(name_field)
  c.add_child(f.make_button("Adopt this puppy",func(): adopt(f,name_field.text)))
 c.add_child(f.make_button("Maybe later",f.close_dialogue))
static func adopt(f,chosen_name:String) -> void:
 if owned(f) or f.day<7: return
 if not ((f.location=="shop" and f.shop_name=="Ranch") or (f.location=="farm" and int(state(f).get("offer_day",-1))==f.day)): return
 var s:Dictionary=state(f);var clean:String=chosen_name.strip_edges().left(16)
 s.adopted=true;s.name="Mochi" if clean.is_empty() else clean;s.arrival=f.day;s.food=10;s.affection=0;s.fed_days=0
 f.save_game(false);preload("res://EverydayLife.gd").remember(f,"Welcome home, "+s.name,"A Shiba puppy joined your family.")
 var c=panel(f,"Welcome home, "+s.name,"Renji brings a bed and a little food bowl to your farm. Your puppy is waiting at home. Visit the ranch for dog meals; feeding, petting and play build your bond.")
 c.add_child(f.make_button("See you at home",f.close_dialogue))
static func care(f,kind:String) -> void:
 if not nearby(f) or kind not in ["fed","petted","played"]: return
 var s:Dictionary=state(f)
 if int(s.get(kind,-1))==f.day: return
 if kind=="fed":
  if s.food<1:
   if f.dialogue_open: f.dialogue_text.text="No dog meals left. Buy ten meals for ¥20 at the town ranch. You can still pet and play with your companion today."
   else: f.say("Buy dog meals at the town ranch.")
   return
  s.food-=1;s.fed_days=int(s.get("fed_days",0))+1
 s[kind]=f.day;s.affection=mini(100,s.affection+{"fed":1,"petted":2,"played":3}[kind]);f.save_game(false)
 var node=f.get_node("FarmDog");node.pet.affection_time=3
 f.close_dialogue()
 if kind=="played":
  node.follow=true
  var goal:Vector2=node.pet.position+Vector2(70,0)
  if node.segment_clear(node.pet.position,goal): node.target=goal
 f.say({"fed":s.name+" enjoys a meal.","petted":s.name+" leans into your hand.","played":s.name+" bounds beside you, tail wagging."}[kind])
static func whistle(f) -> void:
 var node=f.get_node_or_null("FarmDog")
 f.close_dialogue()
 if node==null or not node.visible: f.say("Your dog is resting at home. Try the farmhouse.");return
 var goal:Vector2=f.player.position+Vector2(80,45)
 if node.segment_clear(node.pet.position,goal): node.follow=true;node.target=goal;f.say("Your dog comes when you call.")
 else: f.say("Your dog hears you. Move onto the same open path to call it over.")
static func buy_food(f) -> void:
 if not owned(f) or f.location!="shop" or f.shop_name!="Ranch": return
 if f.coins<20 or state(f).food>989: return
 f.coins-=20;state(f).food+=10;f.save_game(false);menu(f)
static func maybe_visit(f) -> bool:
 if owned(f) or f.day<7 or f.clock_minutes>=720 or f.is_rainy_day(): return false
 if f.day-int(state(f).get("offer_day",-100))<7: return false
 state(f).offer_day=f.day;f.save_game(false)
 var visitor=preload("res://Npc.gd").new()
 f.farm_visitor=visitor;f.add_child(visitor)
 visitor.setup("Renji",preload("res://CharacterArt.gd").walk("Renji"))
 visitor.position=f.get_node("FarmDog").safe_point(f.farmhouse.DOOR_POSITION+Vector2(180,100))
 visitor.z_index=5;visitor.face_player(f.player.position)
 var c=f.make_modal("Renji",true)
 f.dialogue_text.text="A little Shiba has been following me around the ranch. I think a farm like yours could be a good home. Would you like to meet the puppy? No pressure—you can visit us later."
 c.add_child(f.make_button("Meet the puppy",offer.bind(f)));c.add_child(f.make_button("Another time",f.close_dialogue))
 return true
