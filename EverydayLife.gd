extends RefCounted
static func state(f) -> Dictionary:
 if not f.interior_progress.get("everyday") is Dictionary: f.interior_progress.everyday={}
 var s:Dictionary=f.interior_progress.everyday
 for key in ["protected","learned_gifts","dates","birthdays","memories","outings"]:
  if not s.get(key) is Dictionary: s[key]={}
 return s
static func panel(f,title:String,text:String):
 f.close_dialogue();var c=f.make_modal(title)
 f.dialogue_text.text=text;f.dialogue_text.size_flags_vertical=Control.SIZE_SHRINK_BEGIN
 f.dialogue_panel.get_child(0).offset_top=-minf(460,f.get_viewport_rect().size.y-28)
 return c
static func price(f,item:String) -> int:
 if f.CROPS.has(item): return f.CROPS[item].sale
 if f.FISH.has(item): return f.FISH[item]
 if f.ORE.has(item): return f.ORE[item]
 if f.BarnLife.PRICES.has(item): return f.BarnLife.PRICES[item]
 return 45 if item=="Tea packets" else 0
static func carried(f) -> Dictionary:
 var items:Dictionary={}
 for bag in [f.produce,f.fish_basket,f.ore_basket,f.BarnLife.state(f).products]:
  for key in bag:
   if int(bag[key])>0: items[key]=int(bag[key])
 if f.tea_leaves>0: items["Tea leaves"]=f.tea_leaves
 if f.packed_tea>0: items["Tea packets"]=f.packed_tea
 return items
static func category(f,item:String) -> String:
 if f.CROPS.has(item) or item in ["Tea leaves","Tea packets"]: return "Crops"
 if f.FISH.has(item): return "Fish"
 if f.ORE.has(item): return "Materials"
 return "Animal products"
static func bag(f,filter:String="All") -> void:
 var c=panel(f,"Backpack · %d / %d" % [f.backpack_count(),f.BACKPACK_SIZES[f.backpack_level]],"Tap an item for uses, price and shipping protection.")
 var tabs:=HBoxContainer.new();c.add_child(tabs)
 for title in ["All","Crops","Fish","Materials","Animal products"]:
  tabs.add_child(f.make_button(title,bag.bind(f,title)))
 var grid=preload("res://MenuTiles.gd").grid(f,c)
 for item in carried(f):
  if filter!="All" and category(f,item)!=filter: continue
  var b=f.make_button("%s ×%d%s" % [item,f.carried_count(item)," · Keep" if state(f).protected.get(item,false) else ""],details.bind(f,item))
  grid.add_child(b);preload("res://MenuTiles.gd").tile(b)
 var actions:=HBoxContainer.new();c.add_child(actions)
 actions.add_child(f.make_button("Requests",VolunteerRequests.journal.bind(f)))
 actions.add_child(f.make_button("Farm journal",journal.bind(f)))
 actions.add_child(f.make_button("Change farmer",f.backpack_change_farmer))
 actions.add_child(f.make_button("Back",f.close_dialogue))
static func details(f,item:String) -> void:
 var uses:String="Gift, store or ship."
 if item=="Tea leaves": uses="Take two leaves to the tea processing shed to make a tea packet."
 if f.ORE.has(item): uses="Keep some for tool and building upgrades, or ship for money."
 if item in ["Milk","Egg","Potato"]: uses="Useful in cooking; also suitable for gifts and shipping."
 var c=panel(f,item,"In bag: %d · Sale price: ¥%d each.\n%s" % [f.carried_count(item),price(f,item),uses])
 c.add_child(f.make_button("Allow shipping" if state(f).protected.get(item,false) else "Protect from shipping",protect.bind(f,item)))
 if f.inside_house:
  var amount:=SpinBox.new();amount.min_value=1;amount.max_value=maxi(1,f.carried_count(item));amount.custom_minimum_size.y=48;c.add_child(amount)
  c.add_child(f.make_button("Move quantity to storage",func(): f.transfer_storage(item,int(amount.value),true);details(f,item)))
 if f.location=="farm" and not f.inside_house and f.player.position.distance_to(f.SHIPPING_BOX)<=220 and price(f,item)>0:
  var amount:=SpinBox.new();amount.min_value=1;amount.max_value=maxi(1,f.carried_count(item));amount.custom_minimum_size.y=48;c.add_child(amount)
  var ship=f.make_button("Ship selected quantity",func(): ship_quantity(f,item,int(amount.value)))
  ship.disabled=state(f).protected.get(item,false) or f.carried_count(item)==0;c.add_child(ship)
 c.add_child(f.make_button("Back to bag",bag.bind(f,"All")))
