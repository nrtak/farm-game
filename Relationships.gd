extends RefCounted

const STORIES={

 "Seira":["I want to bring seeds from other regions to our little shop.","I tried growing something unfamiliar. Some failed, but one flower survived.","I've decided to make a seed exchange here. I can explore without leaving everything I love."],

 "Aya":["At the clinic, I still worry I'll say the wrong thing to someone frightened.","Today I helped a nervous patient feel safe. Listening mattered more than perfect words.","I want to train further and bring what I learn back to this village."],

 "Hana":["I've been sketching brighter rooms for the inn. Would guests like them?","Mother let me try my design in one room. I kept her favorite window seat.","The first guest left a lovely note. This place can hold both our ideas."],

 "Mika":["I want our tea farm to thrive without losing what Sachiko taught me.","My new tea blend needs work. Sachiko helped me taste what was missing.","We made a blend together. Tradition can be the beginning of something new."],

 "Shohei":["I want to make tools that are easier on tired hands.","My first handle cracked. Gen helped me see where I'd rushed.","The new tool works. I'd like to keep making things that make people's days easier."],

 "Yuta":["I act confident, but I worry about letting the crew down.","We practiced a difficult rescue today. Asking for help made us stronger.","I'm organizing safety lessons for the school. Being dependable starts with little things."],

 "Ken":["Masao thinks I should plan ahead. I don't want to lose the freedom of the sea.","I helped mend the older nets today. There are stories in every knot.","I'd like to teach careful fishing to visitors. Looking after this coast feels like a future I can choose."],

 "Hiro":["I keep notes on the mountain plants. Few people ever see them.","I found a trail that needs protecting. I'd like people to enjoy it gently.","My nature guide is nearly ready. Sharing a place can be another way to care for it."]}

const COLORS=["8a8790","a895c4","729fc4","78aa7a","dfb45e","dc8b62","d55578"]

static func state(f,person:String)->Dictionary:

 if not f.interior_progress.get("relationships") is Dictionary:f.interior_progress.relationships={}

 var all:Dictionary=f.interior_progress.relationships

 if not all.get(person) is Dictionary:all[person]={}

 var s:Dictionary=all[person]

 s.affection=clampi(int(s.get("affection",0)),0,100)

 s.status=str(s.get("status","friends"));s.chapter=clampi(int(s.get("chapter",0)),0,3)

 return s

static func stage(f,person:String)->String:

 var s=state(f,person)

 if s.status=="married":return "Married"

 if s.status=="engaged":return "Engaged"

 if s.status=="dating":return "Devoted" if s.affection>=70 else "Dating"

 if s.status=="interested":return "Growing closer"

 return "Close friend" if int(f.friendship.get(person,0))>=40 else "Getting acquainted"

static func color(f,person:String)->Color:

 var s=state(f,person)

 return Color(COLORS[0 if s.status=="friends" else mini(6,1+int(s.affection/17))])

static func available(f,person:String)->bool:

 for other in f.interior_progress.get("relationships",{}):

  if other!=person and state(f,other).status in ["dating","engaged","married"]:return false

 return true

static func panel(f,person:String):

 return load("res://EverydayLife.gd").panel(f,person+" · "+stage(f,person),"Friendship %d / 100 · Romantic affection %d / 100" % [int(f.friendship.get(person,0)),state(f,person).affection])

static func menu(f,person:String):

 if not f.Cast.is_love_interest(person,f.character_choice):return

 var s=state(f,person);var c=panel(f,person)

 f.dialogue_text.text+="\n"+hint(f,person)

 if s.chapter<3 and int(f.friendship.get(person,0))>=10+s.chapter*20:c.add_child(f.make_button("Spend a moment together",scene.bind(f,person)))

 if s.status=="friends" and int(f.friendship.get(person,0))>=20 and available(f,person):c.add_child(f.make_button("Express romantic interest",confirm.bind(f,person,"interested")))

 if s.status=="interested" and s.affection>=25 and s.chapter>=1 and available(f,person):c.add_child(f.make_button("Ask to become a couple",confirm.bind(f,person,"dating")))

 if s.status=="dating" and s.affection>=80 and s.chapter==3 and available(f,person):c.add_child(f.make_button("Discuss getting engaged",confirm.bind(f,person,"engaged")))

 if s.status=="engaged":c.add_child(f.make_button("Plan our wedding",confirm.bind(f,person,"married")))

 if int(f.friendship.get(person,0))>=20:

  for outing in ["Tea","Beach walk","Shrine garden"]:c.add_child(f.make_button(outing,date.bind(f,person,outing)))

 c.add_child(f.make_button("Back",f.close_dialogue))

static func hint(f,person:String)->String:

 var s=state(f,person)

 if s.chapter<3:return "Another personal conversation opens at %d friendship. Talk when you have a quiet moment." % (10+s.chapter*20)

 return "You've shared their personal story. Outings deepen romance only after you express interest."

static func confirm(f,person:String,status:String):

 var s=state(f,person)

 var allowed=(status=="interested" and s.status=="friends" and int(f.friendship.get(person,0))>=20) or (status=="dating" and s.status=="interested" and s.affection>=25 and s.chapter>=1) or (status=="engaged" and s.status=="dating" and s.affection>=80 and s.chapter==3) or (status=="married" and s.status=="engaged")

 if not allowed or not available(f,person) or not f.Cast.is_love_interest(person,f.character_choice):return

 var c=panel(f,person)

 f.dialogue_text.text={"interested":"I'd like to explore something more than friendship, if you would too.","dating":"Would you like us to be a couple?","engaged":"I'd like to build a future together. Shall we get engaged?","married":"Shall we exchange our vows at the shrine? We will both keep our work and friendships."}[status]

 c.add_child(f.make_button("Yes",commit.bind(f,person,status)));c.add_child(f.make_button("Not yet",menu.bind(f,person)))

