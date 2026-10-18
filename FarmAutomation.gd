extends RefCounted
const OFFERS={"feeder":{"shop":"Ranch","price":3500,"name":"Automatic barn feeder","description":"Uses your stored feed each morning. No purchases are made automatically."},"tractor":{"shop":"Blacksmith","price":18000,"name":"Compact harvest tractor","description":"Harvests up to 12 ripe field beds each morning into storage, stopping when storage is full. Never sells produce or plants seeds."}}
static func state(f)->Dictionary:
 if not f.interior_progress.get("automation") is Dictionary:f.interior_progress.automation={}
 return f.interior_progress.automation
static func menu(f,kind:String):
 var offer:Dictionary=OFFERS[kind];var c=f.make_modal(offer.name)
 f.dialogue_text.text=offer.description+"\nPrice: %d. Available from Year 1, Summer." % offer.price
 if state(f).get(kind,false):f.dialogue_text.text+="\nInstalled."
 else:c.add_child(f.make_button("Purchase",buy.bind(f,kind)))
 c.add_child(f.make_button("Back",f.close_dialogue))
static func buy(f,kind:String):
 if not OFFERS.has(kind):return
 var offer:Dictionary=OFFERS[kind]
 if f.location!="shop" or f.shop_name!=offer.shop or f.day<29 or f.coins<offer.price or state(f).get(kind,false):
  f.dialogue_text.text="Visit the correct shop from Summer onward with enough money.";return
 f.coins-=offer.price;state(f)[kind]=true;f.save_game(false);menu(f,kind)
static func morning(f):
 var s=state(f)
 if int(s.get("morning",-1))>=f.day:return
 s.morning=f.day;var fed=0;var harvested=0
 s.harvest_route=[]
 if s.get("feeder",false):
  var barn=f.BarnLife.state(f)
  for animal in barn.animals:
   if animal.fed!=f.day and barn.feed>0:animal.fed=f.day;barn.feed-=1;fed+=1
 if s.get("tractor",false):
  for plot in f.plots:
   if harvested>=12:break
   if plot.stage!=3 or int(f.stored_items.get(plot.crop,0))>=f.storage_limit():continue
   f.stored_items[plot.crop]=int(f.stored_items.get(plot.crop,0))+1
   s.harvest_route.append([plot.position.x,plot.position.y])
   plot.stage=0;plot.growth=0;f.harvests+=1;harvested+=1
 s.report="Farm equipment: %d animals fed; %d crops placed in storage." % [fed,harvested]
