extends SceneTree
const Audio=preload("res://GameAudio.gd")
func _initialize(): call_deferred("run")
func run():
	var f=load("res://Main.tscn").instantiate();root.add_child(f);await process_frame
	f.set_physics_process(false);f.choose_character("boy");f.interior_progress.story={"intro":true};f.window_focused=true;f.day=1;f.clock_minutes=800
	f.sound.set_process(false)
	for pair in [["farm","farm"],["town","town"],["tea","nature"],["waterfall","falls"]]:
		f.travel_to(pair[0],Vector2(800,950),false);f.sound.poll=0;f.sound._process(2)
		assert(f.sound.current==pair[1]);assert(f.sound.players[f.sound.slot].stream!=null)
		assert(f.sound.players[1-f.sound.slot].stream==null,"Old music released after fade")
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
	assert(sliders.size()==2)
	for slider in sliders:
		if slider.name=="music_volume": slider.value=0
	assert(Audio.volume(f,"music_volume",.45)==0 and Audio.volume(f,"effects_volume",.65)==.65)
	assert(AudioServer.is_bus_mute(AudioServer.get_bus_index(Audio.MUSIC_BUS)))
	f.sound.poll=0;f.sound._process(.3);assert(f.sound.current=="")
	for slider in sliders:
		if slider.name=="effects_volume": slider.value=25
	assert(Audio.volume(f,"effects_volume",.65)==.25)
	f.save_game(false);f.load_game();assert(Audio.volume(f,"music_volume",.45)==0 and Audio.volume(f,"effects_volume",.65)==.25)
	for effect in ["step","door","purchase","save","sleep","wake"]:
		f.sound.play_effect(effect);assert(f.sound.effects.stream!=null)
	assert(f.resources.action_audio.bus==Audio.EFFECTS_BUS and f.regions.waterfall.ambience.bus==Audio.EFFECTS_BUS)
	print("PASS: regional/day/weather music, bounded fades, focus pause, independent volume/mute persistence and sound routing")
	f.queue_free();await create_timer(.2).timeout;quit()
func collect(node,result:Array):
	if node is HSlider: result.append(node)
	for child in node.get_children(): collect(child,result)