static func commit(f,person:String,status:String):

 # Revalidate prerequisites after the confirmation, before touching the save.

 var s=state(f,person)

 var previous={"interested":"friends","dating":"interested","engaged":"dating","married":"engaged"}

 if not f.Cast.is_love_interest(person,f.character_choice) or not available(f,person) or s.status!=previous.get(status,""):return

 if status=="interested" and int(f.friendship.get(person,0))<20:return
 if status=="dating" and (s.affection<25 or s.chapter<1):return
 if status=="engaged" and (s.affection<80 or s.chapter<3):return
 f.close_dialogue()
 s.status=status

 load("res://EverydayLife.gd").remember(f,stage(f,person)+" with "+person,"You chose this next step together.")

 var c=panel(f,person);f.dialogue_text.text="Yes. Let's see where this takes us, together." if status!="married" else "Beneath the shrine trees, you exchange vows with your neighbors beside you. Tomorrow brings familiar work, and a shared future."

 c.add_child(f.make_button("Close",f.close_dialogue))

 if status=="married":
  var moment=load("res://RelationshipMoment.gd").new()
  moment.begin(f,person,"Wedding","With our neighbors beside us, we promise to build a life together.")

static func scene(f,person:String):

 var s=state(f,person)

 if not STORIES.has(person) or s.chapter>=3 or int(f.friendship.get(person,0))<10+s.chapter*20:return

 var text:String=STORIES[person][s.chapter];var c=panel(f,person);f.dialogue_text.text=text

 for response in ["I'd love to hear more.","I'm glad you shared that with me."]:c.add_child(f.make_button(response,finish_scene.bind(f,person,int(s.chapter))))

 c.add_child(f.make_button("Let's talk later",f.close_dialogue))

static func finish_scene(f,person:String,chapter:int):

 var s=state(f,person)

 if not f.Cast.is_love_interest(person,f.character_choice) or not STORIES.has(person):return
 if chapter<0 or chapter>=STORIES[person].size() or s.chapter!=chapter:return
 if int(f.friendship.get(person,0))<10+chapter*20:return
 f.close_dialogue()

 s.chapter+=1

 if s.status!="friends":s.affection=mini(100,s.affection+8)

 load("res://EverydayLife.gd").remember(f,person+" · Personal story "+str(s.chapter),STORIES[person][chapter]);f.save_game(false);f.close_dialogue()

static func date(f,person:String,outing:String):

 if outing not in ["Tea","Beach walk","Shrine garden"]:return

 if not f.Cast.is_love_interest(person,f.character_choice) or int(f.friendship.get(person,0))<20:return

 var e=load("res://EverydayLife.gd").state(f);var s=state(f,person)

 if f.day-int(e.dates.get(person,-100))<7:f.say("Let's plan another outing next week.");return

 if outing!="Tea" and f.is_rainy_day():f.say("Let's choose tea indoors while it's raining.");return
 f.close_dialogue()

 e.dates[person]=f.day;e.outings[person]=int(e.outings.get(person,0))+1;f.friendship[person]=mini(100,int(f.friendship[person])+2)

 if s.status!="friends" and available(f,person):s.affection=mini(100,s.affection+10)

 var words={"Tea":"You share tea by the window and trade stories about your week.","Beach walk":"You walk along the shore together, stopping to watch the tide pools.","Shrine garden":"You sit beneath the shrine trees and listen to the waterfall."}

 load("res://EverydayLife.gd").remember(f,outing+" with "+person,words[outing]);f.save_game(false)

 var c=panel(f,person);f.dialogue_text.text=words[outing]+("\nI'm happy we're making time for each other." if s.status!="friends" else "\nIt's good to have a friend to share this with.");c.add_child(f.make_button("Close",f.close_dialogue))
 var moment=load("res://RelationshipMoment.gd").new()
 moment.begin(f,person,outing,words[outing]+("\nI'm happy we're making time for each other." if s.status!="friends" else "\nIt's good to have a friend to share this with."))


static func greeting(f,person:String)->String:
 if not f.Cast.is_love_interest(person,f.character_choice):return ""
 var bond=state(f,person)
 if bond.status=="married":return "I'm glad we have these little moments together. Tell me about your day."
 if bond.status=="engaged":return "Every time I see you, our future feels a little closer."
 if bond.status=="dating":return "I've been looking forward to seeing you. How are things on the farm?"
 if bond.status=="interested":return "It's good to see you. Shall we find a quiet moment together soon?"
 return ""

static func maybe_visit(f)->bool:
 if f.clock_minutes>=600 or f.is_rainy_day():return false
 var week=int((f.day-1)/7)
 if int(f.interior_progress.get("partner_visit_week",-1))==week:return false
 for person in f.interior_progress.get("relationships",{}):
  if not f.Cast.is_love_interest(person,f.character_choice):continue
  if state(f,person).status not in ["dating","engaged","married"]:continue
  f.interior_progress.partner_visit_week=week
  var npc=load("res://Npc.gd").new();f.add_child(npc);f.farm_visitor=npc
  npc.setup(person,load("res://CharacterArt.gd").walk(person))
  npc.position=f.get_node("FarmDog").safe_point(f.farmhouse.DOOR_POSITION+Vector2(180,100))
  npc.z_index=5;npc.face_player(f.player.position)
  var c=f.make_modal(person,true)
  f.dialogue_text.text=greeting(f,person)+" I stopped by before heading back to my usual day."
  c.add_child(f.make_button("Enjoy a moment together",f.close_dialogue))
  f.save_game(false);return true
 return false
