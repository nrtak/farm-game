extends RefCounted
const LIKES := {"Nao":"Tea packets","Sota":"Turnip","Rin":"Strawberry","Jun":"Milk","Seira":"Strawberry","Shohei":"Copper","Akira":"Tea packets","Taro":"Potato","Aya":"Tea packets","Hana":"Milk","Mika":"Tea leaves","Yuta":"Egg","Ken":"Sardine","Hiro":"Turnip","Keiko":"Potato","Kenji":"Tea packets","Gen":"Iron","Yumi":"Tea packets","Jiro":"Milk","Naomi":"Egg","Sachiko":"Tea leaves","Kenta":"Turnip","Haruka":"Tea packets","Rei":"Strawberry","Masao":"Mackerel","Emi":"Potato","Ren":"Tea packets","Chanel":"Milk","David":"Egg","Renji":"Copper","Midori":"Turnip"}
static func state(f) -> Dictionary:
	if not f.interior_progress.get("village_depth") is Dictionary: f.interior_progress.village_depth={}
	var s:Dictionary=f.interior_progress.village_depth
	for key in ["gifts","friend_scenes","keepsakes"]:
		if not s.get(key) is Dictionary: s[key]={}
	return s
static func conversation(f,person:String) -> void:
	var greeting=load("res://Relationships.gd").greeting(f,person)
	if greeting!="":f.dialogue_lines.append(greeting)
	f.dialogue_lines.append(preload("res://ResidentRoutine.gd").words(f,person))
	if LIKES.has(person):
		preload("res://EverydayLife.gd").state(f).learned_gifts[person]=LIKES[person]
		f.dialogue_lines.append("A little %s always makes my day." % LIKES[person].to_lower())
	var s:=state(f)
	if int(f.friendship.get(person,0))>=8 and not s.friend_scenes.has(person):
		s.friend_scenes[person]=true
		var memories:Dictionary={"Akira":"I kept the letter your family sent when they first came here. I'd like you to see it one day.","Taro":"My rounds are quieter when I know the neighbors are looking out for one another. You've helped with that.","Keiko":"I used to worry no one would plant those fields again. I saved a space on the shelf for your harvest.","Gen":"Pull up a stool. I'll show you the first hammer I made. The handle's crooked, but I kept it.","Yumi":"Your family always sat beside the window. I still put flowers on that table.","Haruka":"I found your farm on an old village map. There are stories in those field names.","Rei":"The shrine is quiet now. Stay a moment; you don't have to be useful every minute.","Masao":"My first net was a hopeless tangle. Sit down and I'll teach you the knot that finally held.","Emi":"I've put an extra bowl out. Mountain walks are better when someone expects you home.","Kenta":"This offcut came from your farm. Good timber deserves another life.","David":"I know every doorstep here, but yours is one where I can stop for a conversation.","Midori":"I saved some space in my garden for wildflowers. We can watch what comes up together."}
		f.dialogue_lines.append(memories.get(person,"I'm glad you stayed in our village. These little conversations have become part of my day. Come sit with me whenever you need a break."))
	# Existing paired scenes are reachable in the noticeboard; this adds a short contextual exchange.
	var pairs:Dictionary={"Hana":["Yumi","We were choosing flowers for the inn window."],"Shohei":["Gen","We were comparing the balance of the new tools."],"Mika":["Sachiko","We were sorting today's tender leaves together."]}
	if pairs.has(person):
		for n in f.polish.area_node().get_children():
			if n.get_script()==preload("res://Npc.gd") and n.first_name==pairs[person][0] and n.is_visible_in_tree() and n.global_position.distance_to(f.talking_npc.global_position)<250:
				f.dialogue_lines.append(pairs[person][1]);break
static func gifts(f,person:String) -> void:
	f.close_dialogue()
	var c=f.make_modal("A gift for "+person)
	f.dialogue_text.text="Choose one item from your bag. One gift per person each day."
	var scroll:=ScrollContainer.new();scroll.custom_minimum_size.y=100;scroll.size_flags_vertical=Control.SIZE_EXPAND_FILL;c.add_child(scroll)
	var list:=GridContainer.new();list.columns=maxi(2,int((f.get_viewport_rect().size.x-100)/155));list.size_flags_horizontal=Control.SIZE_EXPAND_FILL;scroll.add_child(list)
	var items:Array=[]
	for inventory in [f.produce,f.fish_basket,f.ore_basket,f.BarnLife.state(f).products]:
		items.append_array(inventory.keys())
	items.append_array(["Tea leaves","Tea packets"])
	for item in items:
		if list.has_node(item.replace(" ","_")) or f.carried_count(item)<=0: continue
		var b=f.make_button("Give "+item,confirm_gift.bind(f,person,item));b.name=item.replace(" ","_");list.add_child(b);preload("res://MenuTiles.gd").tile(b)
	if list.get_child_count()==0: f.dialogue_text.text="Your bag has no gifts yet. Bring produce, fish, tea or animal products."
	c.add_child(f.make_button("Back",f.close_dialogue))
static func confirm_gift(f,person:String,item:String) -> void:
	var c=f.make_modal("Give to "+person+"?")
	f.dialogue_text.text="Give one %s from your bag? You have %d. You can give one gift per person each day." % [item,f.carried_count(item)]
	c.add_child(f.make_button("Give "+item,give.bind(f,person,item)))
	c.add_child(f.make_button("Back to gifts",gifts.bind(f,person)))
	c.add_child(f.make_button("Cancel",f.close_dialogue))