static func protect(f,item:String) -> void:
 state(f).protected[item]=not state(f).protected.get(item,false);f.save_game(false);details(f,item)
static func preview_animal(f,species:String) -> void:
 var info:Dictionary=f.BarnLife.SPECIES[species]
 var c=panel(f,"Meet your "+species,"¥%d · Produces %s after %d fed night(s).\nNeeds one feed each day. Stalls free: %d.\nChoose a name before confirming." % [info.price,info.product,info.nights,f.BarnLife.capacity(f)-f.BarnLife.state(f).animals.size()])
 var name_field:=LineEdit.new();name_field.max_length=16;name_field.text=species;name_field.custom_minimum_size.y=48;c.add_child(name_field)
 var b=f.make_button("Buy "+species,func():
  var chosen_name:String=name_field.text.strip_edges()
  var count:int=f.BarnLife.state(f).animals.size()
  f.BarnLife.purchase(f,species)
  if f.BarnLife.state(f).animals.size()!=count+1: return
  var animal:Dictionary=f.BarnLife.state(f).animals[count]
  animal.name=chosen_name if not chosen_name.is_empty() else species
  animal.personality=["Curious","Calm","Playful"][count%3]
  animal.arrived=f.day;f.save_game(false)
  var result=panel(f,"Welcome, "+animal.name,"Your %s has arrived in stall %d. Visit your barn to say hello!" % [species,count+1])
  var scene=preload("res://EverydayMoment.gd").new();scene.setup(species);result.add_child(scene)
  remember(f,"Welcome "+animal.name,"A "+species.to_lower()+" joined the farm.")
  result.add_child(f.make_button("Back to ranch",f.BarnLife.open_manager.bind(f))))
 b.disabled=f.coins<int(info.price) or f.BarnLife.state(f).animals.size()>=f.BarnLife.capacity(f)
 c.add_child(b);c.add_child(f.make_button("Cancel",f.BarnLife.open_manager.bind(f)))
static func care_board(f) -> void:
 var data:Dictionary=f.BarnLife.state(f)
 var c=panel(f,"Daily animal care","Feed remaining: %d · About %d days for your current herd.\n%s" % [data.feed,int(data.feed/maxi(1,data.animals.size())),"Buy more feed at the town ranch soon." if data.feed<data.animals.size()*2 else "Pasture hours: 9 AM–5 PM in clear weather. Animals return to the barn at other times."])
 var grid=preload("res://MenuTiles.gd").grid(f,c)
 for i in range(data.animals.size()):
  var a:Dictionary=data.animals[i]
  var b=f.make_button("%s · %s\n%s · %s\nReady: %d" % [a.get("name",a.species),a.species,"Fed" if a.fed==f.day else "Needs feed","Petted" if a.petted==f.day else "Needs petting",a.ready],animal_record.bind(f,i))
  grid.add_child(b);preload("res://MenuTiles.gd").tile(b)
 c.add_child(f.make_button("Pasture · "+("Enabled" if data.get("pasture",false) else "Disabled"),preload("res://AnimalPasture.gd").toggle.bind(f)))
 c.add_child(f.make_button("Back",f.close_dialogue))
static func animal_record(f,index:int) -> void:
 var a:Dictionary=f.BarnLife.state(f).animals[index]
 var c=panel(f,a.get("name",a.species),"%s · Affection %d\nLast veterinary visit: %s\nFed today: %s · Petted today: %s" % [a.get("personality","Calm"),a.affection,str(a.vet_day) if a.has("vet_day") else "None yet","Yes" if a.fed==f.day else "No","Yes" if a.petted==f.day else "No"])
 if f.location=="shop" and f.shop_name=="Barn": c.add_child(f.make_button("Care for animal",f.BarnLife.open_animal.bind(f,index)))
 c.add_child(f.make_button("Back to care board",care_board.bind(f)))
