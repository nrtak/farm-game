extends SceneTree
const Life=preload("res://EverydayLife.gd")
const Status=preload("res://CareStatus.gd")
const Symbol=preload("res://ShopSymbol.gd")
func _initialize(): call_deferred("run")
func collect(n,script,out:Array):
 if n.get_script()==script: out.append(n)
 for child in n.get_children(): collect(child,script,out)
func run():
 var f=load("res://Main.tscn").instantiate();root.add_child(f);await process_frame
 f.set_physics_process(false);f.choose_character("boy");f.coins=2000
 f.enter_shop("Ranch",true);f.BarnLife.purchase(f,"Cow")
 var a:Dictionary=f.BarnLife.state(f).animals[0]
 a.fed=f.day;a.petted=f.day;a.ready=2
 Life.care_board(f);await process_frame
 var cues:Array=[];collect(f.dialogue_panel,Status,cues)
 assert(cues.size()==1 and cues[0].fed and cues[0].petted and cues[0].product_count==2)
 f.day+=1;Life.care_board(f);await process_frame
 cues.clear();collect(f.dialogue_panel,Status,cues)
 assert(not cues[0].fed and not cues[0].petted and cues[0].product_count==2,"Care resets with day but uncollected products remain")
 Life.town_map(f);await process_frame
 cues.clear();collect(f.dialogue_panel,Symbol,cues)
 assert(cues.size()==f.town.BUILDINGS.size())
 var names:Array=[]
 for cue in cues:
  assert(not names.has(cue.shop));names.append(cue.shop)
  assert(cue.mouse_filter==Control.MOUSE_FILTER_IGNORE)
  cue.get_parent().pressed.emit()
  assert(f.dialogue_text.text.begins_with(cue.shop+" · "),"Each map symbol opens its own hours")
 f.queue_free();await create_timer(.3).timeout
 print("PASS: animal care daily status and product counts; all town symbols open correct building hours")
 quit()
