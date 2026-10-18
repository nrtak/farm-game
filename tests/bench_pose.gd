extends SceneTree
func _initialize():call_deferred("run")
func run():
 var f=load("res://Main.tscn").instantiate();root.add_child(f);await process_frame
 f.set_physics_process(false);f.choose_character("boy");f.close_dialogue()
 var places=f.get_node("VillagePlaces")
 for entry in places.PLACES:
  if not entry[3].begins_with("Sit"):continue
  var offset=f.TOWN_ORIGIN if entry[0]=="town" else f.REGION_ORIGINS[entry[0]]
  f.travel_to(entry[0],places.point(entry)-offset,false)
  f.player.position=places.point(entry)+Vector2(0,20)
  var original=f.player.position
  places.interact();await process_frame
  assert(is_instance_valid(places.seated) and not f.farmer.visible)
  assert(f.player.position==original,"Sitting never moves the saved collision body")
  f.close_dialogue();await process_frame
  assert(not is_instance_valid(places.seated) and f.farmer.visible and f.player.position==original)
 print("PASS: remaining harbor bench seat and restore the player without changing position")
 quit()
