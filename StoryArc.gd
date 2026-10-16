extends RefCounted
# Optional chapters guide the existing game; they never gate the village vote.
const CHAPTERS=[
 {"title":"A letter in the ledger","day":10,"person":"Haruka","room":"Archive","goal":"Visit the Archive and read your family's letter.","offer":"I found a letter tucked into your family's land ledger. Would you come to the Archive and read it with me?","lines":["The letter is addressed to whoever tends the farm next. The paper smells faintly of dried tea.","'Do not try to mend everything in one season. Start with a patch of earth, and leave room at your table.'","Haruka smiles. Your family recorded the people they helped beside every harvest. Perhaps that is another kind of inheritance."]},
 {"title":"Room to grow","day":21,"person":"Kenta","room":"Carpentry","goal":"Restore one land patch, then visit town Carpentry.","offer":"Your family's old plans leave space for more than crops. Restore a patch and we'll talk about what comes next.","lines":["Kenta spreads a worn plan across the workbench. Beside the fields is a penciled note: 'A place to welcome people.'","You talk about a larger home, animals, and a garden that can feed more than one household.","'Build at your own pace,' Kenta says. 'A good home grows around the life inside it.'"]},
 {"title":"What the tide brings","day":35,"person":"Ken","room":"Harbor Homes","goal":"Catch three fish in total, then visit Harbor Homes.","offer":"Come down to the harbor after you've caught a few fish. There is an old story I want to tell you while we mend a net.","lines":["Ken passes you a loose section of net. The work goes slowly, but the knot holds.","He remembers a storm when your family brought warm food to the harbor. Nobody asked what it was worth.","'A village is a net,' he says. 'One strong knot helps the next one hold.'"]},
 {"title":"A cup for tomorrow","day":60,"person":"Mika","room":"Tea Farmhouse","goal":"Complete the tea-growing lesson, then visit the Tea Farmhouse.","offer":"I'd like to share a cup of tea and hear how the farm is changing. Learn the tea-growing basics, then come by the farmhouse.","lines":["Mika pours two small cups. You compare the patience of growing tea with the hurry of daily farm chores.","She admits that she used to think keeping tradition meant never changing anything.","Together you sketch an idea for a shared village harvest table: old recipes, new growers, and a place for everyone."]},
 {"title":"A light in winter","day":85,"person":"Hana","room":"Inn","goal":"Take part in the Inn's guest-sketchbook activity, then return to the Inn.","offer":"The inn is quiet in winter. Would you add a page to our guest sketchbook and help me plan a welcoming corner?","lines":["Your page joins drawings by travelers, children, and people who never left the village.","Hana places a lamp beside the book. 'Some days, making a place feel welcoming is enough work.'","You leave a small note beneath the drawing: 'There will be another spring.'"]},
 {"title":"A place at the table","day":120,"person":"Naomi","room":"Café","goal":"Harvest 20 crops in total and join the Café recipe-book activity; return to the Café.","offer":"Our shared harvest table could become a real tradition. Bring your growing experience to the recipe book and we'll plan it together.","lines":["Naomi opens the community recipe book to a clean page. You write down what grew well and what surprised you.","The best meal, you decide, should be something a new farmer can help make too.","Outside, neighbors stop to read the plan. The farm is becoming part of their everyday lives."]},
 {"title":"Many small kindnesses","day":160,"person":"Rei","room":"Shrine Residence","goal":"Join five different room activities, then visit the Shrine Residence.","offer":"The village has been noticing the ways you help. Come by after you've spent time with five of our community activities.","lines":["Rei lays out a ribbon for the next gathering. Each little knot represents someone's work.","You remember repaired nets, recipes, tools, and quiet conversations. None felt like a grand achievement at the time.","'Belonging happens in small visits,' Rei says. 'You have already begun.'"]},
 {"title":"The farm we share","day":196,"person":"Akira","room":"Town Hall","goal":"Harvest 30 crops, restore two patches and join five room activities; visit Town Hall.","offer":"The village vote is approaching. When you're ready, come to Town Hall and tell me what you hope the farm will become.","lines":["Akira puts the original land-trust agreement beside your new farm records.","You speak about the work still ahead, and the people who made the first two years possible.","'The vote will happen at the farm,' he says. 'Whatever comes next, you will not be facing it alone.'"]}
]
static func state(f) -> Dictionary:
 if not f.interior_progress.get("chapters") is Dictionary: f.interior_progress.chapters={}
 var s:Dictionary=f.interior_progress.chapters
 for key in ["accepted","completed","steps"]:
  if not s.get(key) is Dictionary: s[key]={}
 return s
