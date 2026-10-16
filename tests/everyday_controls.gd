extends SceneTree
func _initialize(): call_deferred("run")
func find_button(n,text:String):
 if n is Button and n.text==text: return n
 for child in n.get_children():
  var result=find_button(child,text)
  if result!=null: return result
 return null
func fields(n,out:Array):
 if n is SpinBox: out.append(n)
 for child in n.get_children(): fields(child,out)
func run():
 var f=load("res://Main.tscn").instantiate();root.add_child(f);await process_frame
 f.set_physics_process(false);f.choose_character("boy");f.set_location(true,f.ROOM_ORIGIN+f.interior.CHEST_APPROACH)
 f.produce.Turnip=5;f.stored_items.Turnip=7;f.open_storage_item("Turnip")
 var inputs:Array=[];fields(f.dialogue_panel,inputs);assert(inputs.size()==2)
 inputs[1].value=3;find_button(f.dialogue_panel,"Take selected").pressed.emit()
 assert(f.produce.Turnip==8 and f.stored_items.Turnip==4,"Withdrawal uses its own quantity and direction")
 inputs.clear();fields(f.dialogue_panel,inputs);inputs[0].value=2
 find_button(f.dialogue_panel,"Store selected").pressed.emit()
 assert(f.produce.Turnip==6 and f.stored_items.Turnip==6)
 f.transfer_storage("Turnip",999,false);assert(f.produce.Turnip==12 and f.stored_items.Turnip==0)
 f.close_dialogue();f.travel_to("farm",f.plots[0].position+Vector2(45,0),false)
 f.plots[0].stage=2;f.plots[1].stage=1
 f.select_tool(1);assert(f.nearest==1,"Water targets thirsty bed rather than closer watered bed")
 f.resources.action_time=0;f.interact();assert(f.plots[1].stage==2)
 f.plots[1].stage=3;f.select_tool(2);assert(f.nearest==1)
 f.plots[0].stage=0;f.select_tool(0);assert(f.nearest==0)
 f.player.position=Vector2(100,100);assert(preload("res://CropTarget.gd").find(f)==-1)
 f.set_location(true,f.ROOM_ORIGIN+f.interior.ENTRY);assert(preload("res://CropTarget.gd").find(f)==-1)
 f.queue_free();await create_timer(.3).timeout
 print("PASS: selected storage deposit/withdrawal, capacity clamp and nearby tool-appropriate crop targeting")
 quit()