static func remember(f,title:String,description:String) -> void:
 var memory:Dictionary={"day":f.day,"text":description}
 if DisplayServer.get_name()!="headless":
  var folder:String=f.SAVE_FILE.get_basename()+"-photos"
  if DirAccess.make_dir_recursive_absolute(folder)==OK:
   var shot:Image=f.get_viewport().get_texture().get_image()
   if shot!=null and not shot.is_empty():
    shot.resize(640,maxi(1,int(640.0*shot.get_height()/shot.get_width())))
    var path:String=folder+"/"+title.sha256_text().substr(0,20)+".png"
    if shot.save_png(path)==OK: memory.photo=path
 state(f).memories[title]=memory;f.save_game(false)
static func journal(f) -> void:
 var c=panel(f,"Farm journal","Your animals, neighbors and farm memories.")
 var scroll:=ScrollContainer.new();scroll.custom_minimum_size.y=160;scroll.size_flags_vertical=Control.SIZE_EXPAND_FILL;c.add_child(scroll)
 var list:=VBoxContainer.new();list.size_flags_horizontal=Control.SIZE_EXPAND_FILL;scroll.add_child(list)
 for entry in [["Recipe book",preload("res://RecipeBook.gd").book.bind(f)],["Our village story",preload("res://StoryArc.gd").journal.bind(f)],["Farm dog",preload("res://FarmDog.gd").menu.bind(f)],["Daily animal care",care_board.bind(f)],["Neighbors & gifts",neighbors.bind(f)],["Morning report",morning.bind(f)],["Weather television",forecast.bind(f)],["Farm memories",album.bind(f)],["Seed calendar",seed_calendar.bind(f)],["Town map",town_map.bind(f)],["Home decoration",decorate.bind(f)]]:
  list.add_child(f.make_button(entry[0],entry[1]))
 c.add_child(f.make_button("Back",f.close_dialogue))
static func forecast(f) -> void:
 preload("res://HomeWeather.gd").show_forecast(f,true)
static func receipt(f) -> void:
 var lines:Array=[];var total:=0
 var queues:Array=[f.shipping_queue,f.fish_shipping,f.ore_shipping,f.BarnLife.state(f).shipping,{"Tea packets":f.tea_shipping}]
 for queue in queues:
  for item in queue:
   var count:int=queue[item]
   if count>0:
    var value:int=count*price(f,item);total+=value;lines.append("%s ×%d · ¥%d" % [item,count,value])
 if total>0: state(f).receipt={"day":f.day,"total":total,"lines":lines}
static func morning(f) -> void:
 var receipt_data:Dictionary=state(f).get("receipt",{})
 var text:String=f.calendar_text()+"\nToday: "+preload("res://WeatherLife.gd").forecast(f.day)
 if int(receipt_data.get("day",-1))==f.day: text+="\nShipping paid: ¥%d\n%s" % [receipt_data.total,"\n".join(receipt_data.lines)]
 var event:Dictionary=SeasonalFestivals.today(f.day)
 if not event.is_empty(): text+="\nFestival today: "+event.name
 var data:Dictionary=f.BarnLife.state(f)
 if data.feed<data.animals.size()*2: text+="\nFeed is running low. Visit the ranch."
 if f.interior_progress.has("construction"): text+="\nConstruction is underway."
 var c=panel(f,"Good morning",text);preload("res://PlayerComfort.gd").scroll_text(f,c)
 c.add_child(f.make_button("Start the day",f.close_dialogue))
static func seed_calendar(f) -> void:
 var text:="Outdoor crops grow in spring, summer and autumn and need daily watering. Winter soil is too cold. The greenhouse grows every available seed variety all year.\n"
 for crop in f.CROPS: text+="\n%s · %d nights · Sale ¥%d" % [crop,f.CROPS[crop].days,f.CROPS[crop].sale]
 var c=panel(f,"Seed calendar",text);c.add_child(f.make_button("Back",journal.bind(f)))
static func birthday(f,person:String) -> int:
 return 1+posmod(f.friendship.keys().find(person)*17+6,112)
