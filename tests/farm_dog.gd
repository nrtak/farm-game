extends SceneTree
const Dog=preload("res://FarmDog.gd")
func _initialize(): call_deferred("run")
func run():
 var f=load("res://Main.tscn").instantiate();root.add_child(f);await process_frame
 f.set_physics_process(false);f.choose_character("boy");f.window_focused=true
 f.interior_progress.story={"intro":true};f.clock_minutes=800;f.coins=100
 f.enter_shop("Ranch",true);f.day=6;Dog.adopt(f,"Mochi");assert(not Dog.owned(f))
 f.day=7;Dog.offer(f);f.close_dialogue();assert(not Dog.owned(f),"An offer does not adopt automatically")
 f.travel_to("farm",Vector2(930,705),false);f.clock_minutes=420
 for d in range(7,30):
  f.day=d
  if not f.is_rainy_day(): break
 assert(Dog.maybe_visit(f) and is_instance_valid(f.farm_visitor))
 f.close_dialogue();assert(not Dog.maybe_visit(f),"Declining waits before another invitation")
 f.enter_shop("Ranch",true);f.day=7;f.clock_minutes=800
 Dog.adopt(f,"  Sora  ");assert(Dog.owned(f) and Dog.state(f).name=="Sora")
 Dog.adopt(f,"Other");assert(Dog.state(f).name=="Sora")
 Dog.buy_food(f);assert(f.coins==80 and Dog.state(f).food==20)
 f.close_dialogue();f.travel_to("farm",Vector2(930,705),false);f.day=1
 var dog=f.get_node("FarmDog");dog.set_process(false);await physics_frame;dog._process(.1)
 assert(dog.visible and f.polish.clear_position(dog.pet.position))
 f.player.position=dog.pet.position+Vector2(40,0)
 for action in ["fed","petted","played"]: Dog.care(f,action);Dog.care(f,action)
 assert(Dog.state(f).food==19 and Dog.state(f).affection==6 and Dog.state(f).fed_days==1)
 Dog.state(f).food=0;Dog.menu(f);f.day=2;Dog.care(f,"fed")
 assert(Dog.state(f).fed_days==1 and f.dialogue_text.text.contains("No dog meals"))
 f.close_dialogue();f.player.position+=Vector2(500,0);Dog.care(f,"petted")
 assert(Dog.state(f).affection==6,"Care requires standing near your dog")
 Dog.state(f).arrival=7;f.day=34;Dog.state(f).fed_days=14;assert(not Dog.adult(f))
 f.day=35;assert(Dog.adult(f));Dog.state(f).fed_days=13;assert(not Dog.adult(f))
 Dog.state(f).fed_days=14;f.clock_minutes=1200;dog._process(.1);assert(not dog.visible)
 f.set_location(true,f.ROOM_ORIGIN+Vector2(610,595));await physics_frame;dog._process(.1)
 assert(dog.visible and f.polish.clear_position(dog.pet.position),"Dog shelters in a walkable part of the house")
 assert(not dog.segment_clear(dog.pet.position,f.ROOM_ORIGIN+Vector2(0,0)),"Dog never follows through a wall")
 f.save_game(false);var saved=f.read_saved_json(f.SAVE_FILE).interior_progress.dog
 assert(saved.name=="Sora" and saved.fed_days==14 and saved.affection==6)
 f.queue_free();await create_timer(.3).timeout
 print("PASS: optional dog adoption, daily care, food purchases, growth, safe shelter and saved companion")
 quit()
