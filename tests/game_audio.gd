extends SceneTree
const Audio=preload("res://GameAudio.gd")
func _initialize(): call_deferred("run")
func run():
	var f=load("res://Main.tscn").instantiate();root.add_child(f);await process_frame
	f.set_physics_process(false);f.choose_character("boy");f.interior_progress.story={"intro":true};f.window_focused=true;f.day=1;f.clock_minutes=800
	f.sound.set_process(false)
	f.sound.switch_theme("farm")
	var seasonal_slot=f.sound.slot
	f.sound.fade=.6
	for area in ["town","nature","farm"]:
		f.sound.switch_theme(area)
		assert(f.sound.slot==seasonal_slot and f.sound.fade==.6,"Crossing daytime areas preserves the seasonal track and fade")
	f.sound.switch_theme("interior")
	var indoor_slot=f.sound.slot
	f.day=29;f.sound.switch_theme("interior")
	assert(f.sound.slot==indoor_slot,"Season changes do not restart a nonseasonal indoor score")
	f.day=1
	for pair in [["farm","farm"],["town","town"],["tea","nature"],["waterfall","falls"]]:
		f.travel_to(pair[0],Vector2(800,950),false);f.sound.poll=0;f.sound._process(2)
		assert(f.sound.current==pair[1]);assert(f.sound.players[f.sound.slot].stream!=null)
		assert(f.sound.players[1-f.sound.slot].stream==null,"Old music released after fade")
	for season in range(4):
		f.day=1+season*28
		f.sound.switch_theme("farm")
		assert(f.sound.current_season==season)
		var expected=["spring","summer","autumn","winter"][season]
		assert(f.sound.players[f.sound.slot].stream.resource_path.ends_with("music-"+expected+".wav"),"Season change selects its original score even without changing location")
		assert(f.sound.players[f.sound.slot].stream.get_length()>65,"Seasonal phrases have breathing room before looping")
	f.enter_shop("Inn",true);assert(Audio.theme(f)=="interior")
	f.travel_to("town",Vector2(1100,940),false);f.clock_minutes=1200;assert(Audio.theme(f)=="night")
	for d in range(1,40):
		if f.is_rainy_day(d): f.day=d;break
	assert(Audio.theme(f)=="rain")
	f.sound.poll=0;f.sound._process(2);assert(f.sound.ambient_key=="rain")
	f.window_focused=false;f.sound._process(.1);assert(f.sound.suspended)
	if DisplayServer.get_name()!="headless": assert(f.sound.players[f.sound.slot].stream_paused)
	f.window_focused=true;f.sound._process(.1);assert(not f.sound.suspended)
	Audio.menu(f)
	var sliders:Array=[];collect(f.dialogue_panel,sliders)
	assert(sliders.size()==4)
	for slider in sliders:
		if slider.name=="music_volume": slider.value=0
	assert(Audio.volume(f,"music_volume",.45)==0 and Audio.volume(f,"effects_volume",.65)==.65)
	assert(AudioServer.is_bus_mute(AudioServer.get_bus_index(Audio.MUSIC_BUS)))
	f.sound.poll=0;f.sound._process(.3);assert(f.sound.current=="")
	for slider in sliders:
		if slider.name=="effects_volume": slider.value=25
	assert(Audio.volume(f,"effects_volume",.65)==.25)
	for slider in sliders:
		if slider.name=="footstep_volume": slider.value=0
		if slider.name=="ambience_volume": slider.value=60
	assert(AudioServer.is_bus_mute(AudioServer.get_bus_index(Audio.STEPS_BUS)))
	assert(not AudioServer.is_bus_mute(AudioServer.get_bus_index(Audio.AMBIENCE_BUS)))
	f.save_game(false);f.load_game();assert(Audio.volume(f,"music_volume",.45)==0 and Audio.volume(f,"effects_volume",.65)==.25)
	for effect in ["step","door","purchase","save","sleep","wake"]:
		f.sound.play_effect(effect);assert(f.sound.effects.stream!=null)
	assert(f.resources.action_audio.bus==Audio.EFFECTS_BUS and f.regions.waterfall.ambience.bus==Audio.AMBIENCE_BUS and f.sound.steps.bus==Audio.STEPS_BUS)
	print("PASS: regional/day/weather music, bounded fades, focus pause, independent volume/mute persistence and sound routing")
	f.queue_free();await create_timer(.2).timeout;quit()
func collect(node,result:Array):
	if node is HSlider: result.append(node)
	for child in node.get_children(): collect(child,result)
