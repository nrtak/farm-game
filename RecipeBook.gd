extends RefCounted
const RECIPES={"supper":{"name":"Harvest supper","health":25,"needs":{"Produce":2}},"omelet":{"name":"Farmhouse omelet","health":35,"needs":{"Egg":1,"Milk":1,"Potato":1}},"tea":{"name":"Festival milk tea","health":30,"needs":{"Tea packets":1,"Milk":1}}}
static func available(f,id:String) -> bool:
 return id!="tea" or preload("res://VillageDepth.gd").state(f).get("festival_recipe",false)
static func kitchen(f) -> bool: return f.inside_house and int(f.interior_progress.get("home",0))>=2
static func count(f,item:String) -> int:
 if item!="Produce": return f.carried_count(item)
 var total:=0
 for value in f.produce.values(): total+=int(value)
 return total
static func enough(f,id:String) -> bool:
 for item in RECIPES[id].needs:
  if count(f,item)<RECIPES[id].needs[item]: return false
 return true
static func book(f) -> void:
 f.remove_meta("recipe_ready")
 var c=f.make_modal("Farmhouse recipe book")
 f.dialogue_text.text="Cook and eat at your upgraded home kitchen. Ingredients come from your backpack. Select a dish to review it."
 var grid=preload("res://MenuTiles.gd").grid(f,c)
 grid.get_parent().custom_minimum_size.y=165
 for id in RECIPES:
  var r:Dictionary=RECIPES[id]
  var b=f.make_button(r.name+"\nHealth +%d" % r.health,detail.bind(f,id))
  var old=b.get_node_or_null("ItemArtwork")
  if old!=null: old.queue_free()
  b.remove_meta("item_art")
  preload("res://MenuTiles.gd").tile(b)
  var art=preload("res://RecipeDish.gd").new();art.dish=id;art.mouse_filter=Control.MOUSE_FILTER_IGNORE;b.add_child(art)
  art.size=Vector2(100,76);b.resized.connect(func(): art.position=Vector2((b.size.x-100)/2,0))
  grid.add_child(b)
  if not available(f,id): b.text=r.name+"\nFestival recipe · locked"
 c.add_child(f.make_button("Back",f.close_dialogue))
static func detail(f,id:String) -> void:
 if not RECIPES.has(id): return
 f.set_meta("recipe_ready",id)
 var r:Dictionary=RECIPES[id];var c=f.make_modal(r.name)
 var art=preload("res://RecipeDish.gd").new();art.dish=id;art.custom_minimum_size.y=100;c.add_child(art);c.move_child(art,1)
 var lines:Array=[]
 for item in r.needs: lines.append("%s: %d / %d" % [item,count(f,item),r.needs[item]])
 f.dialogue_text.text="\n".join(lines)+"\nEat immediately · Health +%d (up to 100)." % r.health
 if id=="supper": f.dialogue_text.text+="\nUses any two harvested crops, including fruit."
 if not available(f,id): f.dialogue_text.text+="\nEarn this recipe by taking part in a festival activity."
 elif not kitchen(f): f.dialogue_text.text+="\nAsk the carpenter for the kitchen wing, then cook at home."
 elif f.health>=100: f.dialogue_text.text+="\nYou are already rested; save your ingredients."
 var b=f.make_button("Cook and eat",cook.bind(f,id));b.disabled=not kitchen(f) or not available(f,id) or not enough(f,id) or f.health>=100;c.add_child(b)
 c.add_child(f.make_button("Back to recipes",book.bind(f)))
static func cook(f,id:String) -> void:
 if not RECIPES.has(id) or f.get_meta("recipe_ready","")!=id: return
 if not kitchen(f) or not available(f,id) or not enough(f,id) or f.health>=100: detail(f,id);return
 f.remove_meta("recipe_ready")
 var r:Dictionary=RECIPES[id]
 for item in r.needs:
  var left:int=r.needs[item]
  if item=="Produce":
   for crop in f.produce:
    var take:int=mini(left,int(f.produce[crop]));f.produce[crop]-=take;left-=take
  else: f.change_carried(item,-left)
 var gained:int=mini(r.health,ceili(100-f.health));f.health=minf(100,f.health+r.health)
 if not f.interior_progress.get("cooked_recipes") is Dictionary: f.interior_progress.cooked_recipes={}
 f.interior_progress.cooked_recipes[id]=int(f.interior_progress.cooked_recipes.get(id,0))+1
 f.save_game(false)
 preload("res://EverydayLife.gd").cooking_moment(f,r.name,"Freshly prepared and enjoyed at home. Health +%d." % gained)
