extends RefCounted
static func stage(f) -> String:
 var job:Dictionary=f.interior_progress.get("construction",{})
 if job.is_empty(): return "No work scheduled"
 if f.day>int(job.day): return "Finishing work"
 return "Work underway" if f.clock_minutes-int(job.get("minute",f.clock_minutes))>=120 else "Materials prepared"
static func completed(f,job:Dictionary) -> void:
 if not f.interior_progress.get("building_history") is Array: f.interior_progress.building_history=[]
 var key:String=str(job.kind)+":"+str(job.level)
 for record in f.interior_progress.building_history:
  if record.key==key: return
 f.interior_progress.building_history.append({"key":key,"kind":job.kind,"level":job.level,"day":f.day,"title":job.get("title",str(job.kind).capitalize()),"benefit":job.get("benefit","Your farm expansion is ready to use.")})
static func notice(f) -> String:
 var records:Array=f.interior_progress.get("building_history",[])
 if records.is_empty() or int(records.back().day)!=f.day: return ""
 return "Completed: "+str(records.back().title)+"."
static func open(f) -> void:
 var c=f.make_modal("Carpenter's work journal")
 var job:Dictionary=f.interior_progress.get("construction",{})
 f.dialogue_text.text="Your completed projects and current construction."
 if not job.is_empty():
  f.dialogue_text.text="%s · %s\n%s\nReady after sleeping. Your current rooms, crops and animals stay usable." % [job.get("title",str(job.kind).capitalize()),stage(f),job.get("benefit","")]
 var scroll:=ScrollContainer.new();scroll.custom_minimum_size.y=135;scroll.size_flags_vertical=Control.SIZE_EXPAND_FILL;c.add_child(scroll)
 var list:=VBoxContainer.new();list.size_flags_horizontal=Control.SIZE_EXPAND_FILL;scroll.add_child(list)
 var records:Array=f.interior_progress.get("building_history",[])
 for index in range(records.size()-1,-1,-1):
  list.add_child(f.make_button(str(records[index].title)+" · Day "+str(records[index].day),review.bind(f,index)))
 if records.is_empty():
  var label:=Label.new();label.text="Newly completed projects will appear here.";label.add_theme_color_override("font_color",Color("493b2d"));list.add_child(label)
 c.add_child(f.make_button("Back",f.close_dialogue))
static func review(f,index:int) -> void:
 var records:Array=f.interior_progress.get("building_history",[])
 if index<0 or index>=records.size(): return
 var record:Dictionary=records[index];var c=f.make_modal(str(record.title)+" · Complete")
 f.dialogue_text.text=str(record.benefit)+"\nCompleted on day %d. Visit the marked part of the farm to use it." % record.day
 preload("res://PlayerComfort.gd").preview(f,c,record.kind)
 c.add_child(f.make_button("Back to projects",open.bind(f)))