static func current(f) -> int:
 for i in range(CHAPTERS.size()):
  if not state(f).completed.get(str(i),false): return i
 return -1
static func eligible(f,i:int) -> bool: return i>=0 and i<CHAPTERS.size() and current(f)==i and f.day>=CHAPTERS[i].day
static func ready(f,i:int) -> bool:
 var acts:Array=f.interior_progress.get("activities",[])
 match i:
  0: return true
  1: return int(f.interior_progress.get("restoration",0))>=1
  2: return f.fish_catches>=3
  3: return f.tea_lesson_seen
  4: return acts.has("Inn")
  5: return f.harvests>=20 and acts.has("Café")
  6: return acts.size()>=5
  7: return f.harvests>=30 and int(f.interior_progress.get("restoration",0))>=2 and acts.size()>=5
 return false
static func in_room(f,i:int) -> bool: return f.location=="shop" and f.shop_name==CHAPTERS[i].room
static func progress_text(f,i:int) -> String:
 var acts:Array=f.interior_progress.get("activities",[])
 var land:int=int(f.interior_progress.get("restoration",0))
 match i:
  0: return "Ready to read the letter"
  1: return "Restored patches: %d / 1" % mini(land,1)
  2: return "Fish caught: %d / 3" % mini(f.fish_catches,3)
  3: return "Tea lesson: "+("complete" if f.tea_lesson_seen else "visit the Tea Farmhouse counter")
  4: return "Guest sketchbook: "+("complete" if acts.has("Inn") else "join the Inn room activity")
  5: return "Harvests: %d / 20 · Recipe book: %s" % [mini(f.harvests,20),"complete" if acts.has("Café") else "join the Café room activity"]
  6: return "Different room activities: %d / 5" % mini(acts.size(),5)
  7: return "Harvests %d / 30 · Land %d / 2 · Activities %d / 5" % [mini(f.harvests,30),mini(land,2),mini(acts.size(),5)]
 return ""
static func conversation_button(f,person:String,column) -> void:
 var i:=current(f)
 if not eligible(f,i) or CHAPTERS[i].person!=person: return
 if not state(f).accepted.get(str(i),false): column.add_child(f.make_button("Story invitation",offer.bind(f,i)))
 elif ready(f,i) and in_room(f,i): column.add_child(f.make_button("Our story",scene.bind(f,i)))
 else: column.add_child(f.make_button("Story goal",journal.bind(f)))
static func journal(f) -> void:
 var i:=current(f)
 var c=f.make_modal("Our village story")
 var s:Dictionary=state(f)
 if i<0: f.dialogue_text.text="All eight optional chapters are complete. Your farm's future is decided by the village vote, and life continues afterward."
 else:
  var ch:Dictionary=CHAPTERS[i]
  f.dialogue_text.text="Chapter %d of 8 · %s\n%s\n%s\n%s\nNo item cost · Friendship +2 with %s." % [i+1,ch.title,ch.goal,progress_text(f,i),"Accepted" if s.accepted.get(str(i),false) else "Available from day %d" % ch.day,ch.person]
  if eligible(f,i):
   if not s.accepted.get(str(i),false): c.add_child(f.make_button("Read invitation",offer.bind(f,i)))
   elif ready(f,i) and in_room(f,i): c.add_child(f.make_button("Continue chapter",scene.bind(f,i)))
   else: f.dialogue_text.text+="\n"+("Ready—visit "+ch.room+" and open this journal." if ready(f,i) else "Keep working toward the goal above, then return here.")
 if f.interior_progress.get("story",{}).get("won",false): c.add_child(f.make_button("Our next chapter · ending",ending.bind(f)))
 c.add_child(f.make_button("Village vote progress",vote_progress.bind(f)))
 c.add_child(f.make_button("Back",preload("res://EverydayLife.gd").journal.bind(f)))
static func vote_progress(f) -> void:
 var c=f.make_modal("Village vote")
 f.dialogue_text.text=f.Stewardship.progress(f)+"\nOptional story chapters do not change the vote requirements."
 c.add_child(f.make_button("Back",journal.bind(f)))
