extends SceneTree
const Life=preload("res://EverydayLife.gd")
func _initialize(): call_deferred("run")
func run():
 var f=load("res://Main.tscn").instantiate();root.add_child(f);await process_frame
 f.set_physics_process(false);f.choose_character("boy");f.interior_progress.story={"intro":true};f.coins=2000;f.clock_minutes=800
 f.produce.Turnip=5;f.produce.Potato=2
 Life.state(f).protected.Turnip=true
 f.open_shipping();f.ship_produce()
 assert(f.produce.Turnip==5 and f.shipping_queue.Turnip==0 and f.shipping_queue.Potato==2)
 f.day=2;f.settle_farm_day();assert(Life.state(f).receipt.total==2*f.CROPS.Potato.sale)
 f.settle_farm_day();assert(Life.state(f).receipt.total==2*f.CROPS.Potato.sale)
 f.enter_shop("Ranch",true);Life.preview_animal(f,"Cow")
 assert(f.BarnLife.state(f).animals.is_empty(),"Preview never purchases")
 var field=find_class(f.dialogue_panel,"LineEdit");field.text="Mochi"
 var buttons:Array=[];collect_buttons(f.dialogue_panel,buttons)
 for b in buttons:
  if b.text=="Buy Cow": b.pressed.emit();break
 assert(f.BarnLife.state(f).animals[0].name=="Mochi")
 Life.care_board(f);Life.animal_record(f,0)
 var yard=preload("res://AnimalPasture.gd")
 f.BarnLife.state(f).pasture=true;f.day=1;f.clock_minutes=800
 assert(yard.outside(f));f.clock_minutes=1030;assert(not yard.outside(f))
 f.clock_minutes=800
 for d in range(1,30):
  if preload("res://WeatherLife.gd").forecast(d)!="Normal": f.day=d;break
 assert(not yard.outside(f));f.day=1
 f.close_dialogue();f.travel_to("farm",yard.point(0),false);await physics_frame
 assert(f.is_walkable(yard.point(0)) and f.polish.clear_position(yard.point(0)))
 for i in range(8): assert(f.is_walkable(yard.point(i)),"Animal pasture position "+str(i))
 assert(f.interaction_action()=="pasture_care")
 f.interact();f.BarnLife.care(f,0,"pet");assert(f.BarnLife.state(f).animals[0].petted==f.day)
 assert(not f.is_walkable(yard.FENCES[0].get_center()))
 assert(f.is_walkable(Vector2(1460,1590)),"Pasture gate stays open")
 f.BarnLife.state(f).pasture=false
 f.friendship.Seira=20;Life.invite(f,"Seira");Life.date_scene(f,"Seira");Life.date_scene(f,"Seira")
 assert(f.friendship.Seira==22,"Outing rewards once per week")
 f.character_choice="girl";Life.date_scene(f,"Seira");assert(f.friendship.Seira==22)
 for method in ["bag","journal","forecast","morning","seed_calendar","neighbors","album","shops","town_map"]:
  Life.new().call(method,f);await process_frame
 f.close_dialogue();f.travel_to("farm",Vector2(1020,700),false);f.day=1;f.selected_tool=1;f.window_focused=true
 f.player.position=f.plots[0].position;f.plots[0].stage=1;f.resources.action_time=0
 var water:int=f.resources.state().water;Life.repeat_work(f)
 assert(f.plots[0].stage==2 and f.resources.state().water==water-1)
 Life.repeat_work(f);assert(f.resources.state().water==water-1,"Animation prevents repeat charging")
 f.close_dialogue();f.travel_to("waterfall",Vector2(800,700),false)
 preload("res://VillageDepth.gd").state(f).falls=3
 for season in range(4):
  f.day=1+season*28;Life.listen_season(f);Life.listen_season(f)
 assert(Life.state(f).waterfall_seasons.size()==4)
 assert(preload("res://VillageDepth.gd").state(f).keepsakes.has("Four seasons medallion"))
 f.save_game(false);assert(f.read_saved_json(f.SAVE_FILE).interior_progress.everyday.protected.Turnip)
 f.queue_free();await create_timer(.3).timeout
 print("PASS: protected shipping, receipt idempotence, named purchase confirmation, journal menus and dating eligibility/cooldown")
 quit()
func find_class(node,type:String):
 if node.is_class(type): return node
 for child in node.get_children():
  var found=find_class(child,type)
  if found!=null: return found
 return null
func collect_buttons(node,out):
 if node is Button: out.append(node)
 for child in node.get_children(): collect_buttons(child,out)

