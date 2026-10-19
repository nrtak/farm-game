extends SceneTree
func _initialize():call_deferred("run")
func run():
 var f=load("res://Main.tscn").instantiate();root.add_child(f);await process_frame
 f.set_physics_process(false);f.choose_character("boy");f.close_dialogue()
 for dimensions in [Vector2i(1311,603),Vector2i(844,390),Vector2i(667,375),Vector2i(568,320),Vector2i(390,844)]:
  root.size=dimensions
  f.enter_shop("Inn",true);f.start_conversation(f.shops.Inn.residents[0])
  for frame in range(6):await process_frame
  var panel=f.dialogue_panel.get_child(0)
  var bounds=Rect2(Vector2.ZERO,f.get_viewport_rect().size)
  assert(bounds.encloses(panel.get_global_rect()),"Dialogue panel fits after resize: "+str(dimensions))
  var close=panel.find_child("DialogueClose",true,false)
  assert(bounds.encloses(close.get_global_rect()) and close.size.x>=44,"Close remains reachable: "+str(dimensions))
  f.close_dialogue()
  f.travel_to("historic",Vector2(700,610),false)
  preload("res://VillageDepth.gd").state(f).falls=0
  preload("res://VillageDepth.gd").waterfall(f)
  for frame in range(6):await process_frame
  panel=f.dialogue_panel.get_child(0)
  assert(bounds.encloses(panel.get_global_rect()),"Narrative panel fits after resize: "+str(dimensions))
  f.close_dialogue()
 f.queue_free();await create_timer(.2).timeout
 print("PASS: portrait and narrative dialogue fit five landscape/portrait sizes with reachable close controls")
 quit()
