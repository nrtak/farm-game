extends SceneTree
func _initialize():call_deferred("run")
func run():
 var f=load("res://Main.tscn").instantiate();root.add_child(f);await process_frame
 f.set_physics_process(false);f.choose_character("boy");f.close_dialogue()
 while f.is_rainy_day():f.day+=1
 var R=load("res://Relationships.gd");f.friendship.Seira=60
 for source in ["farm","house","shop","town","tea"]:
  if source=="house":f.set_location(true,f.ROOM_ORIGIN+Vector2(550,500))
  elif source=="shop":f.enter_shop("Archive",true)
  else:f.travel_to(source,Vector2(1100,700) if source!="town" else f.town.design(Vector2(1300,800)),false)
  var position=f.player.position;var shop=f.shop_name
  for outing in ["Tea","Beach walk","Shrine garden"]:
   f.day+=7
   while f.is_rainy_day():f.day+=1
   f.save_game(false)
   R.date(f,"Seira",outing)
   assert(is_instance_valid(f.relationship_moment),"Outing must stage visible actors")
   assert(f.relationship_moment.actors.size()==1)
   assert(f.location==("shop" if outing=="Tea" else "harbor" if outing=="Beach walk" else "historic"))
   var saved=FileAccess.get_file_as_string(f.SAVE_FILE)
   f.save_game(false)
   assert(FileAccess.get_file_as_string(f.SAVE_FILE)==saved,"Staging cannot overwrite the player's save location")
   f.close_dialogue();await process_frame
   assert(f.location==source and f.player.position.is_equal_approx(position),"Return to exact origin")
   if source=="shop":assert(f.shop_name==shop)
   assert(not is_instance_valid(f.relationship_moment) and f.scene_actors.is_empty())
 var s=R.state(f,"Seira");s.status="engaged";s.affection=90;s.chapter=3
 R.commit(f,"Seira","married")
 assert(f.relationship_moment.actors.size()==4,"Wedding includes partner and neighbors")
 f.load_game();await process_frame
 assert(R.state(f,"Seira").status=="married" and f.location=="tea","Reload keeps vows and origin, never staged location")
 print("PASS: staged outings/wedding restore five origins, preserve saves and clean up actors")
 quit()