static func neighbors(f) -> void:
 var c=panel(f,"Neighbors","Hearts mark eligible romance partners. Learn favorite gifts by talking to people.")
 var grid=preload("res://MenuTiles.gd").grid(f,c)
 for person in f.friendship:
  grid.add_child(f.make_button(person,relationship.bind(f,person)))
 c.add_child(f.make_button("Back",journal.bind(f)))
static func relationship(f,person:String) -> void:
 var favorite:String=state(f).learned_gifts.get(person,"Not learned yet")
 var points:int=f.friendship.get(person,0)
 var c=panel(f,person,"Friendship: %d / 100\nFavorite gift: %s\nBirthday: %s\n%s" % [points,favorite,birthday_label(f,person),"Romance eligible · %d outings together" % int(state(f).outings.get(person,0)) if f.Cast.is_love_interest(person,f.character_choice) else "Friendship"])
 c.add_child(f.make_button("Back",neighbors.bind(f)))
static func album(f) -> void:
 var c=panel(f,"Farm memories","Tap a memory to open its photograph and story.")
 var grid=preload("res://MenuTiles.gd").grid(f,c)
 for title in state(f).memories:
  var memory:Dictionary=state(f).memories[title]
  grid.add_child(f.make_button("%s · Day %d" % [title,memory.day],memory_card.bind(f,title)))
 if state(f).memories.is_empty(): f.dialogue_text.text="Your farm's memories will appear here as you reach milestones."
 c.add_child(f.make_button("Back",journal.bind(f)))
static func memory_card(f,title:String) -> void:
 var memory:Dictionary=state(f).memories[title]
 var c=panel(f,title,"Day %d · %s" % [memory.day,memory.text])
 var path:String=memory.get("photo","")
 if path!="" and FileAccess.file_exists(path):
  var photo:=TextureRect.new();photo.texture=ImageTexture.create_from_image(Image.load_from_file(path));photo.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;photo.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;photo.custom_minimum_size.y=160;photo.size_flags_vertical=Control.SIZE_EXPAND_FILL;c.add_child(photo)
 c.add_child(f.make_button("Back to memories",album.bind(f)))
static func cooking_moment(f,title:String,text:String) -> void:
 var c=panel(f,title,text)
 var moment=preload("res://EverydayMoment.gd").new();moment.setup();c.add_child(moment)
 c.add_child(f.make_button("Enjoy your meal",f.close_dialogue))
static func shops(f) -> void:
 var c=panel(f,"Town shops","Walk through each shop doorway to enter. Ranch: southwest town. Vet: northeast, near the tea-country road.")
 var grid=preload("res://MenuTiles.gd").grid(f,c)
 for building in f.town.BUILDINGS:
  var hours:Vector2=f.shop_opening_hours().get(building.name,Vector2(0,1440))
  grid.add_child(f.make_button("%s\n%d:00–%d:00" % [building.name,int(hours.x/60),int(hours.y/60)],func(): f.dialogue_text.text="%s is in town. Follow its doorway sign." % building.name))
 c.add_child(f.make_button("Back",journal.bind(f)))
static func unstuck(f) -> void:
 f.close_dialogue()
 var origin:Vector2=f.player.position
 for radius in range(40,321,20):
  for index in range(24):
   var candidate:Vector2=origin+Vector2.from_angle(index*TAU/24)*radius
   if f.polish.clear_position(candidate):
    f.player.position=candidate;f.player.velocity=Vector2.ZERO;f.polish.path.clear();f.joystick.reset_stick();f.save_game(false);f.say("Moved to nearby clear ground.");return
 f.say("No safe nearby position found. Your location has not changed.")

static func invite(f,person:String) -> void:
 if not f.Cast.is_love_interest(person,f.character_choice) or int(f.friendship.get(person,0))<20: return
 var last:int=state(f).dates.get(person,-100)
 var c=panel(f,"An invitation for "+person,"Would you like to share tea and a walk together? There is no penalty for declining.")
 if f.day-last<7:
  f.dialogue_text.text="Let's plan another outing next week."
 else:
  c.add_child(f.make_button("Invite for tea",date_scene.bind(f,person)))
 c.add_child(f.make_button("Maybe later",f.close_dialogue))