static func offer(f,i:int) -> void:
 if not eligible(f,i): return
 var ch:Dictionary=CHAPTERS[i];var c=f.make_modal(ch.person,true)
 f.dialogue_text.text=ch.offer+"\n\n"+ch.goal+"\nOptional · no deadline or item cost · friendship +2."
 c.add_child(f.make_button("I'd like to help",accept.bind(f,i)))
 c.add_child(f.make_button("Maybe later",f.close_dialogue))
static func accept(f,i:int) -> void:
 if not eligible(f,i): return
 state(f).accepted[str(i)]=true;f.save_game(false);journal(f)
static func scene(f,i:int) -> void:
 if not eligible(f,i) or not state(f).accepted.get(str(i),false) or not ready(f,i) or not in_room(f,i): return
 var ch:Dictionary=CHAPTERS[i];var step:int=clampi(int(state(f).steps.get(str(i),0)),0,ch.lines.size()-1)
 var c=f.make_modal(ch.person,true);f.dialogue_text.text=ch.lines[step]
 c.add_child(f.make_button("Continue" if step<ch.lines.size()-1 else "Keep this memory",advance.bind(f,i,step)))
 c.add_child(f.make_button("Finish talking later",f.close_dialogue))
static func advance(f,i:int,step:int) -> void:
 if not eligible(f,i) or not state(f).accepted.get(str(i),false) or not ready(f,i) or not in_room(f,i): return
 var s:Dictionary=state(f)
 if int(s.steps.get(str(i),0))!=step: return
 if step<CHAPTERS[i].lines.size()-1: s.steps[str(i)]=step+1;f.save_game(false);scene(f,i);return
 s.completed[str(i)]=true
 var person:String=CHAPTERS[i].person;f.friendship[person]=int(f.friendship.get(person,0))+2
 f.save_game(false);f.close_dialogue()
 preload("res://EverydayLife.gd").remember(f,CHAPTERS[i].title,"A chapter shared with "+person+".")
 f.say("Chapter complete · "+CHAPTERS[i].title+" · Friendship +2")
static func maybe_visit(f) -> bool:
 var i:=current(f)
 if not eligible(f,i) or state(f).accepted.get(str(i),false) or f.clock_minutes>=720 or f.is_rainy_day(): return false
 if f.day-int(state(f).get("last_offer",-100))<7: return false
 state(f).last_offer=f.day;f.save_game(false)
 var visitor=preload("res://Npc.gd").new();f.add_child(visitor);f.farm_visitor=visitor
 visitor.setup(CHAPTERS[i].person,preload("res://CharacterArt.gd").walk(CHAPTERS[i].person))
 visitor.position=f.get_node("FarmDog").safe_point(f.farmhouse.DOOR_POSITION+Vector2(180,100));visitor.z_index=5;visitor.face_player(f.player.position)
 offer(f,i);return true
static func ending(f) -> void:
 if not f.interior_progress.get("story",{}).get("won",false): return
 var step:int=clampi(int(state(f).get("ending_step",0)),0,2)
 var people=["Akira","Haruka","Seira"]
 var lines=["The village entrusts the farm to you. Akira places the agreement on the table: permanent stewardship, and a future you can shape.","Haruka adds a fresh page to the family ledger. This time, the handwriting is yours. The old story has become a living one.","Seira waits by the gate. 'Shall we see what grows next?' Tomorrow brings another morning, another harvest, and familiar faces. Thank you for playing Tea Blossom Hills."]
 var c=f.make_modal(people[step],true);f.dialogue_text.text=lines[step]
 c.add_child(f.make_button("Continue" if step<2 else "Continue farm life",ending_advance.bind(f,step)))
 c.add_child(f.make_button("Read the rest later",f.close_dialogue))
static func ending_advance(f,step:int) -> void:
 if not f.interior_progress.get("story",{}).get("won",false) or int(state(f).get("ending_step",0))!=step: return
 if step<2: state(f).ending_step=step+1;f.save_game(false);ending(f);return
 state(f).ending_seen=true;state(f).ending_step=0;f.save_game(false);f.close_dialogue()
 preload("res://EverydayLife.gd").remember(f,"A farm for the future","The village entrusted the family farm to you. Your life here continues.")
