extends SceneTree
func _initialize(): call_deferred("run")
func run():
 var f=load("res://Main.tscn").instantiate();root.add_child(f);await process_frame
 f.set_physics_process(false);f.choose_character("boy");f.interior_progress.story={"intro":true};f.day=1;f.coins=0
 var life=preload("res://EverydayLife.gd")
 life.state(f).protected.Strawberry=true
 var events:Dictionary={}
 for n in range(112):
  var event:Dictionary=SeasonalFestivals.today(f.day)
  if not event.is_empty(): events[event.id]=true
  f.clock_minutes=1200;f.shipping_queue.Turnip=1
  f.finish_sleep_day()
  assert(f.day==n+2 and f.coins==(n+1)*20,"Daily settlement occurs once")
  assert(life.state(f).receipt.total==20 and life.state(f).receipt.day==f.day)
  var balance:int=f.coins;f.settle_farm_day();assert(f.coins==balance,"Repeated settlement never repays")
  if n%7==0:
   f.save_game(false);f.load_game();assert(f.day==n+2 and life.state(f).protected.Strawberry)
 assert(events.size()==16 and f.calendar_text().contains("Year 2"))
 f.queue_free();await create_timer(.3).timeout
 print("PASS: 112 overnight settlements, weekly save reloads, protected items, receipt idempotence, 16 festival dates and Year 2 rollover")
 quit()
