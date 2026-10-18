extends SceneTree
func _initialize():call_deferred("run")
func run():
 var f=load("res://Main.tscn").instantiate();root.add_child(f);await process_frame
 f.set_physics_process(false);f.choose_character("boy");f.close_dialogue();f.interior_progress.story={"intro":true}
 var auto=preload("res://FarmAutomation.gd");f.day=29;f.coins=30000
 f.enter_shop("Ranch",true);auto.buy(f,"feeder");assert(auto.state(f).feeder and f.coins==26500)
 auto.buy(f,"feeder");assert(f.coins==26500,"No duplicate charge")
 var barn=f.BarnLife.state(f);barn.animals=[{"species":"Cow","fed":-1,"petted":-1,"affection":0,"nights":0,"ready":0,"settled":f.day}];barn.feed=2
 f.enter_shop("Blacksmith",true);auto.buy(f,"tractor");assert(auto.state(f).tractor)
 for plot in f.plots:plot.stage=3;plot.crop="Turnip"
 f.stored_items.Turnip=995;auto.morning(f)
 assert(f.stored_items.Turnip==999 and barn.feed==1 and barn.animals[0].fed==29)
 var crops=f.harvests;auto.morning(f);assert(f.harvests==crops and barn.feed==1,"Morning work idempotent")
 f.close_dialogue();f.travel_to("historic",Vector2(1100,820),false);await process_frame
 var nature=f.get_node("NatureFriends");nature._process(0)
 f.player.position=nature.points[0];f.produce.Turnip=2;f.held_gift="Turnip";nature.interact()
 assert(f.produce.Turnip==1 and nature.state(f).friendship["Elder Moss"]==1)
 f.close_dialogue();f.held_gift="Turnip";nature.interact();assert(f.produce.Turnip==1,"One creature gift daily")
 nature.state(f).friendship["Elder Moss"]=12;f.day=30;f.clock_minutes=780
 while f.is_rainy_day():f.day+=3
 f.close_dialogue();f.travel_to("farm",Vector2(930,1450),false);nature._process(0)
 assert(nature.sprites[0].visible,"Leader trust unlocks farm visit")
 for i in range(4):
  if nature.sprites[i].visible:assert(f.is_walkable(nature.points[i]),"Visitor stays on safe ground")
 var original_day:int=f.day
 var seen={}
 for visit_day in [30,33,36,39,42,45]:
  f.day=visit_day
  var spot:Vector2=nature.visit_point(0)
  assert(spot.is_finite() and f.is_walkable(spot),"Every visit circuit has safe ground")
  assert(spot==nature.visit_point(0),"Visit location remains stable within the day")
  for plot in f.plots:assert(spot.distance_to(plot.position)>=85,"Visitors leave crop beds clear")
  seen[str(spot)]=true
 assert(seen.size()>1,"Visitors explore different farm areas")
 f.day=original_day
 assert(nature.seasonal_line(1)!=nature.seasonal_line(29),"Visitor dialogue follows seasons")
 f.enter_shop("School",true);f.open_service("School");assert("Lessons" in f.dialogue_text.text)
 f.friendship.Nao=17;f.friendship.Rin=9
 f.close_dialogue();f.save_game(false);f.interior_progress.automation={};f.load_game();assert(auto.state(f).tractor)
 assert(f.friendship.Nao==17 and f.friendship.Rin==9,"New residents retain friendship on reload")
 print("PASS: equipment purchase, capacity, no repeat charges/work, creature gifts/visits, school and persistence");quit()