static func date_scene(f,person:String) -> void:
 if not f.Cast.is_love_interest(person,f.character_choice) or int(f.friendship.get(person,0))<20 or f.day-int(state(f).dates.get(person,-100))<7: return
 state(f).dates[person]=f.day;f.friendship[person]=mini(100,int(f.friendship[person])+2)
 state(f).outings[person]=int(state(f).outings.get(person,0))+1
 remember(f,"Tea with "+person,"You shared a quiet afternoon and talked about life in the village.")
 var c=f.make_modal(person,true);f.dialogue_text.text="I'd like that. Let's sit by the window and watch the village go by. I'm glad you asked me."
 c.add_child(f.make_button("Enjoy the moment",f.close_dialogue))
static func decorate(f) -> void:
 var c=panel(f,"Home colors","Choose a bedside rug color. These decorations are free and saved with your farm.")
 for entry in [["Sage","7d9b83"],["Ocean","739ab2"],["Lavender","a98cb5"],["Sunflower","c4aa60"]]:
  c.add_child(f.make_button(entry[0],func(): state(f).home_color=entry[1];f.interior.queue_redraw();f.save_game(false);f.close_dialogue()))
 c.add_child(f.make_button("Back",journal.bind(f)))
static func town_map(f) -> void:
 var c=panel(f,"Town map","Tap a building marker for its name and opening hours. Your position is shown in gold when you are in town.")
 var map:=Control.new();map.custom_minimum_size=Vector2(300,240);map.size_flags_vertical=Control.SIZE_EXPAND_FILL;c.add_child(map)
 map.draw.connect(func():
  var width:float=minf(map.size.x,map.size.y*1.5)
  var rect:=Rect2((map.size.x-width)/2,0,width,width/1.5)
  map.draw_texture_rect(preload("res://assets/map-town-open-v3.png"),rect,false)
  if f.location=="town": map.draw_circle(rect.position+(f.player.position-f.TOWN_ORIGIN)/f.town.SIZE*rect.size,7,Color("ffe497")))
 for building in f.town.BUILDINGS:
  var b=f.make_button(str(f.town.BUILDINGS.find(building)+1),func():
   var hours:Vector2=f.shop_opening_hours().get(building.name,Vector2(0,1440))
   f.dialogue_text.text="%s · %d:00–%d:00" % [building.name,int(hours.x/60),int(hours.y/60)])
  b.custom_minimum_size=Vector2(36,36);b.size=Vector2(36,36);map.add_child(b)
  map.resized.connect(func():
   var width:float=minf(map.size.x,map.size.y*1.5)
   b.position=Vector2((map.size.x-width)/2,0)+building.door/f.town.SIZE*Vector2(width,width/1.5)-Vector2(18,18))
 c.add_child(f.make_button("Shop directory",shops.bind(f)));c.add_child(f.make_button("Back",f.close_dialogue))

static func seed_order(f,crop:String) -> void:
 var c=panel(f,crop+" seeds","Five seeds per pack · ¥%d. Grows in %d watered nights. Outdoor: spring–autumn; greenhouse: all year. Choose how many packs." % [f.CROPS[crop].pack,f.CROPS[crop].days])
 var quantity:=SpinBox.new();quantity.min_value=1;quantity.max_value=20;quantity.custom_minimum_size.y=48;c.add_child(quantity)
 c.add_child(f.make_button("Buy seed packs",func(): f.purchase_crop_seeds(crop,int(quantity.value))))
 c.add_child(f.make_button("Back to store",f.open_service.bind("General Store")))
static func feed_order(f) -> void:
 var c=panel(f,"Feed order","Ten portions per pack · ¥30. Each animal needs one portion daily.")
 var quantity:=SpinBox.new();quantity.min_value=1;quantity.max_value=20;quantity.custom_minimum_size.y=48;c.add_child(quantity)
 c.add_child(f.make_button("Buy feed",func(): f.BarnLife.buy_feed(f,int(quantity.value))))
 c.add_child(f.make_button("Back",f.BarnLife.open_manager.bind(f)))
