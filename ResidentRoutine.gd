extends RefCounted
# Day 1 is Monday. Extra indoor instances are only visible at their scheduled time.
const LEISURE = {"Seira":"Archive", "Shohei":"Café", "Aya":"Archive", "Haruka":"Café"}
const STATIONS = {
 "Seira":["General Store","Archive"], "Shohei":["Blacksmith","Café"],
 "Akira":["Town Hall","Archive"], "Taro":["Police Box","General Store"],
 "Aya":["Clinic","Archive"], "Hana":["Restaurant","Inn"],
 "Keiko":["General Store","Café"], "Kenji":["Clinic","Café"],
 "Gen":["Blacksmith","Carpentry"], "Yumi":["Inn","Restaurant"],
 "Jiro":["Fire Station","Police Box"], "Yuta":["Fire Station","Ranch"],
 "Naomi":["Café","General Store"], "Kenta":["Carpentry","Blacksmith"],
 "Haruka":["Archive","Town Hall"]}

static func weekend(day:int)->bool:return posmod(day-1,7)>=5

static func room_override(person:String, day:int, minute:float, rainy:bool)->String:
 if rainy:
  if person=="Taro":return "Police Box"
  if person=="Kenta":return "Carpentry"
  return "@default"
 # Short leisure breaks keep the existing shopkeepers on duty.
 if weekend(day) and minute>=840 and minute<1020 and LEISURE.has(person):return LEISURE[person]
 if minute>=1260:
  return {"Seira":"General Store","Shohei":"Blacksmith","Gen":"Blacksmith","Kenji":"Clinic","Aya":"Clinic","Naomi":"Café","Jiro":"Fire Station","Yuta":"Fire Station","Haruka":"Archive","Rei":"Shrine Residence","Emi":"Mountain Lodge","Hiro":"Hiro Cabin","Kenta":"Carpentry"}.get(person,"@default")
 return "@default"

static func extra_people(room:String)->Array:
 var people=[]
 for person in LEISURE:
  if LEISURE[person]==room:people.append(person)
 return people

static func street_target(town, person:String, minute:float)->Vector2:
 var places:Array=STATIONS.get(person,["Town Hall","Archive"])
 var destination:String=places[0 if minute<900 else 1]
 for b in town.BUILDINGS:
  if b.name==destination:
   # Stand beside the frontage, not in the doorway or main travel lane.
   var tangent=Vector2.RIGHT if b.facing in ["N","S"] else Vector2.DOWN
   var side=1 if posmod(person.hash(),2)==0 else -1
   return town.safe_npc_point(town.G.project(b.raw_door+tangent*95*side))
 return town.safe_npc_point(town.G.project(Vector2(990,900)))

static func words(f,person:String)->String:
 var room:String=f.resident_room(person)
 if f.is_rainy_day() and not room.is_empty():return "I'm staying at the %s until the rain eases. Come in and keep dry." % room.to_lower()
 if weekend(f.day) and f.clock_minutes>=840 and f.clock_minutes<1020 and LEISURE.has(person):
  return {"Seira":"It's my afternoon reading break. Haruka saved a book for me.","Shohei":"A café break helps me think through the next tool design.","Aya":"I'm spending my afternoon break with a good book.","Haruka":"I like a cup of tea away from the archive on weekends."}[person]
 if f.clock_minutes>=1260:return "I'm winding down for the evening. Let's catch up again tomorrow."
 if not room.is_empty():return "You'll usually find me at the %s around this time." % room.to_lower()
 return {"Taro":"I'm checking the streets between the police box and the shops.","Jiro":"I'm checking the civic street before returning to the station.","Yuta":"I'm checking the lanes are clear for an emergency.","Mika":"The tea rows need a careful look every morning. I'll be at the farmhouse this evening.","Ken":"I'm watching the harbor water before heading home this evening.","Hiro":"I'm checking the mountain trail. I'll be at the lodge this evening.","Rei":"I'm tending the shrine grounds and listening to the falls.","Haruka":"I'm taking a walk near the archive and town hall."}.get(person,"I'm taking a short walk before my next stop.")

static func maybe_visit(f)->bool:
 # Story and adoption visits have priority. One optional social call per week;
 # no reward, deadline or automatic quest acceptance.
 if f.day<8 or f.clock_minutes>=600 or f.is_rainy_day():return false
 var week=int((f.day-1)/7)
 if int(f.interior_progress.get("neighbor_visit_week",-1))==week:return false
 var names=["Mika","Ken","Haruka","Midori"]
 var person:String=names[posmod(week-1,names.size())]
 if int(f.friendship.get(person,0))<2:return false
 f.interior_progress.neighbor_visit_week=week
 var npc=preload("res://Npc.gd").new();f.add_child(npc);f.farm_visitor=npc
 npc.setup(person,preload("res://CharacterArt.gd").walk(person))
 npc.position=f.get_node("FarmDog").safe_point(f.farmhouse.DOOR_POSITION+Vector2(180,100))
 npc.z_index=5;npc.face_player(f.player.position)
 var c=f.make_modal(person,true)
 f.dialogue_text.text={"Mika":"I had a little time before checking the tea rows and thought I'd stop by. It's lovely seeing your fields change. Come see us in tea country when you have a quiet afternoon.","Ken":"I stopped by before heading to the harbor. There's no hurry to catch anything—sometimes watching the water is enough. See you down there!","Haruka":"Your farm is on some of our oldest village maps. I thought I'd come see how it's growing. If you want a break later, there's a seat for you at the archive.","Midori":"Just a friendly call before I open the clinic. I like seeing the farm wake up. If your animals need anything, you can find me beside the ranch."}[person]
 c.add_child(f.make_button("Thanks for visiting",f.close_dialogue))
 f.save_game(false)
 return true
