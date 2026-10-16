extends SceneTree
func _initialize(): call_deferred("run")
func run():
 var f=load("res://Main.tscn").instantiate();root.add_child(f);await process_frame
 f.set_physics_process(false);f.choose_character("boy");f.interior_progress.story={"intro":true}
 var tv=preload("res://HomeWeather.gd")
 f.set_location(true,f.ROOM_ORIGIN+tv.APPROACH);await physics_frame
 assert(f.polish.clear_position(f.player.position),"Weather TV approach is walkable")
 assert(f.interaction_action()=="weather_tv");f.interact();assert(f.dialogue_open)
 var found:Dictionary={}
 for day in range(1,113):
  var kind:String=preload("res://WeatherLife.gd").forecast(day+1)
  if found.has(kind): continue
  found[kind]=true;f.day=day;var clock=f.clock_minutes
  tv.show_forecast(f);await process_frame
  assert(f.dialogue_text.text==tv.advice(kind))
  assert(f.day==day and f.clock_minutes==clock,"Forecast never advances time")
 assert(found.size()==4)
 f.close_dialogue();assert(not f.dialogue_open)
 var story=preload("res://StoryArc.gd")
 f.harvests=17;f.interior_progress.restoration=1;f.interior_progress.activities=["Inn"]
 assert(story.progress_text(f,7)=="Harvests 17 / 30 · Land 1 / 2 · Activities 1 / 5")
 assert(story.progress_text(f,4).contains("complete"))
 f.queue_free();await create_timer(.3).timeout
 print("PASS: accessible weather TV, all four forecasts, unchanged time, dismissible menu and accurate story progress")
 quit()