static func ship_quantity(f,item:String,amount:int) -> void:
 if f.location!="farm" or f.inside_house or f.player.position.distance_to(f.SHIPPING_BOX)>220: return
 if amount<1 or amount>f.carried_count(item) or price(f,item)<=0 or state(f).protected.get(item,false): return
 if f.CROPS.has(item): f.shipping_queue[item]+=amount
 elif f.FISH.has(item): f.fish_shipping[item]+=amount
 elif f.ORE.has(item): f.ore_shipping[item]+=amount
 elif f.BarnLife.PRICES.has(item): f.BarnLife.state(f).shipping[item]+=amount
 elif item=="Tea packets": f.tea_shipping+=amount
 else: return
 f.change_carried(item,-amount);f.save_game(false);details(f,item)
static func morning_hint(f) -> void:
 var text:String="Today: "+preload("res://WeatherLife.gd").forecast(f.day)+". "
 var receipt_data:Dictionary=state(f).get("receipt",{})
 if int(receipt_data.get("day",-1))==f.day: text+="Shipping +¥%d. " % receipt_data.total
 for person in f.friendship:
  if birthday(f,person)==1+posmod(f.day-1,112): text+=person+"'s birthday. "
 var event:Dictionary=SeasonalFestivals.today(f.day)
 if not event.is_empty(): text+=event.name+" today. "
 text+="Details in Farm journal."
 f.say(text)

static func birthday_label(f,person:String) -> String:
 var day_of_year:int=birthday(f,person)-1
 return "%s %d" % [f.SEASONS[int(day_of_year/28)],day_of_year%28+1]
static func falls_seasons(f) -> void:
 var c=panel(f,"The spring keeper","Every season gives the water a different voice. Will you come back and listen in spring, summer, autumn and winter? No offering is needed.")
 c.add_child(f.make_button("Listen to this season",listen_season.bind(f)))
 c.add_child(f.make_button("Another time",f.close_dialogue))
static func listen_season(f) -> void:
 if f.location!="waterfall" or int(preload("res://VillageDepth.gd").state(f).get("falls",0))<3: return
 var s:Dictionary=state(f)
 if not s.get("waterfall_seasons") is Dictionary: s.waterfall_seasons={}
 var season:int=int((f.day-1)/28)%4
 var title:String=f.SEASONS[season]
 var first:bool=not s.waterfall_seasons.has(title)
 s.waterfall_seasons[title]=true
 var stories:Array=["The keeper shows you a seed carried through the rocks. A small beginning can find its own way to the light.","Dragonflies skim the pool. The keeper reminds you that a growing farm also needs moments of rest.","A golden leaf circles the water. The keeper speaks of sharing a harvest, and making room for those who arrive late.","Steam rises between snow-covered stones. Beneath the quiet surface, the spring is still moving. Your story will continue, too."]
 var text:String=stories[season]+"\n\nSeasons heard: %d / 4." % s.waterfall_seasons.size()
 if first: remember(f,title+" at Moonveil Falls",stories[season])
 if s.waterfall_seasons.size()==4:
  preload("res://VillageDepth.gd").state(f).keepsakes["Four seasons medallion"]=true
  text+="\nThe keeper gives you a four-seasons medallion for your home."
 f.save_game(false)
 var c=panel(f,"The voice of "+title.to_lower(),text);c.add_child(f.make_button("Return to the path",f.close_dialogue))

static func repeat_work(f) -> void:
 if f.location!="farm" or f.inside_house or f.dialogue_open or f.paused_by_player or f.sleep_in_progress or f.choosing_character or not f.window_focused: return
 if f.interaction_action()!="" or f.resources.action_time>0: return
 var desired:int=[0,1,3][f.selected_tool]
 var nearest:int=-1;var distance:float=78.0
 for i in range(f.plots.size()):
  var plot:Dictionary=f.plots[i]
  var d:float=f.player.position.distance_to(plot.position)
  if int(plot.stage)==desired and d<distance:
   nearest=i;distance=d
 if nearest<0: return
 f.nearest=nearest;f.interact();f.queue_redraw()

static func confirm_purchase(f,title:String,cost:String,action:Callable) -> void:
 var c=panel(f,"Confirm "+title,cost+"\nProceed with this purchase?")
 var button=f.make_button("Confirm purchase",func(): pass)
 button.pressed.connect(func():
  if button.disabled: return
  button.disabled=true;action.call())
 c.add_child(button);c.add_child(f.make_button("Cancel",f.close_dialogue))
