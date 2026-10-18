extends SceneTree
func _initialize():call_deferred("run")
func run():
 root.size=Vector2i(1311,603)
 var f=load("res://Main.tscn").instantiate();root.add_child(f);await process_frame
 f.set_physics_process(false);f.choose_character("boy");f.close_dialogue()
 f.travel_to("farm",f.SHIPPING_BOX+Vector2(0,55),false);await physics_frame
 assert(f.interaction_action()=="shipping")
 assert(f.polish.clear_position(f.player.position))
 var pasture=preload("res://AnimalPasture.gd")
 assert(pasture.BOUNDS.position.x>f.BARN_DOOR.x and pasture.BOUNDS.position.y>f.BARN_DOOR.y)
 for i in range(8):assert(f.is_walkable(pasture.point(i)),"Pasture animals stay reachable")
 for p in [f.SHIPPING_BOX,preload("res://FarmResources.gd").WELL,pasture.GATE]:
  f.polish.plan(p);assert(not f.polish.path.is_empty(),"Utilities and gate have paths")
 f.travel_to("tea",Vector2(1280,675),false);await physics_frame
 for p in f.TEA_SPOTS:
  assert(f.regions.tea.is_walkable(p));f.polish.plan(f.REGION_ORIGINS.tea+p);assert(not f.polish.path.is_empty())
 for place in f.get_node("VillagePlaces").PLACES:assert(place[2] not in ["Library bench","Tea garden bench"])
 f.close_dialogue();f.open_map();await process_frame
 var maps=[]
 for c in f.dialogue_panel.find_children("*","Control",true,false):
  if c.get_script()==load("res://WorldMiniMap.gd"):maps.append(c)
 assert(maps.size()==1 and maps[0].expanded,"Expanded map opens from the same map control")
 f.close_dialogue();f.friendship.Seira=80
 var R=load("res://Relationships.gd");var bond=R.state(f,"Seira");bond.status="engaged";bond.affection=90;bond.chapter=3
 R.commit(f,"Seira","married");assert(f.location=="town","Wedding takes place in village square")
 for actor in f.relationship_moment.actors:assert(f.town.is_walkable(actor.position-f.TOWN_ORIGIN))
 f.close_dialogue()
 print("PASS: revised farm access, tea rows, removed benches, expanded minimap and village-square wedding")
 quit()