static func give(f,person:String,item:String) -> void:
	var s:=state(f)
	if int(s.gifts.get(person,-1))==f.day: f.dialogue_text.text="Thank you! One gift is plenty for today.";return
	if not LIKES.has(person) or f.carried_count(item)<1: return
	f.change_carried(item,-1);s.gifts[person]=f.day
	var favorite:bool=LIKES[person]==item
	f.friendship[person]=mini(100,int(f.friendship.get(person,0))+(3 if favorite else 1))
	var birthday_bonus:bool=preload("res://EverydayLife.gd").birthday(f,person)==1+posmod(f.day-1,112)
	if birthday_bonus: f.friendship[person]=mini(100,int(f.friendship[person])+2)
	f.save_game(false)
	f.dialogue_text.text=("My favorite! You remembered. Friendship +3." if favorite else "Thank you for thinking of me. Friendship +1.")+(" Birthday bonus +2!" if birthday_bonus else "")
static func waterfall(f) -> void:
	var s:=state(f)
	var stage:int=int(s.get("falls",0))
	if stage==0:
		s.falls=1
		var c=f.make_modal("Moonveil Falls")
		f.dialogue_text.text="Mist curls across the pool. A light glimmers behind the falling water. For a moment, a quiet voice seems to call your name.\n\nThe water settles. Perhaps someone in the village knows this place."
		c.add_child(f.make_button("Listen to the water",f.close_dialogue));f.save_game(false)
	elif stage==1:
		var c=f.make_modal("A voice in the mist")
		f.dialogue_text.text="I am the keeper of this spring. Will you share one packet of local tea with the waters? Return whenever you wish; there is no deadline."
		c.add_child(f.make_button("Accept · bring one Tea packets",accept_falls.bind(f)))
		c.add_child(f.make_button("Not today",f.close_dialogue))
	elif stage==2:
		var c=f.make_modal("The spring's request")
		f.dialogue_text.text="The keeper waits quietly. Offer one packet of tea from your bag to complete the request."
		c.add_child(f.make_button("Offer Tea packets",finish_falls.bind(f)));c.add_child(f.make_button("Leave quietly",f.close_dialogue))
	else:
		var c=f.make_modal("The spring keeper")
		f.dialogue_text.text="The spring remembers your kindness. Its glow is a little warmer when you visit."
		c.add_child(f.make_button("Listen to the seasons",preload("res://EverydayLife.gd").falls_seasons.bind(f)))
		c.add_child(f.make_button("Rest beside the falls",f.close_dialogue))
static func accept_falls(f) -> void:
	state(f).falls=2;f.save_game(false);f.close_dialogue();f.say("Request accepted: bring one packet of tea to Moonveil Falls.")
static func finish_falls(f) -> void:
	if not preload("res://ShrineFalls.gd").nearby(f) or int(state(f).get("falls",0))!=2: return
	if f.packed_tea<1: f.dialogue_text.text="Bring one packet of tea. You can pack two handfuls of leaves at the tea shed.";return
	f.packed_tea-=1;state(f).falls=3;state(f).keepsakes["Spring keeper's charm"]=true
	f.save_game(false);f.dialogue_text.text="The tea dissolves into a ring of light. 'May your home always welcome life.' A small spring charm rests on the dry shore. It has been added to your keepsakes."
static func collection(f) -> void:
	f.close_dialogue();var c=f.make_modal("Village life & keepsakes")
	var s:=state(f)
	var text:String=preload("res://Stewardship.gd").progress(f)
	text+="\n\nKeepsakes: "+(", ".join(s.keepsakes.keys()) if not s.keepsakes.is_empty() else "None yet. Join festival activities or explore Moonveil Falls.")
	if int(s.get("falls",0))==2: text+="\nSpring keeper: bring one packet of tea to Moonveil Falls."
	if f.interior_progress.get("story",{}).get("won",false):
		text+="\n\nLife after the vote: harvest 100 crops, befriend 10 residents (20 points), and complete eight festival activities."
		var friends:=0
		for points in f.friendship.values():
			if int(points)>=20: friends+=1
		text+="\nHarvests %d/100 · Friends %d/10 · Activities %d/8" % [f.harvests,friends,f.interior_progress.get("festival_activities",{}).size()]
		if f.harvests>=100 and friends>=10 and f.interior_progress.get("festival_activities",{}).size()>=8:
			s.keepsakes["Beloved village steward"]=true;f.save_game(false);text+="\nEarned: Beloved village steward. Your farm life continues!"
	f.dialogue_text.text=text
	preload("res://PlayerComfort.gd").scroll_text(f,c)
	if f.inside_house and int(f.interior_progress.get("home",0))>=2 and s.get("festival_recipe",false): c.add_child(f.make_button("Festival milk tea recipe",preload("res://RecipeBook.gd").detail.bind(f,"tea")))
	c.add_child(f.make_button("Close",f.close_dialogue))
static func festival_reward(f) -> void:
	if not f.scheduled_gathering: return
	state(f).keepsakes[f.current_festival.name+" ribbon"]=true
	state(f).festival_recipe=true
static func cook_recipe(f) -> void:
	if not f.inside_house or int(f.interior_progress.get("home",0))<2: return
	if not state(f).get("festival_recipe",false) or f.packed_tea<1 or f.carried_count("Milk")<1: f.dialogue_text.text="Festival milk tea needs one tea packet and one milk.";return
	if f.health>=100: f.dialogue_text.text="You're already rested. Save your ingredients for later.";return
	f.packed_tea-=1;f.change_carried("Milk",-1);f.health=minf(100,f.health+30);f.save_game(false);preload("res://EverydayLife.gd").cooking_moment(f,"Festival milk tea","One tea packet and one milk. Health +30.")
