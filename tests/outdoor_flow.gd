extends SceneTree
func _initialize():call_deferred("run")
func run():
 var f=load("res://Main.tscn").instantiate();root.add_child(f);await process_frame
 f.set_physics_process(false);f.choose_character("boy");f.close_dialogue();f.interior_progress.story={"intro":true}
 f.travel_to("town",f.town.arrival("farm"),false)
 f.running=false;assert(f.movement_speed()==145)
 f.running=true;assert(f.movement_speed()==210)
 f.travel_to("historic",Vector2(1440,1060),false)
 for y in range(1060,420,-8):
  assert(f.regions.historic.is_walkable(Vector2(1440,y)),"Straight arrival-to-shrine lane")
 var falls=preload("res://ShrineFalls.gd")
 assert(falls.APPROACH.x<f.REGIONAL_ROOMS["Shrine Residence"][1].x,"Falls left of shrine")
 for room in ["Fishing Shop","Harbor Homes"]:assert(f.REGIONAL_ROOMS[room][1].y==200,"North-edge harbor doors")
 f.travel_to("harbor",Vector2(1480,585),false)
 for x in range(500,1500,8):assert(f.regions.harbor.is_walkable(Vector2(x,585)),"Unbroken harbor promenade")
 # Touch identity must survive a gateway, otherwise releasing the finger would leave movement stuck.
 f.joystick.finger=7;f.joystick.knob=Vector2(40,0);f.joystick.direction=Vector2.RIGHT;f.player.velocity=Vector2.RIGHT*200
 f.walk_to_area("town",f.town.arrival("harbor"))
 assert(f.joystick.finger==7 and f.joystick.direction==Vector2.RIGHT)
 assert(f.perspective.travel_left>0)
 var release=InputEventScreenTouch.new();release.index=7;release.pressed=false
 f.joystick._input(release)
 assert(f.joystick.direction==Vector2.ZERO and f.joystick.finger==-1,"Releasing after gateway stops walking")
 f.perspective._process(.5);assert(f.perspective.travel_left==0)
 # A held touch can reach the gateway with zero velocity after collision resolution.
 f.joystick.finger=8;f.joystick.direction=Vector2.LEFT;f.joystick.knob=Vector2(-30,0)
 f.player.velocity=Vector2.ZERO
 f.walk_to_area("harbor",Vector2(1480,585))
 assert(f.joystick.finger==8 and f.joystick.direction==Vector2.LEFT,"Stationary gateway preserves held touch")
 f.perspective.begin_outdoor_pan(Vector2.RIGHT)
 f.enter_shop("Fishing Shop",true)
 assert(f.perspective.travel_left==0,"Entering an interior cancels outdoor glide")
 f.travel_to("harbor",Vector2(1480,585),false)
 f.perspective.begin_outdoor_pan(Vector2.RIGHT)
 f.travel_to("town",f.town.arrival("harbor"),false)
 assert(f.perspective.travel_left==0,"Direct travel cannot inherit an earlier glide")
 f.perspective.begin_outdoor_pan(Vector2.RIGHT)
 f.set_location(true,f.ROOM_ORIGIN+f.interior.ENTRY)
 assert(f.perspective.travel_left==0,"Home entry cancels glide")
 f.day=1
 while f.WeatherLife.forecast(f.day)!="Hurricane":f.day+=1
 f.inside_house=false;f.location="harbor"
 f.joystick.finger=9;f.joystick.direction=Vector2.RIGHT;f.player.velocity=Vector2.RIGHT*200
 f.walk_to_area("town",f.town.arrival("harbor"))
 assert(f.inside_house and f.joystick.direction==Vector2.ZERO and f.perspective.travel_left==0,"Weather redirect must not restore outdoor input or glide")
 print("PASS: calmer town speed, straight shrine and harbor routes, west falls, touch release and bounded camera glide")
 quit()
